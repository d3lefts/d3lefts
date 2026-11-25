import Mathlib

/-!
# NIGHTFALL T2 — clipped legal-transcript Fourier estimator

The strong rank-free two-query simulator does not need a separate
measure-theoretic conditional-expectation formalization. Given the
physical acceptance probability f(s) in [0,1] and any REAL truncated
Fourier projection h(s) determined by the actually queried original
label transcript τ(s), clipping h to [0,1] cannot increase squared
prediction error, pointwise.

This module proves the complete arbitrary-transcript factorization,
pointwise projection inequality, finite uniform-secret L2 comparison,
and final finite uniform Markov query terminal. The truncated Fourier
projection, original character transcript and its Parseval outside-span
bound must still be derived from the genuine quantum circuit.

The clipped estimator is a deterministic total function of exactly
the supplied transcript: on impossible transcripts it returns zero.
No oracle access to synthetic XOR frequencies and no computational
runtime bound are asserted.
-/

namespace Nightfall.StructuralInformation.T2ClippedEstimator

open Finset

/-- A deterministic, real, [0,1]-valued projection of any real
Fourier partial sum onto the physical range of acceptance probability. -/
noncomputable def clip01 (x : ℝ) : ℝ := min 1 (max 0 x)

theorem clip01_nonneg (x : ℝ) : 0 ≤ clip01 x := by
  unfold clip01
  exact le_min (by norm_num) (le_max_left 0 x)

theorem clip01_le_one (x : ℝ) : clip01 x ≤ 1 := by
  unfold clip01
  exact min_le_left _ _

/-- For an acceptance probability y in [0,1], clipping an arbitrary
real estimate x cannot increase its squared error. -/
theorem clipped_squared_error_le (x y : ℝ)
    (hy0 : 0 ≤ y) (hy1 : y ≤ 1) :
    (y - clip01 x) ^ 2 ≤ (y - x) ^ 2 := by
  by_cases hlow : x ≤ 0
  · have hclip : clip01 x = 0 := by
      unfold clip01
      rw [max_eq_left hlow]
      norm_num
    rw [hclip]
    have hnonneg : 0 ≤ y * (-x) :=
      mul_nonneg hy0 (neg_nonneg.mpr hlow)
    nlinarith [sq_nonneg x]
  · by_cases hhigh : 1 ≤ x
    · have hclip : clip01 x = 1 := by
        unfold clip01
        rw [max_eq_right (by linarith : (0 : ℝ) ≤ x)]
        exact min_eq_left hhigh
      rw [hclip]
      have hproduct : 0 ≤ (x - 1) * (x + 1 - 2 * y) :=
        mul_nonneg (by linarith) (by linarith)
      nlinarith
    · have hx0 : 0 ≤ x := by linarith
      have hx1 : x ≤ 1 := by linarith
      have hclip : clip01 x = x := by
        unfold clip01
        rw [max_eq_right hx0, min_eq_right hx1]
      rw [hclip]

/-- Construct a TOTAL deterministic function of the actual observed
transcript τ(s). On an impossible transcript, output zero. -/
noncomputable def transcriptProjection {S T : Type*}
    (tau : S → T) (h : S → ℝ) (answer : T) : ℝ := by
  classical
  exact if hx : ∃ s : S, tau s = answer then h (Classical.choose hx) else 0

/-- The raw (potentially unbounded) Fourier projection is determined
by the transcript, even if some queried labels are dependent. -/
theorem transcriptProjection_eval {S T : Type*}
    (tau : S → T) (h : S → ℝ)
    (hdepends : ∀ s t, tau s = tau t → h s = h t)
    (s : S) :
    transcriptProjection tau h (tau s) = h s := by
  classical
  unfold transcriptProjection
  split_ifs with hx
  · exact hdepends (Classical.choose hx) s (Classical.choose_spec hx)
  · exact (hx ⟨s, rfl⟩).elim

/-- Real nonadaptive estimator that uses only the actual provided
transcript, with physical output clipped to [0,1]. -/
noncomputable def clippedTranscriptEstimator {S T : Type*}
    (tau : S → T) (h : S → ℝ) (answer : T) : ℝ :=
  clip01 (transcriptProjection tau h answer)

theorem clippedTranscriptEstimator_range {S T : Type*}
    (tau : S → T) (h : S → ℝ) (answer : T) :
    0 ≤ clippedTranscriptEstimator tau h answer ∧
      clippedTranscriptEstimator tau h answer ≤ 1 := by
  exact ⟨clip01_nonneg _, clip01_le_one _⟩

theorem clippedTranscriptEstimator_eval {S T : Type*}
    (tau : S → T) (h : S → ℝ)
    (hdepends : ∀ s t, tau s = tau t → h s = h t)
    (s : S) :
    clippedTranscriptEstimator tau h (tau s) = clip01 (h s) := by
  unfold clippedTranscriptEstimator
  rw [transcriptProjection_eval tau h hdepends s]

/-- Pointwise error dominance, independent of source distribution,
alphabet size, dimension, and effect rank. -/
theorem clipped_estimator_pointwise_error {S T : Type*}
    (tau : S → T) (f h : S → ℝ)
    (hf : ∀ s, 0 ≤ f s ∧ f s ≤ 1)
    (hdepends : ∀ s t, tau s = tau t → h s = h t)
    (s : S) :
    (f s - clippedTranscriptEstimator tau h (tau s)) ^ 2 ≤
      (f s - h s) ^ 2 := by
  rw [clippedTranscriptEstimator_eval tau h hdepends s]
  exact clipped_squared_error_le (h s) (f s) (hf s).1 (hf s).2

/-- Finite uniform-secret Fourier L2 error is never increased
by the actual legal-query clipped estimator. -/
theorem clipped_estimator_L2_le {S T : Type*} [Fintype S]
    (tau : S → T) (f h : S → ℝ)
    (hf : ∀ s, 0 ≤ f s ∧ f s ≤ 1)
    (hdepends : ∀ s t, tau s = tau t → h s = h t) :
    (∑ s : S,
       (f s - clippedTranscriptEstimator tau h (tau s)) ^ 2) ≤
      ∑ s : S, (f s - h s) ^ 2 := by
  apply Finset.sum_le_sum
  intro s _
  exact clipped_estimator_pointwise_error tau f h hf hdepends s

/-- Fully quantitative finite uniform-source failure bound for the
deterministic clipped estimator. Only the raw Fourier L2 estimate
is a visible hypothesis, not an assumed accuracy conclusion. -/
theorem clipped_estimator_uniform_success {S T : Type*} [Fintype S]
    (tau : S → T) (f h : S → ℝ)
    (hf : ∀ s, 0 ≤ f s ∧ f s ≤ 1)
    (hdepends : ∀ s t, tau s = tau t → h s = h t)
    (eps delta : ℝ) (heps : 0 < eps)
    (henergy : (∑ s : S, (f s - h s) ^ 2) ≤
      (Fintype.card S : ℝ) * eps ^ 2 * delta) :
    ((Finset.univ.filter (fun s : S =>
         eps < |f s - clippedTranscriptEstimator tau h (tau s)|)).card : ℝ) ≤
        (Fintype.card S : ℝ) * delta := by
  classical
  let g := clippedTranscriptEstimator tau h
  let z : S → ℝ := fun s => f s - g (tau s)
  let B : Finset S := Finset.univ.filter (fun s => eps < |z s|)
  have hbad : ∀ s ∈ B, eps ^ 2 ≤ z s ^ 2 := by
    intro s hs
    have hs' : eps < |z s| := (Finset.mem_filter.mp hs).2
    have hsq : eps ^ 2 ≤ |z s| ^ 2 :=
      (sq_le_sq₀ heps.le (abs_nonneg _)).mpr hs'.le
    simpa only [sq_abs] using hsq
  have hfirst : (B.card : ℝ) * eps ^ 2 ≤ ∑ s ∈ B, z s ^ 2 := by
    calc
      (B.card : ℝ) * eps ^ 2 = ∑ s ∈ B, eps ^ 2 := by simp
      _ ≤ ∑ s ∈ B, z s ^ 2 := by
        apply Finset.sum_le_sum
        intro s hs
        exact hbad s hs
  have hsecond : (∑ s ∈ B, z s ^ 2) ≤ ∑ s : S, z s ^ 2 := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
    intro s hs hnot
    exact sq_nonneg (z s)
  have hthird : (∑ s : S, z s ^ 2) ≤
      (Fintype.card S : ℝ) * eps ^ 2 * delta := by
    calc
      _ ≤ ∑ s : S, (f s - h s) ^ 2 :=
        clipped_estimator_L2_le tau f h hf hdepends
      _ ≤ _ := henergy
  have hmul :
      (B.card : ℝ) * eps ^ 2 ≤
        ((Fintype.card S : ℝ) * delta) * eps ^ 2 := by
    calc
      (B.card : ℝ) * eps ^ 2 ≤ ∑ s ∈ B, z s ^ 2 := hfirst
      _ ≤ ∑ s : S, z s ^ 2 := hsecond
      _ ≤ (Fintype.card S : ℝ) * eps ^ 2 * delta := hthird
      _ = ((Fintype.card S : ℝ) * delta) * eps ^ 2 := by ring
  change (B.card : ℝ) ≤ (Fintype.card S : ℝ) * delta
  by_contra hn
  have hstrict : (Fintype.card S : ℝ) * delta < (B.card : ℝ) :=
    lt_of_not_ge hn
  have hpositive :
      0 < ((B.card : ℝ) - (Fintype.card S : ℝ) * delta) *
          eps ^ 2 :=
    mul_pos (sub_pos.mpr hstrict) (pow_pos heps 2)
  nlinarith

#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.clip01_nonneg
#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.clipped_squared_error_le
#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.transcriptProjection_eval
#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.clippedTranscriptEstimator_eval
#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.clipped_estimator_pointwise_error
#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.clipped_estimator_L2_le
#print axioms Nightfall.StructuralInformation.T2ClippedEstimator.clipped_estimator_uniform_success

end Nightfall.StructuralInformation.T2ClippedEstimator
