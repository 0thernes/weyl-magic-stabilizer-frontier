<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Changelog

All notable changes to `weyl-magic-stabilizer-frontier` (`0TH-2026-021`) are documented in this file following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and Semantic Versioning.

## [Unreleased]

- Ongoing research tracking for low-mana Conjecture 2, two-qudit prime $M_2$ upper bounds, and algebraic lower bounds on $\mathcal{Q}(p,2)$ for $p \ge 11$.

## [2.0.0] - 2026-11-27

### Added
- **Exhaustive Lean 4.35.0 Axiom Sweep (`lean/AuditAllDecls.lean`):** Metaprogramming `Lean.collectAxioms` check sweeping all **471 constants** in `WeylMagicFrontier.*` (`violations=0`), complementing the 31 explicit `#print axioms` checks in `VerifyAxioms.lean`.
- **Reproducible Numerical Claims Audit (`scripts/verify_numerical_claims.py`, `results/numerical_claims_audit.json`):** Reproduces all four `[NUM-STACK]` claims in `paper/main.tex` from first principles: full $\mathrm{PCliff}_d$ audits ($d=4..7$), 20-start seeded L-BFGS-B for composite $d=4$, exact tangent Hessians for 1-qudit $d\in\{5,7,11,13\}$ and 2-qudit $d=5$ (verifying all 8 exact multiplicity-6 eigenvalue clusters to $<1.5\times 10^{-14}$), and the reproducible low-mana sweep (`15,566` single-qudit and `2,678` two-qutrit 1D Clifford eigenstates plus an explicit 3-qutrit low-mana locally maximal witness at $D=27$).
- **Build Standard v1.2.0 & Playbook v1.3 Governance Additions:** `docs/adr/README.md`, `docs/LITERATURE_SEARCH_LOG.md`, `docs/media/social-preview.png` (1280×640 PNG < 1 MB), Draft 2020-12 JSON Schema validation of `repo.yaml` in `tests/test_all.py`, pinned SHA-256 `gitleaks v8.30.1` + `osv-scanner v2.7.1` CI security scans, and OpenSSL X.509 CMS cryptographic verification in `scripts/stamp_timestamps.py`.

### Changed (Breaking Formal-Contract Strengthenings & Accuracy Corrections)
- **Strengthened Palomar Statement Contract (`lean/Challenge.lean`, `lean/Solution.lean`):**
  - Included `binary_singer_exact_distance_two` directly inside `T4aStmt` (closing a Palomar contract omission in `v1.0.0`).
  - Strengthened `T4bStmt` (`Pillar4.odd_prime_singer_upper_bound`) by proving universal circulant convolution commutativity and associativity internally over `Fin n` (`circMulVec_circConv`, `vecMulCirc_circConv`), eliminating two external hypotheses (`hcomm_row`, `hMQ_A_line`).
  - Strengthened `T1bStmt` with `allSL2F3_nodup`, `allPCliff3_nodup`, `mem_allPCliff3_iff`, and `Vec3.isCollinear_of_scale` (formally proving 100% duplicate-free coverage of $\mathrm{PCliff}_3$).
  - Strengthened `T3dStmt` with `Zeta5.sqrt5Elem_sq` and `Zeta5.real_twice_decomp`.
  - Upgraded `NV07` and `NV08` (`NonVacuity.lean`) to constructively inhabit the universal theorems `binary_singer_exact_distance_two` (on `Q(2,2)`) and `odd_prime_singer_upper_bound` (on `Q(3,2)`).
- **Standalone Independent Reference Oracle (`reference/oracle.py`):** Rewritten from scratch with zero imports from `weyl_magic`, differentially cross-checked against `weyl_magic.oracle` in `tests/test_all.py`.
- **Polyglot & Quantum Engine Hardening:**
  - `eshkol/weyl_magic_ad.esk`: Replaced the algebraic shortcut in `sic-d3-s4` with the explicit 9-term Weyl–Heisenberg overlap sum from first principles.
  - `asm/gf7_singer_kernel.asm` & `c/src/weyl_verify.c`: Added `p < 2` division-by-zero guards, strict `col_basis_insert` return checks, and honest `"nasm_diff_10k_ok": null` under pure-C builds.
  - `quantum_stack/moonlab_super_mub.mjs` & `qrng_mixer.c`: Fixed stale comments, added seed validation, and upgraded Born sampling to `4,096` shots (`20,750` native Moonlab gates, $4.02\times 10^{-16}$ error).
  - `scripts/check_citations.py`: Upgraded live Crossref/arXiv audit to verify author surname overlap and publication year alongside title overlap and retraction status (`14/14` verified live).
- **Monograph (`paper/main.tex`) & Figure Fixes:**
  - Corrected 2-qudit $d=5$ Alltop tangent Hessian report to all 8 exact multiplicity-6 eigenvalue clusters (verified to $<1.5\times 10^{-14}$).
  - Replaced unbacked low-mana sweep counts with exact reproducible counts (`15,566` / `13,215` single-qudit, `2,678` / `1,344` two-qutrit, plus the explicit 3-qutrit low-mana witness plotted in Fig. 2a).
  - Removed $D=9$ ($d=3$, characteristic 3) from the $d\ge 5$ Alltop scatter in Fig. 3a and wired `scripts/make_figures.py` to pull live values from `results/`.
  - Updated Mega-Atlas baseline count to `0 / 2,000` consistently across all documents and synchronized Table~\ref{tab:axioms} with `results/lean_axioms.txt`.
- **Observatory & Blueprint Accessibility (`docs/site/`):** Renamed honestly from "WebGL2" to "Interactive 3D Canvas Observatory" and implemented full WCAG 2.2 AA (skip-link, `:focus-visible`, ARIA tablist keyboard navigation, canvas keyboard controls, `aria-live="polite"`, and `prefers-reduced-motion`).
- **Schema Compliance (`repo.yaml`):** Brought `repo.yaml` into strict compliance with Build Standard v1.2.0 Draft 2020-12 `repo-standard.schema.json`.

## [1.0.0] - 2026-11-26

### Added
- **Zero-Mathlib Lean 4.35.0 Six-Kernel Formalization (`lean/`):**
  - 14 headline theorems (`T1a`–`T4c`), 15 Palomar Comparator targets, 8 constructive non-vacuity witnesses (`NV01`–`NV08`), and 8 formal adversarial boundary refutations (`AT01`–`AT08`).
  - Complete `VerifyAxioms.lean` audit confirming all 31/31 declarations depend strictly on `{propext, Classical.choice, Quot.sound}` (zero `sorryAx`, zero `native_decide`, zero custom axioms).
  - Pillar I refutation of Erew–Goldstein Conjecture 1 (`arXiv:2512.19657v2`) via Pythagorean rational qutrit WH-SIC circle (`v345`, 216-element $\mathrm{PCliff}_3$ audit, 2D eigenspace) and universal all-$d$ Zauner trace-multiplicity obstruction.
  - Pillar II high-mana proof of Erew–Goldstein Conjecture 2 via sign-witness Parseval identity and Trace-Norm Spectral Lock, plus exact Cubic-Mod-3 Wigner origin dichotomy.
  - Pillar III universal all-prime $d\ge 5$, all-$n$ finite-field Alltop attainment addressing Knipfer et al. (`arXiv:2607.07197`) Eq. (59), 1D parabolic Clifford unification, Welch–MUB gap, exact $\mathbb{Z}[i]$ Super-MUB ruptures at 3-qubit Hoggar and composite $d=4$, and exact $\mathbb{Z}[\zeta_5]$ certification of the 1-qudit $d=5$ Alltop saddle.
  - Pillar IV complete all-$d\ge 2$ proof of Kulhandjian–Hanzo Conjecture 24 (`arXiv:2610.02392`), Remark 21 sign dichotomy diagnosis, exact $d_{\min}(\mathcal{Q}(2,d))=2$, universal odd-prime bound $d_{\min}(\mathcal{Q}(p,2))\le p+1$ covering both conic orientations, and concrete witnesses for $\mathcal{Q}(3,2),\mathcal{Q}(5,2),\mathcal{Q}(7,2),\mathcal{Q}(11,2)$.
- **Nine-Language Polyglot & Quantum Verification Suite:**
  - Zero-unsafe Rust (`rust/`), Zig 0.17.0 comptime+runtime (`zig/`), strict ISO C11 + bare-metal dual-ABI x86-64 NASM assembly + 100k libFuzzer-compatible fuzzer (`c/`, `asm/`), strict ISO C++20 `constexpr` (`cpp/`), Eshkol v1.3.6 LLVM AD (`eshkol/`), pinned Moonlab WASM + deterministic software QRNG mixer + pinned QGTL C (`quantum_stack/`, `third_party/`), and exact Python oracle + Hypothesis property/differential suite + 8/8 (100%) mutation harness (`src/`, `reference/`, `tests/`, `scripts/`).
  - Exhaustive Burnside-matched $1{,}546{,}218$-orbit certification of $\mathcal{Q}(7,2)$ independently in Rust and C11+NASM settling $d_{\min}(\mathcal{Q}(7,2))=8$ **exactly**.
- **Publication Monograph, Figures, Observatory & Provenance:**
  - Zero-warning AMS-LaTeX monograph (`paper/main.tex`, `dist/Donahue_2026_weyl_magic_stabilizer_frontier.pdf`) and clean-room verified `dist/arxiv_submission.tar.gz`, with 5 Okabe–Ito vector figures and 14/14 live API-verified citations (`results/citation_audit.json`).
  - Zero-CDN, strict-CSP interactive 3D Observatory (`docs/site/index.html`) and auto-generated Lean Proof Blueprint (`docs/site/blueprint.html`).
  - SHA-256 manifests (`data/MANIFEST.sha256`, `MANIFEST.sha256`), DigiCert RFC 3161 (`.tsr`) and 3-calendar Bitcoin OpenTimestamps (`.ots`) proofs, SLSA build provenance, and Build Standard v1.2.0 3-cycle hardening audit (`HARDENING_LOG.md`).
