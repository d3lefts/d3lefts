import QuadraticWynerSeedAverage
import QuadraticWynerLabelProjection
import MixedDifferenceDegree

/-!
# NIGHTFALL: true-source Jensen influence transfer after label averaging

A source-connected proof attempt. The seed-letter resampling is under the
ACTUAL finite independent seed product; the label θ is held fixed across
both one-coordinate seed copies. Its component-coordinate law pushes to the
ORIGINAL physical component product Pθ, not an auxiliary reference Q.
Zero-mass atoms are allowed. No extra hidden-label oracle query is made.

The full posterior QW+ crux and Wyner DTree terminal remain separate gates.
-/
namespace Nightfall.QuadraticWynerSeedResampling

open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerLabelProjection
open Nightfall.QuadraticWynerSeedAverage
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

/-- Exact local update commutation for one fixed latent component. -/
theorem compOf_update (θ : Θ) (u : ι → Seed α Θ)
    (j : ι) (v : Seed α Θ) :
    compOf θ (Function.update u j v) =
      Function.update (compOf θ u) j (v.2 θ) := by
  funext i
  by_cases hi : i = j
  · subst i
    simp [compOf]
  · simp [compOf, Function.update_of_ne hi]

/-- The label-averaged resampling increment is exactly the weighted
mean of genuine component increments, with the same seed pair. -/
theorem seed_average_difference
    (π : Θ → ℝ) (g : (ι → α) → ℝ)
    (u : ι → Seed α Θ) (j : ι) (v : Seed α Θ) :
    seedAverage π g u - seedAverage π g (Function.update u j v) =
      ∑ θ, π θ *
        (g (compOf θ u) - g (compOf θ (Function.update u j v))) := by
  unfold seedAverage
  calc
    (∑ θ, π θ * g (compOf θ u)) -
        (∑ θ, π θ * g (compOf θ (Function.update u j v))) =
        ∑ θ, (π θ * g (compOf θ u) -
          π θ * g (compOf θ (Function.update u j v))) := by
            rw [Finset.sum_sub_distrib]
    _ = ∑ θ, π θ *
        (g (compOf θ u) - g (compOf θ (Function.update u j v))) := by
          apply Finset.sum_congr rfl
          intro θ _
          ring

/-- A one-coordinate independent seed heat-bath influence of one decoded
component is EXACTLY the original product-law influence of that component. -/
theorem pinfl_compOf_exact
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (θ : Θ) (g : (ι → α) → ℝ) (j : ι) :
    pinfl κ (fun u => g (compOf θ u)) j =
      pinfl (P θ) g j := by
  classical
  let Ψ : (ι → α) → ℝ :=
    fun x => ∑ b : α, P θ j b *
      ((g x - g (Function.update x j b)) ^ 2 / 2)
  have hfactor (u : ι → Seed α Θ) :
      (∑ v : Seed α Θ,
        prodMass κ u * κ j v *
          ((g (compOf θ u) -
            g (compOf θ (Function.update u j v))) ^ 2 / 2)) =
      prodMass κ u *
        (∑ v : Seed α Θ, κ j v *
          ((g (compOf θ u) -
            g (compOf θ (Function.update u j v))) ^ 2 / 2)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro v _
    ring
  have hinner (u : ι → Seed α Θ) :
      (∑ v : Seed α Θ, κ j v *
        ((g (compOf θ u) -
          g (compOf θ (Function.update u j v))) ^ 2 / 2)) =
      Ψ (compOf θ u) := by
    simp_rw [compOf_update]
    dsimp only [Ψ]
    rw [← Finset.sum_fiberwise univ (fun v : Seed α Θ => v.2 θ)]
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [← hκ.comp j θ b, Finset.sum_mul]
    refine Finset.sum_congr rfl fun v hv => ?_
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
    rw [hv]
  unfold pinfl
  simp only [hfactor, hinner]
  calc
    (∑ u : ι → Seed α Θ, prodMass κ u * Ψ (compOf θ u)) =
        pexp (P θ) Ψ := by
          simpa only [seedMass, pexp, prodMass] using
            seed_comp_pexp P q κ hκ θ Ψ
    _ = ∑ x : ι → α, ∑ b : α,
        prodMass (P θ) x * P θ j b *
          ((g x - g (Function.update x j b)) ^ 2 / 2) := by
          unfold pexp Ψ
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring

/-- L2 Jensen on one original coordinate, including zero-mass atoms:
the seed-average's actual seed influence is no greater than the
posterior-weighted ORIGINAL component source influences. -/
theorem seed_average_pinfl_le_original
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ) (j : ι) :
    pinfl κ (seedAverage π g) j ≤
      ∑ θ, π θ * pinfl (P θ) g j := by
  classical
  let Ω := (ι → Seed α Θ) × Seed α Θ
  let μ : Ω → ℝ := fun z => prodMass κ z.1 * κ j z.2 / 2
  let D : Θ → Ω → ℝ := fun θ z =>
    g (compOf θ z.1) - g (compOf θ (Function.update z.1 j z.2))
  have hμ0 : ∀ z : Ω, 0 ≤ μ z := by
    intro z
    dsimp [μ]
    have hu : 0 ≤ prodMass κ z.1 :=
      Finset.prod_nonneg (fun i _ => hκ.nonneg i (z.1 i))
    positivity
  have hleft :
      pinfl κ (seedAverage π g) j =
      ∑ z : Ω, μ z * (labelAverage π D z) ^ 2 := by
    unfold pinfl
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro u _
    apply Finset.sum_congr rfl
    intro v _
    have hd := seed_average_difference π g u j v
    dsimp [Ω, μ, D, labelAverage]
    rw [hd]
    ring
  have hright :
      (∑ θ, π θ * (∑ z : Ω, μ z * (D θ z) ^ 2)) =
      (∑ θ, π θ *
        pinfl κ (fun u => g (compOf θ u)) j) := by
    apply Finset.sum_congr rfl
    intro θ _
    apply congrArg (fun z : ℝ => π θ * z)
    unfold pinfl
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro u _
    apply Finset.sum_congr rfl
    intro v _
    dsimp [Ω, μ, D]
    ring
  calc
    pinfl κ (seedAverage π g) j ≤
        ∑ θ, π θ * pinfl κ (fun u => g (compOf θ u)) j := by
          rw [hleft, ← hright]
          exact weighted_expected_square_jensen π hπ0 hπ1 μ hμ0 D
    _ = ∑ θ, π θ * pinfl (P θ) g j := by
          exact Finset.sum_congr rfl fun θ _ => by
            rw [pinfl_compOf_exact P q κ hκ θ g j]

#print axioms Nightfall.QuadraticWynerSeedResampling.compOf_update
#print axioms Nightfall.QuadraticWynerSeedResampling.seed_average_difference
#print axioms Nightfall.QuadraticWynerSeedResampling.pinfl_compOf_exact
#print axioms Nightfall.QuadraticWynerSeedResampling.seed_average_pinfl_le_original
end Nightfall.QuadraticWynerSeedResampling
