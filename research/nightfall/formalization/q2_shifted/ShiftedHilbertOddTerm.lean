import HilbertManyIncrementMoment

/-!
# Shifted Hilbert fourth moment: the only surviving odd term

For independent weighted U,V, the new increment V is centered, but
U has deterministic mean h. This source-agnostic finite Hilbert lemma
controls the odd term by a*c times the new increment energy. It is
the missing ingredient for the shifted fourth-moment recurrence.
-/

namespace Nightfall.Observability.ShiftedHilbertOddTerm

open Finset
open Nightfall.Observability.QuadraticMoments
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticHilbertMany

variable {A B K : Type*} [Fintype A] [Fintype B] [Fintype K]

theorem independent_shifted_odd_term
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (h : K → ℝ) (a c : ℝ)
    (hq : ∀ y, 0 ≤ q y)
    (hU : ∀ k, (∑ x : A, p x * U x k) = h k)
    (ha : 0 ≤ a) (hc : 0 ≤ c)
    (ha2 : vecNormSq h = a^2)
    (hVbound : ∀ y, vecNormSq (V y) ≤ c^2) :
    jointAvg p q (fun x y =>
      vecNormSq (V y) * vecDot (U x) (V y)) ≤
        a*c*(∑ y : B, q y * vecNormSq (V y)) := by
  classical
  let nv : B → ℝ := fun y => vecNormSq (V y)
  have hdot (y : B) : vecDot h (V y) ≤ a*c := by
    have hsq := vec_dot_sq_le h (V y)
    have hbound := mul_le_mul_of_nonneg_left
      (hVbound y) (vecNormSq_nonneg h)
    have hsqbound : (vecDot h (V y))^2 ≤ (a*c)^2 := by
      rw [ha2] at hsq hbound
      nlinarith [hsq, hbound]
    nlinarith [hsqbound, mul_nonneg ha hc]
  have heq :
      jointAvg p q (fun x y =>
        nv y * vecDot (U x) (V y)) =
      ∑ y : B, q y * (nv y * vecDot h (V y)) := by
    have hexpand (x : A) (y : B) :
        nv y * vecDot (U x) (V y) =
          ∑ k : K, U x k * (nv y * V y k) := by
      unfold vecDot
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro k _
      ring
    calc
      jointAvg p q (fun x y =>
        nv y * vecDot (U x) (V y)) =
          ∑ k : K, jointAvg p q
            (fun x y => U x k * (nv y * V y k)) := by
        rw [← jointAvg_finset_sum]
        unfold jointAvg
        apply Finset.sum_congr rfl
        intro x _
        apply Finset.sum_congr rfl
        intro y _
        simpa only using
          congrArg (fun t : ℝ => p x * q y * t) (hexpand x y)
      _ = ∑ k : K, (∑ x : A, p x * U x k) *
            (∑ y : B, q y * (nv y * V y k)) := by
        apply Finset.sum_congr rfl
        intro k _
        exact jointAvg_factor p q (fun x => U x k)
          (fun y => nv y * V y k)
      _ = ∑ k : K, h k *
            (∑ y : B, q y * (nv y * V y k)) := by
        apply Finset.sum_congr rfl
        intro k _
        rw [hU k]
      _ = ∑ y : B, q y * (nv y * vecDot h (V y)) := by
        calc
          (∑ k : K, h k *
              (∑ y : B, q y * (nv y * V y k))) =
              ∑ k : K, ∑ y : B,
                h k * (q y * (nv y * V y k)) := by
                  apply Finset.sum_congr rfl
                  intro k _
                  rw [Finset.mul_sum]
          _ = ∑ y : B, ∑ k : K,
                h k * (q y * (nv y * V y k)) := Finset.sum_comm
          _ = ∑ y : B, q y * (nv y * vecDot h (V y)) := by
                apply Finset.sum_congr rfl
                intro y _
                unfold vecDot
                rw [Finset.mul_sum, Finset.mul_sum]
                apply Finset.sum_congr rfl
                intro k _
                ring
  change jointAvg p q (fun x y =>
    nv y * vecDot (U x) (V y)) ≤
      a*c*(∑ y : B, q y * nv y)
  rw [heq]
  calc
    (∑ y : B, q y * (nv y * vecDot h (V y))) ≤
        ∑ y : B, q y * (nv y * (a*c)) := by
      apply Finset.sum_le_sum
      intro y _
      exact mul_le_mul_of_nonneg_left
        (mul_le_mul_of_nonneg_left (hdot y) (vecNormSq_nonneg (V y)))
        (hq y)
    _ = a*c*(∑ y : B, q y * nv y) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro y _
      ring

end Nightfall.Observability.ShiftedHilbertOddTerm
