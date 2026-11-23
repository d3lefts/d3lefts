import QuadraticWynerSeedResampling
import QuadraticWynerSeedAverage
import QuadraticWynerLabelProjection
import Route1PolylogSimulation

/-!
All-degree mean absolute increment from an ACTUAL degree-preserving
posterior independent seed product. Separate from degree-2 Q2 progress.
No new latent oracle symbol; no degree+1 lift. The final Wyner tree
and information dichotomy are not included in this module.
-/
namespace Nightfall.QuadraticWynerMeanIncrementProgress
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerLabelProjection
open Nightfall.QuadraticWynerSeedAverage
open Nightfall.QuadraticWynerSeedResampling
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

/-- Actual independent-seed absolute resampling equals the decoded
component's original coordinate increment; zero-mass atoms permitted. -/
theorem pincr_compOf_exact
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (θ : Θ) (g : (ι → α) → ℝ) (j : ι) :
    pincr κ (fun u => g (compOf θ u)) j =
      pincr (P θ) g j := by
  classical
  let Ψ : (ι → α) → ℝ :=
    fun x => ∑ b : α, P θ j b * |g x - g (Function.update x j b)|
  have hfactor (u : ι → Seed α Θ) :
      (∑ v : Seed α Θ,
        prodMass κ u * κ j v *
          |g (compOf θ u) -
            g (compOf θ (Function.update u j v))|) =
      prodMass κ u *
        (∑ v : Seed α Θ, κ j v *
          |g (compOf θ u) -
            g (compOf θ (Function.update u j v))|) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro v _
    ring
  have hinner (u : ι → Seed α Θ) :
      (∑ v : Seed α Θ, κ j v *
        |g (compOf θ u) -
          g (compOf θ (Function.update u j v))|) =
      Ψ (compOf θ u) := by
    simp_rw [compOf_update]
    dsimp only [Ψ]
    rw [← Finset.sum_fiberwise univ (fun v : Seed α Θ => v.2 θ)]
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [← hκ.comp j θ b, Finset.sum_mul]
    refine Finset.sum_congr rfl fun v hv => ?_
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
    rw [hv]
  unfold pincr
  simp only [hfactor, hinner]
  calc
    (∑ u : ι → Seed α Θ, prodMass κ u * Ψ (compOf θ u)) =
        pexp (P θ) Ψ := by
          simpa only [seedMass, pexp, prodMass] using
            seed_comp_pexp P q κ hκ θ Ψ
    _ = ∑ x : ι → α, ∑ b : α,
        prodMass (P θ) x * P θ j b *
          |g x - g (Function.update x j b)| := by
          unfold pexp Ψ
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring

/-- Jensen is paid at each original physical coordinate, not at
the hidden label or the reference marginals. -/
theorem seed_average_pincr_le_original
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (g : (ι → α) → ℝ) (j : ι) :
    pincr κ (seedAverage π g) j ≤
      ∑ θ, π θ * pincr (P θ) g j := by
  classical
  let Ω := (ι → Seed α Θ) × Seed α Θ
  let μ : Ω → ℝ := fun z => prodMass κ z.1 * κ j z.2
  let D : Θ → Ω → ℝ := fun θ z =>
    g (compOf θ z.1) - g (compOf θ (Function.update z.1 j z.2))
  have hμ0 : ∀ z : Ω, 0 ≤ μ z := by
    intro z
    dsimp [μ]
    have hu : 0 ≤ prodMass κ z.1 :=
      Finset.prod_nonneg (fun i _ => hκ.nonneg i (z.1 i))
    positivity
  have hleft :
      pincr κ (seedAverage π g) j =
      ∑ z : Ω, μ z * |labelAverage π D z| := by
    unfold pincr
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
      (∑ θ, π θ * (∑ z : Ω, μ z * |D θ z|)) =
      (∑ θ, π θ *
        pincr κ (fun u => g (compOf θ u)) j) := by
    apply Finset.sum_congr rfl
    intro θ _
    apply congrArg (fun z : ℝ => π θ * z)
    unfold pincr
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro u _
    apply Finset.sum_congr rfl
    intro v _
    dsimp [Ω, μ, D]
    ring
  calc
    pincr κ (seedAverage π g) j ≤
        ∑ θ, π θ * pincr κ (fun u => g (compOf θ u)) j := by
          rw [hleft, ← hright]
          exact weighted_expected_abs_jensen π hπ0 μ hμ0 D
    _ = ∑ θ, π θ * pincr (P θ) g j := by
          exact Finset.sum_congr rfl fun θ _ => by
            rw [pincr_compOf_exact P q κ hκ θ g j]

theorem original_pincr_inv
    (p : ι → α → ℝ) (g : (ι → α) → ℝ)
    (j : ι) (hj : Inv g j) :
    pincr p g j = 0 := by
  unfold pincr
  refine Finset.sum_eq_zero fun x _ => Finset.sum_eq_zero fun b _ => ?_
  rw [hj x b]
  ring

/-- Powered exact original-coordinate mean increment: the radical
bound and final tree are separate gates. -/
theorem mean_increment_original_source_energy
    (P : Θ → ι → α → ℝ)
    (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ)
    (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdegree : HasProdDegreeLE g d)
    (A : Finset ι) (hinv : ∀ j ∈ A, Inv g j)
    (τ : ℝ) (hτ : 0 < τ)
    (hvar : τ / 2 < pvar κ (seedAverage π g)) :
    ∃ j : ι, j ∉ A ∧
      (τ / 2) ^ 3 ≤
        144 * (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) ^ 4 *
          (∑ θ, π θ * pincr (P θ) g j) ^ 2 := by
  classical
  let H : (ι → Seed α Θ) → ℝ := seedAverage π g
  let K : ℝ := Real.pi ^ 2 * (d : ℝ) ^ 2 / 2
  have hdegreeH : HasProdDegreeLE H d :=
    seed_average_degree π g d hdegree
  have hboundH : ∀ u, 0 ≤ H u ∧ H u ≤ 1 :=
    seed_average_bounded π hπ0 hπ1 g hg01
  have hrow : HasRows H K :=
    hasRows_of_degree H d hboundH hdegreeH
  obtain ⟨a, ha, hbudget⟩ := hrow
  have hvpos : 0 < pvar κ H := by linarith
  obtain ⟨j, hj⟩ :=
    mean_increment κ hκ.nonneg hκ.total H a ha K hbudget hvpos
  have hLj0 : 0 ≤ pincr κ H j := pincr_nonneg κ hκ.nonneg H j
  have hLpos : 0 < pincr κ H j := by
    by_contra hno
    have heq : pincr κ H j = 0 := le_antisymm (le_of_not_gt hno) hLj0
    rw [heq] at hj
    have hv3 : 0 < (pvar κ H) ^ 3 := pow_pos hvpos 3
    norm_num at hj
    linarith
  have hjOrig : pincr κ H j ≤
      ∑ θ, π θ * pincr (P θ) g j :=
    seed_average_pincr_le_original P q κ hκ π hπ0 g j
  have hjOutside : j ∉ A := by
    intro hmem
    have hzero : ∀ θ, pincr (P θ) g j = 0 :=
      fun θ => original_pincr_inv (P θ) g j (hinv j hmem)
    have hz : (∑ θ, π θ * pincr (P θ) g j) = 0 := by
      simp only [hzero, mul_zero, Finset.sum_const_zero]
    rw [hz] at hjOrig
    linarith
  have hvar3 :
      (τ / 2) ^ 3 ≤ (pvar κ H) ^ 3 :=
    pow_le_pow_left₀ (by linarith) hvar.le 3
  have hpower :
      (pincr κ H j) ^ 2 ≤
        (∑ θ, π θ * pincr (P θ) g j) ^ 2 :=
    pow_le_pow_left₀ hLj0 hjOrig 2
  have hC0 : 0 ≤ 144 * K ^ 4 := by positivity
  refine ⟨j, hjOutside, ?_⟩
  calc
    (τ / 2) ^ 3 ≤ (pvar κ H) ^ 3 := hvar3
    _ ≤ 144 * K ^ 4 * (pincr κ H j) ^ 2 := hj
    _ ≤ 144 * K ^ 4 * (∑ θ, π θ * pincr (P θ) g j) ^ 2 :=
      mul_le_mul_of_nonneg_left hpower hC0

#print axioms Nightfall.QuadraticWynerMeanIncrementProgress.pincr_compOf_exact
#print axioms Nightfall.QuadraticWynerMeanIncrementProgress.seed_average_pincr_le_original
#print axioms Nightfall.QuadraticWynerMeanIncrementProgress.original_pincr_inv
#print axioms Nightfall.QuadraticWynerMeanIncrementProgress.mean_increment_original_source_energy
end Nightfall.QuadraticWynerMeanIncrementProgress
