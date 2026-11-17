import Mathlib
import PhysicalOperatorReduction
import ComplexPOVMOptimal

/-!
NIGHTFALL transitive source-conditioned Born lower bound.

The outcome denominator is *defined* from the actual averaged physical
density operator's computed diagonal source weights. The theorem removes
a manually supplied outcome-by-outcome hBorn inequality from the complex
POVM optimization in this exact unnormalized source model.

STILL OPEN: kernel identification with the trace of the normalized
physical average, full-register GHZ projector/complement attaining
POVM, and operational gain normalization.
-/
namespace Nightfall.Quantum.SourceBorn

open scoped BigOperators Matrix ComplexOrder
open Matrix
noncomputable section

abbrev Register (d : ℕ) := Fin d → Fin 2

def zeroRay (d : ℕ) : Register d := fun _ => 0
def oneRay (d : ℕ) : Register d := fun _ => 1

def localWeight (a : Fin 2) : ℝ :=
  if a = 0 then 9 / 4 else 3 / 4

def sourceWeight (d : ℕ) (a : Register d) : ℝ :=
  ∏ j, localWeight (a j)

theorem localWeight_pos (a : Fin 2) : 0 < localWeight a := by
  fin_cases a <;> norm_num [localWeight]

theorem sourceWeight_pos (d : ℕ) (a : Register d) :
    0 < sourceWeight d a := by
  unfold sourceWeight
  exact Finset.prod_pos (fun j _ => localWeight_pos (a j))

theorem actual_source_B_diagonal_is_weight
    (d : ℕ) (a : Register d) :
    OperatorReduction.unnormalizedB d a a = (sourceWeight d a : ℂ) := by
  rw [OperatorReduction.actual_B_diagonal]
  have hloc : ∀ x : Fin 2,
      OperatorReduction.localBWeight x = (localWeight x : ℂ) := by
    intro x
    fin_cases x <;> norm_num [OperatorReduction.localBWeight, localWeight]
  simp_rw [hloc]
  simp [sourceWeight]

theorem actual_source_B_weight_real (d : ℕ) (a : Register d) :
    (OperatorReduction.unnormalizedB d a a).re = sourceWeight d a := by
  rw [actual_source_B_diagonal_is_weight]
  simp

theorem rays_distinct (d : ℕ) (hd : 0 < d) :
    zeroRay d ≠ oneRay d := by
  intro h
  have hz : (0 : Fin 2) = 1 := by
    simpa [zeroRay, oneRay] using
      congrArg (fun v : Register d => v ⟨0, hd⟩) h
  exact (by decide : (0 : Fin 2) ≠ 1) hz

theorem finite_two_ray_mass_lower
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (w : ι → ℝ) (hw : ∀ i, 0 ≤ w i)
    (E : Matrix ι ι ℂ) (hE : E.PosSemidef)
    (a b : ι) (hab : a ≠ b) :
    w a * (E a a).re + w b * (E b b).re ≤
      ∑ i, w i * (E i i).re := by
  classical
  let f : ι → ℝ := fun i => w i * (E i i).re
  have hfi : ∀ i, 0 ≤ f i := by
    intro i
    exact mul_nonneg (hw i)
      ((RCLike.nonneg_iff.mp (hE.diag_nonneg (i := i))).1)
  have hsubset : ({a, b} : Finset ι) ⊆ Finset.univ :=
    Finset.subset_univ _
  have hsum : (∑ i ∈ ({a, b} : Finset ι), f i) ≤
      ∑ i : ι, f i := by
    apply Finset.sum_le_sum_of_subset_of_nonneg hsubset
    intro i hi hioutside
    exact hfi i
  simpa [f, hab] using hsum

def sourceBornWeight (d : ℕ)
    (E : Matrix (Register d) (Register d) ℂ) : ℝ :=
  ∑ a, sourceWeight d a * (E a a).re

theorem actual_source_born_lower
    (d : ℕ) (hd : 0 < d)
    (E : Matrix (Register d) (Register d) ℂ)
    (hE : E.PosSemidef) :
    sourceWeight d (zeroRay d) * (E (zeroRay d) (zeroRay d)).re +
      sourceWeight d (oneRay d) * (E (oneRay d) (oneRay d)).re ≤
      sourceBornWeight d E := by
  exact finite_two_ray_mass_lower (sourceWeight d)
    (fun i => (sourceWeight_pos d i).le) E hE
      (zeroRay d) (oneRay d) (rays_distinct d hd)

theorem physical_source_bayes_upper
    (d : ℕ) (hd : 0 < d)
    {Out : Type*} [Fintype Out]
    (E : Out → Matrix (Register d) (Register d) ℂ)
    (hpositive : ∀ z, (E z).PosSemidef)
    (hcomplete : (∑ z, E z) = 1)
    (t : ℝ) :
    (∑ z, (2 * t * (E z (zeroRay d) (oneRay d)).re) ^ 2 /
      sourceBornWeight d (E z)) ≤
      4 * t ^ 2 /
        (sourceWeight d (zeroRay d) + sourceWeight d (oneRay d)) := by
  classical
  exact ComplexPOVM.complex_povm_energy_optimal E hpositive hcomplete
    (zeroRay d) (oneRay d)
    (fun z => sourceBornWeight d (E z))
    (sourceWeight d (zeroRay d)) (sourceWeight d (oneRay d)) t
    (sourceWeight_pos d (zeroRay d)) (sourceWeight_pos d (oneRay d))
    (fun z => actual_source_born_lower d hd (E z) (hpositive z))

#print axioms Nightfall.Quantum.SourceBorn.actual_source_B_diagonal_is_weight
#print axioms Nightfall.Quantum.SourceBorn.finite_two_ray_mass_lower
#print axioms Nightfall.Quantum.SourceBorn.actual_source_born_lower
#print axioms Nightfall.Quantum.SourceBorn.physical_source_bayes_upper

end
end Nightfall.Quantum.SourceBorn
