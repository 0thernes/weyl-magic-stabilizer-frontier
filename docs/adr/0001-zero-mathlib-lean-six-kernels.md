<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ADR 0001: Zero-Mathlib Lean 4.35.0 Formalization with Six-Kernel Palomar Replay

- **Status:** Accepted (2026-11-26)
- **Context:** Large proof assistants often depend on multi-million-line libraries (`Mathlib`), which slows clean-room verification, widens the audit surface, and complicates replay across external proof checkers (`lean4lean`, `nanoda`, `con-leche`, `con-ron`).
- **Decision:** Formalize all 14 headline theorems (`T1a`–`T4c`), 8 non-vacuity witnesses (`NV01`–`NV08`), and 8 adversarial refutations (`AT01`–`AT08`) in **zero-Mathlib Lean 4.35.0** with strict `module` headers, `autoImplicit = false`, zero `native_decide`, zero `sorry` in `defaultTargets`, and exact Palomar `Challenge`/`Solution` separation. Replay all 15 Palomar targets across all 6 independent kernels under `--paranoid` sandboxing in CI, supplemented by a live tamper-injecting negative gate.
- **Consequences:**
  - Positive: Clean build finishes in seconds, zero external dependencies, 100% transparent axiom footprint (`{propext, Classical.choice, Quot.sound}`), and immediate portability across all six external type-checkers.
  - Trade-off: Algebraic primitives (`GaussInt`, `Zeta12`, `Zeta5`, `sumFin`, Cauchy–Schwarz) are constructed explicitly from first principles in `Cyclotomic.lean` (~180 LOC), keeping every line directly auditable.
