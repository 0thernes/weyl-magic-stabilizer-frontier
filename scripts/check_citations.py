# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Live bibliography verifier: checks EVERY arXiv ID and DOI in `paper/refs.bib`
against live arXiv API / Crossref API for HTTP 200, title overlap, author surname
match, publication year consistency, and Crossref retraction status (Playbook v1.3)."""

from __future__ import annotations

import json
import pathlib
import re
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
BIB = ROOT / "paper" / "refs.bib"
OUT_JSON = ROOT / "results" / "citation_audit.json"


def parse_bib(path: pathlib.Path) -> list[dict[str, str]]:
    text = path.read_text(encoding="utf-8")
    entries: list[dict[str, str]] = []
    chunks = re.split(r"\n(?=@\w+\{)", text.strip())
    for chunk in chunks:
        m = re.match(r"@(\w+)\{([^,]+),", chunk.strip())
        if not m:
            continue
        rec: dict[str, str] = {"type": m.group(1), "key": m.group(2).strip()}
        for fm in re.finditer(r"(\w+)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}", chunk):
            rec[fm.group(1).lower()] = re.sub(r"\s+", " ", fm.group(2)).strip()
        entries.append(rec)
    return entries


def normalize_words(s: str) -> set[str]:
    clean = re.sub(r"[{}\\$']", "", s.lower())
    return {w for w in re.findall(r"[a-z0-9]{4,}", clean)}


def extract_surnames(author_field: str) -> set[str]:
    surnames: set[str] = set()
    for part in re.split(r"\s+and\s+", author_field):
        clean = re.sub(r"[{}\\']", "", part).strip()
        if not clean:
            continue
        if "," in clean:
            surname = clean.split(",")[0].strip().lower()
        else:
            surname = clean.split()[-1].strip().lower()
        # Keep hyphenated components as individual tokens too
        for tok in re.findall(r"[a-z]{2,}", surname):
            surnames.add(tok)
    return surnames


def check_doi(doi: str, expected_title: str, expected_authors: str, expected_year: str) -> dict[str, object]:
    url = f"https://api.crossref.org/works/{doi}"
    req = urllib.request.Request(url, headers={"User-Agent": "0thernes-citation-audit/2.0 (mailto:0_0@0thernes.art)"})
    with urllib.request.urlopen(req, timeout=20) as r:
        data = json.loads(r.read().decode("utf-8"))["message"]
    live_title = (data.get("title") or [""])[0]
    updates = data.get("update-to") or []
    retracted = any("retract" in str(u.get("type", "")).lower() for u in updates)
    w_exp = normalize_words(expected_title)
    w_live = normalize_words(live_title)
    overlap = len(w_exp & w_live) / max(1, len(w_exp))

    live_surnames: set[str] = set()
    for a in data.get("author") or []:
        fam = str(a.get("family", "")).lower()
        for tok in re.findall(r"[a-z]{2,}", fam):
            live_surnames.add(tok)
    exp_surnames = extract_surnames(expected_authors)
    author_overlap = len(exp_surnames & live_surnames) / max(1, len(exp_surnames))

    live_year: int | None = None
    for key in ("published-print", "published-online", "issued", "created"):
        parts = (data.get(key) or {}).get("date-parts") or []
        if parts and parts[0] and parts[0][0]:
            live_year = int(parts[0][0])
            break
    bib_year = int(expected_year) if expected_year.isdigit() else None
    year_ok = bib_year is not None and live_year is not None and abs(bib_year - live_year) <= 1

    return {
        "source": "crossref",
        "id": doi,
        "http": 200,
        "live_title": live_title,
        "title_overlap": round(overlap, 3),
        "author_surname_overlap": round(author_overlap, 3),
        "bib_year": bib_year,
        "live_year": live_year,
        "year_ok": year_ok,
        "retracted": retracted,
        "ok": overlap >= 0.5 and author_overlap >= 0.5 and year_ok and not retracted,
    }


def check_arxiv(eprint: str, expected_title: str, expected_authors: str, expected_year: str) -> dict[str, object]:
    clean_id = re.sub(r"v\d+$", "", eprint.strip())
    url = f"https://export.arxiv.org/api/query?id_list={clean_id}"
    req = urllib.request.Request(url, headers={"User-Agent": "0thernes-citation-audit/2.0"})
    with urllib.request.urlopen(req, timeout=20) as r:
        xml_data = r.read().decode("utf-8")
    root = ET.fromstring(xml_data)
    ns = {"a": "http://www.w3.org/2005/Atom"}
    entry = root.find("a:entry", ns)
    live_title = ""
    live_surnames: set[str] = set()
    live_year: int | None = None
    updated_year: int | None = None
    if entry is not None:
        t_el = entry.find("a:title", ns)
        if t_el is not None and t_el.text:
            live_title = re.sub(r"\s+", " ", t_el.text).strip()
        for a_el in entry.findall("a:author", ns):
            n_el = a_el.find("a:name", ns)
            if n_el is not None and n_el.text:
                live_surnames |= extract_surnames(n_el.text)
        pub_el = entry.find("a:published", ns)
        if pub_el is not None and pub_el.text and len(pub_el.text) >= 4:
            live_year = int(pub_el.text[:4])
        upd_el = entry.find("a:updated", ns)
        if upd_el is not None and upd_el.text and len(upd_el.text) >= 4:
            updated_year = int(upd_el.text[:4])

    w_exp = normalize_words(expected_title)
    w_live = normalize_words(live_title)
    overlap = len(w_exp & w_live) / max(1, len(w_exp))
    exp_surnames = extract_surnames(expected_authors)
    author_overlap = len(exp_surnames & live_surnames) / max(1, len(exp_surnames))
    bib_year = int(expected_year) if expected_year.isdigit() else None
    # Accept either published year or revision updated year for revised arXiv v2 preprints
    year_ok = bib_year is not None and (
        (live_year is not None and abs(bib_year - live_year) <= 1)
        or (updated_year is not None and bib_year == updated_year)
    )
    return {
        "source": "arxiv",
        "id": eprint,
        "http": 200,
        "live_title": live_title,
        "title_overlap": round(overlap, 3),
        "author_surname_overlap": round(author_overlap, 3),
        "bib_year": bib_year,
        "live_year": updated_year or live_year,
        "year_ok": year_ok,
        "retracted": False,
        "ok": overlap >= 0.5 and author_overlap >= 0.5 and year_ok,
    }


def main() -> int:
    if not BIB.exists():
        print(f"ERROR: Missing {BIB}")
        return 1
    entries = parse_bib(BIB)
    results = []
    all_ok = True
    for ent in entries:
        key = ent["key"]
        title = ent.get("title", "")
        author = ent.get("author", "")
        year = ent.get("year", "")
        doi = ent.get("doi", "")
        eprint = ent.get("eprint", "")
        try:
            if doi:
                res = check_doi(doi, title, author, year)
            elif eprint:
                res = check_arxiv(eprint, title, author, year)
            else:
                res = {"source": "none", "id": "", "http": 0, "live_title": "", "title_overlap": 0.0, "author_surname_overlap": 0.0, "year_ok": False, "retracted": False, "ok": False}
        except (urllib.error.URLError, TimeoutError, ValueError) as exc:
            res = {"source": "error", "id": doi or eprint, "error": str(exc), "ok": False}
        res["key"] = key
        res["bib_title"] = title
        results.append(res)
        status = "PASS" if res.get("ok") else "FAIL"
        print(
            f"  [{status}] {key:24s} ({res.get('source')}:{res.get('id')}) "
            f"title={res.get('title_overlap', 0)} author={res.get('author_surname_overlap', 0)} year={res.get('bib_year')}/{res.get('live_year')}"
        )
        if not res.get("ok"):
            all_ok = False
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps({"status": "PASS" if all_ok else "FAIL", "entries": results}, indent=2) + "\n", encoding="utf-8")
    print(f"Citation audit: {sum(1 for r in results if r.get('ok'))}/{len(results)} verified live (title + author + year + retraction)")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
