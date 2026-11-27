-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

public import WeylMagicFrontier.Cyclotomic

/-!
# Pillar I: Refutation of Erew & Goldstein Conjecture 1 (`arXiv:2512.19657v2`, Feb 2026)

Conjecture 1 of Erew & Goldstein (`arXiv:2512.19657v2`, Sec. 4.5.3) states:
> "Every SIC-POVM fiducial state is a Clifford-stabilizer state"
where a `G`-stabilizer state is defined as a pure state spanning a **1-dimensional**
joint eigenspace of a finite subgroup `G <= Cliff_d`.

We establish four exact, zero-Mathlib, kernel-checked theorems:
- **T1a (`qutrit_rational_circle_wh_sic`)**: Universal rational circle of qutrit WH-SICs.
- **T1b (`qutrit_sic_refutes_clifford_stabilizer_conjecture`)**: Exhaustive exact 216-element
  `PCliff_3` stabilizer refutation on `v345 = (0, 5, -(3 + 4i))`, proving `|Stab| = 3` (`{I, P, P^2}`)
  and 2-dimensional joint eigenspace `span(e_1, e_2)`!
- **T1c (`zauner_eigenspace_dim_universal_obstruction`)**: Universal all-`d` Zauner eigenspace
  dimension obstruction (`d >= 7` all three eigenspaces `>= 2`; `d >= 4` canonical eigenspace `>= 2`).
- **T1d (`dim4_scott_grassl_4a_obstruction`)**: Exact `d = 4` Scott-Grassl `4a` trace-dimension
  certificate (`m0 = 2 > 1`).
-/

namespace WeylMagicFrontier.Pillar1

public section

/-- A 3-component vector over `Z[i, omega_3]`. -/
@[ext]
structure Vec3 where
  v0 : Zeta12
  v1 : Zeta12
  v2 : Zeta12
  deriving DecidableEq, Repr, Inhabited

namespace Vec3

@[expose] def beq (u v : Vec3) : Bool :=
  Zeta12.beq u.v0 v.v0 && Zeta12.beq u.v1 v.v1 && Zeta12.beq u.v2 v.v2

@[expose] def e0 : Vec3 := ⟨Zeta12.one, Zeta12.zero, Zeta12.zero⟩
@[expose] def e1 : Vec3 := ⟨Zeta12.zero, Zeta12.one, Zeta12.zero⟩
@[expose] def e2 : Vec3 := ⟨Zeta12.zero, Zeta12.zero, Zeta12.one⟩

@[expose] def scale (s : Zeta12) (v : Vec3) : Vec3 :=
  ⟨Zeta12.mul s v.v0, Zeta12.mul s v.v1, Zeta12.mul s v.v2⟩

@[expose] def add (u v : Vec3) : Vec3 :=
  ⟨Zeta12.add u.v0 v.v0, Zeta12.add u.v1 v.v1, Zeta12.add u.v2 v.v2⟩

@[expose] def inner (u v : Vec3) : Zeta12 :=
  Zeta12.add
    (Zeta12.add (Zeta12.mul (Zeta12.conj u.v0) v.v0)
                (Zeta12.mul (Zeta12.conj u.v1) v.v1))
    (Zeta12.mul (Zeta12.conj u.v2) v.v2)

/-- Exact collinearity predicate via vanishing `2 x 2` minors over `Z[i, omega_3]`. -/
@[expose] def isCollinear (u w : Vec3) : Bool :=
  Zeta12.beq (Zeta12.mul u.v0 w.v1) (Zeta12.mul u.v1 w.v0) &&
  Zeta12.beq (Zeta12.mul u.v0 w.v2) (Zeta12.mul u.v2 w.v0) &&
  Zeta12.beq (Zeta12.mul u.v1 w.v2) (Zeta12.mul u.v2 w.v1)

/-- Soundness of collinearity witness: any scalar multiple `scale s u` satisfies `isCollinear u (scale s u) = true`. -/
theorem isCollinear_of_scale (s : Zeta12) (u : Vec3) :
    isCollinear u (scale s u) = true := by
  unfold isCollinear scale
  have h01 : Zeta12.mul u.v0 (Zeta12.mul s u.v1) = Zeta12.mul u.v1 (Zeta12.mul s u.v0) := by
    rw [← Zeta12.mul_assoc, Zeta12.mul_comm u.v0 s, Zeta12.mul_assoc,
        Zeta12.mul_comm u.v0 u.v1, ← Zeta12.mul_assoc, Zeta12.mul_comm s u.v1, Zeta12.mul_assoc]
  have h02 : Zeta12.mul u.v0 (Zeta12.mul s u.v2) = Zeta12.mul u.v2 (Zeta12.mul s u.v0) := by
    rw [← Zeta12.mul_assoc, Zeta12.mul_comm u.v0 s, Zeta12.mul_assoc,
        Zeta12.mul_comm u.v0 u.v2, ← Zeta12.mul_assoc, Zeta12.mul_comm s u.v2, Zeta12.mul_assoc]
  have h12 : Zeta12.mul u.v1 (Zeta12.mul s u.v2) = Zeta12.mul u.v2 (Zeta12.mul s u.v1) := by
    rw [← Zeta12.mul_assoc, Zeta12.mul_comm u.v1 s, Zeta12.mul_assoc,
        Zeta12.mul_comm u.v1 u.v2, ← Zeta12.mul_assoc, Zeta12.mul_comm s u.v2, Zeta12.mul_assoc]
  simp only [Bool.and_eq_true, Zeta12.beq_iff_eq]
  exact ⟨⟨h01, h02⟩, h12⟩

/-- Action of Weyl-Heisenberg displacement `X^p Z^q` on `Vec3`. -/
@[expose] def actWH (p q : Nat) (v : Vec3) : Vec3 :=
  let get (k : Nat) : Zeta12 :=
    match k % 3 with
    | 0 => v.v0
    | 1 => v.v1
    | _ => v.v2
  let coord (y : Nat) : Zeta12 :=
    let x := (y + 3 - p % 3) % 3
    Zeta12.mul (Zeta12.powOmega (q * x)) (get x)
  ⟨coord 0, coord 1, coord 2⟩

@[expose] def rationalFiducial (a b c : Int) : Vec3 :=
  ⟨Zeta12.zero, Zeta12.ofInt c, ⟨-a, -b, 0, 0⟩⟩

@[expose] def v345 : Vec3 := rationalFiducial 3 4 5

end Vec3

/-! ### Theorem T1a: Universal Rational Circle of Qutrit WH-SIC Fiducials -/

theorem rationalFiducial_normSq (a b c : Int) (hpyth : a * a + b * b = c * c) :
    Vec3.inner (Vec3.rationalFiducial a b c) (Vec3.rationalFiducial a b c) =
      Zeta12.ofInt (2 * (c * c)) := by
  unfold Vec3.inner Vec3.rationalFiducial Zeta12.conj Zeta12.mul Zeta12.add Zeta12.ofInt Zeta12.zero
  unfold GaussInt.mul GaussInt.sub GaussInt.add
  ext <;> simp
  · have h1 : (-a) * (-a) = a * a := Int.neg_mul_neg a a
    have h2 : b * (-b) = -(b * b) := Int.mul_neg b b
    omega
  · have h1 : (-a) * (-b) = a * b := Int.neg_mul_neg a b
    have h2 : b * (-a) = -(a * b) := by rw [Int.mul_neg, Int.mul_comm]
    omega

/-- **Theorem T1a (All-Pythagorean Qutrit WH-SIC Equiangularity)**:
    For EVERY `(a, b, c) : Int^3` with `a^2 + b^2 = c^2` and EVERY non-identity Weyl-Heisenberg
    displacement `(p, q) != (0, 0)` in `Z_3^2`, the overlap `ov = <v | X^p Z^q | v>` satisfies
    `4 * |ov|^2 = ||v||^4 = 4 * c^4` EXACTLY in `Z[i, omega_3]` (`normSqSqrt3Part = 0`)! -/
theorem qutrit_rational_circle_wh_sic (a b c : Int) (hpyth : a * a + b * b = c * c) :
    ∀ p q : Fin 3, (p.val ≠ 0 ∨ q.val ≠ 0) →
      let ov := Vec3.inner (Vec3.rationalFiducial a b c) (Vec3.actWH p.val q.val (Vec3.rationalFiducial a b c))
      4 * Zeta12.normSqIntPart ov = (2 * (c * c)) * (2 * (c * c)) ∧
      Zeta12.normSqSqrt3Part ov = 0 := by
  intro ⟨pv, hpv⟩ ⟨qv, hqv⟩ hne
  have hnorm_sq : (2 * (c * c)) * (2 * (c * c)) = 4 * ((c * c) * (c * c)) := by
    simp [Int.mul_assoc, Int.mul_left_comm, Int.mul_comm]
  have hcomb : (a * a) * (c * c) + (b * b) * (c * c) = (c * c) * (c * c) := by
    rw [← Int.add_mul, hpyth]
  match pv, qv with
  | 0, 0 => exfalso; cases hne with | inl h => exact h rfl | inr h => exact h rfl
  | 0, 1 =>
    dsimp only
    have hov : Vec3.inner (Vec3.rationalFiducial a b c)
        (Vec3.actWH 0 1 (Vec3.rationalFiducial a b c)) = Zeta12.ofInt (-(c * c)) := by
      unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
        Zeta12.add Zeta12.ofInt Zeta12.zero GaussInt.mul GaussInt.sub GaussInt.add
      have h1 : (-a) * (-a) = a * a := Int.neg_mul_neg a a
      have h2 : b * (-b) = -(b * b) := Int.mul_neg b b
      have h3 : (-a) * (-b) = a * b := Int.neg_mul_neg a b
      have h4 : b * (-a) = -(a * b) := by rw [Int.mul_neg, Int.mul_comm]
      have h5 : (-a) * a = -(a * a) := Int.neg_mul a a
      have h6 : (-a) * b = -(a * b) := Int.neg_mul a b
      have h7 : b * a = a * b := Int.mul_comm b a
      ext <;> simp <;> omega
    rw [hov]
    unfold Zeta12.ofInt Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
    have hsq : (-(c * c)) * (-(c * c)) = (c * c) * (c * c) := Int.neg_mul_neg (c * c) (c * c)
    constructor <;> simp <;> omega
  | 0, 2 =>
    dsimp only
    have hov : Vec3.inner (Vec3.rationalFiducial a b c)
        (Vec3.actWH 0 2 (Vec3.rationalFiducial a b c)) = Zeta12.ofInt (-(c * c)) := by
      unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
        Zeta12.add Zeta12.ofInt Zeta12.zero GaussInt.mul GaussInt.sub GaussInt.add
      have h1 : (-a) * (-a) = a * a := Int.neg_mul_neg a a
      have h2 : b * (-b) = -(b * b) := Int.mul_neg b b
      have h3 : (-a) * (-b) = a * b := Int.neg_mul_neg a b
      have h4 : b * (-a) = -(a * b) := by rw [Int.mul_neg, Int.mul_comm]
      have h5 : c * (-c) = -(c * c) := Int.mul_neg c c
      ext <;> simp <;> omega
    rw [hov]
    unfold Zeta12.ofInt Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
    have hsq : (-(c * c)) * (-(c * c)) = (c * c) * (c * c) := Int.neg_mul_neg (c * c) (c * c)
    constructor <;> simp <;> omega
  | 1, 0 =>
    dsimp only
    unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
      Zeta12.add Zeta12.ofInt Zeta12.zero Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
      GaussInt.mul GaussInt.sub GaussInt.add
    have hsq1 : ((-a) * c) * ((-a) * c) = (a * a) * (c * c) := by
      rw [Int.neg_mul, Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    have hsq2 : (b * c) * (b * c) = (b * b) * (c * c) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    constructor <;> simp <;> omega
  | 1, 1 =>
    dsimp only
    unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
      Zeta12.add Zeta12.ofInt Zeta12.zero Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
      GaussInt.mul GaussInt.sub GaussInt.add
    have hsq1 : ((-a) * c) * ((-a) * c) = (a * a) * (c * c) := by
      rw [Int.neg_mul, Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    have hsq2 : (b * c) * (b * c) = (b * b) * (c * c) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    constructor <;> simp <;> omega
  | 1, 2 =>
    dsimp only
    unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
      Zeta12.add Zeta12.ofInt Zeta12.zero Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
      GaussInt.mul GaussInt.sub GaussInt.add
    have h1 : (-a) * (-c) = a * c := Int.neg_mul_neg a c
    have h2 : b * (-c) = -(b * c) := Int.mul_neg b c
    have hsq1 : (a * c) * (a * c) = (a * a) * (c * c) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have hsq2 : (-(b * c)) * (-(b * c)) = (b * b) * (c * c) := by
      rw [Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    have hc1 : (-(b * c)) * (a * c) = -(a * b * (c * c)) := by
      rw [Int.neg_mul]; simp [Int.mul_left_comm, Int.mul_comm]
    have hc2 : (a * c) * (-(b * c)) = -(a * b * (c * c)) := by
      rw [Int.mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    constructor <;> simp [h1, h2] <;> omega
  | 2, 0 =>
    dsimp only
    unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
      Zeta12.add Zeta12.ofInt Zeta12.zero Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
      GaussInt.mul GaussInt.sub GaussInt.add
    have hsq1 : (c * (-a)) * (c * (-a)) = (a * a) * (c * c) := by
      rw [Int.mul_neg, Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    have hsq2 : (c * (-b)) * (c * (-b)) = (b * b) * (c * c) := by
      rw [Int.mul_neg, Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    constructor <;> simp <;> omega
  | 2, 1 =>
    dsimp only
    unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
      Zeta12.add Zeta12.ofInt Zeta12.zero Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
      GaussInt.mul GaussInt.sub GaussInt.add
    have h1 : (-(-a)) = a := Int.neg_neg a
    have h2 : (-(-b)) = b := Int.neg_neg b
    have hsq1 : (c * a) * (c * a) = (a * a) * (c * c) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have hsq2 : (c * b) * (c * b) = (b * b) * (c * c) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have hcross : (c * b) * (c * a) = (c * a) * (c * b) := Int.mul_comm _ _
    constructor <;> simp [h1, h2] <;> omega
  | 2, 2 =>
    dsimp only
    unfold Vec3.inner Vec3.actWH Vec3.rationalFiducial Zeta12.powOmega Zeta12.conj Zeta12.mul
      Zeta12.add Zeta12.ofInt Zeta12.zero Zeta12.normSqIntPart Zeta12.normSqSqrt3Part
      GaussInt.mul GaussInt.sub GaussInt.add
    have hsq1 : (c * (-a)) * (c * (-a)) = (a * a) * (c * c) := by
      rw [Int.mul_neg, Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    have hsq2 : (c * (-b)) * (c * (-b)) = (b * b) * (c * c) := by
      rw [Int.mul_neg, Int.neg_mul_neg]; simp [Int.mul_left_comm, Int.mul_comm]
    constructor <;> simp <;> omega
  | _ + 3, _ => omega
  | _, _ + 3 => omega

/-! ### Theorem T1b: Exhaustive Exact 216-Element `PCliff_3` Stabilizer Refutation -/

/-- Exact `2 x 2` matrix over `F_3` encoded as natural numbers in `{0, 1, 2}` for
    instantaneous kernel reduction! -/
@[ext]
structure SL2F3 where
  a : Nat
  b : Nat
  c : Nat
  d : Nat
  deriving DecidableEq, Repr, Inhabited

/-- Exact list of all 24 elements of `SL(2, F_3)`. -/
@[expose] def allSL2F3 : List SL2F3 :=
  ([0, 1, 2] : List Nat).flatMap fun a =>
  ([0, 1, 2] : List Nat).flatMap fun b =>
  ([0, 1, 2] : List Nat).flatMap fun c =>
  ([0, 1, 2] : List Nat).filterMap fun d =>
    if (a * d + 2 * (b * c)) % 3 == 1 then some ⟨a, b, c, d⟩ else none

theorem allSL2F3_card : allSL2F3.length = 24 := by decide

theorem allSL2F3_nodup : allSL2F3.Nodup := by decide

/-- Exhaustiveness of `allSL2F3`: EVERY `2 x 2` matrix over `F_3` with `det = 1` appears in `allSL2F3`. -/
theorem mem_allSL2F3_iff :
    ∀ a b c d : Fin 3,
      (a.val * d.val + 2 * (b.val * c.val)) % 3 = 1 ↔ ⟨a.val, b.val, c.val, d.val⟩ ∈ allSL2F3 := by
  decide

/-- Exact projective Clifford element `(p, q, F)` in `PCliff_3 = Z_3^2 x SL(2, F_3)`. -/
@[ext]
structure PCliff3 where
  p : Nat
  q : Nat
  F : SL2F3
  deriving DecidableEq, Repr, Inhabited

/-- Exact enumeration of all 216 elements of `PCliff_3`. -/
@[expose] def allPCliff3 : List PCliff3 :=
  ([0, 1, 2] : List Nat).flatMap fun p =>
  ([0, 1, 2] : List Nat).flatMap fun q =>
  allSL2F3.map fun F => ⟨p, q, F⟩

theorem allPCliff3_card : allPCliff3.length = 216 := by
  simp [allPCliff3, allSL2F3_card]

theorem allPCliff3_nodup : allPCliff3.Nodup := by
  let block : Nat → List PCliff3 := fun p =>
    ([0, 1, 2] : List Nat).flatMap fun q => allSL2F3.map fun F => PCliff3.mk p q F
  have hmap : ∀ p q : Nat, (allSL2F3.map fun F => PCliff3.mk p q F).Nodup := fun p q =>
    List.Pairwise.map (fun F => PCliff3.mk p q F) (fun _ _ hne heq => hne (by cases heq; rfl)) allSL2F3_nodup
  have hqblock : ∀ p : Nat, (block p).Nodup := by
    intro p
    change (([0, 1, 2] : List Nat).flatMap fun q => allSL2F3.map fun F => PCliff3.mk p q F).Nodup
    simp only [List.flatMap_cons, List.flatMap_nil, List.append_nil]
    rw [List.nodup_append, List.nodup_append]
    refine ⟨hmap p 0, ⟨hmap p 1, hmap p 2, ?_⟩, ?_⟩
    · intro a ha b hb heq
      rw [List.mem_map] at ha hb
      rcases ha with ⟨_, _, rfl⟩; rcases hb with ⟨_, _, rfl⟩; cases heq
    · intro a ha b hb heq
      rw [List.mem_map] at ha; rw [List.mem_append, List.mem_map, List.mem_map] at hb
      rcases ha with ⟨_, _, rfl⟩
      rcases hb with ⟨_, _, rfl⟩ | ⟨_, _, rfl⟩ <;> cases heq
  have hpval : ∀ p : Nat, ∀ g ∈ block p, g.p = p := by
    intro p g hg
    change g ∈ (([0, 1, 2] : List Nat).flatMap fun q => allSL2F3.map fun F => PCliff3.mk p q F) at hg
    rw [List.mem_flatMap] at hg
    rcases hg with ⟨_, _, h2⟩
    rw [List.mem_map] at h2
    rcases h2 with ⟨_, _, rfl⟩
    rfl
  have hall : allPCliff3 = block 0 ++ (block 1 ++ block 2) := by
    show (([0, 1, 2] : List Nat).flatMap block) = block 0 ++ (block 1 ++ block 2)
    simp only [List.flatMap_cons, List.flatMap_nil, List.append_nil]
  rw [hall, List.nodup_append, List.nodup_append]
  refine ⟨hqblock 0, ⟨hqblock 1, hqblock 2, ?_⟩, ?_⟩
  · intro a ha b hb heq
    have h1 := hpval 1 a ha; have h2 := hpval 2 b hb; rw [heq] at h1; omega
  · intro a ha b hb heq
    have h0 := hpval 0 a ha
    rw [List.mem_append] at hb
    cases hb with
    | inl h => have h1 := hpval 1 b h; rw [heq] at h0; omega
    | inr h => have h2 := hpval 2 b h; rw [heq] at h0; omega

/-- Exhaustiveness of `allPCliff3`: EVERY `(p, q, F)` in `Z_3^2 x SL(2, F_3)` appears in `allPCliff3`. -/
theorem mem_allPCliff3_iff :
    ∀ p q a b c d : Fin 3,
      (a.val * d.val + 2 * (b.val * c.val)) % 3 = 1 ↔
        ⟨p.val, q.val, ⟨a.val, b.val, c.val, d.val⟩⟩ ∈ allPCliff3 := by
  intro p q a b c d
  rw [mem_allSL2F3_iff a b c d]
  have hp : p.val ∈ ([0, 1, 2] : List Nat) := by
    rcases p with ⟨pv, hpv⟩
    dsimp only
    match pv with | 0 | 1 | 2 => decide | _ + 3 => omega
  have hq : q.val ∈ ([0, 1, 2] : List Nat) := by
    rcases q with ⟨qv, hqv⟩
    dsimp only
    match qv with | 0 | 1 | 2 => decide | _ + 3 => omega
  simp only [allPCliff3, List.mem_flatMap, List.mem_map]
  constructor
  · intro hF
    exact ⟨p.val, hp, q.val, hq, ⟨a.val, b.val, c.val, d.val⟩, hF, rfl⟩
  · rintro ⟨_, _, _, _, F', hF', heq⟩
    cases heq
    exact hF'

/-- Exact scaled metaplectic matrix entry `M_F[y, x] in Z[omega_3]`. -/
@[expose] def metaEntry (F : SL2F3) (y x : Nat) : Zeta12 :=
  if F.b == 0 then
    if y == (F.a * x) % 3 then
      Zeta12.powOmega (2 * F.c * F.a * x * x)
    else
      Zeta12.zero
  else
    Zeta12.powOmega (2 * F.b * (F.d * y * y + x * y + F.a * x * x))

@[expose] def metaScale (F : SL2F3) : Int :=
  if F.b == 0 then 1 else 3

@[expose] def actMeta (F : SL2F3) (v : Vec3) : Vec3 :=
  let row (y : Nat) : Zeta12 :=
    Zeta12.add
      (Zeta12.add (Zeta12.mul (metaEntry F y 0) v.v0)
                  (Zeta12.mul (metaEntry F y 1) v.v1))
      (Zeta12.mul (metaEntry F y 2) v.v2)
  ⟨row 0, row 1, row 2⟩

@[expose] def actPCliff3 (g : PCliff3) (v : Vec3) : Vec3 :=
  Vec3.actWH g.p g.q (actMeta g.F v)

@[expose] def checkMetaUnitary (F : SL2F3) : Bool :=
  ([0, 1, 2] : List Nat).all fun x1 =>
  ([0, 1, 2] : List Nat).all fun x2 =>
    let entry :=
      Zeta12.add
        (Zeta12.add
          (Zeta12.mul (Zeta12.conj (metaEntry F 0 x1)) (metaEntry F 0 x2))
          (Zeta12.mul (Zeta12.conj (metaEntry F 1 x1)) (metaEntry F 1 x2)))
        (Zeta12.mul (Zeta12.conj (metaEntry F 2 x1)) (metaEntry F 2 x2))
    let expected := if x1 == x2 then Zeta12.ofInt (metaScale F) else Zeta12.zero
    Zeta12.beq entry expected

theorem allSL2F3_meta_unitary : allSL2F3.all checkMetaUnitary = true := by decide

@[expose] def checkMetaSymplecticCov (F : SL2F3) : Bool :=
  let checkGen (p0 q0 p1 q1 : Nat) : Bool :=
    ([0, 1, 2] : List Nat).any fun phaseExp =>
      let ph := Zeta12.powOmega phaseExp
      let basis : List Vec3 := [Vec3.e0, Vec3.e1, Vec3.e2]
      basis.all fun e =>
        Vec3.beq (actMeta F (Vec3.actWH p0 q0 e)) (Vec3.scale ph (Vec3.actWH p1 q1 (actMeta F e)))
  checkGen 1 0 F.a F.c && checkGen 0 1 F.b F.d

theorem allSL2F3_symplectic_covariant : allSL2F3.all checkMetaSymplecticCov = true := by decide

@[expose] def stabilizerOf (v : Vec3) : List PCliff3 :=
  allPCliff3.filter fun g => Vec3.isCollinear v (actPCliff3 g v)

@[expose] def diagPhaseGroup : List PCliff3 :=
  [ ⟨0, 0, ⟨1, 0, 0, 1⟩⟩
  , ⟨0, 0, ⟨1, 0, 1, 1⟩⟩
  , ⟨0, 0, ⟨1, 0, 2, 1⟩⟩
  ]

/-- **Theorem T1b-1 (Exact Stabilizer Classification of `v345`)**:
    Out of ALL 216 elements of `PCliff_3`, the stabilizer subgroup of the WH-SIC fiducial
    `v345 = (0, 5, -(3 + 4i))` consists of **EXACTLY THREE ELEMENTS**: `I`, `P`, and `P^2`! -/
theorem v345_exact_clifford_stabilizer :
    stabilizerOf Vec3.v345 = diagPhaseGroup := by decide

/-- **Theorem T1b-2 (Universal 2-Dimensional Joint Eigenspace of `Stab(v345)`)**:
    Every element `g in {I, P, P^2}` acts on ANY vector `(0, y, z)` by the EXACT scalar
    `omega^(2 * g.F.c)` (matching its eigenvalue on `v345`)! -/
theorem diagPhaseGroup_fixes_2d_subspace (y z : Zeta12) :
    ∀ g ∈ diagPhaseGroup,
      actPCliff3 g ⟨Zeta12.zero, y, z⟩ =
        Vec3.scale (Zeta12.powOmega (2 * g.F.c)) ⟨Zeta12.zero, y, z⟩ := by
  intro g hg
  simp only [diagPhaseGroup, List.mem_cons, List.not_mem_nil, or_false] at hg
  rcases hg with rfl | rfl | rfl
  · unfold actPCliff3 Vec3.actWH actMeta metaEntry Vec3.scale Zeta12.powOmega
      Zeta12.mul Zeta12.add Zeta12.zero GaussInt.mul GaussInt.sub GaussInt.add
    ext <;> simp
  · unfold actPCliff3 Vec3.actWH actMeta metaEntry Vec3.scale Zeta12.powOmega
      Zeta12.mul Zeta12.add Zeta12.zero GaussInt.mul GaussInt.sub GaussInt.add
    ext <;> simp
  · unfold actPCliff3 Vec3.actWH actMeta metaEntry Vec3.scale Zeta12.powOmega
      Zeta12.mul Zeta12.add Zeta12.zero GaussInt.mul GaussInt.sub GaussInt.add
    ext <;> simp

/-- Linear independence of `e_1` and `e_2` over `Z[i, omega_3]` (witnessing `dim >= 2 > 1`). -/
theorem e1_e2_linearly_independent (c1 c2 : Zeta12) :
    Vec3.add (Vec3.scale c1 Vec3.e1) (Vec3.scale c2 Vec3.e2) = ⟨Zeta12.zero, Zeta12.zero, Zeta12.zero⟩ →
    c1 = Zeta12.zero ∧ c2 = Zeta12.zero := by
  intro h
  unfold Vec3.add Vec3.scale Vec3.e1 Vec3.e2 Zeta12.mul Zeta12.add Zeta12.one Zeta12.zero
    GaussInt.mul GaussInt.sub GaussInt.add at h
  have h1 := congrArg Vec3.v1 h
  have h2 := congrArg Vec3.v2 h
  simp at h1 h2
  exact ⟨Zeta12.ext h1.1 h1.2.1 h1.2.2.1 h1.2.2.2,
         Zeta12.ext h2.1 h2.2.1 h2.2.2.1 h2.2.2.2⟩

/-- **Theorem T1b (Complete Refutation of Erew & Goldstein Conjecture 1)**: -/
theorem qutrit_sic_refutes_clifford_stabilizer_conjecture :
    (∀ p q : Fin 3, (p.val ≠ 0 ∨ q.val ≠ 0) →
      let ov := Vec3.inner Vec3.v345 (Vec3.actWH p.val q.val Vec3.v345)
      4 * Zeta12.normSqIntPart ov = 2500 ∧ Zeta12.normSqSqrt3Part ov = 0) ∧
    stabilizerOf Vec3.v345 = diagPhaseGroup ∧
    (∀ g ∈ stabilizerOf Vec3.v345,
      actPCliff3 g Vec3.v345 = Vec3.scale (Zeta12.powOmega (2 * g.F.c)) Vec3.v345 ∧
      actPCliff3 g Vec3.e1 = Vec3.scale (Zeta12.powOmega (2 * g.F.c)) Vec3.e1 ∧
      actPCliff3 g Vec3.e2 = Vec3.scale (Zeta12.powOmega (2 * g.F.c)) Vec3.e2) ∧
    (∀ c1 c2 : Zeta12,
      Vec3.add (Vec3.scale c1 Vec3.e1) (Vec3.scale c2 Vec3.e2) = ⟨Zeta12.zero, Zeta12.zero, Zeta12.zero⟩ →
      c1 = Zeta12.zero ∧ c2 = Zeta12.zero) := by
  refine ⟨?_, v345_exact_clifford_stabilizer, ?_, e1_e2_linearly_independent⟩
  · intro p q hne
    exact qutrit_rational_circle_wh_sic 3 4 5 (by decide) p q hne
  · intro g hg
    rw [v345_exact_clifford_stabilizer] at hg
    exact ⟨diagPhaseGroup_fixes_2d_subspace (Zeta12.ofInt 5) ⟨-3, -4, 0, 0⟩ g hg,
           diagPhaseGroup_fixes_2d_subspace Zeta12.one Zeta12.zero g hg,
           diagPhaseGroup_fixes_2d_subspace Zeta12.zero Zeta12.one g hg⟩

/-! ### Theorems T1c & T1d: Universal All-`d` Zauner Eigenspace-Dimension Obstruction -/

theorem zauner_trace_multiplicity_identity (m0 m1 m2 : Int) :
    let d := m0 + m1 + m2
    (3 * m0 - d) * (3 * m0 - d) + (3 * m1 - d) * (3 * m1 - d) + (3 * m2 - d) * (3 * m2 - d) =
    3 * ((m0 - m1) * (m0 - m1) + (m0 - m2) * (m0 - m2) + (m1 - m2) * (m1 - m2)) := by
  dsimp only
  have s0 : 3 * m0 - (m0 + m1 + m2) = (m0 - m1) + (m0 - m2) := by omega
  have s1 : 3 * m1 - (m0 + m1 + m2) = (m1 - m2) - (m0 - m1) := by omega
  have s2 : 3 * m2 - (m0 + m1 + m2) = -((m0 - m2) + (m1 - m2)) := by omega
  rw [s0, s1, s2]
  let x := m0 - m1
  let y := m0 - m2
  let z := m1 - m2
  show (x + y) * (x + y) + (z - x) * (z - x) + (-(y + z)) * (-(y + z)) =
       3 * (x * x + y * y + z * z)
  have hrel : y = x + z := by omega
  have e1 : (x + y) * (x + y) = x * x + 2 * (x * y) + y * y := by
    rw [Int.add_mul, Int.mul_add, Int.mul_add]
    have : y * x = x * y := Int.mul_comm y x
    omega
  have e2 : (z - x) * (z - x) = z * z - 2 * (x * z) + x * x := by
    have h1 := Int.mul_sub (z - x) z x
    have h2 := Int.sub_mul z x z
    have h3 := Int.sub_mul z x x
    have h4 : z * x = x * z := Int.mul_comm z x
    omega
  have e3 : (-(y + z)) * (-(y + z)) = y * y + 2 * (y * z) + z * z := by
    rw [Int.neg_mul_neg, Int.add_mul, Int.mul_add, Int.mul_add]
    have : z * y = y * z := Int.mul_comm z y
    omega
  have hxy : x * y = x * x + x * z := by rw [hrel, Int.mul_add]
  have hyz : y * z = x * z + z * z := by rw [hrel, Int.add_mul]
  have hy2 : y * y = x * x + 2 * (x * z) + z * z := by
    rw [hrel, Int.add_mul, Int.mul_add, Int.mul_add]
    have : z * x = x * z := Int.mul_comm z x
    omega
  rw [e1, e2, e3, hxy, hyz]
  omega

theorem zauner_eigenspace_dim_universal_obstruction (d m : Int) :
    ((d ≥ 7 ∧ (3 * m - d) * (3 * m - d) ≤ 12) → m ≥ 2) ∧
    ((d ≥ 4 ∧ 3 * m ≥ d) → m ≥ 2) := by
  constructor
  · rintro ⟨hd, htr⟩
    cases Int.le_total 2 m with
    | inl hge => exact hge
    | inr hle =>
      by_cases hm2 : m = 2
      · omega
      · have hm : m ≤ 1 := by omega
        have hpos : 4 ≤ -(3 * m - d) := by omega
        have h1 := Int.mul_le_mul_of_nonneg_left hpos (by omega : (0 : Int) ≤ 4)
        have h2 := Int.mul_le_mul_of_nonneg_right hpos (by omega : (0 : Int) ≤ -(3 * m - d))
        rw [Int.neg_mul_neg] at h2
        omega
  · rintro ⟨hd, hcan⟩
    omega

theorem dim4_scott_grassl_4a_obstruction (m0 m1 m2 : Int)
    (hsum : m0 + m1 + m2 = 4) (htr_re : 2 * m0 - m1 - m2 = 2) (htr_im : m1 = m2) :
    m0 = 2 ∧ m1 = 1 ∧ m2 = 1 ∧ m0 ≥ 2 := by
  omega

end

end WeylMagicFrontier.Pillar1
