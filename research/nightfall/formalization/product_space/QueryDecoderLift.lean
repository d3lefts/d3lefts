import ProductSimulation

/-!
# NIGHTFALL — bounded-cost substitution of latent decision-tree queries

A DecoderTree reads observed symbols and returns a latent symbol. A family of
decoders with observed query cost ≤r allows replacing every query in a latent
DTree with at most r observed queries. A depth-cap is applied to guard
unreachable observed inputs; correctness on encoded source inputs is preserved.

This file does not assume a probability distribution, product independence, or
bounded degree. The construction is exact and fully extensional.
-/

namespace Nightfall.ProductSpace.QueryDecoderLift

open Nightfall.ProductSpace
open Nightfall.ProductSpace.Simulation

variable {I J α β : Type}

/-- An observed-symbol decision tree producing a latent symbol. -/
inductive DecoderTree (I α β : Type) where
  | leaf (value : β)
  | node (i : I) (branch : α → DecoderTree I α β)

namespace DecoderTree

def eval : DecoderTree I α β → (I → α) → β
  | .leaf v, _ => v
  | .node i t, x => eval (t (x i)) x

def queries : DecoderTree I α β → (I → α) → ℕ
  | .leaf _, _ => 0
  | .node i t, x => queries (t (x i)) x + 1

/-- Substitute every decoder output into a continuation tree. -/
def bind : DecoderTree I α β → (β → DTree I α) → DTree I α
  | .leaf b, k => k b
  | .node i t, k => .node i (fun a => bind (t a) k)

/-- The interpreter of a substituted tree agrees with sequential decoding. -/
theorem bind_eval (u : DecoderTree I α β)
    (k : β → DTree I α) (x : I → α) :
    (bind u k).eval x = (k (u.eval x)).eval x := by
  induction u with
  | leaf b => rfl
  | node i t ih =>
      change (bind (t (x i)) k).eval x =
        (k ((t (x i)).eval x)).eval x
      exact ih (x i)

/-- Exact additive path cost of decoder substitution. -/
theorem bind_queries (u : DecoderTree I α β)
    (k : β → DTree I α) (x : I → α) :
    (bind u k).queries x =
      u.queries x + (k (u.eval x)).queries x := by
  induction u with
  | leaf b => simp [bind, DecoderTree.queries, DecoderTree.eval]
  | node i t ih =>
      change (bind (t (x i)) k).queries x + 1 =
        ((t (x i)).queries x + 1) + (k ((t (x i)).eval x)).queries x
      rw [ih (x i)]
      omega

end DecoderTree

/-- Replacing each latent coordinate query by its observed decoder. -/
noncomputable def lift (dec : J → DecoderTree I α β) :
    DTree J β → DTree I α
  | .leaf v bad => .leaf v bad
  | .node j children => DecoderTree.bind (dec j)
      (fun b => lift dec (children b))

/-- On encoded inputs, lifted-tree output exactly matches the latent tree. -/
theorem lift_eval (dec : J → DecoderTree I α β)
    (Phi : (J → β) → (I → α))
    (hdec : ∀ j z, (dec j).eval (Phi z) = z j) :
    ∀ (t : DTree J β) (z : J → β),
      (lift dec t).eval (Phi z) = t.eval z := by
  intro t
  induction t with
  | leaf v bad =>
      intro z
      rfl
  | node j children ih =>
      intro z
      change (DecoderTree.bind (dec j)
        (fun b => lift dec (children b))).eval (Phi z) =
        (children (z j)).eval z
      rw [DecoderTree.bind_eval, hdec j z]
      exact ih (z j) z

/-- On encoded inputs, each latent query costs at most r observed queries. -/
theorem lift_queries_le (dec : J → DecoderTree I α β)
    (Phi : (J → β) → (I → α))
    (hdec : ∀ j z, (dec j).eval (Phi z) = z j)
    (r : ℕ) (hcost : ∀ j x, (dec j).queries x ≤ r) :
    ∀ (t : DTree J β) (z : J → β),
      (lift dec t).queries (Phi z) ≤ r * t.queries z := by
  intro t
  induction t with
  | leaf v bad =>
      intro z
      simp [lift, DTree.queries]
  | node j children ih =>
      intro z
      change (DecoderTree.bind (dec j)
        (fun b => lift dec (children b))).queries (Phi z) ≤
        r * ((children (z j)).queries z + 1)
      rw [DecoderTree.bind_queries, hdec j z]
      have h1 := hcost j (Phi z)
      have h2 := ih (z j) z
      rw [Nat.mul_succ]
      omega

/-- Prune every observed path at a fixed global query budget. -/
def truncate : ℕ → DTree I α → DTree I α
  | 0, .leaf v bad => .leaf v bad
  | 0, .node _ _ => .leaf 0 true
  | _ + 1, .leaf v bad => .leaf v bad
  | n + 1, .node i children => .node i (fun a => truncate n (children a))

theorem truncate_queries (n : ℕ) (t : DTree I α) (x : I → α) :
    (truncate n t).queries x ≤ n := by
  induction n generalizing t with
  | zero =>
      cases t <;> simp [truncate, DTree.queries]
  | succ n ih =>
      cases t with
      | leaf v b => simp [truncate, DTree.queries]
      | node i children =>
          change (truncate n (children (x i))).queries x + 1 ≤ n + 1
          exact Nat.succ_le_succ (ih (children (x i)))

/-- Truncation preserves output on paths already within the budget. -/
theorem truncate_eval (n : ℕ) (t : DTree I α) (x : I → α)
    (h : t.queries x ≤ n) :
    (truncate n t).eval x = t.eval x := by
  induction n generalizing t with
  | zero =>
      cases t with
      | leaf v b => rfl
      | node i children =>
          simp only [DTree.queries] at h
          omega
  | succ n ih =>
      cases t with
      | leaf v b => rfl
      | node i children =>
          have hc : (children (x i)).queries x ≤ n := by
            simpa only [DTree.queries] using Nat.le_of_succ_le_succ h
          change (truncate n (children (x i))).eval x = (children (x i)).eval x
          exact ih (children (x i)) hc

/-- Bounded-cost observed query tree. Truncation makes the bound hold on ALL
observed inputs, including those outside the encoded source support. -/
noncomputable def substitute (dec : J → DecoderTree I α β)
    (r n : ℕ) (t : DTree J β) : DTree I α :=
  truncate (r * n) (lift dec t)

/-- Every observed path has bounded depth, even outside the encoding image. -/
theorem substitute_queries (dec : J → DecoderTree I α β)
    (r n : ℕ) (t : DTree J β) (x : I → α) :
    (substitute dec r n t).queries x ≤ r * n :=
  truncate_queries (r * n) (lift dec t) x

/-- On the source, bounded-cost substitution has EXACT acceptance output. -/
theorem substitute_eval (dec : J → DecoderTree I α β)
    (Phi : (J → β) → (I → α))
    (hdec : ∀ j z, (dec j).eval (Phi z) = z j)
    (r : ℕ) (hcost : ∀ j x, (dec j).queries x ≤ r)
    (n : ℕ) (t : DTree J β)
    (hdepth : ∀ z, t.queries z ≤ n) (z : J → β) :
    (substitute dec r n t).eval (Phi z) = t.eval z := by
  unfold substitute
  rw [truncate_eval (r * n) (lift dec t) (Phi z)
    ((lift_queries_le dec Phi hdec r hcost t z).trans
      (Nat.mul_le_mul_left r (hdepth z)))]
  exact lift_eval dec Phi hdec t z


/-- Pointwise variant: recovery correctness is needed only at this latent
input, allowing decoder specifications that hold merely on source support. -/
theorem lift_eval_at (dec : J → DecoderTree I α β)
    (Phi : (J → β) → (I → α)) (z : J → β)
    (hdec_z : ∀ j, (dec j).eval (Phi z) = z j) :
    ∀ t : DTree J β, (lift dec t).eval (Phi z) = t.eval z := by
  intro t
  induction t with
  | leaf v bad => rfl
  | node j children ih =>
      change (DecoderTree.bind (dec j)
        (fun b => lift dec (children b))).eval (Phi z) =
        (children (z j)).eval z
      rw [DecoderTree.bind_eval, hdec_z j]
      exact ih (z j)

/-- Pointwise path-cost control requires recovery only at this latent input. -/
theorem lift_queries_le_at (dec : J → DecoderTree I α β)
    (Phi : (J → β) → (I → α)) (z : J → β)
    (hdec_z : ∀ j, (dec j).eval (Phi z) = z j)
    (r : ℕ) (hcost : ∀ j x, (dec j).queries x ≤ r) :
    ∀ t : DTree J β,
      (lift dec t).queries (Phi z) ≤ r * t.queries z := by
  intro t
  induction t with
  | leaf v bad => simp [lift, DTree.queries]
  | node j children ih =>
      change (DecoderTree.bind (dec j)
        (fun b => lift dec (children b))).queries (Phi z) ≤
        r * ((children (z j)).queries z + 1)
      rw [DecoderTree.bind_queries, hdec_z j]
      have h1 := hcost j (Phi z)
      have h2 := ih (z j)
      rw [Nat.mul_succ]
      omega

/-- On any one decodable source input, truncation preserves the simulator's
exact value, even if decoding is not valid on other (zero-mass) inputs. -/
theorem substitute_eval_at (dec : J → DecoderTree I α β)
    (Phi : (J → β) → (I → α))
    (r : ℕ) (hcost : ∀ j x, (dec j).queries x ≤ r)
    (n : ℕ) (t : DTree J β)
    (z : J → β) (hdepth : t.queries z ≤ n)
    (hdec_z : ∀ j, (dec j).eval (Phi z) = z j) :
    (substitute dec r n t).eval (Phi z) = t.eval z := by
  unfold substitute
  rw [truncate_eval (r * n) (lift dec t) (Phi z)
    ((lift_queries_le_at dec Phi z hdec_z r hcost t).trans
      (Nat.mul_le_mul_left r hdepth))]
  exact lift_eval_at dec Phi z hdec_z t

end Nightfall.ProductSpace.QueryDecoderLift
