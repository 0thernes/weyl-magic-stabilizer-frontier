<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Third-Party Notices and Attribution (`THIRD_PARTY_NOTICES.md`)

All original code in this repository is licensed under **Apache-2.0**, and all original monograph text, figures, data, and documentation are licensed under **CC-BY-4.0** (declared in [`REUSE.toml`](REUSE.toml)).

Two pinned open-source quantum libraries are vendored strictly for reproducible `[NUM-STACK]` physical and geometric verification under their respective upstream permissive licenses:

1. **Moonlab Quantum Simulator (`third_party/moonlab/`)**
   - **License:** MIT License (full license text preserved in [`third_party/moonlab/LICENSE`](third_party/moonlab/LICENSE)).
   - **Provenance & SHA-256 Pin:** Documented verbatim in [`third_party/moonlab/PROVENANCE.md`](third_party/moonlab/PROVENANCE.md).
   - **Usage:** Independent gate-level statevector verification of the 2-qubit MUB state (`CS|++>`) and 3-qubit Hoggar fiducial (`quantum_stack/moonlab_super_mub.mjs`).

2. **Quantum Geometric Tensor Library — QGTL (`third_party/qgtl/`)**
   - **License:** MIT License (full license text preserved in [`third_party/qgtl/LICENSE`](third_party/qgtl/LICENSE)).
   - **Provenance & SHA-256 Pin:** Documented verbatim in [`third_party/qgtl/PROVENANCE.md`](third_party/qgtl/PROVENANCE.md).
   - **Usage:** Independent C computation of the Fubini–Study metric $g=\mathrm{diag}(1/4,1)$ and Bloch-sphere monopole Berry curvature $|\Omega_{\theta\phi}|=1.0$ on the refuting subspace $\mathrm{span}(e_1,e_2)$ (`quantum_stack/qgtl_sic_metric.c`).

3. **Zero-Dependency Core Engines:**
   - `lean/`: Zero Mathlib and zero external Lake packages (pure Lean 4.35.0 standard library only).
   - `rust/`: Zero external Cargo crates (`Cargo.toml` has empty `[dependencies]`).
   - `zig/`, `c/`, `asm/`, `cpp/`: Standard library / bare-metal x86-64 only.
   - `docs/site/`: Zero external CDNs, zero external JavaScript frameworks, zero external fonts.
