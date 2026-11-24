import TrustedBaseline

open InclusionBench InclusionBench.Support InclusionBench.Counting
open InclusionBench.Support.Classes

namespace Nightfall.InclusionBridge

/-- Uniform enumeration of a polynomial number of relevant contraction terms.
The ambient array need not be materialized. This is a computational
representation, not an assumption about the complexity class of a language. -/
structure SparseContraction where
  count : Word → Nat
  left : Word → Nat → Int
  right : Word → Nat → Int
  bound : List Nat
  countFP : PolynomialNatural count
  leftFP : PolynomialIntegerEntry left
  rightFP : PolynomialIntegerEntry right
  small : ∀ input, count input ≤ polynomialValue bound input.length

def SparseContraction.score (c : SparseContraction) (input : Word) : Int :=
  integerDot ((List.range (c.count input)).map (c.left input))
    ((List.range (c.count input)).map (c.right input))

theorem SparseContraction.score_fp (c : SparseContraction) : FP c.score := by
  exact fp_integerArray_dot
    (polynomialIntegerArray_tabulate c.countFP c.leftFP c.bound c.small)
    (polynomialIntegerArray_tabulate c.countFP c.rightFP c.bound c.small)

/-- Transfer a source-level identity to an actual uniform FP implementation. -/
theorem source_score_fp (c : SparseContraction) (source : Word → Int)
    (identity : ∀ input, c.score input = source input) : FP source :=
  fp_congr c.score_fp identity

/-- Exact equality decision. Unlike a query bound, this conclusion is in
the benchmark's frozen operational P class. -/
theorem equality_in_P (c : SparseContraction) (threshold : Word → Int)
    (thresholdFP : FP threshold) (language : Language)
    (correct : ∀ input, c.score input = threshold input ↔ language input) :
    P language := by
  change InclusionBench.Machines.polynomialTime language
  exact p_of_predicate (polynomialPredicate_congr
    (polynomialPredicate_integer_eq c.score_fp thresholdFP) correct)

/-- More general terminal: an explicitly certified integer postprocessing map
decides the language from the signed exact score. No new axiom is introduced. -/
theorem terminal_in_P (c : SparseContraction) (threshold : Word → Int)
    (thresholdFP : FP threshold) (post : Int → Int)
    (postFP : PolynomialIntegerMap post) (language : Language)
    (correct : ∀ input, post (c.score input - threshold input) = 1 ↔ language input) :
    P language := by
  change InclusionBench.Machines.polynomialTime language
  have h : FP (fun input => post (c.score input - threshold input)) :=
    fp_integer_map postFP (fp_sub c.score_fp thresholdFP)
  exact p_of_predicate (polynomialPredicate_congr
    (polynomialPredicate_integer_eq h (fp_const 1)) correct)

end Nightfall.InclusionBridge
