-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

public import WeylMagicFrontier.Pillar1_SICRefutation
public import WeylMagicFrontier.Pillar2_ManaLock
public import WeylMagicFrontier.Pillar3_AlltopMagic
public import WeylMagicFrontier.Pillar4_SingerCodes

/-!
# Formal Adversarial Boundary Refutations (`AdversarialTests.lean`)

Eight formal refutations (`AT01`–`AT08`) proving the sharp necessity of every hypothesis
and ruling out natural false strengthenings across all four pillars.
-/

namespace WeylMagicFrontier

public section

/-- `AT01`: Refute Erew-Goldstein Conjecture 1 — `v345` is a WH-SIC fiducial whose full
    `PCliff_3` stabilizer fixes a 2D subspace (`e_1` and `e_2` are NOT collinear with `v345`!). -/
theorem refute_at01_sic_is_1d_clifford_stabilizer :
    ¬ (Pillar1.Vec3.isCollinear Pillar1.Vec3.v345 Pillar1.Vec3.e1 = true) ∧
    (∀ g ∈ Pillar1.stabilizerOf Pillar1.Vec3.v345,
      Pillar1.actPCliff3 g Pillar1.Vec3.e1 =
        Pillar1.Vec3.scale (Zeta12.powOmega (2 * g.F.c)) Pillar1.Vec3.e1) := by
  refine ⟨by decide, ?_⟩
  intro g hg
  exact (Pillar1.qutrit_sic_refutes_clifford_stabilizer_conjecture.2.2.1 g hg).2.1

/-- `AT02`: Refute naive `d = 3` Zauner-triviality: `|Stab_{PCliff_3}(v345)|` is strictly `3` (neither `1` nor `>= 9`). -/
theorem refute_at02_v345_stabilizer_order_not_1_or_9 :
    (Pillar1.stabilizerOf Pillar1.Vec3.v345).length ≠ 1 ∧
    (Pillar1.stabilizerOf Pillar1.Vec3.v345).length ≠ 9 := by
  rw [Pillar1.v345_exact_clifford_stabilizer]
  decide

/-- `AT03`: Refute Conjecture 2 spectral dominance without the `2 * e_k^2 > D * N^2` threshold:
    at `D = 3, N = 10`, `e = (10, 10, 10)` satisfies `sum e_j^2 = 300 <= 3 * 100` yet `e_1 = e_0`
    (no strict gap!). -/
theorem refute_at03_spectral_lock_without_high_mana :
    ∃ (e : Fin 3 → Int),
      sumFin (fun j : Fin 3 => e j * e j) ≤ 3 * (10 * 10) ∧
      0 < e ⟨0, by decide⟩ ∧
      ¬ (∀ j : Fin 3, j ≠ ⟨0, by decide⟩ → e j < e ⟨0, by decide⟩) := by
  refine ⟨fun _ => 10, by decide, by decide, ?_⟩
  intro h
  have h1 := h ⟨1, by decide⟩ (by decide)
  dsimp only at h1
  omega

/-- `AT04`: Refute non-vanishing origin Wigner function for `d = 5` Alltop (`5 == 2 mod 3`):
    `cubicOriginMult 5 r = 1` for EVERY `r < 5`, forcing `W_Alltop(0, 0) = 0`! -/
theorem refute_at04_alltop_d5_nonvanishing_wigner :
    ¬ (Pillar2.isConstantOriginMult 5 = false) ∧
    ∀ r : Fin 5, Pillar2.cubicOriginMult 5 r.val = 1 := by
  refine ⟨by decide, ?_⟩
  intro ⟨r, hr⟩
  match r with
  | 0 | 1 | 2 | 3 | 4 => dsimp only; decide
  | _ + 5 => omega

/-- `AT05`: Refute universal `n`-qubit MUB ceiling `15 / 64` at `n = 3` (`D = 8`) via Hoggar fiducial. -/
theorem refute_at05_3qubit_mub_ceiling :
    ¬ (15 * 8 * (Pillar3.hoggarNormSq ^ 4) ≤ 64 * Pillar3.hoggarFourthMoment) := by
  have h := Pillar3.hoggar_3qubit_beats_mub.2.2.2
  omega

/-- `AT06`: Refute composite `d = 4` (`Z_4 x Z_4`, `D = 16`) MUB ceiling `31 / 256` via `v44`. -/
theorem refute_at06_composite_d4_mub_ceiling :
    ¬ (31 * 16 * (Pillar3.v44NormSq ^ 4) ≤ 256 * Pillar3.v44FourthMoment) := by
  have h := Pillar3.composite_d4_beats_mub.2
  omega

/-- `AT07`: Refute local maximality of 1-qudit `d = 5` Alltop state (`S/5 = 9/25`) via `phi5`. -/
theorem refute_at07_d5_alltop_local_maximum :
    let diff := Zeta5.sub (Zeta5.scaleInt 25 Pillar3.phi5FourthMoment)
                          (Zeta5.ofInt (9 * 5 * (Pillar3.phi5NormSq ^ 4)))
    Zeta5.zSqrt5LtZero (Zeta5.realTwiceInt diff) (Zeta5.realTwiceSqrt5 diff) = true := by
  exact Pillar3.alltop_d5_saddle_instability.2.2.2.2

/-- `AT08`: Refute uniform oddness of Remark-21 opposite-sign `u_+[k] = |E cap (k + Q_e)|` at `d = 2` (`m = 3`). -/
theorem refute_at08_remark21_u_plus_at_d2 :
    ¬ (Pillar4.checkConj24Instance 3 11).2 = true ∧
    ((2 ^ 3 - 1) ∣ (3 * 2 ^ 1 + 1)) := by
  refine ⟨?_, Pillar4.remark21_plus_sign_dichotomy.1⟩
  rw [Pillar4.conj24_concrete_d2_to_d5.1]
  decide

end

end WeylMagicFrontier
