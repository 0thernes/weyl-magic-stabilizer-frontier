# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Surgical mutation-testing harness verifying 100% mutant kill rate across all four pillars."""

from __future__ import annotations

import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ORACLE = ROOT / "src" / "weyl_magic" / "oracle.py"

MUTANTS = [
    ("M1_pillar1_det_sign", "(aa * dd + 2 * bb * cc) % 3 == 1", "(aa * dd + bb * cc) % 3 == 1"),
    ("M2_pillar1_equiang", "4 * ov.norm_sq_int() != 4 * (c**4)", "4 * ov.norm_sq_int() != 5 * (c**4)"),
    ("M3_pillar2_mod3", "expected = (p % 3 == 2)", "expected = (p % 3 == 1)"),
    ("M4_pillar3_hoggar_bound", "Fraction(15, 64)", "Fraction(1, 64)"),
    ("M5_pillar3_v44_bound", "Fraction(31, 256)", "Fraction(1, 256)"),
    ("M6_pillar3_saddle_sign", "u < 0 and (v_s5 <= 0", "u > 0 and (v_s5 <= 0"),
    ("M7_pillar4_conj24_exp", "tau_e[(3 * j) % n]", "tau_e[(7 * j) % n]"),
    ("M8_pillar4_conic_exp", "tau_h[(2 * i) % n]", "tau_h[(3 * i) % n]"),
]


def main() -> int:
    orig = ORACLE.read_text(encoding="utf-8")
    # Mandatory baseline green check so a broken oracle can never produce false mutant kills!
    base = subprocess.run(
        [sys.executable, str(ROOT / "reference" / "oracle.py")],
        capture_output=True,
        text=True,
        check=False,
    )
    if base.returncode != 0:
        print(f"ERROR: Baseline oracle failed before mutation testing:\n{base.stderr}")
        return 2
    killed = 0
    try:
        for name, old, new in MUTANTS:
            assert old in orig, f"Mutant target missing: {name}"
            ORACLE.write_text(orig.replace(old, new, 1), encoding="utf-8")
            proc = subprocess.run(
                [sys.executable, str(ROOT / "reference" / "oracle.py")],
                capture_output=True,
                text=True,
                check=False,
            )
            if proc.returncode != 0:
                killed += 1
                print(f"  [KILLED] {name}")
            else:
                print(f"  [SURVIVED] {name}")
    finally:
        ORACLE.write_text(orig, encoding="utf-8")
    print(f"Mutation summary: {killed}/{len(MUTANTS)} killed ({100.0 * killed / len(MUTANTS):.1f}%)")
    return 0 if killed == len(MUTANTS) else 1


if __name__ == "__main__":
    raise SystemExit(main())
