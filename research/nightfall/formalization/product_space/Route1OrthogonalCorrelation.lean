import Mathlib

/-! Finite orthogonal correlation mechanism. Norm preservation is the
isometric form of orthogonality; conditional means and entropy are not
identified with a source law by this module. The sharp entropy composition
takes the precise convexity and entropy-identity obligations explicitly. -/

open Finset Real
namespace Nightfall.Route1OrthogonalCorrelation

variable {I W : Type*} [Fintype I] [Fintype W]

def energy (a : I → ℝ) : ℝ := ∑ i, (a i)^2

def score (a b : I → ℝ) : ℝ := ∑ i, a i * b i

/-- Orthogonal correlation cannot exceed the mean of the two energies. -/
theorem twice_score_le_energy (U : (I → ℝ) → (I → ℝ))
    (hU : ∀ b, energy (U b) = energy b) (a b : I → ℝ) :
    2 * score a (U b) ≤ energy a + energy b := by
  rw [← hU b]
  unfold score energy
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  nlinarith [sq_nonneg (a i - U b i)]

/-- Arbitrary nonnegative finite latent weights; one block carries the
entire correlation-energy lower bound. -/
theorem one_block_energy (U : (I → ℝ) → (I → ℝ))
    (hU : ∀ b, energy (U b) = energy b)
    (w : W → ℝ) (hw : ∀ t, 0 ≤ w t)
    (a b : W → I → ℝ) (C : ℝ)
    (hc : C ≤ ∑ t, w t * score (a t) (U (b t))) :
    C ≤ ∑ t, w t * energy (a t) ∨
    C ≤ ∑ t, w t * energy (b t) := by
  have h : 2 * (∑ t, w t * score (a t) (U (b t))) ≤
      (∑ t, w t * energy (a t)) + ∑ t, w t * energy (b t) := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_le_sum
    intro t _
    have h' := mul_le_mul_of_nonneg_left (twice_score_le_energy U hU (a t) (b t)) (hw t)
    linarith
  by_contra hn
  push_neg at hn
  linarith

/-- Sharp binary-entropy deficit as a function of squared conditional bias. -/
noncomputable def psi (s : ℝ) : ℝ :=
  Real.log 2 - (negMulLog ((1 + Real.sqrt s) / 2) +
    negMulLog ((1 - Real.sqrt s) / 2))

/-- Flattened Jensen bridge for a normalized finite latent/coordinate law.
The supplied convexity is the squared-bias entropy convexity, not merely
convexity in bias. This is a conditional analytic bridge, not the full
Gaussian-sign theorem. -/
theorem weighted_bias_jensen {K : Type*} [Fintype K]
    (p x : K → ℝ) (hp : ∀ k, 0 ≤ p k) (hp1 : ∑ k, p k = 1)
    (hx : ∀ k, x k ∈ Set.Icc (0 : ℝ) 1)
    (hconv : ConvexOn ℝ (Set.Icc (0 : ℝ) 1) psi) :
    psi (∑ k, p k * x k) ≤ ∑ k, p k * psi (x k) := by
  simpa only [smul_eq_mul] using
    hconv.map_sum_le (t := Finset.univ) (w := p) (p := x)
      (fun k _ => hp k) hp1 (fun k _ => hx k)

/-- Robust energy step: a bounded score loses at most twice the TV radius
when its expectation transfer has been established. This lemma only
composes that explicit transfer with the energy operator. -/
theorem tv_one_block_energy (U : (I → ℝ) → (I → ℝ))
    (hU : ∀ b, energy (U b) = energy b)
    (w : W → ℝ) (hw : ∀ t, 0 ≤ w t) (a b : W → I → ℝ)
    (N c eta : ℝ)
    (hscore : N * (c - 2 * eta) ≤ ∑ t, w t * score (a t) (U (b t))) :
    N * (c - 2 * eta) ≤ ∑ t, w t * energy (a t) ∨
    N * (c - 2 * eta) ≤ ∑ t, w t * energy (b t) :=
  one_block_energy U hU w hw a b _ hscore

end Nightfall.Route1OrthogonalCorrelation

#print axioms Nightfall.Route1OrthogonalCorrelation.twice_score_le_energy
#print axioms Nightfall.Route1OrthogonalCorrelation.one_block_energy
#print axioms Nightfall.Route1OrthogonalCorrelation.weighted_bias_jensen
#print axioms Nightfall.Route1OrthogonalCorrelation.tv_one_block_energy
