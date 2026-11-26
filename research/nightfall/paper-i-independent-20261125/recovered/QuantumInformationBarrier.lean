import Route1WynerConverse
import QuantumCircuitSimulation

/-!
# NIGHTFALL: normalized quantum circuits and the general-Wyner query barrier

This is a direct source-level composition of previously established results:
* `QuantumCircuitSimulation.acceptance_degree`: genuine finite complex matrix-oracle
  semantics imply interaction degree at most 2T;
* `QuantumCircuitNormalization.probability_in_unit_interval`: norm-preserving
  circuits have a bona fide Born acceptance probability in [0,1];
* `Route1Polylog.route1_wyner_general`: general-latent Wyner-information
  distributional simulation for bounded low-degree functions;
* `Route1Polylog.wyner_converse_from_approximation_hardness`: exact numerical
  contrapositive under *acceptance-value approximation hardness*.

The positive statement and its necessary-information consequence use the same
original *symbol-coordinate* query model. They do NOT assert a quantum speedup,
a lower bound from an unconverted promise problem, efficient classical computation,
coherent emulation of an arbitrary quantum oracle, or global novelty.
No degree, Born-probability, or hidden simulation premise is supplied by the caller.
-/

namespace Nightfall.QuantumInformationBarrier

open Finset
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.QuantumCircuitSimulation

variable {ι α κ : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
  [Fintype κ]

/-- Actual circuit execution, not a hypothetical low-degree surrogate, gives
a degree bound. A point-mass reference alphabet law is used only to invoke
the representation-independent degree lemma; it is not the input distribution. -/
private theorem circuit_acceptance_degree {T : ℕ}
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool) :
    HasProdDegreeLE (acceptanceProbability c accept) (2 * T) := by
  classical
  let p : ι → α → ℝ := fun _ a => if a = Classical.arbitrary α then 1 else 0
  have hp1 : ∀ i, ∑ a, p i a = 1 := by
    intro i
    simp [p]
  exact acceptance_degree p hp1 T c accept

/-- Physical norm-preservation proves the actual Born range condition. -/
private theorem circuit_acceptance_bounded {T : ℕ}
    {c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T}
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool) (x : ι → α) :
    0 ≤ acceptanceProbability c accept x ∧
      acceptanceProbability c accept x ≤ 1 := by
  simpa only [Nightfall.QuantumCircuitNormalization.probability,
    acceptanceProbability] using
      Nightfall.QuantumCircuitNormalization.probability_in_unit_interval hc accept x

/-- Strongest source-connected forward theorem on arbitrary *finite* symbol
coordinates and arbitrary joint input PMFs. The condition `wynerGen ν < s`
uses genuine general-latent Wyner common information, in natural logarithms.
Only scalar acceptance probability is approximated. -/
theorem normalized_circuit_wyner_simulation
    (ν : (ι → α) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      (∑ x, ν x *
        (if ε < |acceptanceProbability c accept x - t.eval x|
          then (1 : ℝ) else 0)) ≤
        ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
          (2 * gam (2 * T) τ) +
          s / (etaC (2 * T) τ ^ 2 *
            w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
              (2 * T) τ)) / n + τ / ε ^ 2 := by
  have hd : 1 ≤ 2 * T := by omega
  exact route1_wyner_general ν hν0 hν1
    (acceptanceProbability c accept)
    (circuit_acceptance_bounded hc accept)
    (2 * T) hd (circuit_acceptance_degree c accept)
    τ hτ hτ1 ε hε n hn s hs

/-- Quantitative necessary common information for *acceptance-approximation*
hardness of a specific normalized T-query circuit. The hardness premise
quantifies over all original-symbol-coordinate deterministic query trees,
at worst-case depth at most n. A separate task-to-acceptance reduction is
required before applying this to a named promise problem. -/
theorem normalized_circuit_wyner_necessity
    (ν : (ι → α) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) (δ : ℝ)
    (hhard : ∀ t : DTree ι α,
      (∀ x, t.queries x ≤ n) →
        δ < ∑ x, ν x *
          (if ε < |acceptanceProbability c accept x - t.eval x|
            then (1 : ℝ) else 0)) :
    (etaC (2 * T) τ ^ 2 *
      w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
        (2 * T) τ) *
      ((n : ℝ) * (δ - τ / ε ^ 2) -
        (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
          (2 * gam (2 * T) τ)) ≤ wynerGen ν := by
  have hd : 1 ≤ 2 * T := by omega
  exact wyner_converse_from_approximation_hardness
    ν hν0 hν1
    (acceptanceProbability c accept)
    (circuit_acceptance_bounded hc accept)
    (2 * T) hd (circuit_acceptance_degree c accept)
    τ hτ hτ1 ε hε n hn δ hhard

end Nightfall.QuantumInformationBarrier

#print axioms Nightfall.QuantumInformationBarrier.normalized_circuit_wyner_simulation
#print axioms Nightfall.QuantumInformationBarrier.normalized_circuit_wyner_necessity
#print Nightfall.QuantumInformationBarrier.normalized_circuit_wyner_simulation
#print Nightfall.QuantumInformationBarrier.normalized_circuit_wyner_necessity
