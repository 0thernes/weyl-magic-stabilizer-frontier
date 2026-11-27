<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Research Roadmap (`ROADMAP.md`)

**Maintenance Status:** `active` (`v2.0.0`, November 2026).

## Now
- Maintain `v2.0.0` six-kernel Lean 4.35.0 formalization (`14` headline theorems, `15` Palomar targets, `471` exhaustively axiom-audited constants, `0` violations) and nine-language polyglot verification stack under continuous informational CI.
- Maintain exact cryptographic provenance (SHA-256 manifests, OpenSSL X.509-verified DigiCert RFC 3161 `.tsr`, 3-calendar Bitcoin `.ots`, SLSA provenance, Software Heritage snapshot, and `0TH-2026-021` master archive registration).

## Next
1. **Low-Mana Regime of Erew–Goldstein Conjecture 2 (`arXiv:2512.19657v2`):** Develop fourth-moment or representation-theoretic spectral bounds extending `T2b` below $\mathcal{M}(\ket{\psi}) \le \frac{1}{2}\ln(D/2)$ (guided by our explicit 3-qutrit low-mana witness at $D=27$), or construct a low-mana counterexample.
2. **Global Upper Bound for Two-Qudit Prime $M_2$ (`arXiv:2607.07197` Eq. 59):** Investigate whether Weyl–Heisenberg 4-design semidefinite relaxations tighten the universal Welch bound toward $\ln[d^4/(2d^2-1)]$ for odd primes $d\ge 5$.

## Later
1. **Algebraic Lower Bound for $\mathcal{Q}(p,2)$ ($p\ge 11$, Conjecture 27):** Replace Singer–Frobenius orbit enumeration with an algebraic projective-geometry rank proof establishing $d_{\min}(\mathcal{Q}(p,2)) = p+1$ for all odd primes $p\ge 5$.
2. **Optional Hardware QRNG Adapter:** Offer an explicit opt-in interface for physical QRNG devices while keeping the default deterministic software mixer (`quantum_stack/qrng_mixer.c`) strictly labeled and bit-for-bit reproducible.

## Not planned
- **Mathlib Dependency Import:** Deliberately excluded to keep the formal trust base minimal, fast to build from scratch, and portable across all six independent Lean 4.35.0 kernels.
- **Unverified Floating-Point Proofs:** Numerical/AD/WASM engines (`[NUM-STACK]`) will never be promoted to substitute for kernel-checked Lean proofs (`[LEAN-6K]`) or exact integer/finite-field computations (`[EXACT-COMP]`).
- **Blocking CI Gates or Proprietary Platforms:** In compliance with Build Standard Hard Rules R1–R4, CI remains informational-only, zero external CDNs are allowed on GitHub Pages, and all verification artifacts remain open-source and offline-reproducible.
