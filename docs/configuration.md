<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Configuration & Environment (`docs/configuration.md`)

This repository requires **zero environment secrets, zero API keys, and zero external network services** for offline verification.

## Toolchain & Build Configuration Files
| File | Purpose |
| :--- | :--- |
| `lean/lean-toolchain` | Pins exact Lean version `leanprover/lean4:v4.35.0`. |
| `lean/lakefile.toml` | Enforces `autoImplicit = false`, `relaxedAutoImplicit = false`, `linter.unusedVariables = true`, `linter.deprecated = true`, and excludes `PalomarChallenge` from `defaultTargets`. |
| `lean/comparator.json` | Lists all 15 Palomar theorem targets and permitted axioms `["propext", "Quot.sound", "Classical.choice"]`. |
| `rust/Cargo.toml` & `rust/Cargo.lock` | Zero-dependency Rust edition 2021 manifest (`#![forbid(unsafe_code)]`). |
| `c/Makefile` | Compiler flags (`-std=c11 -O3 -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion`) plus ASan/UBSan (`-fsanitize=address,undefined`) and NASM targets. |
| `pyproject.toml` & `requirements.lock.txt` | Pinned Python 3.11+ dev/test/lint/typecheck/figure dependencies. |
| `repo.yaml` | Build Standard v1.2.0 manifest consumed by `scripts/audit-repo.sh` and `scripts/Audit-Repo.ps1`. |

## Optional Environment Variables
- `PYTHONPATH=src:.` — Used when running Python verification scripts directly without editable installation.
- `CC` / `NASM` — Override default C compiler (`gcc`) or assembler (`nasm`) in `c/Makefile`.
- `RUSTFLAGS` — Optional extra compiler flags for `rust/`.
- No `.env` file is required or read at runtime.
