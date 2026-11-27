<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Frequently Asked Questions (`docs/faq.md`)

**Q1: Does refuting Erew–Goldstein Conjecture 1 mean SIC-POVMs do not exist or have no Clifford symmetry?**  
No. Qutrit WH-SICs exist (Theorem `T1a` gives an infinite rational Pythagorean circle), and every known WH-SIC fiducial has at least an order-3 Zauner Clifford symmetry. Conjecture 1 specifically claimed that every SIC fiducial spans a **1-dimensional** joint eigenspace of a finite Clifford subgroup. We prove that $v_{345}$ has full $\mathrm{PCliff}_3$ stabilizer $\{I,P,P^2\}$ with a **2-dimensional** joint eigenspace, and universally any order-3 Zauner symmetry with $|\mathrm{Tr}(Z)|^2\le 3$ forces eigenspace dimension $m_\lambda\ge 2$ for all canonical eigenspaces ($d\ge 4$) and all three eigenspaces ($d\ge 7$).

**Q2: Does this work prove all of Erew–Goldstein Conjecture 2?**  
No — and we state the boundary explicitly. Theorem `T2b` proves Conjecture 2 across the entire **high-mana regime** $\mathcal{M}(\ket{\psi}) > \frac{1}{2}\ln(D/2)$ (which covers the top $\frac{1}{2}\ln 2 \approx 0.3466$ nat beneath the universal Parseval ceiling and contains every prime Alltop state tested). The low-mana regime $\mathcal{M}(\ket{\psi}) \le \frac{1}{2}\ln(D/2)$ remains open.

**Q3: Why is `quantum_stack/qrng_mixer.c` labeled a deterministic software mixer?**  
For full scientific honesty: no physical quantum hardware entropy source is attached to CI runners. `qrng_mixer.c` implements deterministic SplitMix64 + xoshiro256** so Moonlab WASM Born-rule sampling (`2,048` shots) is 100% reproducible across platforms, and it is explicitly disclosed as classical software.

**Q4: Why is Lean built without Mathlib?**  
Zero-Mathlib Lean 4.35.0 compiles from scratch in seconds, avoids multi-million-line dependency surfaces, keeps every definition directly auditable, and replays smoothly across all six independent type-checking kernels (`lean`, `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, `con-ron`).

**Q5: How do I verify $d_{\min}(\mathcal{Q}(7,2)) = 8$ myself?**  
Lean proves the upper bound $d_{\min}(\mathcal{Q}(7,2))\le 8$ via `prove_t4b` and `prove_t4c` (explicit weight-8 diagonal operator $L_{\mathrm{line}} = (\tau_H\mid\tau_H)$). Run `cd rust && cargo run --release -- --json` (5.4 s) or `make -C c test-nasm` to independently certify all $1{,}546{,}218$ Singer–Frobenius orbits of weight 7 have full column rank 14 (0 dependent orbits), establishing $d_{\min}(\mathcal{Q}(7,2)) \ge 8$.
