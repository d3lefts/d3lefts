import QueryLocalWynerCompiler
import Route1WynerGeneral

/-!
# NIGHTFALL — source-exact query-local Wyner simulation terminal

Applies the already kernel-checked general-latent Wyner Route1 theorem to
f ∘ Φ, compiles its ACTUAL latent DTree into single-observed-coordinate
queries, and transfers the failure event by a one-sided TV event bound.

No decoder oracle is free: every adaptive observed query is charged.
A separate degree-locality lemma must establish HasProdDegreeLE (f ∘ Φ) D
from a particular b-local encoding and observed degree-d target. This
terminal assumes that precise predicate explicitly and does not promote
the full #1150 b*d composition or the exact duplicate-source Wyner gap.
-/

namespace Nightfall.QueryLocalWyner

open Finset
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.RowBound
open Nightfall.Route1Polylog

variable {I J A : Type}
  [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype A] [DecidableEq A] [Nonempty A]

/-- Exact observed-query Route1 Wyner simulation given a source-verified
latent degree predicate and deterministic costed recovery of every latent
coordinate. This works for arbitrary finite source laws and arbitrary
finite alphabets, including zero-mass source words. -/
theorem query_local_wyner_terminal
    (μ : (J → A) → ℝ)
    (hμ0 : ∀ z, 0 ≤ μ z)
    (hμ1 : ∑ z, μ z = 1)
    (ν : (I → A) → ℝ)
    (Φ : (J → A) → (I → A))
    (recover : J → RecoveryTree I A)
    (r : ℕ) (hr : ∀ j x, (recover j).queries x ≤ r)
    (hrec : ∀ z, μ z ≠ 0 → ∀ j, (recover j).eval (Φ z) = z j)
    (ζ : ℝ)
    (hTV : ∀ (E : (I → A) → Prop) [DecidablePred E],
      (∑ x, ν x * (if E x then (1 : ℝ) else 0)) ≤
        (∑ z, μ z * (if E (Φ z) then (1 : ℝ) else 0)) + ζ)
    (f : (I → A) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (D : ℕ) (hD : 1 ≤ D)
    (hdeg : HasProdDegreeLE (fun z => f (Φ z)) D)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (q : ℕ) (hq : 0 < q) (s : ℝ) (hs : wynerGen μ < s) :
    ∃ obs : DTree I A,
      (∀ x, obs.queries x ≤ r * q) ∧
      (∑ x, ν x * (if ε < |f x - obs.eval x| then (1 : ℝ) else 0)) ≤
        ((Real.pi ^ 2 * (D : ℝ) ^ 2 / 2) / (2 * gam D τ) +
          s / (etaC D τ ^ 2 *
            w0C (Real.pi ^ 2 * (D : ℝ) ^ 2 / 2) D τ)) / q
          + τ / ε ^ 2 + ζ := by
  classical
  obtain ⟨t, hdepth, hfail⟩ :=
    route1_wyner_general μ hμ0 hμ1
      (fun z => f (Φ z)) (fun z => hf01 (Φ z))
      D hD hdeg τ hτ hτ1 ε hε q hq s hs
  have hcorrect : ∀ z, μ z ≠ 0 →
      (compile recover t).eval (Φ z) = t.eval z := by
    intro z hz
    exact compile_correct_on_source recover Φ t z (hrec z hz)
  refine ⟨compile recover t, ?_, ?_⟩
  · exact compile_global_depth recover r q hr t hdepth
  · calc
      (∑ x, ν x * (if ε < |f x - (compile recover t).eval x|
        then (1 : ℝ) else 0)) ≤
        (∑ z, μ z * (if ε < |f (Φ z) - (compile recover t).eval (Φ z)|
          then (1 : ℝ) else 0)) + ζ :=
            hTV (fun x => ε < |f x - (compile recover t).eval x|)
      _ = (∑ z, μ z * (if ε < |f (Φ z) - t.eval z|
          then (1 : ℝ) else 0)) + ζ := by
            congr 1
            apply Finset.sum_congr rfl
            intro z _
            by_cases hz : μ z = 0
            · simp [hz]
            · rw [hcorrect z hz]
      _ ≤ ((Real.pi ^ 2 * (D : ℝ) ^ 2 / 2) / (2 * gam D τ) +
          s / (etaC D τ ^ 2 *
            w0C (Real.pi ^ 2 * (D : ℝ) ^ 2 / 2) D τ)) / q
          + τ / ε ^ 2 + ζ :=
            by simpa [add_comm] using (add_le_add_right hfail ζ)

end Nightfall.QueryLocalWyner

#print axioms Nightfall.QueryLocalWyner.query_local_wyner_terminal
#print Nightfall.QueryLocalWyner.query_local_wyner_terminal
