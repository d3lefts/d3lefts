import QuadraticHoeffdingBridge
import CenteredRectangles

/-!
# Actual Efron–Stein pair kernels: source-to-matching bridge

Canonical kernels are extracted from the actual product function via
Efron–Stein conditional expectations. Averaging any nonempty interaction
component over one of its own coordinates gives zero. This is proved
from resampling invariance and a finite Mobius involution, not assumed
as a separate kernel hypothesis.

This is the canonical-degeneracy interface for the global matching
parity construction. It does not assert the unrestricted matching mass
bound or the terminal exponent-two influence theorem.
-/

namespace Nightfall.Observability.ActualESPairMatching

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer

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
      (∑ y : ι → α, prodMass p y * f (merge U (Function.update x i a) y))) =
      ∑ a : α, ∑ y : ι → α,
        p i a * (prodMass p y * f (merge U (Function.update x i a) y)) := by
          simp_rw [Finset.mul_sum]
    _ = ∑ y : ι → α, ∑ a : α,
          prodMass p y * p i a * f (merge U (Function.update x i a) y) := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro y _
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = ∑ y : ι → α, ∑ a : α,
          prodMass p y * p i a *
            f (merge (U.erase i) x (Function.update y i a)) := by
          apply Finset.sum_congr rfl
          intro y _
          apply Finset.sum_congr rfl
          intro a _
          rw [merge_update_pull U i hi x y a]
    _ = ∑ y : ι → α, prodMass p y * f (merge (U.erase i) x y) := by
          exact resample_sum p hp1 i (fun y => f (merge (U.erase i) x y))

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
      exact Function.update_of_ne (by
        intro hki
        subst k
        exact hi hk)
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
    rw [Finset.mul_sum]
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

/-- Slice a genuine pair component onto its two alphabet arguments.
All other coordinates are fixed at an arbitrary base configuration. -/
noncomputable def actualPairKernel
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α) (i j : ι) (a b : α) : ℝ :=
  esComp p ({i,j} : Finset ι) f
    (Function.update (Function.update base i a) j b)

/-- Every genuine pair component equals its source-derived slice on
the two indicated coordinate values, independent of unmatched sites. -/
theorem actual_pair_component_is_kernel
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base x : ι → α) (i j : ι) (hij : i ≠ j) :
    esComp p ({i,j} : Finset ι) f x =
      actualPairKernel p f base i j (x i) (x j) := by
  unfold actualPairKernel
  apply esComp_dependsOn p ({i,j} : Finset ι) f
  intro k hk
  have hk' : k = i ∨ k = j := by simpa using hk
  rcases hk' with rfl | rfl
  · simp [Function.update_of_ne hij.symm]
  · simp

/-- Source-derived pair kernel centered in its first argument. -/
theorem actual_pair_kernel_left_centered
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i j : ι) (hij : i ≠ j) (b : α) :
    (∑ a : α, p i a * actualPairKernel p f base i j a b) = 0 := by
  let x := Function.update base j b
  have hs :
      (∑ a : α, p i a * esComp p ({i,j} : Finset ι) f
        (Function.update x i a)) = 0 :=
      actual_esComp_centered p hp1 f {i,j} i (by simp) x
  convert hs using 1
  apply Finset.sum_congr rfl
  intro a _
  congr 1
  unfold actualPairKernel
  congr 1
  rw [Function.update_comm hij]

/-- Source-derived pair kernel centered in its second argument. -/
theorem actual_pair_kernel_right_centered
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i j : ι) (hij : i ≠ j) (a : α) :
    (∑ b : α, p j b * actualPairKernel p f base i j a b) = 0 := by
  let x := Function.update base i a
  have hs :
      (∑ b : α, p j b * esComp p ({i,j} : Finset ι) f
        (Function.update x j b)) = 0 :=
      actual_esComp_centered p hp1 f {i,j} j (by simp) x
  exact hs

/-- An actual source Efron–Stein interaction admits a positively oriented
four-corner rectangle dominating its absolute magnitude. This combines
the genuine conditional-expectation centering proved above with the
independently formalized finite weighted rectangle-extraction theorem.
No externally supplied centered kernel or rectangle witness is assumed. -/
theorem actual_pair_kernel_oriented_rectangle
    [Nonempty α]
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i j : ι) (hij : i ≠ j) (a b : α) :
    ∃ a0 a1 : α, ∃ b0 b1 : α,
      |actualPairKernel p f base i j a b| ≤
        actualPairKernel p f base i j a0 b0 -
        actualPairKernel p f base i j a0 b1 -
        actualPairKernel p f base i j a1 b0 +
        actualPairKernel p f base i j a1 b1 := by
  exact Nightfall.Observability.CenteredRectangles.exists_oriented_rectangle_dominating_abs
    (p i) (p j) (hp i) (hp j) (hp1 i) (hp1 j)
    (actualPairKernel p f base i j)
    (actual_pair_kernel_right_centered p hp1 f base i j hij)
    (actual_pair_kernel_left_centered p hp1 f base i j hij)
    a b


/-- Simultaneously select global amplitude witnesses and positively oriented
four-corner rectangles for every edge of ANY finite graph, with the
coefficients taken from the actual Efron–Stein components of f.

Unlike abstract matching input data, neither the kernels, their
centering, nor the orientations are assumed. Unmatched coordinates
are harmless by actual_pair_component_is_kernel.

This is exactly the source-to-rectangle interface for a subsequent
global parity bound; the 4B matching inequality still requires the
function-level parity/cancellation construction. -/
theorem actual_all_edges_oriented_rectangles
    {E : Type} [Fintype E] [Nonempty α]
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (u v : E → ι) (hne : ∀ e, u e ≠ v e) :
    ∃ a0 a1 b0 b1 : E → α,
      ∀ e : E, ∀ s t : α,
        |actualPairKernel p f base (u e) (v e) s t| ≤
          actualPairKernel p f base (u e) (v e) (a0 e) (b0 e) -
          actualPairKernel p f base (u e) (v e) (a0 e) (b1 e) -
          actualPairKernel p f base (u e) (v e) (a1 e) (b0 e) +
          actualPairKernel p f base (u e) (v e) (a1 e) (b1 e) := by
  classical
  have hmax (e : E) :
      ∃ a b : α, ∀ s t : α,
        |actualPairKernel p f base (u e) (v e) s t| ≤
        |actualPairKernel p f base (u e) (v e) a b| := by
    have hneα : (Finset.univ : Finset (α × α)).Nonempty :=
      ⟨(Classical.choice inferInstance, Classical.choice inferInstance),
        Finset.mem_univ _⟩
    obtain ⟨t, _, ht⟩ :=
      Finset.exists_max_image (Finset.univ : Finset (α × α))
        (fun t : α × α =>
          |actualPairKernel p f base (u e) (v e) t.1 t.2|) hneα
    refine ⟨t.1, t.2, ?_⟩
    intro s t'
    exact ht (s,t') (Finset.mem_univ _)
  choose ma mb hmajor using hmax
  have hrect (e : E) :
      ∃ a0 a1 : α, ∃ b0 b1 : α,
        |actualPairKernel p f base (u e) (v e) (ma e) (mb e)| ≤
          actualPairKernel p f base (u e) (v e) a0 b0 -
          actualPairKernel p f base (u e) (v e) a0 b1 -
          actualPairKernel p f base (u e) (v e) a1 b0 +
          actualPairKernel p f base (u e) (v e) a1 b1 :=
    actual_pair_kernel_oriented_rectangle
      p hp hp1 f base (u e) (v e) (hne e) (ma e) (mb e)
  choose a0 a1 b0 b1 hrects using hrect
  refine ⟨a0, a1, b0, b1, ?_⟩
  intro e s t
  exact (hmajor e s t).trans (hrects e)


end Nightfall.Observability.ActualESPairMatching
