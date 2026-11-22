import PhaseBlockActualCircuit
import QuantumCircuitNormalization
import Route1WynerGeneral

/-!
# Physically well-formed phase-block quantum circuit → actual raw query tree

This discharges the bounded Born-probability premise from the existing
source-connected PhaseBlockActualCircuit terminal, using the pre-existing
kernel-checked normalization theorem for finite unitary circuits.

Scope: a finite 26-valued, 4-fixed-sensor, 8-sign-class oracle, one
address-local encoded symbol per quantum query, independent block law.
The resulting simulator is distributional for *scalar acceptance*
and charges exactly three physical source readings per block tree query.

No arbitrary nonlocal oracle, quantum state simulator, polynomial runtime
or global novelty claim follows. The upstream source-connected terminal
must independently pass its pinned kernel/source audit.
-/

namespace Nightfall.PhaseBlockWellFormed

open Finset
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.QuantumCircuitSimulation
open Nightfall.PhaseBlockTreeCompiler
open Nightfall.PhaseBlockRoute1Terminal
open Nightfall.PhaseBlockActualCircuit
open Nightfall.Route1Polylog

variable {B κ : Type*} [Fintype B] [DecidableEq B] [Fintype κ]

/-- For physically norm-preserving fixed and oracle gates, the scalar
acceptance bound on *all actual phase-block inputs* is a theorem rather
than an externally assumed hypothesis. -/
theorem wellFormed_born_on_phase_code {T : ℕ}
    (c : Nightfall.QuantumCircuitPaths.Circuit (B × Fin 4) (Fin 26) κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool) :
    ∀ x : B → Fin 8,
      0 ≤ acceptanceProbability c accept (rawTable x) ∧
      acceptanceProbability c accept (rawTable x) ≤ 1 := by
  intro x
  simpa only
    [Nightfall.QuantumCircuitNormalization.probability,
     Nightfall.ProductSpace.QuantumCircuitSimulation.acceptanceProbability]
    using (Nightfall.QuantumCircuitNormalization.probability_in_unit_interval
      hc accept (rawTable x))

/-- Source-connected theorem for a well-formed finite quantum circuit.
The 3*n bound counts actual original intensity-sensor oracle queries,
not free hidden-block symbol accesses. The error is distributional for
the independent hidden-block product law. -/
theorem normalized_phase_block_route1_simulation
    (T : ℕ) (hT : 0 < T)
    (c : Nightfall.QuantumCircuitPaths.Circuit (B × Fin 4) (Fin 26) κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (p : B → Fin 8 → ℝ)
    (hp0 : ∀ b a, 0 ≤ p b a)
    (hp1 : ∀ b, ∑ a, p b a = 1)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ rawtree : DTree (B × Fin 4) (Fin 26),
      (∀ x : B → Fin 8, rawtree.queries (rawTable x) ≤ 3 * n) ∧
      Ex (singleProduct p) singleWeight
          (fun x => if ε <
                  |acceptanceProbability c accept (rawTable x) -
                    rawtree.eval (rawTable x)| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
        (2 * gam (2 * T) τ) +
        Real.log (Fintype.card Unit) /
          (etaC (2 * T) τ ^ 2 *
            w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
              (2 * T) τ)) / n + τ / ε ^ 2 := by
  exact actual_circuit_route1_simulation
    T hT c accept p hp0 hp1
    (wellFormed_born_on_phase_code c hc accept)
    τ hτ hτ1 ε hε n hn

#print axioms Nightfall.PhaseBlockWellFormed.wellFormed_born_on_phase_code
#print axioms Nightfall.PhaseBlockWellFormed.normalized_phase_block_route1_simulation
#print Nightfall.PhaseBlockWellFormed.normalized_phase_block_route1_simulation

/-- General-Wyner strengthening: hidden phase blocks may be correlated.
The source-encoded quantum circuit and physical 3-row decoder stay unchanged;
the existing Wyner Route 1 theorem charges any s above C_W of the DECODED
block distribution. This is source-exact and requires NO product-law premise.
It is not an algorithmic guarantee independent of B unless s is bounded. -/
theorem normalized_wyner_phase_block_route1_simulation
    (T : ℕ) (hT : 0 < T)
    (c : Nightfall.QuantumCircuitPaths.Circuit (B × Fin 4) (Fin 26) κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (ν : (B → Fin 8) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x)
    (hν1 : ∑ x, ν x = 1)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ rawtree : DTree (B × Fin 4) (Fin 26),
      (∀ x : B → Fin 8, rawtree.queries (rawTable x) ≤ 3 * n) ∧
      ∑ x, ν x *
        (if ε <
           |acceptanceProbability c accept (rawTable x) -
            rawtree.eval (rawTable x)| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
        (2 * gam (2 * T) τ) +
        s / (etaC (2 * T) τ ^ 2 *
          w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
            (2 * T) τ)) / n + τ / ε ^ 2 := by
  classical
  let f : (B → Fin 8) → ℝ :=
    fun x => acceptanceProbability c accept (rawTable x)
  have hd : 1 ≤ 2 * T := by omega
  have hdeg : HasProdDegreeLE f (2 * T) :=
    actual_circuit_block_degree T c accept
  have hBorn : ∀ x, 0 ≤ f x ∧ f x ≤ 1 :=
    wellFormed_born_on_phase_code c hc accept
  obtain ⟨t, hqueries, herror⟩ :=
    route1_wyner_general ν hν0 hν1
      f hBorn (2 * T) hd hdeg
      τ hτ hτ1 ε hε n hn s hs
  refine ⟨compileTree t, ?_, ?_⟩
  · intro x
    rw [compileTree_queries]
    exact Nat.mul_le_mul_left 3 (hqueries x)
  · simpa only [f, compileTree_eval] using herror

#print axioms Nightfall.PhaseBlockWellFormed.normalized_wyner_phase_block_route1_simulation
#print Nightfall.PhaseBlockWellFormed.normalized_wyner_phase_block_route1_simulation

end Nightfall.PhaseBlockWellFormed
