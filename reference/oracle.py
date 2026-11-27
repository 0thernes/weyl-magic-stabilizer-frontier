# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Independent reference oracle wrapper invoking `weyl_magic.oracle`."""

from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
if str(ROOT / "src") not in sys.path:
    sys.path.insert(0, str(ROOT / "src"))

from weyl_magic.oracle import run_full_audit


def main() -> int:
    report = run_full_audit()
    assert report["pillar1"]["refutes_conjecture1"] is True
    assert report["pillar2"]["all_dichotomy_match"] is True
    assert report["pillar3"]["hoggar_beats_mub"] is True
    assert report["pillar3"]["v44_beats_mub"] is True
    assert report["pillar3"]["phi5_saddle_beats_alltop"] is True
    assert report["pillar4"]["conj24_d2_to_d7_ok"] is True
    assert report["pillar4"]["qp2_line_witnesses_p3_5_7_11_ok"] is True
    print(json.dumps(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
