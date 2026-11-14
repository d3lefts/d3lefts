import SCIFExactTableTransport
import SCIFActualInfluence

/-!
# SCIF exact local-coordinate source influence update

For any observable, a one-coordinate law edit changes another site's
true sourceInfluence by an exact old-source integral of the edited
coordinate's signed marginal difference. No extra old/new law mass
oracle, positive-atom assumption or degree restriction.

The conditional locality result assumes a checkable source residual
ignores the edited coordinate. Degree-two graph-local corollaries
must derive that premise from the original canonical pair graph.
-/
namespace Nightfall.SCIFLocalSourceInfluence

open Finset
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.SCIFExactTableTransport
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.SCIFActualInfluence
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualProductResampleBridge

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact edited-product expectation on the original world space. -/
theorem source_integral_after_one_law_edit
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (k : ι) (q : α → ℝ) (F : (ι → α) → ℝ) :
    (∑ x : ι → α, originalMass (editLaw p k q) x * F x) =
      ∑ x : ι → α, originalMass p x *
        (∑ a : α, q a * F (Function.update x k a)) := by
  classical
  have hs := source_law_swap_integral
    (editLaw p k q) k (p k) (hp1 k) F
  have hback :
      editLaw (editLaw p k q) k (p k) = p := by
    funext i a
    by_cases hi : i = k
    · simp [editLaw, hi]
    · simp [editLaw, hi]
  have hnow : (editLaw p k q) k = q := by
    funext a
    simp [editLaw]
  rw [hback, hnow] at hs
  exact hs.symm

/-- True source influence of an UNEDITED coordinate j admits an
exact rank-one source-law correction. This uses the actual original
f and original resampling residual, not a free pair kernel. -/
theorem actual_influence_change_as_single_coordinate_integral
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) :
    sourceInfluence (editLaw p k q) f j -
      sourceInfluence p f j =
    ∑ x : ι → α, originalMass p x *
      (∑ a : α, (q a - p k a) *
        (residual p f j (Function.update x k a))^2) := by
  classical
  have hj : p j = (editLaw p k q) j := by
    funext a
    simp [editLaw, Ne.symm hkj]
  let F : (ι → α) → ℝ := fun x => (residual p f j x)^2
  have hd := source_influence_unedited_exact p (editLaw p k q) f j hj
  have hnew := source_integral_after_one_law_edit p hp1 k q F
  have hold := (actual_source_resample_sum p hp1 k F).symm
  calc
    sourceInfluence (editLaw p k q) f j -
      sourceInfluence p f j =
      (∑ x : ι → α, originalMass (editLaw p k q) x * F x) -
      (∑ x : ι → α, originalMass p x * F x) := by
        rw [hd, ← Finset.sum_sub_distrib]
        apply Finset.sum_congr rfl
        intro x _
        ring
    _ = (∑ x : ι → α, originalMass p x *
           (∑ a : α, q a * F (Function.update x k a))) -
        (∑ x : ι → α, originalMass p x *
           (∑ a : α, p k a * F (Function.update x k a))) := by
          rw [hnew, hold]
    _ = ∑ x : ι → α, originalMass p x *
           (∑ a : α, (q a - p k a) *
             F (Function.update x k a)) := by
          rw [← Finset.sum_sub_distrib]
          apply Finset.sum_congr rfl
          intro x _
          rw [← mul_sub, ← Finset.sum_sub_distrib]
          congr 1
          apply Finset.sum_congr rfl
          intro a _
          ring
    _ = _ := rfl

/-- If the old true j-residual ignores edited coordinate k,
the changed law cannot change that site's influence. This exact
locality criterion works even for arbitrary high-degree functions;
its hypotheses need to be checked against the canonical graph. -/
theorem unchanged_influence_of_residual_independence
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (hignore : ∀ x : ι → α, ∀ a : α,
       residual p f j (Function.update x k a) = residual p f j x) :
    sourceInfluence (editLaw p k q) f j =
      sourceInfluence p f j := by
  have hd := actual_influence_change_as_single_coordinate_integral
    p hp1 f k j hkj q
  have hzero (x : ι → α) :
      (∑ a : α, (q a - p k a) *
        (residual p f j (Function.update x k a))^2) = 0 := by
    simp_rw [hignore x]
    rw [← Finset.sum_mul, Finset.sum_sub_distrib, hq1, hp1 k]
    ring
  have hz :
      (∑ x : ι → α, originalMass p x *
        (∑ a : α, (q a - p k a) *
          (residual p f j (Function.update x k a))^2)) = 0 := by
    simp [hzero]
  rw [hz] at hd
  linarith

end Nightfall.SCIFLocalSourceInfluence
