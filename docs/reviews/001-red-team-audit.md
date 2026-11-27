<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Red-Team & Independent Audit Review 001 (`docs/reviews/001-red-team-audit.md`)

- **Date:** 2026-11-26
- **Scope:** Full pre-release adversarial review of `weyl-magic-stabilizer-frontier` (`0TH-2026-021`, `v1.0.0`) across mathematics, Lean 4.35.0 kernel soundness, statement fidelity, native memory safety, quantum stack honesty, bibliography accuracy, and Build Standard v1.2.0 compliance.
- **Methodology:** Playbook v1.3 10-lens red-team protocol + Build Standard 10 finding classes (`bug, error, issue, problem, concern, dilemma, conflict, gap, hole, blindspot`) across three full hardening cycles.

## Key Red-Team Findings & Resolutions
1. **[error -> FIXED] Welch–MUB Gap Numerator:** Draft algebra initially wrote $(D-1)^2/(D^2(D+1))$; Lean 4 immediately rejected it and proved the exact numerator $(D-1)/(D^2(D+1))$ (`Pillar3.welch_bound_and_mub_gap`).
2. **[hole -> FIXED] Conic vs. Reciprocal-Conic Intersection Assumption in `T4b`:** Initial assumption $c_k \le 2$ failed on the transpose $M_Q$ ($c_k^- = 3$ at $p=5$, $c_k^- = 4$ at $p=7,11$). Generalizing `odd_prime_singer_upper_bound` to $0 \le c_k < p$ closed the hole for **both** orientations universally.
3. **[bug -> FIXED] Berry Curvature Sign/Value on $\mathrm{span}(e_1,e_2)$:** Hand expectation of zero Berry curvature was refuted by compiled QGTL C, which returned exact Bloch-sphere monopole curvature $|\Omega_{\theta\phi}| = \sin(2\phi) = 1.000000000000000$ at $\phi=\pi/4$ (`results/qgtl_sic_metric.json`).
4. **[bug -> FIXED] Eshkol AD Normalization & Invocation:** Inspection of `eshkol_audit.log` caught $\norm{\phi}^4$ instead of $\norm{\phi}^8$ in `alltop-d5-s4-over-5` and required `-r` for JIT execution; corrected to exact `0.3582441485` and slope `-0.0360167`.
5. **[gap -> FIXED] Mutation Harness Baseline Guard & Weak Mutants:** Adding a mandatory baseline-green guard to `scripts/mutate.py` caught a Python 3.9 `bit_count()` crash and three surviving mutants; strengthened `verify_pillar1` to audit full 24-element symplectic covariance, reaching 8/8 (100.0%) mutant kill rate.
6. **[conflict -> FIXED] Multi-Line `#print axioms` Parsing:** Lean 4 wrapped `refute_at02_v345_stabilizer_order_not_1_or_9` across three lines in `results/lean_axioms.txt`; `scripts/check_readme_axioms.py` was upgraded to rejoin continuation lines and enforce exact 31/31 verbatim agreement with `README.md`.
7. **[concern -> FIXED] Software QRNG Epistemic Labeling:** Explicitly documented `quantum_stack/qrng_mixer.c` across `README.md`, `LIMITATIONS.md`, `paper/main.tex`, and source comments as deterministic classical software (SplitMix64 + xoshiro256**) with zero hardware quantum entropy claims.
8. **[issue -> FIXED] Stray Build Files & LaTeX Typography:** Deleted stray `a.out.exe*`, added `.gitignore` exclusions, and resolved every Overfull/Underfull hbox in `paper/main.tex` to literal 0 warnings.

## Final Red-Team Verdict
**APPROVED FOR `v1.0.0` RELEASE:** Zero `sorry`, zero `admit`, zero `native_decide`, zero custom axioms, 31/31 audited Lean declarations, 14/14 live API-verified citations, 8/8 mutation kill rate, 10,000/10,000 NASM differential vectors, 100,000/100,000 fuzz iterations, exact Burnside match `1,546,218` across independent Rust and C11+NASM engines, and honest scope disclosures (`0 / 1,900` Mega-Atlas grand problems retired).
