import ActualPosteriorInfluence
import SCIFDegreeTransport
import ActualSourceDegreeTwoAllDimensions

/-!
# D2 original-source posterior section-budget transfer

Unlike the numeric 20172 hard-budget implication, this is an actual-source
bridge: revealing arbitrary coordinates and their values replaces their
marginals by Dirac masses, preserves original Hoeffding degree two, and
re-derives the source 8B conditional-section bound *at each posterior*.

Finite common alphabet, original normalized product and pointwise bounded
scalar observable are explicit. Zero-mass source symbols are permitted.
The causal transcript -> Dirac posterior identification and the full Hilbert
matching / max-influence quadratic drift still require separate proofs.
-/

namespace Nightfall.Observability.D2PosteriorSection

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.SCIFDegreeTransport
open Nightfall.Observability.ActualSourceDegreeTwoAllDimensions
open Nightfall.Observability.V7Actual

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The *actual* posterior product after any finite partial observation
preserves degree <=2. No posterior degree premise is supplied. -/
theorem degree_two_after_arbitrary_partial_observation
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (s : ι → Option α) (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    ESDegreeLE (posteriorLaw p s) f 2 :=
  degree_two_preserved_by_any_law p (posteriorLaw p s) hp1 f hdegree

/-- The original-law, arbitrary-alphabet 8B section theorem applies to
every actual Dirac/product posterior, including zero-atom configurations.
Crucially neither an auxiliary fair law nor a posterior 8B assumption
appears: both the new normalization and the new degree are derived. -/
theorem posterior_degree_two_section_budget_eight
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (s : ι → Option α)
    (f : (ι → α) → ℝ) (B : ℝ)
    (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    (∑ i : ι, Real.sqrt (∑ a : α, posteriorLaw p s i a *
      (f (Function.update x i a) -
        (∑ b : α, posteriorLaw p s i b *
          f (Function.update x i b))) ^ 2)) ≤ 8 * B := by
  exact actual_degree_two_source_section_budget_eight_all_current
    (posteriorLaw p s)
    (posteriorLaw_nonneg p hp s)
    (posteriorLaw_sum p hp1 s)
    f B hB hf
    (degree_two_after_arbitrary_partial_observation
      p hp1 s f hdegree)
    x

/-- A finite observation is a cylinder event: each revealed coordinate
equals its reported value; unobserved coordinates impose no constraint. -/
noncomputable def observationIndicator
    (s : ι → Option α) (x : ι → α) (i : ι) : ℝ :=
  match s i with
  | none => 1
  | some a => if x i = a then 1 else 0

noncomputable def cylinderIndicator
    (s : ι → Option α) (x : ι → α) : ℝ :=
  ∏ i : ι, observationIndicator s x i

/-- Original-product probability of the observation cylinder.
May be zero when an observed symbol has zero source probability. -/
noncomputable def evidenceFactor
    (p : ι → α → ℝ) (s : ι → Option α) (i : ι) : ℝ :=
  match s i with
  | none => 1
  | some a => p i a

noncomputable def cylinderEvidence
    (p : ι → α → ℝ) (s : ι → Option α) : ℝ :=
  ∏ i : ι, evidenceFactor p s i

/-- Exact single-coordinate original source density times cylinder
indicator = its evidence times its actual posterior Dirac/marginal law. -/
theorem coordinate_cylinder_posterior_mass
    (p : ι → α → ℝ) (s : ι → Option α)
    (x : ι → α) (i : ι) :
    p i (x i) * observationIndicator s x i =
      evidenceFactor p s i * posteriorLaw p s i (x i) := by
  classical
  cases h : s i with
  | none =>
      simp [observationIndicator, evidenceFactor, posteriorLaw, h]
  | some a =>
      by_cases hx : x i = a
      · simp [observationIndicator, evidenceFactor, posteriorLaw, h, hx]
      · simp [observationIndicator, evidenceFactor, posteriorLaw, h, hx]

/-- The actual source measure restricted to a deterministic observation
cylinder is exactly evidence × the Dirac/product posterior. This equality
holds even on zero-evidence cylinders, where conditioning is undefined. -/
theorem source_cylinder_density_factorization
    (p : ι → α → ℝ) (s : ι → Option α) (x : ι → α) :
    (∏ i : ι, p i (x i)) * cylinderIndicator s x =
      cylinderEvidence p s * posteriorMass p s x := by
  classical
  unfold cylinderIndicator cylinderEvidence posteriorMass
  rw [← Finset.prod_mul_distrib]
  rw [← Finset.prod_mul_distrib]
  apply Finset.prod_congr rfl
  intro i _
  exact coordinate_cylinder_posterior_mass p s x i

/-- Source-derived evidence equals the *actual* mass of the cylinder,
using the independent product normalizers, not a supplied Bayes premise. -/
theorem source_cylinder_evidence_normalizer
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (s : ι → Option α) :
    (∑ x : ι → α, (∏ i : ι, p i (x i)) *
        cylinderIndicator s x) = cylinderEvidence p s := by
  classical
  calc
    _ = ∑ x : ι → α, cylinderEvidence p s *
        posteriorMass p s x := by
      apply Finset.sum_congr rfl
      intro x _
      exact source_cylinder_density_factorization p s x
    _ = cylinderEvidence p s *
        (∑ x : ι → α, posteriorMass p s x) := by
      rw [Finset.mul_sum]
    _ = cylinderEvidence p s := by
      rw [posteriorMass_sum p hp1 s]
      ring

/-- The genuine finite conditional source law given a positive-evidence
coordinate-revelation event is precisely the actual posterior product law.
This closes the cylinder Bayes-identification bridge, not yet the separate
causal-policy-to-cylinder history theorem. -/
theorem source_cylinder_conditional_posterior
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (s : ι → Option α) (x : ι → α)
    (hevidence : cylinderEvidence p s ≠ 0) :
    ((∏ i : ι, p i (x i)) * cylinderIndicator s x) /
      (∑ y : ι → α, (∏ i : ι, p i (y i)) *
        cylinderIndicator s y) =
      posteriorMass p s x := by
  rw [source_cylinder_density_factorization p s x,
    source_cylinder_evidence_normalizer p hp1 s]
  field_simp [hevidence]

end Nightfall.Observability.D2PosteriorSection

#print axioms Nightfall.Observability.D2PosteriorSection.degree_two_after_arbitrary_partial_observation
#print axioms Nightfall.Observability.D2PosteriorSection.posterior_degree_two_section_budget_eight

#print axioms Nightfall.Observability.D2PosteriorSection.coordinate_cylinder_posterior_mass
#print axioms Nightfall.Observability.D2PosteriorSection.source_cylinder_density_factorization
#print axioms Nightfall.Observability.D2PosteriorSection.source_cylinder_evidence_normalizer
#print axioms Nightfall.Observability.D2PosteriorSection.source_cylinder_conditional_posterior
