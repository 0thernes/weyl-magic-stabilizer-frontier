<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Master Hardening Index & Table of Contents (`HARDENING_INDEX.md`)

**Repository:** `0thernes/weyl-magic-stabilizer-frontier` (Archive ID: `0TH-2026-021`)  
**Baseline Audited:** `v1.0.0` (`da2aa5d9e40a7a7e9d54fc18e7ff14a87f6f4617`, 143 tracked files) → **Converged Release:** `v2.0.0` (151 tracked files; 100% audited across Cycles 1–3)  
**Standards Applied:**
1. **Build Standard for LLMs v1.2.0** (`I:\All GH Repos\Repo Checklist\build-standard\build-standard.md`, Hard Rules R1–R8, 10 finding classes, 90 items A01–A45 & B01–B45, Draft 2020-12 `repo-standard.schema.json`).
2. **Defensible Independent AI Research Playbook v1.3** + **Gemini Verification Playbook (2026 Edition)** (`I:\White Papers\DEFENSIBLE_INDEPENDENT_AI_RESEARCH_PLAYBOOK.md`, 43-item Gold Standard Release Checklist, 10-pass review protocol).

---

## Table of Contents (Directory Structure)

| # | Directory / Scope | Audited Files (`v2.0.0`) | Cycle 1 | Cycle 2 | Cycle 3 |
| :--- | :--- | :---: | :---: | :---: | :---: |
| 1 | [Root Metadata, Policies & Agent Entry Points](#1-root-metadata-policies--agent-entry-points) | 34 | — | PASS | PASS |
| 2 | [`.github/` & `.cursor/` (CI, Pages, Release, Issue Templates, Labels)](#2-github--cursor) | 8 | — | PASS | PASS |
| 3 | [`lean/` (Zero-Mathlib Lean 4.35.0 Proofs, Palomar Contracts & `AuditAllDecls.lean`)](#3-lean-zero-mathlib-lean-4350-proofs--palomar-contracts) | 20 | PASS | — | PASS |
| 4 | [`rust/`, `zig/`, `c/`, `asm/`, `cpp/` (Native Exact Engines)](#4-rust-zig-c-asm-cpp-native-exact-engines) | 9 | PASS | — | PASS |
| 5 | [`eshkol/`, `quantum_stack/` & `third_party/` (AD, Moonlab WASM, QGTL C, QRNG)](#5-eshkol-quantum_stack--third_party) | 13 | PASS | — | PASS |
| 6 | [`src/`, `reference/`, `examples/`, `tests/` (Python Exact Oracle & Test Suite)](#6-src-reference-examples--tests) | 5 | PASS | PASS | PASS |
| 7 | [`scripts/` (Auditors, Citations, Figures, Manifests, Mutations, Numerical, Timestamps)](#7-scripts) | 11 | PASS | PASS | PASS |
| 8 | [`paper/` & `dist/` (Monograph, Bibliography, Figures, Frozen PDF & arXiv Tarball)](#8-paper--dist) | 14 | — | PASS | PASS |
| 9 | [`docs/` (Architecture, ADRs, Fidelity, Literature Log, Reviews, Observatory & Blueprint)](#9-docs) | 23 | — | PASS | PASS |
| 10 | [`data/` & `results/` (Golden Certificates, Logs, Manifests & Cryptographic Timestamps)](#10-data--results) | 14 | PASS | PASS | PASS |
| **Total** | **All tracked files (`v1.0.0` baseline 143 + 8 new `v2.0.0` files)** | **151** | **PASS** | **PASS** | **PASS** |

---

## 1. Root Metadata, Policies & Agent Entry Points

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `.editorconfig` | — | PASS | PASS | LF / UTF-8 / indent rules verified |
| `.gitattributes` | — | PASS | PASS | Binary & LF/CRLF rules verified |
| `.gitignore` | — | PASS | PASS | Excludes `.lake/`, `target/`, `build/`, `paper/build/`, `.egg-info`, `__pycache__` |
| `AGENTS.md` | — | PASS | PASS | Updated to `v2.0.0`, `0 / 2,000`, `471` decls |
| `CHANGELOG.md` | — | PASS | PASS | Added `## [Unreleased]` + `## [2.0.0] - 2026-11-27` (`A07`) |
| `CITATION.cff` | — | PASS | PASS | Updated to `2.0.0`, `2026-11-27`, `471` decls |
| `CLAIMS.md` | — | PASS | PASS | Updated `T1b`, `T3d`, `T4a`, `T4b`, `N1–N4` |
| `CLAUDE.md` | — | PASS | PASS | Thin pointer `@./AGENTS.md` |
| `CODE_OF_CONDUCT.md` | — | PASS | PASS | Verified |
| `CONTRIBUTING.md` | — | PASS | PASS | Verified |
| `ERRATA.md` | — | PASS | PASS | Logged all 4 `v1.0.0 -> v2.0.0` corrections transparently |
| `GEMINI.md` | — | PASS | PASS | Converted to thin pointer `@./AGENTS.md` |
| `HARDENING_INDEX.md` *(new in v2.0.0)* | PASS | PASS | PASS | Complete file-by-file ToC and 3-cycle tracker |
| `HARDENING_LOG.md` | — | PASS | PASS | Complete 19-finding `v2.0.0` + 19-finding `v1.0.0` 10-class log |
| `justfile` | — | PASS | PASS | Added `AuditAllDecls.lean`, `numerical`, strict `-Werror` QGTL, `v2.0.0` rollback |
| `LICENSE` | — | PASS | PASS | Apache-2.0 verified |
| `LICENSE-DOCS` | — | PASS | PASS | CC-BY-4.0 verified |
| `LIMITATIONS.md` | — | PASS | PASS | Fixed QRNG seed literal + `0 / 2,000` + reproducible low-mana sweep |
| `llms-full.txt` | — | PASS | PASS | Updated to `v2.0.0` |
| `llms.txt` | — | PASS | PASS | Updated to `v2.0.0` |
| `MANIFEST.sha256` | — | PASS | PASS | Regenerated LF-clean & verified via `sha256sum -c` |
| `pyproject.toml` | — | PASS | PASS | Bumped `2.0.0`, added `jsonschema`, `PyYAML` |
| `README.md` | — | PASS | PASS | Verbatim new `lean_axioms.txt`, error example (`A04`), locale (`A38`), `0 / 2,000`, `social-preview.png` |
| `REPLICATION.md` | — | PASS | PASS | Added `AuditAllDecls.lean`, `verify_numerical_claims.py`, `v2.0.0` replication row |
| `repo-standard.schema.json` | — | PASS | PASS | Draft 2020-12 schema enforced in `tests/test_all.py` |
| `repo.yaml` | — | PASS | PASS | Brought into 100% strict Draft 2020-12 schema compliance |
| `requirements.lock.txt` | — | PASS | PASS | Pinned `jsonschema==4.26.0`, `PyYAML==6.0.3` |
| `REUSE.toml` | — | PASS | PASS | Dual-license coverage verified |
| `ROADMAP.md` | — | PASS | PASS | Restructured to `Now`, `Next`, `Later`, `Not planned` (`A29`) |
| `SECURITY.md` | — | PASS | PASS | Verified |
| `SUPPORT.md` | — | PASS | PASS | Verified |
| `THIRD_PARTY_NOTICES.md` | — | PASS | PASS | Moonlab & QGTL MIT notices verified |
| `UPGRADING.md` | — | PASS | PASS | Documented `v1.0.0 -> v2.0.0` strengthening policy |
| `VERSION` | — | PASS | PASS | Single source of truth: `2.0.0` |

## 2. `.github/` & `.cursor/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `.cursor/rules/build-standard.mdc` | — | PASS | PASS | Verified |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | — | PASS | PASS | Verified |
| `.github/ISSUE_TEMPLATE/config.yml` | — | PASS | PASS | Added `SECURITY.md` contact link (`A16`/`A18`) |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | — | PASS | PASS | Verified |
| `.github/labels.tsv` | — | PASS | PASS | Synced live to GitHub repo via `gh label create --force` (`A30`) |
| `.github/workflows/ci.yml` | — | PASS | PASS | Added `AuditAllDecls.lean`, strict QGTL `-Werror`, `reference/oracle.py`, pinned `gitleaks v8.30.1` + `osv-scanner v2.7.1`, `continue-on-error: true` on SLSA |
| `.github/workflows/pages.yml` | — | PASS | PASS | Static zero-CDN deploy verified |
| `.github/workflows/release.yml` | — | PASS | PASS | Verified for `v2.0.0` tag |

## 3. `lean/` (Zero-Mathlib Lean 4.35.0 Proofs & Palomar Contracts)

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `lean/AuditAllDecls.lean` *(new in v2.0.0)* | PASS | — | PASS | Metaprogramming sweep: `checked=471 declarations, violations=0` |
| `lean/Challenge.lean` | PASS | — | PASS | Strengthened `T1bStmt`, `T3dStmt`, `T4aStmt` (+`binary_singer_exact_distance_two`), `T4bStmt` (5 minimal hypotheses) |
| `lean/comparator.json` | PASS | — | PASS | 15 Palomar targets verified |
| `lean/formalization.yaml` | PASS | — | PASS | Bumped `2.0.0` + complete Palomar metadata |
| `lean/lake-manifest.json` | PASS | — | PASS | Zero Mathlib verified |
| `lean/lakefile.toml` | PASS | — | PASS | Bumped `2.0.0`, `autoImplicit = false` |
| `lean/lean-toolchain` | PASS | — | PASS | `leanprover/lean4:v4.35.0` |
| `lean/PalomarChallenge.lean` | PASS | — | PASS | Intentional statement-only `sorry` contract (excluded from `defaultTargets`) |
| `lean/PalomarSolution.lean` | PASS | — | PASS | Passes `leanchecker-paranoid --fresh` + 6 kernels |
| `lean/README.md` | PASS | — | PASS | Verified |
| `lean/Solution.lean` | PASS | — | PASS | Discharges strengthened `T1bStmt`, `T3dStmt`, `T4aStmt`, `T4bStmt` |
| `lean/VerifyAxioms.lean` | PASS | — | PASS | 31/31 strictly within `{propext, Classical.choice, Quot.sound}` |
| `lean/WeylMagicFrontier.lean` | PASS | — | PASS | Clean root import |
| `lean/WeylMagicFrontier/AdversarialTests.lean` | PASS | — | PASS | `AT01`–`AT08` verified |
| `lean/WeylMagicFrontier/Cyclotomic.lean` | PASS | — | PASS | Added `GaussInt`/`Zeta12`/`Zeta5` algebra + universal `sumFin` lemmas |
| `lean/WeylMagicFrontier/NonVacuity.lean` | PASS | — | PASS | Upgraded `NV07` & `NV08` to inhabit universal Pillar IV theorems |
| `lean/WeylMagicFrontier/Pillar1_SICRefutation.lean` | PASS | — | PASS | Added `allSL2F3_nodup`, `allPCliff3_nodup`, `mem_allPCliff3_iff`, `isCollinear_of_scale` |
| `lean/WeylMagicFrontier/Pillar2_ManaLock.lean` | PASS | — | PASS | Verified |
| `lean/WeylMagicFrontier/Pillar3_AlltopMagic.lean` | PASS | — | PASS | Fixed stale comment `(D-1)^2` -> `(D-1)/(D^2(D+1))` |
| `lean/WeylMagicFrontier/Pillar4_SingerCodes.lean` | PASS | — | PASS | Proved universal `circMulVec_circConv` & `vecMulCirc_circConv`, eliminating 2 hypotheses from `T4b` |

## 4. `rust/`, `zig/`, `c/`, `asm/`, `cpp/` (Native Exact Engines)

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `asm/gf7_singer_kernel.asm` | PASS | — | PASS | Added `p < 2` div0 guards; 10k/10k diff PASS |
| `c/Makefile` | PASS | — | PASS | `test-nasm`, `sanitize`, `fuzz` PASS |
| `c/src/fuzz_singer.c` | PASS | — | PASS | 100k fuzz iterations PASS |
| `c/src/weyl_verify.c` | PASS | — | PASS | Honest `null` under `c11-pure`, checked `col_basis_insert`, `1,546,218` orbits PASS |
| `cpp/src/weyl_verify.cpp` | PASS | — | PASS | `-std=c++20 -Werror` PASS |
| `rust/Cargo.lock` | PASS | — | PASS | Zero external crates |
| `rust/Cargo.toml` | PASS | — | PASS | Bumped `2.0.0` |
| `rust/src/main.rs` | PASS | — | PASS | Bounds assertions + Burnside exact assertions; `clippy -D warnings` = 0, `4/4` tests, `1,546,218` orbits |
| `zig/src/main.zig` | PASS | — | PASS | `zig test` + `ReleaseFast` PASS |

## 5. `eshkol/`, `quantum_stack/` & `third_party/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `eshkol/weyl_magic_ad.esk` | PASS | — | PASS | Genuine 9-term WH sum on `d=3` SIC (`1.5`, `dS/dtheta=0`) + `d=5` saddle (`-0.0360167`) |
| `quantum_stack/moonlab_super_mub.mjs` | PASS | — | PASS | `20,750` gates, `4,096` shots, $4.02\times 10^{-16}$ err, seed validation |
| `quantum_stack/qgtl_sic_metric.c` | PASS | — | PASS | Strict `-Werror` on harness; `0.0` metric & Berry curvature error |
| `quantum_stack/qrng_mixer.c` | PASS | — | PASS | Fixed stale `ChaCha` comment -> `xoshiro256**`; `-Werror` PASS |
| `third_party/moonlab/{LICENSE,moonlab.js,moonlab.wasm,PROVENANCE.md}` | PASS | — | PASS | Fixed stale `PROVENANCE.md` script ref; SHA-256 verified |
| `third_party/qgtl/{LICENSE,PROVENANCE.md,stub/cblas.h,include/...,src/...}` | PASS | — | PASS | Fixed stale `PROVENANCE.md` script ref; vendored MIT |

## 6. `src/`, `reference/`, `examples/` & `tests/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `examples/quickstart_demo.py` | PASS | PASS | PASS | All 4 pillars PASS |
| `reference/oracle.py` | PASS | PASS | PASS | Rewritten 100% standalone (AST-verified zero `weyl_magic` imports, `B12`) |
| `src/weyl_magic/__init__.py` | PASS | PASS | PASS | Verified |
| `src/weyl_magic/oracle.py` | PASS | PASS | PASS | Verified on Python 3.9 & 3.12 (`0` ruff, `0` mypy) |
| `tests/test_all.py` | PASS | PASS | PASS | 11/11 tests: 1,000-case Hypothesis, Draft 2020-12 schema, standalone diff, negative, determinism, WCAG 2.2 AA |

## 7. `scripts/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `scripts/audit-checks.tsv` | — | PASS | PASS | Verified |
| `scripts/Audit-Repo.ps1` | — | PASS | PASS | Verified |
| `scripts/audit-repo.sh` | — | PASS | PASS | **100.0% (71/71)** PASS |
| `scripts/build_blueprint.py` | — | PASS | PASS | Full WCAG 2.2 AA + 471-decl metric -> 118 theorems, 119 defs |
| `scripts/check_citations.py` | — | PASS | PASS | Upgraded with author surname + year check -> 14/14 live PASS |
| `scripts/check_readme_axioms.py` | PASS | PASS | PASS | 31/31 verbatim match PASS |
| `scripts/generate_manifests.py` | — | PASS | PASS | LF normalization + deterministic SHA-256 manifests |
| `scripts/make_figures.py` | — | PASS | PASS | Removed `D=9` from Fig. 3a, live `results/` feed, 1280×640 `social-preview.png` |
| `scripts/mutate.py` | PASS | PASS | PASS | Fixed sub-second `.pyc` poisoning (`-B` + `__pycache__` purge) -> 8/8 killed |
| `scripts/stamp_timestamps.py` | — | PASS | PASS | Upgraded to OpenSSL X.509 CMS `ts -verify` + negative tamper test |
| `scripts/verify_numerical_claims.py` *(new in v2.0.0)* | PASS | PASS | PASS | Reproduces all 4 `[NUM-STACK]` claims; `0` ruff, `0` mypy `--strict` |

## 8. `paper/` & `dist/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `paper/main.tex` | — | PASS | PASS | `v2.0.0`, 21 pp., **0 errors / 0 warnings / 0 overfull / 0 underfull** |
| `paper/refs.bib` | — | PASS | PASS | 14/14 live verified (title + author + year + 0 retractions) |
| `paper/figures/fig1..5.{pdf,png}` (10 files) | — | PASS | PASS | Visually QA'd PNGs; zero overlap or clipping |
| `dist/Donahue_2026_weyl_magic_stabilizer_frontier.pdf` | — | PASS | PASS | Frozen `v2.0.0` 21-page monograph |
| `dist/arxiv_submission.tar.gz` | — | PASS | PASS | Clean-room extracted & compiled with 0 warnings/issues |

## 9. `docs/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `docs/adr/README.md` *(new in v2.0.0)* | — | PASS | PASS | ADR index (`A21`) |
| `docs/adr/0001-zero-mathlib-lean-six-kernels.md` | — | PASS | PASS | Verified |
| `docs/adr/0002-polyglot-exact-and-quantum-stack.md` | — | PASS | PASS | Verified |
| `docs/architecture.md` | — | PASS | PASS | Verified |
| `docs/build-standard.md` | — | PASS | PASS | Reference Build Standard v1.2.0 |
| `docs/configuration.md` | — | PASS | PASS | Verified |
| `docs/faq.md` | — | PASS | PASS | Updated to `4,096` shots & `471` decls |
| `docs/glossary.md` | — | PASS | PASS | Verified |
| `docs/LITERATURE_SEARCH_LOG.md` *(new in v2.0.0)* | — | PASS | PASS | Playbook v1.3 #15 prior-art search log |
| `docs/media/social-preview.png` *(new in v2.0.0)* | — | PASS | PASS | 1280×640 PNG (161 KB, visually QA'd, `A26`) |
| `docs/media/social-preview.svg` | — | PASS | PASS | Retained vector asset |
| `docs/MEGA_ATLAS_CROSSCHECK.md` | — | PASS | PASS | Updated to `0 / 2,000` |
| `docs/operations.md` | — | PASS | PASS | Updated to `v2.0.0` + OpenSSL X.509 TSR |
| `docs/reviews/001-red-team-audit.md` | — | PASS | PASS | Retained `v1.0.0` red-team review |
| `docs/reviews/002-v2-three-cycle-audit.md` *(new in v2.0.0)* | — | PASS | PASS | Full `v2.0.0` 10-lens convergence review |
| `docs/run-log.md` | — | PASS | PASS | Appended `v2.0.0` verification & cold-repro run |
| `docs/site/.nojekyll`, `robots.txt` | — | PASS | PASS | Verified |
| `docs/site/blueprint.html` | — | PASS | PASS | WCAG 2.2 AA, strict CSP, 118 theorems / 119 defs / 471 decls |
| `docs/site/index.html` | — | PASS | PASS | Honest Canvas title, full WCAG 2.2 AA, strict zero-CDN CSP |
| `docs/statement-fidelity.md` | — | PASS | PASS | Synced with strengthened `T1b`, `T3d`, `T4a`, `T4b`, `NV07`, `NV08` |
| `docs/threat-model.md` | — | PASS | PASS | Verified |
| `docs/verification.md` | — | PASS | PASS | Updated to `v2.0.0` |

## 10. `data/` & `results/`

| File | Cycle 1 | Cycle 2 | Cycle 3 | Notes (`v2.0.0`) |
| :--- | :---: | :---: | :---: | :--- |
| `data/MANIFEST.sha256` | — | PASS | PASS | Regenerated & verified |
| `data/MANIFEST.sha256.{tsr,ots}` | — | PASS | PASS | Re-stamped for `v2.0.0` (OpenSSL X.509 CMS OK + 3 Bitcoin calendars + negative test) |
| `results/c11_nasm_verifier.json` | PASS | — | PASS | `10k/10k` ASM diff, `1,827` & `1,546,218` orbits |
| `results/citation_audit.json` | — | PASS | PASS | `14/14` live PASS (title + author + year + 0 retractions) |
| `results/cpp20_verifier.json` | PASS | — | PASS | PASS |
| `results/eshkol_audit.log` | PASS | — | PASS | 9-term WH SIC (`1.5`, `0`) + gap (`+2.305`) + `d=5` saddle (`-0.0360167`) |
| `results/lean_axioms.txt` | PASS | PASS | PASS | 31/31 strictly within `{propext, Classical.choice, Quot.sound}` |
| `results/moonlab_super_mub.json` | PASS | — | PASS | `20,750` gates, `4,096` shots, $4.02\times 10^{-16}$ err |
| `results/numerical_claims_audit.json` *(new in v2.0.0)* | PASS | PASS | PASS | All 4 `[NUM-STACK]` claims verified |
| `results/python_oracle.json` | PASS | — | PASS | Exact oracle output regenerated |
| `results/qgtl_sic_metric.json` | PASS | — | PASS | `0.0` error metric & Berry curvature |
| `results/rust_verifier.json` | PASS | — | PASS | `1,827` & `1,546,218` orbits (`forbid(unsafe)`) |
| `results/zig_verifier.json` | PASS | — | PASS | PASS |
