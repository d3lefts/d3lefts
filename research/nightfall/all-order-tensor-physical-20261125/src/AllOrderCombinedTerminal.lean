import AllOrderAnalyticTerminal
import AllOrderPaddedFiber

namespace Nightfall.AllOrder.Geometry
open Finset
open Nightfall.AllOrder
variable {J K P : Type*} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]
  [Fintype P] [DecidableEq P]

/-- Actual binary tensor-character simulation for contracted pattern arrays:
    neither the active-fiber count nor the mixed-row inequality is assumed.
    The remaining premises are the pattern representation/support, its
    cube norm, normalized output range, and the explicit numerical budget. -/
theorem tensor_pattern_simulation {n : ℕ}
    (c : P → (Fin (n+1) → Label J K) → ℝ) (S : P → Finset (Fin (n+1) → Label J K))
    (t C eps delta : ℝ) (m : ℕ)
    (ht : 0 < t) (heps : 0 < eps)
    (hMt : Real.sqrt ((3:ℝ)^n)*C ≤ (m : ℝ)*t)
    (hC : ∀ p x, |chaos (c p) x| ≤ C)
    (hgood : ∀ p b, b ∈ S p → paddedGood b (circuitRadius (Fintype.card (NonzeroFactor K)) (n+1)))
    (hf : ∀ s : AddChar (Tensor J K) ℂ,
        0 ≤ (∑ p, phaseEval optionLabel (S p) (c p) s) ∧
        (∑ p, phaseEval optionLabel (S p) (c p) s) ≤ 1)
    (hbudget : (Fintype.card P : ℝ)^2 * (fiberBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) (n+1) : ℝ) *
          ((n+1 : ℕ) : ℝ) * (t*(Real.sqrt ((3:ℝ)^n)*C)) ≤ eps^2*delta) :
    ∃ Q : Finset (Label J K), Q.card ≤ Fintype.card P * (n+1) * m ∧
      ∃ g : (↑Q → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar (Tensor J K) ℂ =>
        eps < |(∑ p, phaseEval optionLabel (S p) (c p) s) - g (fun a => s (optionLabel a.1))|)).card : ℝ) ≤
        (Fintype.card (AddChar (Tensor J K) ℂ) : ℝ)*delta := by
  classical
  have hB (p : P) (z : Tensor J K) := padded_fiber_bound (S p) (by simpa using hgood p) z
  simpa only [Fintype.card_fin] using
    all_pattern_simulation_from_chaos_norm (G := Tensor J K) optionLabel tensor_add_self c S t C eps delta
      (fiberBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) (n+1)) m ht heps hMt hC
      (by simpa only [Fintype.card_fin] using hB) hf (by simpa only [Fintype.card_fin] using hbudget)

#print axioms tensor_pattern_simulation
end Nightfall.AllOrder.Geometry
