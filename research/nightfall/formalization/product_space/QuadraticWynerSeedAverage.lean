import Route1Lift
import QuadraticWynerLabelProjection

/-!
# NIGHTFALL: degree-preserving latent averaging on Route 1's real seeds

H(u) = E_theta[g(compOf theta u)] is a true function of independent seeds,
of the SAME original indicator interaction degree as g. Applying the
product rigidity theorem to H avoids the old latent-variable degree+1 lift.
The complete source-specific good-query terminal remains open.
-/
namespace Nightfall.QuadraticWynerSeedAverage
open Finset
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.QuadraticWynerLabelProjection

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

/-- Average out the latent label before applying product rigidity. -/
noncomputable def seedAverage
    (π : Θ → ℝ) (g : (ι → α) → ℝ) (u : ι → Seed α Θ) : ℝ :=
  ∑ θ, π θ * g (compOf θ u)

/-- No shared-label coordinate is introduced, so the degree remains d. -/
theorem seed_average_degree
    (π : Θ → ℝ) (g : (ι → α) → ℝ) (d : ℕ)
    (hdeg : HasProdDegreeLE g d) :
    HasProdDegreeLE (seedAverage π g) d := by
  classical
  have hcomponent (θ : Θ) :
      HasProdDegreeLE
        (fun u : ι → Seed α Θ => g (compOf θ u)) d := by
    exact deg_comp hdeg (fun v : Seed α Θ => v.2 θ)
  have hscaled (θ : Θ) :
      HasProdDegreeLE
        (fun u : ι → Seed α Θ => π θ * g (compOf θ u)) d :=
    deg_smul (π θ) (hcomponent θ)
  have hsum : Nightfall.Route1LatentDegree.DegreeLE
      (fun u : ι → Seed α Θ => ∑ θ, π θ * g (compOf θ u)) d := by
    apply Nightfall.Route1LatentDegree.degree_sum
    exact hscaled
  exact hsum

/-- Convex label averaging preserves the observable's [0,1] range. -/
theorem seed_average_bounded
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1) :
    ∀ u : ι → Seed α Θ,
      0 ≤ seedAverage π g u ∧ seedAverage π g u ≤ 1 := by
  intro u
  unfold seedAverage
  constructor
  · exact Finset.sum_nonneg (fun θ _ =>
      mul_nonneg (hπ0 θ) (hg01 (compOf θ u)).1)
  · calc
      (∑ θ, π θ * g (compOf θ u)) ≤ ∑ θ, π θ * 1 :=
        Finset.sum_le_sum (fun θ _ =>
          mul_le_mul_of_nonneg_left (hg01 (compOf θ u)).2 (hπ0 θ))
      _ = 1 := by simpa using hπ1

/-- The independent seed expectation is exactly the original mixture mean,
because the old SeedCoupling already certified each component marginal. -/
theorem seed_average_mean
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (g : (ι → α) → ℝ) :
    pexp κ (seedAverage π g) =
      ∑ θ, π θ * pexp (P θ) g := by
  calc
    pexp κ (seedAverage π g) =
        ∑ u : ι → Seed α Θ, seedMass κ u *
          labelAverage π (fun θ u => g (compOf θ u)) u := by
            rfl
    _ = ∑ θ, π θ *
          (∑ u : ι → Seed α Θ, seedMass κ u * g (compOf θ u)) :=
            weighted_sum_comm π (seedMass κ) (fun θ u => g (compOf θ u))
    _ = ∑ θ, π θ * pexp (P θ) g := by
            apply Finset.sum_congr rfl
            intro θ _
            rw [seed_comp_pexp P q κ hκ θ g]

/-- Original mixture second moments are exact joint seed second moments. -/
theorem seed_average_mixed_second_moment
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (g : (ι → α) → ℝ) (r : ℝ) :
    (∑ θ, π θ * pexp (P θ) (fun x => (g x - r) ^ 2)) =
      (∑ u : ι → Seed α Θ, seedMass κ u *
        ∑ θ, π θ * (g (compOf θ u) - r) ^ 2) := by
  symm
  calc
    (∑ u : ι → Seed α Θ, seedMass κ u *
      ∑ θ, π θ * (g (compOf θ u) - r) ^ 2) =
      ∑ θ, π θ * (∑ u : ι → Seed α Θ,
        seedMass κ u * (g (compOf θ u) - r) ^ 2) :=
          weighted_sum_comm π (seedMass κ)
            (fun θ u => (g (compOf θ u) - r) ^ 2)
    _ = ∑ θ, π θ * pexp (P θ) (fun x => (g x - r) ^ 2) := by
          apply Finset.sum_congr rfl
          intro θ _
          rw [seed_comp_pexp P q κ hκ θ (fun x => (g x - r) ^ 2)]


/-- Source-concrete exact variance survival under the Key Lemma's real
coupling cost, assuming only an explicit bound on that cost. The stronger
τ/2 threshold is valid because latent averaging removes the label
variance *before* applying product Q2. -/
theorem seed_average_variance_survival
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ) (r τ : ℝ)
    (hr : r = ∑ θ, π θ * pexp (P θ) g)
    (hτ : 0 < τ)
    (hlarge : τ <
      ∑ θ, π θ * pexp (P θ) (fun x => (g x - r) ^ 2))
    (hdelta :
      (∑ θ, π θ * ∑ u, seedMass κ u *
        (g (refOf u) - g (compOf θ u)) ^ 2) ≤ τ / 2) :
    τ / 2 < pvar κ (seedAverage π g) := by
  have hμ0 : ∀ u : ι → Seed α Θ, 0 ≤ seedMass κ u :=
    seedMass_nonneg κ hκ.nonneg
  have hlarge' :
      τ < (∑ u : ι → Seed α Θ, seedMass κ u *
        ∑ θ, π θ * (g (compOf θ u) - r) ^ 2) := by
    rw [← seed_average_mixed_second_moment P q κ hκ π g r]
    exact hlarge
  have hdelta' :
      (∑ u : ι → Seed α Θ, seedMass κ u *
        ∑ θ, π θ * (g (compOf θ u) - g (refOf u)) ^ 2) ≤ τ / 2 := by
    calc
      (∑ u : ι → Seed α Θ, seedMass κ u *
        ∑ θ, π θ * (g (compOf θ u) - g (refOf u)) ^ 2) =
        ∑ θ, π θ *
          (∑ u : ι → Seed α Θ, seedMass κ u *
            (g (compOf θ u) - g (refOf u)) ^ 2) :=
              weighted_sum_comm π (seedMass κ)
                (fun θ u => (g (compOf θ u) - g (refOf u)) ^ 2)
      _ = ∑ θ, π θ *
          (∑ u : ι → Seed α Θ, seedMass κ u *
            (g (refOf u) - g (compOf θ u)) ^ 2) := by
            apply Finset.sum_congr rfl
            intro θ _
            apply congrArg (fun z : ℝ => π θ * z)
            apply Finset.sum_congr rfl
            intro u _
            ring
      _ ≤ τ / 2 := hdelta
  have hsurvive := variance_survives_latent_averaging
    π hπ1 (seedMass κ) hμ0
    (fun θ u => g (compOf θ u)) (fun u => g (refOf u))
    r τ hτ hlarge' hdelta'
  have hmean : pexp κ (seedAverage π g) = r := by
    rw [seed_average_mean P q κ hκ π g]
    exact hr.symm
  change τ / 2 <
    ∑ u : ι → Seed α Θ, prodMass κ u *
      (seedAverage π g u - r) ^ 2 at hsurvive
  rw [← hmean] at hsurvive
  exact hsurvive

#print axioms Nightfall.QuadraticWynerSeedAverage.seed_average_variance_survival

#print axioms Nightfall.QuadraticWynerSeedAverage.seed_average_degree
#print axioms Nightfall.QuadraticWynerSeedAverage.seed_average_bounded
#print axioms Nightfall.QuadraticWynerSeedAverage.seed_average_mean
#print axioms Nightfall.QuadraticWynerSeedAverage.seed_average_mixed_second_moment
end Nightfall.QuadraticWynerSeedAverage
