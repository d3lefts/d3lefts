import CubicTopCoverProjection
import ActualSourceQ223802Terminal

/-!
# Unconditional finite-source cubic top-cover inequality using C105.416 Q2

This is a source-owned lift, not an assumed projected-Q2 scalar bound.
It reuses kernel-checked source ANOVA sector identities, the genuine
conditional projection's degree-2 reduction, non-expansion of influence,
and the pinned finite original-source Q2 C105.416 terminal.

No bound is asserted when the cubic supports have no finite cover.
The unrestricted cubic exponent-two conjecture remains open.
-/

namespace Nightfall.Observability.CubicTopCover105416

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ223802Terminal
open Nightfall.Observability.CubicTopCoverEnergy
open Nightfall.Observability.CubicTopCoverProjection

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Original-source, no projected-Q2 hypothesis: cubic degree at most
three with a top-degree vertex cover H has variance at most the full
quadratic C105.416 root coefficient times B sqrt M, plus |H| M.
All genuine source weights may contain zero-probability atoms. -/
theorem actual_source_cubic_top_cover_105416
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 3)
    (H : Finset ι)
    (hcover : ∀ S : Finset ι, S.card = 3 →
      ¬ touches H S → ∀ x, esComp p S f x = 0)
    (B M : ℝ) (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hf : ∀ x, |f x| ≤ B)
    (hI : ∀ i, sourceInfluence p f i ≤ M) :
    sourceVariance p f ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 +
        11901 / 6250) * B * Real.sqrt M +
        (H.card : ℝ) * M := by
  classical
  let U : Finset ι := Finset.univ \ H
  let g : (ι → α) → ℝ := condExp p U f
  have hgdegree : ESDegreeLE p g 2 :=
    covered_projection_degree_two p hp1 f hdegree H hcover
  have hgbounded : ∀ x, |g x| ≤ B :=
    conditional_amplitude_le p hp hp1 f U B hf
  have hgI : ∀ i, sourceInfluence p g i ≤ M := by
    intro i
    exact (projected_influence_le_original p hp hp1 f U i).trans (hI i)
  have hQ2 := actual_source_q2_23802_unconditional
    p hp hp1 g hgdegree B hB hgbounded M hM hgI
  have hproj : sourceVariance p g = outsideSourceEnergy p f H :=
    projected_variance_eq_outside_energy p hp1 f H
  have houtside :
      (outsideSourceEnergy p f H)^2 ≤
        ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 +
          11901 / 6250)^2 * B^2 * M := by
    simpa only [hproj] using hQ2
  exact cubic_cover_terminal_from_projected_q2
    p hp hp1 f H B M hB hM hI houtside

end Nightfall.Observability.CubicTopCover105416
