import AllOrderQuantumPath
import AllOrderMaskCost

namespace Nightfall.AllOrder.Quantum
open Finset
open Nightfall.AllOrder
variable {A E : Type*} [Fintype A] [DecidableEq A] [NormedAddCommGroup E] [InnerProductSpace ℂ E]

noncomputable def amplitudeCoeff (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (effect : E →ₗ[ℂ] E) (T : ℕ) (b : Fin (T+T) → A) : ℝ :=
  (inner ℂ (path P U ψ T (fun i => b (Fin.castAdd T i)))
    (effect (path P U ψ T (fun i => b (Fin.natAdd T i))))).re

theorem sum_two_paths (T : ℕ) (F : (Fin T → A) → (Fin T → A) → ℝ) :
    (∑ b : Fin (T+T) → A, F (fun i => b (Fin.castAdd T i)) (fun i => b (Fin.natAdd T i))) =
      ∑ a : Fin T → A, ∑ b : Fin T → A, F a b := by
  classical
  let e : (Fin (T+T) → A) ≃ ((Fin T → A) × (Fin T → A)) := {
    toFun := fun b => (fun i => b (Fin.castAdd T i), fun i => b (Fin.natAdd T i))
    invFun := fun p => Fin.addCases p.1 p.2
    left_inv := by intro b; funext i; refine Fin.addCases (fun j => ?_) (fun j => ?_) i <;> simp [← Fin.natAdd_eq_addNat]
    right_inv := by intro p; ext i <;> simp [← Fin.natAdd_eq_addNat] }
  calc
    _ = ∑ p : (Fin T → A) × (Fin T → A), F p.1 p.2 := Fintype.sum_equiv e _ _ (fun b => rfl)
    _ = _ := Fintype.sum_prod_type _

/-- The real coefficient form is exactly the two-run sesquilinear expression. -/
theorem amplitude_cube_identity (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (effect : E →ₗ[ℂ] E) (T : ℕ) (u : Fin (T+T) → A → ℝ) :
    cubeForm (amplitudeCoeff P U ψ effect T) u =
      (inner ℂ (run P U ψ T (fun i => u (Fin.castAdd T i)))
        (effect (run P U ψ T (fun i => u (Fin.natAdd T i))))).re := by
  classical
  unfold cubeForm amplitudeCoeff
  simp_rw [Fin.prod_univ_add]
  rw [sum_two_paths T (fun a b => (inner ℂ (path P U ψ T a) (effect (path P U ψ T b))).re * ((∏ i, u (Fin.castAdd T i) (a i)) * ∏ i, u (Fin.natAdd T i) (b i)))]
  rw [run_path_expansion,run_path_expansion,map_sum,sum_inner]
  simp_rw [inner_sum,map_smul,inner_smul_left,inner_smul_right,Complex.re_sum]
  apply Finset.sum_congr rfl
  intro a _
  apply Finset.sum_congr rfl
  intro b _
  simp only [Complex.conj_ofReal,Complex.re_ofReal_mul]
  ring

/-- The normalized physical circuit implies the original cube bound. -/
theorem amplitude_cube_bound (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (effect : E →ₗ[ℂ] E) (T : ℕ)
    (hP : ∀ x a b, a ≠ b → inner ℂ (P a x) (P b x) = 0)
    (hsum : ∀ x, ∑ a, P a x = x) (hU : ∀ k x, ‖U k x‖ ≤ ‖x‖)
    (hψ : ‖ψ‖ ≤ 1) (hE : ∀ x, ‖effect x‖ ≤ ‖x‖) : CubeBound (amplitudeCoeff P U ψ effect T) 1 := by
  intro u hu
  rw [amplitude_cube_identity]
  have h1 := (run_contract P U ψ hP hsum hU T (fun i => u (Fin.castAdd T i)) (fun i => hu _)).trans hψ
  have h2 := (run_contract P U ψ hP hsum hU T (fun i => u (Fin.natAdd T i)) (fun i => hu _)).trans hψ
  apply (Complex.abs_re_le_norm _).trans
  apply (norm_inner_le_norm _ _).trans
  exact mul_le_one₀ h1 (norm_nonneg _) ((hE _).trans h2)

#print axioms amplitude_cube_identity
#print axioms amplitude_cube_bound
end Nightfall.AllOrder.Quantum
