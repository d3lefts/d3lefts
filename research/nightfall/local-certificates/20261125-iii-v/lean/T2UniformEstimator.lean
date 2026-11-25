import T2UniformParseval
import T2WalshTranscript
import T2ClippedEstimator

/-! Exact uniform-source Fourier projection and legal-transcript Markov bridge.
The numerical tail estimate remains an explicit hypothesis, not an assumed
quantum theorem. -/
namespace Nightfall.StructuralInformation.T2UniformEstimator
open Finset
open Nightfall.StructuralInformation.T2UniformParseval
open Nightfall.StructuralInformation.T2WalshTranscript
open Nightfall.StructuralInformation.T2ClippedEstimator
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

noncomputable def inside (H : Finset G) : Finset G := by
  classical
  exact univ.filter (fun z => z ∈ AddSubgroup.closure (H : Set G))

noncomputable def outside (H : Finset G) : Finset G := univ \ inside H

theorem projection_depends (H : Finset G) (c : G → ℝ) (s t : AddChar G ℂ)
    (h : originalTranscript H s = originalTranscript H t) :
    polynomial (inside H) c s = polynomial (inside H) c t := by
  unfold polynomial
  apply Finset.sum_congr rfl
  intro z hz
  have hmem : z ∈ AddSubgroup.closure (H : Set G) := by
    classical
    exact (Finset.mem_filter.mp hz).2
  rw [sign, sign, character_agree_of_transcript H s t h z hmem]

theorem full_sub_projection (H : Finset G) (c : G → ℝ) (s : AddChar G ℂ) :
    polynomial univ c s - polynomial (inside H) c s = polynomial (outside H) c s := by
  classical
  unfold polynomial outside
  have h := Finset.sum_sdiff (Finset.subset_univ (inside H))
    (f := fun z => c z * sign s z)
  linarith

theorem actual_uniform_tail_identity (h₂ : ∀ z : G, z+z=0)
    (H : Finset G) (c : G → ℝ) :
    (∑ s : AddChar G ℂ,
      (polynomial univ c s - polynomial (inside H) c s)^2) =
      (Fintype.card G : ℝ) * ∑ z ∈ outside H, (c z)^2 := by
  simp_rw [full_sub_projection]
  exact uniform_parseval h₂ (outside H) c

/-- The actual uniform dual-secret source, using only original label readings.
No abstract orthogonality or conditional-expectation assumption. -/
theorem legal_query_uniform_success (h₂ : ∀ z : G, z+z=0)
    (H : Finset G) (c : G → ℝ)
    (hf : ∀ s : AddChar G ℂ, 0 ≤ polynomial univ c s ∧ polynomial univ c s ≤ 1)
    (eps delta : ℝ) (heps : 0 < eps)
    (htail : (∑ z ∈ outside H, (c z)^2) ≤ eps^2*delta) :
    ∃ g : (↑H → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar G ℂ =>
        eps < |polynomial univ c s - g (originalTranscript H s)|)).card : ℝ) ≤
          (Fintype.card (AddChar G ℂ) : ℝ)*delta := by
  classical
  let f := polynomial (univ : Finset G) c
  let h := polynomial (inside H) c
  let tau := originalTranscript H
  refine ⟨clippedTranscriptEstimator tau h, clippedTranscriptEstimator_range tau h, ?_⟩
  apply clipped_estimator_uniform_success tau f h hf (projection_depends H c) eps delta heps
  change (∑ s : AddChar G ℂ, (polynomial univ c s - polynomial (inside H) c s)^2) ≤ _
  rw [actual_uniform_tail_identity h₂ H c, AddChar.card_eq]
  calc
    _ ≤ (Fintype.card G : ℝ) * (eps^2*delta) := mul_le_mul_of_nonneg_left htail (by positivity)
    _ = _ := by ring

#print axioms actual_uniform_tail_identity
#print axioms legal_query_uniform_success
end Nightfall.StructuralInformation.T2UniformEstimator
