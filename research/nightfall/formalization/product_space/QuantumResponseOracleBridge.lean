import QuantumCircuitNormalization

/-!
# NIGHTFALL — native coherent response oracle as one source matrix query

For a finite address set I, finite additive response group G, and finite
workspace W, the physical reversible query
  |i,y,w> -> |i,y+x_i,w>
is exactly one QuantumCircuitPaths.Circuit.step oracle.  This file proves
the matrix identity for *every* input and all basis states, then proves
unitarity and well-formed step preservation using the same source definitions.

This is an ideal coherent query oracle, NOT a destructive physical sensor.
The source still models basis-projective final acceptance; arbitrary POVMs
require a separately justified dilation. No runtime or novelty claim.
-/

namespace Nightfall.QuantumResponseOracleBridge

open Finset
open Nightfall.QuantumCircuitPaths
open Nightfall.QuantumCircuitNormalization

abbrev State (I G W : Type) := I × (G × W)

variable {I G W : Type}
  [Fintype I] [DecidableEq I]
  [Fintype G] [DecidableEq G] [AddCommGroup G]
  [Fintype W] [DecidableEq W]

/-- One native translation on the response register, leaving address and
workspace untouched. Its inverse subtracts the same hidden symbol. -/
def responseShift (x : I → G) : State I G W ≃ State I G W where
  toFun := fun v => (v.1, (v.2.1 + x v.1, v.2.2))
  invFun := fun v => (v.1, (v.2.1 - x v.1, v.2.2))
  left_inv := by
    rintro ⟨i, ⟨z, w⟩⟩
    simp
  right_inv := by
    rintro ⟨i, ⟨z, w⟩⟩
    simp

/-- The coefficient of the source symbol (i,a) is the address-controlled
translation by a. Symbols of value zero are included. -/
noncomputable def responseCoefficient (s : I × G)
    (b v : State I G W) : ℂ :=
  if s.1 = v.1 then
    if b = (v.1, (v.2.1 + s.2, v.2.2)) then 1 else 0
  else 0

/-- Standard coherent controlled-response permutation matrix. -/
noncomputable def standardResponseMatrix (x : I → G)
    (b v : State I G W) : ℂ :=
  if b = responseShift x v then 1 else 0

private theorem symbol_sum_select (x : I → G) (F : I × G → ℂ) :
    (∑ s : I × G, symbol s x * F s) = ∑ i : I, F (i, x i) := by
  classical
  simp [Fintype.sum_prod_type, symbol]

/-- Exact one-query embedding. No query, normalization, or degree predicate
is assumed to establish this operator equality. -/
theorem oracleMat_response_eq_translation (x : I → G) :
    oracleMat (responseCoefficient (I := I) (G := G) (W := W)) x =
      standardResponseMatrix (I := I) (G := G) (W := W) x := by
  classical
  funext b v
  change (∑ s : I × G, symbol s x *
      responseCoefficient (I := I) (G := G) (W := W) s b v) =
      standardResponseMatrix (I := I) (G := G) (W := W) x b v
  rw [symbol_sum_select]
  simp [responseCoefficient, standardResponseMatrix, responseShift]

/-- A finite basis permutation matrix preserves the exact complex energy. -/
private theorem permutation_isUnitary {S : Type}
    [Fintype S] [DecidableEq S] (e : S ≃ S) :
    IsUnitary (fun b v : S => if b = e v then (1 : ℂ) else 0) := by
  classical
  intro ψ
  have happly :
      applyMat (fun b v : S => if b = e v then (1 : ℂ) else 0) ψ =
        (fun b => ψ (e.symm b)) := by
    funext b
    have hiff (v : S) : (b = e v) ↔ (v = e.symm b) := by
      constructor
      · intro h
        have he := congrArg e.symm h
        simpa using he.symm
      · intro h
        rw [h, e.apply_symm_apply]
    simp [applyMat, hiff]
  rw [happly]
  unfold energy
  apply Fintype.sum_equiv e.symm
    (fun b : S => ((ψ (e.symm b)).re ^ 2 + (ψ (e.symm b)).im ^ 2))
    (fun v : S => ((ψ v).re ^ 2 + (ψ v).im ^ 2))
  intro b
  rfl

/-- Native controlled addition is unitary, including zero symbols and
arbitrary finite workspace. The caller does not assume oracle unitarity. -/
theorem responseOracle_isUnitary (x : I → G) :
    IsUnitary (oracleMat (responseCoefficient (I := I) (G := G) (W := W)) x) := by
  rw [oracleMat_response_eq_translation]
  exact permutation_isUnitary (responseShift (W := W) x)

/-- An actual response query takes exactly one source Circuit.step. -/
theorem execute_response_step (T : ℕ)
    (U : State I G W → State I G W → ℂ)
    (prev : Circuit I G (State I G W) T) (x : I → G) :
    execute (Circuit.step U responseCoefficient prev) x =
      applyMat U (applyMat (standardResponseMatrix (W := W) x)
        (execute prev x)) := by
  simpa only [oracleMat_response_eq_translation] using
    execute_step_eq T U responseCoefficient prev x

/-- Physical assumptions discharged for the new step: normalized prior
state and fixed unitary imply a WellFormed extension with one response query. -/
theorem response_step_wellFormed (T : ℕ)
    (U : State I G W → State I G W → ℂ)
    (prev : Circuit I G (State I G W) T)
    (hprev : WellFormed prev) (hU : IsUnitary U) :
    WellFormed (Circuit.step U responseCoefficient prev) := by
  exact WellFormed.step U responseCoefficient hprev hU
    (fun x => responseOracle_isUnitary (W := W) x)

#print axioms Nightfall.QuantumResponseOracleBridge.oracleMat_response_eq_translation
#print axioms Nightfall.QuantumResponseOracleBridge.responseOracle_isUnitary
#print axioms Nightfall.QuantumResponseOracleBridge.execute_response_step
#print axioms Nightfall.QuantumResponseOracleBridge.response_step_wellFormed

end Nightfall.QuantumResponseOracleBridge
