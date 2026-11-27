<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Verification Run Log (`docs/run-log.md`)

Chronological audit trail of reproducible verification runs for `weyl-magic-stabilizer-frontier` (`0TH-2026-020`).

| Timestamp (UTC) | Commit / Tag | Runner / Host | Verification Suite Executed | Outcome |
| :--- | :--- | :--- | :--- | :---: |
| 2026-11-26 | pre-release (Cycle 1) | Windows 11 x86-64 (ReFS Dev Drive) | Lean 4.35.0 `lake build`, `VerifyAxioms.lean` (31/31), `leanchecker-paranoid`, Rust, Zig 0.17.0, C11+NASM, C++20, Eshkol v1.3.6 AD, Moonlab WASM, QGTL C, Python pytest + 8/8 mutation + ruff + mypy | **PASS** (5 defects found & fixed; see `HARDENING_LOG.md`) |
| 2026-11-26 | pre-release (Cycle 2) | Windows 11 x86-64 (ReFS Dev Drive) | Publication figures visual QA (5/5 PNGs), live citation audit (14/14 Crossref/arXiv), Tectonic 21p monograph (0 warnings/overfulls/underfulls), clean-room `arxiv_submission.tar.gz` compile, 100k C11 fuzzer, Build Standard v1.2.0 audit | **PASS** |
| 2026-11-26 | `v1.0.0` (Cycle 3) | Windows 11 + GitHub Actions (`ubuntu-latest`, `macos-latest`, `windows-latest`) | Full SHA-256 manifests, DigiCert RFC 3161 `.tsr` + 3-calendar Bitcoin `.ots` stamping & negative tamper test, 6-kernel Lean CI + tamper gate, 9-language CI, Pages deploy, Release `v1.0.0`, SLSA provenance, `0TH-2026-020` archive registration | **PASS** |
