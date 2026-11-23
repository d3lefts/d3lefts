import Mathlib
import AffineWynerFibers

/-!
# NIGHTFALL — the full free-coordinate affine-code fiber is a Cartesian cube

The algebraic heart of the exact finite-field Wyner identity is not merely
that free-axis updates remain in the affine code, but that the entire fiber
over a fixed projection to the nonfree coordinates is EXACTLY the set of all
free-coordinate assignments, with no additional correlations.

This module gives an explicit equivalence for arbitrary fields, then proves
the exact finite-field fiber count q^r with r free axes. It is a new scoped
step beyond #1104, but it does not compute Shannon entropy or Wyner's infimum.
-/

namespace Nightfall.AffineWyner

variable {ι 𝔽 : Type*} [Fintype ι] [DecidableEq ι] [Field 𝔽]

/-- Coordinates whose unit axes belong to the linear code. -/
def FreeAxis (L : Submodule 𝔽 (ι → 𝔽)) : Type _ :=
  { i : ι // axis i ∈ L }

/-- All codewords in the SAME nonfree-coordinate projection fiber as x. -/
def FixedProjectionFiber
    (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽) : Type _ :=
  {z : ι → 𝔽 // InAffineCode L a z ∧
    ∀ i, axis i ∉ L → z i = x i}

/-- A source-exact algebraic bijection between the affine fiber and all
free-coordinate assignments, for any field and finite index type. -/
noncomputable def fixedProjectionFiberEquiv
    (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽)
    (hx : InAffineCode L a x) :
    FixedProjectionFiber L a x ≃ (FreeAxis L → 𝔽) := by
  classical
  let assign : (FreeAxis L → 𝔽) → ι → 𝔽 :=
    fun h i => if hi : axis i ∈ L then h ⟨i, hi⟩ else x i
  have hass : ∀ h, InAffineCode L a (assign h) := by
    intro h
    apply complete_free_fiber L a x (assign h) hx
    intro i hi
    simp [assign, hi]
  refine {
    toFun := fun z j => z.1 j.1
    invFun := fun h => ⟨assign h,
      hass h, by
        intro i hi
        simp [assign, hi]⟩
    left_inv := ?_
    right_inv := ?_
  }
  · intro z
    apply Subtype.ext
    funext i
    by_cases hi : axis i ∈ L
    · simp [assign, hi]
    · simpa [assign, hi] using (z.2.2 i hi).symm
  · intro h
    funext ⟨i, hi⟩
    simp [assign, hi]

/-- Every fiber over the nonfree coordinates has exactly q^r codewords.
All assumptions are finite-field and code-dimensional; the information
and logarithm bridge remains a separate theorem gate. -/
theorem fixedProjectionFiber_card
    [Fintype 𝔽]
    (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽)
    (hx : InAffineCode L a x) :
    Fintype.card (FixedProjectionFiber L a x) =
      (Fintype.card 𝔽) ^ Fintype.card (FreeAxis L) := by
  classical
  rw [Fintype.card_congr (fixedProjectionFiberEquiv L a x hx)]
  simp

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.fixedProjectionFiberEquiv
#print axioms Nightfall.AffineWyner.fixedProjectionFiber_card
