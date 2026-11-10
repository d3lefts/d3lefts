import Mathlib

/-!
NIGHTFALL quartic antipodal manuscript: exact Rademacher fourth moment.

Theorem 8(ii) of Wright, A quartic antipodal inequality, uses
E[(sum a_i epsilon_i)^4] = 3(sum a_i^2)^2 - 2 sum a_i^4
for independent fair signs. These declarations prove that exact
identity for arbitrary real coefficient lists via a recursively
defined expectation over all sign choices.

This alone does NOT establish the affine Q(3) antipodal inequality;
the certificate-row lower bound and reciprocal-weight comparison
remain separate proof obligations.
-/

namespace Nightfall.Quartic

/-- Exact expectation of a test function of a finite sum of independent
fair signs with coefficients in the supplied list. -/
def rademacherAvg : List ℝ → (ℝ → ℝ) → ℝ
  | [], φ => φ 0
  | a :: as, φ =>
      (rademacherAvg as (fun t => φ (t + a)) +
       rademacherAvg as (fun t => φ (t - a))) / 2

theorem rademacherAvg_add (as : List ℝ) :
    ∀ φ ψ : ℝ → ℝ,
      rademacherAvg as (fun t => φ t + ψ t) =
        rademacherAvg as φ + rademacherAvg as ψ := by
  induction as with
  | nil =>
      intro φ ψ
      simp [rademacherAvg]
  | cons a xs ih =>
      intro φ ψ
      change (rademacherAvg xs (fun t => φ (t+a) + ψ (t+a)) +
              rademacherAvg xs (fun t => φ (t-a) + ψ (t-a))) / 2 =
             (rademacherAvg xs (fun t => φ (t+a)) +
              rademacherAvg xs (fun t => φ (t-a))) / 2 +
             (rademacherAvg xs (fun t => ψ (t+a)) +
              rademacherAvg xs (fun t => ψ (t-a))) / 2
      rw [ih, ih]
      ring

theorem rademacherAvg_smul (as : List ℝ) :
    ∀ (c : ℝ) (φ : ℝ → ℝ),
      rademacherAvg as (fun t => c * φ t) =
        c * rademacherAvg as φ := by
  induction as with
  | nil =>
      intro c φ
      simp [rademacherAvg]
  | cons a xs ih =>
      intro c φ
      change (rademacherAvg xs (fun t => c * φ (t+a)) +
              rademacherAvg xs (fun t => c * φ (t-a))) / 2 =
             c * ((rademacherAvg xs (fun t => φ (t+a)) +
                   rademacherAvg xs (fun t => φ (t-a))) / 2)
      rw [ih, ih]
      ring

theorem rademacherAvg_const (as : List ℝ) :
    ∀ c : ℝ, rademacherAvg as (fun _ => c) = c := by
  induction as with
  | nil => intro c; simp [rademacherAvg]
  | cons a xs ih =>
      intro c
      change (rademacherAvg xs (fun _ => c) +
              rademacherAvg xs (fun _ => c)) / 2 = c
      rw [ih]
      ring

theorem rademacherAvg_ext (as : List ℝ) :
    ∀ (φ ψ : ℝ → ℝ), (∀ t, φ t = ψ t) →
      rademacherAvg as φ = rademacherAvg as ψ := by
  induction as with
  | nil =>
      intro φ ψ h
      exact h 0
  | cons a xs ih =>
      intro φ ψ h
      change (rademacherAvg xs (fun t => φ (t+a)) +
              rademacherAvg xs (fun t => φ (t-a))) / 2 =
             (rademacherAvg xs (fun t => ψ (t+a)) +
              rademacherAvg xs (fun t => ψ (t-a))) / 2
      rw [ih (fun t => φ (t+a)) (fun t => ψ (t+a)) (fun t => h (t+a))]
      rw [ih (fun t => φ (t-a)) (fun t => ψ (t-a)) (fun t => h (t-a))]

/-- Conditioning on the first sign amounts to averaging both shifts. -/
theorem rademacherAvg_cons (a : ℝ) (as : List ℝ) (φ : ℝ → ℝ) :
    rademacherAvg (a :: as) φ =
      (1 / 2 : ℝ) *
        rademacherAvg as (fun t => φ (t+a) + φ (t-a)) := by
  change (rademacherAvg as (fun t => φ (t+a)) +
          rademacherAvg as (fun t => φ (t-a))) / 2 =
         (1 / 2 : ℝ) *
           rademacherAvg as (fun t => φ (t+a) + φ (t-a))
  rw [rademacherAvg_add]
  ring

def squareEnergy (as : List ℝ) : ℝ :=
  (as.map fun a => a ^ 2).sum

def quarticEnergy (as : List ℝ) : ℝ :=
  (as.map fun a => a ^ 4).sum

/-- The exact variance of a sum of independent fair signed coefficients. -/
theorem rademacher_second_moment (as : List ℝ) :
    rademacherAvg as (fun t => t ^ 2) = squareEnergy as := by
  induction as with
  | nil => simp [rademacherAvg, squareEnergy]
  | cons a xs ih =>
      rw [rademacherAvg_cons]
      have hpoly :
          (fun t : ℝ => (t+a)^2 + (t-a)^2) =
          (fun t : ℝ => 2 * t^2 + 2 * a^2) := by
        funext t
        ring
      rw [hpoly, rademacherAvg_add]
      rw [rademacherAvg_smul, rademacherAvg_const]
      rw [ih]
      simp only [squareEnergy, List.map_cons, List.sum_cons]
      ring

/-- Exact fourth-moment recursion; the mixed third/first moment terms
cancel under the two fair orientations. -/
theorem rademacher_fourth_rec (a : ℝ) (as : List ℝ) :
    rademacherAvg (a :: as) (fun t => t ^ 4) =
      rademacherAvg as (fun t => t ^ 4) +
      6 * a ^ 2 * rademacherAvg as (fun t => t ^ 2) + a ^ 4 := by
  rw [rademacherAvg_cons]
  have hpoly :
      (fun t : ℝ => (t+a)^4 + (t-a)^4) =
      (fun t : ℝ => (2*t^4 + 12*a^2*t^2) + 2*a^4) := by
    funext t
    ring
  rw [hpoly, rademacherAvg_add, rademacherAvg_add]
  rw [rademacherAvg_smul, rademacherAvg_smul, rademacherAvg_const]
  ring

/-- Dimension-independent and exact fourth-moment identity used in the
quartic affine-conjecture argument. -/
theorem rademacher_fourth_moment (as : List ℝ) :
    rademacherAvg as (fun t => t ^ 4) =
      3 * (squareEnergy as) ^ 2 - 2 * quarticEnergy as := by
  induction as with
  | nil => simp [rademacherAvg, squareEnergy, quarticEnergy]
  | cons a xs ih =>
      rw [rademacher_fourth_rec]
      rw [ih, rademacher_second_moment]
      simp only [squareEnergy, quarticEnergy, List.map_cons, List.sum_cons]
      ring

theorem quarticEnergy_nonneg (as : List ℝ) : 0 ≤ quarticEnergy as := by
  induction as with
  | nil => simp [quarticEnergy]
  | cons a xs ih =>
      simp only [quarticEnergy, List.map_cons, List.sum_cons]
      have ha : 0 ≤ a ^ 4 := by positivity
      exact add_nonneg ha ih

/-- Optimal universal fourth-moment estimate for independent fair signs.
It does not by itself certify the antipodal reciprocal inequality Q(3). -/
theorem rademacher_fourth_upper (as : List ℝ) :
    rademacherAvg as (fun t => t ^ 4) ≤
      3 * (squareEnergy as) ^ 2 := by
  rw [rademacher_fourth_moment]
  have h := quarticEnergy_nonneg as
  linarith

end Nightfall.Quartic
