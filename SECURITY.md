<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Security Policy (`SECURITY.md`)

## Scope
This repository is a static mathematical formalization, offline polyglot verifier suite, and zero-CDN client-side HTML/Canvas visualization (`docs/site/`). It runs no network server, stores no personal data, and requires no credentials or API keys.

## Supply-Chain & Memory-Safety Controls
- **Lean 4:** Zero Mathlib dependencies; replayed across 6 independent kernels with bubblewrap sandboxing (`--paranoid`) and a live CI tamper-injection negative test.
- **Rust:** Zero external crates and `#![forbid(unsafe_code)]`.
- **C11 / NASM / C++20:** Compiled with `-Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion`, verified under AddressSanitizer + UndefinedBehaviorSanitizer (`-fsanitize=address,undefined`), 10,000-vector ASM differential tests, and 100,000-iteration libFuzzer-compatible fuzzing.
- **Static Web Site (`docs/site/`):** Zero third-party CDNs, strict Content-Security-Policy (`default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src 'self' data:`), zero cookies, zero external network requests.
- **Artifacts:** SHA-256 manifests (`data/MANIFEST.sha256`, `MANIFEST.sha256`), DigiCert RFC 3161 `.tsr`, Bitcoin OpenTimestamps `.ots`, and GitHub SLSA Build Provenance attestations.

## Reporting a Vulnerability
Report security or proof-integrity issues privately to `0_0@0thernes.art` (Alexander Stephen Donahue) or via GitHub Security Advisories. Expect an acknowledgement within 72 hours.
