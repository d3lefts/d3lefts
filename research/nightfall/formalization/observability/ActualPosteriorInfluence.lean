import Mathlib

/-!
# NIGHTFALL: actual finite-product posterior resampling influence

An explicit observation transcript `s : ι → Option α` induces independent
conditional coordinate laws: unobserved coordinates retain their original
marginal and observed coordinates have Dirac marginals. Zero-mass atoms are
allowed; no conditioning on a null transcript is asserted.

This module checks:
* normalization and positivity of the actual finite posterior product law;
* exact equality of signed scalar resampling influence with the squared
  projection of Hilbert-coordinate resampling increments;
* a rank-factor fallback bound using the actual posterior sample weights.

The sharper v7 coherence factor and scalar influence theorem are SEPARATE
premises, not disguised as proofs in this module.
-/

namespace Nightfall.Observability.V7Actual

open Finset

variable {ι α κ : Type*}
variable [Fintype ι] [Fintype α] [Fintype κ]
variable [DecidableEq ι] [DecidableEq α]

/-- Explicit posterior marginal after the transcript fixes some coordinates. -/
noncomputable def posteriorLaw (p : ι → α → ℝ) (s : ι → Option α)
    (i : ι) (a : α) : ℝ :=
  match s i with
  | none => p i a
  | some b => if a = b then 1 else 0

/-- A posterior is a product of the original unobserved marginals and Diracs. -/
noncomputable def posteriorMass (p : ι → α → ℝ)
    (s : ι → Option α) (x : ι → α) : ℝ :=
  ∏ i : ι, posteriorLaw p s i (x i)

theorem posteriorLaw_nonneg
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (s : ι → Option α) (i : ι) (a : α) :
    0 ≤ posteriorLaw p s i a := by
  classical
  cases h : s i with
  | none => simpa [posteriorLaw, h] using hp i a
  | some b =>
      by_cases hab : a = b
      · simp [posteriorLaw, h, hab]
      · simp [posteriorLaw, h, hab]

theorem posteriorLaw_sum
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (s : ι → Option α) (i : ι) :
    (∑ a : α, posteriorLaw p s i a) = 1 := by
  classical
  cases h : s i with
  | none => simpa [posteriorLaw, h] using hp1 i
  | some b => simp [posteriorLaw, h]

theorem posteriorMass_nonneg
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (s : ι → Option α) (x : ι → α) :
    0 ≤ posteriorMass p s x := by
  unfold posteriorMass
  exact Finset.prod_nonneg (fun i _ => posteriorLaw_nonneg p hp s i (x i))

theorem posteriorMass_sum
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (s : ι → Option α) :
    (∑ x : ι → α, posteriorMass p s x) = 1 := by
  unfold posteriorMass
  have h :
    (∑ x : ι → α, ∏ i : ι, posteriorLaw p s i (x i)) =
      ∏ i : ι, ∑ a : α, posteriorLaw p s i a :=
        (Fintype.prod_sum (fun i (a : α) => posteriorLaw p s i a)).symm
  rw [h]
  simp [posteriorLaw_sum p hp1 s]

/-- Genuine Efron–Stein resampling influence for a scalar posterior section. -/
noncomputable def scalarResamplingInfluence
    (p : ι → α → ℝ) (s : ι → Option α)
    (h : (ι → α) → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, ∑ b : α,
    (posteriorMass p s x * posteriorLaw p s i b) *
      ((h x - h (Function.update x i b)) ^ 2 / 2)

/-- The actual squared resampling energy of a finite-rank Hilbert output. -/
noncomputable def vectorResamplingInfluence
    (p : ι → α → ℝ) (s : ι → Option α)
    (G : (ι → α) → κ → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, ∑ b : α,
    (posteriorMass p s x * posteriorLaw p s i b) *
      ((∑ j : κ, (G x j - G (Function.update x i b) j) ^ 2) / 2)

/-- Scalar influence is exactly the square of the signed vector increment
under the actual posterior resampling weights, not an abstract matrix axiom. -/
theorem signed_scalar_resampling_exact
    (p : ι → α → ℝ) (s : ι → Option α)
    (G : (ι → α) → κ → ℝ) (ε : κ → ℝ) (i : ι) :
    scalarResamplingInfluence p s
      (fun x => ∑ j : κ, ε j * G x j) i =
      ∑ x : ι → α, ∑ b : α,
        (posteriorMass p s x * posteriorLaw p s i b) *
          ((∑ j : κ, ε j * (G x j - G (Function.update x i b) j)) ^ 2 / 2) := by
  classical
  have hd (x : ι → α) (b : α) :
      (∑ j : κ, ε j * G x j) -
        (∑ j : κ, ε j * G (Function.update x i b) j) =
          ∑ j : κ, ε j * (G x j - G (Function.update x i b) j) := by
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro j _
    ring
  unfold scalarResamplingInfluence
  apply Finset.sum_congr rfl
  intro x _
  apply Finset.sum_congr rfl
  intro b _
  rw [hd x b]

/-- A checked unconditional rank-factor bound. The sharper coherence
factor requires the local PSD off-diagonal information from v7. -/
theorem signed_scalar_le_rank_vector
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (s : ι → Option α) (G : (ι → α) → κ → ℝ)
    (ε : κ → ℝ) (hε : ∀ j, ε j ^ 2 = 1) (i : ι) :
    scalarResamplingInfluence p s
      (fun x => ∑ j : κ, ε j * G x j) i ≤
        (Fintype.card κ : ℝ) * vectorResamplingInfluence p s G i := by
  classical
  rw [signed_scalar_resampling_exact]
  unfold vectorResamplingInfluence
  calc
    (∑ x : ι → α, ∑ b : α,
       (posteriorMass p s x * posteriorLaw p s i b) *
         ((∑ j : κ, ε j * (G x j - G (Function.update x i b) j)) ^ 2 / 2)) ≤
      ∑ x : ι → α, ∑ b : α,
        (posteriorMass p s x * posteriorLaw p s i b) *
          ((Fintype.card κ : ℝ) *
            (∑ j : κ, (G x j - G (Function.update x i b) j) ^ 2) / 2) := by
      apply Finset.sum_le_sum
      intro x _
      apply Finset.sum_le_sum
      intro b _
      have hc := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ) ε
        (fun j : κ => G x j - G (Function.update x i b) j)
      have hs : (∑ j : κ, ε j ^ 2) = (Fintype.card κ : ℝ) := by
        simp [hε]
      rw [hs] at hc
      apply mul_le_mul_of_nonneg_left
      · linarith
      · exact mul_nonneg (posteriorMass_nonneg p hp s x)
          (posteriorLaw_nonneg p hp s i b)
    _ = (Fintype.card κ : ℝ) *
         (∑ x : ι → α, ∑ b : α,
            (posteriorMass p s x * posteriorLaw p s i b) *
              ((∑ j : κ, (G x j - G (Function.update x i b) j) ^ 2) / 2)) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro b _
      ring

end Nightfall.Observability.V7Actual
