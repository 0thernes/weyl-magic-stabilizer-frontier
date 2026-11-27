# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Normalize tracked text line endings to LF (except .ps1/.bat/.cmd) and generate
deterministic SHA-256 manifests (`data/MANIFEST.sha256` and root `MANIFEST.sha256`)."""

from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

TEXT_EXTS = {
    ".lean", ".toml", ".json", ".yaml", ".yml", ".rs", ".zig", ".c", ".h", ".cpp",
    ".hpp", ".asm", ".esk", ".mjs", ".js", ".py", ".sh", ".tex", ".bib", ".md",
    ".txt", ".html", ".svg", ".cff", ".tsv", ".mdc", ".log", ".gitignore", ".gitattributes",
    ".editorconfig",
}
CRLF_EXTS = {".ps1", ".bat", ".cmd"}
SKIP_DIRS = {
    ".git", ".lake", "target", ".zig-cache", "zig-out", "build", "__pycache__",
    ".pytest_cache", ".mypy_cache", ".ruff_cache", ".hypothesis", ".venv", "venv",
}


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def normalize_lf() -> int:
    converted = 0
    for p in sorted(ROOT.rglob("*")):
        if not p.is_file():
            continue
        if any(part in SKIP_DIRS or part.endswith(".egg-info") for part in p.relative_to(ROOT).parts):
            continue
        if p.suffix.lower() in CRLF_EXTS:
            continue
        if p.suffix.lower() in TEXT_EXTS or p.name in {
            "VERSION", "LICENSE", "LICENSE-DOCS", "justfile", "Makefile", "REUSE.toml",
            ".gitignore", ".gitattributes", ".editorconfig",
        }:
            raw = p.read_bytes()
            if b"\r\n" in raw:
                p.write_bytes(raw.replace(b"\r\n", b"\n"))
                converted += 1
    return converted


def write_manifest(out_path: Path, rel_paths: list[Path]) -> None:
    lines = [f"{sha256_file(ROOT / rp)}  {rp.as_posix()}" for rp in sorted(rel_paths)]
    out_path.write_bytes(("\n".join(lines) + "\n").encode("utf-8"))
    print(f"Wrote {out_path.relative_to(ROOT)} ({len(lines)} entries)")


def main() -> int:
    converted = normalize_lf()
    print(f"Normalized {converted} text files to LF.")

    data_targets: list[Path] = []
    for folder in ("results", "dist", "paper/figures"):
        d = ROOT / folder
        if d.exists():
            for p in sorted(d.rglob("*")):
                if p.is_file() and not p.name.endswith(("_local.txt", ".tsr", ".ots")):
                    data_targets.append(p.relative_to(ROOT))
    (ROOT / "data").mkdir(exist_ok=True)
    write_manifest(ROOT / "data" / "MANIFEST.sha256", data_targets)

    root_targets: list[Path] = []
    for folder in ("lean", "rust/src", "zig/src", "c/src", "cpp/src", "asm", "eshkol",
                   "quantum_stack", "src", "reference", "tests", "examples", "paper",
                   "dist", "results", "docs/site"):
        d = ROOT / folder
        if not d.exists():
            continue
        for p in sorted(d.rglob("*")):
            if not p.is_file():
                continue
            rel = p.relative_to(ROOT)
            if any(part in SKIP_DIRS or part.endswith(".egg-info") for part in rel.parts):
                continue
            if rel.as_posix().startswith("paper/build/"):
                continue
            if p.name.endswith(("_local.txt", ".pyc", ".exe", ".o", ".obj")):
                continue
            root_targets.append(rel)
    for extra in ("VERSION", "CITATION.cff", "REUSE.toml", "repo.yaml", "justfile",
                  "pyproject.toml", "requirements.lock.txt", "data/MANIFEST.sha256"):
        if (ROOT / extra).exists():
            root_targets.append(Path(extra))
    # Deduplicate preserving sort order
    unique_root = sorted(set(root_targets))
    write_manifest(ROOT / "MANIFEST.sha256", unique_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
