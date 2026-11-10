import Mathlib

/-!
NIGHTFALL: quantitative finite resampling from a centered interaction witness.

This proves the weighted Cauchy--Schwarz implication behind
  P(change) >= e/R^2
under explicit moment/orthogonality premises.

It does NOT derive those premises from a Hoeffding expansion. The
probabilistic ANOVA bridge is a distinct, still-open formalization task.
-/

namespace Nightfall.Recovery

open Finset

variable {Atom : Type*} [Fintype Atom]

/-- Weighted orthogonality + positive energy yield a quantitative
resampling lower bound. R2 is a certified upper bound on squared
differences from the chosen base atom. No normalization of p is needed. -/
theorem energy_controls_resampling
    (p : Atom → ℝ) (f g : Atom → ℝ) (base : Atom)
    (e R2 : ℝ) (hp : ∀ u, 0 ≤ p u)
    (he : 0 < e)
    (hcenter : (∑ u, p u * g u) = 0)
    (hnorm : (∑ u, p u * (g u)^2) = e)
    (hinner : (∑ u, p u * f u * g u) = e)
    (hbound : ∀ u, (f u - f base)^2 ≤ R2) :
    e ≤ R2 * (∑ u, if f u ≠ f base then p u else 0) := by
  classical
  have hp_sqrt (u : Atom) : (Real.sqrt (p u))^2 = p u := Real.sq_sqrt (hp u)
  have hprod : (∑ u, (Real.sqrt (p u) * (f u - f base)) *
                    (Real.sqrt (p u) * g u)) = e := by
    calc
      (∑ u, (Real.sqrt (p u) * (f u - f base)) *
                    (Real.sqrt (p u) * g u)) =
          ∑ u, p u * (f u - f base) * g u := by
            apply Finset.sum_congr rfl
            intro u _
            calc
              _ = (Real.sqrt (p u))^2 * (f u - f base) * g u := by ring
              _ = p u * (f u - f base) * g u := by rw [hp_sqrt]
      _ = (∑ u, p u * f u * g u) -
            f base * (∑ u, p u * g u) := by
          rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
          apply Finset.sum_congr rfl
          intro u _
          ring
      _ = e := by rw [hinner, hcenter]; ring
  have hsqf : (∑ u, (Real.sqrt (p u) * (f u - f base))^2) =
        ∑ u, p u * (f u - f base)^2 := by
    apply Finset.sum_congr rfl
    intro u _
    calc
      _ = (Real.sqrt (p u))^2 * (f u - f base)^2 := by ring
      _ = p u * (f u - f base)^2 := by rw [hp_sqrt]
  have hsqg : (∑ u, (Real.sqrt (p u) * g u)^2) = e := by
    calc
      _ = ∑ u, p u * (g u)^2 := by
          apply Finset.sum_congr rfl
          intro u _
          calc
            _ = (Real.sqrt (p u))^2 * (g u)^2 := by ring
            _ = p u * (g u)^2 := by rw [hp_sqrt]
      _ = e := hnorm
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun u => Real.sqrt (p u) * (f u - f base))
      (fun u => Real.sqrt (p u) * g u)
  rw [hprod, hsqf, hsqg] at hcs
  have hvariance : e ≤ ∑ u, p u * (f u - f base)^2 := by
    have hmul : e * e ≤ (∑ u, p u * (f u - f base)^2) * e := by
      nlinarith [hcs]
    by_contra h
    have hlt : (∑ u, p u * (f u - f base)^2) < e := lt_of_not_ge h
    have hcontradiction :
        (∑ u, p u * (f u - f base)^2) * e < e * e :=
      mul_lt_mul_of_pos_right hlt he
    exact (not_lt_of_ge hmul) hcontradiction
  have hterm (u : Atom) :
      p u * (f u - f base)^2 ≤
         R2 * (if f u ≠ f base then p u else 0) := by
    by_cases hu : f u = f base
    · simp [hu]
    · simp [hu]
      simpa [mul_comm] using
        (mul_le_mul_of_nonneg_left (hbound u) (hp u))
  calc
    e ≤ ∑ u, p u * (f u - f base)^2 := hvariance
    _ ≤ ∑ u, R2 * (if f u ≠ f base then p u else 0) := by
      apply Finset.sum_le_sum
      intro u _
      exact hterm u
    _ = R2 * (∑ u, if f u ≠ f base then p u else 0) := by rw [Finset.mul_sum]

end Nightfall.Recovery
