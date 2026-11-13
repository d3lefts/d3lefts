import ActualESOwnedSourceCover

/-!
# Actual-source pair energy and greedy ownership

The energy of an edge is the literal finite product-law squared L2 norm
of its canonical Efron–Stein pair kernel. Owned edges form a disjoint
partition, so the sum of owned energies equals the sum of genuine
source pair energies *exactly*, not merely approximately. Endpoint
costs and injective owned-neighbor maps are built from the actual
source in ActualESOwnedSourceCover.

This module does not identify the pair-energy sum with pvar or pinfl;
those are separate ANOVA orthogonality and conditional-expectation
identities. It does not label this equality as the terminal Q2 theorem.
-/

namespace Nightfall.Observability.ActualESOwnedEnergy

open Finset
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESOwnedSourceCover

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The genuine squared Hilbert L2 energy of an actual source pair
kernel. Its two weights are exactly the two original input marginals. -/
noncomputable def sourcePairEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α) (i j : ι) : ℝ :=
  ∑ a : α, ∑ b : α,
    p i a * p j b *
      (actualPairKernel p f base i j a b)^2

theorem sourcePairEnergy_nonneg
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i j : ι) :
    0 ≤ sourcePairEnergy p f base i j := by
  unfold sourcePairEnergy
  apply Finset.sum_nonneg
  intro a _
  apply Finset.sum_nonneg
  intro b _
  exact mul_nonneg
    (mul_nonneg (hp i a) (hp j b))
    (sq_nonneg _)

/-- Energy of all edges assigned by the greedy cover to source site i. -/
noncomputable def ownedSourceEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α)
    (u v : E → ι) (c : ι → ℝ) (T : Finset E) (i : ι) : ℝ :=
  (ownedEdges u v c T i).sum
    (fun e => sourcePairEnergy p f base (u e) (v e))

theorem ownedSourceEnergy_nonneg
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (base : ι → α)
    (u v : E → ι) (c : ι → ℝ) (T : Finset E)
    (i : ι) :
    0 ≤ ownedSourceEnergy p f base u v c T i := by
  unfold ownedSourceEnergy
  exact Finset.sum_nonneg
    (fun e _ => sourcePairEnergy_nonneg p hp f base (u e) (v e))

/-- Exact partition of real source-component energies.
No energy budget is supplied in this statement. -/
theorem actual_source_owned_energy_partition
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α)
    (u v : E → ι) (c : ι → ℝ) (T : Finset E) :
    (∑ i : ι, ownedSourceEnergy p f base u v c T i) =
      T.sum (fun e => sourcePairEnergy p f base (u e) (v e)) := by
  exact owned_energy_partition u v c T
    (fun e => sourcePairEnergy p f base (u e) (v e))

/-- Actual-source generated greedy costs plus an EXACT decomposition
of the source pair energies. The source-level conditional Jensen and
influence/variance identities remain separate obligations. -/
theorem actual_source_owned_energy_and_distinct_neighbors
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (T : Finset E)
    (hends : ∀ e ∈ T, u e ≠ v e)
    (hSimple : ∀ e ∈ T, ∀ d ∈ T,
      ({u e, v e} : Finset ι) = {u d, v d} → e = d)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i e, e ∈ ownedEdges u v c T i →
        ∀ s t : α,
          |actualPairKernel p f base (u e) (v e) s t| ≤ c i) ∧
      (∀ i, Set.InjOn (other u v c)
        (↑(ownedEdges u v c T i) : Set E)) ∧
      (∀ i e, e ∈ ownedEdges u v c T i →
        i ≠ other u v c e) ∧
      (∀ i, 0 ≤ ownedSourceEnergy p f base u v c T i) ∧
      ((∑ i : ι, ownedSourceEnergy p f base u v c T i) =
          T.sum (fun e => sourcePairEnergy p f base (u e) (v e))) := by
  classical
  obtain ⟨c, hc, htotal, hamp, hinj, hne, _⟩ :=
    actual_source_owned_distinct_neighbors
      p hp hp1 f hdegree base u v T hends hSimple B hf
  refine ⟨c, hc, htotal, hamp, hinj, hne, ?_, ?_⟩
  · intro i
    exact ownedSourceEnergy_nonneg p hp f base u v c T i
  · exact actual_source_owned_energy_partition p f base u v c T

end Nightfall.Observability.ActualESOwnedEnergy
