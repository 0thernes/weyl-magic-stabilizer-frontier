<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Upgrading & Deprecation Policy (`UPGRADING.md`)

`weyl-magic-stabilizer-frontier` follows Semantic Versioning (`VERSION`, `pyproject.toml`, `rust/Cargo.toml`, `lean/lakefile.toml`, `lean/formalization.yaml`, `CITATION.cff`, `CHANGELOG.md`).

- **`v1.0.0` -> `v2.0.0` (Major Upgrade — Strictly Stronger Formal Contract):**
  - `v2.0.0` strengthens `T1bStmt`, `T3dStmt`, `T4aStmt`, and `T4bStmt` in `lean/Challenge.lean` (adding `allPCliff3_nodup`/`mem_allPCliff3_iff`, `sqrt5Elem_sq`, `binary_singer_exact_distance_two`, and eliminating two external hypotheses from `odd_prime_singer_upper_bound`), and updates `repo.yaml` to strict Draft 2020-12 schema compliance. Every theorem provable in `v1.0.0` remains strictly implied by `v2.0.0`.
- **Compatibility Guarantee:** Existing theorem names in `lean/Challenge.lean` (`T1aStmt`–`T4cStmt`, `AllFrontierTheoremsStmt`) and `lean/comparator.json` will never be weakened in minor or patch releases. Any breaking statement change or Lean toolchain bump increments the major version and preserves prior frozen PDFs and SHA-256 manifests via git tags.
