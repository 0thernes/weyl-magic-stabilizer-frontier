<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Lean 4.35.0 Six-Kernel Formalization (`lean/`)

This directory contains a **zero-Mathlib** Lean 4.35.0 formalization of all 14 headline theorems (`T1a`–`T4c`), 8 constructive non-vacuity witnesses (`NV01`–`NV08`), and 8 formal adversarial boundary refutations (`AT01`–`AT08`).

## Module Layout
- `WeylMagicFrontier/Cyclotomic.lean` — Exact rings `GaussInt` ($\mathbb{Z}[i]$), `Zeta12` ($\mathbb{Z}[\zeta_{12}]$), `Zeta5` ($\mathbb{Z}[\zeta_5]$), finite sums `sumFin`, and integer Cauchy–Schwarz.
- `WeylMagicFrontier/Pillar1_SICRefutation.lean` — `T1a` (universal Pythagorean qutrit WH-SIC circle), `T1b` (exhaustive 216-element $\mathrm{PCliff}_3$ refutation of Erew–Goldstein Conj. 1), `T1c` (universal all-$d$ Zauner obstruction), `T1d` ($d=4$ Scott–Grassl $4a$ multiplicity $(2,1,1)$).
- `WeylMagicFrontier/Pillar2_ManaLock.lean` — `T2a` (universal $\mathrm{Tr}(K_s^2)=D^3$), `T2b` (high-mana Trace-Norm Spectral Lock proving Conj. 2 for $\mathcal{M}>\frac{1}{2}\ln(D/2)$), `T2c` (Cubic-Mod-3 Wigner origin dichotomy).
- `WeylMagicFrontier/Pillar3_AlltopMagic.lean` — `T3a` (all-prime $d\ge 5$, all-$n$ Alltop attainment), `T3b` (1D parabolic Clifford unification), `T3c` (Welch–MUB gap + exact $\mathbb{Z}[i]$ 3-qubit Hoggar and composite $d=4$ ruptures), `T3d` (exact $\mathbb{Z}[\zeta_5]$ ququint $d=5$ Alltop saddle).
- `WeylMagicFrontier/Pillar4_SingerCodes.lean` — `T4a` (complete all-$d\ge 2$ proof of Conj. 24, Remark 21 sign dichotomy, exact $d_{\min}(\mathcal{Q}(2,d))=2$), `T4b` (universal odd-prime upper bound $d_{\min}(\mathcal{Q}(p,2))\le p+1$ covering both conic orientations), `T4c` (concrete witnesses for $d=2..5$ and $\mathcal{Q}(3,2),\mathcal{Q}(5,2),\mathcal{Q}(7,2),\mathcal{Q}(11,2)$).
- `WeylMagicFrontier/NonVacuity.lean` (`NV01`–`NV08`) & `WeylMagicFrontier/AdversarialTests.lean` (`AT01`–`AT08`).
- `Challenge.lean`, `PalomarChallenge.lean` (excluded from `defaultTargets`), `Solution.lean`, `PalomarSolution.lean`, `comparator.json`, `VerifyAxioms.lean`.

## Verification Commands
```bash
lake build
lake build PalomarChallenge
lake env lean VerifyAxioms.lean
lake env leanchecker --fresh PalomarSolution
lake env leanchecker-paranoid --fresh PalomarSolution
# Six independent kernels (Linux + bubblewrap):
lake check --paranoid
lake comparator --config comparator.json --paranoid
```
