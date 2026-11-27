-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

public import WeylMagicFrontier.Cyclotomic
public import WeylMagicFrontier.Pillar1_SICRefutation
public import WeylMagicFrontier.Pillar2_ManaLock
public import WeylMagicFrontier.Pillar3_AlltopMagic
public import WeylMagicFrontier.Pillar4_SingerCodes

/-!
# Statement-Only Challenge Contract (`Challenge.lean`)

Exports the exact `Prop` statements for all 14 headline theorems (`T1a`–`T4c`) plus the
grand conjunction (`AllFrontierTheoremsStmt`), independently matched by `PalomarChallenge.lean`
and `PalomarSolution.lean` under `lake comparator --config comparator.json --paranoid`.
-/

namespace WeylMagicFrontier.Challenge

public section

open WeylMagicFrontier.Pillar1
open WeylMagicFrontier.Pillar2
open WeylMagicFrontier.Pillar3
open WeylMagicFrontier.Pillar4

abbrev T1aStmt : Prop :=
  ∀ a b c : Int, a * a + b * b = c * c →
    ∀ p q : Fin 3, (p.val ≠ 0 ∨ q.val ≠ 0) →
      let ov := Vec3.inner (Vec3.rationalFiducial a b c) (Vec3.actWH p.val q.val (Vec3.rationalFiducial a b c))
      4 * Zeta12.normSqIntPart ov = (2 * (c * c)) * (2 * (c * c)) ∧
      Zeta12.normSqSqrt3Part ov = 0

abbrev T1bStmt : Prop :=
  allSL2F3.length = 24 ∧
  allPCliff3.length = 216 ∧
  allSL2F3.all checkMetaUnitary = true ∧
  allSL2F3.all checkMetaSymplecticCov = true ∧
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
    c1 = Zeta12.zero ∧ c2 = Zeta12.zero)

abbrev T1cStmt : Prop :=
  (∀ m0 m1 m2 : Int,
    let d := m0 + m1 + m2
    (3 * m0 - d) * (3 * m0 - d) + (3 * m1 - d) * (3 * m1 - d) + (3 * m2 - d) * (3 * m2 - d) =
    3 * ((m0 - m1) * (m0 - m1) + (m0 - m2) * (m0 - m2) + (m1 - m2) * (m1 - m2))) ∧
  (∀ d m : Int,
    ((d ≥ 7 ∧ (3 * m - d) * (3 * m - d) ≤ 12) → m ≥ 2) ∧
    ((d ≥ 4 ∧ 3 * m ≥ d) → m ≥ 2))

abbrev T1dStmt : Prop :=
  ∀ m0 m1 m2 : Int,
    m0 + m1 + m2 = 4 → 2 * m0 - m1 - m2 = 2 → m1 = m2 →
    m0 = 2 ∧ m1 = 1 ∧ m2 = 1 ∧ m0 ≥ 2

abbrev T2aStmt : Prop :=
  ∀ (D : Nat) (s : Fin (D * D) → Int),
    (∀ u, s u * s u = 1) →
    signWitnessTraceSq D s = (D : Int) * (D : Int) * (D : Int)

abbrev T2bStmt : Prop :=
  ∀ {D : Nat} (N : Int) (e : Fin D → Int) (k : Fin D),
    sumFin (fun j : Fin D => e j * e j) ≤ (D : Int) * (N * N) →
    (D : Int) * (N * N) < 2 * (e k * e k) →
    0 < e k →
    (∀ j : Fin D, j ≠ k →
      e j * e j ≤ (D : Int) * (N * N) - e k * e k ∧
      e j * e j < e k * e k ∧ -e k < e j ∧ e j < e k) ∧
    (∀ (c : Fin D → Int) (j0 : Fin D), j0 ≠ k → c j0 ≠ 0 →
      sumFin (fun j : Fin D => (c j * c j) * e j) <
        e k * sumFin (fun j : Fin D => c j * c j))

abbrev T2cStmt : Prop :=
  (∀ (p : Nat), p ≥ 5 → p % 3 = 2 → (∀ x : Nat, x % p ≠ 0 → x ^ (p - 1) % p = 1) →
    let e := (2 * p - 1) / 3
    3 * e = 2 * (p - 1) + 1 ∧
    ∀ x : Nat, ((x ^ 3) ^ e) % p = x % p ∧ ((x ^ e) ^ 3) % p = x % p) ∧
  (∀ (p g : Nat), g ^ 3 % p = 1 → ∀ x : Nat, (g * x) ^ 3 % p = x ^ 3 % p) ∧
  (isConstantOriginMult 5 = true ∧ isConstantOriginMult 11 = true ∧
   isConstantOriginMult 17 = true ∧ isConstantOriginMult 23 = true ∧
   isConstantOriginMult 7 = false ∧ isConstantOriginMult 13 = false ∧
   isConstantOriginMult 19 = false ∧
   cubicOriginMult 7 0 = 1 ∧ cubicOriginMult 7 2 = 3 ∧ cubicOriginMult 7 1 = 0)

abbrev T3aStmt : Prop :=
  (∀ (q : Nat), q ≥ 1 →
    sumFin (fun a : Fin q => sumFin (fun b : Fin q =>
      alltopAmbiguitySq q a b * alltopAmbiguitySq q a b)) =
    (q : Int) * (q : Int) * (q : Int) * (2 * (q : Int) - 1)) ∧
  (∀ {q : Nat} (M : AlltopFieldModel q) (a h : Fin q),
    a ≠ M.zero → M.mul (M.mul M.six a) h = M.zero → h = M.zero)

abbrev T3bStmt : Prop :=
  ∀ {q : Nat} {R : Type} (M : AlltopFieldModel q)
    (mulR : R → R → R) (oneR : R)
    (_ : ∀ u v w, mulR (mulR u v) w = mulR u (mulR v w))
    (_ : ∀ u v, mulR u v = mulR v u)
    (_ : ∀ u, mulR oneR u = u)
    (chi : Fin q → R)
    (_ : chi M.zero = oneR)
    (_ : ∀ u v, chi (M.add u v) = mulR (chi u) (chi v)),
    let psiAlltop : Fin q → R := fun x => chi (M.cube x)
    let actCa : Fin q → (Fin q → R) → (Fin q → R) :=
      fun a phi x =>
        mulR (chi (M.neg (M.add (M.mul (M.mul M.three a) (M.sq x))
                                (M.mul (M.mul M.three (M.sq a)) x))))
             (phi (M.add x a))
    (∀ a x : Fin q, actCa a psiAlltop x = mulR (chi (M.cube a)) (psiAlltop x)) ∧
    (∀ phi : Fin q → R,
      (∀ a x : Fin q, actCa a phi x = mulR (chi (M.cube a)) (phi x)) →
      ∀ a : Fin q, phi a = mulR (psiAlltop a) (phi M.zero))

abbrev T3cStmt : Prop :=
  (∀ (D : Nat) (hD : D ≥ 2) (N : Int) (p : Fin (D * D) → Int),
    p ⟨0, Nat.mul_pos (by omega) (by omega)⟩ = N →
    sumFin p = (D : Int) * N →
    ((D : Int) + 1) * sumFin (fun k : Fin (D * D) => p k * p k) ≥ 2 * (D : Int) * (N * N) ∧
    (2 * (D : Int) - 1) * ((D : Int) + 1) - 2 * ((D : Int) * (D : Int)) = (D : Int) - 1 ∧
    0 < (D : Int) - 1) ∧
  (hoggarNormSq = 6 ∧ hoggarFourthMoment = 2304 ∧
   9 * hoggarFourthMoment = 2 * 8 * (hoggarNormSq ^ 4) ∧
   64 * hoggarFourthMoment < 15 * 8 * (hoggarNormSq ^ 4)) ∧
  (v44NormSq = 354 ∧ 256 * v44FourthMoment < 31 * 16 * (v44NormSq ^ 4))

abbrev T3dStmt : Prop :=
  phi5NormSq = 506 ∧
  Zeta5.beq (Zeta5.conj phi5FourthMoment) phi5FourthMoment = true ∧
  phi5FourthMoment.c1 = 0 ∧
  phi5FourthMoment.c2 = phi5FourthMoment.c3 ∧
  let diff := Zeta5.sub (Zeta5.scaleInt 25 phi5FourthMoment)
                        (Zeta5.ofInt (9 * 5 * (phi5NormSq ^ 4)))
  Zeta5.zSqrt5LtZero (Zeta5.realTwiceInt diff) (Zeta5.realTwiceSqrt5 diff) = true

abbrev T4aStmt : Prop :=
  (∀ m r : Nat, m ≥ 3 → r < m →
    ¬ ((2 ^ m - 1) ∣ 1) ∧ ¬ ((2 ^ m - 1) ∣ 3) ∧ ¬ ((2 ^ m - 1) ∣ (3 * 2 ^ r - 1))) ∧
  (((2 ^ 3 - 1) ∣ (3 * 2 ^ 1 + 1)) ∧
    ∀ m r : Nat, m ≥ 4 → r < m → ¬ ((2 ^ m - 1) ∣ (3 * 2 ^ r + 1))) ∧
  (∀ m i e : Nat, m ≥ 1 → (((2 ^ m - 1) ∣ (2 ^ i * e)) ↔ ((2 ^ m - 1) ∣ e)))

abbrev T4bStmt : Prop :=
  ∀ {n : Nat} (p : Nat), p ≥ 3 →
    ∀ (tauH tauQ : Fin n → Int),
      (∀ k : Fin n, tauH k = 0 ∨ tauH k = 1) →
      sumFin tauQ = (p : Int) + 1 →
      (∀ i : Fin n, circMulVec tauH tauH i % (p : Int) = 1) →
      (∀ (u : Fin n → Int) (k : Fin n),
        (∀ j : Fin n, vecMulCirc u tauH j % (p : Int) = tauH j % (p : Int)) →
        vecMulCirc u (circConv tauQ tauH) k % (p : Int) = vecMulCirc tauH tauQ k % (p : Int)) →
      (∀ i : Fin n, circMulVec (circConv tauQ tauH) tauH i % (p : Int) = (sumFin tauQ) % (p : Int)) →
      (∀ k : Fin n, 0 ≤ vecMulCirc tauH tauQ k ∧ vecMulCirc tauH tauQ k < (p : Int)) →
      sumFin (fun k : Fin n => vecMulCirc tauH tauQ k * (vecMulCirc tauH tauQ k - 1)) =
        (p : Int) * ((p : Int) + 1) →
      (∀ i : Fin n, (circMulVec (circConv tauQ tauH) tauH i - circMulVec tauH tauH i) % (p : Int) = 0) ∧
      (¬ ∃ u : Fin n → Int,
        (∀ k : Fin n, vecMulCirc u tauH k % (p : Int) = tauH k % (p : Int)) ∧
        (∀ k : Fin n, vecMulCirc u (circConv tauQ tauH) k % (p : Int) = tauH k % (p : Int)))

abbrev T4cStmt : Prop :=
  (checkConj24Instance 3 11 = (true, false) ∧
   checkConj24Instance 4 19 = (true, true) ∧
   checkConj24Instance 5 37 = (true, true) ∧
   checkConj24Instance 6 67 = (true, true)) ∧
  (verifyQp2LineWitness 3 1 0 2 = true ∧
   verifyQp2LineWitness 5 2 0 1 = true ∧
   verifyQp2LineWitness 7 2 1 1 = true ∧
   verifyQp2LineWitness 11 3 0 1 = true)

abbrev AllFrontierTheoremsStmt : Prop :=
  T1aStmt ∧ T1bStmt ∧ T1cStmt ∧ T1dStmt ∧
  T2aStmt ∧ T2bStmt ∧ T2cStmt ∧
  T3aStmt ∧ T3bStmt ∧ T3cStmt ∧ T3dStmt ∧
  T4aStmt ∧ T4bStmt ∧ T4cStmt

end

end WeylMagicFrontier.Challenge
