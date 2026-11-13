import ActualESOwnedSecondMoment
import ActualESInfluenceEnergy

/-!
# Q2 genuine owned-pair energy bounded by actual source influence

The exact owned-pair L2 energy is a **subset** of those canonical
Efron–Stein energies involving its owner. No user-supplied energy cap
is permitted. Input graph simple = an injective labeling of each
unordered source pair. This hypothesis is satisfied automatically by
the canonical graph of 2-element source-coordinate subsets.

This is finite product source mathematics under the historical
Efron–Stein Lean source pin; NOT terminal Q2.
-/

namespace Nightfall.Observability.ActualESOwnedInfluenceBound

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESOwnedSecondMoment
open Nightfall.Observability.ActualESInfluenceEnergy

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Weighted source pair energies owned by i form a positive subset
of all canonical interactions contributing to pinfl(p,f,i).
No bound is a premise; source independence/orthogonality are supplied
by the original-source influence Parseval theorem. -/
theorem source_owned_pair_energy_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ) (T : Finset E)
    (hSimple : ∀ e d : E,
      ({u e, v e} : Finset ι) =
      {u d, v d} → e = d)
    (i : ι) :
    (ownedEdges u v c T i).sum
      (fun e => ∑ x : ι → α, prodMass p x *
        (esComp p ({u e, v e} : Finset ι) f x)^2) ≤
      pinfl p f i := by
  classical
  let F : Finset E := ownedEdges u v c T i
  let q : E → Finset ι := fun e => {u e,v e}
  let P : Finset (Finset ι) := F.image q
  let en : Finset ι → ℝ := fun S =>
    ∑ x : ι → α, prodMass p x * (esComp p S f x)^2
  have hen (S : Finset ι) : 0 ≤ en S := by
    dsimp [en]
    apply Finset.sum_nonneg
    intro x _
    exact mul_nonneg (prodMass_nonneg' p hp x) (sq_nonneg _)
  have hinj : Set.InjOn q (↑F : Set E) := by
    intro e he d hd heq
    exact hSimple e d heq
  have hsum : F.sum (fun e => en (q e)) = P.sum en := by
    exact (Finset.sum_image (s := F) (f := q)
      (g := en) (fun e he d hd heq => hinj he hd heq)).symm
  have hsub : P ⊆ Finset.univ.filter (fun S : Finset ι => i ∈ S) := by
    intro S hS
    obtain ⟨e, he, rfl⟩ := Finset.mem_image.mp hS
    have heowner : owner u v c e = i :=
      (Finset.mem_filter.mp he).2
    apply Finset.mem_filter.mpr
    constructor
    · exact Finset.mem_univ _
    change i ∈ q e
    dsimp [q]
    rw [endpoints_eq_owner_other u v c e, heowner]
    simp
  have hsmall :
      P.sum en ≤
      (Finset.univ.filter (fun S : Finset ι => i ∈ S)).sum en :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub
      (fun S hS hnot => hen S)
  have htotal :
      (Finset.univ.filter (fun S : Finset ι => i ∈ S)).sum en =
      pinfl p f i := by
    have h := actual_source_influence_eq_interaction_energy p hp1 f i
    simpa [Finset.sum_filter, en] using h.symm
  change F.sum (fun e => en (q e)) ≤ pinfl p f i
  calc
    F.sum (fun e => en (q e)) = P.sum en := hsum
    _ ≤ (Finset.univ.filter (fun S : Finset ι => i ∈ S)).sum en := hsmall
    _ = pinfl p f i := htotal

/-- The source-indexed actual product second moment for all greedy
owned neighbors is bounded by the original coordinate influence.
No moment2 cap or energy equality appears in the assumptions.
-/
theorem actual_owned_second_moment_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ) (T : Finset E)
    (hSimple : ∀ e d : E,
      ({u e, v e} : Finset ι) =
      {u d, v d} → e = d)
    (i : ι) :
    ownedSourceMoment2 p f u v c T i ≤ pinfl p f i := by
  rw [ownedSourceMoment2_eq_pair_energy
    p hp1 f u v c T hSimple i]
  exact source_owned_pair_energy_le_influence
    p hp hp1 f u v c T hSimple i

end Nightfall.Observability.ActualESOwnedInfluenceBound
