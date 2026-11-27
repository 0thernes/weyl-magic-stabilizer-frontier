<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Independent Replication Protocol (`REPLICATION.md`)

Any independent researcher can reproduce every formal proof, exact computation, quantum simulation, figure, and the 21-page AMS-LaTeX monograph from a clean clone without proprietary software or credentials.

## 1. Prerequisites
- **Lean 4.35.0** via `elan` (`leanprover/lean4:v4.35.0`; `lean/lean-toolchain` pins this automatically)
- **Rust** stable toolchain (`cargo`, `clippy`) — zero external crates
- **Zig 0.17.0** — zero external packages
- **GCC / Clang + NASM** (x86-64) — standard C11 & C++20 toolchains
- **Node.js 20+** — runs pinned `third_party/moonlab/moonlab.wasm`
- **Python 3.11+** with `pip install -r requirements.lock.txt`
- **Tectonic** (or standard TeX Live `pdflatex` + `bibtex`) for `paper/main.tex`
- *(Optional)* **Eshkol v1.3.6** (`eshkol-run -r eshkol/weyl_magic_ad.esk`)

## 2. Step-by-Step Clean-Clone Reproduction
1. **Six-Kernel Lean 4.35.0 Formal Verification:**
   ```bash
   cd lean
   lake build
   lake build PalomarChallenge
   lake env lean VerifyAxioms.lean > ../results/lean_axioms_local.txt
   diff -u ../results/lean_axioms.txt ../results/lean_axioms_local.txt
   lake env leanchecker --fresh PalomarSolution
   lake env leanchecker-paranoid --fresh PalomarSolution
   # On Linux with bubblewrap + Palomar kernels:
   lake check --paranoid
   lake comparator --config comparator.json --paranoid
   ```
2. **Exact Native Polyglot Engines (Rust, Zig, ISO C11 + x86-64 NASM, ISO C++20):**
   ```bash
   (cd rust && cargo clippy --all-targets -- -D warnings && cargo test --release && cargo run --release -- --json)
   (cd zig && zig test src/main.zig && zig run -O ReleaseFast src/main.zig)
   make -C c clean test-nasm sanitize fuzz
   g++ -std=c++20 -O3 -Wall -Wextra -Wpedantic -Werror cpp/src/weyl_verify.cpp -o /tmp/weyl_cpp && /tmp/weyl_cpp
   ```
   Verify that Rust and C11+NASM both report `q5_orbits = 1827, q5_deps = 0` and `q7_orbits = 1546218, q7_deps = 0`.
3. **Quantum & Differential-Geometry Stack (Moonlab WASM, QGTL C, Eshkol AD):**
   ```bash
   mkdir -p build && gcc -std=c11 -O3 -Wall -Wextra -Wpedantic -Werror quantum_stack/qrng_mixer.c -o build/qrng_mixer
   node quantum_stack/moonlab_super_mub.mjs
   gcc -std=c11 -O3 -Wall -Wextra -Wpedantic -Ithird_party/qgtl/include -Ithird_party/qgtl/stub \
       quantum_stack/qgtl_sic_metric.c third_party/qgtl/src/quantum_geometric/distributed/differential_geometry.c -lm -o build/qgtl_sic && ./build/qgtl_sic
   ```
4. **Python Oracle, Property/Differential Tests, 100% Mutation Suite & Blueprint:**
   ```bash
   PYTHONPATH=src:. python3 examples/quickstart_demo.py
   PYTHONPATH=src:. pytest -v tests/test_all.py
   PYTHONPATH=src:. python3 scripts/mutate.py
   python3 scripts/check_readme_axioms.py
   python3 scripts/build_blueprint.py
   ```
5. **Manuscript, Clean-Room arXiv Tarball & Cryptographic Provenance:**
   ```bash
   tectonic -X compile paper/main.tex --outdir paper/build --keep-logs
   ! grep -E "Overfull|Underfull|Undefined|Error" paper/build/main.log
   sha256sum -c data/MANIFEST.sha256
   sha256sum -c MANIFEST.sha256
   python3 scripts/stamp_timestamps.py --verify --negative-test
   ```

## 3. Replication Log

| Date | Environment | Scope Verified | Result | Notes |
| :--- | :--- | :--- | :---: | :--- |
| 2026-11-26 | Windows 11 x86-64 (local ReFS Dev Drive) | All 9 toolchains (Lean 4.35.0 paranoid, Rust 1.94, Zig 0.17.0, GCC C11+NASM, G++ C++20, Eshkol v1.3.6, Moonlab WASM, QGTL C, Python 3.13), Tectonic 0-warning PDF, clean-room arXiv tarball, 8/8 mutation | PASS | Author baseline build (`v1.0.0`) |
| 2026-11-26 | GitHub Actions (`ubuntu-latest`, `macos-latest`, `windows-latest`) | 6-kernel Lean 4.35.0 (`lean`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`) + tamper negative test, Rust matrix, Zig 0.17.0, C11+NASM+ASan/UBSan+100k Fuzz, C++20, Moonlab WASM, QGTL C, Python matrix, LaTeX + SLSA | PASS | Clean-room cloud CI reproduction (`v1.0.0`) |
