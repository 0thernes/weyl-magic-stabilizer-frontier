-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

/-!
# Exact Cyclotomic Rings and Finite-Field Arithmetic (Zero-Mathlib)

Self-contained exact algebraic rings over `Int` used across all four pillars of
`WeylMagicFrontier`:
1. `GaussInt`: Gaussian integers `Z[i]`, with exact conjugation and norm squared.
2. `Zeta12`: The 12th cyclotomic ring `Z[i, omega_3]` (`i^2 = -1`, `omega^2 + omega + 1 = 0`),
   used for exact qutrit Weyl-Heisenberg operators, `PCliff_3` (216 elements), and the
   exact Gaussian-rational WH-SIC fiducial `(0, 5, -(3+4i))`.
3. `Zeta5`: The 5th cyclotomic ring `Z[zeta_5]` (`zeta^4 + zeta^3 + zeta^2 + zeta + 1 = 0`),
   used for exact ququint Alltop saddle verification and discrete Wigner checks.
4. `FinSum`: Elementary finite-sum lemmas (`sumFin`) over `Fin n` with exact reindexing
   and Cauchy-Schwarz, avoiding any Mathlib dependency.
-/

namespace WeylMagicFrontier

public section

/-- Gaussian integer `re + im * i`. -/
@[ext]
structure GaussInt where
  re : Int
  im : Int
  deriving DecidableEq, Repr, Inhabited

namespace GaussInt

@[expose] def zero : GaussInt := ⟨0, 0⟩
@[expose] def one : GaussInt := ⟨1, 0⟩
@[expose] def I : GaussInt := ⟨0, 1⟩
@[expose] def ofInt (n : Int) : GaussInt := ⟨n, 0⟩

@[expose] def add (x y : GaussInt) : GaussInt := ⟨x.re + y.re, x.im + y.im⟩
@[expose] def sub (x y : GaussInt) : GaussInt := ⟨x.re - y.re, x.im - y.im⟩
@[expose] def neg (x : GaussInt) : GaussInt := ⟨-x.re, -x.im⟩
@[expose] def mul (x y : GaussInt) : GaussInt :=
  ⟨x.re * y.re - x.im * y.im, x.re * y.im + x.im * y.re⟩
@[expose] def conj (x : GaussInt) : GaussInt := ⟨x.re, -x.im⟩
@[expose] def normSq (x : GaussInt) : Int := x.re * x.re + x.im * x.im
@[expose] def beq (x y : GaussInt) : Bool := (x.re == y.re) && (x.im == y.im)

instance : Add GaussInt := ⟨add⟩
instance : Sub GaussInt := ⟨sub⟩
instance : Neg GaussInt := ⟨neg⟩
instance : Mul GaussInt := ⟨mul⟩
instance : OfNat GaussInt 0 := ⟨zero⟩
instance : OfNat GaussInt 1 := ⟨one⟩

theorem int_mul_self_nonneg (a : Int) : 0 ≤ a * a := by
  cases Int.le_total 0 a with
  | inl h => exact Int.mul_nonneg h h
  | inr h =>
    have hneg : 0 ≤ -a := by omega
    have hmul : 0 ≤ (-a) * (-a) := Int.mul_nonneg hneg hneg
    rw [Int.neg_mul_neg] at hmul
    exact hmul

theorem normSq_nonneg (x : GaussInt) : 0 ≤ x.normSq := by
  unfold normSq
  have h1 : 0 ≤ x.re * x.re := int_mul_self_nonneg x.re
  have h2 : 0 ≤ x.im * x.im := int_mul_self_nonneg x.im
  omega

theorem mul_conj (x : GaussInt) : x * x.conj = ofInt x.normSq := by
  show GaussInt.mul x x.conj = ofInt x.normSq
  unfold mul conj ofInt normSq
  ext <;> simp
  · rw [Int.mul_neg]; omega
  · rw [Int.mul_neg, Int.mul_comm x.im x.re]; omega

theorem normSq_mul (x y : GaussInt) : (x * y).normSq = x.normSq * y.normSq := by
  show (GaussInt.mul x y).normSq = x.normSq * y.normSq
  unfold mul normSq
  have h : (x.re * y.re - x.im * y.im) * (x.re * y.re - x.im * y.im) +
           (x.re * y.im + x.im * y.re) * (x.re * y.im + x.im * y.re) =
           (x.re * x.re + x.im * x.im) * (y.re * y.re + y.im * y.im) := by
    have e1 := Int.mul_sub (x.re * y.re - x.im * y.im) (x.re * y.re) (x.im * y.im)
    have e2 := Int.sub_mul (x.re * y.re) (x.im * y.im) (x.re * y.re)
    have e3 := Int.sub_mul (x.re * y.re) (x.im * y.im) (x.im * y.im)
    have e4 := Int.mul_add (x.re * y.im + x.im * y.re) (x.re * y.im) (x.im * y.re)
    have e5 := Int.add_mul (x.re * y.im) (x.im * y.re) (x.re * y.im)
    have e6 := Int.add_mul (x.re * y.im) (x.im * y.re) (x.im * y.re)
    have e7 := Int.add_mul (x.re * x.re) (x.im * x.im) (y.re * y.re + y.im * y.im)
    have e8 := Int.mul_add (x.re * x.re) (y.re * y.re) (y.im * y.im)
    have e9 := Int.mul_add (x.im * x.im) (y.re * y.re) (y.im * y.im)
    have c1 : (x.re * y.re) * (x.re * y.re) = (x.re * x.re) * (y.re * y.re) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have c2 : (x.im * y.im) * (x.im * y.im) = (x.im * x.im) * (y.im * y.im) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have c3 : (x.re * y.im) * (x.re * y.im) = (x.re * x.re) * (y.im * y.im) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have c4 : (x.im * y.re) * (x.im * y.re) = (x.im * x.im) * (y.re * y.re) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have c5 : (x.re * y.re) * (x.im * y.im) = (x.re * y.im) * (x.im * y.re) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have c6 : (x.im * y.im) * (x.re * y.re) = (x.re * y.im) * (x.im * y.re) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    have c7 : (x.im * y.re) * (x.re * y.im) = (x.re * y.im) * (x.im * y.re) := by
      simp [Int.mul_left_comm, Int.mul_comm]
    omega
  exact h

/-- Power of `i`: `i^(k mod 4)`. -/
@[expose] def powI (k : Nat) : GaussInt :=
  match k % 4 with
  | 0 => ⟨1, 0⟩
  | 1 => ⟨0, 1⟩
  | 2 => ⟨-1, 0⟩
  | _ => ⟨0, -1⟩

end GaussInt

/-- Exact ring `Z[i, omega_3] = Z[zeta_12]` in the integral basis `{1, i, omega, i*omega}`,
    where `i^2 = -1` and `omega^2 = -1 - omega`. -/
@[ext]
structure Zeta12 where
  a : Int  -- coeff of 1
  b : Int  -- coeff of i
  c : Int  -- coeff of omega
  d : Int  -- coeff of i * omega
  deriving DecidableEq, Repr, Inhabited

namespace Zeta12

@[expose] def zero : Zeta12 := ⟨0, 0, 0, 0⟩
@[expose] def one : Zeta12 := ⟨1, 0, 0, 0⟩
@[expose] def I : Zeta12 := ⟨0, 1, 0, 0⟩
@[expose] def omega : Zeta12 := ⟨0, 0, 1, 0⟩
@[expose] def ofInt (n : Int) : Zeta12 := ⟨n, 0, 0, 0⟩
@[expose] def ofGauss (z : GaussInt) : Zeta12 := ⟨z.re, z.im, 0, 0⟩

@[expose] def beq (x y : Zeta12) : Bool :=
  (x.a == y.a) && (x.b == y.b) && (x.c == y.c) && (x.d == y.d)

@[expose] def add (x y : Zeta12) : Zeta12 :=
  ⟨x.a + y.a, x.b + y.b, x.c + y.c, x.d + y.d⟩

@[expose] def sub (x y : Zeta12) : Zeta12 :=
  ⟨x.a - y.a, x.b - y.b, x.c - y.c, x.d - y.d⟩

@[expose] def neg (x : Zeta12) : Zeta12 :=
  ⟨-x.a, -x.b, -x.c, -x.d⟩

@[expose] def scaleInt (k : Int) (x : Zeta12) : Zeta12 :=
  ⟨k * x.a, k * x.b, k * x.c, k * x.d⟩

@[expose] def mul (x y : Zeta12) : Zeta12 :=
  let x0 : GaussInt := ⟨x.a, x.b⟩
  let x1 : GaussInt := ⟨x.c, x.d⟩
  let y0 : GaussInt := ⟨y.a, y.b⟩
  let y1 : GaussInt := ⟨y.c, y.d⟩
  let p00 := GaussInt.mul x0 y0
  let p11 := GaussInt.mul x1 y1
  let p01 := GaussInt.mul x0 y1
  let p10 := GaussInt.mul x1 y0
  let r0 := GaussInt.sub p00 p11
  let r1 := GaussInt.sub (GaussInt.add p01 p10) p11
  ⟨r0.re, r0.im, r1.re, r1.im⟩

@[expose] def conj (x : Zeta12) : Zeta12 :=
  ⟨x.a - x.c, -x.b + x.d, -x.c, x.d⟩

instance : Add Zeta12 := ⟨add⟩
instance : Sub Zeta12 := ⟨sub⟩
instance : Neg Zeta12 := ⟨neg⟩
instance : Mul Zeta12 := ⟨mul⟩
instance : OfNat Zeta12 0 := ⟨zero⟩
instance : OfNat Zeta12 1 := ⟨one⟩

@[expose] def powOmega (k : Nat) : Zeta12 :=
  match k % 3 with
  | 0 => ⟨1, 0, 0, 0⟩
  | 1 => ⟨0, 0, 1, 0⟩
  | _ => ⟨-1, 0, -1, 0⟩

@[expose] def normSqIntPart (x : Zeta12) : Int :=
  x.a * x.a - x.a * x.c + x.c * x.c + x.b * x.b - x.b * x.d + x.d * x.d

@[expose] def normSqSqrt3Part (x : Zeta12) : Int :=
  x.b * x.c - x.a * x.d

@[expose] def sqrt3Elem : Zeta12 := ⟨0, -1, 0, -2⟩

theorem sqrt3Elem_sq : mul sqrt3Elem sqrt3Elem = ofInt 3 := by
  decide

theorem mul_conj_eq (x : Zeta12) :
    mul x (conj x) = add (ofInt (normSqIntPart x)) (scaleInt (normSqSqrt3Part x) sqrt3Elem) := by
  unfold mul conj ofInt add scaleInt sqrt3Elem normSqIntPart normSqSqrt3Part
  unfold GaussInt.mul GaussInt.sub GaussInt.add
  ext <;> simp
  · have h1 := Int.mul_sub x.a x.a x.c
    have h2 := Int.mul_add x.b (-x.b) x.d
    have h3 : x.c * (-x.c) = -(x.c * x.c) := Int.mul_neg x.c x.c
    have h4 : x.b * (-x.b) = -(x.b * x.b) := Int.mul_neg x.b x.b
    have h5 : x.a * x.c = x.c * x.a := Int.mul_comm x.a x.c
    have h6 : x.b * x.d = x.d * x.b := Int.mul_comm x.b x.d
    omega
  · have h1 := Int.mul_add x.a (-x.b) x.d
    have h2 := Int.mul_sub x.b x.a x.c
    have h3 : x.c * x.d = x.d * x.c := Int.mul_comm x.c x.d
    have h4 : x.d * (-x.c) = -(x.c * x.d) := by rw [Int.mul_neg, Int.mul_comm]
    have h5 : x.a * (-x.b) = -(x.a * x.b) := Int.mul_neg x.a x.b
    have h6 : x.b * x.a = x.a * x.b := Int.mul_comm x.b x.a
    have h7 : (x.b * x.c - x.a * x.d) * (-1) = -(x.b * x.c - x.a * x.d) := by
      rw [Int.mul_neg, Int.mul_one]
    omega
  · have h1 : x.a * (-x.c) = -(x.a * x.c) := Int.mul_neg x.a x.c
    have h2 := Int.mul_sub x.c x.a x.c
    have h3 : (-x.c) * (-x.c) = x.c * x.c := Int.neg_mul_neg x.c x.c
    have h3b : x.c * (-x.c) = -(x.c * x.c) := Int.mul_neg x.c x.c
    have h4 : x.d * (-x.b + x.d) = -(x.b * x.d) + x.d * x.d := by
      rw [Int.mul_add, Int.mul_neg, Int.mul_comm x.d x.b]
    have h5 : x.b * x.d = x.d * x.b := Int.mul_comm x.b x.d
    have h6 : x.c * x.a = x.a * x.c := Int.mul_comm x.c x.a
    omega
  · have h1 : x.b * (-x.c) = -(x.b * x.c) := Int.mul_neg x.b x.c
    have h2 := Int.mul_add x.c (-x.b) x.d
    have h3 : x.c * (-x.b) = -(x.b * x.c) := by rw [Int.mul_neg, Int.mul_comm]
    have h4 := Int.mul_sub x.d x.a x.c
    have h5 : x.d * (-x.c) = -(x.c * x.d) := by rw [Int.mul_neg, Int.mul_comm]
    have h6 : x.d * x.a = x.a * x.d := Int.mul_comm x.d x.a
    have h7 : x.d * x.c = x.c * x.d := Int.mul_comm x.d x.c
    have h8 : (x.b * x.c - x.a * x.d) * (-2) = -2 * (x.b * x.c - x.a * x.d) := by
      rw [Int.mul_comm]
    have h9 : -2 * (x.b * x.c - x.a * x.d) = -2 * (x.b * x.c) + 2 * (x.a * x.d) := by
      rw [Int.mul_sub]
      omega
    omega

end Zeta12

/-- Exact cyclotomic ring `Z[zeta_5]` in integral basis `{1, z, z^2, z^3}` where
    `z^4 = -1 - z - z^2 - z^3` and `conj(z^k) = z^(5-k)`. -/
@[ext]
structure Zeta5 where
  c0 : Int
  c1 : Int
  c2 : Int
  c3 : Int
  deriving DecidableEq, Repr, Inhabited

namespace Zeta5

@[expose] def zero : Zeta5 := ⟨0, 0, 0, 0⟩
@[expose] def one : Zeta5 := ⟨1, 0, 0, 0⟩
@[expose] def ofInt (n : Int) : Zeta5 := ⟨n, 0, 0, 0⟩

@[expose] def beq (x y : Zeta5) : Bool :=
  (x.c0 == y.c0) && (x.c1 == y.c1) && (x.c2 == y.c2) && (x.c3 == y.c3)

@[expose] def add (x y : Zeta5) : Zeta5 :=
  ⟨x.c0 + y.c0, x.c1 + y.c1, x.c2 + y.c2, x.c3 + y.c3⟩

@[expose] def sub (x y : Zeta5) : Zeta5 :=
  ⟨x.c0 - y.c0, x.c1 - y.c1, x.c2 - y.c2, x.c3 - y.c3⟩

@[expose] def neg (x : Zeta5) : Zeta5 :=
  ⟨-x.c0, -x.c1, -x.c2, -x.c3⟩

@[expose] def scaleInt (k : Int) (x : Zeta5) : Zeta5 :=
  ⟨k * x.c0, k * x.c1, k * x.c2, k * x.c3⟩

@[expose] def powZeta (k : Nat) : Zeta5 :=
  match k % 5 with
  | 0 => ⟨1, 0, 0, 0⟩
  | 1 => ⟨0, 1, 0, 0⟩
  | 2 => ⟨0, 0, 1, 0⟩
  | 3 => ⟨0, 0, 0, 1⟩
  | _ => ⟨-1, -1, -1, -1⟩

@[expose] def mul (x y : Zeta5) : Zeta5 :=
  let p0 := x.c0 * y.c0
  let p1 := x.c0 * y.c1 + x.c1 * y.c0
  let p2 := x.c0 * y.c2 + x.c1 * y.c1 + x.c2 * y.c0
  let p3 := x.c0 * y.c3 + x.c1 * y.c2 + x.c2 * y.c1 + x.c3 * y.c0
  let p4 := x.c1 * y.c3 + x.c2 * y.c2 + x.c3 * y.c1
  let p5 := x.c2 * y.c3 + x.c3 * y.c2
  let p6 := x.c3 * y.c3
  ⟨p0 - p4 + p5, p1 - p4 + p6, p2 - p4, p3 - p4⟩

@[expose] def conj (x : Zeta5) : Zeta5 :=
  ⟨x.c0 - x.c1, -x.c1, x.c3 - x.c1, x.c2 - x.c1⟩

@[expose] def realTwiceInt (x : Zeta5) : Int := 2 * x.c0 - x.c2
@[expose] def realTwiceSqrt5 (x : Zeta5) : Int := -x.c2
@[expose] def absSq (x : Zeta5) : Zeta5 := mul x (conj x)

@[expose] def zSqrt5LtZero (u v : Int) : Bool :=
  if u < 0 then
    if v ≤ 0 then true else 5 * v * v < u * u
  else
    if v < 0 then u * u < 5 * v * v else false

theorem zSqrt5LtZero_sound (u v : Int) (h : zSqrt5LtZero u v = true) :
    (u < 0 ∧ v ≤ 0) ∨ (u < 0 ∧ 0 < v ∧ 5 * v * v < u * u) ∨ (0 ≤ u ∧ v < 0 ∧ u * u < 5 * v * v) := by
  unfold zSqrt5LtZero at h
  by_cases hu : u < 0
  · simp [hu] at h
    by_cases hv : v ≤ 0
    · simp [hv] at h; exact Or.inl ⟨hu, hv⟩
    · simp [hv] at h; exact Or.inr (Or.inl ⟨hu, by omega, h⟩)
  · simp [hu] at h
    by_cases hv : v < 0
    · simp [hv] at h; exact Or.inr (Or.inr ⟨by omega, hv, h⟩)
    · simp [hv] at h

end Zeta5

/-- Finite integer summation over `Fin n`. -/
@[expose] def sumFin : {n : Nat} → (Fin n → Int) → Int
  | 0, _ => 0
  | _ + 1, f => f ⟨0, Nat.zero_lt_succ _⟩ + sumFin (fun i => f i.succ)

theorem sumFin_zero {n : Nat} : sumFin (fun (_ : Fin n) => (0 : Int)) = 0 := by
  induction n with
  | zero => rfl
  | succ k ih => simp [sumFin, ih]

theorem sumFin_add {n : Nat} (f g : Fin n → Int) :
    sumFin (fun i => f i + g i) = sumFin f + sumFin g := by
  induction n with
  | zero => simp [sumFin]
  | succ k ih =>
    simp [sumFin, ih]
    omega

theorem sumFin_const {n : Nat} (c : Int) :
    sumFin (fun (_ : Fin n) => c) = (n : Int) * c := by
  induction n with
  | zero => simp [sumFin]
  | succ k ih =>
    simp only [sumFin, ih]
    have hm : ((k + 1 : Nat) : Int) = (k : Int) + 1 := by omega
    rw [hm, Int.add_mul, Int.one_mul]
    omega

theorem sumFin_mul_left {n : Nat} (c : Int) (f : Fin n → Int) :
    sumFin (fun i => c * f i) = c * sumFin f := by
  induction n with
  | zero => simp [sumFin]
  | succ k ih =>
    simp [sumFin, ih, Int.mul_add]

theorem sumFin_nonneg {n : Nat} (f : Fin n → Int) (h : ∀ i, 0 ≤ f i) :
    0 ≤ sumFin f := by
  induction n with
  | zero => simp [sumFin]
  | succ k ih =>
    simp only [sumFin]
    have h0 := h ⟨0, Nat.zero_lt_succ k⟩
    have h1 := ih (fun i => f i.succ) (fun i => h i.succ)
    omega

theorem sumFin_le {n : Nat} (f g : Fin n → Int) (h : ∀ i, f i ≤ g i) :
    sumFin f ≤ sumFin g := by
  induction n with
  | zero => simp [sumFin]
  | succ k ih =>
    simp only [sumFin]
    have h0 := h ⟨0, Nat.zero_lt_succ k⟩
    have h1 := ih (fun i => f i.succ) (fun i => g i.succ) (fun i => h i.succ)
    omega

theorem sumFin_eq_of_eq {n : Nat} (f g : Fin n → Int) (h : ∀ i, f i = g i) :
    sumFin f = sumFin g := by
  induction n with
  | zero => rfl
  | succ k ih =>
    simp only [sumFin]
    rw [h ⟨0, Nat.zero_lt_succ k⟩, ih (fun i => f i.succ) (fun i => g i.succ) (fun i => h i.succ)]

/-- Exact splitting of `sumFin` at any single index `k : Fin n`. -/
theorem sumFin_split_at {n : Nat} (k : Fin n) (f : Fin n → Int) :
    sumFin f = f k + sumFin (fun i : Fin n => if i = k then 0 else f i) := by
  induction n with
  | zero => exact Fin.elim0 k
  | succ m ih =>
    cases k using Fin.cases with
    | zero =>
      simp only [sumFin]
      have h0 : (⟨0, Nat.zero_lt_succ m⟩ : Fin (m + 1)) = (0 : Fin (m + 1)) := rfl
      rw [h0]
      simp only [ite_true]
      have htail : sumFin (fun i : Fin m => if i.succ = (0 : Fin (m + 1)) then (0 : Int) else f i.succ) =
          sumFin (fun i : Fin m => f i.succ) := by
        apply sumFin_eq_of_eq
        intro i
        have hne : i.succ ≠ (0 : Fin (m + 1)) := Fin.succ_ne_zero i
        simp [hne]
      rw [htail]
      omega
    | succ j =>
      simp only [sumFin]
      have h0 : (⟨0, Nat.zero_lt_succ m⟩ : Fin (m + 1)) ≠ j.succ := (Fin.succ_ne_zero j).symm
      simp only [h0, ite_false]
      have htail : sumFin (fun i : Fin m => if i.succ = j.succ then (0 : Int) else f i.succ) =
          sumFin (fun i : Fin m => if i = j then (0 : Int) else f i.succ) := by
        apply sumFin_eq_of_eq
        intro i
        by_cases hij : i = j
        · subst hij; simp
        · have hne : i.succ ≠ j.succ := fun h => hij (Fin.succ_inj.mp h)
          simp [hij, hne]
      rw [htail]
      have hrec := ih j (fun i => f i.succ)
      omega

/-- Exact integer Cauchy-Schwarz inequality over `Fin n`:
    `(sum_i f i)^2 <= n * sum_i (f i)^2`, proved purely in `Int` via double sum of squares! -/
theorem sumFin_cauchy_schwarz {n : Nat} (f : Fin n → Int) :
    (sumFin f) * (sumFin f) ≤ (n : Int) * sumFin (fun i => f i * f i) := by
  induction n with
  | zero => simp [sumFin]
  | succ m ih =>
    simp only [sumFin]
    let a : Int := f ⟨0, Nat.zero_lt_succ m⟩
    let tail : Fin m → Int := fun i => f i.succ
    show (a + sumFin tail) * (a + sumFin tail) ≤
      ((m + 1 : Nat) : Int) * (a * a + sumFin (fun i => tail i * tail i))
    have hih := ih tail
    have hsq : 0 ≤ sumFin (fun i : Fin m => (a - tail i) * (a - tail i)) :=
      sumFin_nonneg _ (fun i => GaussInt.int_mul_self_nonneg _)
    have hexp : sumFin (fun i : Fin m => (a - tail i) * (a - tail i)) =
        (m : Int) * (a * a) - 2 * a * sumFin tail + sumFin (fun i => tail i * tail i) := by
      have step : ∀ i : Fin m, (a - tail i) * (a - tail i) =
          a * a + ((-2 * a) * tail i + tail i * tail i) := by
        intro i
        have e1 := Int.mul_sub (a - tail i) a (tail i)
        have e2 := Int.sub_mul a (tail i) a
        have e3 := Int.sub_mul a (tail i) (tail i)
        have e4 : tail i * a = a * tail i := Int.mul_comm _ _
        have e5 : (-2 * a) * tail i = -(2 * (a * tail i)) := by
          rw [Int.neg_mul, Int.neg_mul, Int.mul_assoc]
        omega
      rw [sumFin_eq_of_eq _ _ step]
      rw [sumFin_add, sumFin_add, sumFin_const, sumFin_mul_left]
      have hmul2 : (-2 * a) * sumFin tail = -(2 * (a * sumFin tail)) := by
        rw [Int.neg_mul, Int.neg_mul, Int.mul_assoc]
      have hmul2' : 2 * a * sumFin tail = 2 * (a * sumFin tail) := Int.mul_assoc 2 a (sumFin tail)
      omega
    have h_m1 : ((m + 1 : Nat) : Int) * (a * a + sumFin (fun i => tail i * tail i)) =
        (m : Int) * (a * a) + (m : Int) * sumFin (fun i => tail i * tail i) +
        a * a + sumFin (fun i => tail i * tail i) := by
      have hm : ((m + 1 : Nat) : Int) = (m : Int) + 1 := by omega
      rw [hm, Int.add_mul, Int.one_mul, Int.mul_add]
      omega
    have h_lhs : (a + sumFin tail) * (a + sumFin tail) =
        a * a + 2 * a * sumFin tail + sumFin tail * sumFin tail := by
      rw [Int.add_mul, Int.mul_add, Int.mul_add]
      have : sumFin tail * a = a * sumFin tail := Int.mul_comm _ _
      have h2a : 2 * a * sumFin tail = 2 * (a * sumFin tail) := Int.mul_assoc 2 a (sumFin tail)
      omega
    omega

end

end WeylMagicFrontier
