import ShiftedHilbertTwoIncrement

/-!
# Arbitrary-length shifted independent Hilbert fourth moment

The deterministic singleton h is inside the vector before taking the
fourth moment. Unlike the old centered-only result, no centering of h
is assumed. The all-n proof uses the certified noncentered two-increment
recurrence and the existing exact product second/fourth moment budgets.
-/

namespace Nightfall.Observability.ShiftedHilbertManyIncrement

open Finset
open Nightfall.Observability.QuadraticMoments
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.ShiftedHilbertTwoIncrement

variable {α K : Type*} [Fintype α] [Fintype K]

noncomputable def shiftedMoment4
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (h : K → ℝ) (n : ℕ) : ℝ :=
  ∑ w : Samples α n, mass p n w *
    (vecNormSq (fun k => h k + sumVector Y n w k))^2

theorem shifted_mean
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (h : K → ℝ)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1)
    (hY : ∀ n k, (∑ a : α, p n a * Y n a k) = 0)
    (n : ℕ) (k : K) :
    (∑ w : Samples α n, mass p n w *
      (h k + sumVector Y n w k)) = h k := by
  have hcent := sumVector_center p Y hp1 hY n k
  have hmass := mass_one p hp1 n
  calc
    (∑ w : Samples α n, mass p n w *
      (h k + sumVector Y n w k)) =
      (∑ w : Samples α n, mass p n w) * h k +
        (∑ w : Samples α n, mass p n w *
          sumVector Y n w k) := by
      simp only [mul_add, Finset.sum_add_distrib]
      rw [← Finset.sum_mul]
    _ = h k := by rw [hmass, hcent]; ring

theorem shifted_second_moment
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (h : K → ℝ)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1)
    (hY : ∀ n k, (∑ a : α, p n a * Y n a k) = 0)
    (n : ℕ) :
    (∑ w : Samples α n, mass p n w *
      vecNormSq (fun k => h k + sumVector Y n w k)) =
      vecNormSq h + moment2 p Y n := by
  classical
  have hmass := mass_one p hp1 n
  have hcent (k : K) := sumVector_center p Y hp1 hY n k
  have hcross :
      (∑ w : Samples α n, mass p n w *
        vecDot h (sumVector Y n w)) = 0 := by
    calc
      (∑ w : Samples α n, mass p n w *
        vecDot h (sumVector Y n w)) =
        ∑ k : K, h k *
          (∑ w : Samples α n,
            mass p n w * sumVector Y n w k) := by
        unfold vecDot
        calc
          (∑ w : Samples α n, mass p n w *
            (∑ k : K, h k * sumVector Y n w k)) =
            ∑ w : Samples α n, ∑ k : K,
              mass p n w * (h k * sumVector Y n w k) := by
            apply Finset.sum_congr rfl
            intro w _
            rw [Finset.mul_sum]
          _ = ∑ k : K, ∑ w : Samples α n,
                mass p n w * (h k * sumVector Y n w k) :=
            Finset.sum_comm
          _ = ∑ k : K, h k *
              (∑ w : Samples α n,
                mass p n w * sumVector Y n w k) := by
            apply Finset.sum_congr rfl
            intro k _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro w _
            ring
      _ = 0 := by simp only [hcent, mul_zero, Finset.sum_const_zero]
  have hpoint (w : Samples α n) :
      vecNormSq (fun k => h k + sumVector Y n w k) =
        vecNormSq h + vecNormSq (sumVector Y n w) +
          2 * vecDot h (sumVector Y n w) :=
    vec_normSq_add h (sumVector Y n w)
  calc
    (∑ w : Samples α n, mass p n w *
      vecNormSq (fun k => h k + sumVector Y n w k)) =
      ∑ w : Samples α n, mass p n w *
        (vecNormSq h + vecNormSq (sumVector Y n w) +
          2 * vecDot h (sumVector Y n w)) := by
      apply Finset.sum_congr rfl
      intro w _
      rw [hpoint]
    _ = (∑ w : Samples α n, mass p n w) * vecNormSq h +
        moment2 p Y n +
        2 * (∑ w : Samples α n, mass p n w *
          vecDot h (sumVector Y n w)) := by
      unfold moment2
      simp only [mul_add, Finset.sum_add_distrib]
      rw [← Finset.sum_mul]
      rw [Finset.mul_sum]
      ring
    _ = vecNormSq h + moment2 p Y n := by
      rw [hmass, hcross]
      ring

/-- The full shifted fourth-moment envelope for ANY number of actual
independent finite draws. This is the noncentered Hilbert operator
needed before source-level owner/Jensen composition. -/
theorem arbitrary_law_many_shifted_hilbert_fourth
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (h : K → ℝ) (a c : ℝ)
    (hp : ∀ n b, 0 ≤ p n b)
    (hp1 : ∀ n, (∑ b : α, p n b) = 1)
    (hY : ∀ n k, (∑ b : α, p n b * Y n b k) = 0)
    (ha : 0 ≤ a) (hc : 0 ≤ c)
    (ha2 : vecNormSq h = a^2)
    (hbound : ∀ n b, vecNormSq (Y n b) ≤ c^2)
    (n : ℕ) :
    shiftedMoment4 p Y h n ≤
      a^4 + 6*a^2*(budget p Y n) +
      3*(budget p Y n)^2 +
      c^2*(budget p Y n) + 4*a*c*(budget p Y n) := by
  induction n with
  | zero =>
      simp [shiftedMoment4, budget, mass, sumVector, Samples, ha2,
        Finset.card_univ, Fintype.card_punit]
      ring
  | succ n ih =>
      let v : ℝ := ∑ b : α, p n b * vecNormSq (Y n b)
      let w : ℝ := ∑ b : α, p n b * (vecNormSq (Y n b))^2
      have hV : 0 ≤ v := by
        dsimp [v]
        exact Finset.sum_nonneg (fun b _ =>
          mul_nonneg (hp n b) (vecNormSq_nonneg (Y n b)))
      have hw : w ≤ c^2*v := by
        dsimp [w, v]
        exact weighted_hilbert_fourth_self
          (p n) (Y n) c (hp n) (hbound n)
      have hmean : ∀ k : K,
          (∑ z : Samples α n,
            mass p n z *
              (h k + sumVector Y n z k)) = h k :=
        shifted_mean p Y h hp1 hY n
      have htwo := shifted_second_moment p Y h hp1 hY n
      have hstep := independent_shifted_two_hilbert_fourth
        (mass p n) (p n)
        (fun z k => h k + sumVector Y n z k)
        (Y n) h a c
        (mass_nonneg p hp n) (hp n)
        (mass_one p hp1 n) (hp1 n)
        hmean (hY n) ha hc ha2 (hbound n)
      have hq :
          shiftedMoment4 p Y h (n+1) ≤
            shiftedMoment4 p Y h n + w +
              6*(a^2+moment2 p Y n)*v + 4*a*c*v := by
        calc
          shiftedMoment4 p Y h (n+1) =
            jointAvg (mass p n) (p n)
              (fun z b => (vecNormSq
                (fun k => h k + sumVector Y n z k + Y n b k))^2) := by
                  unfold shiftedMoment4
                  rw [expectation_succ]
                  unfold jointAvg
                  apply Finset.sum_congr rfl
                  intro z _
                  apply Finset.sum_congr rfl
                  intro b _
                  apply congrArg (fun t : ℝ => mass p n z * p n b * t)
                  congr 1
                  unfold vecNormSq
                  apply Finset.sum_congr rfl
                  intro k _
                  change
                    (h k + (sumVector Y n z k + Y n b k))^2 =
                    (h k + sumVector Y n z k + Y n b k)^2
                  ring
          _ ≤ shiftedMoment4 p Y h n + w +
              6*(a^2+moment2 p Y n)*v + 4*a*c*v := by
                dsimp [shiftedMoment4, w, v]
                rw [htwo, ha2] at hstep
                exact hstep
      have hbudget : budget p Y (n+1) = budget p Y n + v :=
        budget_succ p Y n
      have henergy : moment2 p Y n = budget p Y n :=
        moment2_eq_budget p Y hp1 hY n
      rw [henergy] at hq
      rw [hbudget]
      nlinarith [ih, hq, hw, sq_nonneg v]

end Nightfall.Observability.ShiftedHilbertManyIncrement
