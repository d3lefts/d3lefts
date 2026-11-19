import Mathlib

/-!
# Exact adaptive seed-bit tree → whole-symbol query tree

A sampled conditional decoder can be represented by a *fixed* function
`seed : I → A → U` (the random tape is chosen before the input).
A Boolean query to bit `b` of seed block `i` can be implemented by
one whole-symbol query `i`, followed by the fixed predicate
`a ↦ bit (seed i a) b`.

The resulting deterministic whole-symbol decision tree has:
* exactly the same output at every original input,
* exactly the same number of queries on every path,
* exactly the same worst-case depth.

No explicit adaptive seed cache is necessary for QUERY-DEPTH complexity:
repeated bit queries simply re-query the whole source symbol and use the
same fixed decoder table. This does NOT establish the random tape's
distribution, BDST, or the coherent quantum oracle reduction.
-/

namespace Nightfall.StrongAdaptiveSeedCompiler

variable {I A U B : Type*}

/-- A deterministic decision tree querying individual bits in seed blocks. -/
inductive BitTree (I B : Type*) where
  | leaf (v : ℝ) : BitTree I B
  | query (i : I) (b : B)
      (yes no : BitTree I B) : BitTree I B

/-- A deterministic whole-symbol query can apply a fixed Boolean predicate
to its returned symbol. It costs one whole-symbol query. -/
inductive SymbolTree (I A : Type*) where
  | leaf (v : ℝ) : SymbolTree I A
  | query (i : I) (test : A → Bool)
      (yes no : SymbolTree I A) : SymbolTree I A

/-- Bit-query execution on an entire seed input. -/
def bitEval (bit : U → B → Bool) :
    BitTree I B → (I → U) → ℝ
  | .leaf v, _ => v
  | .query i b yes no, seeds =>
      if bit (seeds i) b then
        bitEval bit yes seeds
      else bitEval bit no seeds

/-- Number of individual bit queries executed along this input path. -/
def bitQueries (bit : U → B → Bool) :
    BitTree I B → (I → U) → ℕ
  | .leaf _, _ => 0
  | .query i b yes no, seeds =>
      1 + if bit (seeds i) b then
        bitQueries bit yes seeds
      else bitQueries bit no seeds

/-- Worst-case structural depth of the bit decision tree. -/
def bitDepth : BitTree I B → ℕ
  | .leaf _ => 0
  | .query _ _ yes no => 1 + max (bitDepth yes) (bitDepth no)

/-- Whole-symbol tree execution. -/
def symbolEval : SymbolTree I A → (I → A) → ℝ
  | .leaf v, _ => v
  | .query i test yes no, x =>
      if test (x i) then
        symbolEval yes x
      else symbolEval no x

/-- Number of whole-symbol queries executed along this original input path. -/
def symbolQueries : SymbolTree I A → (I → A) → ℕ
  | .leaf _, _ => 0
  | .query i test yes no, x =>
      1 + if test (x i) then
        symbolQueries yes x
      else symbolQueries no x

/-- Worst-case structural depth of the whole-symbol decision tree. -/
def symbolDepth : SymbolTree I A → ℕ
  | .leaf _ => 0
  | .query _ _ yes no => 1 + max (symbolDepth yes) (symbolDepth no)

/-- Compile every bit query into a whole-symbol query with deterministic,
input-independent postprocessing of the returned symbol. -/
def compile (seed : I → A → U) (bit : U → B → Bool) :
    BitTree I B → SymbolTree I A
  | .leaf v => .leaf v
  | .query i b yes no =>
      .query i (fun a => bit (seed i a) b)
        (compile seed bit yes) (compile seed bit no)

/-- *Exact semantic compilation*, even for repeated adaptive bit queries
to the same seed block and arbitrary fixed seed maps. -/
theorem exact_tree_output
    (seed : I → A → U) (bit : U → B → Bool)
    (t : BitTree I B) (x : I → A) :
    symbolEval (compile seed bit t) x =
      bitEval bit t (fun i => seed i (x i)) := by
  induction t with
  | leaf v => rfl
  | query i b yes no ihYes ihNo =>
      simp only [compile, symbolEval, bitEval]
      split_ifs <;> assumption

/-- The compiled whole-symbol tree uses exactly one query for each
individual queried seed bit, so no adaptive caching is needed. -/
theorem exact_tree_queries
    (seed : I → A → U) (bit : U → B → Bool)
    (t : BitTree I B) (x : I → A) :
    symbolQueries (compile seed bit t) x =
      bitQueries bit t (fun i => seed i (x i)) := by
  induction t with
  | leaf v => rfl
  | query i b yes no ihYes ihNo =>
      simp only [compile, symbolQueries, bitQueries]
      split_ifs <;> simp [ihYes, ihNo]

/-- Uniform worst-case depth preservation. In particular an `n`-query
strong simulator on uniform seed bits transfers to an `n`-whole-symbol
tree once a valid deterministic seed table has been fixed. -/
theorem exact_tree_depth
    (seed : I → A → U) (bit : U → B → Bool)
    (t : BitTree I B) :
    symbolDepth (compile seed bit t) = bitDepth t := by
  induction t with
  | leaf v => rfl
  | query i b yes no ihYes ihNo =>
      simp [compile, symbolDepth, bitDepth, ihYes, ihNo]

end Nightfall.StrongAdaptiveSeedCompiler

#print axioms Nightfall.StrongAdaptiveSeedCompiler.exact_tree_output
#print axioms Nightfall.StrongAdaptiveSeedCompiler.exact_tree_queries
#print axioms Nightfall.StrongAdaptiveSeedCompiler.exact_tree_depth
