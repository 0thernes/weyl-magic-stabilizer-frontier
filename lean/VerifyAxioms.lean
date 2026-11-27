-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

import PalomarSolution
import WeylMagicFrontier.NonVacuity
import WeylMagicFrontier.AdversarialTests

/-!
# Strict Kernel Axiom Audit (`VerifyAxioms.lean`)

Prints exact transitive axiom footprints for all 15 Palomar headline targets
(`T1a`–`T4c` + `ALL`), all 8 constructive non-vacuity witnesses (`NV01`–`NV08`),
and all 8 formal adversarial boundary refutations (`AT01`–`AT08`) — 31 declarations total.
Every single declaration must depend ONLY on a subset of `{propext, Classical.choice, Quot.sound}`
(zero `sorryAx`, zero `Lean.ofReduceBool`, zero custom axioms).
-/

#print axioms WeylMagicFrontier.Palomar.prove_t1a
#print axioms WeylMagicFrontier.Palomar.prove_t1b
#print axioms WeylMagicFrontier.Palomar.prove_t1c
#print axioms WeylMagicFrontier.Palomar.prove_t1d
#print axioms WeylMagicFrontier.Palomar.prove_t2a
#print axioms WeylMagicFrontier.Palomar.prove_t2b
#print axioms WeylMagicFrontier.Palomar.prove_t2c
#print axioms WeylMagicFrontier.Palomar.prove_t3a
#print axioms WeylMagicFrontier.Palomar.prove_t3b
#print axioms WeylMagicFrontier.Palomar.prove_t3c
#print axioms WeylMagicFrontier.Palomar.prove_t3d
#print axioms WeylMagicFrontier.Palomar.prove_t4a
#print axioms WeylMagicFrontier.Palomar.prove_t4b
#print axioms WeylMagicFrontier.Palomar.prove_t4c
#print axioms WeylMagicFrontier.Palomar.prove_all_frontier_theorems

#print axioms WeylMagicFrontier.nonvacuity_nv01_qutrit_rational_circle
#print axioms WeylMagicFrontier.nonvacuity_nv02_pcliff3_refutation
#print axioms WeylMagicFrontier.nonvacuity_nv03_zauner_multiplicities
#print axioms WeylMagicFrontier.nonvacuity_nv04_mana_spectral_lock
#print axioms WeylMagicFrontier.nonvacuity_nv05_alltop_f5_model
#print axioms WeylMagicFrontier.nonvacuity_nv06_super_mub_witnesses
#print axioms WeylMagicFrontier.nonvacuity_nv07_binary_singer_d2
#print axioms WeylMagicFrontier.nonvacuity_nv08_singer_q7_q11_witnesses

#print axioms WeylMagicFrontier.refute_at01_sic_is_1d_clifford_stabilizer
#print axioms WeylMagicFrontier.refute_at02_v345_stabilizer_order_not_1_or_9
#print axioms WeylMagicFrontier.refute_at03_spectral_lock_without_high_mana
#print axioms WeylMagicFrontier.refute_at04_alltop_d5_nonvanishing_wigner
#print axioms WeylMagicFrontier.refute_at05_3qubit_mub_ceiling
#print axioms WeylMagicFrontier.refute_at06_composite_d4_mub_ceiling
#print axioms WeylMagicFrontier.refute_at07_d5_alltop_local_maximum
#print axioms WeylMagicFrontier.refute_at08_remark21_u_plus_at_d2
