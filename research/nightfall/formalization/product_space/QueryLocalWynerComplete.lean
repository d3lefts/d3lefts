import QueryLocalWynerDegree
import QueryLocalWynerTerminal

/-!
# NIGHTFALL — source-connected full finite b-local Wyner simulation theorem

This applies the *actual*, finite-alphabet, general-latent kernel-checked
Route1 theorem to every b-local encoded input, with an adaptive decoder
implemented by real observed-coordinate queries, exact r*q cost on ALL
observed words, and one-sided total-variation event transfer.

No b-local source degree hypothesis is assumed here: it is proved by
QueryLocalWynerDegree.degree_local_pullback. No witness-computation/runtime
claim, equality of arbitrary unnormalized information laws, or exact
ambient-vs-latent C_W gap is asserted.
-/

namespace Nightfall.QueryLocalWyner

open Finset
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.RowBound
open Nightfall.Route1Polylog

variable {I J A : Type}
  [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype A] [DecidableEq A] [Nonempty A]

theorem degree_le_mono
    (f : (J → A) → ℝ) (d e : ℕ)
    (hde : d ≤ e) (hd : HasProdDegreeLE f d) :
    HasProdDegreeLE f e := by
  obtain ⟨a, ha0, ha⟩ := hd
  exact ⟨a, (by
    intro T he τ
    exact ha0 T (lt_of_le_of_lt hde he) τ), ha⟩

/-- Costed query-local Wyner theorem with b-locality checked by source
proof rather than accepted as a separate interaction-degree premise.
The error constant and exact q-denominator come from Route1WynerGeneral. -/
theorem query_local_wyner_blocal
    (μ : (J → A) → ℝ)
    (hμ0 : ∀ z, 0 ≤ μ z)
    (hμ1 : ∑ z, μ z = 1)
    (ν : (I → A) → ℝ)
    (Φ : (J → A) → (I → A))
    (S : I → Finset J) (b d : ℕ)
    (hb : ∀ i, (S i).card ≤ b)
    (hlocal : LocallyEncoded Φ S)
    (recover : J → RecoveryTree I A)
    (r : ℕ) (hr : ∀ j x, (recover j).queries x ≤ r)
    (hrec : ∀ z, μ z ≠ 0 → ∀ j, (recover j).eval (Φ z) = z j)
    (ζ : ℝ)
    (hTV : ∀ E : (I → A) → Prop,
      (∑ x, ν x * (if E x then (1 : ℝ) else 0)) ≤
        (∑ z, μ z * (if E (Φ z) then (1 : ℝ) else 0)) + ζ)
    (f : (I → A) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (q : ℕ) (hq : 0 < q) (s : ℝ) (hs : wynerGen μ < s) :
    ∃ obs : DTree I A,
      (∀ x, obs.queries x ≤ r * q) ∧
      (∑ x, ν x * (if ε < |f x - obs.eval x| then (1 : ℝ) else 0)) ≤
        ((Real.pi ^ 2 * ((max 1 (b*d) : ℕ) : ℝ) ^ 2 / 2) /
              (2 * gam (max 1 (b*d)) τ) +
          s / (etaC (max 1 (b*d)) τ ^ 2 *
            w0C (Real.pi ^ 2 * ((max 1 (b*d) : ℕ) : ℝ) ^ 2 / 2)
              (max 1 (b*d)) τ)) / q
          + τ / ε ^ 2 + ζ := by
  have hpull : HasProdDegreeLE (fun z => f (Φ z)) (b*d) :=
    degree_local_pullback Φ S b d hb hlocal f hdeg
  have hmono : HasProdDegreeLE (fun z => f (Φ z)) (max 1 (b*d)) :=
    degree_le_mono _ (b*d) _ (le_max_right 1 (b*d)) hpull
  exact query_local_wyner_terminal μ hμ0 hμ1 ν Φ recover r hr hrec
    ζ hTV f hf01 (max 1 (b*d)) (le_max_left 1 (b*d))
    hmono τ hτ hτ1 ε hε q hq s hs

end Nightfall.QueryLocalWyner

#print axioms Nightfall.QueryLocalWyner.degree_le_mono
#print axioms Nightfall.QueryLocalWyner.query_local_wyner_blocal
#print Nightfall.QueryLocalWyner.query_local_wyner_blocal
