-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue
module

import Lean
import PalomarSolution
import WeylMagicFrontier.NonVacuity
import WeylMagicFrontier.AdversarialTests

/-!
# Exhaustive Environment-Wide Axiom Sweep (`AuditAllDecls.lean`)

Uses `Lean.collectAxioms` over EVERY SINGLE constant in the `WeylMagicFrontier` namespace
(theorems, definitions, auxiliary lemmas, non-vacuity witnesses, adversarial tests, and
Palomar targets) — failing elaboration if ANY declaration anywhere depends on `sorryAx`,
a Lean 4.35 `_native` axiom, `Lean.ofReduceBool`, or any custom axiom outside
`{propext, Classical.choice, Quot.sound}`.
-/

open Lean in
#eval show MetaM Unit from do
  let env ← getEnv
  let allowed : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut checked := 0
  let mut violations : Array (Name × Array Name) := #[]
  for (name, _) in env.constants.map₁.toList do
    let s := name.toString
    if s.startsWith "WeylMagicFrontier." && !name.isInternal then
      let axs ← Lean.collectAxioms name
      let bad := axs.filter fun a => !allowed.contains a
      checked := checked + 1
      if !bad.isEmpty then
        violations := violations.push (name, bad)
  if !violations.isEmpty then
    throwError m!"EXHAUSTIVE AXIOM AUDIT FAILED: {violations}"
  IO.println s!"EXHAUSTIVE_AXIOM_AUDIT_PASS: checked={checked} declarations in WeylMagicFrontier.*, violations=0"
