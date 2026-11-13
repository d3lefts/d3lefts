import Mathlib

/-!
# Exact greedy owner/neighbor indexing

A weighted graph edge is assigned to its larger-cost endpoint. Each
edge is assigned exactly once, every owner covers its edge amplitude,
and for a simple undirected graph the opposite endpoints at a fixed
owner are pairwise distinct. This last property is the independence
precondition for applying the existing source Hilbert fourth-moment
certificate; it is NOT inferred from a merely surjective neighbor map.

No probability, influence or moment inequality is assumed here.
-/

namespace Nightfall.Observability.ActualESGreedyOwnership

open Finset

variable {E ι : Type*} [DecidableEq E] [Fintype E]
  [DecidableEq ι] [Fintype ι]

/-- Choose the endpoint with the larger generated greedy-cover cost. -/
noncomputable def owner (u v : E → ι) (c : ι → ℝ) (e : E) : ι :=
  if c (v e) ≤ c (u e) then u e else v e

/-- The opposite neighbor of the owned edge. -/
noncomputable def other (u v : E → ι) (c : ι → ℝ) (e : E) : ι :=
  if c (v e) ≤ c (u e) then v e else u e

/-- Every retained edge has one and only one assigned owner. -/
noncomputable def ownedEdges (u v : E → ι) (c : ι → ℝ)
    (T : Finset E) (i : ι) : Finset E :=
  T.filter (fun e => owner u v c e = i)

/-- The owner inherits the larger endpoint cost. -/
theorem owner_cost_dominates
    (u v : E → ι) (c : ι → ℝ) (e : E) (w : ℝ)
    (hw : w ≤ max (c (u e)) (c (v e))) :
    w ≤ c (owner u v c e) := by
  classical
  by_cases h : c (v e) ≤ c (u e)
  · simpa [owner, h, max_eq_left h] using hw
  · have h' : c (u e) ≤ c (v e) := le_of_lt (lt_of_not_ge h)
    simpa [owner, h, max_eq_right h'] using hw

/-- Exact finite-sum partition: no interaction is discarded or counted twice. -/
theorem owned_energy_partition
    (u v : E → ι) (c : ι → ℝ) (T : Finset E)
    (energy : E → ℝ) :
    (∑ i : ι, (ownedEdges u v c T i).sum energy) =
      T.sum energy := by
  classical
  calc
    (∑ i : ι, (ownedEdges u v c T i).sum energy) =
        ∑ i : ι, ∑ e ∈ T,
          if owner u v c e = i then energy e else 0 := by
            simp only [ownedEdges, Finset.sum_filter]
    _ = ∑ e ∈ T, ∑ i : ι,
          if owner u v c e = i then energy e else 0 := by
            rw [Finset.sum_comm]
    _ = T.sum energy := by
          apply Finset.sum_congr rfl
          intro e _
          simp

/-- Any edge is the unordered pair of its owner and its other endpoint. -/
theorem endpoints_eq_owner_other
    (u v : E → ι) (c : ι → ℝ) (e : E) :
    ({u e, v e} : Finset ι) =
      {owner u v c e, other u v c e} := by
  classical
  by_cases h : c (v e) ≤ c (u e)
  · simp [owner, other, h]
  · simp [owner, other, h, Finset.pair_comm]

/-- With distinct endpoints the owner never equals its neighbor. -/
theorem owner_ne_other
    (u v : E → ι) (c : ι → ℝ) (e : E)
    (hends : u e ≠ v e) :
    owner u v c e ≠ other u v c e := by
  classical
  by_cases h : c (v e) ≤ c (u e)
  · simpa [owner, other, h] using hends
  · simpa [owner, other, h] using hends.symm

/-- No parallel unordered edges means different edges assigned to
one owner have genuinely different source neighbors. -/
theorem other_injective_at_owner
    (u v : E → ι) (c : ι → ℝ) (T : Finset E)
    (hSimple : ∀ e ∈ T, ∀ f ∈ T,
      ({u e, v e} : Finset ι) = {u f, v f} → e = f)
    (i : ι) :
    Set.InjOn (other u v c)
      (↑(ownedEdges u v c T i) : Set E) := by
  intro e he f hf hneigh
  have he' := Finset.mem_filter.mp (show e ∈ ownedEdges u v c T i from he)
  have hf' := Finset.mem_filter.mp (show f ∈ ownedEdges u v c T i from hf)
  apply hSimple e he'.1 f hf'.1
  calc
    ({u e, v e} : Finset ι) =
        {owner u v c e, other u v c e} :=
          endpoints_eq_owner_other u v c e
    _ = {owner u v c f, other u v c f} := by
          rw [he'.2, hf'.2, hneigh]
    _ = ({u f, v f} : Finset ι) :=
          (endpoints_eq_owner_other u v c f).symm

/-- Every actual owned-neighbor index is different from its owner. -/
theorem owned_neighbor_ne_owner
    (u v : E → ι) (c : ι → ℝ) (T : Finset E)
    (hends : ∀ e ∈ T, u e ≠ v e)
    (i : ι) (e : E) (he : e ∈ ownedEdges u v c T i) :
    i ≠ other u v c e := by
  have he' := Finset.mem_filter.mp he
  rw [← he'.2]
  exact owner_ne_other u v c e (hends e he'.1)

/-- True source pair amplitudes are controlled at the chosen endpoint. -/
theorem owned_source_amplitude
    {α : Type*}
    (u v : E → ι) (c : ι → ℝ)
    (a : E → α → α → ℝ) (T : Finset E)
    (hcover : ∀ e ∈ T, ∀ s t,
      |a e s t| ≤ max (c (u e)) (c (v e)))
    (i : ι) (e : E) (he : e ∈ ownedEdges u v c T i)
    (s t : α) :
    |a e s t| ≤ c i := by
  have he' := Finset.mem_filter.mp he
  rw [← he'.2]
  exact owner_cost_dominates u v c e _ (hcover e he'.1 s t)

end Nightfall.Observability.ActualESGreedyOwnership
