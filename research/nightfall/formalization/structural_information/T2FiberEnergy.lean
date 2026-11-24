import Mathlib

/-!
# NIGHTFALL T2 — exact complex Cauchy charging by frequency fibers

The T2 Fourier tail proof repeatedly bounds the grouped complex
coefficient energy at each XOR frequency by the maximal number of
original four-slot tuples at that frequency times their *ungrouped*
squared energy. This source proves the exact universal operator,
not a finite-field enumeration or a hidden grouping assumption.

For arbitrary finite source tuples S, any frequency map ω:S→Z,
arbitrary complex amplitudes c_a, any subset F of frequencies and
an upper multiplicity M on each fiber, one has

  Σ_{z∈F} |Σ_{a∈S:ω(a)=z} c_a|²
       <= M Σ_{a∈S} |c_a|².

The proof uses finite real Cauchy–Schwarz, complex triangle
inequality, and disjointness of function fibers. It neither assumes
individual path coefficients orthogonal nor introduces synthetic
classical queries. Apply it to Class A at K4, triple corrections at
M2, and joint zero-triple corrections at 6M2.
-/

namespace Nightfall.StructuralInformation.T2FiberEnergy

open Finset

variable {A Z : Type*} [DecidableEq A] [DecidableEq Z]

/-- Actual coefficient support at the selected frequency. -/
noncomputable def frequencyFiber (S : Finset A) (omega : A → Z)
    (z : Z) : Finset A :=
  S.filter (fun a => omega a = z)

/-- A finite sum of arbitrary complex path coefficients satisfies the
sharp card-times-ungrouped-energy bound without orthogonality. -/
theorem norm_complex_sum_sq_le_card
    (S : Finset A) (c : A → ℂ) :
    ‖∑ a ∈ S, c a‖ ^ 2 ≤
      (S.card : ℝ) * (∑ a ∈ S, ‖c a‖ ^ 2) := by
  have hnorm : ‖∑ a ∈ S, c a‖ ≤ ∑ a ∈ S, ‖c a‖ :=
    norm_sum_le _ _
  have hnonneg : 0 ≤ ∑ a ∈ S, ‖c a‖ :=
    Finset.sum_nonneg (fun a ha => norm_nonneg _)
  have hsq : ‖∑ a ∈ S, c a‖ ^ 2 ≤
      (∑ a ∈ S, ‖c a‖) ^ 2 :=
    (sq_le_sq₀ (norm_nonneg _) hnonneg).mpr hnorm
  have hcs :
      (∑ a ∈ S, ‖c a‖) ^ 2 ≤
      (S.card : ℝ) * (∑ a ∈ S, ‖c a‖ ^ 2) := by
    simpa only [one_mul, one_pow, Finset.sum_const_zero, Finset.sum_const,
      nsmul_eq_mul, mul_one, Nat.cast_id] using
      (Finset.sum_mul_sq_le_sq_mul_sq (R := ℝ) S
        (fun _ => 1) (fun a => ‖c a‖))
  exact hsq.trans hcs

/-- Every original coefficient is charged to at most one
frequency in F; this is a genuine disjoint-fiber identity, not a
postulated energy inequality. -/
theorem frequency_fibers_disjoint_energy
    (S : Finset A) (F : Finset Z) (omega : A → Z)
    (u : A → ℝ) (hu : ∀ a, 0 ≤ u a) :
    (∑ z ∈ F, ∑ a ∈ frequencyFiber S omega z, u a) ≤
      ∑ a ∈ S, u a := by
  have hsum :
      (∑ z ∈ F, ∑ a ∈ frequencyFiber S omega z, u a) =
        ∑ a ∈ S, if omega a ∈ F then u a else 0 := by
    simp [frequencyFiber, Finset.sum_filter, Finset.sum_comm]
  rw [hsum]
  apply Finset.sum_le_sum
  intro a _
  split_ifs
  · exact le_refl _
  · exact hu a

/-- The universal grouped complex Fourier-energy bound by the
actual finite original-tuple multiplicity at each frequency,
including empty fibers and arbitrary complex cancellation. -/
theorem grouped_fourier_energy_le_multiplicity
    (S : Finset A) (F : Finset Z) (omega : A → Z)
    (c : A → ℂ) (M : ℕ)
    (hM : ∀ z ∈ F, (frequencyFiber S omega z).card ≤ M) :
    (∑ z ∈ F, ‖∑ a ∈ frequencyFiber S omega z, c a‖ ^ 2) ≤
      (M : ℝ) * (∑ a ∈ S, ‖c a‖ ^ 2) := by
  have hrow : ∀ z ∈ F,
      ‖∑ a ∈ frequencyFiber S omega z, c a‖ ^ 2 ≤
        (M : ℝ) *
          (∑ a ∈ frequencyFiber S omega z, ‖c a‖ ^ 2) := by
    intro z hz
    have hcard : ((frequencyFiber S omega z).card : ℝ) ≤ M := by
      exact_mod_cast hM z hz
    calc
      _ ≤ ((frequencyFiber S omega z).card : ℝ) *
          (∑ a ∈ frequencyFiber S omega z, ‖c a‖ ^ 2) :=
          norm_complex_sum_sq_le_card _ c
      _ ≤ (M : ℝ) *
          (∑ a ∈ frequencyFiber S omega z, ‖c a‖ ^ 2) :=
          mul_le_mul_of_nonneg_right hcard
            (Finset.sum_nonneg (fun a ha => sq_nonneg _))
  calc
    (∑ z ∈ F, ‖∑ a ∈ frequencyFiber S omega z, c a‖ ^ 2) ≤
        ∑ z ∈ F, (M : ℝ) *
          (∑ a ∈ frequencyFiber S omega z, ‖c a‖ ^ 2) := by
      apply Finset.sum_le_sum
      intro z hz
      exact hrow z hz
    _ = (M : ℝ) * (∑ z ∈ F, ∑ a ∈ frequencyFiber S omega z,
          ‖c a‖ ^ 2) := by rw [Finset.mul_sum]
    _ ≤ (M : ℝ) * (∑ a ∈ S, ‖c a‖ ^ 2) := by
      apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg M)
      exact frequency_fibers_disjoint_energy S F omega
        (fun a => ‖c a‖ ^ 2) (fun a => sq_nonneg _)

#print axioms Nightfall.StructuralInformation.T2FiberEnergy.norm_complex_sum_sq_le_card
#print axioms Nightfall.StructuralInformation.T2FiberEnergy.frequency_fibers_disjoint_energy
#print axioms Nightfall.StructuralInformation.T2FiberEnergy.grouped_fourier_energy_le_multiplicity

end Nightfall.StructuralInformation.T2FiberEnergy
