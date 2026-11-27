<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Three-Cycle Comprehensive Hardening Log (`HARDENING_LOG.md`)

This repository underwent **three full, end-to-end hardening cycles** spanning every folder, file, proof kernel, native engine, figure, bibliography entry, LaTeX log line, CI workflow, and governance artifact, classifying every finding across the 10 Build Standard v1.2.0 finding classes (`bug`, `error`, `issue`, `problem`, `concern`, `dilemma`, `conflict`, `gap`, `hole`, `blindspot`) and all 10 Playbook v1.3 red-team lenses.

---

## Cycle 1 — Mathematical Core, Zero-Mathlib Lean 4.35.0 & Nine-Language Polyglot Stack

| ID | Class | Location | Finding | Resolution & Verification |
| :--- | :--- | :--- | :--- | :--- |
| C1-01 | `error` | `lean/WeylMagicFrontier/Pillar3_AlltopMagic.lean` | Draft algebra wrote Welch–MUB gap numerator as $(D-1)^2/(D^2(D+1))$. | Lean kernel caught the slip immediately; proved exact $(D-1)/(D^2(D+1))$ in `welch_bound_and_mub_gap`. |
| C1-02 | `hole` | `lean/WeylMagicFrontier/Pillar4_SingerCodes.lean` | Initial `odd_prime_singer_upper_bound` assumed $c_k \le 2$, which holds for conic $M_Q^T$ ($c_k^+\le 2$) but fails for reciprocal-conic $M_Q$ ($c_k^-=3$ at $p=5$; $c_k^-=4$ at $p=7,11$). | Generalized hypothesis to $0\le c_k < p$ and $\sum c_k(c_k-1)=p(p+1)$; theorem now holds unconditionally for **both** orientations simultaneously. |
| C1-03 | `issue` | `lean/WeylMagicFrontier/*.lean` | Lean 4.35.0 `module` opacity blocked `unfold`/`decide` and hit `maxRecDepth` on `Pillar1`/`Pillar3`/`Pillar4`. | Added `public section` + `@[expose]` on exported defs (never on `instance`), tail-recursive sums, structural-recursive `Nat` bitmasks, and scoped `set_option maxRecDepth 4096 in`. `lake build` 16/16 jobs green, 0 warnings; `leanchecker-paranoid` PASS. |
| C1-04 | `bug` | `quantum_stack/qgtl_sic_metric.c` | Hand calculation predicted vanishing Berry curvature on $\mathrm{span}(e_1,e_2)$; compiled QGTL C reported $|\Omega_{\theta\phi}|=1.0$. | Confirmed analytically: $\ket{\psi(\theta,\phi)}=(0,\cos\phi,-\sin\phi e^{i\theta})$ is a genuine Bloch sphere with exact monopole curvature $\sin(2\phi)=1$ at $\phi=\pi/4$ (`0.0` error) and $g=\mathrm{diag}(1/4,1)$ (`0.0` error). |
| C1-05 | `bug` | `eshkol/weyl_magic_ad.esk` | Denominator in `alltop-d5-s4-over-5` used `norm2^2` instead of `norm2^4` (`norm8`), and running without `-r` wrote stray `a.out.exe`. | Fixed to `norm8`, executed via `eshkol-run.exe -r`, verified exact `0.3582441485` and slope `-0.0360167`, deleted stray `a.out.exe*`. |
| C1-06 | `issue` | `zig/src/main.zig`, `cpp/src/weyl_verify.cpp`, `rust/src/main.rs` | Zig 0.17.0 `std.Io.File.stdout` API change & `i1` shadow; C++20 `-Wpedantic` rejection of `__int128`; 5 Rust clippy lints. | Migrated Zig to `init: std.process.Init` + `std.Io.File.stdout().writer`, replaced C++20 `__int128` with standard `std::uint64_t`, cleared all 5 Rust clippy lints (`-D warnings` = 0). |
| C1-07 | `blindspot` | `scripts/mutate.py`, `src/weyl_magic/oracle.py` | Initial mutation harness lacked a green-baseline guard (masking a Python 3.9 `bit_count()` crash and 3 weak mutants). | Added mandatory baseline-green assertion, Python 3.9–3.14 portable `bin(x).count("1")`, and full 24-element symplectic covariance check in `verify_pillar1`; achieved **8/8 (100.0%)** mutant kill rate. |
| C1-08 | `concern` | `quantum_stack/qrng_mixer.c` | "QRNG" label could be misread as hardware quantum entropy. | Explicitly documented across code, `README.md`, `LIMITATIONS.md`, and `paper/main.tex` as deterministic classical SplitMix64 + xoshiro256**. |

---

## Cycle 2 — Figures, Bibliography, 21-Page Monograph & Clean-Room arXiv Packaging

| ID | Class | Location | Finding | Resolution & Verification |
| :--- | :--- | :--- | :--- | :--- |
| C2-01 | `error` | `paper/refs.bib` | Two candidate bibliography DOIs failed live Crossref verification prior to draft lock. | Replaced via live Crossref API lookups with verified DOIs `10.1103/PhysRevLett.128.050402` (Leone–Oliviero–Hamma 2022) and `10.1007/s11128-023-04186-9` (Wang–Li 2023); `results/citation_audit.json` = **14/14 live PASS**, 0 retractions. |
| C2-02 | `issue` | `scripts/make_figures.py`, `paper/figures/` | Visual PNG QA revealed text overflow in Fig. 5 boxes and minor legend overlaps in Figs. 1, 2, 4. | Adjusted box margins, legend anchors, and matplotlib `\geq`/`\leq` mathtext; re-rendered and visually inspected all 5 PNGs to zero overlap/clipping. |
| C2-03 | `bug` | `paper/main.tex` | Nested `[...]` in `\begin{theorem}[T3d: $\Z[\zeta_5]$]` broke TeX optional-argument parsing; initial compile also had 2 tiny Overfull and 10 minor Underfull hboxes. | Braced theorem titles (`[{...}]`), added brief intro lines before `enumerate` environments inside `amsthm`, and tuned `\nolinkurl` / phrasing to achieve **literal 0 errors, 0 warnings, 0 overfull, 0 underfull** across all 21 pages. |
| C2-04 | `problem` | `dist/arxiv_submission.tar.gz` | Needed guaranteed clean-room compilation without local build caches or PNG figures. | Packaged strictly `main.tex`, `refs.bib`, `main.bbl`, and vector `figures/fig1..5.pdf`, extracted into a clean temp directory, and verified Tectonic clean-room build passes end-to-end. |
| C2-05 | `gap` | `c/src/fuzz_singer.c`, `c/Makefile` | Build Standard `B15`/`B16` require native fuzzing + ASan/UBSan targets. | Added dual-mode `c/src/fuzz_singer.c` (standalone 100k deterministic fuzzer + `LLVMFuzzerTestOneInput` for libFuzzer) and `c/Makefile` (`test-nasm`, `sanitize`, `fuzz`), verified clean under `-Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion`. |

---

## Cycle 3 — Provenance, Governance, 6-Kernel Cloud CI & Archive Registration

| ID | Class | Location | Finding | Resolution & Verification |
| :--- | :--- | :--- | :--- | :--- |
| C3-01 | `conflict` | `scripts/check_readme_axioms.py`, `results/lean_axioms.txt` | Lean 4 wrapped `refute_at02_v345_stabilizer_order_not_1_or_9` across 3 lines in `results/lean_axioms.txt`, which would undercount single-line regex parsers. | Upgraded `parse_axiom_lines` to rejoin indented continuation lines while still enforcing exact verbatim inclusion in `README.md`; verified `31/31 PASS`. |
| C3-02 | `dilemma` | Author affiliation across repo | Older template drafts referenced an LLC entity, conflicting with Playbook v1.3 Finding 1 (independent researcher standard). | Enforced `Alexander Stephen Donahue · Independent Researcher, Spokane, WA, USA` uniformly across every file and added a CI grep guard against stale strings. |
| C3-03 | `gap` | `data/MANIFEST.sha256`, `MANIFEST.sha256`, timestamps | Needed LF-normalized deterministic SHA-256 manifests and independent external timestamping. | Added `scripts/generate_manifests.py` and `scripts/stamp_timestamps.py`; sealed `data/MANIFEST.sha256` with DigiCert RFC 3161 `.tsr` + 3-calendar Bitcoin `.ots`, and verified 1-byte tamper rejection. |
| C3-04 | `blindspot` | Cross-platform CI (`ubuntu-latest`, `macos-latest`, `windows-latest`) | Local Windows toolchain paths differ from clean Linux/macOS cloud runners. | Executed full GitHub Actions CI across all 6 Lean kernels (including live tamper-injecting negative gate), Rust matrix, Zig 0.17.0, C11+NASM+ASan/UBSan+100k Fuzz, C++20, Moonlab WASM, QGTL C, Python matrix, Tectonic LaTeX, SLSA provenance, and GitHub Pages until 100% green. |
| C3-05 | `gap` | `0thernes-research-archive` | New monograph and formalization needed permanent pinned registration including Section D refutation ledger. | Registered as `0TH-2026-020` with pinned submodule commit, frozen PDF, SHA-256 checksum, Section A + Section D refutation entries, and verified `verify_archive.py` 100% pass. |
| C3-06 | `issue` | `.github/workflows/ci.yml`, `scripts/make_figures.py`, `scripts/generate_manifests.py` | First Linux CI run passed Lean 4.35.0 (all 6 kernels + live tamper test), 3-OS Rust, Zig, C11+NASM ELF64+ASan+Fuzz, C++20, 3-OS Python, and Tectonic LaTeX, while flagging 3 small hygiene issues: `matplotlib.figure.Figure`/`Rectangle` typing under `mypy --strict`, `build/qrng_mixer` path for Moonlab, and gitignored `.egg-info` entries in `MANIFEST.sha256`. | Fixed all three cleanly, verified `mypy --strict` with matplotlib stubs, regenerated LF-clean `MANIFEST.sha256`, re-verified timestamps, and confirmed 100% all-jobs green CI + SLSA attestation. |
