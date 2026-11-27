# SPDX-License-Identifier: Apache-2.0
set shell := ["bash", "-cu"]

default: verify

# Build and strictly audit all Lean 4.35.0 proofs (15 Palomar targets, 31 audited decls)
lean:
    cd lean && lake build && lake build PalomarChallenge && lake env lean VerifyAxioms.lean > ../results/lean_axioms_local.txt
    ! grep -E "sorryAx|_native|Lean\.ofReduceBool|Lean\.trustCompiler" results/lean_axioms_local.txt
    diff -u results/lean_axioms.txt results/lean_axioms_local.txt
    cd lean && lake env leanchecker --fresh PalomarSolution && lake env leanchecker-paranoid --fresh PalomarSolution
    python3 scripts/check_readme_axioms.py

# Build and test stdlib-only zero-unsafe Rust engine (Q(5,2) 1,827 + Q(7,2) 1,546,218 orbits)
rust:
    cd rust && cargo clippy --all-targets -- -D warnings && cargo test --release && cargo run --release -- --json

# Build and test Zig 0.17.0 comptime + runtime engine
zig:
    cd zig && zig test src/main.zig && zig run -O ReleaseFast src/main.zig

# Build and test zero-warning ISO C11 + bare-metal x86-64 NASM assembly + ASan/UBSan + 100k fuzz
c11:
    make -C c clean test-nasm sanitize fuzz

# Build and test strict ISO C++20 constexpr + runtime engine
cpp:
    g++ -std=c++20 -O3 -Wall -Wextra -Wpedantic -Werror cpp/src/weyl_verify.cpp -o /tmp/weyl_verify_cpp && /tmp/weyl_verify_cpp

# Run pinned Moonlab WASM + deterministic software QRNG mixer + pinned QGTL C harness
quantum:
    mkdir -p build
    gcc -std=c11 -O3 -Wall -Wextra -Wpedantic -Werror quantum_stack/qrng_mixer.c -o build/qrng_mixer
    node quantum_stack/moonlab_super_mub.mjs
    gcc -std=c11 -O3 -Wall -Wextra -Wpedantic -Ithird_party/qgtl/include -Ithird_party/qgtl/stub quantum_stack/qgtl_sic_metric.c third_party/qgtl/src/quantum_geometric/distributed/differential_geometry.c -lm -o build/qgtl_sic_metric && ./build/qgtl_sic_metric

# Run Python exact oracle, Hypothesis property/differential tests, 100% mutation suite, ruff, mypy, citations, blueprint
python:
    PYTHONPATH=src:. python3 examples/quickstart_demo.py
    PYTHONPATH=src:. pytest -v tests/test_all.py
    PYTHONPATH=src:. python3 scripts/mutate.py
    python3 scripts/check_readme_axioms.py
    python3 scripts/check_citations.py
    python3 scripts/build_blueprint.py
    ruff check src/ reference/ scripts/ tests/ examples/
    mypy --strict src/ reference/ scripts/ tests/ examples/

# Verify DigiCert RFC 3161 (.tsr) and Bitcoin OpenTimestamps (.ots) cryptographic proofs
timestamps:
    python3 scripts/stamp_timestamps.py --verify --negative-test

# Regenerate vector PDF/PNG figures and compile AMS-LaTeX white paper with Tectonic (0 warnings)
paper:
    PYTHONPATH=src:. python3 scripts/make_figures.py
    mkdir -p paper/build
    tectonic -X compile paper/main.tex --outdir paper/build --keep-logs
    ! grep -E "Overfull|Underfull|Undefined|Error" paper/build/main.log

# Deploy interactive 3D Observatory & Lean Blueprint to GitHub Pages (via pages.yml)
deploy:
    python3 scripts/build_blueprint.py
    gh workflow run pages.yml

# Roll back GitHub Pages deployment to a known-good git tag or commit SHA
rollback tag="v1.0.0":
    git rev-parse --verify "{{tag}}"
    git checkout "{{tag}}" -- docs/site/
    git status -s docs/site/
    @echo "Staged docs/site/ from {{tag}}; commit and push to main to trigger pages.yml rollback."

# End-to-end clean-clone reproduction entry point (Build Standard B01)
reproduce: lean rust zig c11 cpp quantum python timestamps paper
    sha256sum -c data/MANIFEST.sha256
    sha256sum -c MANIFEST.sha256

# Full verification ladder
verify: lean rust zig c11 cpp quantum python timestamps paper
