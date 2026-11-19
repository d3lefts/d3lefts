import QuantumCircuitSimulation
import MixtureSimulation

/-!
# NIGHTFALL — normalized quantum circuits simulated on product mixtures

Source-closed bridge from the finite complex matrix-oracle circuit semantics
(QuantumCircuitPaths, QuantumCircuitNormalization) through indicator degree
(QuantumPathDegree) to the Jensen-sharpened product-mixture simulator.

The original circuit accepts via the Born rule. No low-degree hypothesis and
no separately postulated acceptance probability bound are assumed.

Scope: finite-dimensional T-query whole-symbol matrix-oracle circuits with
a normalized initial state and norm-preserving fixed/oracle matrices; finite
input alphabets and finite mixtures of arbitrary product laws, including zero
mixture weights and zero-mass coordinate symbols.

This certifies query complexity and distributional error, not classical
computation time, and makes no claim for general correlated distributions.
-/

namespace Nightfall.ProductSpace.QuantumCircuitMixture

open Finset

variable {ι α κ Θ : Type}
    [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α] [Fintype κ] [Fintype Θ]

/-- A single reference product marginal whose symbol masses sum to one.
    This is used only for the law-independent indicator-degree certificate,
    not for simulating the correlated input distribution. -/
noncomputable def averageMarginal
    (P : Θ → ι → α → ℝ) (w : Θ → ℝ) : ι → α → ℝ :=
  fun i a => ∑ θ, w θ * P θ i a

theorem averageMarginal_normalized
    (P : Θ → ι → α → ℝ)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw1 : ∑ θ, w θ = 1) :
    ∀ i, ∑ a, averageMarginal P w i a = 1 := by
  classical
  intro i
  calc
    (∑ a, averageMarginal P w i a) =
        ∑ θ, w θ * (∑ a, P θ i a) := by
      simp only [averageMarginal]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro θ _
      rw [Finset.mul_sum]
    _ = ∑ θ, w θ := by simp only [hP1, mul_one]
    _ = 1 := hw1

/-- Fully kernel-checkable, normalized circuit-to-mixture simulation theorem.

For any M-component mixture of product laws, any normalized T-query finite
complex matrix-oracle circuit and any 0 < τ ≤ 1/2, ε > 0 and n > 0, a
deterministic classical whole-symbol decision tree with depth at most n has
mixture probability of acceptance-error greater than ε bounded by

  (3 sqrt(2) π^6 (2T)^6 M / (τ sqrt τ)
   + 512 (2T)^4 M^4 / τ^3) / n + τ / ε^2.

The circuit-to-degree ≤ 2T and unitary-normalization steps are derived
from the circuit semantics, not supplied by the caller. -/
theorem unitary_circuit_mixture_simulation_jensen
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (hc : QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w (fun x =>
        if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x -
            t.eval x| then (1 : ℝ) else 0) ≤
        (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
          Fintype.card Θ / (τ * Real.sqrt τ) +
         512 * ((2 * T : ℕ) : ℝ) ^ 4 * (Fintype.card Θ : ℝ) ^ 4 /
          τ ^ 3) / n + τ / ε ^ 2 := by
  classical
  let p := averageMarginal P w
  have hp1 : ∀ i, ∑ a, p i a = 1 :=
    averageMarginal_normalized P hP1 w hw1
  have hd : 1 ≤ 2 * T := by omega
  have hdeg : RowBound.HasProdDegreeLE
      (QuantumCircuitSimulation.acceptanceProbability c accept) (2 * T) :=
    QuantumCircuitSimulation.acceptance_degree p hp1 T c accept
  have hb : ∀ x,
      0 ≤ QuantumCircuitSimulation.acceptanceProbability c accept x ∧
      QuantumCircuitSimulation.acceptanceProbability c accept x ≤ 1 := by
    intro x
    simpa only [QuantumCircuitNormalization.probability,
      QuantumCircuitSimulation.acceptanceProbability] using
      QuantumCircuitNormalization.probability_in_unit_interval hc accept x
  exact Mixture.mixture_simulation_jensen P hP0 hP1 w hw0 hw1
    (QuantumCircuitSimulation.acceptanceProbability c accept) hb
    (2 * T) hd hdeg τ hτ hτ2 ε hε n hn

#print axioms Nightfall.ProductSpace.QuantumCircuitMixture.unitary_circuit_mixture_simulation_jensen

end Nightfall.ProductSpace.QuantumCircuitMixture
