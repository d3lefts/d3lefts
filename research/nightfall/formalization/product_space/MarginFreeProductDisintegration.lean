import MarginFreeIntegrated

/-!
# Source-level product disintegration with zero atoms

Observed coordinates are sampled from the source product law and
unobserved coordinates are filled with a fixed dummy symbol. The
conditional pinned law then resamples the unobserved coordinates.
The resulting two-stage input has exactly the original product law.

This proves the global weighted-failure budgets of the low-TV branch
rather than treating them as abstract assumptions. All sums are finite;
no positive atom bound is required.
-/

namespace Nightfall.MarginFreeDisintegration

open Finset
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.MarginFreeIntegrated

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The canonical observation law: source marginals on A, fixed dummy
symbol off A. The resulting transcript is determined by its coordinates
in A, so a test of this law queries only A. -/
noncomputable def observedLaw (A : Finset ι) (a0 : α)
    (p : ι → α → ℝ) : ι → α → ℝ :=
  fun i a => if i ∈ A then p i a else delta a0 a

theorem observedLaw_nonneg (A : Finset ι) (a0 : α)
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) :
    ∀ i a, 0 ≤ observedLaw A a0 p i a := by
  intro i a
  by_cases h : i ∈ A
  · simpa [observedLaw, h] using hp i a
  · by_cases heq : a = a0
    · simp [observedLaw, h, delta, heq]
    · simp [observedLaw, h, delta, heq]

theorem observedLaw_sum_one (A : Finset ι) (a0 : α)
    (p : ι → α → ℝ) (hp : ∀ i, ∑ a, p i a = 1) :
    ∀ i, ∑ a, observedLaw A a0 p i a = 1 := by
  intro i
  by_cases h : i ∈ A
  · simpa [observedLaw, h] using hp i
  · simpa [observedLaw, h] using delta_sum a0

/-- Jointly drawing an observed transcript from P_A and resampling the
unobserved coordinates from their original product law reproduces the
exact product point mass. Source level, zero atoms included. -/
theorem observed_then_pin_mass (A : Finset ι) (a0 : α)
    (p : ι → α → ℝ) (y : ι → α) :
    (∑ x : ι → α, prodMass (observedLaw A a0 p) x *
        prodMass (pin A x p) y) = prodMass p y := by
  have hcollapse : ∀ i : ι,
      (∑ a : α, observedLaw A a0 p i a *
         (if i ∈ A then delta a (y i) else p i (y i))) = p i (y i) := by
    intro i
    by_cases hi : i ∈ A
    · simp [observedLaw, hi, delta, eq_comm]
    · simp [observedLaw, hi, ← Finset.sum_mul, delta_sum]
  have hfactor :
      (∑ x : ι → α, ∏ i : ι,
          (observedLaw A a0 p i (x i) *
           (if i ∈ A then delta (x i) (y i) else p i (y i)))) =
      ∏ i : ι, p i (y i) := by
    let F : ι → α → ℝ := fun i a =>
      observedLaw A a0 p i a *
        (if i ∈ A then delta a (y i) else p i (y i))
    change (∑ x : ι → α, ∏ i : ι, F i (x i)) =
      ∏ i : ι, p i (y i)
    rw [Nightfall.ProductSpace.RowBound.sum_prod_eq_prod_sum F]
    exact Finset.prod_congr rfl (fun i _ => hcollapse i)
  calc
    (∑ x : ι → α, prodMass (observedLaw A a0 p) x *
        prodMass (pin A x p) y)
      = ∑ x : ι → α, ∏ i : ι,
          (observedLaw A a0 p i (x i) *
           (if i ∈ A then delta (x i) (y i) else p i (y i))) := by
            apply Finset.sum_congr rfl
            intro x _
            simp only [prodMass, pin, Finset.prod_mul_distrib]
    _ = ∏ i : ι, p i (y i) := hfactor
    _ = prodMass p y := rfl

/-- Weighted conditional failure probabilities over all canonical
transcripts exactly reproduce the source's unconditional failure mass. -/
theorem observed_then_pin_failure (A : Finset ι) (a0 : α)
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (u ε : ℝ) :
    (∑ x : ι → α, prodMass (observedLaw A a0 p) x *
      pinnedFailure A x p f u ε) =
      (∑ y ∈ (Finset.univ : Finset (ι → α)).filter
         (fun y => ε < |f y - u|), prodMass p y) := by
  let bad := (Finset.univ : Finset (ι → α)).filter
    (fun y => ε < |f y - u|)
  change (∑ x : ι → α, prodMass (observedLaw A a0 p) x *
      (∑ y ∈ bad, prodMass (pin A x p) y)) =
        ∑ y ∈ bad, prodMass p y
  calc
    (∑ x : ι → α, prodMass (observedLaw A a0 p) x *
        (∑ y ∈ bad, prodMass (pin A x p) y)) =
      ∑ x : ι → α, ∑ y ∈ bad,
        prodMass (observedLaw A a0 p) x * prodMass (pin A x p) y := by
          simp_rw [Finset.mul_sum]
    _ = ∑ y ∈ bad, ∑ x : ι → α,
        prodMass (observedLaw A a0 p) x * prodMass (pin A x p) y :=
          Finset.sum_comm
    _ = ∑ y ∈ bad, prodMass p y :=
      Finset.sum_congr rfl (fun y _ => observed_then_pin_mass A a0 p y)

/-- Actual-source low-gap theorem: no abstract conditional means
or weighted failure hypotheses. The conclusion is the overlap of two
observed-law transcripts, which are determined solely by the coordinates
in A. The remaining high-gap finite-K selection is a separate theorem. -/
theorem observed_component_low_tv
    (A : Finset ι) (a0 : α) (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ ε : ℝ) (hγ : 0 < γ) (hε : 0 ≤ ε)
    (hsmall : ∀ i, i ∉ A → tvd (p i) (q i) ≤ γ)
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f d)
    (hbudget : 16 * (d : ℝ) ^ 2 * γ ≤ ε)
    (u v ρP ρQ : ℝ)
    (hu : 0 ≤ u ∧ u ≤ 1) (hv : 0 ≤ v ∧ v ≤ 1)
    (hsep : 3 * ε < |u - v|)
    (hfailP : ∑ y ∈ (Finset.univ : Finset (ι → α)).filter
         (fun y => ε < |f y - u|), prodMass p y ≤ ρP)
    (hfailQ : ∑ y ∈ (Finset.univ : Finset (ι → α)).filter
         (fun y => ε < |f y - v|), prodMass q y ≤ ρQ) :
    (∑ x : ι → α, min (prodMass (observedLaw A a0 p) x)
         (prodMass (observedLaw A a0 q) x)) ≤
      (ρP + ρQ) / (|u - v| - 3 * ε) := by
  apply weighted_pinned_component_overlap
    (Finset.univ : Finset (ι → α)) (fun x => x) p q
    hp0 hq0 hp1 hq1 A γ ε hγ hε hsmall
    d hd f hf hdegree hbudget
    (fun x => prodMass (observedLaw A a0 p) x)
    (fun x => prodMass (observedLaw A a0 q) x)
    u v ρP ρQ
    (fun x _ => prodMass_nonneg' (observedLaw A a0 p)
      (observedLaw_nonneg A a0 p hp0) x)
    (fun x _ => prodMass_nonneg' (observedLaw A a0 q)
      (observedLaw_nonneg A a0 q hq0) x)
    hu hv hsep
  · exact (observed_then_pin_failure A a0 p f u ε).symm ▸ hfailP
  · exact (observed_then_pin_failure A a0 q f v ε).symm ▸ hfailQ

end Nightfall.MarginFreeDisintegration
