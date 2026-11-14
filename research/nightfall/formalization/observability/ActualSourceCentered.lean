import ActualProductResampleBridge

/-!
# Canonical source centering, original-product conditional expectation
Active Lean 4.36 port of source-centered Efron-Stein subset Möbius
components in legacy #424. No independentness axiom, no atom floor,
no energy or Q2 premise.
-/
namespace Nightfall.Observability.ActualSourceCentered
open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualProductMergeTower
variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

private theorem merge_update_pull (U : Finset ι) (i : ι) (hi : i ∈ U)
    (x y : ι → α) (a : α) :
    merge U (Function.update x i a) y =
      merge (U.erase i) x (Function.update y i a) := by
  funext k
  by_cases hik : k = i
  · subst k
    simp [merge, hi]
  · have hmem : k ∈ U.erase i ↔ k ∈ U := by simp [hik]
    by_cases hkU : k ∈ U
    · simp [merge, hkU, hmem.mpr hkU, Function.update_of_ne hik]
    · simp [merge, hkU, fun h => hkU (hmem.mp h), Function.update_of_ne hik]

/-- Integrating out a retained coordinate removes it from the
conditioning support, without assuming a positive atom floor. -/
theorem average_condExp_update_mem
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (U : Finset ι) (i : ι) (hi : i ∈ U)
    (x : ι → α) :
    (∑ a : α, p i a * condExp p U f (Function.update x i a)) =
      condExp p (U.erase i) f x := by
  unfold condExp
  calc
    (∑ a : α, p i a *
      (∑ y : ι → α, originalMass p y * f (merge U (Function.update x i a) y))) =
      ∑ a : α, ∑ y : ι → α,
        p i a * (originalMass p y * f (merge U (Function.update x i a) y)) := by
          simp_rw [Finset.mul_sum]
    _ = ∑ y : ι → α, ∑ a : α,
          originalMass p y * p i a * f (merge U (Function.update x i a) y) := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro y _
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = ∑ y : ι → α, ∑ a : α,
          originalMass p y * p i a *
            f (merge (U.erase i) x (Function.update y i a)) := by
          apply Finset.sum_congr rfl
          intro y _
          apply Finset.sum_congr rfl
          intro a _
          rw [merge_update_pull U i hi x y a]
    _ = ∑ y : ι → α, originalMass p y *
          (∑ a : α, p i a * f (merge (U.erase i) x (Function.update y i a))) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = ∑ y : ι → α, originalMass p y * f (merge (U.erase i) x y) :=
          actual_source_resample_sum p hp1 i (fun y => f (merge (U.erase i) x y))

/-- Average of any conditional expectation after a coordinate update:
the conditioning support contracts by erasure. -/
theorem average_condExp_update
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (U : Finset ι) (i : ι) (x : ι → α) :
    (∑ a : α, p i a * condExp p U f (Function.update x i a)) =
      condExp p (U.erase i) f x := by
  by_cases hi : i ∈ U
  · exact average_condExp_update_mem p hp1 f U i hi x
  · have hinv (a : α) :
        condExp p U f (Function.update x i a) = condExp p U f x := by
      apply condExp_dependsOn p U f
      intro k hk
      have hki : k ≠ i := by
        intro hki
        exact hi (hki ▸ hk)
      exact Function.update_of_ne hki a x
    calc
      (∑ a : α, p i a * condExp p U f (Function.update x i a)) =
          ∑ a : α, p i a * condExp p U f x := by
            apply Finset.sum_congr rfl
            intro a _
            rw [hinv]
      _ = (∑ a : α, p i a) * condExp p U f x := by rw [Finset.sum_mul]
      _ = condExp p (U.erase i) f x := by simp [hp1 i, hi]

private theorem toggle_erase (U : Finset ι) (i : ι) :
    (toggle i U).erase i = U.erase i := by
  unfold toggle
  by_cases hi : i ∈ U
  · simp [hi]
  · simp [hi]

/-- Actual Efron–Stein components of every order are centered in each
coordinate in their support. No separate kernel or centering premise. -/
theorem actual_esComp_centered
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (S : Finset ι) (i : ι)
    (hi : i ∈ S) (x : ι → α) :
    (∑ a : α, p i a * esComp p S f (Function.update x i a)) = 0 := by
  classical
  unfold esComp
  have hswap :
      (∑ a : α, p i a *
        (∑ U ∈ S.powerset,
          (-1 : ℝ) ^ (S.card - U.card) * condExp p U f (Function.update x i a))) =
      ∑ U ∈ S.powerset,
        (-1 : ℝ) ^ (S.card - U.card) *
          (∑ a : α, p i a * condExp p U f (Function.update x i a)) := by
    simp_rw [Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro U hU
    apply Finset.sum_congr rfl
    intro a _
    ring
  rw [hswap]
  simp_rw [average_condExp_update p hp1 f]
  apply sum_toggle_cancel S.powerset i
  · intro U hU
    exact Finset.mem_powerset.mpr
      (toggle_subset hi (Finset.mem_powerset.mp hU))
  · intro U hU
    have hUS : U ⊆ S := Finset.mem_powerset.mp hU
    have hTS : toggle i U ⊆ S := toggle_subset hi hUS
    have hc := toggle_card i U
    have hu : U.card ≤ S.card := Finset.card_le_card hUS
    have ht : (toggle i U).card ≤ S.card := Finset.card_le_card hTS
    have hsign :
        (-1 : ℝ) ^ (S.card - (toggle i U).card) =
          -(-1 : ℝ) ^ (S.card - U.card) := by
      exact neg_one_pow_flip (by omega)
    rw [toggle_erase, hsign]
    ring


end Nightfall.Observability.ActualSourceCentered
