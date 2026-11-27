<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Operations, Archival Backups, Offsite Mirrors & Rollback (`docs/operations.md`)

## 1. Static Deployment & Rollback (GitHub Pages)
- The interactive 3D Observatory (`docs/site/index.html`) and auto-generated Lean Proof Blueprint (`docs/site/blueprint.html`) deploy statically via `.github/workflows/pages.yml` on pushes touching `docs/site/**`.
- **One-command deploy:** `just deploy`
- **One-command rollback:** `just rollback v1.0.0` restores `docs/site/` from any tagged release or commit SHA for immediate re-deployment.

## 2. Cryptographic Integrity, Backups & Offsite Mirror Strategy
- **Local Checksum Verification:** `sha256sum -c data/MANIFEST.sha256 && sha256sum -c MANIFEST.sha256`
- **Independent Time-Stamping:** `data/MANIFEST.sha256` is sealed with both a DigiCert RFC 3161 TSA token (`data/MANIFEST.sha256.tsr`) and a 3-calendar Bitcoin OpenTimestamps proof (`data/MANIFEST.sha256.ots`), verified via `python3 scripts/stamp_timestamps.py --verify --negative-test`.
- **Offsite Git Mirror & Archival Bundle:**
  1. **Primary Remote:** `https://github.com/0thernes/weyl-magic-stabilizer-frontier`
  2. **Master Research Archive Submodule Mirror:** Pinned commit + frozen PDF registered as `0TH-2026-021` in `https://github.com/0thernes/0thernes-research-archive`
  3. **Public Preservation Mirror:** Requested archival snapshot on Software Heritage (`https://archive.softwareheritage.org/`)
  4. **Offline Git Bundle Backup:** Generate a self-contained single-file cold backup at any time via:
     ```bash
     git bundle create ../weyl-magic-stabilizer-frontier-v1.0.0.bundle --all
     git bundle verify ../weyl-magic-stabilizer-frontier-v1.0.0.bundle
     ```
