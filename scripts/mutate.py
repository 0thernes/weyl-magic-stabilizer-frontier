# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Surgical mutation-testing harness verifying 100% mutant kill rate across all four pillars
directly against `src/weyl_magic/oracle.py` (uses `-B` and purges `__pycache__` to prevent
sub-second same-byte-length `.pyc` cache poisoning)."""

from __future__ import annotations

import pathlib
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ORACLE = ROOT / "src" / "weyl_magic" / "oracle.py"

CHECK_SNIPPET = (
    "import sys; sys.path.insert(0, 'src'); "
    "from weyl_magic.oracle import run_full_audit; "
    "r = run_full_audit(); "
    "assert r['pillar1']['refutes_conjecture1'] is True; "
    "assert r['pillar1']['sl2_order'] == 24; "
    "assert r['pillar2']['all_dichotomy_match'] is True; "
    "assert r['pillar3']['hoggar_beats_mub'] is True; "
    "assert r['pillar3']['v44_beats_mub'] is True; "
    "assert r['pillar3']['phi5_saddle_beats_alltop'] is True; "
    "assert r['pillar4']['conj24_d2_to_d7_ok'] is True; "
    "assert r['pillar4']['qp2_line_witnesses_p3_5_7_11_ok'] is True"
)

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


def _purge_pycache() -> None:
    cache_dir = ORACLE.parent / "__pycache__"
    if cache_dir.exists():
        shutil.rmtree(cache_dir, ignore_errors=True)


def _run_check() -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, "-B", "-c", CHECK_SNIPPET],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
        check=False,
    )


def main() -> int:
    _purge_pycache()
    orig = ORACLE.read_text(encoding="utf-8")
    # Mandatory baseline green check so a broken oracle can never produce false mutant kills!
    base = _run_check()
    if base.returncode != 0:
        print(f"ERROR: Baseline oracle failed before mutation testing:\n{base.stderr}")
        return 2
    killed = 0
    try:
        for name, old, new in MUTANTS:
            assert old in orig, f"Mutant target missing: {name}"
            ORACLE.write_text(orig.replace(old, new, 1), encoding="utf-8")
            proc = _run_check()
            if proc.returncode != 0:
                killed += 1
                print(f"  [KILLED] {name}")
            else:
                print(f"  [SURVIVED] {name}")
    finally:
        ORACLE.write_text(orig, encoding="utf-8")
        _purge_pycache()
    print(f"Mutation summary: {killed}/{len(MUTANTS)} killed ({100.0 * killed / len(MUTANTS):.1f}%)")
    return 0 if killed == len(MUTANTS) else 1


if __name__ == "__main__":
    raise SystemExit(main())
