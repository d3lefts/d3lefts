import ActualESGreedyCover
import ActualESGreedyOwnership

/-!
# End-to-end actual source -> simple-graph greedy ownership

There are NO supplied edge weights, rectangle witnesses, independent
increment tables, or matching-budget hypotheses. The source's pair
weights are maximized on the finite alphabet. Existing kernel-checked
source-matching and greedy-cover results construct c. Every interaction
is assigned exactly once to a covered endpoint. For a simple unordered
graph, its owned neighbors are injectively indexed original coordinates.

This is the graph/ownership interface for the moment-to-source
conditional-expectation bridge. It does NOT itself prove a variance
influence inequality. An input edge family must enumerate each actual
two-coordinate interaction exactly once for its energy partition to
coincide with the total Hoeffding pair energy.
-/

namespace Nightfall.Observability.ActualESOwnedSourceCover

open Finset
open Nightfall.Observability.ActualESGreedyCover
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESPairMatching

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- For a true finite source the maximum pair-kernel amplitude is
attained. This witness comes from an explicit finite-alphabet maximum. -/
theorem exists_actual_pair_amplitude_weights
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ)
    (base : ι → α)
    (u v : E → ι) :
    ∃ w : E → ℝ,
      (∀ e, ∃ s t : α,
        w e = |actualPairKernel p f base (u e) (v e) s t|) ∧
      (∀ e s t,
        |actualPairKernel p f base (u e) (v e) s t| ≤ w e) := by
  classical
  have hmax (e : E) :
      ∃ a b : α, ∀ s t : α,
        |actualPairKernel p f base (u e) (v e) s t| ≤
        |actualPairKernel p f base (u e) (v e) a b| := by
    have hnonempty :
        (Finset.univ : Finset (α × α)).Nonempty :=
      ⟨(Classical.choice inferInstance, Classical.choice inferInstance),
        Finset.mem_univ _⟩
    obtain ⟨pair, _, hbest⟩ := Finset.exists_max_image
      (Finset.univ : Finset (α × α))
      (fun pair : α × α =>
        |actualPairKernel p f base (u e) (v e) pair.1 pair.2|)
      hnonempty
    exact ⟨pair.1, pair.2, fun s t => hbest (s,t) (Finset.mem_univ _)⟩
  choose ma mb hmajor using hmax
  refine ⟨fun e => |actualPairKernel p f base (u e) (v e) (ma e) (mb e)|,
    ?_, ?_⟩
  · intro e
    exact ⟨ma e, mb e, rfl⟩
  · intro e s t
    exact hmajor e s t

/-- Structural source-level ownership with no supplied matching budget,
edge amplitude weights, rectangle or moment inequalities. The only
graph restriction is unique unordered edge labels; hence neighbors
owned by the same coordinate are genuinely distinct source sites. -/
theorem actual_source_owned_distinct_neighbors
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (T : Finset E)
    (hends : ∀ e ∈ T, u e ≠ v e)
    (hSimple : ∀ e ∈ T, ∀ f ∈ T,
      ({u e, v e} : Finset ι) = {u f, v f} → e = f)
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
      (∀ energy : E → ℝ,
        (∑ i : ι, (ownedEdges u v c T i).sum energy) =
          T.sum energy) := by
  classical
  obtain ⟨w, hwitness, hwmax⟩ :=
    exists_actual_pair_amplitude_weights p f base u v
  obtain ⟨c, hc, hcost, hcover⟩ :=
    actual_source_greedy_endpoint_cover
      p hp hp1 f hdegree base u v T hends w
      (fun e he => hwitness e)
      (fun e he s t => hwmax e s t)
      B hf
  refine ⟨c, hc, hcost, ?_, ?_, ?_, ?_⟩
  · intro i e he s t
    exact owned_source_amplitude u v c
      (fun e s t => actualPairKernel p f base (u e) (v e) s t)
      T hcover i e he s t
  · intro i
    exact other_injective_at_owner u v c T hSimple i
  · intro i e he
    exact owned_neighbor_ne_owner u v c T hends i e he
  · intro energy
    exact owned_energy_partition u v c T energy

end Nightfall.Observability.ActualESOwnedSourceCover
