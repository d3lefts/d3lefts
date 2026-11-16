import Mathlib

/-!
NIGHTFALL quantum visibility: physically constructed product pure states.

This is a source-level Lean module. The generalized weighted SLD/Bayes
optimality theorem is a separate downstream proof, not assumed here.

Pure-state construction is pointwise over arbitrary finite tensor registers,
indexed by `Fin d → Fin 2`; no positive-semidefinite premise is supplied
by the caller. Full trace normalization follows from local norm-one identities.
-/

namespace Nightfall.Quantum.PhysicalQubit

open scoped BigOperators Matrix ComplexOrder
noncomputable section
open Matrix

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def densityOfAmplitude (ψ : ι → ℂ) : Matrix ι ι ℂ :=
  Matrix.vecMulVec ψ (star ψ)

theorem densityOfAmplitude_psd (ψ : ι → ℂ) :
    (densityOfAmplitude ψ).PosSemidef :=
  Matrix.posSemidef_vecMulVec_self_star ψ

theorem densityOfAmplitude_hermitian (ψ : ι → ℂ) :
    (densityOfAmplitude ψ).IsHermitian :=
  (densityOfAmplitude_psd ψ).1

theorem densityOfAmplitude_entry (ψ : ι → ℂ) (a b : ι) :
    densityOfAmplitude ψ a b = ψ a * star (ψ b) := rfl

theorem densityOfAmplitude_trace (ψ : ι → ℂ) :
    Matrix.trace (densityOfAmplitude ψ) =
      ∑ a, ψ a * star (ψ a) := by
  simp [Matrix.trace, densityOfAmplitude, Matrix.vecMulVec]

def qubitAmplitude (r : ℝ) (θ : ℂ) (a : Fin 2) : ℂ :=
  if a = 0 then (r : ℂ) / 2 else θ / 2

def qubitDensity (r : ℝ) (θ : ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  densityOfAmplitude (qubitAmplitude r θ)

theorem qubitDensity_psd (r : ℝ) (θ : ℂ) :
    (qubitDensity r θ).PosSemidef :=
  densityOfAmplitude_psd _

def productAmplitude (d : ℕ) (r : ℝ) (phase : Fin d → ℂ)
    (a : Fin d → Fin 2) : ℂ :=
  ∏ j, qubitAmplitude r (phase j) (a j)

def productDensity (d : ℕ) (r : ℝ) (phase : Fin d → ℂ) :
    Matrix (Fin d → Fin 2) (Fin d → Fin 2) ℂ :=
  densityOfAmplitude (productAmplitude d r phase)

theorem productDensity_psd (d : ℕ) (r : ℝ) (phase : Fin d → ℂ) :
    (productDensity d r phase).PosSemidef :=
  densityOfAmplitude_psd _

theorem productDensity_entry (d : ℕ) (r : ℝ) (phase : Fin d → ℂ)
    (a b : Fin d → Fin 2) :
    productDensity d r phase a b =
      ∏ j, qubitDensity r (phase j) (a j) (b j) := by
  simp [productDensity, qubitDensity, densityOfAmplitude_entry,
    productAmplitude, Finset.prod_mul_distrib]

theorem productAmplitude_norm_one (d : ℕ) (r : ℝ) (phase : Fin d → ℂ)
    (hlocal : ∀ j, ∑ a : Fin 2,
      qubitAmplitude r (phase j) a * star (qubitAmplitude r (phase j) a) = 1) :
    (∑ b : Fin d → Fin 2,
      productAmplitude d r phase b * star (productAmplitude d r phase b)) = 1 := by
  have hsum := Finset.sum_prod_piFinset (ι := Fin d)
      (s := (Finset.univ : Finset (Fin 2)))
      (g := fun j a => qubitAmplitude r (phase j) a *
        star (qubitAmplitude r (phase j) a))
  simp only [Fintype.piFinset_univ] at hsum
  calc
    (∑ b : Fin d → Fin 2,
        productAmplitude d r phase b * star (productAmplitude d r phase b)) =
        ∑ b : Fin d → Fin 2, ∏ j,
          qubitAmplitude r (phase j) (b j) *
          star (qubitAmplitude r (phase j) (b j)) := by
          apply Finset.sum_congr rfl
          intro b _
          simp [productAmplitude, Finset.prod_mul_distrib]
    _ = ∏ j, ∑ a : Fin 2,
          qubitAmplitude r (phase j) a *
          star (qubitAmplitude r (phase j) a) := by
          simpa only [Fintype.piFinset_univ] using hsum
    _ = 1 := by
      apply Finset.prod_eq_one
      intro j _
      simpa only [Fin.sum_univ_two] using hlocal j

theorem productDensity_trace_one (d : ℕ) (r : ℝ) (phase : Fin d → ℂ)
    (hlocal : ∀ j, ∑ a : Fin 2,
      qubitAmplitude r (phase j) a * star (qubitAmplitude r (phase j) a) = 1) :
    Matrix.trace (productDensity d r phase) = 1 := by
  rw [productDensity, densityOfAmplitude_trace]
  exact productAmplitude_norm_one d r phase hlocal

theorem qubitAmplitude_norm_one (r : ℝ) (θ : ℂ)
    (hr : r ^ 2 = 3) (hθ : θ * star θ = 1) :
    (∑ a : Fin 2,
      qubitAmplitude r θ a * star (qubitAmplitude r θ a)) = 1 := by
  have hrC : (r : ℂ) ^ 2 = 3 := by exact_mod_cast hr
  have hvalue :
      (((r : ℂ) / 2) * star ((r : ℂ) / 2) +
        (θ / 2) * star (θ / 2)) = 1 := by
    calc
      _ = ((r : ℂ) ^ 2 + θ * star θ) / 4 := by
        have hrstar : star (r : ℂ) = (r : ℂ) := by simp
        have htwostar : star (2 : ℂ) = 2 := by norm_num
        rw [hrstar, htwostar]
        ring
      _ = 1 := by rw [hrC, hθ]; norm_num
  rw [Fin.sum_univ_two]
  change (((r : ℂ) / 2) * star ((r : ℂ) / 2) +
      (θ / 2) * star (θ / 2)) = 1
  exact hvalue

theorem unit_phase_powers (θ : ℂ) (hθ : θ * star θ = 1) (n : ℕ) :
    θ ^ n * star (θ ^ n) = 1 := by
  rw [star_pow, ← mul_pow, hθ, one_pow]

theorem normalized_product_physical (d : ℕ) (phase : Fin d → ℂ)
    (hphase : ∀ j, phase j * star (phase j) = 1) :
    Matrix.trace (productDensity d (Real.sqrt 3) phase) = 1 := by
  apply productDensity_trace_one
  intro j
  apply qubitAmplitude_norm_one
  · norm_num
  · exact hphase j

theorem powered_phase_product_physical
    (d : ℕ) (ω : ℂ) (hω : ω * star ω = 1)
    (x : Fin d → Fin 3) :
    Matrix.trace (productDensity d (Real.sqrt 3)
      (fun j => ω ^ (x j).val)) = 1 := by
  apply normalized_product_physical
  intro j
  exact unit_phase_powers ω hω _

#print axioms Nightfall.Quantum.PhysicalQubit.densityOfAmplitude_psd
#print axioms Nightfall.Quantum.PhysicalQubit.qubitDensity_psd
#print axioms Nightfall.Quantum.PhysicalQubit.productDensity_psd
#print axioms Nightfall.Quantum.PhysicalQubit.productDensity_entry
#print axioms Nightfall.Quantum.PhysicalQubit.productDensity_trace_one
#print axioms Nightfall.Quantum.PhysicalQubit.qubitAmplitude_norm_one
#print axioms Nightfall.Quantum.PhysicalQubit.normalized_product_physical
#print axioms Nightfall.Quantum.PhysicalQubit.powered_phase_product_physical

end

end Nightfall.Quantum.PhysicalQubit
