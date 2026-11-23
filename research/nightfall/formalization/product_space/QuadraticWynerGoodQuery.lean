import QuadraticWynerQuadraticProgress
import Route1WynerSimulation

/-!
# Quadratic Wyner QW+: original posterior good-query dichotomy

This is a source-connected compilation *attempt*, not a Lean certificate
until strict exact-head kernel replay succeeds. It combines:
 - actual finite maximal-star SeedCoupling of the original source,
 - exact source-component mixture mean/variance (no fake independent law),
 - proven Key Lemma squared mismatch,
 - label projection before Q2 (NO latent-coordinate degree+1 lift),
 - original source Jensen influence and increment conversion,
 - posterior real TV² information charge in the Wyner Info potential.

The output of quadratic_crux is a REAL unqueried coordinate. The terminal
must still instantiate GoodW in the actual wbuild and C_W infimum.
-/
namespace Nightfall.QuadraticWynerGoodQuery
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerSeedAverage
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

noncomputable def quadEta (τ : ℝ) : ℝ := τ / 2048
noncomputable def quadW0 (K τ : ℝ) : ℝ := τ / (8 * K)
noncomputable def quadGa (τ : ℝ) : ℝ := τ ^ 2 / (2 * quadraticC)
noncomputable def quadGb (K τ : ℝ) : ℝ := quadEta τ ^ 2 * quadW0 K τ

theorem quadEta_pos (τ : ℝ) (hτ : 0 < τ) : 0 < quadEta τ := by
  unfold quadEta
  positivity

theorem quadGa_pos (τ : ℝ) (hτ : 0 < τ) : 0 < quadGa τ := by
  unfold quadGa
  have := quadraticC_pos
  positivity

theorem quadGb_pos (K τ : ℝ) (hK : 0 < K) (hτ : 0 < τ) :
    0 < quadGb K τ := by
  unfold quadGb quadEta quadW0
  positivity

theorem quadDelta_budget (K τ : ℝ) (hK : 0 < K) :
    2 * K * quadW0 K τ + 128 * (2 : ℝ) ^ 2 * quadEta τ = τ / 2 := by
  unfold quadW0 quadEta
  field_simp
  ring

/-- Strictly original-coordinate QW+ crux for an arbitrary positive-mass
posterior, including source atoms of zero probability. -/
theorem quadratic_crux
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v)
    (g : (ι → α) → ℝ) (hg01 : ∀ x, 0 ≤ g x ∧ g x ≤ 1)
    (hdeg : HasProdDegreeLE g 2)
    (K : ℝ) (hK : 0 < K) (hrows : HasRows g K)
    (A : Finset ι) (hinv : ∀ i ∈ A, Inv g i)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1 / 4)
    (hvar : τ * Vs v < mvar P v g) :
    ∃ j : ι, j ∉ A ∧
      (quadGa τ * Vs v ≤ ∑ θ, v θ * pincr (P θ) g j ∨
       quadGb K τ * Vs v ≤
         ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2) := by
  classical
  set π : Θ → ℝ := fun θ => v θ / Vs v with hπdef
  have hπ0 : ∀ θ, 0 ≤ π θ := fun θ => div_nonneg (hv θ) hV.le
  have hπ1 : ∑ θ, π θ = 1 := by
    simp only [π]
    rw [← Finset.sum_div]
    exact div_self hV.ne'
  set q : ι → α → ℝ := qmix P v with hqdef
  obtain ⟨κ, hκ⟩ := seed_coupling_exists P hP0 hP1 q
    (fun j b => qmix_nonneg P hP0 v hv j b)
    (fun j => qmix_sum P hP1 v hV j)
  let r : ℝ := ∑ θ, π θ * pexp (P θ) g
  have hr : r = ∑ θ, π θ * pexp (P θ) g := rfl
  have hvareq :
      mvar P v g =
        Vs v * (∑ θ, π θ *
          pexp (P θ) (fun x => (g x - r) ^ 2)) := by
    simpa only [π, r] using mvar_eq P v hV g
  have hlarge : τ <
      ∑ θ, π θ * pexp (P θ) (fun x => (g x - r) ^ 2) := by
    by_contra hn
    have hle : (∑ θ, π θ *
      pexp (P θ) (fun x => (g x - r) ^ 2)) ≤ τ := le_of_not_gt hn
    have hm := mul_le_mul_of_nonneg_left hle hV.le
    rw [hvareq] at hvar
    nlinarith
  let η : ℝ := quadEta τ
  let w₀ : ℝ := quadW0 K τ
  have hη0 : 0 < η := quadEta_pos τ hτ
  have hηhalf : η ≤ 1 / 2 := by
    unfold quadEta at *
    linarith
  have hw0 : 0 ≤ w₀ := by
    dsimp [w₀, quadW0]
    positivity
  by_cases hbig : ∃ j : ι, j ∉ A ∧
      w₀ < ∑ θ, π θ * (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)
  · obtain ⟨j, hjA, hjbig⟩ := hbig
    refine ⟨j, hjA, Or.inr ?_⟩
    have hpt : ∀ θ, π θ *
        (η ^ 2 * (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)) ≤
        π θ * tvd (P θ j) (q j) ^ 2 := by
      intro θ
      refine mul_le_mul_of_nonneg_left ?_ (hπ0 θ)
      split_ifs with h
      · nlinarith
      · simp
        exact sq_nonneg _
    have hsum :
        η ^ 2 * (∑ θ, π θ *
          (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)) ≤
        ∑ θ, π θ * tvd (P θ j) (q j) ^ 2 := by
      calc
        _ = ∑ θ, π θ * (η ^ 2 *
          (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0)) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro θ _
            ring
        _ ≤ _ := Finset.sum_le_sum (fun θ _ => hpt θ)
    have hinformation : quadGb K τ <
        ∑ θ, π θ * tvd (P θ j) (q j) ^ 2 := by
      change η ^ 2 * w₀ < _
      have hη2 : 0 < η ^ 2 := sq_pos_of_pos hη0
      exact (mul_lt_mul_of_pos_left hjbig hη2).trans_le hsum
    have heq :
        ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 =
          Vs v * (∑ θ, π θ * tvd (P θ j) (q j) ^ 2) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro θ _
      simp only [π, q]
      field_simp
    rw [heq]
    exact (mul_le_mul_of_nonneg_left hinformation.le hV.le)
  · have hsmall : ∀ j, j ∉ A →
        ∑ θ, π θ * (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0) ≤ w₀ := by
      intro j hjA
      by_contra hn
      have hgt : w₀ < ∑ θ, π θ *
          (if η < tvd (P θ j) (q j) then (1 : ℝ) else 0) :=
        lt_of_not_ge hn
      exact hbig ⟨j, hjA, hgt⟩
    have hkey := key_lemma P q κ hκ π hπ0 hπ1
      g hg01 2 hdeg K hrows A hinv η hη0 hηhalf w₀ hw0 hsmall
    have hbudget :
        2 * K * w₀ + 128 * (2 : ℝ) ^ 2 * η = τ / 2 :=
      quadDelta_budget K τ hK
    rw [hbudget] at hkey
    have hseed : τ / 2 < pvar κ (seedAverage π g) :=
      seed_average_variance_survival P q κ hκ π hπ1 g r τ hr hτ hlarge hkey
    obtain ⟨j, hjA, hjinc⟩ := quadratic_original_increment_from_seed_variance
      P hP0 q κ hκ π hπ0 hπ1 g hg01 hdeg A hinv τ hτ hseed
    refine ⟨j, hjA, Or.inl ?_⟩
    have hsum :
        ∑ θ, v θ * pincr (P θ) g j =
          Vs v * (∑ θ, π θ * pincr (P θ) g j) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro θ _
      simp only [π]
      field_simp
    rw [hsum]
    change quadGa τ ≤ _ at hjinc
    exact mul_le_mul_of_nonneg_left hjinc hV.le

#print axioms Nightfall.QuadraticWynerGoodQuery.quadDelta_budget
#print axioms Nightfall.QuadraticWynerGoodQuery.quadratic_crux
end Nightfall.QuadraticWynerGoodQuery
