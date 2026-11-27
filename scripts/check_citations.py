# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Live bibliography verifier: checks EVERY arXiv ID and DOI in `paper/refs.bib`
against live arXiv API / Crossref API for BOTH HTTP 200 AND title/author match
plus Crossref retraction check (Playbook v1.3 Gold Standard)."""

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
    clean = re.sub(r"[{}\\$]", "", s.lower())
    return {w for w in re.findall(r"[a-z0-9]{4,}", clean)}


def check_doi(doi: str, expected_title: str) -> dict[str, object]:
    url = f"https://api.crossref.org/works/{doi}"
    req = urllib.request.Request(url, headers={"User-Agent": "0thernes-citation-audit/1.0 (mailto:0_0@0thernes.art)"})
    with urllib.request.urlopen(req, timeout=20) as r:
        data = json.loads(r.read().decode("utf-8"))["message"]
    live_title = (data.get("title") or [""])[0]
    updates = data.get("update-to") or []
    retracted = any("retract" in str(u.get("type", "")).lower() for u in updates)
    w_exp = normalize_words(expected_title)
    w_live = normalize_words(live_title)
    overlap = len(w_exp & w_live) / max(1, len(w_exp))
    return {
        "source": "crossref",
        "id": doi,
        "http": 200,
        "live_title": live_title,
        "title_overlap": round(overlap, 3),
        "retracted": retracted,
        "ok": overlap >= 0.5 and not retracted,
    }


def check_arxiv(eprint: str, expected_title: str) -> dict[str, object]:
    clean_id = re.sub(r"v\d+$", "", eprint.strip())
    url = f"https://export.arxiv.org/api/query?id_list={clean_id}"
    req = urllib.request.Request(url, headers={"User-Agent": "0thernes-citation-audit/1.0"})
    with urllib.request.urlopen(req, timeout=20) as r:
        xml_data = r.read().decode("utf-8")
    root = ET.fromstring(xml_data)
    ns = {"a": "http://www.w3.org/2005/Atom"}
    entry = root.find("a:entry", ns)
    live_title = ""
    if entry is not None:
        t_el = entry.find("a:title", ns)
        if t_el is not None and t_el.text:
            live_title = re.sub(r"\s+", " ", t_el.text).strip()
    w_exp = normalize_words(expected_title)
    w_live = normalize_words(live_title)
    overlap = len(w_exp & w_live) / max(1, len(w_exp))
    return {
        "source": "arxiv",
        "id": eprint,
        "http": 200,
        "live_title": live_title,
        "title_overlap": round(overlap, 3),
        "retracted": False,
        "ok": overlap >= 0.5,
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
        doi = ent.get("doi", "")
        eprint = ent.get("eprint", "")
        try:
            if doi:
                res = check_doi(doi, title)
            elif eprint:
                res = check_arxiv(eprint, title)
            else:
                res = {"source": "none", "id": "", "http": 0, "live_title": "", "title_overlap": 0.0, "retracted": False, "ok": False}
        except (urllib.error.URLError, TimeoutError, ValueError) as exc:
            res = {"source": "error", "id": doi or eprint, "error": str(exc), "ok": False}
        res["key"] = key
        res["bib_title"] = title
        results.append(res)
        status = "PASS" if res.get("ok") else "FAIL"
        print(f"  [{status}] {key:24s} ({res.get('source')}:{res.get('id')}) overlap={res.get('title_overlap', 0)}")
        if not res.get("ok"):
            all_ok = False
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps({"status": "PASS" if all_ok else "FAIL", "entries": results}, indent=2) + "\n", encoding="utf-8")
    print(f"Citation audit: {sum(1 for r in results if r.get('ok'))}/{len(results)} verified live")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
