<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# System & Proof Architecture (`docs/architecture.md`)

`weyl-magic-stabilizer-frontier` (`0TH-2026-021`) separates its formal trust base, exact native verification, physical/differential-geometry cross-checks, and publication provenance into four clean, independently auditable layers.

```mermaid
flowchart TD
    L1["Layer 1: Zero-Mathlib Lean 4.35.0 (lean/)<br/>14 headline theorems, 15 Palomar targets, 8 NV, 8 AT<br/>6 Independent Kernels: lean, leanchecker-paranoid, lean4lean, nanoda, con-leche, con-ron"]
    L2["Layer 2: Exact Native Polyglot Engines<br/>Rust (forbid unsafe) · Zig 0.17 · ISO C11 + x86-64 NASM · ISO C++20 · Python Oracle<br/>Exhaustive 1,546,218-orbit Q(7,2) certification + 10k ASM differential + 100k Fuzz"]
    L3["Layer 3: Quantum & AD Stack (NUM-STACK)<br/>Eshkol v1.3.6 LLVM AD · Pinned Moonlab WASM + Software QRNG Mixer · Pinned QGTL C"]
    L4["Layer 4: Monograph, Visuals & Provenance<br/>21p Zero-Warning AMS-LaTeX PDF · Clean-Room arXiv Tarball · 3D Observatory & Blueprint<br/>SHA-256 Manifests · DigiCert RFC 3161 (.tsr) · Bitcoin OTS (.ots) · SLSA"]

    L1 --> L2
    L2 --> L3
    L1 --> L4
    L2 --> L4
    L3 --> L4
```

## Directory Map
- `lean/` — Zero-Mathlib Lean 4.35.0 project (`WeylMagicFrontier/{Cyclotomic,Pillar1..4,NonVacuity,AdversarialTests}.lean`, `Challenge.lean`, `PalomarChallenge.lean`, `Solution.lean`, `PalomarSolution.lean`, `VerifyAxioms.lean`, `comparator.json`).
- `rust/` — Stdlib-only `#![forbid(unsafe_code)]` exact verifier (`Cargo.toml`, `Cargo.lock`, `src/main.rs`).
- `zig/` — Zig 0.17.0 `comptime` + runtime exact verifier (`src/main.zig`).
- `c/` & `asm/` — Strict ISO C11 (`src/weyl_verify.c`), libFuzzer-compatible fuzzer (`src/fuzz_singer.c`), `Makefile`, and dual-ABI x86-64 NASM assembly kernel (`asm/gf7_singer_kernel.asm`).
- `cpp/` — Strict ISO C++20 `constexpr` `static_assert` verifier (`src/weyl_verify.cpp`).
- `eshkol/` — Eshkol v1.3.6 LLVM automatic differentiation verification (`weyl_magic_ad.esk`).
- `quantum_stack/` & `third_party/` — Pinned Moonlab WASM (`third_party/moonlab/`), deterministic software QRNG mixer (`qrng_mixer.c`), Moonlab Super-MUB harness (`moonlab_super_mub.mjs`), and pinned QGTL C harness (`qgtl_sic_metric.c`, `third_party/qgtl/`).
- `src/`, `reference/`, `tests/`, `examples/`, `scripts/` — Exact Python oracle, Hypothesis property + differential tests, 8/8 mutation suite, figure generator, Blueprint builder, live citation auditor, axiom drift guard, manifest/timestamp scripts, and Build Standard v1.2.0 audit scripts.
- `paper/` & `dist/` — 21-page AMS-LaTeX monograph (`main.tex`, `refs.bib`, `figures/fig1..5.{pdf,png}`), frozen compiled PDF, and clean-room `arxiv_submission.tar.gz`.
- `docs/` — Documentation, ADRs, red-team audit, run-log, Mega-Atlas crosscheck, statement-fidelity audit, and zero-CDN GitHub Pages site (`docs/site/{index.html,blueprint.html}`).
