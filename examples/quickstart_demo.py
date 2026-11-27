# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Quickstart demonstration running the exact Python oracle across all four pillars."""

from __future__ import annotations

import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from weyl_magic import run_full_audit


def main() -> None:
    report = run_full_audit()
    print("=== Weyl-Magic-Stabilizer-Frontier Quickstart Demo ===")
    print(f"Pillar I   (Refutation of Erew-Goldstein Conj. 1): {report['pillar1']['refutes_conjecture1']} "
          f"(|PCliff_3|={report['pillar1']['pcliff3_order']}, |Stab|={report['pillar1']['stabilizer_count']}, "
          f"dim={report['pillar1']['joint_eigenspace_dim']})")
    print(f"Pillar II  (Cubic-Mod-3 Dichotomy & Mana Lock):    {report['pillar2']['all_dichotomy_match']} "
          f"({report['pillar2']['primes_checked']} primes verified)")
    print(f"Pillar III (Hoggar, Composite d=4, d=5 Saddle):    "
          f"Hoggar={report['pillar3']['hoggar_ratio_exact']} (<15/64), "
          f"v44_beats={report['pillar3']['v44_beats_mub']}, "
          f"d5_saddle={report['pillar3']['phi5_saddle_beats_alltop']}")
    print(f"Pillar IV  (Conj. 24 & Q(p,2) Witnesses):          "
          f"Conj24={report['pillar4']['conj24_d2_to_d7_ok']}, "
          f"Q(3,5,7,11)={report['pillar4']['qp2_line_witnesses_p3_5_7_11_ok']}")


if __name__ == "__main__":
    main()
