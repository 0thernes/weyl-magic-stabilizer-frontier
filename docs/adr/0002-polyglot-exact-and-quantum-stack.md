<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# ADR 0002: Nine-Language Polyglot & Quantum Verification Architecture

- **Status:** Accepted (2026-11-26)
- **Context:** Settling $d_{\min}(\mathcal{Q}(7,2)) = 8$ requires exhausting $1{,}546{,}218$ Singer–Frobenius orbits of weight-7 subsets over $\mathbb{F}_7$, while cross-checking Pillars I–III benefits from independent compiler backends, automatic differentiation, gate-level quantum statevector execution, and differential-geometric metric/Berry-curvature computation.
- **Decision:** Implement independent cross-checks across nine distinct toolchains while strictly preserving epistemic separation (`[LEAN-6K]` vs. `[EXACT-COMP]` vs. `[NUM-STACK]`):
  1. **Zero-unsafe Rust (`#![forbid(unsafe_code)]`)** and **ISO C11 + bare-metal dual-ABI x86-64 NASM assembly** independently certify all $1{,}827$ $\mathcal{Q}(5,2)$ orbits and all $1{,}546{,}218$ $\mathcal{Q}(7,2)$ orbits (matching the exact Burnside count to the unit).
  2. **Zig 0.17.0** (`comptime`) and **ISO C++20** (`constexpr` `static_assert`) independently verify finite algebraic witnesses at compile time and runtime.
  3. **Eshkol v1.3.6 LLVM AD**, **pinned Moonlab WASM + deterministic software QRNG mixer**, and **pinned QGTL C** provide independent `[NUM-STACK]` physical and geometric checks.
  4. **Python exact oracle** + Hypothesis + 8/8 mutation suite runs bit-for-bit differential assertions against every JSON artifact.
- **Consequences:** Eliminates single-compiler and single-implementation blindspots; during hardening, QGTL C caught a hand-computed Berry curvature zero and Eshkol AD caught a normalization exponent slip prior to release.
