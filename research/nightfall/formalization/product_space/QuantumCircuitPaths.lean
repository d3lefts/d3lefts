import Mathlib

/-!
# NIGHTFALL — circuit-to-query-path normal form

This source formalizes the *semantic* step left open by QuantumPathDegree:
arbitrary fixed finite-dimensional complex linear gates interleaved with oracle
calls whose matrix entries are sums of one-coordinate symbol indicators.

The statement is intentionally more general than unitary gates. Any standard
finite-dimensional index-controlled quantum query oracle is of this form.
The proof does not assume a low-degree polynomial representation.
-/

namespace Nightfall.QuantumCircuitPaths

open Finset

variable {ι α κ : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Fintype κ]

abbrev Trace (n : ℕ) (ι α : Type) := Fin n → ι × α

/-- One coordinate/symbol test as a complex scalar. -/
noncomputable def symbol (s : ι × α) (x : ι → α) : ℂ :=
  if x s.1 = s.2 then 1 else 0

/-- Product of all tests on a query path (inconsistent proposals yield zero). -/
noncomputable def traceWeight {n : ℕ} (σ : Trace n ι α) (x : ι → α) : ℂ :=
  ∏ j : Fin n, symbol (σ j) x

/-- Finite-dimensional linear query programs; physically valid unitary programs
form a subclass, but unitarity is unnecessary for the polynomial-degree bound. -/
inductive Circuit (ι α κ : Type) : ℕ → Type where
  | start (ψ : κ → ℂ) : Circuit ι α κ 0
  | step {n : ℕ} (U : κ → κ → ℂ)
      (A : (ι × α) → κ → κ → ℂ)
      (previous : Circuit ι α κ n) : Circuit ι α κ (n + 1)

/-- Actual matrix-entry semantics: one oracle call is linear in symbol tests. -/
noncomputable def execute : {n : ℕ} → Circuit ι α κ n → (ι → α) → κ → ℂ
  | _, .start ψ, _, k => ψ k
  | _, .step U A prev, x, k =>
      ∑ b : κ, ∑ v : κ, U k b *
        (∑ s : ι × α, symbol s x * A s b v) * execute prev x v

/-- Circuit compiler: path coefficients depend on the gates, not on the input. -/
noncomputable def pathCoeff :
    {n : ℕ} → Circuit ι α κ n → Trace n ι α → κ → ℂ
  | _, .start ψ, _, k => ψ k
  | _, .step U A prev, σ, k =>
      ∑ b : κ, ∑ v : κ,
        U k b * A (σ 0) b v * pathCoeff prev (fun j => σ j.succ) v

theorem traceWeight_cons (n : ℕ) (s : ι × α)
    (σ : Trace n ι α) (x : ι → α) :
    traceWeight (Fin.cons s σ) x = symbol s x * traceWeight σ x := by
  simp [traceWeight, Fin.prod_univ_succ, Fin.cons_zero, Fin.cons_succ]

/-- Reindexing trace sums by the first query response and the remaining path. -/
theorem trace_sum_succ (n : ℕ) (F : Trace (n + 1) ι α → ℂ) :
    (∑ σ : Trace (n + 1) ι α, F σ) =
      ∑ s : ι × α, ∑ τ : Trace n ι α, F (Fin.cons s τ) := by
  let e : ((ι × α) × Trace n ι α) ≃ Trace (n + 1) ι α :=
    Fin.consEquiv (fun _ : Fin (n + 1) => ι × α)
  calc
    (∑ σ : Trace (n + 1) ι α, F σ) =
      ∑ p : (ι × α) × Trace n ι α, F (e p) := by
        apply Fintype.sum_equiv e.symm
          (fun σ => F σ)
          (fun p => F (e p))
        intro σ
        simp
    _ = ∑ s : ι × α, ∑ τ : Trace n ι α, F (Fin.cons s τ) := by
        simp [e, Fintype.sum_prod_type, Fin.consEquiv_apply]

/-- Pure Fubini exchange for the four finite sums appearing in one query. -/
private theorem reorder_four (n : ℕ)
    (F : κ → κ → (ι × α) → Trace n ι α → ℂ) :
    (∑ b : κ, ∑ v : κ, ∑ s : ι × α, ∑ τ : Trace n ι α,
       F b v s τ) =
    (∑ s : ι × α, ∑ τ : Trace n ι α, ∑ b : κ, ∑ v : κ,
       F b v s τ) := by
  calc
    _ = ∑ b : κ, ∑ s : ι × α, ∑ v : κ, ∑ τ : Trace n ι α,
         F b v s τ := by
          apply Finset.sum_congr rfl
          intro b _
          exact Finset.sum_comm
    _ = ∑ s : ι × α, ∑ b : κ, ∑ v : κ, ∑ τ : Trace n ι α,
         F b v s τ := Finset.sum_comm
    _ = ∑ s : ι × α, ∑ b : κ, ∑ τ : Trace n ι α, ∑ v : κ,
         F b v s τ := by
          apply Finset.sum_congr rfl
          intro s _
          apply Finset.sum_congr rfl
          intro b _
          exact Finset.sum_comm
    _ = ∑ s : ι × α, ∑ τ : Trace n ι α, ∑ b : κ, ∑ v : κ,
         F b v s τ := by
          apply Finset.sum_congr rfl
          intro s _
          exact Finset.sum_comm

/-- The substantial bridge: every finite matrix-oracle circuit evaluates
exactly to its input-independent query path coefficient expansion. -/
theorem execute_eq_path_sum : ∀ {n : ℕ}
    (c : Circuit ι α κ n) (x : ι → α) (k : κ),
    execute c x k =
      ∑ σ : Trace n ι α, pathCoeff c σ k * traceWeight σ x := by
  intro n c
  induction c with
  | start ψ =>
      intro x k
      simp [execute, pathCoeff, traceWeight]
  | @step n U A prev ih =>
      intro x k
      let F : κ → κ → (ι × α) → Trace n ι α → ℂ :=
        fun b v s τ =>
          (U k b * A s b v * pathCoeff prev τ v) *
            (symbol s x * traceWeight τ x)
      have hL :
          execute (Circuit.step U A prev) x k =
            ∑ b : κ, ∑ v : κ, ∑ s : ι × α, ∑ τ : Trace n ι α, F b v s τ := by
        change (∑ b : κ, ∑ v : κ, U k b *
            (∑ s : ι × α, symbol s x * A s b v) * execute prev x v) = _
        simp_rw [ih x]
        apply Finset.sum_congr rfl
        intro b _
        apply Finset.sum_congr rfl
        intro v _
        change U k b * (∑ s : ι × α, symbol s x * A s b v) *
            (∑ τ : Trace n ι α, pathCoeff prev τ v * traceWeight τ x) = _
        rw [Finset.mul_sum]
        rw [Finset.mul_sum]
        rw [Finset.sum_mul]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro s _
        apply Finset.sum_congr rfl
        intro τ _
        dsimp [F]
        ring
      have hR :
          (∑ σ : Trace (n + 1) ι α,
            pathCoeff (Circuit.step U A prev) σ k * traceWeight σ x) =
          ∑ s : ι × α, ∑ τ : Trace n ι α, ∑ b : κ, ∑ v : κ, F b v s τ := by
        rw [trace_sum_succ]
        apply Finset.sum_congr rfl
        intro s _
        apply Finset.sum_congr rfl
        intro τ _
        have hc :
            pathCoeff (Circuit.step U A prev) (Fin.cons s τ) k =
              ∑ b : κ, ∑ v : κ,
                U k b * A s b v * pathCoeff prev τ v := rfl
        rw [hc, traceWeight_cons]
        rw [Finset.sum_mul]
        apply Finset.sum_congr rfl
        intro b _
        rw [Finset.sum_mul]
      exact hL.trans ((reorder_four n F).trans hR.symm)

end Nightfall.QuantumCircuitPaths
