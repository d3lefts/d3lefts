import QuantumCircuitSimulation
import MixtureSimulation

/-!
# NIGHTFALL — normalized quantum query circuits over latent product mixtures

Composes the exact complex matrix-oracle semantics and output-state normalization
with the Jensen-improved, source-law mixture decision tree.

No degree premise is assumed: acceptance degree ≤ 2*T is established from
the complex query circuit itself. Zero-weight components and zero-mass symbols
are allowed. The classical cost is query depth only, not runtime.

The circuit notion is finite matrix-oracle / whole-symbol query semantics.
No assumption is made about correlated input laws beyond the stated
mixture of independent components.
-/

namespace Nightfall.ProductSpace.QuantumMixtureSimulation

open Finset
open Nightfall.ProductSpace

variable {ι α κ Θ : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
  [Nonempty α] [Fintype κ] [Fintype Θ] [Nonempty Θ]

/-- **Circuit-to-mixture theorem with exact Jensen error bound.**
The nonempty latent typeclass is redundant for normalized mixture weights,
but makes a witness component available to the underlying law-indexed
indicator-degree theorem. No atom-lower-bound assumptions occur. -/
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
        if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x - t.eval x|
        then (1 : ℝ) else 0) ≤
        (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
             Fintype.card Θ / (τ * Real.sqrt τ) +
          512 * ((2 * T : ℕ) : ℝ) ^ 4 *
             (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n + τ / ε ^ 2 := by
  classical
  let θ0 : Θ := Classical.choice inferInstance
  have hdegree :
      RowBound.HasProdDegreeLE
        (QuantumCircuitSimulation.acceptanceProbability c accept) (2 * T) :=
    QuantumCircuitSimulation.acceptance_degree (P θ0) (hP1 θ0) T c accept
  have hBorn :
      ∀ x, 0 ≤ QuantumCircuitSimulation.acceptanceProbability c accept x ∧
        QuantumCircuitSimulation.acceptanceProbability c accept x ≤ 1 := by
    intro x
    simpa only [QuantumCircuitNormalization.probability,
      QuantumCircuitSimulation.acceptanceProbability] using
      QuantumCircuitNormalization.probability_in_unit_interval hc accept x
  exact Mixture.mixture_simulation_jensen P hP0 hP1 w hw0 hw1
    (QuantumCircuitSimulation.acceptanceProbability c accept)
    hBorn (2 * T) (by omega) hdegree τ hτ hτ2 ε hε n hn

/-- **Explicit target-error version.** For τ = ε²δ/2 the certified
depth threshold consists of the Jensen within-component term and the
Gini posterior-separation term, with no low-degree acceptance hypothesis.

The budget condition states exactly which integer depth n is sufficient;
the theorem does not claim its two additive terms have been optimized. -/
theorem unitary_circuit_mixture_delta
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (hc : QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (hτ2 : ε ^ 2 * δ / 2 ≤ 1 / 2)
    (n : ℕ) (hn : 0 < n)
    (hbudget :
      (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
           Fintype.card Θ /
           ((ε ^ 2 * δ / 2) * Real.sqrt (ε ^ 2 * δ / 2)) +
        512 * ((2 * T : ℕ) : ℝ) ^ 4 *
           (Fintype.card Θ : ℝ) ^ 4 / (ε ^ 2 * δ / 2) ^ 3) / n ≤ δ / 2) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w (fun x =>
        if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x - t.eval x|
        then (1 : ℝ) else 0) ≤ δ := by
  have hτ : 0 < ε ^ 2 * δ / 2 := by positivity
  obtain ⟨t, ht, herr⟩ :=
    unitary_circuit_mixture_simulation_jensen P hP0 hP1 w hw0 hw1 T hT
      c hc accept (ε ^ 2 * δ / 2) hτ hτ2 ε hε n hn
  refine ⟨t, ht, ?_⟩
  have hε2 : ε ^ 2 ≠ 0 := ne_of_gt (by positivity)
  have hleaf : (ε ^ 2 * δ / 2) / ε ^ 2 = δ / 2 := by
    field_simp
  calc
    _ ≤ (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
           Fintype.card Θ /
           ((ε ^ 2 * δ / 2) * Real.sqrt (ε ^ 2 * δ / 2)) +
        512 * ((2 * T : ℕ) : ℝ) ^ 4 *
           (Fintype.card Θ : ℝ) ^ 4 / (ε ^ 2 * δ / 2) ^ 3) / n +
          (ε ^ 2 * δ / 2) / ε ^ 2 := herr
    _ ≤ δ := by rw [hleaf]; linarith

end Nightfall.ProductSpace.QuantumMixtureSimulation

#print axioms Nightfall.ProductSpace.QuantumMixtureSimulation.unitary_circuit_mixture_simulation_jensen
#print axioms Nightfall.ProductSpace.QuantumMixtureSimulation.unitary_circuit_mixture_delta
