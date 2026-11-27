<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Agent & Contributor Guide (`AGENTS.md`)

This repository (`weyl-magic-stabilizer-frontier`, Archive ID `0TH-2026-021`, `v2.0.0`) is a formally verified mathematical and quantum-information research project following the **Build Standard for LLMs v1.2.0** (`repo.yaml`, `scripts/audit-checks.tsv`).

## Non-Negotiable Rules
1. **Lean 4.35.0 Strictness (`lean/`):**
   - Zero Mathlib. Every `.lean` file begins with `module`.
   - Zero `sorry` (except the intentional statement-only contract `lean/PalomarChallenge.lean`, excluded from `defaultTargets`), zero `admit`, zero `native_decide`, zero custom axioms.
   - Every headline theorem (`T1a`–`T4c` + master conjunction), non-vacuity witness (`NV01`–`NV08`), and adversarial refutation (`AT01`–`AT08`) must audit via `VerifyAxioms.lean` strictly within `{propext, Classical.choice, Quot.sound}` (31/31 declarations), AND every constant in `WeylMagicFrontier.*` must pass `AuditAllDecls.lean` (471/471 declarations, `0` violations).
   - `README.md` must contain the exact verbatim output of `results/lean_axioms.txt` (enforced by `scripts/check_readme_axioms.py`).
2. **Epistemic Integrity & Verification Boundaries:**
   - Strictly separate `[LEAN-6K]` (6-kernel machine-checked), `[EXACT-COMP]` (exact integer/finite-field Rust, Zig, C11+NASM, C++20, Python `weyl_magic.oracle`, and standalone `reference/oracle.py`), and `[NUM-STACK]` (Eshkol AD, Moonlab WASM, QGTL C, `scripts/verify_numerical_claims.py`).
   - Explicitly report `0 / 2,000` overarching Mega-Atlas grand problems retired.
   - Disclose `quantum_stack/qrng_mixer.c` as deterministic classical software (SplitMix64 + xoshiro256**), never claiming quantum hardware entropy.
3. **Author Identity & Licensing:**
   - Author: `Alexander Stephen Donahue` (`Independent Researcher, Spokane, WA, USA`, ORCID `0009-0006-8168-9648`, `0_0@0thernes.art`).
   - Dual license: `Apache-2.0` (code) + `CC-BY-4.0` (monograph, figures, data, docs), declared in `REUSE.toml`.
4. **Git & CI Conventions (Build Standard R1–R4):**
   - Commit and push straight to `main`; unsigned commits and tags; report-only CI (`ci.yml`) and static GitHub Pages deployment (`pages.yml`).
   - Normalize all tracked text files (except `.ps1`/`.bat`/`.cmd`) to LF (`\n`) before regenerating `data/MANIFEST.sha256` and `MANIFEST.sha256` via `python scripts/generate_manifests.py`.
