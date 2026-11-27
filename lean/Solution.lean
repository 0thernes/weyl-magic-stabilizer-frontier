-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

public import Challenge

/-!
# Complete Sorry-Free Solution (`Solution.lean`)

Discharges all 14 headline theorems (`T1a`–`T4c`) plus `AllFrontierTheoremsStmt` from
`WeylMagicFrontier.Pillar1`–`Pillar4`, with zero `sorry`, zero `admit`, zero `native_decide`,
and zero custom axioms.
-/

namespace WeylMagicFrontier.Solution

open Challenge
open WeylMagicFrontier.Pillar1
open WeylMagicFrontier.Pillar2
open WeylMagicFrontier.Pillar3
open WeylMagicFrontier.Pillar4

public theorem prove_t1a : T1aStmt :=
  fun a b c hpyth => qutrit_rational_circle_wh_sic a b c hpyth

public theorem prove_t1b : T1bStmt :=
  ⟨allSL2F3_card, allPCliff3_card, allSL2F3_meta_unitary, allSL2F3_symplectic_covariant,
   qutrit_sic_refutes_clifford_stabilizer_conjecture.1,
   qutrit_sic_refutes_clifford_stabilizer_conjecture.2.1,
   qutrit_sic_refutes_clifford_stabilizer_conjecture.2.2.1,
   qutrit_sic_refutes_clifford_stabilizer_conjecture.2.2.2⟩

public theorem prove_t1c : T1cStmt :=
  ⟨zauner_trace_multiplicity_identity, zauner_eigenspace_dim_universal_obstruction⟩

public theorem prove_t1d : T1dStmt :=
  dim4_scott_grassl_4a_obstruction

public theorem prove_t2a : T2aStmt :=
  sign_witness_trace_sq_identity

public theorem prove_t2b : T2bStmt :=
  fun N e k ht hh hp =>
    ⟨trace_norm_spectral_dominance N e k ht hh hp,
     trace_norm_spectral_lock N e k ht hh hp⟩

public theorem prove_t2c : T2cStmt :=
  ⟨cubic_bijection_mod3_eq2, cubic_3to1_mod3_eq1, cubic_origin_wigner_concrete_dichotomy⟩

public theorem prove_t3a : T3aStmt :=
  ⟨alltop_fourth_moment_exact, fun M a h ha hz => AlltopFieldModel.six_mul_eq_zero_imp M a h ha hz⟩

public theorem prove_t3b : T3bStmt :=
  fun M mulR oneR ha hc ho chi hz hadd =>
    alltop_clifford_unification M mulR oneR ha hc ho chi hz hadd

public theorem prove_t3c : T3cStmt :=
  ⟨fun D hD N p hp0 hpv => welch_bound_and_mub_gap D hD N p hp0 hpv,
   hoggar_3qubit_beats_mub,
   composite_d4_beats_mub⟩

public theorem prove_t3d : T3dStmt :=
  alltop_d5_saddle_instability

public theorem prove_t4a : T4aStmt :=
  ⟨conjecture24_nondivisibility, remark21_plus_sign_dichotomy, pow2_dvd_iff_of_odd_mod⟩

public theorem prove_t4b : T4bStmt :=
  fun p hp tauH tauQ hbin hwt hline hcomm hmq harc hsec =>
    odd_prime_singer_upper_bound p hp tauH tauQ hbin hwt hline hcomm hmq harc hsec

public theorem prove_t4c : T4cStmt :=
  ⟨conj24_concrete_d2_to_d5, qp2_concrete_flagship_witnesses⟩

public theorem prove_all_frontier_theorems : AllFrontierTheoremsStmt :=
  ⟨prove_t1a, prove_t1b, prove_t1c, prove_t1d,
   prove_t2a, prove_t2b, prove_t2c,
   prove_t3a, prove_t3b, prove_t3c, prove_t3d,
   prove_t4a, prove_t4b, prove_t4c⟩

end WeylMagicFrontier.Solution
