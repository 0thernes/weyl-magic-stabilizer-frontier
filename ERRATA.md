<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Errata (`ERRATA.md`)

No external errata have been reported against `v2.0.0` (`0TH-2026-021`).

## Corrections Incorporated from `v1.0.0` to `v2.0.0`
During our self-initiated three-cycle hardening audit following `v1.0.0`, four mathematical/reporting inaccuracies in `v1.0.0` were discovered and corrected in `v2.0.0` (documented in full in [`HARDENING_LOG.md`](HARDENING_LOG.md)):
1. **2-Qudit $d=5$ Alltop Tangent Hessian (`paper/main.tex` Sec. 4.2):** `v1.0.0` listed only three eigenvalues `{112/25, 160/25, 272/25}` of $\nabla^2 S(\psi)$. Reproducible exact numerical computation (`scripts/verify_numerical_claims.py`) revealed all **eight** strictly positive multiplicity-6 clusters: $\{112/25,\, 160/25,\, (216-8\sqrt{29})/25,\, 192/25,\, 200/25,\, 240/25,\, (216+8\sqrt{29})/25,\, 272/25\}$ (with $\lambda_{\min}(\nabla^2(S/25)) = 112/625 = 0.1792 > 0$, preserving strict local maximality).
2. **Low-Mana Empirical Sweep Counts (`paper/main.tex` Sec. 7):** `v1.0.0` cited `7,000+` single-qudit and `3,435` two-qutrit counts without a committed reproduction script. `v2.0.0` replaces these with the exact live reproducible audit in `scripts/verify_numerical_claims.py` (`15,566` single-qudit / `13,215` nowhere-vanishing; `2,678` two-qutrit / `1,344` nowhere-vanishing; plus an explicit low-mana locally maximal 3-qutrit witness at $D=27$).
3. **Figure 3(a) Alltop Prime Scatter (`scripts/make_figures.py`):** `v1.0.0` plotted $D=9$ ($d=3$) alongside $D=25, 49$ under the $d\ge 5$ Alltop attainment legend. `v2.0.0` restricts the scatter strictly to $D\in\{25, 49\}$ ($d\in\{5, 7\}$).
4. **Palomar Contract Omission (`lean/Challenge.lean` `T4aStmt`):** `v1.0.0` proved `binary_singer_exact_distance_two` in `Pillar4_SingerCodes.lean` without binding it inside `T4aStmt`. `v2.0.0` includes it directly in `T4aStmt` (and strengthens `T1bStmt`, `T3dStmt`, `T4bStmt`, `NV07`, and `NV08`).

If you discover any error, discrepancy, or statement-fidelity concern, please open an issue using `.github/ISSUE_TEMPLATE/bug_report.yml` or email `0_0@0thernes.art`.
