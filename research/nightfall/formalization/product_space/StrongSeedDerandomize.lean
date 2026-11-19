import StrongAdaptiveSeedCompiler
import StrongSeedFixing

/-!
# Strong simulation: actual deterministic whole-symbol tree from weighted seed averaging

The existing finite `StrongSeedFixing.exists_weighted_seed` selects one
real-weighted finite random tape whose original-source error does not exceed
the average. The new `StrongAdaptiveSeedCompiler` then compiles the full
adaptive bit-query tree to a deterministic whole-symbol tree, exactly
preserving output on every source input and the worst-case query depth.

This theorem does not assume a deterministic output tree exists.
It CONSTRUCTS one from a bit tree, a finite decoder-table distribution,
and a proven bound on the actual source-weighted failure event.

Unproved obligations outside this module:
* show that one-sided dyadic seed kernels induce the required average failure
  from uniform BDST and quantum coupling;
* formalize coherent quantum bit-oracle substitution and hybrid query weights;
* instantiate the frozen mixture tournament using the actual weighted tests.
-/

namespace Nightfall.StrongSeedDerandomize

open Finset
open Nightfall.StrongAdaptiveSeedCompiler
open Nightfall.StrongSimulation.SeedFixing

variable {I A U B : Type*}
variable [Fintype I] [Fintype A] [Fintype U]

/-- Actual source failure event of the compiled deterministic symbol tree. -/
noncomputable def symbolFailureMass
    (mass : (I → A) → ℝ) (f : (I → A) → ℝ)
    (t : SymbolTree I A) (ε : ℝ) : ℝ :=
  ∑ x : I → A,
    mass x * (if ε < |f x - symbolEval t x| then (1 : ℝ) else 0)

/-- Average source failure of a randomized seed table, evaluated through the
original adaptive bit-tree's exact semantics. -/
noncomputable def seedFailureMass
    (mass : (I → A) → ℝ) (f : (I → A) → ℝ)
    (t : BitTree I B) (bit : U → B → Bool)
    (σ : I → A → U) (ε : ℝ) : ℝ :=
  ∑ x : I → A,
    mass x *
      (if ε < |f x - bitEval bit t (fun i => σ i (x i))|
       then (1 : ℝ) else 0)

/-- Identical original-source failure mass for every fixed decoder table.
This equality holds without probability normalization assumptions. -/
theorem compiled_failure_mass_eq
    (mass : (I → A) → ℝ) (f : (I → A) → ℝ)
    (t : BitTree I B) (bit : U → B → Bool)
    (σ : I → A → U) (ε : ℝ) :
    symbolFailureMass mass f (compile σ bit t) ε =
      seedFailureMass mass f t bit σ ε := by
  simp [symbolFailureMass, seedFailureMass, exact_tree_output]

/-- **Concrete classical strong transfer, at the finite-randomness interface.**
A weighted distribution on fixed decoder tables (arbitrary nonnegative real
weights, including zeros) can be derandomized to an actual deterministic
whole-symbol decision tree of exactly the original bit-tree depth.
Its failure mass under the true original source is at most δ.

The only probabilistic hypothesis is the explicit average failure bound;
there is NO assumed `hproduct` for an already-existing deterministic
symbol tree, and NO hidden lazy cache. -/
theorem exists_strong_symbol_tree
    (mass : (I → A) → ℝ) (f : (I → A) → ℝ)
    (t : BitTree I B) (bit : U → B → Bool)
    (weight : (I → A → U) → ℝ) (ε δ : ℝ)
    (hw0 : ∀ σ, 0 ≤ weight σ)
    (hw1 : (∑ σ : I → A → U, weight σ) = 1)
    (haverage : (∑ σ : I → A → U,
      weight σ * seedFailureMass mass f t bit σ ε) ≤ δ) :
    ∃ tree : SymbolTree I A,
      symbolDepth tree = bitDepth t ∧
      symbolFailureMass mass f tree ε ≤ δ := by
  classical
  obtain ⟨σ, _hσpos, hσ⟩ :=
    exists_weighted_seed
      weight (fun σ => seedFailureMass mass f t bit σ ε)
      δ hw0 hw1 haverage
  refine ⟨compile σ bit t, exact_tree_depth σ bit t, ?_⟩
  rw [compiled_failure_mass_eq]
  exact hσ

end Nightfall.StrongSeedDerandomize

#print axioms Nightfall.StrongSeedDerandomize.compiled_failure_mass_eq
#print axioms Nightfall.StrongSeedDerandomize.exists_strong_symbol_tree
