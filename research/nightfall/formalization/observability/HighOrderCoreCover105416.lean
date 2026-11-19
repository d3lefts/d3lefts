import CubicTopCover105416

/-!
# NIGHTFALL: all-degree original-source high-order hitting-set reduction

This module removes the artificial degree-<=3 restriction from the
original source C105.416 cubic top-cover terminal. The genuine assumption:
EVERY source Hoeffding component of order >=3 outside H vanishes.
No restriction on the degree of f itself, and no assumption about the
number or overlaps of high-order interactions. Finite independent original
product law with heterogeneous weights on the common finite alphabet;
zero source masses are permitted.

This is a restricted all-degree class, not universal N-UE2(6)/(2).
Source proof builds on merged, kernel-checked original-source Q2 and
cubic top-cover lemmas. Originality/priority not claimed.
-/

namespace Nightfall.Observability.HighOrderCoreCover105416

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ223802Terminal
open Nightfall.Observability.CubicTopCoverEnergy
open Nightfall.Observability.CubicTopCoverProjection

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- A high-order ANOVA core H makes the original-source projection
on its complement exactly degree at most two. The original function
can have ARBITRARILY HIGH ANOVA DEGREE. -/
theorem high_order_core_projection_degree_two
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (H : Finset ι)
    (hcover : ∀ S : Finset ι, 2 < S.card →
      ¬ touches H S → ∀ x, esComp p S f x = 0) :
    ESDegreeLE p (condExp p (Finset.univ \ H) f) 2 := by
  intro S hS x
  rw [esComp_condExp p hp1 f (Finset.univ \ H) S x]
  by_cases hSU : S ⊆ (Finset.univ \ H)
  · rw [if_pos hSU]
    exact hcover S hS ((subset_complement_iff_no_touch H S).mp hSU) x
  · rw [if_neg hSU]

/-- End-to-end genuine original finite-product theorem, no
projected-Q2 premise and no degree<=3 assumption. This bound is
dimension-free for a fixed high-order hitting set H. The bound
on f is pointwise on the whole finite table (including null words);
the main-source a.e. supported variant is a separate transfer. -/
theorem original_source_all_degree_high_order_core_105416
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (H : Finset ι)
    (hcover : ∀ S : Finset ι, 2 < S.card →
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
  have hgd : ESDegreeLE p g 2 :=
    high_order_core_projection_degree_two p hp1 f H hcover
  have hgbounded : ∀ x, |g x| ≤ B :=
    conditional_amplitude_le p hp hp1 f U B hf
  have hgI : ∀ i, sourceInfluence p g i ≤ M := by
    intro i
    exact (projected_influence_le_original p hp hp1 f U i).trans (hI i)
  have hQ2 := actual_source_q2_23802_unconditional
    p hp hp1 g hgd B hB hgbounded M hM hgI
  have hproj : sourceVariance p g = outsideSourceEnergy p f H :=
    projected_variance_eq_outside_energy p hp1 f H
  have houtside :
      (outsideSourceEnergy p f H)^2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 +
        11901 / 6250)^2 * B^2 * M := by
    simpa only [hproj] using hQ2
  exact cubic_cover_terminal_from_projected_q2
    p hp hp1 f H B M hB hM hI houtside

#print axioms Nightfall.Observability.HighOrderCoreCover105416.high_order_core_projection_degree_two
#print axioms Nightfall.Observability.HighOrderCoreCover105416.original_source_all_degree_high_order_core_105416

end Nightfall.Observability.HighOrderCoreCover105416
