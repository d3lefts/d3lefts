import Init

/-!
RYEV #250: finite same-oracle F16 adaptive 27-state block and a general
algebraic phase-factorization lemma. Uses polynomial-bit arithmetic for
the Lean kernel and an independently developed GF4 tower Python replay.

This is NOT a Lean proof of arbitrary-dimensional phase decoding.
The support/anchor selection and chunked adaptive observation theorem
remain unformalized. No external mathematical review is implied.
-/

namespace Nightfall.AdaptiveF16

def xtime (a : Nat) : Nat :=
  let z := 2 * a
  if z < 16 then z else Nat.xor z 19

def mul (a b : Nat) : Nat :=
  let a1 := xtime a
  let a2 := xtime a1
  let a3 := xtime a2
  Nat.xor (if b % 2 == 1 then a else 0)
    (Nat.xor (if b / 2 % 2 == 1 then a1 else 0)
      (Nat.xor (if b / 4 % 2 == 1 then a2 else 0)
        (if b / 8 % 2 == 1 then a3 else 0)))

def cube (a : Nat) : Nat := mul (mul a a) a

def phase (a : Nat) : Nat :=
  if a % 3 == 0 then 1 else if a % 3 == 1 then 6 else 7

def mixed (a b c d : Nat) (i : Fin 27) : Nat :=
  let e1 := phase i.val
  let e2 := phase (i.val / 3)
  let e3 := phase (i.val / 9)
  cube (Nat.xor a (Nat.xor (mul b e1) (Nat.xor (mul c e2) (mul d e3))))

def first (i : Fin 27) : Nat := mixed 1 2 3 4 i

-- The next row is chosen solely from the *measured cubed result*.
def second (y : Nat) (i : Fin 27) : Nat :=
  if y == 0 then mixed 0 0 0 1 i
  else if y == 1 then mixed 1 0 2 8 i
  else if y == 8 then mixed 0 1 4 8 i
  else if y == 10 then mixed 0 1 2 4 i
  else if y == 12 then mixed 0 1 8 4 i
  else if y == 15 then mixed 0 1 2 4 i
  else 0

def output (i : Fin 27) : Nat × Nat :=
  (first i, second (first i) i)

theorem first_reading_branch_boolean_certificate :
    decide (∀ i : Fin 27,
      first i = 0 ∨ first i = 1 ∨ first i = 8 ∨
      first i = 10 ∨ first i = 12 ∨ first i = 15) = true := by
  rfl

theorem adaptive_twenty_seven_boolean_certificate :
    decide ((List.ofFn (fun i : Fin 27 => output i)).Nodup) = true := by
  rfl

theorem worst_case_lower_bound_k4 :
    6 ^ 5 < 1 + (16 ^ 4 - 1) / 3 := by
  decide

theorem worst_case_lower_bound_k7 :
    6 ^ 10 < 1 + (16 ^ 7 - 1) / 3 := by
  decide

-- Parametric transport only: once all relative phases have been recovered,
-- one common anchor phase recovers the signal in any finite dimension.
-- This lemma does NOT assert that the relative phases are observable.
theorem phase_factorization
    {α : Type} (op : α → α → α)
    (assoc : ∀ a b c : α, op (op a b) c = op a (op b c))
    {k : Nat} (u lam eta x : Fin k → α) (anchor : Fin k)
    (phase_rel : ∀ i, lam i = op (lam anchor) (eta i))
    (coord_rel : ∀ i, x i = op (lam i) (u i)) :
    ∀ i, x i = op (lam anchor) (op (eta i) (u i)) := by
  intro i
  rw [coord_rel i, phase_rel i, assoc]

#print axioms Nightfall.AdaptiveF16.first_reading_branch_boolean_certificate
#print axioms Nightfall.AdaptiveF16.adaptive_twenty_seven_boolean_certificate
#print axioms Nightfall.AdaptiveF16.worst_case_lower_bound_k4
#print axioms Nightfall.AdaptiveF16.worst_case_lower_bound_k7
#print axioms Nightfall.AdaptiveF16.phase_factorization

end Nightfall.AdaptiveF16
