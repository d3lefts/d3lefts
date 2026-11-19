import LatentProductInterpolationDegree

/-!
# Algebraic evaluation bridge for sparse product expectations

The polynomial built out of at-most-d coordinate interactions evaluates
exactly to the corresponding finite sum of products of affine marginal
weights. No margin, positivity, distribution assumption or derivative
inequality occurs in this theorem.

The next bridge to full product laws is the finite Fubini identity equating
each one-hot interaction's expectation to the product of its marginals.
-/
namespace Nightfall.LatentProductInterpolationDegree

open Polynomial Finset

theorem interactionPoly_eval
    {ι α : Type*} (S : Finset ι) (a : ι → α)
    (p q : ι → α → ℝ) (s : ℝ) :
    (interactionPoly S a p q).eval s =
      ∏ i ∈ S, (p i (a i) + (q i (a i) - p i (a i)) * s) := by
  simp [interactionPoly, affineMarginal_eval]

theorem sparseExpectationPoly_eval
    {ι α β : Type*}
    (terms : Finset β) (support : β → Finset ι)
    (assignment : β → ι → α) (coeff : β → ℝ)
    (p q : ι → α → ℝ) (s : ℝ) :
    (sparseExpectationPoly terms support assignment coeff p q).eval s =
      ∑ t ∈ terms, coeff t *
        ∏ i ∈ support t,
          (p i (assignment t i) +
            (q i (assignment t i) - p i (assignment t i)) * s) := by
  simp [sparseExpectationPoly, interactionPoly_eval]

end Nightfall.LatentProductInterpolationDegree
