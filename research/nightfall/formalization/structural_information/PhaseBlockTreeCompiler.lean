import ProductSimulation
import PhaseBlockRoute1

/-!
# Exact 3-query physical sensor compilation of NIGHTFALL's actual Route1 DTree

Unlike a surrogate query-cost lemma, this works with the exact
`Nightfall.ProductSpace.Simulation.DTree` type already used by merged Route1.
Every block-variable query is replaced by three nested real-intensity
coordinate queries (sensors 0,1,2), and the unique finite-state decoder
routes to the original child. This preserves the estimator output and scales
the actual per-input query count by exactly 3.

This module does not assert that an arbitrary physical amplitude oracle is
sign-invariant, nor that a user-supplied nonlocal quantum query has degree 1.
-/

namespace Nightfall.PhaseBlockTreeCompiler
open Nightfall.PhaseBlockRoute1
open Nightfall.ProductSpace.Simulation

/-- Observed integer intensities are all between 0 and 25; use a FINITE
alphabet to match Route1's original finite-symbol query model exactly. -/
def rawReading (s : Fin 8) (j : Fin 4) : Fin 26 :=
  ⟨(reading s j).toNat, by
    have h := all_measurements_bounded s j
    omega⟩

def tripleRead (s : Fin 8) : Fin 3 → Fin 26 :=
  ![rawReading s 0, rawReading s 1, rawReading s 2]

theorem tripleRead_injective : Function.Injective tripleRead := by
  decide

/-- Total (nonuniform) exact decoder. Its behavior off the eight valid
three-reading strings is irrelevant to the original-signal promise. -/
noncomputable def decodeTriple (v : Fin 3 → Fin 26) : Fin 8 :=
  if h : ∃ s : Fin 8, tripleRead s = v then Classical.choose h else 0

theorem decodeTriple_correct (s : Fin 8) :
    decodeTriple (tripleRead s) = s := by
  classical
  unfold decodeTriple
  split
  · next h =>
      exact tripleRead_injective (Classical.choose_spec h)
  · next h =>
      exact False.elim (h ⟨s,rfl⟩)

/-- Real physical four-sensor table induced by independent hidden blocks. -/
def rawTable {B : Type*} (x : B → Fin 8) : B × Fin 4 → Fin 26 :=
  fun pos => rawReading (x pos.1) pos.2

/-- The actual existing decision-tree type is preserved, with a new query
alphabet and raw-address space. Each hidden block read is replaced by
exactly three physical sensor queries, and decoder lookup is free. -/
noncomputable def compileTree {B : Type*} :
    DTree B (Fin 8) → DTree (B × Fin 4) (Fin 26)
  | .leaf v bad => .leaf v bad
  | .node b cont =>
      .node (b,0) (fun v0 =>
        .node (b,1) (fun v1 =>
          .node (b,2) (fun v2 =>
            compileTree (cont (decodeTriple ![v0,v1,v2])))))

/-- **Source-exact terminal semantics:** compiled physical sensor tree
returns exactly the same scalar as the decoded-block Route1 tree. -/
theorem compileTree_eval {B : Type*}
    (t : DTree B (Fin 8)) (x : B → Fin 8) :
    (compileTree t).eval (rawTable x) = t.eval x := by
  induction t with
  | leaf v bad =>
      rfl
  | node b cont ih =>
      have hdec :
          decodeTriple ![rawReading (x b) 0, rawReading (x b) 1, rawReading (x b) 2] =
            x b := by
        simpa only [tripleRead] using decodeTriple_correct (x b)
      simpa [compileTree, DTree.eval, rawTable, hdec] using ih (x b)

/-- The raw physical access count equals EXACTLY three times the original
adaptive decoded-block query count, for every hidden input separately. -/
theorem compileTree_queries {B : Type*}
    (t : DTree B (Fin 8)) (x : B → Fin 8) :
    (compileTree t).queries (rawTable x) = 3 * t.queries x := by
  induction t with
  | leaf v bad =>
      rfl
  | node b cont ih =>
      have hdec :
          decodeTriple ![rawReading (x b) 0, rawReading (x b) 1, rawReading (x b) 2] =
            x b := by
        simpa only [tripleRead] using decodeTriple_correct (x b)
      have hr := ih (x b)
      simp only [compileTree, DTree.queries, rawTable]
      rw [hdec, hr]
      omega

#print axioms Nightfall.PhaseBlockTreeCompiler.tripleRead_injective
#print axioms Nightfall.PhaseBlockTreeCompiler.decodeTriple_correct
#print axioms Nightfall.PhaseBlockTreeCompiler.compileTree_eval
#print axioms Nightfall.PhaseBlockTreeCompiler.compileTree_queries
#print Nightfall.PhaseBlockTreeCompiler.compileTree_queries

end Nightfall.PhaseBlockTreeCompiler
