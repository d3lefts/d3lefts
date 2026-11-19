import QuantumCircuitPaths

/-!
# NIGHTFALL — finite quantum circuit normalization

A physically valid quantum query circuit starts from a unit vector, then
applies norm-preserving fixed gates and norm-preserving symbol-controlled
oracle matrices. These are the finite-dimensional unitary-gate hypotheses,
expressed operationally as norm preservation on all input vectors.

The theorem proves that the executed quantum state has squared norm 1 for
every input, and every accepted subset of output basis vectors has probability
in [0,1]. It does *not* assume acceptance probabilities are bounded.
-/

namespace Nightfall.QuantumCircuitNormalization

open Finset
open Nightfall.QuantumCircuitPaths

variable {ι α κ : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Fintype κ]

/-- The squared Hermitian norm of a complex finite-dimensional state. -/
noncomputable def energy (ψ : κ → ℂ) : ℝ :=
  ∑ k : κ, ((ψ k).re ^ 2 + (ψ k).im ^ 2)

/-- Matrix multiplication on state vectors. -/
noncomputable def applyMat (U : κ → κ → ℂ) (ψ : κ → ℂ) : κ → ℂ :=
  fun k => ∑ v, U k v * ψ v

/-- Square complex matrices preserving the Hermitian norm of every vector.
For finite-dimensional complex square matrices, this is equivalent to unitarity. -/
def IsUnitary (U : κ → κ → ℂ) : Prop :=
  ∀ ψ : κ → ℂ, energy (applyMat U ψ) = energy ψ

/-- The input-controlled oracle matrix is a sum over symbol indicators. -/
noncomputable def oracleMat (A : (ι × α) → κ → κ → ℂ)
    (x : ι → α) : κ → κ → ℂ :=
  fun b v => ∑ s : ι × α, symbol s x * A s b v

/-- A finite circuit with a normalized starting state and unitary gates
for every input word, as in the standard quantum query model. -/
inductive WellFormed :
    {T : ℕ} → Circuit ι α κ T → Prop where
  | start (ψ : κ → ℂ) (hψ : energy ψ = 1) :
      WellFormed (Circuit.start ψ)
  | step {T : ℕ} (U : κ → κ → ℂ)
      (A : (ι × α) → κ → κ → ℂ)
      {prev : Circuit ι α κ T}
      (hprev : WellFormed prev)
      (hU : IsUnitary U)
      (hO : ∀ x : ι → α, IsUnitary (oracleMat A x)) :
      WellFormed (Circuit.step U A prev)

/-- A circuit step is composition of its actual oracle and fixed gate matrices. -/
theorem execute_step_eq (T : ℕ) (U : κ → κ → ℂ)
    (A : (ι × α) → κ → κ → ℂ)
    (prev : Circuit ι α κ T) (x : ι → α) :
    execute (Circuit.step U A prev) x =
      applyMat U (applyMat (oracleMat A x) (execute prev x)) := by
  funext k
  change (∑ b : κ, ∑ v : κ, U k b *
      (∑ s : ι × α, symbol s x * A s b v) * execute prev x v) =
    (∑ b : κ, U k b *
      (∑ v : κ, (∑ s : ι × α, symbol s x * A s b v) * execute prev x v))
  apply Finset.sum_congr rfl
  intro b _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro v _
  ring

/-- Input-by-input normalization follows from unitary gates and oracle matrices. -/
theorem execute_energy_one : ∀ {T : ℕ}
    {c : Circuit ι α κ T}, WellFormed c →
    ∀ x : ι → α, energy (execute c x) = 1 := by
  intro T c hc
  induction hc with
  | start ψ hψ =>
      intro x
      simpa only [execute] using hψ
  | @step T U A prev hprev hU hO ih =>
      intro x
      calc
        energy (execute (Circuit.step U A prev) x) =
            energy (applyMat U (applyMat (oracleMat A x) (execute prev x))) := by
              rw [execute_step_eq]
        _ = energy (applyMat (oracleMat A x) (execute prev x)) := hU _
        _ = energy (execute prev x) := hO x _
        _ = 1 := ih x

/-- Probability assigned to a chosen subset of measured basis outcomes. -/
noncomputable def probability {T : ℕ}
    (c : Circuit ι α κ T) (accept : κ → Bool) (x : ι → α) : ℝ :=
  ∑ k : κ, if accept k then
    ((execute c x k).re ^ 2 + (execute c x k).im ^ 2)
    else 0

/-- A normalized finite quantum circuit automatically has physical
Born acceptance probability in [0,1], with no boundedness assumption. -/
theorem probability_in_unit_interval {T : ℕ}
    {c : Circuit ι α κ T} (hc : WellFormed c)
    (accept : κ → Bool) (x : ι → α) :
    0 ≤ probability c accept x ∧ probability c accept x ≤ 1 := by
  have hnorm := execute_energy_one hc x
  constructor
  · unfold probability
    apply Finset.sum_nonneg
    intro k _
    split_ifs <;> positivity
  · unfold probability
    rw [← hnorm]
    unfold energy
    apply Finset.sum_le_sum
    intro k _
    split_ifs
    · exact le_refl _
    · positivity

end Nightfall.QuantumCircuitNormalization
