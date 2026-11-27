<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Upgrading & Deprecation Policy (`UPGRADING.md`)

`weyl-magic-stabilizer-frontier` follows Semantic Versioning (`VERSION`, `pyproject.toml`, `rust/Cargo.toml`, `CITATION.cff`, `repo.yaml`).

- **Initial Release (`v1.0.0`):** Baseline frozen formalization (`0TH-2026-021`), Lean 4.35.0 Palomar contract (`Challenge.lean`), and 9-language polyglot suite.
- **Compatibility Guarantee:** Existing theorem names in `lean/Challenge.lean` (`T1aStmt`–`T4cStmt`, `AllFrontierTheoremsStmt`) and `lean/comparator.json` will never be weakened in minor or patch releases. Any breaking statement change or Lean toolchain bump increments the major version and preserves prior frozen PDFs and SHA-256 manifests via git tags.
