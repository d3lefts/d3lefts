import SCIFLocalSourceInfluence
import ActualSourceQuadraticRectangles

/-!
# SCIF graph-local influence invariance from the original f

A finite source degree-two function with identically zero original
canonical {k,j} pair projector has a j-resampling residual independent
of k. Hence any replacement of the marginal at k leaves the genuine
sourceInfluence of j exactly unchanged.

This formally links the canonical Efron–Stein graph to actual local
law-change recertification. No externally supplied source neighbor set,
positive atom floor, or synthetic influence is assumed. The conclusion
is valid pointwise, including old zero-probability symbols.
-/
namespace Nightfall.SCIFGraphLocality

open Finset
open Nightfall.SCIFLocalSourceInfluence
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.SCIFActualInfluence
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

private theorem update_at_current_value
    (x : ι → α) (i : ι) :
    Function.update x i (x i) = x := by
  funext t
  by_cases ht : t = i
  · subst t
    simp
  · simp [Function.update_of_ne ht]

private theorem restore_unchanged_second_coordinate
    (x : ι → α) (k j : ι) (hkj : k ≠ j) (a : α) :
    Function.update (Function.update x k a) j (x j) =
      Function.update x k a := by
  funext t
  by_cases ht : t = j
  · subst t
    simp [Ne.symm hkj]
  · simp [Function.update_of_ne ht]

/-- Mixed four-corner vanishing forces the j-centered source residual
to ignore the k-coordinate. The source law at j is normalized. -/
theorem residual_ignores_k_if_mixed_rectangles_vanish
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (hrect : ∀ x : ι → α, ∀ a0 a1 b0 b1 : α,
        sourceRectangle f x k j a0 a1 b0 b1 = 0) :
    ∀ x : ι → α, ∀ a : α,
      Nightfall.Observability.SCIFActualInfluence.residual p f j (Function.update x k a) = Nightfall.Observability.SCIFActualInfluence.residual p f j x := by
  intro x a
  have hcorner (b : α) :
      f (Function.update x k a) -
        f (Function.update (Function.update x k a) j b) =
      f x - f (Function.update x j b) := by
    have hr := hrect x a (x k) (x j) b
    have h3 :
        Function.update (Function.update x k (x k)) j (x j) = x := by
      rw [update_at_current_value x k]
      exact update_at_current_value x j
    have h4 :
        Function.update (Function.update x k (x k)) j b =
          Function.update x j b := by
      rw [update_at_current_value x k]
    unfold sourceRectangle at hr
    rw [restore_unchanged_second_coordinate x k j hkj a,
        h3, h4] at hr
    linarith
  unfold residual
  calc
    f (Function.update x k a) -
      (∑ b : α, p j b * f (Function.update (Function.update x k a) j b)) =
        ∑ b : α, p j b *
          (f (Function.update x k a) -
            f (Function.update (Function.update x k a) j b)) := by
              simp_rw [mul_sub]
              rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hp1 j, one_mul]
    _ = ∑ b : α, p j b * (f x - f (Function.update x j b)) := by
          apply Finset.sum_congr rfl
          intro b _
          rw [hcorner b]
    _ = f x - (∑ b : α, p j b * f (Function.update x j b)) := by
          simp_rw [mul_sub]
          rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hp1 j, one_mul]

/-- Fully canonical source graph certificate: if the original
order-two canonical projector on {k,j} vanishes pointwise, changing
coordinate k cannot modify the genuine j-resampling residual. -/
theorem residual_ignores_k_if_canonical_pair_zero
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (k j : ι) (hkj : k ≠ j)
    (hpair : ∀ x : ι → α,
      esComp p ({k,j} : Finset ι) f x = 0) :
    ∀ x : ι → α, ∀ a : α,
      Nightfall.Observability.SCIFActualInfluence.residual p f j (Function.update x k a) = Nightfall.Observability.SCIFActualInfluence.residual p f j x := by
  have hrect (x : ι → α) (a0 a1 b0 b1 : α) :
      sourceRectangle f x k j a0 a1 b0 b1 = 0 := by
    rw [actual_quadratic_rectangle_eq_es_pair p hp1 f hdegree
          k j hkj x a0 a1 b0 b1]
    simp [sourceRectangle, hpair]
  exact residual_ignores_k_if_mixed_rectangles_vanish
    p hp1 f k j hkj hrect

/-- The canonical pair graph directly controls WHICH true original
source influences require updates when marginal k changes. Every
nonneighbor j with an identically zero old canonical pair has
exactly unchanged influence under the new law. -/
theorem actual_influence_unchanged_outside_canonical_neighborhood
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (hpair : ∀ x : ι → α,
      esComp p ({k,j} : Finset ι) f x = 0) :
    sourceInfluence (editLaw p k q) f j =
      sourceInfluence p f j := by
  exact unchanged_influence_of_residual_independence
    p hp1 f k j hkj q hq1
      (residual_ignores_k_if_canonical_pair_zero
        p hp1 f hdegree k j hkj hpair)

end Nightfall.SCIFGraphLocality
