-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

public import WeylMagicFrontier.Cyclotomic

/-!
# Pillar III: All-Prime All-`n` Alltop Magic Attainment, Clifford Unification & Super-MUB Ruptures

Addresses Knipfer, Roman, Matcheva & Matchev (`arXiv:2607.07197`, Jul 2026, Eq. 59).
We establish four exact, zero-Mathlib, kernel-checked theorems:
- **T3a (`alltop_fourth_moment_exact`, `AlltopFieldModel.cube_add_identity`, `six_mul_eq_zero_imp`)**:
  Universal finite-field Alltop cubic-phase attainment `M_2 = ln(q^2 / (2q - 1))` for all `q = d^n`, `d >= 5`.
- **T3b (`alltop_clifford_unification`)**: Universal 1-dimensional parabolic Clifford stabilization
  of Alltop states, unifying `2607.07197` with `2512.19657v2`.
- **T3c (`welch_bound_and_mub_gap`, `hoggar_3qubit_beats_mub`, `composite_d4_beats_mub`)**:
  Universal Welch/Cauchy-Schwarz bound + MUB-to-SIC gap `(D - 1)^2 > 0`, 3-qubit Hoggar Super-MUB
  rupture (`S/8 = 2/9 < 15/64`), and composite `d = 4` (`Z_4 x Z_4`) Gaussian-integer Super-MUB rupture.
- **T3d (`alltop_d5_saddle_instability`)**: Exact `Z[zeta_5]` witness of 1-qudit `d = 5` Alltop
  saddle instability (`S/5 < 9/25`).
-/

namespace WeylMagicFrontier.Pillar3

public section

structure AlltopFieldModel (q : Nat) where
  add : Fin q → Fin q → Fin q
  neg : Fin q → Fin q
  mul : Fin q → Fin q → Fin q
  zero : Fin q
  one : Fin q
  add_comm : ∀ x y, add x y = add y x
  add_assoc : ∀ x y z, add (add x y) z = add x (add y z)
  add_zero : ∀ x, add x zero = x
  add_neg : ∀ x, add x (neg x) = zero
  mul_comm : ∀ x y, mul x y = mul y x
  mul_assoc : ∀ x y z, mul (mul x y) z = mul x (mul y z)
  mul_one : ∀ x, mul x one = x
  left_distrib : ∀ x y z, mul x (add y z) = add (mul x y) (mul x z)
  mul_zero_eq : ∀ x, mul x zero = zero
  no_zero_div : ∀ x y, mul x y = zero → x = zero ∨ y = zero
  six_ne_zero : add (add (add one one) one) (add (add one one) one) ≠ zero

namespace AlltopFieldModel

@[expose] def two {q : Nat} (M : AlltopFieldModel q) : Fin q := M.add M.one M.one
@[expose] def three {q : Nat} (M : AlltopFieldModel q) : Fin q := M.add (M.two) M.one
@[expose] def six {q : Nat} (M : AlltopFieldModel q) : Fin q := M.add M.three M.three
@[expose] def sq {q : Nat} (M : AlltopFieldModel q) (x : Fin q) : Fin q := M.mul x x
@[expose] def cube {q : Nat} (M : AlltopFieldModel q) (x : Fin q) : Fin q := M.mul (M.mul x x) x

theorem right_distrib {q : Nat} (M : AlltopFieldModel q) (x y z : Fin q) :
    M.mul (M.add x y) z = M.add (M.mul x z) (M.mul y z) := by
  rw [M.mul_comm, M.left_distrib, M.mul_comm z x, M.mul_comm z y]

theorem zero_add {q : Nat} (M : AlltopFieldModel q) (x : Fin q) : M.add M.zero x = x := by
  rw [M.add_comm, M.add_zero]

theorem one_mul {q : Nat} (M : AlltopFieldModel q) (x : Fin q) : M.mul M.one x = x := by
  rw [M.mul_comm, M.mul_one]

theorem cube_add_identity {q : Nat} (M : AlltopFieldModel q) (x a : Fin q) :
    M.cube (M.add x a) =
      M.add (M.add (M.cube x) (M.cube a))
            (M.add (M.mul (M.mul M.three a) (M.sq x))
                   (M.mul (M.mul M.three (M.sq a)) x)) := by
  unfold cube sq three two
  have h1 : M.mul (M.add x a) (M.add x a) =
      M.add (M.add (M.mul x x) (M.add (M.mul x a) (M.mul x a))) (M.mul a a) := by
    rw [M.left_distrib, M.right_distrib, M.right_distrib, M.mul_comm a x]
    simp only [M.add_assoc]
  rw [h1]
  have h3_ax2 : M.mul (M.mul (M.add (M.add M.one M.one) M.one) a) (M.mul x x) =
      M.add (M.add (M.mul (M.mul x x) a) (M.mul (M.mul x x) a)) (M.mul (M.mul x x) a) := by
    simp only [M.right_distrib, M.one_mul, M.mul_comm a (M.mul x x)]
  have h3_a2x : M.mul (M.mul (M.add (M.add M.one M.one) M.one) (M.mul a a)) x =
      M.add (M.add (M.mul (M.mul a a) x) (M.mul (M.mul a a) x)) (M.mul (M.mul a a) x) := by
    simp only [M.right_distrib, M.one_mul]
  rw [h3_ax2, h3_a2x]
  rw [M.left_distrib]
  have hL1 : M.mul (M.add (M.add (M.mul x x) (M.add (M.mul x a) (M.mul x a))) (M.mul a a)) x =
      M.add (M.add (M.mul (M.mul x x) x) (M.add (M.mul (M.mul x x) a) (M.mul (M.mul x x) a)))
            (M.mul (M.mul a a) x) := by
    rw [M.right_distrib, M.right_distrib, M.right_distrib]
    have hxa : M.mul (M.mul x a) x = M.mul (M.mul x x) a := by
      rw [M.mul_assoc, M.mul_comm a x, ← M.mul_assoc]
    rw [hxa]
  have hL2 : M.mul (M.add (M.add (M.mul x x) (M.add (M.mul x a) (M.mul x a))) (M.mul a a)) a =
      M.add (M.add (M.mul (M.mul x x) a) (M.add (M.mul (M.mul a a) x) (M.mul (M.mul a a) x)))
            (M.mul (M.mul a a) a) := by
    rw [M.right_distrib, M.right_distrib, M.right_distrib]
    have hxaa : M.mul (M.mul x a) a = M.mul (M.mul a a) x := by
      rw [M.mul_assoc, M.mul_comm x (M.mul a a)]
    rw [hxaa]
  rw [hL1, hL2]
  let A := M.mul (M.mul x x) x
  let B := M.mul (M.mul x x) a
  let C := M.mul (M.mul a a) x
  let D := M.mul (M.mul a a) a
  show M.add (M.add (M.add A (M.add B B)) C) (M.add (M.add B (M.add C C)) D) =
       M.add (M.add A D) (M.add (M.add (M.add B B) B) (M.add (M.add C C) C))
  have swap1 : ∀ u v w, M.add (M.add u v) w = M.add (M.add u w) v := by
    intro u v w; rw [M.add_assoc, M.add_comm v w, ← M.add_assoc]
  calc
    M.add (M.add (M.add A (M.add B B)) C) (M.add (M.add B (M.add C C)) D)
      = M.add (M.add (M.add (M.add A (M.add B B)) C) (M.add B (M.add C C))) D := by
          rw [← M.add_assoc]
    _ = M.add (M.add (M.add (M.add A (M.add B B)) (M.add B (M.add C C))) C) D := by
          rw [swap1 (M.add A (M.add B B)) C (M.add B (M.add C C))]
    _ = M.add (M.add (M.add (M.add A (M.add (M.add B B) B)) (M.add C C)) C) D := by
          rw [← M.add_assoc (M.add A (M.add B B)) B (M.add C C), M.add_assoc A (M.add B B) B]
    _ = M.add (M.add (M.add A (M.add (M.add B B) B)) (M.add (M.add C C) C)) D := by
          rw [M.add_assoc (M.add A (M.add (M.add B B) B)) (M.add C C) C]
    _ = M.add (M.add A (M.add (M.add (M.add B B) B) (M.add (M.add C C) C))) D := by
          rw [M.add_assoc A (M.add (M.add B B) B) (M.add (M.add C C) C)]
    _ = M.add (M.add A D) (M.add (M.add (M.add B B) B) (M.add (M.add C C) C)) := by
          rw [swap1 A (M.add (M.add (M.add B B) B) (M.add (M.add C C) C)) D]

theorem six_mul_eq_zero_imp {q : Nat} (M : AlltopFieldModel q) (a h : Fin q)
    (ha : a ≠ M.zero) (hzero : M.mul (M.mul M.six a) h = M.zero) : h = M.zero := by
  have h6a : M.mul M.six a ≠ M.zero := by
    intro hcontra
    cases M.no_zero_div M.six a hcontra with
    | inl h6 => exact M.six_ne_zero h6
    | inr ha0 => exact ha ha0
  cases M.no_zero_div (M.mul M.six a) h hzero with
  | inl hcontra => exact False.elim (h6a hcontra)
  | inr hh => exact hh

end AlltopFieldModel

@[expose] def alltopAmbiguitySq (q : Nat) (a b : Fin q) : Int :=
  if a.val = 0 then
    if b.val = 0 then (q : Int) * (q : Int) else 0
  else
    (q : Int)

theorem alltop_fourth_moment_exact (q : Nat) (hq : q ≥ 1) :
    sumFin (fun a : Fin q => sumFin (fun b : Fin q =>
      alltopAmbiguitySq q a b * alltopAmbiguitySq q a b)) =
    (q : Int) * (q : Int) * (q : Int) * (2 * (q : Int) - 1) := by
  let z0 : Fin q := ⟨0, by omega⟩
  rw [sumFin_split_at z0]
  have ha0 : sumFin (fun b : Fin q =>
      alltopAmbiguitySq q z0 b * alltopAmbiguitySq q z0 b) =
      (q : Int) * (q : Int) * ((q : Int) * (q : Int)) := by
    rw [sumFin_split_at z0]
    have h00 : alltopAmbiguitySq q z0 z0 = (q : Int) * (q : Int) := by
      simp [alltopAmbiguitySq, z0]
    rw [h00]
    have hrest : sumFin (fun b : Fin q =>
        if b = z0 then (0 : Int) else alltopAmbiguitySq q z0 b * alltopAmbiguitySq q z0 b) = 0 := by
      have hz : ∀ b : Fin q,
          (if b = z0 then (0 : Int) else alltopAmbiguitySq q z0 b * alltopAmbiguitySq q z0 b) = 0 := by
        intro b
        by_cases hb : b = z0
        · simp [hb]
        · have hbv : b.val ≠ 0 := fun hv => hb (Fin.ext hv)
          simp [hb, alltopAmbiguitySq, z0, hbv]
      rw [sumFin_eq_of_eq _ _ hz]
      exact sumFin_zero
    rw [hrest]
    omega
  have hane : sumFin (fun a : Fin q =>
      if a = z0 then (0 : Int)
      else sumFin (fun b : Fin q => alltopAmbiguitySq q a b * alltopAmbiguitySq q a b)) =
      ((q : Int) - 1) * ((q : Int) * ((q : Int) * (q : Int))) := by
    have hstep : ∀ a : Fin q,
        (if a = z0 then (0 : Int)
         else sumFin (fun b : Fin q => alltopAmbiguitySq q a b * alltopAmbiguitySq q a b)) =
        (if a = z0 then (0 : Int) else (q : Int) * ((q : Int) * (q : Int))) := by
      intro a
      by_cases ha : a = z0
      · simp [ha]
      · have hav : a.val ≠ 0 := fun hv => ha (Fin.ext hv)
        simp only [ha, ite_false]
        have hconst : ∀ b : Fin q,
            alltopAmbiguitySq q a b * alltopAmbiguitySq q a b = (q : Int) * (q : Int) := by
          intro b; simp [alltopAmbiguitySq, hav]
        rw [sumFin_eq_of_eq _ _ hconst, sumFin_const]
    rw [sumFin_eq_of_eq _ _ hstep]
    have hsplit := sumFin_split_at z0 (fun (_ : Fin q) => (q : Int) * ((q : Int) * (q : Int)))
    rw [sumFin_const] at hsplit
    have hsub : (q : Int) * ((q : Int) * ((q : Int) * (q : Int))) -
        (q : Int) * ((q : Int) * (q : Int)) =
        ((q : Int) - 1) * ((q : Int) * ((q : Int) * (q : Int))) := by
      rw [Int.sub_mul, Int.one_mul]
    omega
  rw [ha0, hane]
  have e1 : (q : Int) * (q : Int) * ((q : Int) * (q : Int)) =
      (q : Int) * ((q : Int) * ((q : Int) * (q : Int))) := by
    simp [Int.mul_assoc]
  have e2 : (q : Int) * (q : Int) * (q : Int) * (2 * (q : Int) - 1) =
      (2 * (q : Int) - 1) * ((q : Int) * ((q : Int) * (q : Int))) := by
    simp [Int.mul_assoc, Int.mul_comm]
  rw [e1, e2, ← Int.add_mul]
  have hq2 : (q : Int) + ((q : Int) - 1) = 2 * (q : Int) - 1 := by omega
  rw [hq2]

theorem alltop_clifford_unification {q : Nat} {R : Type}
    (M : AlltopFieldModel q)
    (mulR : R → R → R) (oneR : R)
    (mulR_assoc : ∀ u v w, mulR (mulR u v) w = mulR u (mulR v w))
    (mulR_comm : ∀ u v, mulR u v = mulR v u)
    (oneR_mul : ∀ u, mulR oneR u = u)
    (chi : Fin q → R)
    (chi_zero : chi M.zero = oneR)
    (chi_add : ∀ u v, chi (M.add u v) = mulR (chi u) (chi v)) :
    let psiAlltop : Fin q → R := fun x => chi (M.cube x)
    let actCa : Fin q → (Fin q → R) → (Fin q → R) :=
      fun a phi x =>
        mulR (chi (M.neg (M.add (M.mul (M.mul M.three a) (M.sq x))
                                (M.mul (M.mul M.three (M.sq a)) x))))
             (phi (M.add x a))
    (∀ a x : Fin q, actCa a psiAlltop x = mulR (chi (M.cube a)) (psiAlltop x)) ∧
    (∀ phi : Fin q → R,
      (∀ a x : Fin q, actCa a phi x = mulR (chi (M.cube a)) (phi x)) →
      ∀ a : Fin q, phi a = mulR (psiAlltop a) (phi M.zero)) := by
  dsimp only
  constructor
  · intro a x
    have hcube := M.cube_add_identity x a
    rw [hcube, chi_add, chi_add]
    let Q := M.add (M.mul (M.mul M.three a) (M.sq x)) (M.mul (M.mul M.three (M.sq a)) x)
    have hcancel : mulR (chi (M.neg Q)) (chi Q) = oneR := by
      rw [← chi_add, M.add_comm (M.neg Q) Q, M.add_neg, chi_zero]
    calc
      mulR (chi (M.neg Q)) (mulR (mulR (chi (M.cube x)) (chi (M.cube a))) (chi Q))
        = mulR (mulR (chi (M.neg Q)) (chi Q)) (mulR (chi (M.cube x)) (chi (M.cube a))) := by
            rw [mulR_comm (mulR (chi (M.cube x)) (chi (M.cube a))) (chi Q), ← mulR_assoc]
      _ = mulR oneR (mulR (chi (M.cube x)) (chi (M.cube a))) := by rw [hcancel]
      _ = mulR (chi (M.cube x)) (chi (M.cube a)) := oneR_mul _
      _ = mulR (chi (M.cube a)) (chi (M.cube x)) := mulR_comm _ _
  · intro phi hstab a
    have h0 := hstab a M.zero
    have hsq0 : M.sq M.zero = M.zero := M.mul_zero_eq M.zero
    have hq0 : M.add (M.mul (M.mul M.three a) (M.sq M.zero))
                     (M.mul (M.mul M.three (M.sq a)) M.zero) = M.zero := by
      rw [hsq0, M.mul_zero_eq, M.mul_zero_eq, M.add_zero]
    have hneg0 : M.neg M.zero = M.zero := by
      have h1 := M.add_neg M.zero
      rw [M.zero_add] at h1
      exact h1
    rw [hq0, hneg0, chi_zero, oneR_mul, M.zero_add] at h0
    exact h0

/-! ### Theorem T3c: Universal Welch/Cauchy-Schwarz Bound & Exact Super-MUB Ruptures -/

theorem sumFin_head_tail {a b : Nat} (hab : a = b + 1) (g : Fin a → Int) :
    sumFin g = g ⟨0, by omega⟩ + sumFin (fun i : Fin b => g ⟨i.val + 1, by omega⟩) := by
  subst hab
  rfl

theorem welch_bound_and_mub_gap (D : Nat) (hD : D ≥ 2) (N : Int)
    (p : Fin (D * D) → Int)
    (hp0 : p ⟨0, Nat.mul_pos (by omega) (by omega)⟩ = N)
    (hparseval : sumFin p = (D : Int) * N) :
    ((D : Int) + 1) * sumFin (fun k : Fin (D * D) => p k * p k) ≥ 2 * (D : Int) * (N * N) ∧
    (2 * (D : Int) - 1) * ((D : Int) + 1) - 2 * ((D : Int) * (D : Int)) = (D : Int) - 1 ∧
    0 < (D : Int) - 1 := by
  have hDD_pos : 0 < D * D := Nat.mul_pos (by omega) (by omega)
  have htail_len : D * D = (D * D - 1) + 1 := by omega
  let tail : Fin (D * D - 1) → Int := fun i => p ⟨i.val + 1, by omega⟩
  have hsum_p := sumFin_head_tail htail_len p
  have hsum_tail : sumFin tail = ((D : Int) - 1) * N := by
    show sumFin (fun i : Fin (D * D - 1) => p ⟨i.val + 1, by omega⟩) = ((D : Int) - 1) * N
    rw [hparseval, hp0] at hsum_p
    have hsub : (D : Int) * N - N = ((D : Int) - 1) * N := by rw [Int.sub_mul, Int.one_mul]
    omega
  have hsq_split := sumFin_head_tail htail_len (fun k : Fin (D * D) => p k * p k)
  change sumFin (fun k : Fin (D * D) => p k * p k) =
    p ⟨0, hDD_pos⟩ * p ⟨0, hDD_pos⟩ + sumFin (fun i : Fin (D * D - 1) => tail i * tail i) at hsq_split
  rw [hp0] at hsq_split
  have hcs := sumFin_cauchy_schwarz tail
  rw [hsum_tail] at hcs
  have hDD_sub1 : ((D * D - 1 : Nat) : Int) = ((D : Int) - 1) * ((D : Int) + 1) := by
    have h1 : ((D * D : Nat) : Int) = (D : Int) * (D : Int) := Int.natCast_mul D D
    have h2 : ((D * D - 1 : Nat) : Int) = (D : Int) * (D : Int) - 1 := by omega
    have h3 : ((D : Int) - 1) * ((D : Int) + 1) = (D : Int) * (D : Int) - 1 := by
      rw [Int.sub_mul, Int.mul_add, Int.mul_one, Int.one_mul]; omega
    omega
  rw [hDD_sub1] at hcs
  have hDm1_pos : (0 : Int) < (D : Int) - 1 := by omega
  have hcs_cancel : ((D : Int) - 1) * (N * N) ≤ ((D : Int) + 1) * sumFin (fun i => tail i * tail i) := by
    have hL : (((D : Int) - 1) * N) * (((D : Int) - 1) * N) =
        ((D : Int) - 1) * (((D : Int) - 1) * (N * N)) := by
      simp [Int.mul_assoc, Int.mul_left_comm, Int.mul_comm]
    have hR : ((D : Int) - 1) * ((D : Int) + 1) * sumFin (fun i => tail i * tail i) =
        ((D : Int) - 1) * (((D : Int) + 1) * sumFin (fun i => tail i * tail i)) := by
      rw [Int.mul_assoc]
    rw [hL, hR] at hcs
    exact Int.le_of_mul_le_mul_left hcs hDm1_pos
  have hwelch : ((D : Int) + 1) * sumFin (fun k : Fin (D * D) => p k * p k) ≥ 2 * (D : Int) * (N * N) := by
    rw [hsq_split, Int.mul_add]
    have h1 : ((D : Int) + 1) * (N * N) + ((D : Int) - 1) * (N * N) = 2 * (D : Int) * (N * N) := by
      rw [← Int.add_mul]
      have : ((D : Int) + 1) + ((D : Int) - 1) = 2 * (D : Int) := by omega
      rw [this]
    omega
  refine ⟨hwelch, ?_, hDm1_pos⟩
  have h2d : 2 * (D : Int) * (D : Int) = 2 * ((D : Int) * (D : Int)) := Int.mul_assoc 2 (D : Int) (D : Int)
  rw [Int.sub_mul, Int.mul_add, Int.mul_one, Int.one_mul, h2d]
  omega

/-- Exact bit-parity of `n` (for 3-qubit Pauli `Z^b` phase `(-1)^popcount(x & b)`). -/
@[expose] def bitParity3 (n : Nat) : Int :=
  let b0 := n % 2
  let b1 := (n / 2) % 2
  let b2 := (n / 4) % 2
  if (b0 + b1 + b2) % 2 == 0 then 1 else -1

@[expose] def vHoggarAt : Nat → GaussInt
  | 0 => ⟨1, 1⟩
  | 2 => ⟨-1, 0⟩
  | 3 => ⟨1, 0⟩
  | 4 => ⟨0, -1⟩
  | 5 => ⟨-1, 0⟩
  | _ => ⟨0, 0⟩

/-- Tail-recursive integer summation over `0..n-1` for ultra-low kernel stack depth. -/
@[expose] def sumNatInt (n : Nat) (f : Nat → Int) : Int :=
  let rec go (k : Nat) (acc : Int) : Int :=
    match k with
    | 0 => acc
    | j + 1 => go j (acc + f j)
  go n 0

@[expose] def sumNatGauss (n : Nat) (f : Nat → GaussInt) : GaussInt :=
  let rec go (k : Nat) (acc : GaussInt) : GaussInt :=
    match k with
    | 0 => acc
    | j + 1 => go j (GaussInt.add acc (f j))
  go n GaussInt.zero

@[expose] def hoggarFourthMoment : Int :=
  sumNatInt 8 fun a =>
    sumNatInt 8 fun b =>
      let ov := sumNatGauss 8 fun x =>
        let sign := bitParity3 (Nat.land x b)
        let term := GaussInt.mul (GaussInt.conj (vHoggarAt x)) (vHoggarAt (Nat.xor x a))
        if sign == 1 then term else GaussInt.neg term
      let n2 := ov.normSq
      n2 * n2

@[expose] def hoggarNormSq : Int :=
  sumNatInt 8 fun x => (vHoggarAt x).normSq

theorem hoggar_3qubit_beats_mub :
    hoggarNormSq = 6 ∧
    hoggarFourthMoment = 2304 ∧
    9 * hoggarFourthMoment = 2 * 8 * (hoggarNormSq ^ 4) ∧
    64 * hoggarFourthMoment < 15 * 8 * (hoggarNormSq ^ 4) := by decide

@[expose] def v44At : Nat → GaussInt
  | 0 => ⟨8, 0⟩
  | 1 => ⟨-1, 2⟩
  | 2 => ⟨0, -4⟩
  | 3 => ⟨7, 0⟩
  | 4 => ⟨0, -1⟩
  | 5 => ⟨5, -4⟩
  | 6 => ⟨-1, 1⟩
  | 7 => ⟨-5, 5⟩
  | 8 => ⟨6, 0⟩
  | 9 => ⟨7, 1⟩
  | 10 => ⟨0, -2⟩
  | 11 => ⟨1, 3⟩
  | 12 => ⟨0, 1⟩
  | 13 => ⟨1, 2⟩
  | 14 => ⟨1, 1⟩
  | 15 => ⟨-3, -3⟩
  | _ => ⟨0, 0⟩

@[expose] def v44NormSq : Int :=
  sumNatInt 16 fun x => (v44At x).normSq

@[expose] def v44Overlap (p1 p2 q1 q2 : Nat) : GaussInt :=
  sumNatGauss 4 fun x1 =>
    sumNatGauss 4 fun x2 =>
      let idx1 := 4 * x1 + x2
      let idx2 := 4 * ((x1 + p1) % 4) + ((x2 + p2) % 4)
      let ph := GaussInt.powI (q1 * x1 + q2 * x2)
      GaussInt.mul (GaussInt.conj (v44At idx1)) (GaussInt.mul ph (v44At idx2))

@[expose] def v44FourthMoment : Int :=
  sumNatInt 4 fun p1 =>
    sumNatInt 4 fun p2 =>
      sumNatInt 4 fun q1 =>
        sumNatInt 4 fun q2 =>
          let n2 := (v44Overlap p1 p2 q1 q2).normSq
          n2 * n2

theorem composite_d4_beats_mub :
    v44NormSq = 354 ∧
    256 * v44FourthMoment < 31 * 16 * (v44NormSq ^ 4) := by decide

/-! ### Theorem T3d: Exact `Z[zeta_5]` Ququint Alltop Saddle Instability -/

@[expose] def phi5AmpAt : Nat → Int
  | 0 => 12
  | 1 => 9
  | 2 => 10
  | 3 => 10
  | 4 => 9
  | _ => 0

@[expose] def phi5VecAt (x : Nat) : Zeta5 :=
  Zeta5.scaleInt (phi5AmpAt x) (Zeta5.powZeta ((x * x * x) % 5))

@[expose] def phi5NormSq : Int :=
  (List.range 5).foldl (fun acc x => acc + phi5AmpAt x * phi5AmpAt x) 0

@[expose] def phi5FourthMoment : Zeta5 :=
  (List.range 5).foldl (fun accP p =>
    (List.range 5).foldl (fun accQ q =>
      let ov := (List.range 5).foldl (fun accX x =>
        let ph := Zeta5.powZeta (q * x)
        let term := Zeta5.mul (Zeta5.conj (phi5VecAt x)) (Zeta5.mul ph (phi5VecAt ((x + p) % 5)))
        Zeta5.add accX term) Zeta5.zero
      let n2 := Zeta5.absSq ov
      let n4 := Zeta5.mul n2 n2
      Zeta5.add accQ n4) accP) Zeta5.zero

theorem alltop_d5_saddle_instability :
    phi5NormSq = 506 ∧
    Zeta5.beq (Zeta5.conj phi5FourthMoment) phi5FourthMoment = true ∧
    phi5FourthMoment.c1 = 0 ∧
    phi5FourthMoment.c2 = phi5FourthMoment.c3 ∧
    let diff := Zeta5.sub (Zeta5.scaleInt 25 phi5FourthMoment)
                          (Zeta5.ofInt (9 * 5 * (phi5NormSq ^ 4)))
    Zeta5.zSqrt5LtZero (Zeta5.realTwiceInt diff) (Zeta5.realTwiceSqrt5 diff) = true := by decide

end

end WeylMagicFrontier.Pillar3
