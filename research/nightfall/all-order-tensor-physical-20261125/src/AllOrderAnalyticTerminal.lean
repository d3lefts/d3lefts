import AllOrderTerminal
import AllOrderRowBound

namespace Nightfall.AllOrder
open Finset
open Nightfall.StructuralInformation.T2UniformParseval
variable {A P G : Type*} [Fintype A] [DecidableEq A] [Fintype P] [DecidableEq P]
    [AddCommGroup G] [Fintype G] [DecidableEq G]

/-- The old terminal with its analytic row-norm premise discharged by the
    exact sign-cube form norm, at arbitrary order and every slot. -/
theorem all_pattern_simulation_from_chaos_norm {n : ℕ}
    (label : A → G) (h₂ : ∀ z : G, z+z=0)
    (c : P → (Fin (n+1) → A) → ℝ) (S : P → Finset (Fin (n+1) → A))
    (t K eps delta : ℝ) (B m : ℕ)
    (ht : 0 < t) (heps : 0 < eps)
    (hMt : Real.sqrt ((3:ℝ)^n)*K ≤ (m : ℝ)*t)
    (hK : ∀ p x, |chaos (c p) x| ≤ K)
    (hB : ∀ p z, ((S p).filter (fun b => (∑ i, label (b i)) = z)).card ≤ B)
    (hf : ∀ s : AddChar G ℂ, 0 ≤ (∑ p, phaseEval label (S p) (c p) s) ∧
        (∑ p, phaseEval label (S p) (c p) s) ≤ 1)
    (hbudget : (Fintype.card P : ℝ)^2 * (B : ℝ) * (Fintype.card (Fin (n+1)) : ℝ) *
          (t*(Real.sqrt ((3:ℝ)^n)*K)) ≤ eps^2*delta) :
    ∃ Q : Finset A, Q.card ≤ Fintype.card P * Fintype.card (Fin (n+1)) * m ∧
      ∃ g : (↑Q → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar G ℂ =>
        eps < |(∑ p, phaseEval label (S p) (c p) s) - g (fun a => s (label a.1))|)).card : ℝ) ≤
        (Fintype.card (AddChar G ℂ) : ℝ)*delta := by
  classical
  exact all_pattern_simulation label h₂ c S t (Real.sqrt ((3:ℝ)^n)*K) eps delta B m ht heps hMt
      (fun p i => all_slot_mixed_bound (c p) i K (hK p)) hB hf hbudget

#print axioms all_pattern_simulation_from_chaos_norm
end Nightfall.AllOrder
