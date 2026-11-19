import Mathlib

/-!
# Product-source interpolation: exact polynomial degree

This proves an unconditional algebraic bridge: the expectation polynomial of
an interaction expansion whose monomials involve at most d *distinct input
coordinates* has ordinary univariate degree at most d along any affine path
of coordinate marginals. The result is valid for arbitrary real marginal
weights, hence in particular for finite product distributions with zero atoms.

The missing next ingredient for bias-free stability is the sharp analytic
Markov derivative inequality (and the probabilistic normalization/positivity
of the common-part path), NOT this degree accounting.
-/

namespace Nightfall.LatentProductInterpolationDegree

open Polynomial Finset

variable {ι α β : Type*}

/-- The marginal probability weight along a line from p to q. -/
noncomputable def affineMarginal (p q : ι → α → ℝ) (i : ι) (a : α) : Polynomial ℝ :=
  C (p i a) + C (q i a - p i a) * X

/-- Every affine marginal has ordinary polynomial degree at most one. -/
theorem affineMarginal_natDegree_le_one
    (p q : ι → α → ℝ) (i : ι) (a : α) :
    (affineMarginal p q i a).natDegree ≤ 1 := by
  unfold affineMarginal
  have hc : (C (p i a) : Polynomial ℝ).natDegree = 0 := by simp
  have hd : (C (q i a - p i a) : Polynomial ℝ).natDegree = 0 := by simp
  have hx : (X : Polynomial ℝ).natDegree = 1 := by simp
  have hm : ((C (q i a - p i a) : Polynomial ℝ) * X).natDegree ≤
      (C (q i a - p i a) : Polynomial ℝ).natDegree +
      (X : Polynomial ℝ).natDegree := Polynomial.natDegree_mul_le
  have ha := Polynomial.natDegree_add_le
    (C (p i a) : Polynomial ℝ)
    ((C (q i a - p i a) : Polynomial ℝ) * X)
  omega

/-- Product expectation of a one-hot interaction supported on S. -/
noncomputable def interactionPoly (S : Finset ι) (a : ι → α)
    (p q : ι → α → ℝ) : Polynomial ℝ :=
  ∏ i ∈ S, affineMarginal p q i (a i)

/-- Interaction interpolation has degree at most the number of active
coordinates, regardless of ambient dimension or marginal atoms. -/
theorem interactionPoly_natDegree_le_card
    (S : Finset ι) (a : ι → α) (p q : ι → α → ℝ) :
    (interactionPoly S a p q).natDegree ≤ S.card := by
  unfold interactionPoly
  calc
    (∏ i ∈ S, affineMarginal p q i (a i)).natDegree ≤
        ∑ i ∈ S, (affineMarginal p q i (a i)).natDegree :=
      Polynomial.natDegree_prod_le S (fun i => affineMarginal p q i (a i))
    _ ≤ ∑ i ∈ S, (1 : ℕ) := by
      apply Finset.sum_le_sum
      intro i hi
      exact affineMarginal_natDegree_le_one p q i (a i)
    _ = S.card := by simp

/-- Multiplying an interaction by a real coefficient adds no degree. -/
theorem weightedInteraction_natDegree_le_card
    (S : Finset ι) (a : ι → α) (c : ℝ) (p q : ι → α → ℝ) :
    (C c * interactionPoly S a p q).natDegree ≤ S.card := by
  have h : (C c * interactionPoly S a p q).natDegree ≤
      (C c : Polynomial ℝ).natDegree +
      (interactionPoly S a p q).natDegree := Polynomial.natDegree_mul_le
  have hc : (C c : Polynomial ℝ).natDegree = 0 := by simp
  have hs := interactionPoly_natDegree_le_card S a p q
  omega

/-- Finite sparse interaction expansion of product expectations. -/
noncomputable def sparseExpectationPoly
    (terms : Finset β) (support : β → Finset ι)
    (assignment : β → ι → α) (coeff : β → ℝ)
    (p q : ι → α → ℝ) : Polynomial ℝ :=
  ∑ t ∈ terms, C (coeff t) * interactionPoly (support t) (assignment t) p q

/-- **Exact algebraic certificate.** No positivity, bias-floor, dimension,
or bounded-function assumption is needed for the degree upper bound.
Those enter only when using the polynomial to prove stability. -/
theorem sparseExpectationPoly_natDegree_le
    (terms : Finset β) (support : β → Finset ι)
    (assignment : β → ι → α) (coeff : β → ℝ)
    (p q : ι → α → ℝ) (d : ℕ)
    (hdegree : ∀ t ∈ terms, (support t).card ≤ d) :
    (sparseExpectationPoly terms support assignment coeff p q).natDegree ≤ d := by
  unfold sparseExpectationPoly
  apply Polynomial.natDegree_sum_le_of_forall_le
  intro t ht
  exact (weightedInteraction_natDegree_le_card
    (support t) (assignment t) (coeff t) p q).trans (hdegree t ht)

/-- Evaluating the affine polynomial exactly reproduces the desired
coordinate marginal interpolation. -/
theorem affineMarginal_eval
    (p q : ι → α → ℝ) (i : ι) (a : α) (s : ℝ) :
    (affineMarginal p q i a).eval s =
      p i a + (q i a - p i a) * s := by
  simp [affineMarginal]

end Nightfall.LatentProductInterpolationDegree
