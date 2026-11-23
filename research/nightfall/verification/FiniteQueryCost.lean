import Mathlib

/-!
NIGHTFALL finite conditional resource-cost semantics.
This defines the resource function of a finite decision tree. Branch probability
validity and the mapping from a physical oracle to this tree are NOT proved here.
No statement about a general Route 1/Wyner quantum algorithm follows from this
definition alone.
-/

namespace Nightfall.FiniteQueryCost

inductive Tree where
  | leaf : Tree
  | query (oracleCalls : Nat) (pYes : Rat) (yes no : Tree) : Tree

def expected : Tree → Rat
  | .leaf => 0
  | .query n p yes no =>
      (n : Rat) + p * expected yes + (1 - p) * expected no

def worstSyntactic : Tree → Nat
  | .leaf => 0
  | .query n _ yes no =>
      n + max (worstSyntactic yes) (worstSyntactic no)

theorem expected_leaf : expected .leaf = 0 := rfl

theorem expected_query (n : Nat) (p : Rat) (yes no : Tree) :
    expected (.query n p yes no) =
      (n : Rat) + p * expected yes + (1 - p) * expected no := rfl

theorem two_stage_expected :
    expected (.query 1 (1/2) .leaf (.query 1 (1/2) .leaf .leaf)) = (3/2 : Rat) := by
  norm_num [expected]

theorem two_stage_worst :
    worstSyntactic (.query 1 (1/2) .leaf (.query 1 (1/2) .leaf .leaf)) = 2 := by
  norm_num [worstSyntactic]

end Nightfall.FiniteQueryCost
