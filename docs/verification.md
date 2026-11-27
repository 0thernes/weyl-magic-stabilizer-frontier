<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Verification Ledger & Tool Matrix (`docs/verification.md`)

Complete summary of every automated verification check executed locally and in GitHub Actions CI for `weyl-magic-stabilizer-frontier` (`0TH-2026-021`, `v2.0.0`).

| Layer | Command | Evidence File | Verified Result |
| :--- | :--- | :--- | :--- |
| Lean 4.35.0 Build | `cd lean && lake build && lake build PalomarChallenge` | `lean/` | 16/16 jobs green, 0 warnings, 0 `sorry` in `defaultTargets` |
| Lean Axiom Audit | `cd lean && lake env lean VerifyAxioms.lean && lake env lean AuditAllDecls.lean` + `scripts/check_readme_axioms.py` | `results/lean_axioms.txt` | 31/31 flagship + **471/471 exhaustive constants** (`0` violations) $\subseteq\{\texttt{propext},\texttt{Classical.choice},\texttt{Quot.sound}\}$ |
| 6-Kernel Replay | `lake env leanchecker-paranoid`, `lake check --paranoid`, `lake comparator --paranoid` + tamper negative test | `.github/workflows/ci.yml` | 15/15 Palomar targets across 6 kernels; synthetic `sorry`/axiom tamper rejected |
| Rust (Zero-Unsafe) | `cargo clippy --all-targets -- -D warnings && cargo test --release && cargo run --release -- --json` | `results/rust_verifier.json` | 0 warnings, 4/4 tests, `1,827` $\mathcal{Q}(5,2)$ & `1,546,218` $\mathcal{Q}(7,2)$ orbits, 0 dep |
| Zig 0.17.0 | `zig test src/main.zig && zig run -O ReleaseFast src/main.zig` | `results/zig_verifier.json` | Comptime + runtime PASS |
| ISO C11 + x86-64 NASM + Fuzz + ASan | `make -C c clean test-nasm sanitize fuzz` | `results/c11_nasm_verifier.json` | 0 warnings (`-Werror`), 10k/10k ASM diff, `1,546,218` $\mathcal{Q}(7,2)$ orbits, ASan/UBSan clean, 100k fuzz clean |
| ISO C++20 | `g++ -std=c++20 -O3 -Wall -Wextra -Wpedantic -Werror cpp/src/weyl_verify.cpp` | `results/cpp20_verifier.json` | 0 warnings, `static_assert` constexpr + runtime PASS |
| Eshkol v1.3.6 AD | `eshkol-run -r eshkol/weyl_magic_ad.esk` | `results/eshkol_audit.log` | Exact derivatives on 9-term WH-SIC equator, spectral gap, and $d=5$ saddle |
| Moonlab WASM + QRNG | `node quantum_stack/moonlab_super_mub.mjs` | `results/moonlab_super_mub.json` | `20,750` gates, 2q MUB ($4\times 10^{-16}$), 3q Hoggar ($4.02\times 10^{-16}$), `4,096` shots |
| Pinned QGTL C | `quantum_stack/qgtl_sic_metric.c` (`-Werror`) linked with `third_party/qgtl/` | `results/qgtl_sic_metric.json` | Exact $g=\mathrm{diag}(1/4,1)$ (`0.0` err), $|\Omega_{\theta\phi}|=1.0$ (`0.0` err) |
| Python Oracle, Schema, Diff & Mutation | `pytest -v tests/test_all.py`, `scripts/mutate.py`, `scripts/verify_numerical_claims.py`, `ruff`, `mypy --strict` | `results/python_oracle.json`, `results/numerical_claims_audit.json` | Draft 2020-12 schema + standalone `reference/oracle.py` diff + 1,000-case Hypothesis + 8/8 (100%) mutants killed + 0 ruff/mypy errors |
| Bibliography Audit | `python3 scripts/check_citations.py` | `results/citation_audit.json` | 14/14 live Crossref/arXiv verified (title + author surname + year + 0 retractions) |
| Monograph & Clean-Room | `tectonic -X compile paper/main.tex` + clean-room `arxiv_submission.tar.gz` | `dist/` | 21 pp., 0 errors, 0 warnings, 0 overfull, 0 underfull |
| Timestamps, Security & SLSA | `sha256sum -c`, `scripts/stamp_timestamps.py --verify --negative-test`, `gitleaks`, `osv-scanner` | `data/MANIFEST.sha256.{tsr,ots}` | OpenSSL X.509 CMS-verified DigiCert RFC 3161 + 3-calendar Bitcoin OTS + 1-byte tamper rejected + report-only security scan |
