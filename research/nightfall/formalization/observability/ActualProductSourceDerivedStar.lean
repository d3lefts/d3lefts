import ActualProductSourcePairCentering
import ActualProductSoftStar
import ActualProductSoftStarParseval

/-!
# Direct source-derived singleton + pair star for Q2

This binds the strict-compiled star eigenaction and weighted L2 energy
to tables derived from one literal source function f. In particular,
no arbitrary separately centered star is supplied by the caller.

IMPORTANT: this does not yet prove f equals its derived degree-two
singleton/pair decomposition, derive matching weights, or establish
the quantitative fourth moment. It is NOT the terminal Q2 theorem.
-/

namespace Nightfall.Observability.ActualProductSourceDerivedStar

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSoftStar
open Nightfall.Observability.ActualProductSoftStarParseval
open Nightfall.Observability.ActualProductSourcePairCentering

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Raw original-law one-site projection from an arbitrary f. -/
noncomputable def sourceOneSiteTable
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (a : α) : ℝ :=
  ∑ y : ι → α, originalMass p y *
    f (Function.update y i a)

/-- Genuine product-source singleton table, centered without
postulating any source mean or conditional expectation axiom. -/
noncomputable def sourceCenteredSingleton
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (a : α) : ℝ :=
  sourceOneSiteTable p f i a -
    ∑ b : α, p i b * sourceOneSiteTable p f i b

/-- Algebraic original-source singleton centering holds even for
zero-atom symbols; no positivity assumption is needed for this
finite mass identity. -/
theorem actual_source_derived_singleton_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    (∑ a : α, p i a * sourceCenteredSingleton p f i a) = 0 := by
  classical
  unfold sourceCenteredSingleton
  calc
    (∑ a : α, p i a * (sourceOneSiteTable p f i a -
      ∑ b : α, p i b * sourceOneSiteTable p f i b)) =
    (∑ a : α, p i a * sourceOneSiteTable p f i a) -
      (∑ a : α, p i a) *
        (∑ b : α, p i b * sourceOneSiteTable p f i b) := by
          simp only [mul_sub, Finset.sum_sub_distrib, ← Finset.sum_mul]
    _ = 0 := by rw [hp1 i]; ring

/-- The **complete soft-star spectral identity** with every singleton
and pair table extracted directly from one actual source f.
Degree-two representation is not supplied or asserted in this lemma:
the output is the spectral identity for the source-derived star. -/
theorem actual_source_derived_soft_star_eigen
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (retain : ι → ℝ)
    (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) :
    softSourceNoise p retain
      (fun z : ι → α =>
        sourceCenteredSingleton p f i (z i) +
          ∑ j : ι, if j = i then 0 else
            sourceDoubleCenteredPair p f i j (z i) (z j)) x =
      retain i * sourceCenteredSingleton p f i (x i) +
        ∑ j : ι, if j = i then 0 else
          (retain i * retain j) *
            sourceDoubleCenteredPair p f i j (x i) (x j) := by
  classical
  exact actual_soft_noise_centered_star_eigen
    p hp1 retain i
    (sourceCenteredSingleton p f i)
    (actual_source_derived_singleton_centered p hp1 f i)
    (fun j => sourceDoubleCenteredPair p f i j)
    (fun j _ b => actual_source_derived_pair_first_centered p hp1 f i j b)
    (fun j _ a => actual_source_derived_pair_second_centered p hp1 f i j a)
    x

/-- **Exact weighted star energy from the original f itself**, with
no input pair-kernel centering or energy certificate. The source
coordinates remain distinct even for overlapping stars across i. -/
theorem actual_source_derived_weighted_star_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (w : ι → ℝ) :
    (∑ x : ι → α, originalMass p x *
      (∑ j : ι, if j = i then 0 else
        w j * sourceDoubleCenteredPair p f i j (x i) (x j))^2) =
    ∑ j : ι, if j = i then 0 else
      (w j)^2 *
        (∑ a : α, ∑ b : α,
          p i a * p j b *
            (sourceDoubleCenteredPair p f i j a b)^2) := by
  classical
  exact actual_source_weighted_centered_star_energy
    p hp1 i w (fun j => sourceDoubleCenteredPair p f i j)
    (fun j _ a => actual_source_derived_pair_second_centered p hp1 f i j a)

end Nightfall.Observability.ActualProductSourceDerivedStar
