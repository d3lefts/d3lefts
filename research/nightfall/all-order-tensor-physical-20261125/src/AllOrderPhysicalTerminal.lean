import AllOrderFullForm
import AllOrderQuantumForm

namespace Nightfall.AllOrder.Quantum
open Finset Nightfall.AllOrder Nightfall.AllOrder.Geometry Nightfall.StructuralInformation.T2UniformParseval
variable {J K E : Type*} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K] [NormedAddCommGroup E] [InnerProductSpace ℂ E]

theorem sign_sum_tensor {I : Type*} [Fintype I] (s : AddChar (Tensor J K) ℂ) (b : I → Label J K) :
    sign s (∑ i, optionLabel (b i)) = ∏ i, sign s (optionLabel (b i)) := by
  classical
  have h (S : Finset I) : sign s (∑ i ∈ S, optionLabel (b i)) = ∏ i ∈ S, sign s (optionLabel (b i)) := by
    induction S using Finset.induction_on with
    | empty => simp [sign, s.map_zero_eq_one]
    | insert a S ha ih => rw [sum_insert ha,prod_insert ha,← ih,Nightfall.StructuralInformation.T2UniformParseval.sign_mul tensor_add_self]
  exact h univ

theorem physical_phase_identity (P : Label J K → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (effect : E →ₗ[ℂ] E) (T : ℕ) (s : AddChar (Tensor J K) ℂ) :
    phaseEval optionLabel univ (amplitudeCoeff P U ψ effect T) s =
      (inner ℂ (run P U ψ T (fun _ a => sign s (optionLabel a)))
        (effect (run P U ψ T (fun _ a => sign s (optionLabel a))))).re := by
  unfold phaseEval
  simp_rw [sign_sum_tensor]
  exact amplitude_cube_identity P U ψ effect T (fun _ a => sign s (optionLabel a))

end Nightfall.AllOrder.Quantum

namespace Nightfall.AllOrder.Quantum
open Finset Nightfall.AllOrder Nightfall.AllOrder.Geometry Nightfall.StructuralInformation.T2UniformParseval
variable {J K E : Type*} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K] [NormedAddCommGroup E] [InnerProductSpace ℂ E]

noncomputable def acceptance (P : Label J K → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (effect : E →ₗ[ℂ] E) (T : ℕ) (s : AddChar (Tensor J K) ℂ) : ℝ :=
  (inner ℂ (run P U ψ T (fun _ a => sign s (optionLabel a)))
    (effect (run P U ψ T (fun _ a => sign s (optionLabel a))))).re

theorem physical_tensor_simulation (P : Label J K → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (effect : E →ₗ[ℂ] E) (T : ℕ)
    (hP : ∀ x a b, a ≠ b → inner ℂ (P a x) (P b x) = 0)
    (hsum : ∀ x, ∑ a, P a x = x) (hU : ∀ k x, ‖U k x‖ ≤ ‖x‖)
    (hψ : ‖ψ‖ ≤ 1) (hE : ∀ x, ‖effect x‖ ≤ ‖x‖)
    (hpos : ∀ x, 0 ≤ (inner ℂ x (effect x)).re)
    (eps delta : ℝ) (heps : 0 < eps) (hdelta : 0 < delta) :
    ∃ Q : Finset (Label J K), Q.card ≤ simulationBudget (Fintype.card J) (Fintype.card (NonzeroFactor K)) (T+T+1) 1 eps delta ∧
      ∃ g : (↑Q → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar (Tensor J K) ℂ =>
        eps < |acceptance P U ψ effect (T+1) s - g (fun a => s (optionLabel a.1))|)).card : ℝ) ≤
        (Fintype.card (AddChar (Tensor J K) ℂ) : ℝ)*delta := by
  classical
  have hf (s : AddChar (Tensor J K) ℂ) : 0 ≤ phaseEval optionLabel univ (amplitudeCoeff P U ψ effect (T+1)) s ∧
      phaseEval optionLabel univ (amplitudeCoeff P U ψ effect (T+1)) s ≤ 1 := by
    rw [physical_phase_identity]
    refine ⟨hpos _,?_⟩
    have h := amplitude_cube_bound P U ψ effect (T+1) hP hsum hU hψ hE
      (fun _ a => sign s (optionLabel a)) (by intro i a; rcases char_sign tensor_add_self s (optionLabel a) with hh | hh <;> simp [sign,hh])
    rw [amplitude_cube_identity] at h
    exact (abs_le.mp h).2
  have hc := amplitude_cube_bound P U ψ effect (T+1) hP hsum hU hψ hE
  have h := bounded_tensor_form_simulation (n := T+1+T) (amplitudeCoeff P U ψ effect (T+1)) 1 eps delta (by norm_num) hc heps hdelta hf
  obtain ⟨Q,hQ,g,hg,herr⟩ := h
  refine ⟨Q,by simpa only [Nat.add_right_comm T 1 T] using hQ,g,hg,?_⟩
  have heq : (fun s : AddChar (Tensor J K) ℂ => phaseEval optionLabel univ (amplitudeCoeff P U ψ effect (T+1)) s) = acceptance P U ψ effect (T+1) := funext (physical_phase_identity P U ψ effect (T+1))
  change ((univ.filter (fun s : AddChar (Tensor J K) ℂ => eps < |acceptance P U ψ effect (T+1) s - g (fun a => s (optionLabel a.1))|)).card : ℝ) ≤ _
  simpa only [← heq] using herr

#print axioms physical_phase_identity
#print axioms physical_tensor_simulation
end Nightfall.AllOrder.Quantum
