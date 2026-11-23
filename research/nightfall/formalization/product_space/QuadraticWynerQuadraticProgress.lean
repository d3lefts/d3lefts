import QuadraticWynerSeedResampling
import QuadraticWynerQ2SourceBridge
import Route1PolylogSimulation

/-!
# QW+: degree-two REAL source-coordinate query from latent-average variance

Once a normalized posterior's independent-seed label average has variance
exceeding τ/2, the original finite Q2 constant C2 gives an actual unqueried
ORIGINAL coordinate with expected real-component mean increment >=τ²/(2C2).

This source-level proof uses the genuine degree-preserving seed average,
actual source influence Jensen, and the already compiled source inequality
2*pinfl <= pincr. A complete QW theorem still needs variance survival
via the Key Lemma, the information alternative, and the Wyner DTree.
-/
namespace Nightfall.QuadraticWynerQuadraticProgress
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerSeedAverage
open Nightfall.QuadraticWynerSeedResampling
open Nightfall.QuadraticWynerQ2SourceBridge
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

noncomputable def quadraticC : ℝ :=
  ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2

theorem quadraticC_pos : 0 < quadraticC := by
  unfold quadraticC
  have h : 0 < (2 * (1 + Real.sqrt 2)) * Real.sqrt 3 +
      (11901 : ℝ) / 6250 := by positivity
  exact sq_pos_of_pos h

/-- The original-source Q2 branch produces a genuine unqueried coordinate.
No reference-law influence bound or Θ-oracle appears in the conclusion. -/
theorem quadratic_original_increment_from_seed_variance
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ)
    (hπ1 : ∑ θ, π θ = 1)
    (g : (ι → α) → ℝ)
    (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (hdeg : HasProdDegreeLE g 2)
    (A : Finset ι) (hinv : ∀ j ∈ A, Inv g j)
    (τ : ℝ) (hτ : 0 < τ)
    (hvar : τ / 2 < pvar κ (seedAverage π g)) :
    ∃ j : ι, j ∉ A ∧
      τ ^ 2 / (2 * quadraticC) ≤
        ∑ θ, π θ * pincr (P θ) g j := by
  classical
  have hC : 0 < quadraticC := quadraticC_pos
  let H : (ι → Seed α Θ) → ℝ := seedAverage π g
  let M : ℝ := τ ^ 2 / (4 * quadraticC)
  have hM0 : 0 ≤ M := by dsimp [M]; positivity
  have hHdegree : HasProdDegreeLE H 2 := seed_average_degree π g 2 hdeg
  have hHbound : ∀ u, 0 ≤ H u ∧ H u ≤ 1 :=
    seed_average_bounded π hπ0 hπ1 g hg01
  have hex : ∃ j : ι, M < pinfl κ H j := by
    by_contra hn
    push_neg at hn
    have hQ2 := quadratic_product_influence_on_route1_source
      κ hκ.nonneg hκ.total H hHbound hHdegree M hM0 hn
    have hQ2' : (pvar κ H) ^ 2 ≤ quadraticC * M := by
      simpa only [quadraticC] using hQ2
    have hCM : quadraticC * M = τ ^ 2 / 4 := by
      dsimp [M]
      field_simp
      ring
    have hpos : 0 < (pvar κ H - τ / 2) *
        (pvar κ H + τ / 2) :=
      mul_pos (by linarith) (by linarith)
    rw [hCM] at hQ2'
    nlinarith
  obtain ⟨j, hj⟩ := hex
  have hJ : pinfl κ H j ≤
      ∑ θ, π θ * pinfl (P θ) g j :=
    seed_average_pinfl_le_original P q κ hκ π hπ0 hπ1 g j
  have hinc : 2 * (∑ θ, π θ * pinfl (P θ) g j) ≤
      ∑ θ, π θ * pincr (P θ) g j := by
    calc
      2 * (∑ θ, π θ * pinfl (P θ) g j) =
        ∑ θ, π θ * (2 * pinfl (P θ) g j) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro θ _
          ring
      _ ≤ ∑ θ, π θ * pincr (P θ) g j :=
        Finset.sum_le_sum (fun θ _ =>
          mul_le_mul_of_nonneg_left
            (pinfl_le_half_pincr (P θ) (hP0 θ) g hg01 j) (hπ0 θ))
  have hjA : j ∉ A := by
    intro hmem
    have hz : ∀ θ, pinfl (P θ) g j = 0 :=
      fun θ => pinfl_inv (P θ) g j (hinv j hmem)
    have hzero : (∑ θ, π θ * pinfl (P θ) g j) = 0 := by
      simp only [hz, mul_zero, Finset.sum_const_zero]
    have hpos : 0 < pinfl κ H j := lt_trans (by dsimp [M]; positivity) hj
    linarith
  refine ⟨j, hjA, ?_⟩
  have hM : τ ^ 2 / (2 * quadraticC) = 2 * M := by
    dsimp [M]
    field_simp
    ring
  rw [hM]
  linarith

#print axioms Nightfall.QuadraticWynerQuadraticProgress.quadraticC_pos
#print axioms Nightfall.QuadraticWynerQuadraticProgress.quadratic_original_increment_from_seed_variance
end Nightfall.QuadraticWynerQuadraticProgress
