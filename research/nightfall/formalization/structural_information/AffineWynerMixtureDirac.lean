import AffineWynerSupport

/-!
# NIGHTFALL: finite product-mixture support forces nonfree Dirac coordinates

A nonnegative finite mixture of normalized product distributions, whose
aggregate law vanishes off an affine code a+L, has a strong property:
every *positive-weight* component distribution itself has support in a+L.
The certified rectangle-support theorem then forces each coordinate whose
unit axis is not in L to be deterministic under that component.

No positivity lower bound is assumed on atom masses, and zero-weight
latent components may be arbitrary. This is an exact source-level
consequence of the already kernel-checked support rigidity theorem.
It is NOT the full Wyner common-information/entropy infimum identity.
-/

namespace Nightfall.AffineWyner

open Finset

variable {ι 𝔽 Θ : Type*}
  [Fintype ι] [DecidableEq ι] [Field 𝔽]
  [Fintype 𝔽] [DecidableEq 𝔽]
  [Fintype Θ] [DecidableEq Θ]

/-- Every positive-weight component of a nonnegative product mixture is
supported where the total mixture has support. This holds including
zero-mass atoms and does not need positive masses elsewhere. -/
theorem positive_component_supported_in_code
    (L : Submodule 𝔽 (ι → 𝔽)) (a : ι → 𝔽)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (P : Θ → ι → 𝔽 → ℝ) (hP0 : ∀ θ i b, 0 ≤ P θ i b)
    (hsupport : ∀ x : ι → 𝔽, ¬InAffineCode L a x →
      (∑ θ, w θ * productMass (P θ) x) = 0)
    (θ : Θ) (hθ : 0 < w θ)
    (x : ι → 𝔽) (hx : 0 < productMass (P θ) x) :
    InAffineCode L a x := by
  by_contra hnot
  have hzero := hsupport x hnot
  have hterms : ∀ t : Θ, 0 ≤ w t * productMass (P t) x := by
    intro t
    have hprod : 0 ≤ productMass (P t) x := by
      unfold productMass
      exact Finset.prod_nonneg (fun j _ => hP0 t j (x j))
    exact mul_nonneg (hw0 t) hprod
  have hterm : 0 < w θ * productMass (P θ) x := mul_pos hθ hx
  have hsingle : w θ * productMass (P θ) x ≤
      ∑ t : Θ, w t * productMass (P t) x :=
    Finset.single_le_sum (fun t _ => hterms t) (Finset.mem_univ θ)
  linarith

/-- Every positive-weight latent component has a Dirac marginal on
each nonfree affine-code coordinate. This is the decisive geometric
support-to-latent-determinism bridge for finite affine Wyner. -/
theorem mixture_nonfree_coordinate_dirac
    (L : Submodule 𝔽 (ι → 𝔽)) (a : ι → 𝔽)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (P : Θ → ι → 𝔽 → ℝ)
    (hP0 : ∀ θ i b, 0 ≤ P θ i b)
    (hP1 : ∀ θ i, ∑ b, P θ i b = 1)
    (hsupport : ∀ x : ι → 𝔽, ¬InAffineCode L a x →
      (∑ θ, w θ * productMass (P θ) x) = 0)
    (θ : Θ) (hθ : 0 < w θ)
    (i : ι) (hi : axis i ∉ L) :
    ∃ b : 𝔽, P θ i b = 1 ∧ ∀ v : 𝔽, v ≠ b → P θ i v = 0 := by
  have hprod : ∀ x : ι → 𝔽, 0 < productMass (P θ) x →
      InAffineCode L a x := by
    intro x hx
    exact positive_component_supported_in_code L a w hw0 P hP0
      hsupport θ hθ x hx
  exact supported_product_nonfree_dirac L a (P θ)
    (hP0 θ) (hP1 θ) hprod i hi

/-- Same conclusion from an explicitly represented source law: if the
source is zero off the affine code and equals a finite product mixture,
every positive-weight component fixes all nonfree coordinates. -/
theorem mixture_nonfree_dirac_of_source
    (L : Submodule 𝔽 (ι → 𝔽)) (a : ι → 𝔽)
    (ν : (ι → 𝔽) → ℝ)
    (hν : ∀ x : ι → 𝔽, ¬InAffineCode L a x → ν x = 0)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (P : Θ → ι → 𝔽 → ℝ)
    (hP0 : ∀ θ i b, 0 ≤ P θ i b)
    (hP1 : ∀ θ i, ∑ b, P θ i b = 1)
    (hdecomp : ∀ x : ι → 𝔽,
      ν x = ∑ θ, w θ * productMass (P θ) x)
    (θ : Θ) (hθ : 0 < w θ)
    (i : ι) (hi : axis i ∉ L) :
    ∃ b : 𝔽, P θ i b = 1 ∧ ∀ v : 𝔽, v ≠ b → P θ i v = 0 := by
  apply mixture_nonfree_coordinate_dirac L a w hw0 P hP0 hP1 ?_ θ hθ i hi
  intro x hx
  calc
    (∑ t : Θ, w t * productMass (P t) x) = ν x := (hdecomp x).symm
    _ = 0 := hν x hx

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.positive_component_supported_in_code
#print axioms Nightfall.AffineWyner.mixture_nonfree_coordinate_dirac
#print axioms Nightfall.AffineWyner.mixture_nonfree_dirac_of_source
