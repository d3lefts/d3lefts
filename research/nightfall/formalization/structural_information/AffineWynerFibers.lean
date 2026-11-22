import Mathlib
import AffineWynerSupport

/-!
# NIGHTFALL — exact affine-code rectangle fibers

Source dependency: AffineWynerSupport.lean, authored independently in PR #1099.
This module proves the **converse** to its rectangular-support rigidity
without invoking entropy, a new axiom, or any result labeled "Wyner identity".

For an affine linear code a + L over a field, a Cartesian coordinate rectangle
containing a codeword x is contained in the code exactly when each coordinate
with axis e_i ∉ L is fixed to x_i. Free coordinates may vary *jointly and
arbitrarily*, not just one at a time.

This is a formal algebraic certification step toward the uniform-code
common-information identity, NOT yet a formal entropy or infimum equality.
-/

namespace Nightfall.AffineWyner

variable {ι 𝔽 : Type*} [Fintype ι] [DecidableEq ι] [Field 𝔽]

/-- Replace a selected finite set of coordinates by values from z. -/
def mix (x z : ι → 𝔽) (s : Finset ι) : ι → 𝔽 :=
  fun j => if j ∈ s then z j else x j

/-- Changing one free coordinate preserves membership in the affine code. -/
theorem update_free_in_affine_code
    (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽) (i : ι) (v : 𝔽)
    (hx : InAffineCode L a x) (hi : axis i ∈ L) :
    InAffineCode L a (Function.update x i v) := by
  have hdelta :
      Function.update x i v - x = (v - x i) • axis i := by
    apply sub_eq_smul_axis i (Function.update x i v) x
    intro j hj
    simp [Function.update_noteq hj]
  have hrewrite :
      Function.update x i v - a =
        (Function.update x i v - x) + (x - a) := by
    ext j
    simp only [Pi.sub_apply, Pi.add_apply]
    ring
  change Function.update x i v - a ∈ L
  rw [hrewrite, hdelta]
  exact L.add_mem (L.smul_mem (v - x i) hi) hx

/-- Any simultaneous assignment of values to finitely many free coordinates
preserves affine code membership. No independence of nonfree coordinates
is asserted. -/
theorem mix_free_in_affine_code
    (L : Submodule 𝔽 (ι → 𝔽)) (a x z : ι → 𝔽)
    (hx : InAffineCode L a x) (s : Finset ι)
    (hfree : ∀ i ∈ s, axis i ∈ L) :
    InAffineCode L a (mix x z s) := by
  induction s using Finset.induction_on with
  | empty =>
      simpa [mix] using hx
  | @insert i s his ih =>
      have hs : ∀ j ∈ s, axis j ∈ L := by
        intro j hj
        exact hfree j (Finset.mem_insert_of_mem hj)
      have hstep :
          mix x z (insert i s) =
            Function.update (mix x z s) i (z i) := by
        ext j
        by_cases hj : j = i
        · subst j
          simp [mix]
        · simp [mix, hj, Function.update_noteq hj]
      rw [hstep]
      exact update_free_in_affine_code L a (mix x z s) i (z i)
        (ih hs) (hfree i (Finset.mem_insert_self i s))

/-- All assignments agreeing with a codeword on the nonfree coordinates
belong to its affine code. The free-coordinate fiber is a full Cartesian cube. -/
theorem complete_free_fiber
    (L : Submodule 𝔽 (ι → 𝔽)) (a x z : ι → 𝔽)
    (hx : InAffineCode L a x)
    (hmatch : ∀ i, axis i ∉ L → z i = x i) :
    InAffineCode L a z := by
  classical
  let s : Finset ι := Finset.univ.filter (fun i => axis i ∈ L)
  have hfree : ∀ i ∈ s, axis i ∈ L := by
    intro i hi
    exact (Finset.mem_filter.mp hi).2
  have hmix : mix x z s = z := by
    ext i
    by_cases hi : axis i ∈ L
    · simp [mix, s, hi]
    · simp [mix, s, hi, hmatch i hi]
  have hcode : InAffineCode L a (mix x z s) :=
    mix_free_in_affine_code L a x z hx s hfree
  simpa only [hmix] using hcode

/-- **Exact rectangle classification**, the converse and strengthening of
the #1099 support-rectangle obstruction. Given a codeword x in the rectangle,
the full rectangle is in a+L iff each nonfree coordinate is fixed to x_i.
This holds over arbitrary fields and any finite number of coordinates. -/
theorem rectangular_support_iff_nonfree_fixed
    (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽)
    (P : ι → Set 𝔽)
    (hP : ∀ i, (P i).Nonempty)
    (hxP : ∀ i, x i ∈ P i)
    (hxcode : InAffineCode L a x) :
    (∀ z : ι → 𝔽, (∀ i, z i ∈ P i) → InAffineCode L a z) ↔
      (∀ i, axis i ∉ L → ∀ v ∈ P i, v = x i) := by
  constructor
  · intro hrect i hi v hv
    exact rectangular_support_nonfree_singleton L a P hP hrect
      i hi v hv (x i) (hxP i)
  · intro hfix z hz
    apply complete_free_fiber L a x z hxcode
    intro i hi
    exact hfix i hi (z i) (hz i)

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.update_free_in_affine_code
#print axioms Nightfall.AffineWyner.mix_free_in_affine_code
#print axioms Nightfall.AffineWyner.complete_free_fiber
#print axioms Nightfall.AffineWyner.rectangular_support_iff_nonfree_fixed
