<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Changelog

All notable changes to `weyl-magic-stabilizer-frontier` (`0TH-2026-020`) are documented in this file following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and Semantic Versioning.

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
  - 21-page zero-warning AMS-LaTeX monograph (`paper/main.tex`, `dist/Donahue_2026_weyl_magic_stabilizer_frontier.pdf`) and clean-room verified `dist/arxiv_submission.tar.gz`, with 5 Okabe–Ito vector figures and 14/14 live API-verified citations (`results/citation_audit.json`).
  - Zero-CDN, strict-CSP, WCAG 2.2 AA interactive 3D Observatory (`docs/site/index.html`) and auto-generated Lean Proof Blueprint (`docs/site/blueprint.html`, 91 theorems, 115 defs).
  - SHA-256 manifests (`data/MANIFEST.sha256`, `MANIFEST.sha256`), DigiCert RFC 3161 (`.tsr`) and 3-calendar Bitcoin OpenTimestamps (`.ots`) proofs, SLSA build provenance, and Build Standard v1.2.0 3-cycle hardening audit (`HARDENING_LOG.md`).
