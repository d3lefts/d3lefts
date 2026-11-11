import Mathlib

/-!
# NIGHTFALL actual centered pair kernels: exact rectangle averaging

For any two finite nonempty alphabets with independent normalized probability
weights (including zero atoms), a separately centered real pair kernel h
has an exact mixed-rectangle expectation.  In particular, for *every*
fixed pair (x,y), some second pair (u,v) has rectangle difference >= h(x,y).

This is a source-level kernel lemma: it quantifies over the actual weighted
sum and actual centered function, not an assumed matching amplitude.
It does not yet choose a *maximum absolute* component or orient signed
rectangles across a matching, nor establish centering for actual esComp.
-/

namespace Nightfall.Observability.CenteredRectangles

open Finset

variable {A B : Type*} [Fintype A] [Fintype B]

/-- An average of real values with nonnegative normalized finite weights
cannot exceed every value in the support. No positivity floor is used. -/
theorem weighted_average_below_some_value
    [Nonempty A]
    (p : A → ℝ) (hp : ∀ a, 0 ≤ p a)
    (hp1 : (∑ a : A, p a) = 1) (f : A → ℝ) :
    ∃ a : A, (∑ u : A, p u * f u) ≤ f a := by
  classical
  have hne : (Finset.univ : Finset A).Nonempty :=
    ⟨Classical.choice inferInstance, Finset.mem_univ _⟩
  obtain ⟨a, _, hmax⟩ := Finset.exists_max_image Finset.univ f hne
  refine ⟨a, ?_⟩
  calc
    (∑ u : A, p u * f u) ≤ ∑ u : A, p u * f a := by
      apply Finset.sum_le_sum
      intro u _
      exact mul_le_mul_of_nonneg_left
        (hmax u (Finset.mem_univ u)) (hp u)
    _ = (∑ u : A, p u) * f a := by rw [Finset.sum_mul]
    _ = f a := by rw [hp1, one_mul]

/-- Exact weighted mean of the four-corner mixed difference.
Separate centering in both variables is the only nontrivial functional
hypothesis: no fairness, lower atom floor, or pairwise sign symmetry. -/
theorem centered_rectangle_average
    (p : A → ℝ) (q : B → ℝ)
    (hp1 : (∑ u : A, p u) = 1)
    (hq1 : (∑ v : B, q v) = 1)
    (h : A → B → ℝ)
    (hrow : ∀ x : A, (∑ v : B, q v * h x v) = 0)
    (hcol : ∀ y : B, (∑ u : A, p u * h u y) = 0)
    (x : A) (y : B) :
    (∑ u : A, ∑ v : B,
      p u * q v *
      (h x y - h x v - h u y + h u v)) = h x y := by
  have hinner (u : A) :
      (∑ v : B, q v *
        (h x y - h x v - h u y + h u v)) =
      h x y - h u y := by
    calc
      (∑ v : B, q v *
        (h x y - h x v - h u y + h u v)) =
        ∑ v : B,
          ((q v * (h x y - h u y) +
              q v * h u v) - q v * h x v) := by
          apply Finset.sum_congr rfl
          intro v _
          ring
      _ = ((∑ v : B, q v) * (h x y - h u y) +
            (∑ v : B, q v * h u v)) -
            (∑ v : B, q v * h x v) := by
          rw [Finset.sum_sub_distrib, Finset.sum_add_distrib,
            ← Finset.sum_mul]
      _ = h x y - h u y := by
          rw [hq1, hrow u, hrow x]
          ring
  calc
    (∑ u : A, ∑ v : B, p u * q v *
      (h x y - h x v - h u y + h u v)) =
        ∑ u : A, p u * (∑ v : B, q v *
          (h x y - h x v - h u y + h u v)) := by
          apply Finset.sum_congr rfl
          intro u _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro v _
          ring
    _ = ∑ u : A, p u * (h x y - h u y) := by
          apply Finset.sum_congr rfl
          intro u _
          rw [hinner]
    _ = (∑ u : A, p u) * h x y -
        (∑ u : A, p u * h u y) := by
          calc
            (∑ u : A, p u * (h x y - h u y)) =
                ∑ u : A, (p u * h x y - p u * h u y) := by
                  apply Finset.sum_congr rfl
                  intro u _
                  ring
            _ = (∑ u : A, p u) * h x y -
                  (∑ u : A, p u * h u y) := by
                    rw [Finset.sum_sub_distrib, ← Finset.sum_mul]
    _ = h x y := by
          rw [hp1, hcol y]
          ring

/-- The chosen rectangle comes from the *actual product measures*
and independent canonical centering. The first corner (x,y) is arbitrary;
this is enough to feed maximal-amplitude selection after orienting signs. -/
theorem exists_rectangle_dominating_value
    [Nonempty A] [Nonempty B]
    (p : A → ℝ) (q : B → ℝ)
    (hp : ∀ u, 0 ≤ p u) (hq : ∀ v, 0 ≤ q v)
    (hp1 : (∑ u : A, p u) = 1)
    (hq1 : (∑ v : B, q v) = 1)
    (h : A → B → ℝ)
    (hrow : ∀ x : A, (∑ v : B, q v * h x v) = 0)
    (hcol : ∀ y : B, (∑ u : A, p u * h u y) = 0)
    (x : A) (y : B) :
    ∃ u : A, ∃ v : B,
      h x y ≤ h x y - h x v - h u y + h u v := by
  have hfixed (u : A) :
      (∑ v : B, q v * (h x y - h x v - h u y + h u v)) =
      h x y - h u y := by
    -- The first averaging step follows solely from centering in B.
    calc
      (∑ v : B, q v * (h x y - h x v - h u y + h u v)) =
        ∑ v : B,
          ((q v * (h x y - h u y) + q v * h u v) -
            q v * h x v) := by
          apply Finset.sum_congr rfl
          intro v _
          ring
      _ = ((∑ v : B, q v) * (h x y - h u y) +
            (∑ v : B, q v * h u v)) -
            (∑ v : B, q v * h x v) := by
          rw [Finset.sum_sub_distrib, Finset.sum_add_distrib,
            ← Finset.sum_mul]
      _ = h x y - h u y := by
          rw [hq1, hrow u, hrow x]
          ring
  have houter :
      (∑ u : A, p u *
        (∑ v : B, q v *
          (h x y - h x v - h u y + h u v))) = h x y := by
    calc
      (∑ u : A, p u *
        (∑ v : B, q v *
          (h x y - h x v - h u y + h u v))) =
        (∑ u : A, ∑ v : B, p u * q v *
          (h x y - h x v - h u y + h u v)) := by
          apply Finset.sum_congr rfl
          intro u _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro v _
          ring
      _ = h x y :=
        centered_rectangle_average p q hp1 hq1 h hrow hcol x y
  obtain ⟨u, hu⟩ :=
    weighted_average_below_some_value p hp hp1
      (fun u : A =>
        ∑ v : B, q v * (h x y - h x v - h u y + h u v))
  obtain ⟨v, hv⟩ :=
    weighted_average_below_some_value q hq hq1
      (fun v : B => h x y - h x v - h u y + h u v)
  refine ⟨u, v, ?_⟩
  calc
    h x y = (∑ u : A, p u *
      (∑ v : B, q v *
        (h x y - h x v - h u y + h u v))) := houter.symm
    _ ≤ (∑ v : B, q v *
      (h x y - h x v - h u y + h u v)) := hu
    _ ≤ h x y - h x v - h u y + h u v := hv

end Nightfall.Observability.CenteredRectangles
