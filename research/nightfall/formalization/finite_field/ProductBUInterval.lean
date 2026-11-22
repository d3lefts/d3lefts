import Mathlib

/-!
# Fixed points of arbitrary continuous maps on a closed real interval

This is the elementary topological input for the one-interval orbit
contradiction in the product-sphere proof. No product-sphere zero theorem
or transversality is asserted here.

We use the pinned Mathlib Tietze extension and intermediate value theorem.
-/

namespace Nightfall.ProductBUInterval

theorem interval_has_fixedPoint
    (f : Set.Icc (0 : ℝ) 1 → Set.Icc (0 : ℝ) 1)
    (hf : Continuous f) :
    ∃ x : Set.Icc (0 : ℝ) 1, f x = x := by
  let J : Set ℝ := Set.Icc 0 1
  let fsub : C(J, ℝ) :=
    ⟨(fun t => ((f t).1 : ℝ)), continuous_subtype_val.comp hf⟩
  obtain ⟨F, hF⟩ :=
    ContinuousMap.exists_restrict_eq (isClosed_Icc : IsClosed J) fsub
  have hzero : F 0 = ((f ⟨0, by norm_num⟩).1 : ℝ) := by
    have h := congrArg (fun T : C(J, ℝ) => T ⟨0, by dsimp [J]; norm_num⟩) hF
    exact h
  have hone : F 1 = ((f ⟨1, by norm_num⟩).1 : ℝ) := by
    have h := congrArg (fun T : C(J, ℝ) => T ⟨1, by dsimp [J]; norm_num⟩) hF
    exact h
  have h0 : 0 ≤ F 0 - 0 := by
    rw [hzero]
    simpa only [sub_zero] using (f ⟨0, by norm_num⟩).2.1
  have h1 : F 1 - 1 ≤ 0 := by
    rw [hone]
    linarith [(f ⟨1, by norm_num⟩).2.2]
  have hcont : ContinuousOn (fun t : ℝ => F t - t) J :=
    (F.continuous.sub continuous_id).continuousOn
  obtain ⟨x, hx, hz⟩ :=
    intermediate_value_Icc' (by norm_num : (0 : ℝ) ≤ 1)
      hcont ⟨h1, h0⟩
  refine ⟨⟨x, hx⟩, Subtype.ext ?_⟩
  have hres := congrArg (fun T : C(J, ℝ) => T ⟨x,hx⟩) hF
  change F x = (f ⟨x,hx⟩).1 at hres
  change F x - x = 0 at hz
  linarith

/-- The interval fixed-point principle transports along a homeomorphism. -/
theorem homeomorphic_interval_has_fixedPoint
    {Z : Type*} [TopologicalSpace Z]
    (e : Z ≃ₜ Set.Icc (0 : ℝ) 1)
    (g : Z → Z) (hg : Continuous g) :
    ∃ z : Z, g z = z := by
  have hcon : Continuous (fun x : Set.Icc (0 : ℝ) 1 =>
      e (g (e.symm x))) :=
    e.continuous.comp (hg.comp e.symm.continuous)
  obtain ⟨x,hfix⟩ := interval_has_fixedPoint
    (fun x => e (g (e.symm x))) hcon
  refine ⟨e.symm x, ?_⟩
  have h := congrArg e.symm hfix
  simpa only [e.symm_apply_apply] using h

#print axioms interval_has_fixedPoint
#print axioms homeomorphic_interval_has_fixedPoint

end Nightfall.ProductBUInterval
