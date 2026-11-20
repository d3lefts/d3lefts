import QuantumCircuitMixtureSimulation
import Route1WynerSimulation

/-!
# NIGHTFALL — physical quantum circuit simulation at Wyner-information cost

A source-exact composition of the merged finite complex matrix-oracle circuit
semantics with the newly proved Route 1 remaining-information decision tree.

This discharges both previously separate caller hypotheses:
* interaction degree at most 2T is derived from the circuit path semantics;
* acceptance probabilities lie in [0,1] by unitary/norm preservation.

The terminal bounds concern *whole-symbol query count and distributional
acceptance-error*, not polynomial classical computation time or sampling tasks.
-/

namespace Nightfall.ProductSpace.QuantumCircuitWyner

open Finset
open Nightfall.Route1Polylog

variable {ι α κ : Type}
    [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]
    [Fintype κ]

/-- A normalized T-query circuit on a finite product mixture has a
Wyner-information, rather than component-cardinality, query-depth bound.
The decomposition is supplied explicitly and may have zero masses. -/
theorem unitary_circuit_wyner_simulation
    {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (hc : QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w (fun x =>
        if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x -
          t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
            (2 * gam (2 * T) τ) +
          mutInfo P w /
            (etaC (2 * T) τ ^ 2 *
              w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
                (2 * T) τ)) / n + τ / ε ^ 2 := by
  classical
  let p := QuantumCircuitMixture.averageMarginal P w
  have hp1 : ∀ i, ∑ a, p i a = 1 :=
    QuantumCircuitMixture.averageMarginal_normalized P hP1 w hw1
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
  exact route1_wyner_simulation P hP0 hP1 w hw0 hw1
    (QuantumCircuitSimulation.acceptanceProbability c accept) hb
    (2 * T) hd hdeg τ hτ hτ1 ε hε n hn

/-- Distribution-only form. The bound is expressed using any strict
upper bound s on finite-latent Wyner common information, with no fixed
mixture decomposition supplied in the theorem statement. -/
theorem unitary_circuit_wyner_CI
    (ν : (ι → α) → ℝ)
    (hne : (wynerSet ν).Nonempty)
    (T : ℕ) (hT : 1 ≤ T)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (hc : QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerCI ν < s) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x *
        (if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x -
          t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
            (2 * gam (2 * T) τ) +
          s /
            (etaC (2 * T) τ ^ 2 *
              w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
                (2 * T) τ)) / n + τ / ε ^ 2 := by
  classical
  let p : ι → α → ℝ := fun _ a => if a = Classical.arbitrary α then 1 else 0
  have hp1 : ∀ i, ∑ a, p i a = 1 := by
    intro i
    simp [p]
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
  exact route1_wyner_CI ν hne
    (QuantumCircuitSimulation.acceptanceProbability c accept) hb
    (2 * T) hd hdeg τ hτ hτ1 ε hε n hn s hs

end Nightfall.ProductSpace.QuantumCircuitWyner

#print axioms Nightfall.ProductSpace.QuantumCircuitWyner.unitary_circuit_wyner_simulation
#print axioms Nightfall.ProductSpace.QuantumCircuitWyner.unitary_circuit_wyner_CI
