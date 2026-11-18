import InfinitePiQ2UnconditionalTerminal

/-!
# Infinite-product L² degree: named finite-order residual equivalence

The index type and coordinate types are arbitrary. This module establishes
the nontrivial all-orders extension of the existing three-residual criterion,
without claiming that the closed-span Hoeffding/ANOVA characterization has
yet been formalized.

The latter requires a separately proved finite-label density + canonical
ANOVA decomposition converse. That is an explicit remaining gate.
-/

namespace Nightfall.InfinitePiQ2DegreeEquivalence

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2CellAverage
open Nightfall.InfinitePiQ2NativeSupportedTerminal

universe u v

variable {ι : Type u} [DecidableEq ι] {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- An ordered, finite word of original-source coordinate residuals,
evaluated left to right. No independent-law surrogate is involved. -/
noncomputable def sourceResidualWord
    (l : List ι) (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
  l.foldl (fun h i => sourceCoordinateResidual μ i h) G

private theorem sourceResidualWord_zero (l : List ι) :
    sourceResidualWord μ l
      (0 : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = 0 := by
  induction l with
  | nil => rfl
  | cons i rest ih =>
    have hzero : sourceCoordinateResidual μ i
        (0 : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = 0 := by
      simp [sourceCoordinateResidual, sourceOtherProjection]
    change sourceResidualWord μ rest
      (sourceCoordinateResidual μ i 0) = 0
    simpa only [hzero] using ih

/-- **Named arbitrary-index equivalence (finite mixed-residual criterion).**
Three distinct genuine infinite-product residuals annihilate G iff every
ordered finite word of at least three *distinct* original residuals
annihilates G. This is valid for uncountable index types and arbitrary
coordinate alphabets. It does not by itself formalize the separate
closed-span canonical ANOVA representation. -/
theorem tripleResidualZero_iff_all_higher_mixed_residuals
    (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    CellLabels.TripleResidualZero μ G ↔
      ∀ l : List ι, l.Nodup → 3 ≤ l.length →
        sourceResidualWord μ l G = 0 := by
  constructor
  · intro h l hn hl
    match l with
    | [] => simp at hl
    | [_] => simp at hl
    | [_, _] => simp at hl
    | i :: j :: k :: rest =>
      have htail : i ∉ (j :: k :: rest) :=
        (List.nodup_cons.mp hn).1
      have htail2 : j ∉ (k :: rest) :=
        (List.nodup_cons.mp (List.nodup_cons.mp hn).2).1
      have hij : i ≠ j := by
        intro heq
        exact htail (by simp [heq])
      have hik : i ≠ k := by
        intro heq
        exact htail (by simp [heq])
      have hjk : j ≠ k := by
        intro heq
        exact htail2 (by simp [heq])
      have hzero : sourceCoordinateResidual μ k
          (sourceCoordinateResidual μ j
            (sourceCoordinateResidual μ i G)) = 0 :=
        h k j i hjk.symm hik.symm hij.symm
      change sourceResidualWord μ rest
        (sourceCoordinateResidual μ k
          (sourceCoordinateResidual μ j
            (sourceCoordinateResidual μ i G))) = 0
      rw [hzero]
      exact sourceResidualWord_zero μ rest
  · intro h i j k hij hik hjk
    have hn : ([k,j,i] : List ι).Nodup := by
      simp [List.nodup_cons, hij, hik, hjk, Ne.symm hij, Ne.symm hik, Ne.symm hjk]
    have hlength : 3 ≤ ([k, j, i] : List ι).length := by simp
    have hh := h [k, j, i] hn hlength
    simpa [sourceResidualWord] using hh

/-- Existing finite-label native ANOVA consequence, exposed as a reusable
named bridge from the original arbitrary-index L² degree predicate. -/
theorem tripleResidualZero_implies_every_finite_label_supported_q2
    (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hG : CellLabels.TripleResidualZero μ G) :
    ∀ L : CellLabels X,
      NativeSupportedDegreeTwo L.Letter (L.prob μ) (L.avg μ (⇑G)) := by
  intro L
  exact L.avg_nativeSupportedDegreeTwo_of_triple μ G hG

#print axioms Nightfall.InfinitePiQ2DegreeEquivalence.tripleResidualZero_iff_all_higher_mixed_residuals
#print axioms Nightfall.InfinitePiQ2DegreeEquivalence.tripleResidualZero_implies_every_finite_label_supported_q2

end Nightfall.InfinitePiQ2DegreeEquivalence
