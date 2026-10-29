import Init

/-!
NIGHTFALL: tiny, kernel-checkable characteristic-three sanity lemmas.
Scope: Fin 3 only. These do NOT formalize the adaptive decoder theorem,
the optimal query count, F_(3^r), or any originality claim.
No sorry, axioms, native_decide, or trusted external result.
-/

namespace Nightfall.FiniteField

theorem cubing_is_identity_mod_three :
    ∀ x : Fin 3, (x.val ^ 3) % 3 = x.val := by
  decide

theorem cube_additive_mod_three :
    ∀ x y : Fin 3,
      ((x.val + y.val) ^ 3) % 3 = (x.val ^ 3 + y.val ^ 3) % 3 := by
  decide

#print axioms Nightfall.FiniteField.cubing_is_identity_mod_three
#print axioms Nightfall.FiniteField.cube_additive_mod_three

end Nightfall.FiniteField
