import QuantumResponseOracleBridge
import QuantumCircuitSimulation
import Route1WynerGeneral

/-!
# NIGHTFALL — complete native coherent response-query program → Route 1/Wyner

This source constructs recursive physical query programs whose EVERY input-dependent
gate is the standard address-controlled finite-group translation
  |i,y,w⟩ ↦ |i,y+x_i,w⟩.
The only supplied physical premises are normalization of the initial state and
unitarity of fixed input-independent gates; neither oracle unitarity, acceptance
bounds, nor interaction-degree bounds are hypotheses of the final theorem.

Each classical DTree query is an original address i, returning the actual symbol
x_i. The theorem concerns a single scalar Boolean-basis acceptance probability
under a finite (possibly correlated) input source. Offline classical computation
is unrestricted. Coherent hardware availability, arbitrary POVMs, full state
simulation, and heterogeneous oracles are NOT established.
-/

namespace Nightfall.QuantumResponseRoute1Terminal

open Finset
open Nightfall.QuantumCircuitPaths
open Nightfall.QuantumCircuitNormalization
open Nightfall.QuantumResponseOracleBridge
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.QuantumCircuitSimulation
open Nightfall.Route1Polylog

variable {I G W : Type}
  [Fintype I] [DecidableEq I]
  [Fintype G] [DecidableEq G] [AddCommGroup G]
  [Fintype W] [DecidableEq W]

/-- Physical syntax: the only input-dependent operation is the standard
single-symbol reversible response oracle, with address and workspace retained. -/
inductive NativeProgram (I G W : Type) : ℕ → Type where
  | start (ψ : State I G W → ℂ) : NativeProgram I G W 0
  | step {T : ℕ} (U : State I G W → State I G W → ℂ)
      (prev : NativeProgram I G W T) : NativeProgram I G W (T + 1)

/-- The compilation expands one native response query to one source
matrix-oracle call. It does not change the query depth. -/
noncomputable def compileNative :
    {T : ℕ} → NativeProgram I G W T →
      Circuit I G (State I G W) T
  | _, .start ψ => Circuit.start ψ
  | _, .step U prev => Circuit.step U responseCoefficient (compileNative prev)

/-- Physical gate obligations, no separate hypothesis about oracle unitarity. -/
inductive NativeValid : {T : ℕ} → NativeProgram I G W T → Prop where
  | start (ψ : State I G W → ℂ) (hψ : energy ψ = 1) :
      NativeValid (NativeProgram.start ψ)
  | step {T : ℕ} (U : State I G W → State I G W → ℂ)
      (prev : NativeProgram I G W T)
      (hprev : NativeValid prev) (hU : IsUnitary U) :
      NativeValid (NativeProgram.step U prev)

/-- Every valid native physical program is source-WellFormed.
The oracle-unitarity hypothesis is PROVED from the translation-permutation
identity, not assumed here. -/
theorem compileNative_wellFormed :
    ∀ {T : ℕ} {p : NativeProgram I G W T}, NativeValid p →
      WellFormed (compileNative p) := by
  intro T p hp
  induction hp with
  | start ψ hψ =>
      exact WellFormed.start ψ hψ
  | @step T U prev hprev hU ih =>
      exact response_step_wellFormed T U (compileNative prev) ih hU

/-- Nonnegative normalized source-independent reference product marginal,
used ONLY to derive an indicator-degree bound. The actual distribution ν
in the terminal is arbitrary, and need not be a product law. -/
noncomputable def deltaReference (i : I) (a : G) : ℝ :=
  if a = 0 then 1 else 0

theorem deltaReference_sum : ∀ i : I, ∑ a : G, deltaReference i a = 1 := by
  intro i
  simp [deltaReference]

/-- A T-query native program has degree at most 2T for scalar Born acceptance.
No degree assumption appears in the source assumptions. -/
theorem native_acceptance_degree (T : ℕ)
    (p : NativeProgram I G W T) (accept : State I G W → Bool) :
    HasProdDegreeLE
      (acceptanceProbability (compileNative p) accept) (2 * T) := by
  exact acceptance_degree deltaReference deltaReference_sum T (compileNative p) accept

/-- Whole-symbol Wyner Route 1 terminal, now on genuinely native coherent
finite-group response query programs (rather than arbitrary source A matrices).

The DTree asks only ORIGINAL addresses i, not free hidden variables. Neither
its query depth nor the quantum query depth silently changes at compilation.
-/
theorem native_response_route1_wyner
    (ν : (I → G) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (p : NativeProgram I G W T) (hp : NativeValid p)
    (accept : State I G W → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree I G, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x *
        (if ε < |acceptanceProbability (compileNative p) accept x -
              t.eval x| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
          (2 * gam (2 * T) τ) +
        s / (etaC (2 * T) τ ^ 2 *
          w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
            (2 * T) τ)) / n + τ / ε ^ 2 := by
  classical
  have hc : WellFormed (compileNative p) := compileNative_wellFormed hp
  have hb : ∀ x,
      0 ≤ acceptanceProbability (compileNative p) accept x ∧
      acceptanceProbability (compileNative p) accept x ≤ 1 := by
    intro x
    simpa only [Nightfall.QuantumCircuitNormalization.probability,
      Nightfall.ProductSpace.QuantumCircuitSimulation.acceptanceProbability] using
      probability_in_unit_interval hc accept x
  have hd : 1 ≤ 2 * T := by omega
  have hdeg : HasProdDegreeLE
      (acceptanceProbability (compileNative p) accept) (2 * T) :=
    native_acceptance_degree T p accept
  exact route1_wyner_general ν hν0 hν1
    (acceptanceProbability (compileNative p) accept) hb
    (2 * T) hd hdeg τ hτ hτ1 ε hε n hn s hs

#print axioms Nightfall.QuantumResponseRoute1Terminal.compileNative_wellFormed
#print axioms Nightfall.QuantumResponseRoute1Terminal.deltaReference_sum
#print axioms Nightfall.QuantumResponseRoute1Terminal.native_acceptance_degree
#print axioms Nightfall.QuantumResponseRoute1Terminal.native_response_route1_wyner
#print Nightfall.QuantumResponseRoute1Terminal.native_response_route1_wyner

end Nightfall.QuantumResponseRoute1Terminal
