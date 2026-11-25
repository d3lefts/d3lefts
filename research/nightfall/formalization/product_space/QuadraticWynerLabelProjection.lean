import Mathlib

/-!
# NIGHTFALL: independent finite-label projection before quadratic rigidity

This source-free algebra makes the key operator shift reusable: average the
latent label *before* applying the product influence inequality. The variance
lost to that averaging is bounded by the existing squared Key Lemma coupling
with any seed-measurable reference.

Only algebraic finite-probability lemmas are proved here. They do NOT yet
instantiate the actual Route 1 seed law, source variance, source degree or
adaptive decision tree. No custom axioms, sorry or externally assumed theorem.
-/

namespace Nightfall.QuadraticWynerLabelProjection

open Finset

variable {Θ U : Type} [Fintype Θ] [Fintype U]

/-- The conditional expectation of a table over the latent label. -/
noncomputable def labelAverage (π : Θ → ℝ) (F : Θ → U → ℝ) (u : U) : ℝ :=
  ∑ θ, π θ * F θ u

/-- Weighted ANOVA identity at a single seed atom.  This is exact and
does not require the weights to be strictly positive. -/
theorem weighted_centered_square_identity
    (π : Θ → ℝ) (hπ1 : ∑ θ, π θ = 1)
    (x : Θ → ℝ) (r : ℝ) :
    ∑ θ, π θ * (x θ - r) ^ 2 =
      (∑ θ, π θ * (x θ - ∑ θ', π θ' * x θ') ^ 2) +
        (∑ θ, π θ * x θ - r) ^ 2 := by
  classical
  let m : ℝ := ∑ θ, π θ * x θ
  have hcenter : ∑ θ, π θ * (x θ - m) = 0 := by
    calc
      ∑ θ, π θ * (x θ - m) =
          ∑ θ, (π θ * x θ - π θ * m) := by
            apply Finset.sum_congr rfl
            intro θ _
            ring
      _ = (∑ θ, π θ * x θ) - (∑ θ, π θ) * m := by
            rw [Finset.sum_sub_distrib, Finset.sum_mul]
      _ = 0 := by rw [hπ1]; dsimp [m]; ring
  have hpoint (θ : Θ) :
      π θ * (x θ - r) ^ 2 =
        π θ * (x θ - m) ^ 2 +
          2 * (m - r) * (π θ * (x θ - m)) +
          (m - r) ^ 2 * π θ := by ring
  calc
    (∑ θ, π θ * (x θ - r) ^ 2) =
        ∑ θ, (π θ * (x θ - m) ^ 2 +
          2 * (m - r) * (π θ * (x θ - m)) +
          (m - r) ^ 2 * π θ) := by
          exact Finset.sum_congr rfl (fun θ _ => hpoint θ)
    _ = (∑ θ, π θ * (x θ - m) ^ 2) +
        2 * (m - r) * (∑ θ, π θ * (x θ - m)) +
        (m - r) ^ 2 * (∑ θ, π θ) := by
          simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    _ = (∑ θ, π θ * (x θ - m) ^ 2) + (m - r) ^ 2 := by
          rw [hcenter, hπ1]
          ring
    _ = (∑ θ, π θ * (x θ - ∑ θ', π θ' * x θ') ^ 2) +
        (∑ θ, π θ * x θ - r) ^ 2 := by
          dsimp [m]

/-- Exact weighted Jensen for squared conditional resampling increments. -/
theorem weighted_square_jensen
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1) (x : Θ → ℝ) :
    (∑ θ, π θ * x θ) ^ 2 ≤ ∑ θ, π θ * (x θ) ^ 2 := by
  have hh := weighted_centered_square_identity π hπ1 x 0
  have hn : 0 ≤ ∑ θ, π θ * (x θ - ∑ θ', π θ' * x θ') ^ 2 :=
    Finset.sum_nonneg (fun θ _ => mul_nonneg (hπ0 θ) (sq_nonneg _))
  simp only [sub_zero] at hh
  linarith


/-- Exact interchange of a finite latent average and an arbitrary finite
seed expectation. No conditional-independence approximation is introduced. -/
theorem weighted_sum_comm
    (π : Θ → ℝ) (μ : U → ℝ) (F : Θ → U → ℝ) :
    (∑ u, μ u * labelAverage π F u) =
      ∑ θ, π θ * (∑ u, μ u * F θ u) := by
  classical
  unfold labelAverage
  calc
    (∑ u, μ u * (∑ θ, π θ * F θ u)) =
        ∑ u, ∑ θ, μ u * (π θ * F θ u) := by
          apply Finset.sum_congr rfl
          intro u _
          rw [Finset.mul_sum]
    _ = ∑ θ, ∑ u, μ u * (π θ * F θ u) := Finset.sum_comm
    _ = ∑ θ, π θ * (∑ u, μ u * F θ u) := by
          apply Finset.sum_congr rfl
          intro θ _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro u _
          ring

/-- Convex absolute-value bound for the mean increment of a label-averaged
target. This is valid for all nonnegative finite latent masses, including
zeros. -/
theorem weighted_abs_jensen
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (x : Θ → ℝ) :
    |∑ θ, π θ * x θ| ≤ ∑ θ, π θ * |x θ| := by
  calc
    |∑ θ, π θ * x θ| ≤ ∑ θ, |π θ * x θ| :=
      Finset.abs_sum_le_sum_abs _ _
    _ = ∑ θ, π θ * |x θ| := by
          apply Finset.sum_congr rfl
          intro θ _
          rw [abs_mul, abs_of_nonneg (hπ0 θ)]


/-- Jensen for finite label averaging inside any nonnegative seed-weighted
quadratic functional. This supplies the source product-resampling influence
step once the exact source pushforward is established. -/
theorem weighted_expected_square_jensen
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1)
    (μ : U → ℝ) (hμ0 : ∀ u, 0 ≤ μ u)
    (F : Θ → U → ℝ) :
    (∑ u, μ u * (labelAverage π F u) ^ 2) ≤
      ∑ θ, π θ * (∑ u, μ u * (F θ u) ^ 2) := by
  calc
    (∑ u, μ u * (labelAverage π F u) ^ 2) ≤
      ∑ u, μ u * (labelAverage π (fun θ u => (F θ u) ^ 2) u) := by
        apply Finset.sum_le_sum
        intro u _
        exact mul_le_mul_of_nonneg_left
          (weighted_square_jensen π hπ0 hπ1 (fun θ => F θ u)) (hμ0 u)
    _ = ∑ θ, π θ * (∑ u, μ u * (F θ u) ^ 2) :=
      weighted_sum_comm π μ (fun θ u => (F θ u) ^ 2)

/-- Jensen for nonnegative-weighted absolute seed increments. -/
theorem weighted_expected_abs_jensen
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (μ : U → ℝ) (hμ0 : ∀ u, 0 ≤ μ u)
    (F : Θ → U → ℝ) :
    (∑ u, μ u * |labelAverage π F u|) ≤
      ∑ θ, π θ * (∑ u, μ u * |F θ u|) := by
  calc
    (∑ u, μ u * |labelAverage π F u|) ≤
      ∑ u, μ u * labelAverage π (fun θ u => |F θ u|) u := by
        apply Finset.sum_le_sum
        intro u _
        exact mul_le_mul_of_nonneg_left
          (weighted_abs_jensen π hπ0 (fun θ => F θ u)) (hμ0 u)
    _ = ∑ θ, π θ * (∑ u, μ u * |F θ u|) :=
      weighted_sum_comm π μ (fun θ u => |F θ u|)

/-- Exact source-independent conditional variance decomposition.
No normalization or positivity of the seed masses is needed for the
identity; those are required later to interpret it as a probability law. -/
theorem weighted_total_variance
    (π : Θ → ℝ) (hπ1 : ∑ θ, π θ = 1)
    (μ : U → ℝ) (F : Θ → U → ℝ) (r : ℝ) :
    (∑ u, μ u * ∑ θ, π θ * (F θ u - r) ^ 2) =
      (∑ u, μ u * (labelAverage π F u - r) ^ 2) +
      (∑ u, μ u * ∑ θ, π θ * (F θ u - labelAverage π F u) ^ 2) := by
  classical
  calc
    (∑ u, μ u * ∑ θ, π θ * (F θ u - r) ^ 2) =
        ∑ u, (μ u * (labelAverage π F u - r) ^ 2 +
          μ u * ∑ θ, π θ * (F θ u - labelAverage π F u) ^ 2) := by
          apply Finset.sum_congr rfl
          intro u _
          have h := weighted_centered_square_identity π hπ1 (fun θ => F θ u) r
          dsimp [labelAverage]
          rw [h]
          ring
    _ = (∑ u, μ u * (labelAverage π F u - r) ^ 2) +
      (∑ u, μ u * ∑ θ, π θ * (F θ u - labelAverage π F u) ^ 2) := by
          rw [Finset.sum_add_distrib]

/-- At each seed, the latent conditional mean minimizes squared error
among all reference values depending only on that seed. -/
theorem weighted_fiber_variance_le_reference
    (π : Θ → ℝ) (hπ1 : ∑ θ, π θ = 1)
    (μ : U → ℝ) (hμ0 : ∀ u, 0 ≤ μ u)
    (F : Θ → U → ℝ) (R : U → ℝ) :
    (∑ u, μ u * ∑ θ, π θ * (F θ u - labelAverage π F u) ^ 2) ≤
      (∑ u, μ u * ∑ θ, π θ * (F θ u - R u) ^ 2) := by
  classical
  apply Finset.sum_le_sum
  intro u _
  have h := weighted_centered_square_identity π hπ1 (fun θ => F θ u) (R u)
  have hbound :
      (∑ θ, π θ * (F θ u - labelAverage π F u) ^ 2) ≤
        (∑ θ, π θ * (F θ u - R u) ^ 2) := by
    dsimp [labelAverage]
    nlinarith [h, sq_nonneg ((∑ θ, π θ * F θ u) - R u)]
  exact mul_le_mul_of_nonneg_left hbound (hμ0 u)

/-- Improved QW variance survival: a reference-source Key Lemma bound
of Δ ≤ τ/2 is already sufficient. The old quadratic-variance transfer
required Δ=O(τ²/C2), losing three powers of τ in the information charge. -/
theorem variance_survives_latent_averaging
    (π : Θ → ℝ) (hπ1 : ∑ θ, π θ = 1)
    (μ : U → ℝ) (hμ0 : ∀ u, 0 ≤ μ u)
    (F : Θ → U → ℝ) (R : U → ℝ) (r τ : ℝ)
    (hτ : 0 < τ)
    (hvariance :
      τ < ∑ u, μ u * ∑ θ, π θ * (F θ u - r) ^ 2)
    (hDelta :
      (∑ u, μ u * ∑ θ, π θ * (F θ u - R u) ^ 2) ≤ τ / 2) :
    τ / 2 < ∑ u, μ u * (labelAverage π F u - r) ^ 2 := by
  have hdec := weighted_total_variance π hπ1 μ F r
  have hfib := weighted_fiber_variance_le_reference π hπ1 μ hμ0 F R
  linarith

#print axioms Nightfall.QuadraticWynerLabelProjection.weighted_centered_square_identity
#print axioms Nightfall.QuadraticWynerLabelProjection.weighted_square_jensen
#print axioms Nightfall.QuadraticWynerLabelProjection.weighted_sum_comm
#print axioms Nightfall.QuadraticWynerLabelProjection.weighted_abs_jensen
#print axioms Nightfall.QuadraticWynerLabelProjection.weighted_total_variance
#print axioms Nightfall.QuadraticWynerLabelProjection.weighted_fiber_variance_le_reference
#print axioms Nightfall.QuadraticWynerLabelProjection.variance_survives_latent_averaging

end Nightfall.QuadraticWynerLabelProjection
