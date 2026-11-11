import VariancePosteriorOneStep

/-!
# Actual scalar and finite-Hilbert squared-resampling posterior descent

This upgrades the pre-existing concrete Boolean crossing-potential posterior
certificate (#303/#312) to the actual squared coordinate-resampling energy
of arbitrary real scalar or finite-dimensional real-Hilbert-valued observables.

No Hoeffding-degree, magnitude or matching assumptions are required for
this *one-step exact identity*.  Degree two and the influence lower bound
enter separately when deriving a deterministic adaptive query budget.

The posterior definition uses the first draw's observation X_j=a and
the fresh second draw's resampling coordinate; normalization is secured by
the assumed strictly positive, normalized product masses.  The coordinate
being revealed is explicitly excluded from the remaining total.
-/

namespace Nightfall.ProductSpace.RealPosterior

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Posterior

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Genuine squared scalar replacement difference on two product draws.
The one-half factor makes the expectation equal E|f-E_j f|². -/
noncomputable def scalarEdgeSq (f : (ι → α) → ℝ)
    (j : ι) (z : PairSample ι α) : ℝ :=
  (f z.1 - f (replaceFromSecond z j)) ^ 2 / 2

/-- The actual squared-resampling influence of coordinate j. -/
noncomputable def scalarInfluence (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (j : ι) : ℝ :=
  ∑ z : PairSample ι α, pairMass p z * scalarEdgeSq f j z

/-- Remaining total scalar squared influences after observing X_j=a. -/
noncomputable def scalarPosteriorTotal (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (j : ι) (a : α) : ℝ :=
  ∑ k : ι, posteriorEdge
    (pairMass p)
    (fun z : PairSample ι α => z.1 j)
    (p j) (scalarEdgeSq f) j a k

/-- Actual scalar finite-product posterior identity, not an abstract table.
Requires only positive normalized heterogeneous coordinate laws. -/
theorem scalar_actual_posterior_total_mean
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (_hprob : ∀ i, (∑ a, p i a) = 1)
    (f : (ι → α) → ℝ) (j : ι) :
    (∑ a : α, p j a * scalarPosteriorTotal p f j a) =
       (∑ k : ι, scalarInfluence p f k) - scalarInfluence p f j := by
  unfold scalarPosteriorTotal scalarInfluence
  exact posterior_total_mean
    (pairMass p)
    (fun z : PairSample ι α => z.1 j)
    (p j)
    (fun a => hp j a)
    (scalarEdgeSq f) j

/-- The actual squared Euclidean replacement norm for arbitrary output rank.
Finite-dimensional real Hilbert outputs are represented by their components. -/
noncomputable def vectorEdgeSq {κ : Type} [Fintype κ]
    (F : (ι → α) → κ → ℝ) (j : ι) (z : PairSample ι α) : ℝ :=
  (∑ t : κ, (F z.1 t - F (replaceFromSecond z j) t) ^ 2) / 2

/-- Actual squared vector influence of coordinate j. -/
noncomputable def vectorInfluence {κ : Type} [Fintype κ]
    (p : ι → α → ℝ) (F : (ι → α) → κ → ℝ) (j : ι) : ℝ :=
  ∑ z : PairSample ι α, pairMass p z * vectorEdgeSq F j z

/-- Actual remaining sum of vector squared influences after X_j=a. -/
noncomputable def vectorPosteriorTotal {κ : Type} [Fintype κ]
    (p : ι → α → ℝ) (F : (ι → α) → κ → ℝ)
    (j : ι) (a : α) : ℝ :=
  ∑ k : ι, posteriorEdge
    (pairMass p)
    (fun z : PairSample ι α => z.1 j)
    (p j) (vectorEdgeSq F) j a k

/-- Actual finite-rank real-Hilbert posterior squared-influence descent.
No fair input law, common bias, or output-symmetry restriction. -/
theorem vector_actual_posterior_total_mean
    {κ : Type} [Fintype κ]
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (_hprob : ∀ i, (∑ a, p i a) = 1)
    (F : (ι → α) → κ → ℝ) (j : ι) :
    (∑ a : α, p j a * vectorPosteriorTotal p F j a) =
       (∑ k : ι, vectorInfluence p F k) - vectorInfluence p F j := by
  unfold vectorPosteriorTotal vectorInfluence
  exact posterior_total_mean
    (pairMass p)
    (fun z : PairSample ι α => z.1 j)
    (p j)
    (fun a => hp j a)
    (vectorEdgeSq F) j

end Nightfall.ProductSpace.RealPosterior
