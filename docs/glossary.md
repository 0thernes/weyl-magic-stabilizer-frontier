<!-- SPDX-License-Identifier: CC-BY-4.0 -->
# Glossary (`docs/glossary.md`)

- **Alltop Cubic-Phase State ($\ket{\psi_{\mathrm{Alltop}}}$):** The finite-field pure state $q^{-1/2}\sum_{x\in\mathbb{F}_q} \chi(x^3)\ket{x}$ ($q=d^n$, prime $d\ge 5$), attaining $M_2 = \ln[q^2/(2q-1)]$ universally (Theorem `T3a`).
- **Burnside Orbit Count:** The exact number of orbits of $w$-subsets of $\mathbb{Z}_n$ under the Singer–Frobenius group $\mathbb{Z}_n\rtimes\mathbb{Z}_3$; equals $1{,}827$ for $(n,w)=(31,5)$ and $1{,}546{,}218$ for $(n,w)=(57,7)$.
- **Clifford-Stabilizer State ($G$-Stabilizer State):** A pure state spanning a **1-dimensional** joint eigenspace of some finite subgroup $G\le \mathrm{Cliff}_d$ (Erew & Goldstein, Sec. 2).
- **Conic vs. Reciprocal-Conic Orientation:** The two circulant transposes $M_Q^T$ ($c_k^+ = |H\cap(k+Q)|\le 2$) and $M_Q$ ($c_k^- = |H\cap(k-Q)| < p$, reaching 4 at $p=7,11$) in projective-geometry Singer codes $\mathcal{Q}(p,2)$.
- **Discrete Wigner Function ($W_\psi(u)$):** $W_\psi(u)=\frac{1}{D}\bra{\psi}A_u\ket{\psi}\in\mathbb{R}$ defined via Gross's phase-point operators $A_u$ in odd dimension $D$.
- **Mana of Magic ($\mathcal{M}(\ket{\psi})$):** $\ln\sum_u |W_\psi(u)|$, a computable monotone of magic in odd dimension $D$.
- **Palomar Comparator:** Lean 4.35.0 multi-kernel replay harness (`lake comparator --paranoid`) verifying that `PalomarSolution` discharges every target in `PalomarChallenge` under six independent kernels.
- **SIC-POVM Fiducial State:** A normalized vector $\ket{\psi}\in\mathbb{C}^d$ whose Weyl–Heisenberg orbit satisfies $|\bra{\psi}D_u\ket{\psi}|^2 = 1/(d+1)$ for all $u\neq (0,0)$.
- **Sign-Witness Operator ($H_s$):** $H_s = \frac{1}{D}\sum_u s(u) A_u$ for $s\in\{\pm 1\}^{D^2}$, obeying universal Parseval identity $\mathrm{Tr}(H_s^2)=D$ (Theorem `T2a`).
- **Singer Difference Set ($H$):** The zero-trace hyperplane set $\{i\in\mathbb{Z}_n : \mathrm{Tr}_{\mathbb{F}_{q^{d+1}}/\mathbb{F}_q}(\alpha^i)=0\}$ in $\mathrm{PG}(d,q)$, defining circulant matrix $A$ in $\mathcal{Q}(q,d)$.
- **Stabilizer 2-Rényi Entropy ($M_2$):** $-\ln\bigl(\frac{1}{D}\sum_u |\bra{\psi}D_u\ket{\psi}|^4\bigr)$.
- **Super-MUB Rupture:** A pure state strictly exceeding the complete-MUB magic ceiling $\ln[D^2/(2D-1)]$ (i.e., $S/D < (2D-1)/D^2$), realized explicitly in $\mathbb{Z}[i]$ for 3-qubit Hoggar ($D=8$) and composite $d=4$ ($\mathbb{Z}_4\times\mathbb{Z}_4$, $D=16$).
- **Zauner Symmetry:** An order-3 Clifford unitary $Z$ ($Z^3=I$) commuting with the WH-SIC fiducial ray, satisfying $|\mathrm{Tr}(Z)|^2\in\{1,3\}$.
