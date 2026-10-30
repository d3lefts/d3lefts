import Init

/-!
NIGHTFALL: exact finite certificate for a three-query phase block.
Finite field representation: F₂[z]/(z⁴+z+1), with elements encoded as
four-bit polynomials. In this representation F₄ˣ = {1,6,7}.

The kernel proves that the concrete three-output map on four relative
phases has 81 pairwise distinct images. This file is a finite certificate;
the arbitrary-dimensional two-round transfer is proved separately in
the accompanying mathematical note and awaits external review.
-/

namespace Nightfall.PhaseBlock

def doubleReduce (a : Nat) : Nat :=
  let doubled := a * 2
  if doubled < 16 then doubled else Nat.xor doubled 19

def mul (a b : Nat) : Nat :=
  let a1 := doubleReduce a
  let a2 := doubleReduce a1
  let a3 := doubleReduce a2
  let b0 := if b % 2 == 1 then a else 0
  let b1 := if b / 2 % 2 == 1 then a1 else 0
  let b2 := if b / 4 % 2 == 1 then a2 else 0
  let b3 := if b / 8 % 2 == 1 then a3 else 0
  Nat.xor b0 (Nat.xor b1 (Nat.xor b2 b3))

def cube (a : Nat) : Nat := mul (mul a a) a

def phase (n : Nat) : Nat :=
  if n == 0 then 1 else if n == 1 then 6 else 7

-- Each code i < 81 identifies exactly one tuple in {1,6,7}^4.
def coordinate (i j : Nat) : Nat :=
  phase (i / (3 ^ j) % 3)

def mixed (a₀ a₁ a₂ a₃ a₄ : Nat) (i : Fin 81) : Nat :=
  let t0 := mul a₀ 1
  let t1 := mul a₁ (coordinate i.val 0)
  let t2 := mul a₂ (coordinate i.val 1)
  let t3 := mul a₃ (coordinate i.val 2)
  let t4 := mul a₄ (coordinate i.val 3)
  cube (Nat.xor t0 (Nat.xor t1 (Nat.xor t2 (Nat.xor t3 t4))))

def outputs (i : Fin 81) : Nat × Nat × Nat :=
  (mixed 14 12 15 3 7 i,
   mixed 15 4 9 6 8 i,
   mixed 5 5 3 14 6 i)

theorem subgroup_cubic_identity :
    cube 1 = 1 ∧ cube 6 = 1 ∧ cube 7 = 1 := by
  decide

-- This is the computationally decisive certificate, checked by Lean's kernel.
theorem eighty_one_distinct_outputs :
    (List.ofFn (fun i : Fin 81 => outputs i)).Nodup := by
  decide

#print axioms Nightfall.PhaseBlock.subgroup_cubic_identity
#print axioms Nightfall.PhaseBlock.eighty_one_distinct_outputs

end Nightfall.PhaseBlock
