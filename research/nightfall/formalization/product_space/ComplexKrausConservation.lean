import QuantumResponseOracleBridge

/-! Exact complex Kraus completeness -> mass conservation on arbitrary
finite ensembles, and harmless response-register padding. No spectral
factorization or complete adaptive-circuit dilation compiler claimed. -/
namespace Nightfall.ComplexKrausConservation

open Finset
open Nightfall.QuantumCircuitNormalization
open Nightfall.QuantumResponseOracleBridge

variable {κ β η : Type} [Fintype κ] [Fintype β] [Fintype η]

noncomputable def gram (ψ : κ → ℂ) : ℂ :=
  ∑ k, (starRingEnd ℂ) (ψ k) * ψ k

theorem gram_re (ψ : κ → ℂ) : (gram ψ).re = energy ψ := by
  unfold gram energy
  rw [Complex.re_sum]
  apply Finset.sum_congr rfl
  intro k _
  simp [Complex.mul_re, pow_two] <;> ring

/-- Standard Kraus completeness, written entry by entry. -/
def Complete [DecidableEq κ] (A : β → κ → κ → ℂ) : Prop :=
  ∀ i j, ∑ b, ∑ k, (starRingEnd ℂ) (A b k i) * A b k j =
    if i = j then 1 else 0

private theorem expand_inner (A : κ → κ → ℂ) (ψ : κ → ℂ) (k : κ) :
    (starRingEnd ℂ) (applyMat A ψ k) * applyMat A ψ k =
      ∑ i, ∑ j, ((starRingEnd ℂ) (ψ i) * ψ j) *
        ((starRingEnd ℂ) (A k i) * A k j) := by
  unfold applyMat
  simp only [map_sum, map_mul]
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem apply_gram_sum [DecidableEq κ] (A : β → κ → κ → ℂ)
    (hA : Complete A) (ψ : κ → ℂ) :
    ∑ b, gram (applyMat (A b) ψ) = gram ψ := by
  classical
  unfold gram
  simp_rw [expand_inner]
  let F : β → κ → κ → κ → ℂ := fun b k i j =>
    ((starRingEnd ℂ) (ψ i) * ψ j) *
      ((starRingEnd ℂ) (A b k i) * A b k j)
  change (∑ b, ∑ k, ∑ i, ∑ j, F b k i j) = _
  calc
    (∑ b, ∑ k, ∑ i, ∑ j, F b k i j) =
        ∑ b, ∑ i, ∑ k, ∑ j, F b k i j := by
      apply Finset.sum_congr rfl
      intro b _
      exact Finset.sum_comm
    _ = ∑ i, ∑ b, ∑ k, ∑ j, F b k i j := Finset.sum_comm
    _ = ∑ i, ∑ b, ∑ j, ∑ k, F b k i j := by
      apply Finset.sum_congr rfl
      intro i _
      apply Finset.sum_congr rfl
      intro b _
      exact Finset.sum_comm
    _ = ∑ i, ∑ j, ∑ b, ∑ k, F b k i j := by
      apply Finset.sum_congr rfl
      intro i _
      exact Finset.sum_comm
    _ = ∑ i, ∑ j, ((starRingEnd ℂ) (ψ i) * ψ j) *
          (∑ b, ∑ k, (starRingEnd ℂ) (A b k i) * A b k j) := by
      simp only [F, Finset.mul_sum]
    _ = ∑ i, (starRingEnd ℂ) (ψ i) * ψ i := by
      simp_rw [hA]
      simp [mul_ite]

theorem apply_energy_sum [DecidableEq κ] (A : β → κ → κ → ℂ)
    (hA : Complete A) (ψ : κ → ℂ) :
    ∑ b, energy (applyMat (A b) ψ) = energy ψ := by
  have h := congrArg Complex.re (apply_gram_sum A hA ψ)
  simpa only [Complex.re_sum, gram_re] using h

/-- Each vector in the finite ensemble carries its own probability weight
through its squared norm; no branch renormalization is needed. -/
theorem instrument_mass [DecidableEq κ] (A : β → κ → κ → ℂ)
    (hA : Complete A) (ψ : η → κ → ℂ) :
    ∑ b, ∑ h, energy (applyMat (A b) (ψ h)) = ∑ h, energy (ψ h) := by
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl (fun h _ => apply_energy_sum A hA (ψ h))

theorem energy_nonneg (ψ : κ → ℂ) : 0 ≤ energy ψ := by
  unfold energy
  exact Finset.sum_nonneg (fun k _ => add_nonneg (sq_nonneg _) (sq_nonneg _))

/-- A factorized accepting effect (one member of a complete instrument)
has nonnegative probability bounded by the input mass. -/
theorem terminal_effect_bounds [DecidableEq κ] (A : β → κ → κ → ℂ)
    (hA : Complete A) (ψ : κ → ℂ) (b : β) :
    0 ≤ energy (applyMat (A b) ψ) ∧ energy (applyMat (A b) ψ) ≤ energy ψ := by
  refine ⟨energy_nonneg _, ?_⟩
  rw [← apply_energy_sum A hA ψ]
  exact Finset.single_le_sum (fun c _ => energy_nonneg (applyMat (A c) ψ)) (mem_univ b)

variable {I G W : Type}
  [Fintype I] [DecidableEq I]
  [Fintype G] [DecidableEq G] [AddCommGroup G]
  [Fintype W] [DecidableEq W]

/-- A uniform response-register amplitude, with arbitrary address/workspace
amplitudes, is unchanged by every coherent translation query. -/
theorem translation_padding (x : I → G) (ψ : State I G W → ℂ)
    (hψ : ∀ i y z w, ψ (i,(y,w)) = ψ (i,(z,w))) :
    applyMat (standardResponseMatrix x) ψ = ψ := by
  classical
  let e := responseShift (W := W) x
  funext b
  have hiff (v : State I G W) : (b = e v) ↔ (v = e.symm b) := by
    constructor
    · intro h
      have he := congrArg e.symm h
      simpa using he.symm
    · intro h
      rw [h, e.apply_symm_apply]
  change (∑ v, (if b = e v then (1 : ℂ) else 0) * ψ v) = ψ b
  simp only [hiff, ite_mul, one_mul, zero_mul, Finset.sum_ite_eq', mem_univ, if_true]
  rcases b with ⟨i, y, w⟩
  exact hψ i (y - x i) y w

end Nightfall.ComplexKrausConservation

#print axioms Nightfall.ComplexKrausConservation.apply_energy_sum
#print axioms Nightfall.ComplexKrausConservation.instrument_mass
#print axioms Nightfall.ComplexKrausConservation.terminal_effect_bounds
#print axioms Nightfall.ComplexKrausConservation.translation_padding
