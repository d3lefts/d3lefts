import Mathlib

/-! Paper VII Appendix A, Theorem B. Actual finite source and transcript
fiber sums, including randomized policies via the source's independent
seed. The affine-posterior rank argument that establishes the cell-wise
lower bound remains a distinct geometric obligation. -/
namespace Nightfall.PaperVIIAdaptiveLikelihood
open Finset

variable {S H : Type*} [Fintype S] [DecidableEq S] [DecidableEq H]

noncomputable def mass (P : S → ℝ) (B : Finset S) : ℝ := ∑ s ∈ B, P s
noncomputable def planted (P D : S → ℝ) (B : Finset S) : ℝ := ∑ s ∈ B, P s * D s

/-- Cauchy–Schwarz for the actual planted event probability. -/
theorem planted_event_bound (P D : S → ℝ) (B : Finset S)
    (hP : ∀ s, 0 ≤ P s) (hD : ∀ s, 0 ≤ D s)
    (delta C : ℝ) (hdelta : 0 ≤ delta) (hC : 0 ≤ C)
    (hB : mass P B ≤ delta)
    (hsecond : ∑ s : S, P s*(D s)^2 ≤ C) :
    planted P D B ≤ Real.sqrt (delta*C) := by
  classical
  have hsq : (planted P D B)^2 ≤
      mass P B * (∑ s ∈ B, P s*(D s)^2) := by
    unfold planted mass
    apply Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul B
      (fun s _ => hP s) (fun s _ => mul_nonneg (hP s) (sq_nonneg _))
    intro s _
    ring_nf <;> exact le_rfl
  have hsub : (∑ s ∈ B, P s*(D s)^2) ≤ C :=
    (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
      (fun s _ _ => mul_nonneg (hP s) (sq_nonneg _))).trans hsecond
  have hmass : 0 ≤ mass P B := Finset.sum_nonneg fun s _ => hP s
  have henergy : 0 ≤ ∑ s ∈ B, P s*(D s)^2 :=
    Finset.sum_nonneg fun s _ => mul_nonneg (hP s) (sq_nonneg _)
  have hbound := mul_le_mul hB hsub henergy hdelta
  have hpl : 0 ≤ planted P D B :=
    Finset.sum_nonneg fun s _ => mul_nonneg (hP s) (hD s)
  have hs := Real.sq_sqrt (mul_nonneg hdelta hC)
  exact (sq_le_sq₀ hpl (Real.sqrt_nonneg _)).mp (hsq.trans (by rw [hs]; exact hbound))

/-- The probability of a union of no-fault transcript cells under
the planted law is at least (1-a) times its source probability.
Only the actual posterior cell bound is assumed; no independence
of transcripts and secrets is asserted. -/
theorem transcript_event_lower [Fintype H]
    (P D : S → ℝ) (T : S → H) (N : Finset H) (a : ℝ)
    (hcell : ∀ h : H, (1-a)*mass P (univ.filter (fun s => T s=h)) ≤
      planted P D (univ.filter (fun s => T s=h))) :
    (1-a)*mass P (univ.filter (fun s => T s ∈ N)) ≤
      planted P D (univ.filter (fun s => T s ∈ N)) := by
  classical
  unfold mass planted at *
  have h := Finset.sum_le_sum (fun h (_ : h ∈ N) => hcell h)
  rw [← Finset.mul_sum] at h
  rw [Finset.sum_fiberwise_eq_sum_filter univ N T,
    Finset.sum_fiberwise_eq_sum_filter univ N T] at h
  exact h

/-- Exact Theorem B1 inference using a finite source, actual transcript
cells and planted density. The two error-event inequalities and the
second moment are explicit and must be established from the affine
block source before the full prospectus theorem is certified. -/
theorem adaptive_likelihood_bound [Fintype H]
    (P D : S → ℝ) (T : S → H) (N : Finset H)
    (P0 delta lambda a : ℝ) (hlambda : 0 < lambda)
    (hP : ∀ s, 0 ≤ P s) (hD : ∀ s, 0 ≤ D s)
    (hP1 : ∑ s, P s = 1) (hdelta : 0 ≤ delta) (ha : 0 ≤ a)
    (hcell : ∀ h : H, (1-a)*mass P (univ.filter (fun s => T s=h)) ≤
      planted P D (univ.filter (fun s => T s=h)))
    (hsource : P0-delta ≤ mass P (univ.filter (fun s => T s ∈ N)))
    (hsecond : ∑ s : S, P s*(D s)^2 ≤ 1+1/lambda)
    (hbad : ∃ B : Finset S, mass P B ≤ delta ∧
      planted P D (univ.filter (fun s => T s ∈ N)) = planted P D B) :
    P0-delta-Real.sqrt (delta*(1+1/lambda)) ≤ a := by
  obtain ⟨B,hB,heq⟩ := hbad
  have hC : 0 ≤ 1+1/lambda := by positivity
  have hupper := planted_event_bound P D B hP hD delta (1+1/lambda) hdelta hC hB hsecond
  have hlower := transcript_event_lower P D T N a hcell
  have hmass : mass P (univ.filter (fun s => T s ∈ N)) ≤ 1 := by
    unfold mass
    rw [← hP1]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) (fun s _ _ => hP s)
  have hprod := mul_le_mul_of_nonneg_left hmass ha
  rw [heq] at hlower
  linarith only [hlower,hupper,hprod,hsource]

#print axioms planted_event_bound
#print axioms transcript_event_lower
#print axioms adaptive_likelihood_bound
end Nightfall.PaperVIIAdaptiveLikelihood
