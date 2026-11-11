import Mathlib

/-!
NIGHTFALL universal spectral observability: necessary ANOVA energy and
finite-horizon stopping interfaces. This module does NOT assume or certify
the missing Hilbert random-sign bound, measurable conditional expectations,
or the validity of posterior drift for the actual observation policy.
-/

namespace Nightfall.Observability.Universal
open Finset
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def energyVariance (E : Finset ι → ℝ) : ℝ :=
  ∑ S : Finset ι, E S

def energyPotential (E : Finset ι → ℝ) : ℝ :=
  ∑ S : Finset ι, (S.card : ℝ) * E S

theorem energy_le_potential (E : Finset ι → ℝ)
    (hE : ∀ S, 0 ≤ E S) (hzero : E ∅ = 0) :
    energyVariance E ≤ energyPotential E := by
  unfold energyVariance energyPotential
  apply Finset.sum_le_sum
  intro S _
  by_cases hs : S = ∅
  · simp [hs, hzero]
  · have hne : S.Nonempty := Finset.nonempty_iff_ne_empty.mpr hs
    have hc_nat : 1 ≤ S.card := by
      have hp : 0 < S.card := Finset.card_pos.mpr hne
      omega
    have hc : (1 : ℝ) ≤ (S.card : ℝ) := by exact_mod_cast hc_nat
    have hmul : 0 ≤ ((S.card : ℝ) - 1) * E S :=
      mul_nonneg (sub_nonneg.mpr hc) (hE S)
    nlinarith

theorem potential_le_degree_variance (E : Finset ι → ℝ) (d : ℕ)
    (hE : ∀ S, 0 ≤ E S)
    (hdegree : ∀ S, d < S.card → E S = 0) :
    energyPotential E ≤ (d : ℝ) * energyVariance E := by
  unfold energyVariance energyPotential
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro S _
  by_cases hs : S.card ≤ d
  · have hc : (S.card : ℝ) ≤ (d : ℝ) := by exact_mod_cast hs
    have hmul : 0 ≤ ((d : ℝ) - (S.card : ℝ)) * E S :=
      mul_nonneg (sub_nonneg.mpr hc) (hE S)
    nlinarith
  · have hz : E S = 0 := hdegree S (by omega)
    simp [hz]

theorem energy_sandwich (E : Finset ι → ℝ) (d : ℕ)
    (hE : ∀ S, 0 ≤ E S) (hzero : E ∅ = 0)
    (hdegree : ∀ S, d < S.card → E S = 0) :
    energyVariance E ≤ energyPotential E ∧
      energyPotential E ≤ (d : ℝ) * energyVariance E := by
  exact ⟨energy_le_potential E hE hzero,
    potential_le_degree_variance E d hE hdegree⟩

theorem unit_drift_telescopes (P : ℕ → ℝ) :
    ∀ n : ℕ, (∀ t < n, P (t + 1) + 1 ≤ P t) →
      P n + (n : ℝ) ≤ P 0 := by
  intro n
  induction n with
  | zero =>
      intro _
      simp
  | succ n ih =>
      intro hstep
      have hprev : ∀ t < n, P (t + 1) + 1 ≤ P t := by
        intro t ht
        exact hstep t (Nat.lt_trans ht (Nat.lt_succ_self n))
      have hb := ih hprev
      have hs := hstep n (Nat.lt_succ_self n)
      simp only [Nat.cast_succ]
      linarith

theorem budget_forces_target (V P : ℕ → ℝ) (η : ℝ) (N : ℕ)
    (hV : Antitone V)
    (hbudget : P 0 ≤ (N : ℝ))
    (hpositive : η < V N → 0 < P N)
    (hstep : ∀ t < N, η < V t → P (t + 1) + 1 ≤ P t) :
    V N ≤ η := by
  by_contra hbad
  have hVN : η < V N := lt_of_not_ge hbad
  have hdesc : ∀ t < N, P (t + 1) + 1 ≤ P t := by
    intro t ht
    have hle : V N ≤ V t := hV (Nat.le_of_lt ht)
    exact hstep t ht (lt_of_lt_of_le hVN hle)
  have htel := unit_drift_telescopes P N hdesc
  have hp := hpositive hVN
  linarith

end Nightfall.Observability.Universal
