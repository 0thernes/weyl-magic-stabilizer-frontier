<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Threat Model (`docs/threat-model.md`)

## Assets Protected
1. **Formal Proof Soundness:** Ensuring no theorem in `lean/` relies on `sorryAx`, `native_decide`, custom axioms, or weakened definitions.
2. **Computational Correctness:** Ensuring the exhaustive $1{,}546{,}218$-orbit lower bound for $\mathcal{Q}(7,2)$ has zero missed orbits, zero memory corruption, and zero compiler miscompilation.
3. **Artifact & Provenance Integrity:** Ensuring the frozen PDF, arXiv tarball, and result JSONs cannot be silently altered post-release.
4. **Browser Client Safety (`docs/site/`):** Ensuring the static Observatory & Blueprint execute with zero external network calls, zero XSS vectors, and zero supply-chain script dependencies.

## Threat Matrix & Mitigations

| Threat | Impact | Mitigation Implemented |
| :--- | :--- | :--- |
| Hidden `sorry`, `admit`, `native_decide`, or custom axiom in Lean proof | Invalidates formal claim | `VerifyAxioms.lean` + `scripts/check_readme_axioms.py` + 6 independent kernels (`--paranoid`) + live CI tamper-injection negative test |
| Statement mismatch between paper conjecture and Lean type | Vacuous formalization | `Challenge.lean` literal statement contract + `docs/statement-fidelity.md` + `NonVacuity.lean` (`NV01`–`NV08`) + `AdversarialTests.lean` (`AT01`–`AT08`) |
| Single-implementation / compiler bug in exhaustive $\mathcal{Q}(7,2)$ search | Wrong distance lower bound | Two completely independent native engines (zero-unsafe Rust + strict ISO C11/x86-64 NASM) both matching exact analytical Burnside count $1{,}546{,}218$; 10k ASM differential vectors; ASan/UBSan; 100k fuzzing |
| Post-hoc artifact tampering or backdating | Provenance compromise | `data/MANIFEST.sha256` + `MANIFEST.sha256` + DigiCert RFC 3161 `.tsr` + 3-calendar Bitcoin `.ots` + GitHub SLSA Build Provenance + `0thernes-research-archive` pinned submodule |
| Third-party CDN compromise or browser tracking in `docs/site/` | Client XSS / privacy leak | Zero external CDNs; strict `Content-Security-Policy` (`default-src 'none'`); zero cookies/telemetry |
| Secret leakage or accidental binary/cache tracking | Hygiene / security failure | `.gitignore`, `scripts/audit-repo.sh`, and CI secret/placeholder scanner |
