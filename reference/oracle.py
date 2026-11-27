# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Independent, zero-import-from-`weyl_magic` naive reference oracle (Build Standard B12).

Implements the simplest possible readable reference calculations using only Python's
standard library (`cmath`, `fractions`, `math`) so `tests/test_all.py` can perform
genuine differential testing against `src/weyl_magic/oracle.py` without circularity.
"""

from __future__ import annotations

import cmath
import json
import math
from fractions import Fraction
from typing import Any


def ref_verify_pillar1(a: int = 3, b: int = 4, c: int = 5) -> dict[str, Any]:
    """Naive complex-arithmetic reference check of d=3 WH-SIC equiangularity and PCliff_3 stabilizer."""
    if a * a + b * b != c * c or c <= 0:
        raise ValueError("Require a^2 + b^2 = c^2 with c > 0")
    omega = cmath.exp(2j * math.pi / 3.0)
    norm = math.sqrt(2.0 * c * c)
    v = [0j, complex(c, 0) / norm, complex(-a, -b) / norm]

    def act_wh(p: int, q: int, u: list[complex]) -> list[complex]:
        return [(omega ** ((q * ((y - p) % 3)) % 3)) * u[(y - p) % 3] for y in range(3)]

    def inner(u: list[complex], w: list[complex]) -> complex:
        return sum(x.conjugate() * y for x, y in zip(u, w))

    sic_ok = True
    for p in range(3):
        for q in range(3):
            if p == 0 and q == 0:
                continue
            ov_sq = abs(inner(v, act_wh(p, q, v))) ** 2
            if abs(ov_sq - 0.25) > 1e-12:
                sic_ok = False

    sl2 = [
        (aa, bb, cc, dd)
        for aa in range(3)
        for bb in range(3)
        for cc in range(3)
        for dd in range(3)
        if (aa * dd - bb * cc) % 3 == 1
    ]

    def act_meta(f: tuple[int, int, int, int], u: list[complex]) -> list[complex]:
        aa, bb, cc, dd = f
        scale = 1.0 if bb == 0 else (1.0 / math.sqrt(3.0))
        out = []
        for y in range(3):
            s = 0j
            for x in range(3):
                if bb == 0:
                    ent = (omega ** ((2 * cc * aa * x * x) % 3)) if y == (aa * x) % 3 else 0j
                else:
                    ent = scale * (omega ** ((2 * bb * (dd * y * y + x * y + aa * x * x)) % 3))
                s += ent * u[x]
            out.append(s)
        return out

    stabs = []
    for p in range(3):
        for q in range(3):
            for f in sl2:
                w = act_wh(p, q, act_meta(f, v))
                if abs(abs(inner(v, w)) - 1.0) < 1e-11:
                    stabs.append((p, q, f))

    e1 = [0j, 1 + 0j, 0j]
    e2 = [0j, 0j, 1 + 0j]
    dim2_ok = len(stabs) == 3
    for p, q, f in stabs:
        phase = inner(v, act_wh(p, q, act_meta(f, v)))
        w1 = act_wh(p, q, act_meta(f, e1))
        w2 = act_wh(p, q, act_meta(f, e2))
        err1 = math.sqrt(sum(abs(w1[i] - phase * e1[i]) ** 2 for i in range(3)))
        err2 = math.sqrt(sum(abs(w2[i] - phase * e2[i]) ** 2 for i in range(3)))
        if err1 > 1e-11 or err2 > 1e-11:
            dim2_ok = False

    return {
        "sl2_order": len(sl2),
        "pcliff3_order": 9 * len(sl2),
        "sic_equiangular_all_8": sic_ok,
        "stabilizer_count": len(stabs),
        "joint_eigenspace_dim": 2 if dim2_ok else 0,
        "refutes_conjecture1": sic_ok and dim2_ok and len(stabs) == 3,
    }


def ref_verify_pillar2(primes: tuple[int, ...] = (5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47)) -> dict[str, Any]:
    """Naive complex-sum reference check of the Cubic-Mod-3 Wigner origin dichotomy."""
    all_ok = True
    for p in primes:
        om = cmath.exp(2j * math.pi / p)
        s = sum(om ** (((-2) * (x**3)) % p) for x in range(p))
        vanishes = abs(s) < 1e-10
        if vanishes != (p % 3 == 2):
            all_ok = False
    return {"primes_checked": len(primes), "all_dichotomy_match": all_ok}


def ref_verify_pillar3() -> dict[str, Any]:
    """Naive reference check of Hoggar (D=8), Composite d=4 (D=16), and d=5 Alltop saddle."""
    vh = [1 + 1j, 0j, -1 + 0j, 1 + 0j, -1j, -1 + 0j, 0j, 0j]
    h_norm = round(sum(abs(z) ** 2 for z in vh))
    h_s4 = 0
    for a in range(8):
        for b in range(8):
            ov = sum(
                vh[x].conjugate()
                * vh[x ^ a]
                * (1 if (((x & b) & 1) + (((x & b) >> 1) & 1) + (((x & b) >> 2) & 1)) % 2 == 0 else -1)
                for x in range(8)
            )
            h_s4 += round(abs(ov) ** 2) ** 2

    v44 = [
        8 + 0j, -1 + 2j, -4j, 7 + 0j,
        -1j, 5 - 4j, -1 + 1j, -5 + 5j,
        6 + 0j, 7 + 1j, -2j, 1 + 3j,
        1j, 1 + 2j, 1 + 1j, -3 - 3j,
    ]
    v44_norm = round(sum(abs(z) ** 2 for z in v44))
    v44_s4 = 0
    for p1 in range(4):
        for p2 in range(4):
            for q1 in range(4):
                for q2 in range(4):
                    ov = 0j
                    for x1 in range(4):
                        for x2 in range(4):
                            ov += v44[4 * x1 + x2].conjugate() * ((1j ** ((q1 * x1 + q2 * x2) % 4)) * v44[4 * ((x1 + p1) % 4) + ((x2 + p2) % 4)])
                    v44_s4 += round(abs(ov) ** 2) ** 2

    om5 = cmath.exp(2j * math.pi / 5.0)
    amps = [12, 9, 10, 10, 9]
    phi5_norm = sum(a * a for a in amps)
    phi5 = [amps[x] * (om5 ** ((x**3) % 5)) / math.sqrt(phi5_norm) for x in range(5)]
    s5_over_5 = 0.0
    for p in range(5):
        for q in range(5):
            ov = sum(phi5[x].conjugate() * (om5 ** ((q * x) % 5)) * phi5[(x + p) % 5] for x in range(5))
            s5_over_5 += abs(ov) ** 4
    s5_over_5 /= 5.0

    return {
        "hoggar_norm_sq": h_norm,
        "hoggar_s4": h_s4,
        "hoggar_beats_mub": Fraction(h_s4, 8 * (h_norm**4)) < Fraction(15, 64),
        "v44_norm_sq": v44_norm,
        "v44_s4": v44_s4,
        "v44_beats_mub": Fraction(v44_s4, 16 * (v44_norm**4)) < Fraction(31, 256),
        "phi5_norm_sq": phi5_norm,
        "phi5_s4_over_5": s5_over_5,
        "phi5_saddle_beats_alltop": s5_over_5 < 0.36 - 1e-4,
    }


def ref_verify_pillar4() -> dict[str, Any]:
    """Naive reference check of Conjecture 24 non-divisibility (m=3..12) and Remark-21."""
    ok = True
    for m in range(3, 13):
        mod = (1 << m) - 1
        if 1 % mod == 0 or 3 % mod == 0:
            ok = False
        for r in range(m):
            if (3 * (1 << r) - 1) % mod == 0:
                ok = False
            if m >= 4 and (3 * (1 << r) + 1) % mod == 0:
                ok = False
    rem21_d2_divides = (3 * 2 + 1) % ((1 << 3) - 1) == 0
    return {"conj24_nondiv_m3_to_m12_ok": ok and rem21_d2_divides}


def run_reference_audit() -> dict[str, Any]:
    return {
        "status": "PASS",
        "engine": "independent-naive-reference-oracle",
        "pillar1": ref_verify_pillar1(),
        "pillar2": ref_verify_pillar2(),
        "pillar3": ref_verify_pillar3(),
        "pillar4": ref_verify_pillar4(),
    }


def main() -> int:
    report = run_reference_audit()
    assert report["pillar1"]["refutes_conjecture1"] is True
    assert report["pillar2"]["all_dichotomy_match"] is True
    assert report["pillar3"]["hoggar_beats_mub"] is True
    assert report["pillar3"]["v44_beats_mub"] is True
    assert report["pillar3"]["phi5_saddle_beats_alltop"] is True
    assert report["pillar4"]["conj24_nondiv_m3_to_m12_ok"] is True
    print(json.dumps(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
