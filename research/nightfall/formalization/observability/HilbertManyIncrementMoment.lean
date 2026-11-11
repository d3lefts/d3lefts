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

/-- The first n independent coordinates, represented without a Fin-index cast. -/
def Samples (α : Type*) : ℕ → Type*
  | 0 => PUnit
  | n + 1 => Samples α n × α

instance : (n : ℕ) → Fintype (Samples α n)
  | 0 => inferInstanceAs (Fintype PUnit)
  | n + 1 => inferInstanceAs (Fintype (Samples α n × α))

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
  induction n generalizing w with
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
  | zero => simp [mass, Samples]
  | succ n ih =>
      change (∑ w : Samples α n × α, mass p (n + 1) w) = 1
      rw [Fintype.sum_prod_type]
      change (∑ s : Samples α n, ∑ a : α, mass p n s * p n a) = 1
      rw [tensor_sum_factor, ih, hp1 n]
      ring

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
  have hh :
      jointAvg p q (fun a b => U a k + V b k) =
        jointAvg p q (fun a b => U a k * 1) +
          jointAvg p q (fun a b => 1 * V b k) := by
    rw [jointAvg_add]
    congr 1 <;> (unfold jointAvg; apply Finset.sum_congr rfl;
      intro a _; apply Finset.sum_congr rfl; intro b _; ring)
  rw [hh, jointAvg_factor, jointAvg_factor]
  simp only [mul_one, one_mul]
  rw [hU k, hV k, hp1, hq1]
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
    simpa only [one_mul, hp1] using h
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
    rw [vec_normSq_add]
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

end Nightfall.Observability.QuadraticHilbertMany
