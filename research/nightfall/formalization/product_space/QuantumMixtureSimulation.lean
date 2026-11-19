import MixtureSimulation
import QuantumCircuitSimulation

/-!
# NIGHTFALL — quantum query simulation over finite mixtures of product laws

The quantum acceptance function is the actual complex-circuit Born probability,
not a polynomial postulated to have degree 2T. By a proved path expansion it has
indicator interaction degree at most 2T. Norm preservation of every matrix in a
WellFormed circuit implies acceptance lies in [0,1]. The Jensen-sharpened
mixture simulator supplies one decision tree for the whole mixture law.

The simulator may depend on the circuit and mixture. This is symbol-query
complexity, not classical running time. All components are product laws and
may contain zero-mass symbols.
-/

namespace Nightfall.ProductSpace.QuantumMixture

open Finset
open Nightfall.ProductSpace
open Nightfall.ProductSpace.QuantumCircuitSimulation

variable {ι α κ Θ : Type}
    [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]
    [Fintype κ] [Fintype Θ] [Nonempty Θ]

/-- **End-to-end Jensen mixture theorem.** A normalized T-query finite
complex matrix-oracle circuit is classically approximable under any
M-component mixture of product input laws by ONE deterministic tree of
depth n and the exact Jensen-certified error expression.

Neither low degree nor acceptance boundedness is assumed in this theorem. -/
theorem unitary_circuit_mixture_simulation_jensen
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α,
      (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w
        (fun x => if ε < |acceptanceProbability c accept x - t.eval x|
                  then (1 : ℝ) else 0) ≤
        (3 * Real.sqrt 2 * Real.pi ^ 6 *
            (((2 * T : ℕ) : ℝ) ^ 6) * Fintype.card Θ /
            (τ * Real.sqrt τ) +
          512 * (((2 * T : ℕ) : ℝ) ^ 4) *
            (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n +
        τ / ε ^ 2 := by
  classical
  have hb : ∀ x, 0 ≤ acceptanceProbability c accept x ∧
      acceptanceProbability c accept x ≤ 1 := by
    intro x
    simpa only [Nightfall.QuantumCircuitNormalization.probability,
      acceptanceProbability] using
      Nightfall.QuantumCircuitNormalization.probability_in_unit_interval
        hc accept x
  let θ₀ : Θ := Classical.choice inferInstance
  have hdegree : RowBound.HasProdDegreeLE
      (acceptanceProbability c accept) (2 * T) :=
    acceptance_degree (P θ₀) (hP1 θ₀) T c accept
  have hd : 1 ≤ 2 * T := by omega
  exact Mixture.mixture_simulation_jensen P hP0 hP1
    w hw0 hw1 (acceptanceProbability c accept) hb
    (2 * T) hd hdegree τ hτ hτ2 ε hε n hn

/-- Failure-probability version. The explicit condition on n is precisely
the certified Jensen depth expression, without asymptotic notation. -/
theorem unitary_circuit_mixture_simulation_delta
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (δ : ℝ) (n : ℕ) (hn : 0 < n)
    (hdepth :
      (3 * Real.sqrt 2 * Real.pi ^ 6 *
            (((2 * T : ℕ) : ℝ) ^ 6) * Fintype.card Θ /
            (τ * Real.sqrt τ) +
          512 * (((2 * T : ℕ) : ℝ) ^ 4) *
            (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n +
        τ / ε ^ 2 ≤ δ) :
    ∃ t : Simulation.DTree ι α,
      (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w
        (fun x => if ε < |acceptanceProbability c accept x - t.eval x|
                  then (1 : ℝ) else 0) ≤ δ := by
  obtain ⟨t, ht, he⟩ :=
    unitary_circuit_mixture_simulation_jensen
      P hP0 hP1 w hw0 hw1 T hT c hc accept
      τ hτ hτ2 ε hε n hn
  exact ⟨t, ht, le_trans he hdepth⟩

end Nightfall.ProductSpace.QuantumMixture
