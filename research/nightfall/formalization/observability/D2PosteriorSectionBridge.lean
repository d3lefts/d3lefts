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

end Nightfall.Observability.D2PosteriorSection

#print axioms Nightfall.Observability.D2PosteriorSection.degree_two_after_arbitrary_partial_observation
#print axioms Nightfall.Observability.D2PosteriorSection.posterior_degree_two_section_budget_eight
