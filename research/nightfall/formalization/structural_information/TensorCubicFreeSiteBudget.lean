import SubcubeL3

/-!
# Conditional free-site reduction and 2x2 binary matrix source

This module formalizes only the finite counting/arithmetic bridge behind
the all-frequency cubic tensor primitive-lift paper theorem:
* every 2x2 binary tensor has original-row length at most two;
* if a minimal circuit spends at least s-1 reference variation sites
  and has LP support size at most s+t-2, then at most t-1 sites are new;
* disjoint circuit blocks consuming at most four new rows leave at most
  three freely variable sites in total.

The full minimum-reference variation lemma at arbitrary depth, source
identification of Lovitz-Petrov, and quantum Hilbert theorem are **not**
proved or introduced as Lean axioms here.
-/

namespace Nightfall.StructuralInformation.TensorCubicFreeSiteBudget

open Nightfall.StructuralInformation.SubcubeL3

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

/-- All 16 binary 2x2 matrices can be written as zero, one, or two
    of the actual tensor-subcube rank-one rows of level two. -/
theorem all_two_factor_tensors_use_at_most_two_rows :
    ∀ z : Fin 16,
      z.val = 0 ∨ z.val ∈ rows2 ∨
      ∃ a ∈ rows2, ∃ b ∈ rows2, Nat.xor a b = z.val := by
  decide

/-- The per-circuit site inequality with both external mathematical inputs
    clearly visible as hypotheses; no unproved LP axiom is added. -/
theorem extra_site_le_new_rows
    {Site : Type*} [DecidableEq Site]
    (F S : Finset Site) (s t : ℕ)
    (hFS : F ⊆ S)
    (hmin : s ≤ F.card + 1)
    (hLP : S.card + 2 ≤ s + t) :
    (S \ F).card + 1 ≤ t := by
  classical
  have hd : Disjoint F (S \ F) := by
    apply Finset.disjoint_left.mpr
    intro x hxF hxD
    exact (Finset.mem_sdiff.mp hxD).2 hxF
  have hu : F ∪ (S \ F) = S := by
    ext x
    constructor
    · intro hx
      rcases Finset.mem_union.mp hx with hf | hs
      · exact hFS hf
      · exact (Finset.mem_sdiff.mp hs).1
    · intro hs
      by_cases hf : x ∈ F
      · exact Finset.mem_union.mpr (Or.inl hf)
      · exact Finset.mem_union.mpr
          (Or.inr (Finset.mem_sdiff.mpr ⟨hs, hf⟩))
  have hcard : F.card + (S \ F).card = S.card := by
    have h := Finset.card_union_of_disjoint hd
    rw [hu] at h
    omega
  omega

/-- The key cubic transition: any nonempty family of disjoint zero-circuit
    blocks with at most four alternative-row occurrences has <=3 freely
    varying sites, assuming the reference-variation and published LP caps. -/
theorem at_most_three_freely_varying_sites
    {I Site : Type*} [DecidableEq Site]
    (circuits : Finset I)
    (active forced : I → Finset Site)
    (referenceCount newCount : I → ℕ)
    (hne : circuits.Nonempty)
    (hsubset : ∀ i ∈ circuits, forced i ⊆ active i)
    (hmin : ∀ i ∈ circuits, referenceCount i ≤ (forced i).card + 1)
    (hLP : ∀ i ∈ circuits,
      (active i).card + 2 ≤ referenceCount i + newCount i)
    (hnew : (∑ i ∈ circuits, newCount i) ≤ 4) :
    (circuits.biUnion (fun i => active i \ forced i)).card ≤ 3 := by
  classical
  have hcost : ∀ i ∈ circuits,
      ((active i \ forced i).card + 1) ≤ newCount i := by
    intro i hi
    exact extra_site_le_new_rows (forced i) (active i)
      (referenceCount i) (newCount i)
      (hsubset i hi) (hmin i hi) (hLP i hi)
  have hunion : (circuits.biUnion (fun i =>
       active i \ forced i)).card ≤
       ∑ i ∈ circuits, (active i \ forced i).card :=
    Finset.card_biUnion_le
  have hsum : (∑ i ∈ circuits, ((active i \ forced i).card + 1)) ≤
       ∑ i ∈ circuits, newCount i :=
    Finset.sum_le_sum hcost
  have hsum' :
      (∑ i ∈ circuits, ((active i \ forced i).card + 1)) =
      (∑ i ∈ circuits, (active i \ forced i).card) +
        circuits.card := by
    simp [Finset.sum_add_distrib]
  have hcard : 0 < circuits.card := Finset.card_pos.mpr hne
  omega

#print axioms Nightfall.StructuralInformation.TensorCubicFreeSiteBudget.all_two_factor_tensors_use_at_most_two_rows
#print axioms Nightfall.StructuralInformation.TensorCubicFreeSiteBudget.extra_site_le_new_rows
#print axioms Nightfall.StructuralInformation.TensorCubicFreeSiteBudget.at_most_three_freely_varying_sites

end Nightfall.StructuralInformation.TensorCubicFreeSiteBudget
