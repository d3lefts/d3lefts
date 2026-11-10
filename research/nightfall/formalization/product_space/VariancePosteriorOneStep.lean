import CertificateCostBridge

/-!
# NIGHTFALL: finite-product variance to genuine posterior descent

Composes three separately compiled parts, with no manually assumed
reciprocal bound, localized overlap inequality, class positivity or
cost-to-variance estimate:
  * Turturean -> finite product localized two-sided theorem (#298)
  * concrete nonconstant certificate-overlap sampler (#304, #308)
  * certificate cost-to-expected crossing gain (#309)
  * product posterior resampling identity (#303)

The final theorem uses normalized strictly positive coordinate laws.
It gives the exact one-query *expected residual total directed
influence* bound. It does not claim that total influence equals mean
squared prediction error, or derive the multistep adaptive policy.
-/

namespace Nightfall.ProductSpace.Observation

open Finset Nightfall.ProductSpace Nightfall.ProductSpace.Transfer
  Nightfall.ProductSpace.Posterior

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The concrete certificate-overlap selection weight. -/
noncomputable def observationProbability
    (p : ι → α → ℝ) (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) (j : ι) : ℝ :=
  Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) /
    (∑ k, Real.sqrt (positiveLoad p g lam k * negativeLoad p g lam k))

/-- Total directed resampling boundary potential. -/
noncomputable def totalCrossingPotential
    (p : ι → α → ℝ) (g : (ι → α) → Bool) : ℝ :=
  ∑ k, crossingMass p g k

/-- The posterior total boundary potential after observing j=a.
Its observed-coordinate component is removed exactly. -/
noncomputable def remainingAt
    (p : ι → α → ℝ) (g : (ι → α) → Bool)
    (j : ι) (a : α) : ℝ :=
  ∑ k, posteriorEdge
    (pairMass p)
    (fun z : PairSample ι α => z.1 j)
    (p j) (edgeCross g) j a k

/-- First sample a coordinate by the certificate overlap and then
observe its response under the coordinate product law. -/
noncomputable def expectedPosteriorPotential
    (p : ι → α → ℝ) (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) : ℝ :=
  ∑ j, observationProbability p g lam j *
    (∑ a, p j a * remainingAt p g j a)

/-- The overlap sampler is a genuine probability distribution over
coordinates whenever both Boolean output classes are nonempty. -/
theorem observationProbability_sum_one
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (htrue : ∃ x, g x = true) (hfalse : ∃ x, g x = false) :
    (∑ j, observationProbability p g lam j) = 1 := by
  have hSpos := (nonconstant_finite_product_sampler
    p hp g lam hrow htrue hfalse).1
  unfold observationProbability
  rw [← Finset.sum_div]
  exact div_self hSpos.ne'

/-- For every queried coordinate j, posterior total influence averages
to the old total minus that coordinate's directed crossing mass. The
identity is genuine finite posterior arithmetic, not an ANOVA premise. -/
theorem posterior_total_at_coordinate
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (j : ι) :
    (∑ a, p j a * remainingAt p g j a) =
      totalCrossingPotential p g - crossingMass p g j := by
  unfold remainingAt totalCrossingPotential crossingMass
  exact posterior_total_mean
    (pairMass p)
    (fun z : PairSample ι α => z.1 j)
    (p j) (fun a => hp j a)
    (edgeCross g) j

/-- Purely exact finite-product identity: certificate-overlap observation
reduces average total resampling influence by the sampler's expected
directed influence. This is not merely a symbolic potential axiom. -/
theorem exact_certificate_posterior_decrement
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (htrue : ∃ x, g x = true) (hfalse : ∃ x, g x = false) :
    expectedPosteriorPotential p g lam =
      totalCrossingPotential p g -
        overlapSamplerExpectedInfluence p g lam := by
  have hsum := observationProbability_sum_one p hp g lam hrow htrue hfalse
  have hpost : ∀ j, (∑ a, p j a * remainingAt p g j a) =
      totalCrossingPotential p g - crossingMass p g j := by
    intro j
    exact posterior_total_at_coordinate p hp g j
  unfold expectedPosteriorPotential
  calc
    (∑ j, observationProbability p g lam j *
      ∑ a, p j a * remainingAt p g j a) =
      ∑ j, observationProbability p g lam j *
        (totalCrossingPotential p g - crossingMass p g j) := by
          apply Finset.sum_congr rfl
          intro j _
          rw [hpost j]
    _ = ∑ j, (totalCrossingPotential p g * observationProbability p g lam j -
          observationProbability p g lam j * crossingMass p g j) := by
          apply Finset.sum_congr rfl
          intro j _
          ring
    _ = totalCrossingPotential p g *
          (∑ j, observationProbability p g lam j) -
        ∑ j, observationProbability p g lam j * crossingMass p g j := by
          rw [Finset.sum_sub_distrib, Finset.mul_sum]
    _ = totalCrossingPotential p g -
        overlapSamplerExpectedInfluence p g lam := by
          rw [hsum]
          simp only [mul_one]
          rfl

/-- **The complete one-query variance-to-posterior bridge.**
With normalized strictly positive finite-product masses and valid
certificate rows bounded by K, the expected remaining directed
resampling influence is at most its previous value minus
the Boolean output variance / K².
This does not yet imply an MSE theorem without the degree/variance
relationship and a recursive identification of posterior states. -/
theorem normalized_one_step_certificate_to_observation
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (hprob : ∀ i, (∑ a, p i a) = 1)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (htrue : ∃ x, g x = true) (hfalse : ∃ x, g x = false)
    (K : ℝ) (hK : 0 < K)
    (hbounded : ∀ x, (∑ j, lam x j) ≤ K) :
    expectedPosteriorPotential p g lam ≤
      totalCrossingPotential p g -
        (positiveClassMass p g * negativeClassMass p g) / K ^ 2 := by
  have hdelta :=
    exact_certificate_posterior_decrement p hp g lam hrow htrue hfalse
  have hgain := nonconstant_variance_to_expected_influence
    p hp g lam hrow htrue hfalse K hK hbounded
  have hK2 : 0 < K ^ 2 := sq_pos_of_pos hK
  have hdiv :
      (positiveClassMass p g * negativeClassMass p g) / K ^ 2 ≤
        overlapSamplerExpectedInfluence p g lam := by
    apply (div_le_iff₀ hK2).2
    simpa [mul_comm] using hgain
  rw [hdelta]
  exact sub_le_sub_left hdiv _

end Nightfall.ProductSpace.Observation
