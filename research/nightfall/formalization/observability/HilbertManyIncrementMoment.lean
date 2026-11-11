import HilbertTwoIncrementMoment

/-!
# Actual finite independent Hilbert increments: arbitrary family length

A concrete product sample space is built recursively from *coordinate-specific*
finite laws. No fourth-moment estimate is assumed. The only probabilistic
hypotheses are nonnegative normalized weights and centering of each increment.
The theorem applies to an arbitrary number of increments and an arbitrary
finite-dimensional real output (no common atom lower bound).
This is a supporting theorem, **not** the end-to-end quadratic influence result:
matching / ANOVA and bounded section inputs still require separate proofs.
-/

namespace Nightfall.Observability.QuadraticHilbertMany

open Finset
open Nightfall.Observability.QuadraticMoments
open Nightfall.Observability.QuadraticHilbertMoments

variable {α K : Type*} [Fintype α] [Fintype K]

universe u

/-- The first n independent coordinates, represented without a Fin-index cast. -/
def Samples (α : Type u) : ℕ → Type u
  | 0 => PUnit
  | n + 1 => Samples α n × α

instance instSamplesFintype (n : ℕ) : Fintype (Samples α n) :=
  match n with
  | 0 => inferInstanceAs (Fintype PUnit)
  | n + 1 => by
      letI : Fintype (Samples α n) := instSamplesFintype n
      exact inferInstanceAs (Fintype (Samples α n × α))

/-- Coordinate-wise product mass. -/
noncomputable def mass (p : ℕ → α → ℝ) :
    (n : ℕ) → Samples α n → ℝ
  | 0, _ => 1
  | n + 1, (s, a) => mass p n s * p n a

/-- Sum of the first n real-vector increments. -/
noncomputable def sumVector (Y : ℕ → α → K → ℝ) :
    (n : ℕ) → Samples α n → K → ℝ
  | 0, _ => fun _ => 0
  | n + 1, (s, a) => fun k => sumVector Y n s k + Y n a k

/-- Product expectation at n+1 factors is a two-factor expectation. -/
theorem expectation_succ (p : ℕ → α → ℝ) (n : ℕ)
    (F : Samples α (n + 1) → ℝ) :
    (∑ w : Samples α (n + 1), mass p (n + 1) w * F w) =
      jointAvg (mass p n) (p n) (fun w a => F (w, a)) := by
  change (∑ w : Samples α n × α,
      mass p (n + 1) w * F w) = _
  rw [Fintype.sum_prod_type]
  rfl

theorem mass_nonneg (p : ℕ → α → ℝ)
    (hp : ∀ n a, 0 ≤ p n a) (n : ℕ) (w : Samples α n) :
    0 ≤ mass p n w := by
  induction n with
  | zero =>
      cases w
      norm_num [mass]
  | succ n ih =>
      rcases w with ⟨s, a⟩
      change 0 ≤ mass p n s * p n a
      exact mul_nonneg (ih s) (hp n a)

theorem mass_one (p : ℕ → α → ℝ)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1) (n : ℕ) :
    (∑ w : Samples α n, mass p n w) = 1 := by
  induction n with
  | zero =>
      change (∑ _ : PUnit, (1 : ℝ)) = 1
      simp
  | succ n ih =>
      calc
        (∑ w : Samples α (n + 1), mass p (n + 1) w) =
            jointAvg (mass p n) (p n) (fun _ _ => (1 : ℝ)) := by
              simpa only [mul_one] using (expectation_succ p n (fun _ => (1 : ℝ)))
        _ = (∑ w : Samples α n, mass p n w) *
              (∑ a : α, p n a) := by
              simpa only [mul_one] using
                (jointAvg_factor (mass p n) (p n)
                  (fun _ : Samples α n => (1 : ℝ)) (fun _ : α => (1 : ℝ)))
        _ = 1 := by rw [ih, hp1 n]; ring

/-- The mean of a sum of independent centered vectors is zero, on actual
product tables rather than abstract assumed moment identities. -/
theorem joint_center_add
    {A B : Type*} [Fintype A] [Fintype B]
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (hp1 : (∑ a : A, p a) = 1)
    (hq1 : (∑ b : B, q b) = 1)
    (hU : ∀ k, (∑ a : A, p a * U a k) = 0)
    (hV : ∀ k, (∑ b : B, q b * V b k) = 0)
    (k : K) :
    jointAvg p q (fun a b => U a k + V b k) = 0 := by
  have hleft :
      jointAvg p q (fun a b => U a k) =
        (∑ a : A, p a * U a k) * (∑ b : B, q b) := by
    simpa only [mul_one] using
      (jointAvg_factor p q (fun a => U a k) (fun _ : B => 1))
  have hright :
      jointAvg p q (fun a b => V b k) =
        (∑ a : A, p a) * (∑ b : B, q b * V b k) := by
    simpa only [one_mul, mul_one] using
      (jointAvg_factor p q (fun _ : A => 1) (fun b => V b k))
  rw [jointAvg_add, hleft, hright, hU k, hV k, hp1, hq1]
  ring

/-- The exact second moment of the sum of two independent centered
Hilbert vectors, using arbitrary finite product weights. -/
theorem independent_two_second
    {A B : Type*} [Fintype A] [Fintype B]
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (hp1 : (∑ a : A, p a) = 1)
    (hq1 : (∑ b : B, q b) = 1)
    (hU : ∀ k, (∑ a : A, p a * U a k) = 0)
    (hV : ∀ k, (∑ b : B, q b * V b k) = 0) :
    jointAvg p q (fun a b => vecNormSq (fun k => U a k + V b k)) =
      (∑ a : A, p a * vecNormSq (U a)) +
        (∑ b : B, q b * vecNormSq (V b)) := by
  have hx :
      jointAvg p q (fun a b => vecDot (U a) (V b)) = 0 := by
    have hdot (a : A) (b : B) :
        vecDot (U a) (V b) = ∑ k : K, U a k * V b k := rfl
    have h := jointAvg_finset_sum p q (fun k a b => U a k * V b k)
    unfold vecDot at *
    rw [h]
    apply Finset.sum_eq_zero
    intro k _
    rw [jointAvg_factor, hU k, zero_mul]
  have ha : jointAvg p q (fun a _ => vecNormSq (U a)) =
      ∑ a : A, p a * vecNormSq (U a) := by
    have h := jointAvg_factor p q (fun a => vecNormSq (U a)) (fun _ : B => 1)
    simpa only [mul_one, Finset.sum_const_zero, hq1] using h
  have hb : jointAvg p q (fun _ b => vecNormSq (V b)) =
      ∑ b : B, q b * vecNormSq (V b) := by
    have h := jointAvg_factor p q (fun _ : A => 1) (fun b => vecNormSq (V b))
    simpa only [one_mul, mul_one, hp1] using h
  have heq :
      jointAvg p q (fun a b => vecNormSq (fun k => U a k + V b k)) =
        jointAvg p q (fun a b =>
          vecNormSq (U a) + vecNormSq (V b) +
            2 * vecDot (U a) (V b)) := by
    unfold jointAvg
    apply Finset.sum_congr rfl
    intro a _
    apply Finset.sum_congr rfl
    intro b _
    simpa only using congrArg (fun t : ℝ => p a * q b * t)
      (vec_normSq_add (U a) (V b))
  rw [heq, jointAvg_add, jointAvg_add, jointAvg_smul, ha, hb, hx]
  ring

theorem sumVector_center (p : ℕ → α → ℝ)
    (Y : ℕ → α → K → ℝ)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1)
    (hY : ∀ n k, (∑ a : α, p n a * Y n a k) = 0)
    (n : ℕ) : ∀ k : K,
    (∑ w : Samples α n, mass p n w * sumVector Y n w k) = 0 := by
  induction n with
  | zero =>
      intro k
      simp [Samples, mass, sumVector]
  | succ n ih =>
      intro k
      rw [expectation_succ]
      change jointAvg (mass p n) (p n)
        (fun s a => sumVector Y n s k + Y n a k) = 0
      exact joint_center_add (mass p n) (p n)
        (sumVector Y n) (Y n)
        (mass_one p hp1 n) (hp1 n) ih (hY n) k

/-- Second and fourth moments for the actual n-fold product table. -/
noncomputable def moment2 (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (n : ℕ) : ℝ :=
  ∑ w : Samples α n, mass p n w * vecNormSq (sumVector Y n w)

noncomputable def moment4 (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (n : ℕ) : ℝ :=
  ∑ w : Samples α n, mass p n w * (vecNormSq (sumVector Y n w)) ^ 2

noncomputable def budget (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (n : ℕ) : ℝ :=
  ∑ j ∈ Finset.range n, ∑ a : α, p j a * vecNormSq (Y j a)

/-- Nonnegative quadratic Euclidean energy on any finite output alphabet. -/
theorem vecNormSq_nonneg (v : K → ℝ) : 0 ≤ vecNormSq v := by
  unfold vecNormSq
  exact Finset.sum_nonneg (fun k _ => sq_nonneg (v k))

theorem budget_succ (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ) (n : ℕ) :
    budget p Y (n+1) =
      budget p Y n + (∑ a : α, p n a * vecNormSq (Y n a)) := by
  simp only [budget, Finset.sum_range_succ]

/-- The second moment on an actual product equals the sum of all independent
coordinate energies, with no fair-sign or atom-floor assumptions. -/
theorem moment2_eq_budget
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1)
    (hY : ∀ n k, (∑ a : α, p n a * Y n a k) = 0) :
    ∀ n, moment2 p Y n = budget p Y n := by
  intro n
  induction n with
  | zero =>
      simp [moment2, budget, mass, sumVector, vecNormSq, Samples]
  | succ n ih =>
      have ht := independent_two_second
        (mass p n) (p n) (sumVector Y n) (Y n)
        (mass_one p hp1 n) (hp1 n)
        (sumVector_center p Y hp1 hY n) (hY n)
      have hs : moment2 p Y (n+1) =
          moment2 p Y n + ∑ a : α, p n a * vecNormSq (Y n a) := by
        calc
          moment2 p Y (n+1) =
              jointAvg (mass p n) (p n)
                (fun w a => vecNormSq
                  (fun k => sumVector Y n w k + Y n a k)) := by
                  unfold moment2
                  rw [expectation_succ]
                  rfl
          _ = _ := ht
      rw [hs, budget_succ, ih]

theorem moment4_succ_bound
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (hp : ∀ n a, 0 ≤ p n a)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1)
    (hY : ∀ n k, (∑ a : α, p n a * Y n a k) = 0)
    (n : ℕ) :
    moment4 p Y (n+1) ≤ moment4 p Y n +
      (∑ a : α, p n a * vecNormSq (Y n a) ^ 2) +
      6 * moment2 p Y n *
        (∑ a : α, p n a * vecNormSq (Y n a)) := by
  have ht := independent_centered_two_hilbert_fourth
    (mass p n) (p n) (sumVector Y n) (Y n)
    (mass_nonneg p hp n) (hp n) (mass_one p hp1 n) (hp1 n)
    (sumVector_center p Y hp1 hY n) (hY n)
  calc
    moment4 p Y (n+1) =
        jointAvg (mass p n) (p n)
          (fun w a => (vecNormSq
            (fun k => sumVector Y n w k + Y n a k)) ^ 2) := by
              unfold moment4
              rw [expectation_succ]
              rfl
    _ ≤ _ := ht
    _ = _ := rfl

/-- The genuine many-increment Hilbert fourth-moment inequality, quantified
over **every number of independent inputs**, every finite alphabet,
coordinate-dependent normalized nonnegative masses, and arbitrary finite
Hilbert output dimension. Only centering and individual pointwise norm bounds
are required. No fourth-moment assumption is passed to this theorem. -/
theorem arbitrary_law_many_hilbert_fourth
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ) (c : ℝ)
    (hp : ∀ n a, 0 ≤ p n a)
    (hp1 : ∀ n, (∑ a : α, p n a) = 1)
    (hY : ∀ n k, (∑ a : α, p n a * Y n a k) = 0)
    (hbound : ∀ n a, vecNormSq (Y n a) ≤ c ^ 2)
    (n : ℕ) :
    moment4 p Y n ≤ c ^ 2 * budget p Y n +
      3 * (budget p Y n) ^ 2 := by
  induction n with
  | zero =>
      simp [moment4, budget, mass, sumVector, vecNormSq, Samples]
  | succ n ih =>
      let v : ℝ := ∑ a : α, p n a * vecNormSq (Y n a)
      have hv : 0 ≤ v := by
        dsimp [v]
        apply Finset.sum_nonneg
        intro a _
        exact mul_nonneg (hp n a) (vecNormSq_nonneg (Y n a))
      have hfour : (∑ a : α, p n a * vecNormSq (Y n a) ^ 2) ≤ c ^ 2 * v := by
        simpa only [vecNormSq, v] using
          (weighted_hilbert_fourth_self (p n) (Y n) c
            (hp n) (fun a => hbound n a))
      have htwo := moment2_eq_budget p Y hp1 hY n
      have hstep := moment4_succ_bound p Y hp hp1 hY n
      rw [budget_succ]
      dsimp [v] at *
      nlinarith [sq_nonneg v]

end Nightfall.Observability.QuadraticHilbertMany

