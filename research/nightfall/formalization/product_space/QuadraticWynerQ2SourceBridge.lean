import EfronSteinDegree
import MixedDifferenceDegree
import ActualSourceQ223802Terminal

/-!
# QW finite original-product Q2 source bridge

This is a REAL source-interface result: the Route 1 original indicator
monomial degree and original resampling influence are identified with
the finite original-product Q2 terminal's ANOVA degree and heat-bath
influence, including zero-mass atoms. This does not yet prove the new
posterior coupling crux or the resulting QW decision-tree statement.
-/

namespace Nightfall.QuadraticWynerQ2SourceBridge

open Finset
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.MixedDifference
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Exact original-source influence normalization:
half the resampled squared increment equals original heat-bath energy. -/
theorem route1_influence_eq_q2_source
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    pinfl p f i = sourceInfluence p f i := by
  have h := dinfl_eq_heatBath (q := p) hp1 f i
  change pinfl p f i = sourceInfluence p f i at h
  exact h

/-- Exact original-source variance, same product measure and units. -/
theorem route1_variance_eq_q2_source
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) :
    pvar p f = sourceVariance p f := by
  rfl

/-- The complete C105.416 Q2 inequality with the EXACT Route 1
monomial-degree and Efron–Stein influence input predicates. -/
theorem quadratic_product_influence_on_route1_source
    (p : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f 2)
    (M : ℝ) (hM : 0 ≤ M)
    (hI : ∀ i, pinfl p f i ≤ M) :
    (pvar p f) ^ 2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2 * M := by
  have hES' := esDegree_of_prodDegree p f 2 hdegree
  have hES : Nightfall.Observability.ActualSourceANOVA.ESDegreeLE p f 2 := by
    exact hES'
  have hfB : ∀ x, |f x| ≤ (1 : ℝ) := by
    intro x
    exact abs_le.mpr ⟨by linarith [(hf01 x).1], (hf01 x).2⟩
  have hcap : ∀ i, sourceInfluence p f i ≤ M := by
    intro i
    rw [← route1_influence_eq_q2_source p hp1 f i]
    exact hI i
  have hQ := Nightfall.Observability.ActualSourceQ223802Terminal.actual_source_q2_23802_unconditional
    p hp0 hp1 f hES (1 : ℝ) (by norm_num) hfB M hM hcap
  rw [← route1_variance_eq_q2_source p f] at hQ
  simpa only [one_pow, one_mul, mul_one] using hQ

#print axioms Nightfall.QuadraticWynerQ2SourceBridge.route1_influence_eq_q2_source
#print axioms Nightfall.QuadraticWynerQ2SourceBridge.route1_variance_eq_q2_source
#print axioms Nightfall.QuadraticWynerQ2SourceBridge.quadratic_product_influence_on_route1_source
end Nightfall.QuadraticWynerQ2SourceBridge
