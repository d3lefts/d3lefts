import GroupAdaptiveLikelihood

/-!
# A2 exact Bayes-risk source bridge from the genuine adaptive group oracle

This module removes the manuscript's *assumed* per-coordinate loss formula:
the normalized coordinate posterior is computed from the actual causal
group-observation likelihood; under nonzero transcript evidence the
posterior conditional squared loss of a fresh noisy sign equals the
irreducible noise floor plus β² (1-M²), M the posterior sign mean.

The universal expected stopping-time KL lower bound, its two-way
testing conversion and the constructive matching schedule remain separate.
-/

namespace Nightfall.GroupAdaptiveBayesRisk

open Finset
open Nightfall.GroupAdaptiveLikelihood

/-- The elementary binary posterior risk identity at unit mass. -/
theorem binary_sign_bayes_risk
    (pPlus pMinus beta : ℝ)
    (hmass : pPlus + pMinus = 1) :
    pPlus * (beta - beta * (pPlus - pMinus)) ^ 2 +
    pMinus * (-beta - beta * (pPlus - pMinus)) ^ 2 =
      beta ^ 2 * (1 - (pPlus - pMinus) ^ 2) := by
  calc
    _ = beta ^ 2 * ((pPlus + pMinus) *
        (1 + (pPlus - pMinus) ^ 2) -
        2 * (pPlus - pMinus) ^ 2) := by ring
    _ = beta ^ 2 * (1 - (pPlus - pMinus) ^ 2) := by
      rw [hmass]
      ring

/-- The actual fresh noisy ±1 target, conditional on a hidden sign nu=±1,
has an exact mean-square decomposition into intrinsic noise plus squared
conditional-sign prediction error. -/
theorem noisy_sign_conditional_loss
    (beta nu predictor : ℝ) (hnu : nu ^ 2 = 1) :
    ((1 + beta * nu) / 2) * (1 - beta * predictor) ^ 2 +
    ((1 - beta * nu) / 2) * (-1 - beta * predictor) ^ 2 =
      (1 - beta ^ 2) + beta ^ 2 * (nu - predictor) ^ 2 := by
  calc
    _ = 1 - 2 * beta ^ 2 * nu * predictor +
        beta ^ 2 * predictor ^ 2 := by ring
    _ = (1 - beta ^ 2) + beta ^ 2 * (nu - predictor) ^ 2 +
        beta ^ 2 * (1 - nu ^ 2) := by ring
    _ = (1 - beta ^ 2) + beta ^ 2 * (nu - predictor) ^ 2 := by
      rw [hnu]
      ring

/-- A posterior over a binary hidden sign, combined with the exact
fresh noisy observation kernel, produces the paper A2 risk formula.
This includes the irreducible model-noise floor. -/
theorem noisy_sign_posterior_risk
    (pPlus pMinus beta : ℝ)
    (hmass : pPlus + pMinus = 1) :
    let m := pPlus - pMinus
    pPlus * (
      ((1 + beta) / 2) * (1 - beta * m) ^ 2 +
      ((1 - beta) / 2) * (-1 - beta * m) ^ 2) +
    pMinus * (
      ((1 - beta) / 2) * (1 - beta * m) ^ 2 +
      ((1 + beta) / 2) * (-1 - beta * m) ^ 2) =
      (1 - beta ^ 2) + beta ^ 2 * (1 - m ^ 2) := by
  dsimp
  have hminus : pMinus = 1 - pPlus := by linarith
  rw [hminus]
  ring

/-- Posterior sign probabilities from any *actual legal adaptive group
transcript*, not supplied independent posterior marginals. The likelihood
normalizer must be nonzero to interpret conditioning. -/
theorem actual_coordinate_posterior_unit_mass
    {I Q : Type*} [Fintype I] [Fintype Q]
    [DecidableEq I] [DecidableEq Q]
    (G : Q → I → Prop) (beta : I → ℝ)
    (i : I) (h : History I Q)
    (hden : coordinateLikelihood G beta i true h +
        coordinateLikelihood G beta i false h ≠ 0) :
    coordinateLikelihood G beta i true h /
        (coordinateLikelihood G beta i true h +
         coordinateLikelihood G beta i false h) +
    coordinateLikelihood G beta i false h /
        (coordinateLikelihood G beta i true h +
         coordinateLikelihood G beta i false h) = 1 := by
  rw [← add_div]
  exact div_self hden

/-- Actual causal oracle -> conditional sign-target Bayes risk.
The only statistical premise is that this realised transcript has positive
normalizing evidence (expressed as a nonzero likelihood denominator). -/
theorem actual_group_transcript_bayes_risk
    {I Q : Type*} [Fintype I] [Fintype Q]
    [DecidableEq I] [DecidableEq Q]
    (G : Q → I → Prop) (beta : I → ℝ)
    (i : I) (h : History I Q)
    (hden : coordinateLikelihood G beta i true h +
        coordinateLikelihood G beta i false h ≠ 0) :
    let plus := coordinateLikelihood G beta i true h /
        (coordinateLikelihood G beta i true h +
         coordinateLikelihood G beta i false h)
    let minus := coordinateLikelihood G beta i false h /
        (coordinateLikelihood G beta i true h +
         coordinateLikelihood G beta i false h)
    let m := plus - minus
    plus * (
      ((1 + beta i) / 2) * (1 - beta i * m) ^ 2 +
      ((1 - beta i) / 2) * (-1 - beta i * m) ^ 2) +
    minus * (
      ((1 - beta i) / 2) * (1 - beta i * m) ^ 2 +
      ((1 + beta i) / 2) * (-1 - beta i * m) ^ 2) =
      (1 - (beta i) ^ 2) + (beta i) ^ 2 * (1 - m ^ 2) := by
  dsimp
  exact noisy_sign_posterior_risk
    (coordinateLikelihood G beta i true h /
      (coordinateLikelihood G beta i true h +
       coordinateLikelihood G beta i false h))
    (coordinateLikelihood G beta i false h /
      (coordinateLikelihood G beta i true h +
       coordinateLikelihood G beta i false h))
    (beta i)
    (actual_coordinate_posterior_unit_mass G beta i h hden)

/-- Positive mass of an actual *legal* grouped-oracle history forces every
coordinate likelihood normalizer to be nonzero: the global normalizer is
their product by the existing original-source transcript theorem. -/
theorem legal_transcript_coordinate_evidence_nonzero
    {I Q : Type*} [Fintype I] [Fintype Q]
    [DecidableEq I] [DecidableEq Q]
    (G : Q → I → Prop) (beta : I → ℝ)
    (policy : History I Q → Q) (h : History I Q)
    (hlegal : Legal policy h)
    (hglobal : (∑ nu : I → Bool,
      transcriptMass G beta policy nu h) ≠ 0)
    (i : I) :
    coordinateLikelihood G beta i true h +
      coordinateLikelihood G beta i false h ≠ 0 := by
  classical
  have hproduct : (∏ j : I,
      ∑ bit : Bool, coordinateLikelihood G beta j bit h) ≠ 0 := by
    rw [← hidden_normalizer_factorization G beta policy h hlegal]
    exact hglobal
  have hi : (∑ bit : Bool,
      coordinateLikelihood G beta i bit h) ≠ 0 := by
    intro hz
    apply hproduct
    apply Finset.prod_eq_zero (Finset.mem_univ i)
    exact hz
  simpa [Fintype.sum_bool, add_comm] using hi

/-- Original grouped-oracle *legal* history plus genuinely positive
global evidence suffices for the fresh-target Bayes-risk identity.
The coordinate nonzero premise is now proved, not separately assumed. -/
theorem legal_group_transcript_bayes_risk
    {I Q : Type*} [Fintype I] [Fintype Q]
    [DecidableEq I] [DecidableEq Q]
    (G : Q → I → Prop) (beta : I → ℝ)
    (policy : History I Q → Q) (h : History I Q)
    (hlegal : Legal policy h)
    (hglobal : (∑ nu : I → Bool,
      transcriptMass G beta policy nu h) ≠ 0)
    (i : I) :
    let plus := coordinateLikelihood G beta i true h /
        (coordinateLikelihood G beta i true h +
         coordinateLikelihood G beta i false h)
    let minus := coordinateLikelihood G beta i false h /
        (coordinateLikelihood G beta i true h +
         coordinateLikelihood G beta i false h)
    let m := plus - minus
    plus * (
      ((1 + beta i) / 2) * (1 - beta i * m) ^ 2 +
      ((1 - beta i) / 2) * (-1 - beta i * m) ^ 2) +
    minus * (
      ((1 - beta i) / 2) * (1 - beta i * m) ^ 2 +
      ((1 + beta i) / 2) * (-1 - beta i * m) ^ 2) =
      (1 - (beta i) ^ 2) + (beta i) ^ 2 * (1 - m ^ 2) := by
  exact actual_group_transcript_bayes_risk G beta i h
    (legal_transcript_coordinate_evidence_nonzero
      G beta policy h hlegal hglobal i)

end Nightfall.GroupAdaptiveBayesRisk

#print axioms Nightfall.GroupAdaptiveBayesRisk.binary_sign_bayes_risk
#print axioms Nightfall.GroupAdaptiveBayesRisk.noisy_sign_conditional_loss
#print axioms Nightfall.GroupAdaptiveBayesRisk.noisy_sign_posterior_risk
#print axioms Nightfall.GroupAdaptiveBayesRisk.actual_coordinate_posterior_unit_mass
#print axioms Nightfall.GroupAdaptiveBayesRisk.actual_group_transcript_bayes_risk

#print axioms Nightfall.GroupAdaptiveBayesRisk.legal_transcript_coordinate_evidence_nonzero
#print axioms Nightfall.GroupAdaptiveBayesRisk.legal_group_transcript_bayes_risk
