import ActualESGreedyOwnership
import ActualESConditionalProjection
import ActualESConditionalJensen

/-!
# Generated greedy ownership -> actual product conditional sections

The neighbor set is the image of the owned-edge Finset under the true
opposite-coordinate map.  The source conditionals retain these actual
coordinates, not a synthetic list with possible collisions.

This module proves a source conditional expectation identity, true
Hilbert-norm Jensen for the owned neighbor set, and an exact partition
of original-product Efron–Stein pair energies. It does NOT yet identify
owned pair energies with the squared norm of the source section; that is
the remaining ANOVA + independent-neighbor moment obligation.
-/

namespace Nightfall.Observability.ActualESOwnedConditional

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESConditionalSection
open Nightfall.Observability.ActualESConditionalJensen

variable {E ι α : Type}
    [Fintype E] [DecidableEq E]
    [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]

/-- Genuine distinct source neighbor set selected by the greedy owner. -/
noncomputable def ownedNeighbors
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E) (i : ι) : Finset ι :=
  (ownedEdges u v c T i).image (other u v c)

/-- No greedy owner is included in its own selected neighbor set. -/
theorem ownedNeighbors_avoid_owner
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E)
    (hends : ∀ e ∈ T, u e ≠ v e)
    (i : ι) :
    i ∉ ownedNeighbors u v c T i := by
  classical
  intro hi
  obtain ⟨e, he, hother⟩ := Finset.mem_image.mp hi
  have hne := owned_neighbor_ne_owner u v c T hends i e he
  exact hne hother.symm

/-- Greedy-generated source projection is an exact difference of true
Efron–Stein conditional expectations. No section equality is assumed. -/
theorem actual_greedy_owned_section_eq_condExp
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E)
    (hends : ∀ e ∈ T, u e ≠ v e)
    (i : ι) (x : ι → α) (a : α) :
    averageSourceSection p f i (ownedNeighbors u v c T i) x a =
      condExp p (insert i (ownedNeighbors u v c T i))
        f (Function.update x i a) -
      condExp p (ownedNeighbors u v c T i) f x := by
  exact average_source_section_eq_condExp_difference
    p hp1 f i (ownedNeighbors u v c T i)
    (ownedNeighbors_avoid_owner u v c T hends i) x a

/-- The actual source's conditional Jensen bound holds for each set of
owned neighbors generated from the original graph. -/
theorem actual_greedy_owned_section_jensen
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E) (i : ι) (x : ι → α) :
    norm (p i)
      (fun a => averageSourceSection p f i
        (ownedNeighbors u v c T i) x a) ≤
      ∑ y : ι → α, prodMass p y *
        norm (p i)
          (sourceSection p f i
            (merge (ownedNeighbors u v c T i) x y)) := by
  exact actual_source_section_hilbert_jensen
    p hp f i (ownedNeighbors u v c T i) x

/-- Actual original-product pair energy, not an external edge weight
or a synthetic-moment oracle. -/
noncomputable def actualPairEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (u v : E → ι) (e : E) : ℝ :=
  ∑ x : ι → α, prodMass p x *
    (esComp p ({u e, v e} : Finset ι) f x)^2

/-- Each original-source pair energy appears at exactly one endpoint,
because the source graph's edge set is partitioned by greedy ownership. -/
theorem actual_owned_pair_energy_partition
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ) (T : Finset E) :
    (∑ i : ι, (ownedEdges u v c T i).sum
      (actualPairEnergy p f u v)) =
    T.sum (actualPairEnergy p f u v) := by
  exact owned_energy_partition u v c T (actualPairEnergy p f u v)

end Nightfall.Observability.ActualESOwnedConditional
