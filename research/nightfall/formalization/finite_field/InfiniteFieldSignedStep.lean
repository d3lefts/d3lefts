import Mathlib

/-!
# Infinite-field square oracle: signed-code extension

A reusable algebraic bridge for infinite-field phase retrieval.
Every injective finite signed code can be extended by one sign.
No source-level oracle terminal is claimed in this file.
-/

namespace Nightfall.InfiniteFieldPhase

noncomputable section

variable {K : Type*} [Field K] [Infinite K] [NeZero (2 : K)]

/-- Extend any injective finite code by one signed bit over an infinite field. -/
theorem exists_signed_code_extension
    {α : Type*} [Fintype α] (f : α → K) (hf : Function.Injective f) :
    ∃ z : K, Function.Injective (fun p : Bool × α =>
      f p.2 + (if p.1 then z else -z)) := by
  classical
  let bad : Finset K :=
    Finset.univ.image (fun p : α × α => (f p.1 - f p.2) / (2 : K))
  obtain ⟨z, hz⟩ := Infinite.exists_notMem_finset bad
  refine ⟨z, ?_⟩
  rintro ⟨b, x⟩ ⟨c, y⟩ heq
  have htwo : (2 : K) ≠ 0 := NeZero.ne _
  cases b with
  | false =>
      cases c with
      | false =>
          have hxy : x = y := hf (by linear_combination heq)
          simpa [hxy]
      | true =>
          have he : f x - z = f y + z := by simpa using heq
          have hcalc : z = (f x - f y) / (2 : K) := by
            apply (eq_div_iff htwo).2
            linear_combination -he
          have hmem : z ∈ bad := by
            apply Finset.mem_image.mpr
            refine ⟨(x, y), Finset.mem_univ _, ?_⟩
            simpa [hcalc]
          exact False.elim (hz hmem)
  | true =>
      cases c with
      | false =>
          have he : f x + z = f y - z := by simpa using heq
          have hcalc : z = (f y - f x) / (2 : K) := by
            apply (eq_div_iff htwo).2
            linear_combination he
          have hmem : z ∈ bad := by
            apply Finset.mem_image.mpr
            refine ⟨(y, x), Finset.mem_univ _, ?_⟩
            simpa [hcalc]
          exact False.elim (hz hmem)
      | true =>
          have hxy : x = y := hf (by linear_combination heq)
          simpa [hxy]

#print axioms Nightfall.InfiniteFieldPhase.exists_signed_code_extension

end
end Nightfall.InfiniteFieldPhase
