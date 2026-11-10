import ProductSpaceTwoSidedBridge

/-!
# NIGHTFALL: the concrete certificate-to-observation bridge

This module composes, without re-assuming the localized certificate inequality,
the pinned Turturean -> finite-product two-sided theorem (#298)
and the certificate-overlap sampler (#300).

Every theorem is for a finite coordinate set and a common finite alphabet.
The mass weights need only be strictly positive. They become probabilities
if the coordinate mass tables are normalized.

There is no claim here that the probability-theoretic posterior Hoeffding
decomposition, recursive adaptive policy, or its MSE guarantee are certified.
-/

namespace Nightfall.ProductSpace.Observation

open Finset Nightfall.ProductSpace Nightfall.ProductSpace.Transfer
  Nightfall.ProductSpace.Discovery

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def positiveClassValue (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ) : ℝ :=
  ∑ x : {x : ι → α // g x = true},
    prodMass p x.1 * invCost (lam x.1)

noncomputable def negativeClassValue (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ) : ℝ :=
  ∑ y : {y : ι → α // g y = false},
    prodMass p y.1 * invCost (lam y.1)

noncomputable def positiveLoad (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ) (j : ι) : ℝ :=
  ∑ x : {x : ι → α // g x = true},
    prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j

noncomputable def negativeLoad (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ) (j : ι) : ℝ :=
  ∑ y : {y : ι → α // g y = false},
    prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j

noncomputable def crossingMass (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (j : ι) : ℝ :=
  ∑ z, pairMass p z * edgeCross g j z

/-- The positive class-coordinate loads sum to the positive inverse-cost mass,
provided that all rows have positive total cost. -/
theorem positive_load_total (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hnorm : ∀ x, 0 < ∑ j, lam x j) :
    (∑ j, positiveLoad p g lam j) = positiveClassValue p g lam := by
  unfold positiveLoad positiveClassValue
  exact mass_load_sum
    (fun x : {x : ι → α // g x = true} => prodMass p x.1)
    (fun x j => lam x.1 j) (fun x => hnorm x.1)

/-- The corresponding load identity for the negative output class. -/
theorem negative_load_total (p : ι → α → ℝ)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hnorm : ∀ x, 0 < ∑ j, lam x j) :
    (∑ j, negativeLoad p g lam j) = negativeClassValue p g lam := by
  unfold negativeLoad negativeClassValue
  exact mass_load_sum
    (fun y : {y : ι → α // g y = false} => prodMass p y.1)
    (fun y j => lam y.1 j) (fun y => hnorm y.1)

/-- A nonconstant Boolean function with globally valid fractional
certificate rows automatically has positive cost on every input. -/
theorem row_cost_pos_of_two_classes
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (hone : ∃ x, g x = true) (hzero : ∃ x, g x = false) :
    ∀ x, 0 < ∑ j, lam x j := by
  intro x
  have hopposite : ∃ y, g y ≠ g x := by
    cases hx : g x with
    | false =>
      obtain ⟨y, hy⟩ := hone
      exact ⟨y, by simp [hy, hx]⟩
    | true =>
      obtain ⟨y, hy⟩ := hzero
      exact ⟨y, by simp [hy, hx]⟩
  obtain ⟨y, hdiff⟩ := hopposite
  have hcert := hrow.2 x y hdiff
  have hsub : (∑ j ∈ disagree x y, lam x j) ≤ ∑ j, lam x j := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    intro j _ _
    exact hrow.1 x j
  linarith

/-- **Concrete finite-product observation sampler.** All localized inequality
premises are discharged by the pinned antipodal->product theorem. Only the
row-cost positivity and positive class masses are needed for the sampler
normalization. The latter follow from positive masses for nonconstant g. -/
theorem finite_product_certificate_sampler
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (hV : 0 < positiveClassValue p g lam * negativeClassValue p g lam) :
    0 < ∑ j, Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) ∧
    (positiveClassValue p g lam * negativeClassValue p g lam) ^ 2 ≤
      (∑ j, Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j)) ^ 2 *
      (∑ j,
        (Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) /
        (∑ k, Real.sqrt (positiveLoad p g lam k * negativeLoad p g lam k))) *
        crossingMass p g j) ∧
    positiveClassValue p g lam * negativeClassValue p g lam ≤
      ∑ j,
        (Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) /
        (∑ k, Real.sqrt (positiveLoad p g lam k * negativeLoad p g lam k))) *
        crossingMass p g j := by
  have hC : ∀ j, 0 ≤ crossingMass p g j := by
    intro j
    unfold crossingMass
    exact Finset.sum_nonneg (fun z _ =>
      mul_nonneg (pairMass_nonneg p (fun i a => (hp i a).le) z)
        (edgeCross_nonneg g j z))
  have hP : ∀ j, 0 ≤ positiveLoad p g lam j := by
    intro j
    unfold positiveLoad
    exact Finset.sum_nonneg (fun x _ =>
      mul_nonneg
        (mul_nonneg (prodMass_pos p hp x.1).le (sq_nonneg _))
        (hrow.1 x.1 j))
  have hQ : ∀ j, 0 ≤ negativeLoad p g lam j := by
    intro j
    unfold negativeLoad
    exact Finset.sum_nonneg (fun y _ =>
      mul_nonneg
        (mul_nonneg (prodMass_pos p hp y.1).le (sq_nonneg _))
        (hrow.1 y.1 j))
  have hloc :
    positiveClassValue p g lam * negativeClassValue p g lam ≤
      ∑ j, Real.sqrt (crossingMass p g j) *
        Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) := by
    unfold positiveClassValue negativeClassValue crossingMass
      positiveLoad negativeLoad
    exact localized_two_sided_product p hp g lam hrow
  exact certificate_overlap_sampler
    (crossingMass p g) (positiveLoad p g lam) (negativeLoad p g lam)
    (positiveClassValue p g lam) (negativeClassValue p g lam)
    hC hP hQ (positive_load_total p g lam hnorm)
    (negative_load_total p g lam hnorm) hV hloc

end Nightfall.ProductSpace.Observation
