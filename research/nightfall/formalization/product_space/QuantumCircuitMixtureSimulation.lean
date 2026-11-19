import QuantumCircuitSimulation
import MixtureSimulation

/-!
# NIGHTFALL: normalized quantum circuit → deterministic simulation on mixtures

This module composes already source-certified constructions:
* The finite complex matrix-oracle circuit semantics and Born probability degree
  bound from QuantumCircuitSimulation / QuantumCircuitNormalization.
* The arbitrary finite product-mixture Jensen decision tree from MixtureSimulation.

The hypotheses describe a normalized, norm-preserving T-query whole-symbol
circuit and an arbitrary M-component mixture of independently sampled symbols.
No lower bound on atom masses is assumed; zero-weight components are allowed.
All query budgets are worst-case tree depth; no running-time guarantee is made.

This source should only be called kernel certified once a strict pinned CI
has compiled the exact merged import closure with standard axioms.
-/

namespace Nightfall.ProductSpace.QuantumCircuitMixtureSimulation

open Finset
open Nightfall.ProductSpace

variable {ι α κ Θ : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
  [Fintype κ] [Fintype Θ] [Nonempty α] [Nonempty Θ]

/-- **Circuit-to-mixture quantified terminal.** No assumed interaction degree,
or assumed acceptance-probability boundedness, appears in the theorem. The
Born acceptance is computed from normalized finite complex quantum matrices.

For τ∈(0,1/2] and n≥1 the probability of an ε-discrepancy under the
mixture distribution is at most
 (3√2 π⁶ (2T)⁶ M/(τ√τ) + 512 (2T)⁴ M⁴/τ³)/n + τ/ε².
Thus setting τ=ε²δ/2 yields a polynomial worst-case classical query budget
independent of coordinate number, atom probabilities, and alphabet size. -/
theorem unitary_circuit_mixture_simulation_jensen
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w (fun x =>
        if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x - t.eval x|
        then (1 : ℝ) else 0) ≤
      (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
          Fintype.card Θ / (τ * Real.sqrt τ) +
        512 * ((2 * T : ℕ) : ℝ) ^ 4 *
          (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n + τ / ε ^ 2 := by
  have hBorn : ∀ x, 0 ≤ QuantumCircuitSimulation.acceptanceProbability c accept x ∧
      QuantumCircuitSimulation.acceptanceProbability c accept x ≤ 1 := by
    intro x
    simpa only [Nightfall.QuantumCircuitNormalization.probability,
      QuantumCircuitSimulation.acceptanceProbability] using
      Nightfall.QuantumCircuitNormalization.probability_in_unit_interval hc accept x
  have hdeg : RowBound.HasProdDegreeLE
      (QuantumCircuitSimulation.acceptanceProbability c accept) (2 * T) :=
    QuantumCircuitSimulation.acceptance_degree
      (P (Classical.choice ‹Nonempty Θ›))
      (hP1 (Classical.choice ‹Nonempty Θ›)) T c accept
  have hd : 1 ≤ 2 * T := by omega
  exact Mixture.mixture_simulation_jensen P hP0 hP1 w hw0 hw1
    (QuantumCircuitSimulation.acceptanceProbability c accept) hBorn
    (2 * T) hd hdeg τ hτ hτ2 ε hε n hn

/-- Error-probability formulation with explicit numerical budget certificate.
The sufficient bound is purely scalar, and can be discharged by the
application's chosen n, ε, δ and τ without hidden asymptotics. -/
theorem unitary_circuit_mixture_simulation
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε δ : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (hbudget :
      (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
          Fintype.card Θ / (τ * Real.sqrt τ) +
        512 * ((2 * T : ℕ) : ℝ) ^ 4 *
          (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n + τ / ε ^ 2 ≤ δ) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w (fun x =>
        if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x - t.eval x|
        then (1 : ℝ) else 0) ≤ δ := by
  obtain ⟨t, hq, he⟩ := unitary_circuit_mixture_simulation_jensen
    P hP0 hP1 w hw0 hw1 T hT c hc accept τ hτ hτ2 ε hε n hn
  exact ⟨t, hq, le_trans he hbudget⟩

end Nightfall.ProductSpace.QuantumCircuitMixtureSimulation

#print axioms Nightfall.ProductSpace.QuantumCircuitMixtureSimulation.unitary_circuit_mixture_simulation_jensen
#print axioms Nightfall.ProductSpace.QuantumCircuitMixtureSimulation.unitary_circuit_mixture_simulation
