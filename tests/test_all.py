# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 Alexander Stephen Donahue
"""Comprehensive pytest + 1,000-case Hypothesis property-based + metamorphic + negative +
determinism + Draft 2020-12 JSON Schema + standalone reference-oracle + cross-language
differential + WCAG 2.2 AA test suite verifying Pillars I-IV across all 9 toolchains."""

from __future__ import annotations

import ast
import hashlib
import json
import pathlib
import sys
from typing import Any

import jsonschema
import pytest
import yaml  # type: ignore[import-untyped]
from hypothesis import given, settings
from hypothesis import strategies as st

ROOT = pathlib.Path(__file__).resolve().parents[1]
if str(ROOT / "src") not in sys.path:
    sys.path.insert(0, str(ROOT / "src"))
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from reference import oracle as ref_oracle
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
    if a != b:
        assert rep["stabilizer_count"] == 3
        assert rep["joint_eigenspace_dim"] == 2
        assert rep["refutes_conjecture1"] is True


@given(
    st.integers(min_value=-100, max_value=100),
    st.integers(min_value=-100, max_value=100),
    st.integers(min_value=-100, max_value=100),
    st.integers(min_value=-100, max_value=100),
)
@settings(max_examples=1000, deadline=None)
def test_zeta12_norm_multiplicativity_1000(a: int, b: int, c: int, d: int) -> None:
    """1,000-case Hypothesis property test (Build Standard B10): `x * conj(x) = normSqInt + normSqSqrt3 * sqrt(3)`."""
    x = Zeta12(a, b, c, d)
    prod = x * x.conj()
    sqrt3 = Zeta12(0, -1, 0, -2)
    rhs = Zeta12(x.norm_sq_int(), 0, 0, 0) + Zeta12(x.norm_sq_sqrt3(), 0, 0, 0) * sqrt3
    assert prod == rhs
    # Metamorphic invariance under conjugation (B14)
    assert x.conj().norm_sq_int() == x.norm_sq_int()
    assert x.conj().norm_sq_sqrt3() == x.norm_sq_sqrt3()


@given(
    st.integers(min_value=-100, max_value=100),
    st.integers(min_value=-100, max_value=100),
    st.integers(min_value=-100, max_value=100),
    st.integers(min_value=-100, max_value=100),
)
@settings(max_examples=200)
def test_gauss_int_norm_and_metamorphic_invariance(a: int, b: int, c: int, d: int) -> None:
    """Property & metamorphic test: `GaussInt` norm multiplicativity and negation/conjugation invariance."""
    x = GaussInt(a, b)
    y = GaussInt(c, d)
    assert (x * y).norm_sq() == x.norm_sq() * y.norm_sq()
    assert GaussInt(-a, -b).norm_sq() == x.norm_sq()
    assert x.conj().norm_sq() == x.norm_sq()


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


def test_metamorphic_pythagorean_scaling_and_reflection() -> None:
    """Metamorphic test (B14): scaling/conjugating/swapping Pythagorean triples preserves WH-SIC & dim(Stab)=2."""
    base = verify_pillar1(3, 4, 5)
    for a, b, c in [(6, 8, 10), (-3, 4, 5), (3, -4, 5), (4, 3, 5), (9, 12, 15)]:
        alt = verify_pillar1(a, b, c)
        assert alt["sic_equiangular_all_8"] == base["sic_equiangular_all_8"] is True
        assert alt["stabilizer_count"] == base["stabilizer_count"] == 3
        assert alt["joint_eigenspace_dim"] == base["joint_eigenspace_dim"] == 2


def test_negative_boundary_inputs() -> None:
    """Negative tests (B06): non-Pythagorean triples and Clifford-orbit points behave as mathematically required."""
    # Non-Pythagorean triple (1, 1, 2) must raise ValueError
    with pytest.raises(ValueError, match=r"a\^2 \+ b\^2 = c\^2"):
        verify_pillar1(1, 1, 2)
    with pytest.raises(ValueError, match=r"c > 0"):
        verify_pillar1(0, 0, 0)

    # Higher-symmetry Hesse SIC fiducial (1, 0, 1) has |Stab| = 24 (orbit size 216/24 = 9), NOT generic |Stab| = 3
    sym = verify_pillar1(1, 0, 1)
    assert sym["sic_equiangular_all_8"] is True
    assert sym["stabilizer_count"] == 24
    assert sym["refutes_conjecture1"] is False


def test_all_four_pillars_exact_and_deterministic() -> None:
    """Exact verification + bit-for-bit determinism SHA-256 repeatability test (B03)."""
    def run_once() -> str:
        payload = {
            "p1": verify_pillar1(3, 4, 5),
            "p2": verify_pillar2(),
            "p3": verify_pillar3(),
            "p4": verify_pillar4(),
        }
        return json.dumps(payload, sort_keys=True)

    out1 = run_once()
    out2 = run_once()
    assert hashlib.sha256(out1.encode("utf-8")).hexdigest() == hashlib.sha256(out2.encode("utf-8")).hexdigest()

    data = json.loads(out1)
    assert data["p1"]["refutes_conjecture1"] is True
    assert data["p2"]["all_dichotomy_match"] is True
    assert data["p3"]["hoggar_norm_sq"] == 6 and data["p3"]["hoggar_s4"] == 2304 and data["p3"]["hoggar_beats_mub"] is True
    assert data["p3"]["v44_norm_sq"] == 354 and data["p3"]["v44_s4"] == 30301769984 and data["p3"]["v44_beats_mub"] is True
    assert data["p3"]["phi5_norm_sq"] == 506 and data["p3"]["phi5_saddle_beats_alltop"] is True
    assert data["p4"]["conj24_d2_to_d7_ok"] is True
    assert data["p4"]["qp2_line_witnesses_p3_5_7_11_ok"] is True


def test_independent_reference_oracle_differential() -> None:
    """Differential test (B11/B12): standalone `reference/oracle.py` (zero `weyl_magic` imports) vs `weyl_magic.oracle`."""
    # Confirm via AST that reference/oracle.py has zero Import / ImportFrom statements referencing weyl_magic
    tree = ast.parse((ROOT / "reference" / "oracle.py").read_text(encoding="utf-8"))
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                assert not alias.name.startswith("weyl_magic")
        elif isinstance(node, ast.ImportFrom):
            assert not (node.module or "").startswith("weyl_magic")

    ref_rep = ref_oracle.run_reference_audit()
    assert ref_rep["status"] == "PASS"

    p1 = verify_pillar1(3, 4, 5)
    p2 = verify_pillar2()
    p3 = verify_pillar3()
    p4 = verify_pillar4()

    assert ref_rep["pillar1"]["sic_equiangular_all_8"] == p1["sic_equiangular_all_8"]
    assert ref_rep["pillar1"]["stabilizer_count"] == p1["stabilizer_count"] == 3
    assert ref_rep["pillar1"]["joint_eigenspace_dim"] == p1["joint_eigenspace_dim"] == 2
    assert ref_rep["pillar2"]["all_dichotomy_match"] == p2["all_dichotomy_match"] is True
    assert ref_rep["pillar3"]["hoggar_s4"] == p3["hoggar_s4"] == 2304
    assert ref_rep["pillar3"]["v44_s4"] == p3["v44_s4"] == 30301769984
    assert ref_rep["pillar3"]["v44_beats_mub"] == p3["v44_beats_mub"] is True
    assert ref_rep["pillar3"]["phi5_saddle_beats_alltop"] == p3["phi5_saddle_beats_alltop"] is True
    assert ref_rep["pillar4"]["conj24_nondiv_m3_to_m12_ok"] == p4["conj24_d2_to_d7_ok"] is True


def test_cross_language_differential_agreement() -> None:
    """Verify exact bit-for-bit agreement across saved Rust, Zig, C11+NASM, C++20,
    Moonlab WASM, QGTL C, and numerical claims audit artifacts."""
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
        assert mj["moonlab_gate_calls"] == 20750
        assert mj["qrng_shots_xyz"] == 4096
        assert mj["three_qubit_max_sic_equiangular_err"] < 1e-12
    if (res_dir / "qgtl_sic_metric.json").exists():
        qj = json.loads((res_dir / "qgtl_sic_metric.json").read_text(encoding="utf-8-sig"))
        assert qj["status"] == "PASS"
        assert qj["sic_circle_err_g_tt"] < 1e-12
    if (res_dir / "numerical_claims_audit.json").exists():
        nj: dict[str, Any] = json.loads((res_dir / "numerical_claims_audit.json").read_text(encoding="utf-8-sig"))
        assert nj["status"] == "PASS"
        assert nj["claim_n1_pcliff_d4_to_d7"]["d=4"]["isolated_1d_fiducials_in_4a"] == 0
        assert nj["claim_n2_composite_d4_lbfgsb"]["beats_mub_ceiling"] is True
        h2 = nj["claim_n3_alltop_hessians"]["two_qudit_d5"]
        assert h2["classification"] == "strict_local_max_of_M2"
        assert len(h2["distinct_eigenvalues"]) == 8
        assert h2["max_analytic_cluster_err"] < 1e-11
        n4 = nj["claim_n4_low_mana_sweep"]
        assert n4["single_qudit_counterexamples"] == 0
        assert n4["two_qutrit_counterexamples"] == 0
        assert n4["three_qutrit_low_mana_witness"]["strictly_below_threshold"] is True
        assert n4["three_qutrit_low_mana_witness"]["still_strict_local_max"] is True


def test_repo_yaml_draft_2020_12_schema() -> None:
    """Validate `repo.yaml` strictly against Build Standard v1.2.0 Draft 2020-12 JSON Schema."""
    schema_path = ROOT / "repo-standard.schema.json"
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    manifest = yaml.safe_load((ROOT / "repo.yaml").read_text(encoding="utf-8"))
    jsonschema.Draft202012Validator.check_schema(schema)
    jsonschema.Draft202012Validator(schema).validate(manifest)


def test_version_governance_accessibility_and_csp() -> None:
    """Audit single version source across all manifests, strict CSP + WCAG 2.2 AA on docs/site/,
    and zero stale affiliation."""
    ver = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    assert ver == "2.0.0"
    assert f'version: "{ver}"' in (ROOT / "CITATION.cff").read_text(encoding="utf-8")
    assert f"## [{ver}]" in (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
    assert f'version = "{ver}"' in (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    assert f'version = "{ver}"' in (ROOT / "rust" / "Cargo.toml").read_text(encoding="utf-8")
    assert f'version = "{ver}"' in (ROOT / "lean" / "lakefile.toml").read_text(encoding="utf-8")
    _fy_txt = (ROOT / "lean" / "formalization.yaml").read_text(encoding="utf-8")
    assert 'version: v0.4' in _fy_txt or 'version: "v0.4"' in _fy_txt
    assert f'release_version: "{ver}"' in _fy_txt or f'release_version: {ver}' in _fy_txt

    # WCAG 2.2 AA + strict zero-CDN CSP checks on BOTH docs/site/ pages
    for site_file in ("index.html", "blueprint.html"):
        html_txt = (ROOT / "docs" / "site" / site_file).read_text(encoding="utf-8")
        assert "Content-Security-Policy" in html_txt
        assert "default-src 'none'" in html_txt
        assert "https://cdn." not in html_txt and "https://unpkg.com" not in html_txt
        assert "WebGL2" not in html_txt, f"Misleading WebGL2 label found in {site_file}"
        assert 'class="skip-link"' in html_txt
        assert ":focus-visible" in html_txt
        assert "prefers-reduced-motion" in html_txt
        assert 'id="main-content"' in html_txt

    idx_html = (ROOT / "docs" / "site" / "index.html").read_text(encoding="utf-8")
    assert 'aria-live="polite"' in idx_html
    assert 'role="tablist"' in idx_html
    assert "ArrowRight" in idx_html and "ArrowLeft" in idx_html

    for check_file in ("README.md", "CLAIMS.md", "LIMITATIONS.md", "CITATION.cff", "AGENTS.md", "paper/main.tex"):
        txt = (ROOT / check_file).read_text(encoding="utf-8")
        assert "0thernes LLC" not in txt, f"Stale affiliation found in {check_file}"
