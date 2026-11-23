import Mathlib

/-!
Exact, all-size coherent edge/star XOR oracle action. Equality on all
computational basis labels implies equality of the corresponding linear
permutation operators on the free vector space; this module does NOT assert
a physical intensity device implements those unitaries.
-/

namespace Nightfall.OperationalInformationCost

/-- The root-star bit associated to a vertex. The root is a fixed gauge. -/
def starBit {V : Type*} [DecidableEq V] (root : V) (z : V → Bool) (v : V) : Bool :=
  if v = root then false else z v

/-- One coherent star XOR action on the answer register. -/
def starAction {V : Type*} [DecidableEq V]
    (root : V) (z : V → Bool) (v : V) (answer : Bool) : Bool :=
  answer ^^ starBit root z v

/-- The original edge parity oracle, in the root-fixed representation. -/
def edgeAction {V : Type*} [DecidableEq V]
    (root : V) (z : V → Bool) (u v : V) (answer : Bool) : Bool :=
  answer ^^ (starBit root z u ^^ starBit root z v)

/-- The two coherent star calls implement the edge oracle on every basis label. -/
theorem edge_eq_two_stars {V : Type*} [DecidableEq V]
    (root : V) (z : V → Bool) (u v : V) (answer : Bool) :
    edgeAction root z u v answer =
      starAction root z v (starAction root z u answer) := by
  simp only [edgeAction, starAction]
  cases answer <;> cases starBit root z u <;> cases starBit root z v <;> rfl

/-- The root coordinate is identically zero, so a root-star call is free. -/
theorem starBit_root {V : Type*} [DecidableEq V]
    (root : V) (z : V → Bool) :
    starBit root z root = false := by
  simp [starBit]

/-- A root-edge query agrees with one star query on every answer label. -/
theorem edge_root_eq_star {V : Type*} [DecidableEq V]
    (root : V) (z : V → Bool) (v : V) (answer : Bool) :
    edgeAction root z root v answer = starAction root z v answer := by
  simp [edgeAction, starAction, starBit]

/-- Every edge bit is recovered by two root-star bits. -/
theorem edge_parity_eq_stars {V : Type*} [DecidableEq V]
    (root : V) (z : V → Bool) (u v : V) :
    edgeAction root z u v false =
      starBit root z u ^^ starBit root z v := by
  cases starBit root z u <;> cases starBit root z v <;> rfl

#print axioms Nightfall.OperationalInformationCost.edge_eq_two_stars
#print axioms Nightfall.OperationalInformationCost.edge_root_eq_star
#print axioms Nightfall.OperationalInformationCost.edge_parity_eq_stars

end Nightfall.OperationalInformationCost
