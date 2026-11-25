import AllOrderPatternMask
import AllOrderCombinedTerminal

namespace Nightfall.AllOrder.Geometry
open Finset
open Nightfall.AllOrder
open Nightfall.StructuralInformation.T2UniformParseval
variable {I J K : Type*} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

noncomputable def pathsOf (r : ℕ) (p : Pattern I) : Finset (I → Label J K) := by
  classical
  exact univ.filter (fun a => patternOf a r = p)

noncomputable def keepFor (r : ℕ) (p : Pattern I) : Finset I := by
  classical
  exact if h : ∃ a : I → Label J K, patternOf a r = p then keepSet (Classical.choose h) r else ∅

theorem keepFor_eq (r : ℕ) (p : Pattern I) (a : I → Label J K) (ha : patternOf a r = p) :
    keepFor (J := J) (K := K) r p = keepSet a r := by
  classical
  unfold keepFor
  rw [dif_pos ⟨a,ha⟩]
  exact pattern_keep_eq _ _ r ((Classical.choose_spec (show ∃ b : I → Label J K, patternOf b r = p from ⟨a,ha⟩)).trans ha.symm)

noncomputable def paddedMap (r : ℕ) (p : Pattern I) (a : I → Label J K) : I → Label J K :=
  pad a (keepFor (J := J) (K := K) r p)

noncomputable def contractedSupport (r : ℕ) (p : Pattern I) : Finset (I → Label J K) := by
  classical
  exact (pathsOf (J := J) (K := K) r p).image (paddedMap r p)

noncomputable def contractedCoeff (c : (I → Label J K) → ℝ) (r : ℕ) (p : Pattern I) (b : I → Label J K) : ℝ := by
  classical
  exact ∑ a ∈ (pathsOf r p).filter (fun a => paddedMap r p a = b), c a

theorem contracted_coeff_zero (c : (I → Label J K) → ℝ) (r : ℕ) (p : Pattern I) (b : I → Label J K)
    (hb : b ∉ contractedSupport r p) : contractedCoeff c r p b = 0 := by
  classical
  unfold contractedCoeff
  apply Finset.sum_eq_zero
  intro a ha
  exact False.elim (hb (Finset.mem_image.mpr ⟨a,(Finset.mem_filter.mp ha).1,(Finset.mem_filter.mp ha).2⟩))

theorem contracted_support_good (r : ℕ) (p : Pattern I) (b : I → Label J K)
    (hb : b ∈ contractedSupport r p) : paddedGood b r := by
  classical
  obtain ⟨a,ha,rfl⟩ := Finset.mem_image.mp hb
  have he := (Finset.mem_filter.mp ha).2
  unfold paddedMap
  rw [keepFor_eq r p a he]
  exact pad_good a r

theorem contracted_sum_eval (c : (I → Label J K) → ℝ) (r : ℕ) (p : Pattern I)
    (v : (I → Label J K) → ℝ) :
    (∑ b ∈ contractedSupport r p, contractedCoeff c r p b * v b) =
      ∑ a ∈ pathsOf r p, c a * v (paddedMap r p a) := by
  classical
  have he : (∑ b ∈ contractedSupport r p, contractedCoeff c r p b * v b) =
      ∑ b, contractedCoeff c r p b * v b := by
    apply Finset.sum_subset (Finset.subset_univ _)
    intro b _ hb
    rw [contracted_coeff_zero c r p b hb,zero_mul]
  rw [he, ← Finset.sum_fiberwise (pathsOf r p) (paddedMap r p) (fun a => c a * v (paddedMap r p a))]
  apply Finset.sum_congr rfl
  intro b _
  unfold contractedCoeff
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro a ha
  rw [(Finset.mem_filter.mp ha).2]

theorem contracted_cube_identity (c : (I → Label J K) → ℝ) (r : ℕ) (p : Pattern I) (u : I → Label J K → ℝ) :
    cubeForm (contractedCoeff c r p) u =
      cubeForm (fun a => c a * patternMask r p a)
        (fun i a => if i ∈ keepFor (J := J) (K := K) r p then u i a else u i none) := by
  classical
  unfold cubeForm
  have he : (∑ b ∈ contractedSupport r p, contractedCoeff c r p b * ∏ i, u i (b i)) =
      ∑ b, contractedCoeff c r p b * ∏ i, u i (b i) := by
    apply Finset.sum_subset (Finset.subset_univ _)
    intro b _ hb
    rw [contracted_coeff_zero c r p b hb,zero_mul]
  rw [← he, contracted_sum_eval]
  unfold pathsOf
  rw [Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro a _
  by_cases ha : patternOf a r = p
  · simp only [ha,if_true,patternMask,mul_one]
    congr 1
    apply Finset.prod_congr rfl
    intro i _
    unfold paddedMap pad
    split <;> simp_all
  · simp [ha,patternMask]

theorem contracted_cube_bound (c : (I → Label J K) → ℝ) (r : ℕ) (p : Pattern I) (V : ℝ)
    (hV : 0 ≤ V) (hc : CubeBound c V) :
    CubeBound (contractedCoeff c r p)
      (((rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r : ℝ)+2)^Fintype.card (Test I)*V) := by
  intro u hu
  rw [contracted_cube_identity]
  apply (pattern_mask_cost (J := J) (K := K) r p).2 c V hV hc
  intro i a
  split <;> apply hu

theorem contracted_phase_identity (c : (I → Label J K) → ℝ) (r : ℕ) (s : AddChar (Tensor J K) ℂ) :
    (∑ p : Pattern I, phaseEval optionLabel (contractedSupport r p) (contractedCoeff c r p) s) =
      phaseEval optionLabel univ c s := by
  classical
  unfold phaseEval
  rw [← Finset.sum_fiberwise (univ : Finset (I → Label J K)) (fun a => patternOf a r)
    (fun b => c b * sign s (∑ i, optionLabel (b i)))]
  apply Finset.sum_congr rfl
  intro p _
  rw [contracted_sum_eval]
  apply Finset.sum_congr rfl
  intro a ha
  have hp := (Finset.mem_filter.mp ha).2
  unfold paddedMap
  rw [keepFor_eq r p a hp,pad_freq]

#print axioms contracted_support_good
#print axioms contracted_cube_bound
#print axioms contracted_phase_identity
end Nightfall.AllOrder.Geometry
