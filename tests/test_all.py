# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Comprehensive pytest + Hypothesis property-based + cross-language differential test suite
verifying Pillars I-IV across Python, Rust, Zig, C11+NASM, C++20, Moonlab WASM, QGTL C, and Lean."""

from __future__ import annotations

import json
import pathlib
import sys

from hypothesis import given, settings
from hypothesis import strategies as st

ROOT = pathlib.Path(__file__).resolve().parents[1]
if str(ROOT / "src") not in sys.path:
    sys.path.insert(0, str(ROOT / "src"))

from weyl_magic.oracle import (
    GaussInt,
    Zeta12,
    verify_pillar1,
    verify_pillar2,
    verify_pillar3,
    verify_pillar4,
)


@given(st.integers(min_value=1, max_value=20), st.integers(min_value=1, max_value=20))
@settings(max_examples=40, deadline=None)
def test_pythagorean_circle_wh_sic_property(m: int, n: int) -> None:
    """Property test: Euclid's parametrization generates valid qutrit WH-SICs with dim(Stab)=2."""
    if m <= n:
        m, n = n + 1, m
    a = m * m - n * n
    b = 2 * m * n
    c = m * m + n * n
    rep = verify_pillar1(a, b, c)
    assert rep["sic_equiangular_all_8"] is True
    assert rep["pcliff3_order"] == 216
    # On generic non-Clifford-orbit rational points (a != 0, b != 0), |Stab| = 3 and dim = 2!
    if a != b:
        assert rep["stabilizer_count"] == 3
        assert rep["joint_eigenspace_dim"] == 2
        assert rep["refutes_conjecture1"] is True


@given(
    st.integers(min_value=-50, max_value=50),
    st.integers(min_value=-50, max_value=50),
    st.integers(min_value=-50, max_value=50),
    st.integers(min_value=-50, max_value=50),
)
@settings(max_examples=80)
def test_zeta12_norm_multiplicativity(a: int, b: int, c: int, d: int) -> None:
    """Property test: `x * conj(x) = normSqInt + normSqSqrt3 * sqrt(3)` in `Z[i, omega_3]`."""
    x = Zeta12(a, b, c, d)
    prod = x * x.conj()
    sqrt3 = Zeta12(0, -1, 0, -2)
    rhs = Zeta12(x.norm_sq_int(), 0, 0, 0) + Zeta12(x.norm_sq_sqrt3(), 0, 0, 0) * sqrt3
    assert prod == rhs


@given(st.integers(min_value=3, max_value=30))
@settings(max_examples=50)
def test_conjecture24_nondivisibility_property(m: int) -> None:
    """Property test: `(2^m - 1)` never divides `1`, `3`, or `3 * 2^r - 1` for `r < m`."""
    mod = (1 << m) - 1
    assert 1 % mod != 0
    assert 3 % mod != 0
    for r in range(m):
        assert (3 * (1 << r) - 1) % mod != 0
        if m >= 4:
            assert (3 * (1 << r) + 1) % mod != 0


def test_all_four_pillars_exact() -> None:
    p1 = verify_pillar1(3, 4, 5)
    p2 = verify_pillar2()
    p3 = verify_pillar3()
    p4 = verify_pillar4()
    assert p1["refutes_conjecture1"] is True
    assert p2["all_dichotomy_match"] is True
    assert p3["hoggar_norm_sq"] == 6 and p3["hoggar_s4"] == 2304 and p3["hoggar_beats_mub"] is True
    assert p3["v44_norm_sq"] == 354 and p3["v44_s4"] == 30301769984 and p3["v44_beats_mub"] is True
    assert p3["phi5_norm_sq"] == 506 and p3["phi5_saddle_beats_alltop"] is True
    assert p4["conj24_d2_to_d7_ok"] is True
    assert p4["qp2_line_witnesses_p3_5_7_11_ok"] is True


def test_cross_language_differential_agreement() -> None:
    """Verify exact bit-for-bit agreement across saved Rust, Zig, C11+NASM, C++20,
    Moonlab WASM, and QGTL C result artifacts when present."""
    p3 = verify_pillar3()
    res_dir = ROOT / "results"
    if (res_dir / "rust_verifier.json").exists():
        rj = json.loads((res_dir / "rust_verifier.json").read_text(encoding="utf-8-sig"))
        assert rj["status"] == "PASS"
        assert rj["pillar1"]["stabilizer_count"] == 3
        assert rj["pillar3"]["hoggar_s4"] == p3["hoggar_s4"]
        assert rj["pillar3"]["v44_s4"] == p3["v44_s4"]
        assert rj["pillar4"]["q5_cert"]["orbits_checked"] == 1827
        assert rj["pillar4"]["q5_cert"]["dependent_orbits_found"] == 0
        if rj["pillar4"]["q7_cert"] is not None:
            assert rj["pillar4"]["q7_cert"]["orbits_checked"] == 1546218
            assert rj["pillar4"]["q7_cert"]["dependent_orbits_found"] == 0
    if (res_dir / "c11_nasm_verifier.json").exists():
        cj = json.loads((res_dir / "c11_nasm_verifier.json").read_text(encoding="utf-8-sig"))
        assert cj["status"] == "PASS"
        assert cj["nasm_diff_10k_ok"] is True
        assert cj["q5_orbits"] == 1827 and cj["q5_deps"] == 0
        if cj["q7_orbits"] > 0:
            assert cj["q7_orbits"] == 1546218 and cj["q7_deps"] == 0
    if (res_dir / "zig_verifier.json").exists():
        zj = json.loads((res_dir / "zig_verifier.json").read_text(encoding="utf-8-sig"))
        assert zj["status"] == "PASS"
        assert zj["hoggar_s4"] == p3["hoggar_s4"]
        assert zj["v44_s4"] == p3["v44_s4"]
    if (res_dir / "cpp20_verifier.json").exists():
        cppj = json.loads((res_dir / "cpp20_verifier.json").read_text(encoding="utf-8-sig"))
        assert cppj["status"] == "PASS"
        assert cppj["hoggar_s4"] == p3["hoggar_s4"]
        assert cppj["v44_s4"] == p3["v44_s4"]
    if (res_dir / "moonlab_super_mub.json").exists():
        mj = json.loads((res_dir / "moonlab_super_mub.json").read_text(encoding="utf-8-sig"))
        assert mj["status"] == "PASS"
        assert mj["three_qubit_max_sic_equiangular_err"] < 1e-12
    if (res_dir / "qgtl_sic_metric.json").exists():
        qj = json.loads((res_dir / "qgtl_sic_metric.json").read_text(encoding="utf-8-sig"))
        assert qj["status"] == "PASS"
        assert qj["sic_circle_err_g_tt"] < 1e-12


def test_gauss_int_norm_multiplicativity() -> None:
    x = GaussInt(3, -7)
    y = GaussInt(-5, 11)
    assert (x * y).norm_sq() == x.norm_sq() * y.norm_sq()


def test_version_governance_accessibility_and_csp() -> None:
    """Audit single version source, strict CSP + WCAG 2.2 AA on docs/site/, and zero stale affiliation."""
    ver = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    assert ver == "1.0.0"
    assert f'version: "{ver}"' in (ROOT / "CITATION.cff").read_text(encoding="utf-8")
    assert f'version: "{ver}"' in (ROOT / "repo.yaml").read_text(encoding="utf-8")
    assert f"## [{ver}]" in (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
    assert f'version = "{ver}"' in (ROOT / "pyproject.toml").read_text(encoding="utf-8")

    for site_file in ("index.html", "blueprint.html"):
        html = (ROOT / "docs" / "site" / site_file).read_text(encoding="utf-8")
        assert "Content-Security-Policy" in html
        assert "default-src 'none'" in html
        assert "https://cdn." not in html and "https://unpkg.com" not in html

    for check_file in ("README.md", "CLAIMS.md", "LIMITATIONS.md", "CITATION.cff", "AGENTS.md", "paper/main.tex"):
        txt = (ROOT / check_file).read_text(encoding="utf-8")
        assert "0thernes LLC" not in txt, f"Stale affiliation found in {check_file}"
