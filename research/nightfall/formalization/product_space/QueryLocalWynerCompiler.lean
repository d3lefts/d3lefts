import ProductSimulation

/-!
# NIGHTFALL — deterministic query-local decoder compiler

A latent coordinate read may be an adaptive observed-coordinate decision tree.
The compiler replaces each latent query with that decoder, charging each
observed query. Crucially, for every observed word (including off-image words),
the decoded latent values are a SINGLE CONSISTENT virtual word. Thus a
source-certified per-input depth bound is preserved for all observed inputs;
there is no assumption that an off-image history is physically possible.
This theorem is purely operational. Wyner information and degree transfer
are separate, explicit dependencies.
-/

namespace Nightfall.QueryLocalWyner

open Nightfall.ProductSpace.Simulation

inductive RecoveryTree (I A : Type) where
  | leaf (value : A)
  | node (i : I) (next : A → RecoveryTree I A)

namespace RecoveryTree

def eval {I A : Type} : RecoveryTree I A → (I → A) → A
  | .leaf v, _ => v
  | .node i next, x => eval (next (x i)) x

def queries {I A : Type} : RecoveryTree I A → (I → A) → ℕ
  | .leaf _, _ => 0
  | .node i next, x => queries (next (x i)) x + 1

end RecoveryTree

variable {I J A : Type}

def decodedWord (recover : J → RecoveryTree I A) (x : I → A) : J → A :=
  fun j => (recover j).eval x

def graft (t : RecoveryTree I A) (k : A → DTree I A) : DTree I A :=
  match t with
  | .leaf a => k a
  | .node i next => .node i (fun v => graft (next v) k)

theorem graft_eval (t : RecoveryTree I A) (k : A → DTree I A)
    (x : I → A) :
    (graft t k).eval x = (k (t.eval x)).eval x := by
  induction t with
  | leaf a =>
      rfl
  | node i next ih =>
      simpa [graft, RecoveryTree.eval, DTree.eval] using ih (x i)

theorem graft_queries (t : RecoveryTree I A) (k : A → DTree I A)
    (x : I → A) :
    (graft t k).queries x =
      t.queries x + (k (t.eval x)).queries x := by
  induction t with
  | leaf a =>
      rfl
  | node i next ih =>
      change (graft (next (x i)) k).queries x + 1 =
        ((next (x i)).queries x + 1) +
          (k ((next (x i)).eval x)).queries x
      rw [ih (x i)]
      omega

def compile (recover : J → RecoveryTree I A) : DTree J A → DTree I A
  | .leaf v bad => .leaf v bad
  | .node j next => graft (recover j) (fun a => compile recover (next a))

/-- Exact semantics for EVERY observed word, including off-image inputs. -/
theorem compile_eval (recover : J → RecoveryTree I A)
    (t : DTree J A) (x : I → A) :
    (compile recover t).eval x = t.eval (decodedWord recover x) := by
  induction t with
  | leaf v bad =>
      rfl
  | node j next ih =>
      change (graft (recover j) (fun a => compile recover (next a))).eval x =
        (next ((recover j).eval x)).eval (decodedWord recover x)
      rw [graft_eval]
      exact ih ((recover j).eval x)

/-- Strong pointwise query bound: the simulated path always corresponds to
one globally consistent virtual latent word, even when x is off-image. -/
theorem compile_queries_le (recover : J → RecoveryTree I A)
    (r : ℕ) (hr : ∀ j x, (recover j).queries x ≤ r)
    (t : DTree J A) (x : I → A) :
    (compile recover t).queries x ≤
      r * t.queries (decodedWord recover x) := by
  induction t with
  | leaf v bad =>
      simp [compile, DTree.queries]
  | node j next ih =>
      calc
        (compile recover (.node j next)).queries x =
          (recover j).queries x +
            (compile recover (next ((recover j).eval x))).queries x := by
              exact graft_queries (recover j) (fun a => compile recover (next a)) x
        _ ≤ r + r * (next ((recover j).eval x)).queries
              (decodedWord recover x) :=
                Nat.add_le_add (hr j x) (ih ((recover j).eval x))
        _ = r * (DTree.node j next).queries (decodedWord recover x) := by
              simp [DTree.queries, decodedWord, Nat.mul_add, Nat.add_comm]

/-- Every source word is reproduced exactly when each latent coordinate
decoder recovers the corresponding coordinate on its encoded image. -/
theorem compile_correct_on_source
    (recover : J → RecoveryTree I A)
    (Φ : (J → A) → (I → A)) (t : DTree J A)
    (z : J → A)
    (hrec : ∀ j, (recover j).eval (Φ z) = z j) :
    (compile recover t).eval (Φ z) = t.eval z := by
  have hw : decodedWord recover (Φ z) = z := funext hrec
  rw [compile_eval, hw]

/-- An everywhere observed depth bound follows from the *pointwise* depth
bound of the latent DTree, without assuming any decoding law off the image. -/
theorem compile_global_depth
    (recover : J → RecoveryTree I A)
    (r q : ℕ)
    (hr : ∀ j x, (recover j).queries x ≤ r)
    (t : DTree J A)
    (ht : ∀ z, t.queries z ≤ q) :
    ∀ x, (compile recover t).queries x ≤ r * q := by
  intro x
  exact (compile_queries_le recover r hr t x).trans
    (Nat.mul_le_mul_left r (ht (decodedWord recover x)))

end Nightfall.QueryLocalWyner

#print axioms Nightfall.QueryLocalWyner.graft_eval
#print axioms Nightfall.QueryLocalWyner.graft_queries
#print axioms Nightfall.QueryLocalWyner.compile_eval
#print axioms Nightfall.QueryLocalWyner.compile_queries_le
#print axioms Nightfall.QueryLocalWyner.compile_correct_on_source
#print axioms Nightfall.QueryLocalWyner.compile_global_depth
