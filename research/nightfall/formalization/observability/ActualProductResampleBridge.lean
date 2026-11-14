import ActualSourceANOVA
import ActualProductSourceMarginal

/-!
# Actual-source one-site refresh = literal source-coordinate resampling

A missing interface in the Q2 source-derived-to-canonical transport.
The proof uses only originalMass and the already certified product
marginal + stationarity identities; every coordinate stays an actual
original site. No nonzero-atom hypothesis or synthetic copy model.
-/

namespace Nightfall.Observability.ActualProductResampleBridge

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSourceMarginal

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Keeping all original coordinates except j and taking y at j
is precisely original-state coordinate update. -/
theorem keep_source_erase_eq_update
    (j : ι) (x y : ι → α) :
    keepSource (Finset.univ.erase j) x y =
      Function.update x j (y j) := by
  funext t
  by_cases ht : t = j
  · subst t
    simp [keepSource]
  · simp [keepSource, ht]

/-- Exact conditional source refresh at the complement of one site
agrees with an actual original-law one-coordinate marginal. -/
theorem source_refresh_erase_eq_coordinate_average
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (j : ι) (F : (ι → α) → ℝ) (x : ι → α) :
    sourceConditional p (Finset.univ.erase j) F x =
      ∑ a : α, p j a * F (Function.update x j a) := by
  classical
  unfold sourceConditional
  calc
    (∑ y : ι → α, originalMass p y •
      F (keepSource (Finset.univ.erase j) x y)) =
      ∑ y : ι → α, originalMass p y *
        F (Function.update x j (y j)) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [keep_source_erase_eq_update j x y]
          rfl
    _ = ∑ a : α, p j a * F (Function.update x j a) :=
      actual_product_coordinate_marginal p hp1 j
        (fun a => F (Function.update x j a))

/-- Integrated real source resampling identity. This is an EXACT
source law equality, not a declared independence axiom. -/
theorem actual_source_resample_sum
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (j : ι) (F : (ι → α) → ℝ) :
    (∑ x : ι → α, originalMass p x *
      (∑ a : α, p j a * F (Function.update x j a))) =
      ∑ x : ι → α, originalMass p x * F x := by
  classical
  calc
    (∑ x : ι → α, originalMass p x *
      (∑ a : α, p j a * F (Function.update x j a))) =
    ∑ x : ι → α, originalMass p x *
      sourceConditional p (Finset.univ.erase j) F x := by
        apply Finset.sum_congr rfl
        intro x _
        rw [source_refresh_erase_eq_coordinate_average p hp1 j F x]
    _ = ∑ x : ι → α, originalMass p x * F x :=
      actual_source_conditional_stationary p hp1 (Finset.univ.erase j) F

end Nightfall.Observability.ActualProductResampleBridge
