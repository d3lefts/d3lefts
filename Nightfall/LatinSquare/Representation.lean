import Mathlib

/-!
# Latin squares as ordered perfect-matching factorizations

The elementary combinatorial representation underlying Mira Cult's
"Exact uniform generation of labeled Latin squares", pinned at
30ddaaad27b48df2002225c3e3f40cffd02c5253.

For fixed column/symbol shores Fin n, each physical row is a bijection,
hence a perfect matching. Pairwise edge disjointness is equivalent
to Latin column bijectivity because both shores have cardinality n.

This module is elementary and DOES NOT formalize the decorated proposal,
its analytic performance bounds, or expected polynomial-time sampling.
-/

namespace Nightfall.LatinSquare

/-- Every physical row and column is a permutation of the symbol set. -/
def IsLabeledLatin (n : ℕ) (S : Fin n → Fin n → Fin n) : Prop :=
  (∀ row, Function.Bijective (S row)) ∧
    (∀ col, Function.Bijective (fun row => S row col))

/-- Each row is a perfect matching from columns to symbols. -/
def HasPerfectMatchingRows (n : ℕ) (S : Fin n → Fin n → Fin n) : Prop :=
  ∀ row, Function.Bijective (S row)

/-- Two different physical rows never use the same column-symbol edge. -/
def PairwiseEdgeDisjoint (n : ℕ) (S : Fin n → Fin n → Fin n) : Prop :=
  ∀ r₁ r₂ : Fin n, r₁ ≠ r₂ → ∀ col, S r₁ col ≠ S r₂ col

/-- Edge-disjoint rows are equivalent to injectivity of each fixed
column's symbol map. -/
theorem edgeDisjoint_iff_column_injective
    (n : ℕ) (S : Fin n → Fin n → Fin n) :
    PairwiseEdgeDisjoint n S ↔
      ∀ col, Function.Injective (fun row => S row col) := by
  constructor
  · intro h col r₁ r₂ heq
    by_contra hneq
    exact h r₁ r₂ hneq col heq
  · intro h r₁ r₂ hneq col heq
    exact hneq ((h col) heq)

/-- The exact row-perfect-matching representation: an array is Latin
iff it is an ordered decomposition into n disjoint matching rows. -/
theorem latin_iff_ordered_one_factorization
    (n : ℕ) (S : Fin n → Fin n → Fin n) :
    IsLabeledLatin n S ↔
      HasPerfectMatchingRows n S ∧ PairwiseEdgeDisjoint n S := by
  constructor
  · intro h
    refine ⟨h.1, ?_⟩
    exact (edgeDisjoint_iff_column_injective n S).2
      (fun col => (h.2 col).1)
  · intro h
    refine ⟨h.1, ?_⟩
    intro col
    exact (Finite.injective_iff_bijective).mp
      ((edgeDisjoint_iff_column_injective n S).1 h.2 col)

#print axioms Nightfall.LatinSquare.edgeDisjoint_iff_column_injective
#print axioms Nightfall.LatinSquare.latin_iff_ordered_one_factorization

end Nightfall.LatinSquare
