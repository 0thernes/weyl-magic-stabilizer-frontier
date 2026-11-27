# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Anti-drift guard: verifies README.md's verbatim `#print axioms` block matches
results/lean_axioms.txt and enforces that EVERY audited declaration depends ONLY on
standard Lean 4 axioms {propext, Classical.choice, Quot.sound} with zero sorryAx,
zero native_decide, and zero custom axioms."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def parse_axiom_lines(text: str) -> dict[str, list[str]]:
    # Rejoin multi-line Lean `#print axioms` wraps (lines starting with whitespace)
    logical_lines: list[str] = []
    for raw in text.splitlines():
        if not raw.strip():
            continue
        if raw[0].isspace() and logical_lines:
            logical_lines[-1] = logical_lines[-1].rstrip() + " " + raw.strip()
        else:
            logical_lines.append(raw.strip())

    found: dict[str, list[str]] = {}
    for line in logical_lines:
        m_no = re.match(r"^'([^']+)' does not depend on any axioms$", line)
        if m_no:
            found[m_no.group(1)] = []
            continue
        m_dep = re.match(r"^'([^']+)' depends on axioms:\s*\[([^\]]*)\]$", line)
        if m_dep:
            axioms = [a.strip() for a in m_dep.group(2).split(",") if a.strip()]
            found[m_dep.group(1)] = axioms
    return found


def main() -> int:
    axioms_path = ROOT / "results" / "lean_axioms.txt"
    readme_path = ROOT / "README.md"
    if not axioms_path.exists():
        print(f"ERROR: missing {axioms_path}", file=sys.stderr)
        return 1
    if not readme_path.exists():
        print(f"ERROR: missing {readme_path}", file=sys.stderr)
        return 1

    axioms_text = axioms_path.read_text(encoding="utf-8").replace("\r\n", "\n").strip()
    readme_text = readme_path.read_text(encoding="utf-8").replace("\r\n", "\n")

    parsed = parse_axiom_lines(axioms_text)
    if len(parsed) != 31:
        print(f"ERROR: expected exactly 31 audited declarations, found {len(parsed)}", file=sys.stderr)
        return 1

    for decl, axs in parsed.items():
        bad = [a for a in axs if a not in ALLOWED_AXIOMS]
        if bad:
            print(f"ERROR: declaration {decl} uses disallowed axioms: {bad}", file=sys.stderr)
            return 1

    if axioms_text not in readme_text:
        for line in axioms_text.splitlines():
            stripped = line.strip()
            if stripped and stripped not in readme_text:
                print(f"ERROR: README.md drift — missing verbatim axiom line:\n  {stripped}", file=sys.stderr)
                return 1

    print(
        f"PASS: {len(parsed)}/31 audited declarations strictly within "
        f"{sorted(ALLOWED_AXIOMS)} and verbatim in README.md."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
