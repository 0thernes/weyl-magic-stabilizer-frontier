<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Contributing (`CONTRIBUTING.md`)

Contributions that strengthen mathematical proofs, extend formalization coverage, add independent verifier implementations, or report errors are warmly welcomed.

## Standards
1. **Lean 4.35.0 (`lean/`):** Zero Mathlib, `module` header on every file, zero `sorry` outside `PalomarChallenge.lean`, zero `admit`, zero `native_decide`, zero custom axioms. All declarations in `VerifyAxioms.lean` must remain strictly within `{propext, Classical.choice, Quot.sound}`.
2. **Native & Quantum Engines:** Keep `rust/` strictly `#![forbid(unsafe_code)]` with zero external crates and zero clippy warnings; keep C11 and C++20 strictly `-Wall -Wextra -Wpedantic -Werror`.
3. **Verification & Hygiene:** Before pushing or submitting patches, run `just verify` (or the individual checks in `README.md`) and verify `scripts/check_readme_axioms.py` and `scripts/audit-repo.sh` pass cleanly.
4. **Licensing:** Code contributions are licensed under `Apache-2.0`; documentation, figures, and manuscript text under `CC-BY-4.0`.
5. **Finding Classes:** When filing issues, classify findings using the 10 standard classes in `.github/labels.tsv`: `bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, `blindspot`.
