import QuantumCircuitSimulation
import Route1PolylogSimulation
import PhaseBlockGrouping
import PhaseBlockRoute1
import PhaseBlockTreeCompiler
import PhaseBlockRoute1Terminal

/-!
# Actual finite matrix-oracle circuit → decoded independent phase blocks
# → kernel-checked Route1 simulation → exact three-intensity-query DTree

Unlike a generic path-sum assumption, this source uses the repository's
genuine QuantumCircuitPaths.Circuit input semantics, whose symbol queries
address one original raw coordinate (block,sensor) and a 26-valued observed
intensity. It imports the already merged circuit path expansion and degree
certificate and the newly verified generic source grouping lemma.

The physical circuit's Born acceptance is assumed in [0,1] ONLY on actual
eight-state raw tables. The source's QuantumCircuitNormalization proves this
hypothesis for normalized unitary circuits; arbitrary nonunitary matrices
do not satisfy it automatically. This theorem returns an actual
ProductSpace.Simulation.DTree on the original sensor query addresses.

This is scalar acceptance estimation, not coherent oracle replacement or
quantum state simulation. Classical offline computation is unrestricted.
-/

namespace Nightfall.PhaseBlockActualCircuit

open Finset
open Nightfall.Route1LatentDegree
open Nightfall.PhaseBlockRoute1
open Nightfall.PhaseBlockTreeCompiler
open Nightfall.PhaseBlockGrouping
open Nightfall.PhaseBlockRoute1Terminal
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.QuantumCircuitSimulation

variable {B κ : Type*}
  [Fintype B] [DecidableEq B]
  [Fintype κ]

/-- Generic raw symbol law used only as an exact degree reconstruction
reference; it is NOT the physical correlated raw intensity distribution. -/
def auxRaw (i : B × Fin 4) (a : Fin 26) : ℝ := 1 / 26

theorem auxRaw_sum :
    ∀ i : B × Fin 4, ∑ a : Fin 26, auxRaw i a = 1 := by
  intro i
  simp [auxRaw] <;> norm_num

/-- Formal degree of a full raw-symbol quantum circuit's accepted Born
probability pulled back along the REAL squared-linear intensity table.
Uses the existing QuantumCircuitSimulation.acceptance_degree theorem,
then the new GROUPING theorem. No hypothetical degree premise. -/
theorem actual_circuit_block_degree (T : ℕ)
    (c : Nightfall.QuantumCircuitPaths.Circuit (B × Fin 4) (Fin 26) κ T)
    (accept : κ → Bool) :
    HasProdDegreeLE
      (fun x : B → Fin 8 =>
        acceptanceProbability c accept (rawTable x)) (2 * T) := by
  classical
  have hr :
      HasProdDegreeLE (acceptanceProbability c accept) (2 * T) :=
    acceptance_degree (auxRaw (B := B)) auxRaw_sum T c accept
  have hgroup :=
    grouped_degree (f := acceptanceProbability c accept)
      (d := 2 * T) hr
      (parent := fun i : B × Fin 4 => i.1)
      (φ := fun i s => rawReading s i.2)
  simpa only [groupedInput, rawTable] using hgroup

/-- **Entire source-connected conditional matrix-circuit terminal.**
The circuit is an actual recursive finite matrix-oracle program with
original sensor addresses. Its scalar acceptance, when restricted to
independent eight-state signal blocks, is approximated by an ACTUAL
deterministic DTree querying the raw sensor addresses, with query
count at most 3n and the pinned Route1 single-product error bound.

No unproved degree predicate, "quantum-path-exists", or
"decoder-preserves-output" hypothesis occurs in the theorem. -/
theorem actual_circuit_route1_simulation
    (T : ℕ) (hT : 0 < T)
    (c : Nightfall.QuantumCircuitPaths.Circuit (B × Fin 4) (Fin 26) κ T)
    (accept : κ → Bool)
    (p : B → Fin 8 → ℝ)
    (hp0 : ∀ b a, 0 ≤ p b a)
    (hp1 : ∀ b, ∑ a, p b a = 1)
    (hBorn : ∀ x : B → Fin 8,
      0 ≤ acceptanceProbability c accept (rawTable x) ∧
      acceptanceProbability c accept (rawTable x) ≤ 1)
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
  classical
  let f : (B → Fin 8) → ℝ :=
    fun x => acceptanceProbability c accept (rawTable x)
  have hd : 1 ≤ 2 * T := by omega
  have hdeg : HasProdDegreeLE f (2 * T) :=
    actual_circuit_block_degree T c accept
  have hP0 : ∀ θ b a, 0 ≤ singleProduct p θ b a := by
    intro θ b a
    exact hp0 b a
  have hP1 : ∀ θ b, ∑ a, singleProduct p θ b a = 1 := by
    intro θ b
    exact hp1 b
  obtain ⟨t, hq, he⟩ :=
    route1_polylog_simulation
      (singleProduct p) hP0 hP1
      singleWeight singleWeight_nonneg singleWeight_sum
      f hBorn (2 * T) hd hdeg τ hτ hτ1 ε hε n hn
  refine ⟨compileTree t, ?_, ?_⟩
  · intro x
    rw [compileTree_queries]
    exact Nat.mul_le_mul_left 3 (hq x)
  · simpa only [f, compileTree_eval] using he

#print axioms Nightfall.PhaseBlockActualCircuit.auxRaw_sum
#print axioms Nightfall.PhaseBlockActualCircuit.actual_circuit_block_degree
#print axioms Nightfall.PhaseBlockActualCircuit.actual_circuit_route1_simulation
#print Nightfall.PhaseBlockActualCircuit.actual_circuit_route1_simulation

end Nightfall.PhaseBlockActualCircuit
