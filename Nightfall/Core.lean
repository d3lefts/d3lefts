import Mathlib

/-!
# Shared finite-product vocabulary (migration interface)

These are source-law formulas, not a new axiom system. The legacy sources
remain canonical until explicit definitional/equivalence adapters show that
their original-source variance, influence, and Efron–Stein degree predicates
match these definitions. Such adapters are NOT proved here.
-/

namespace Nightfall.Core

/-- Heterogeneous finite coordinate laws, permitting zero-probability atoms. -/
structure FiniteProductLaw (ι α : Type) [Fintype α] where
  pmf : ι → α → ℝ
  nonneg : ∀ i a, 0 ≤ pmf i a
  normalize : ∀ i, (∑ a : α, pmf i a) = 1

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Weight of a word under the genuine product of its coordinate laws. -/
def productMass (p : FiniteProductLaw ι α) (x : ι → α) : ℝ :=
  ∏ i : ι, p.pmf i (x i)

/-- Original-law expectation. -/
def sourceMean (p : FiniteProductLaw ι α) (f : (ι → α) → ℝ) : ℝ :=
  ∑ x : ι → α, productMass p x * f x

/-- Original-law centered variance. -/
def sourceVariance (p : FiniteProductLaw ι α) (f : (ι → α) → ℝ) : ℝ :=
  ∑ x : ι → α, productMass p x * (f x - sourceMean p f)^2

/-- Original-law Efron–Stein influence, with the resampling factor 1/2. -/
def sourceInfluence (p : FiniteProductLaw ι α)
    (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  (1 / 2 : ℝ) * ∑ x : ι → α, ∑ b : α,
    productMass p x * p.pmf i b *
      (f x - f (Function.update x i b))^2

/-- One-coordinate heat-bath operator. -/
def heatBath (p : FiniteProductLaw ι α)
    (i : ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ b : α, p.pmf i b * f (Function.update x i b)

/-- One-coordinate Efron–Stein residual. -/
def residual (p : FiniteProductLaw ι α)
    (i : ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  f x - heatBath p i f x

/-- Candidate degree-at-most-two operator presentation. Equivalence to
legacy `ESDegreeLE p f 2` is an explicit UNPROVED adapter obligation. -/
def degreeLETwoByResidual (p : FiniteProductLaw ι α)
    (f : (ι → α) → ℝ) : Prop :=
  ∀ i j k : ι, i ≠ j → i ≠ k → j ≠ k →
    ∀ x : ι → α,
      residual p i (residual p j (residual p k f)) x = 0

end Nightfall.Core
