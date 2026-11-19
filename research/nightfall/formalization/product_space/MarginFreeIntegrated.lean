import PinnedConditionalStability
import MarginFreeCertificate

/-!
# Zero-atom component identification: integrated source-level low-gap theorem

The product expectation bound comes from the kernel proof in
`MixtureSimulation.fooling_tv`, and the concentration-to-mean bound
comes from explicit finite products and the previous certified
`ComponentIdentification.mean_near`.

No analytic Bernstein hypothesis or arbitrary small-mean-shift hypothesis
is exposed. The weighted global concentration budgets still enter as
explicit hypotheses: the remaining disintegration task is to prove these
budgets equal the original component failure probability for the selected
large-coordinate cells. The high-TV classification branch is separately
compiled in MarginFreeLargeGaps.
-/

namespace Nightfall.MarginFreeIntegrated

open Finset
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.PinnedConditional
open Nightfall.ProductSpace.RowBound
open Nightfall.ComponentIdentification
open Nightfall.MarginFreeCertificate

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Conditional failure mass under the pinned product distribution.
The expression is defined even for zero-probability original cells. -/
noncomputable def pinnedFailure (A : Finset ι) (ρ : ι → α)
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (u ε : ℝ) : ℝ :=
  ∑ x ∈ (Finset.univ : Finset (ι → α)).filter
      (fun x => ε < |f x - u|), prodMass (pin A ρ p) x

theorem pinned_failure_nonneg (A : Finset ι) (ρ : ι → α)
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (u ε : ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) :
    0 ≤ pinnedFailure A ρ p f u ε := by
  unfold pinnedFailure
  exact Finset.sum_nonneg (fun x _ =>
    prodMass_nonneg' (pin A ρ p) (pin_nonneg A ρ p hp0) x)

/-- The conditional mean-to-failure estimate is proved directly with
`mean_near` and the true pinned product mass, not a supplied hypothesis. -/
theorem pinned_failure_mean_near (A : Finset ι) (ρ : ι → α)
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (u ε : ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hu : 0 ≤ u ∧ u ≤ 1)
    (hε : 0 ≤ ε) :
    |pexp (pin A ρ p) f - u| ≤ ε + pinnedFailure A ρ p f u ε := by
  have hpinned0 := pin_nonneg A ρ p hp0
  have hpinned1 := pin_sum_one A ρ p hp1
  have hm := Nightfall.ComponentIdentification.mean_near
    (Finset.univ : Finset (ι → α))
    (fun x => prodMass (pin A ρ p) x) f u ε
    (fun x _ => prodMass_nonneg' (pin A ρ p) hpinned0 x)
    (by simpa using sum_prodMass (pin A ρ p) hpinned1)
    (fun x _ => hf x) hu hε
  simpa [pinnedFailure, pexp] using hm

/-- Fully sourced low-TV branch. The only remaining probabilistic inputs are
the two weighted *global* concentration budgets, rather than pointwise
conditional error assumptions. Compatible with arbitrary zero atom marginals. -/
theorem weighted_pinned_component_overlap
    {κ : Type*} (cells : Finset κ) (assign : κ → ι → α)
    (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (A : Finset ι) (γ ε : ℝ)
    (hγ : 0 < γ) (hε : 0 ≤ ε)
    (hsmall : ∀ i, i ∉ A → tvd (p i) (q i) ≤ γ)
    (d : ℕ) (hd : 1 ≤ d)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f d)
    (hbudget : 16 * (d : ℝ) ^ 2 * γ ≤ ε)
    (P Q : κ → ℝ) (u v ρP ρQ : ℝ)
    (hP : ∀ x ∈ cells, 0 ≤ P x) (hQ : ∀ x ∈ cells, 0 ≤ Q x)
    (hu : 0 ≤ u ∧ u ≤ 1) (hv : 0 ≤ v ∧ v ≤ 1)
    (hsep : 3 * ε < |u - v|)
    (hfailP : ∑ x ∈ cells,
        P x * pinnedFailure A (assign x) p f u ε ≤ ρP)
    (hfailQ : ∑ x ∈ cells,
        Q x * pinnedFailure A (assign x) q f v ε ≤ ρQ) :
    ∑ x ∈ cells, min (P x) (Q x) ≤
      (ρP + ρQ) / (|u - v| - 3 * ε) := by
  apply Nightfall.MarginFreeCertificate.weighted_overlap
    cells P Q
    (fun x => pinnedFailure A (assign x) p f u ε)
    (fun x => pinnedFailure A (assign x) q f v ε)
    (fun x => pexp (pin A (assign x) p) f)
    (fun x => pexp (pin A (assign x) q) f)
    u v ε ρP ρQ hP hQ
  · intro x _
    exact pinned_failure_nonneg A (assign x) p f u ε hp0
  · intro x _
    exact pinned_failure_nonneg A (assign x) q f v ε hq0
  · intro x _
    exact pinned_small_mean_shift A (assign x)
      p q hp0 hq0 hp1 hq1 γ ε hγ hsmall d hd
      f hf hdegree hbudget
  · intro x _
    exact pinned_failure_mean_near A (assign x) p f u ε
      hp0 hp1 hf hu hε
  · intro x _
    exact pinned_failure_mean_near A (assign x) q f v ε
      hq0 hq1 hf hv hε
  · exact hsep
  · exact hfailP
  · exact hfailQ

end Nightfall.MarginFreeIntegrated
