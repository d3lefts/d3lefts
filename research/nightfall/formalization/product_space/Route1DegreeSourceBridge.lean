import ProductRowBound
import Route1LatentDegree

/-!
Source-connected degree bridge for the Route 1 latent lift.

Unlike Route1LatentDegree.lean's Mathlib-only source, this directly checks
definitional compatibility with the pinned repository RowBound.HasProdDegreeLE.
The theorem is still *only* about indicator interaction degree, not the
original-source ES residual theorem or the complete polylog-M simulator.
-/

namespace Nightfall.Route1SourceBridge

open Nightfall.Route1LatentDegree
open Nightfall.ProductSpace.RowBound

variable {ι A : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype A] [DecidableEq A] [Nonempty A]

theorem local_to_source (f : (ι → A) → ℝ) (d : ℕ)
    (hf : DegreeLE f d) : HasProdDegreeLE f d := by
  exact hf

theorem source_to_local (f : (ι → A) → ℝ) (d : ℕ)
    (hf : HasProdDegreeLE f d) : DegreeLE f d := by
  exact hf

variable {Θ U : Type*}
  [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
  [Fintype U] [DecidableEq U] [Nonempty U]

/-- Pinned RowBound-compatible all-degree latent-coordinate theorem.
Every encoded coordinatewise decoder with one shared latent label
increases indicator interaction degree by at most one. -/
theorem source_latent_degree_succ (f : (ι → A) → ℝ)
    (h : Θ → ι → U → A) (d : ℕ)
    (hf : HasProdDegreeLE f d) :
    HasProdDegreeLE (latentLift f h) (d+1) := by
  exact local_to_source _ _ (latent_degree_succ f h d (source_to_local f d hf))

end Nightfall.Route1SourceBridge

#print axioms Nightfall.Route1SourceBridge.local_to_source
#print axioms Nightfall.Route1SourceBridge.source_to_local
#print axioms Nightfall.Route1SourceBridge.source_latent_degree_succ
