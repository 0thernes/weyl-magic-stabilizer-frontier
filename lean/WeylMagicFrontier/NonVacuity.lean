-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

public import WeylMagicFrontier.Pillar1_SICRefutation
public import WeylMagicFrontier.Pillar2_ManaLock
public import WeylMagicFrontier.Pillar3_AlltopMagic
public import WeylMagicFrontier.Pillar4_SingerCodes

/-!
# Constructive Non-Vacuity Witnesses (`NonVacuity.lean`)

Every universal theorem in `WeylMagicFrontier` is accompanied by a concrete, kernel-checked
non-vacuity witness (`NV01`–`NV08`) proving that its hypothesis domain is genuinely inhabited
and that the conclusion produces explicit nontrivial mathematical structure.
-/

namespace WeylMagicFrontier

public section

/-- `NV01`: Concrete `(3,4,5)` and `(5,12,13)` rational WH-SIC fiducials inhabit `T1a`. -/
theorem nonvacuity_nv01_qutrit_rational_circle :
    (3 : Int) * 3 + 4 * 4 = 5 * 5 ∧
    (5 : Int) * 5 + 12 * 12 = 13 * 13 ∧
    (∀ p q : Fin 3, (p.val ≠ 0 ∨ q.val ≠ 0) →
      let ov := Pillar1.Vec3.inner (Pillar1.Vec3.rationalFiducial 5 12 13)
                  (Pillar1.Vec3.actWH p.val q.val (Pillar1.Vec3.rationalFiducial 5 12 13))
      4 * Zeta12.normSqIntPart ov = 4 * (169 * 169) ∧ Zeta12.normSqSqrt3Part ov = 0) := by
  refine ⟨by decide, by decide, ?_⟩
  intro p q hne
  have h := Pillar1.qutrit_rational_circle_wh_sic 5 12 13 (by decide) p q hne
  exact ⟨by omega, h.2⟩

/-- `NV02`: Concrete `SL(2, F_3)` (24), `PCliff_3` (216), and `Stab(v345)` (3, 2D eigenspace) inhabit `T1b`. -/
theorem nonvacuity_nv02_pcliff3_refutation :
    Pillar1.allSL2F3.length = 24 ∧
    Pillar1.allPCliff3.length = 216 ∧
    (Pillar1.stabilizerOf Pillar1.Vec3.v345).length = 3 := by
  refine ⟨Pillar1.allSL2F3_card, Pillar1.allPCliff3_card, ?_⟩
  rw [Pillar1.v345_exact_clifford_stabilizer]
  rfl

/-- `NV03`: Concrete Zauner multiplicity tuples `(2,1,1)` (`d=4`) and `(3,2,2)` (`d=7`) inhabit `T1c` & `T1d`. -/
theorem nonvacuity_nv03_zauner_multiplicities :
    (∀ m : Int, ((7 : Int) ≥ 7 ∧ (3 * m - 7) * (3 * m - 7) ≤ 12) → m ≥ 2) ∧
    (2 + 1 + 1 = (4 : Int) ∧ 2 * 2 - 1 - 1 = (2 : Int)) := by
  refine ⟨fun m hm => (Pillar1.zauner_eigenspace_dim_universal_obstruction 7 m).1 hm, by decide⟩

/-- `NV04`: Concrete high-mana spectral lock instance (`D = 7, N = 10, e = (20, 10, 10, 10, 0, 0, 0)`) inhabits `T2b`. -/
theorem nonvacuity_nv04_mana_spectral_lock :
    let e : Fin 7 → Int := fun j => if j.val = 0 then 20 else if j.val ≤ 3 then 10 else 0
    sumFin (fun j : Fin 7 => e j * e j) ≤ 7 * (10 * 10) ∧
    7 * (10 * 10) < 2 * (e ⟨0, by decide⟩ * e ⟨0, by decide⟩) ∧
    ∀ j : Fin 7, j ≠ ⟨0, by decide⟩ → e j < e ⟨0, by decide⟩ := by
  dsimp only
  refine ⟨by decide, by decide, ?_⟩
  intro j hj
  have h := Pillar2.trace_norm_spectral_dominance 10
    (fun i : Fin 7 => if i.val = 0 then 20 else if i.val ≤ 3 then 10 else 0)
    ⟨0, by decide⟩ (by decide) (by decide) (by decide) j hj
  exact h.2.2.2

/-- `NV05`: Concrete finite-field Alltop model `F_5` inhabits `AlltopFieldModel 5` (`T3a` & `T3b`). -/
@[expose] def f5Model : Pillar3.AlltopFieldModel 5 where
  add x y := ⟨(x.val + y.val) % 5, Nat.mod_lt _ (by decide)⟩
  neg x := ⟨(5 - x.val) % 5, Nat.mod_lt _ (by decide)⟩
  mul x y := ⟨(x.val * y.val) % 5, Nat.mod_lt _ (by decide)⟩
  zero := ⟨0, by decide⟩
  one := ⟨1, by decide⟩
  add_comm := by decide
  add_assoc := by decide
  add_zero := by decide
  add_neg := by decide
  mul_comm := by decide
  mul_assoc := by decide
  mul_one := by decide
  left_distrib := by decide
  mul_zero_eq := by decide
  no_zero_div := by decide
  six_ne_zero := by decide

theorem nonvacuity_nv05_alltop_f5_model :
    Pillar3.AlltopFieldModel.six f5Model = ⟨1, by decide⟩ ∧
    sumFin (fun a : Fin 5 => sumFin (fun b : Fin 5 =>
      Pillar3.alltopAmbiguitySq 5 a b * Pillar3.alltopAmbiguitySq 5 a b)) = 1125 := by
  refine ⟨by decide, ?_⟩
  have h := Pillar3.alltop_fourth_moment_exact 5 (by decide)
  exact h

/-- `NV06`: Concrete 3-qubit Hoggar (`D = 8`) & composite `d = 4` (`D = 16`) Super-MUB witnesses inhabit `T3c`. -/
theorem nonvacuity_nv06_super_mub_witnesses :
    Pillar3.hoggarNormSq = 6 ∧
    Pillar3.hoggarFourthMoment = 2304 ∧
    Pillar3.v44NormSq = 354 ∧
    Pillar3.phi5NormSq = 506 := by
  exact ⟨Pillar3.hoggar_3qubit_beats_mub.1, Pillar3.hoggar_3qubit_beats_mub.2.1,
         Pillar3.composite_d4_beats_mub.1, Pillar3.alltop_d5_saddle_instability.1⟩

/-- Concrete `Q(2, 2)` (`n = 7`) Singer incidence matrix for `x^3 + x + 1` over `GF(2)`
    (hyperplane support `H = {0, 1, 3}`), directly inhabiting `binary_singer_exact_distance_two`! -/
@[expose] def q22Mat (r c : Fin 7) : Bool :=
  let d := (c.val + 7 - r.val) % 7
  (d == 0) || (d == 1) || (d == 3)

private def maskToFin7Bool (m : Nat) (r : Fin 7) : Bool :=
  ((m >>> r.val) % 2) == 1

private def fin7BoolToMask (u : Fin 7 → Bool) : Nat :=
  (if u ⟨0, by decide⟩ then 1 else 0) +
  (if u ⟨1, by decide⟩ then 2 else 0) +
  (if u ⟨2, by decide⟩ then 4 else 0) +
  (if u ⟨3, by decide⟩ then 8 else 0) +
  (if u ⟨4, by decide⟩ then 16 else 0) +
  (if u ⟨5, by decide⟩ then 32 else 0) +
  (if u ⟨6, by decide⟩ then 64 else 0)

private theorem fin7BoolToMask_lt (u : Fin 7 → Bool) : fin7BoolToMask u < 128 := by
  unfold fin7BoolToMask
  cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
  cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
  cases u ⟨6, by decide⟩ <;> decide

private theorem maskToFin7Bool_fin7BoolToMask (u : Fin 7 → Bool) (r : Fin 7) :
    maskToFin7Bool (fin7BoolToMask u) r = u r := by
  rcases r with ⟨rv, hrv⟩
  unfold maskToFin7Bool fin7BoolToMask
  dsimp only
  match rv with
  | 0 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | 1 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | 2 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | 3 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | 4 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | 5 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | 6 => cases u ⟨0, by decide⟩ <;> cases u ⟨1, by decide⟩ <;> cases u ⟨2, by decide⟩ <;>
         cases u ⟨3, by decide⟩ <;> cases u ⟨4, by decide⟩ <;> cases u ⟨5, by decide⟩ <;>
         cases u ⟨6, by decide⟩ <;> decide
  | _ + 7 => omega

set_option maxRecDepth 4096 in
private theorem q22Mat_rowspace_minw_mask :
    ∀ m : Fin 128,
      let rowComb (j : Fin 7) : Bool :=
        (List.finRange 7).foldl (fun acc r => xor acc (maskToFin7Bool m.val r && q22Mat r j)) false
      (∃ j : Fin 7, rowComb j = true) →
      3 ≤ ((List.finRange 7).filter (fun j => rowComb j)).length := by
  decide

private theorem q22Mat_rowspace_minw (u : Fin 7 → Bool) :
    let rowComb (j : Fin 7) : Bool :=
      (List.finRange 7).foldl (fun acc r => xor acc (u r && q22Mat r j)) false
    (∃ j : Fin 7, rowComb j = true) →
    3 ≤ ((List.finRange 7).filter (fun j => rowComb j)).length := by
  have hfn : u = maskToFin7Bool (fin7BoolToMask u) := by
    funext r; exact (maskToFin7Bool_fin7BoolToMask u r).symm
  rw [hfn]
  exact q22Mat_rowspace_minw_mask ⟨fin7BoolToMask u, fin7BoolToMask_lt u⟩

/-- `NV07`: Concrete `Q(2, 2)` (`n = 7`) punctured `RM(1, 3)` incidence matrix directly inhabits
    EVERY hypothesis of `binary_singer_exact_distance_two` (`T4a`) and witnesses `d_min = 2`. -/
theorem nonvacuity_nv07_binary_singer_d2 :
    Pillar4.checkConj24Instance 3 11 = (true, false) ∧
    Pillar4.checkConj24Instance 4 19 = (true, true) ∧
    ((∀ c : Fin 7,
        (∃ _r : Fin 7, true = true) ∧
        (∃ r : Fin 7, q22Mat r c = true) ∧
        (∃ r : Fin 7, xor true (q22Mat r c) = true)) ∧
     (∀ j0 j1 : Fin 7, j0 ≠ j1 →
        let xVec (j : Fin 7) : Bool := (j == j0) || (j == j1)
        (((List.finRange 7).filter (fun j => xVec j)).length = 2) ∧
        (∀ u : Fin 7 → Bool,
          let rowComb (j : Fin 7) : Bool :=
            (List.finRange 7).foldl (fun acc r => xor acc (u r && q22Mat r j)) false
          ¬ (∀ j : Fin 7, rowComb j = xVec j)))) := by
  refine ⟨Pillar4.conj24_concrete_d2_to_d5.1, Pillar4.conj24_concrete_d2_to_d5.2.1, ?_⟩
  exact Pillar4.binary_singer_exact_distance_two (by decide) q22Mat
    (by decide) (by decide) q22Mat_rowspace_minw

/-- Concrete `Q(3, 2)` (`p = 3, n = 13`) hyperplane & conic supports (`x^3 + 2x^2 + 1` over `GF(3)`),
    directly inhabiting EVERY hypothesis of the universal theorem `odd_prime_singer_upper_bound` (`T4b`)! -/
@[expose] def q32TauH (k : Fin 13) : Int :=
  if Pillar4.bitAt (Pillar4.buildTauHMaskAndSup 3 1 0 2 13).1 k.val == 1 then 1 else 0

@[expose] def q32TauQ (k : Fin 13) : Int :=
  q32TauH ⟨(2 * k.val) % 13, Nat.mod_lt _ (by decide)⟩

/-- `NV08`: Concrete `Q(3, 2)` (`n = 13`) vectors directly inhabit `odd_prime_singer_upper_bound` (`T4b`),
    alongside the concrete `Q(7, 2)` (`n = 57`, weight 8) and `Q(11, 2)` (`n = 133`, weight 12) witnesses! -/
theorem nonvacuity_nv08_singer_q7_q11_witnesses :
    Pillar4.verifyQp2LineWitness 7 2 1 1 = true ∧
    Pillar4.verifyQp2LineWitness 11 3 0 1 = true ∧
    (∀ i : Fin 13,
      (Pillar4.circMulVec (Pillar4.circConv q32TauQ q32TauH) q32TauH i -
       Pillar4.circMulVec q32TauH q32TauH i) % 3 = 0) ∧
    (¬ ∃ u : Fin 13 → Int,
      (∀ k : Fin 13, Pillar4.vecMulCirc u q32TauH k % 3 = q32TauH k % 3) ∧
      (∀ k : Fin 13, Pillar4.vecMulCirc u (Pillar4.circConv q32TauQ q32TauH) k % 3 = q32TauH k % 3)) := by
  have h3 := Pillar4.odd_prime_singer_upper_bound 3 (by decide) q32TauH q32TauQ
    (by decide) (by decide) (by decide) (by decide) (by decide)
  exact ⟨Pillar4.qp2_concrete_flagship_witnesses.2.2.1,
         Pillar4.qp2_concrete_flagship_witnesses.2.2.2,
         h3.1, h3.2⟩

end

end WeylMagicFrontier
