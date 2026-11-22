import Route1WynerGeneral
import PhaseBlockLocality

/-!
# Phase-block decoding composes with Route 1 at actual interaction degree.

Given a polynomial-style expansion into finitely many raw-oracle-local
terms, every raw entry reads a single hidden block, so the same acceptance
function on hidden block symbols has degree ≤ d. We invoke the exact
source-merged Route 1 / general-Wyner theorem on those block symbols.

Caveats: the finite polynomial representation of an arbitrary T-query
quantum *value oracle* from Beals et al. is an EXTERNAL paper theorem,
not proved here. The assertion C_W(product decoded law)=0 is also not
proved in this module. This is a certified composition conditional on
the actual finite expansion, probability law, and Wyner bound parameters.
-/

namespace Nightfall.PhaseBlockRoute1

open Finset
open Nightfall.PhaseBlockLocality
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Simulation

variable {B J S V K : Type*}
variable [Fintype B] [DecidableEq B]
variable [Fintype S] [DecidableEq S] [Nonempty S]
variable [Fintype K]

/-- Raw-local finite expansion remains degree at most d in hidden block
coordinates after composition with any deterministic single-block reader. -/
theorem pulled_raw_terms_have_degree
    (read : S → J → V)
    (terms : K → ((B × J) → V) → ℝ)
    (R : K → Finset (B × J))
    (d : ℕ)
    (hsupp : ∀ k, RawSupportedOn (R k) (terms k))
    (hsize : ∀ k, (R k).card ≤ d) :
    HasProdDegreeLE
      (fun x : B → S => ∑ k, terms k (encode read x)) d := by
  refine Nightfall.Route1Polylog.deg_of_terms
    (fun k x => terms k (encode read x))
    (fun k => (R k).image Prod.fst) d ?_ ?_
  · intro k
    exact Or.inl ((pullback_support_card_le (R k)).trans (hsize k))
  · intro k
    exact local_pullback read (R k) (terms k) (hsupp k)

/-- Exact Route 1 instantiation on decoded independent-block coordinates.
The law is arbitrary with the *explicit* Wyner-information assumption;
the B-independent quantitative specialization follows for product laws
once their Wyner information is shown zero. Nothing here asserts such a
zero without proof.

Each logical tree query is a hidden-block query; realizing it using
the four allowed 2D intensity rows costs three physical queries
per first-visited block, with caching on repeated accesses. -/
theorem route1_for_phase_encoded_raw_terms
    (read : S → J → V)
    (terms : K → ((B × J) → V) → ℝ)
    (R : K → Finset (B × J))
    (d : ℕ)
    (hsupp : ∀ k, RawSupportedOn (R k) (terms k))
    (hsize : ∀ k, (R k).card ≤ d)
    (ν : (B → S) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (hf01 : ∀ x, 0 ≤ (∑ k, terms k (encode read x)) ∧
                         (∑ k, terms k (encode read x)) ≤ 1)
    (hd : 1 ≤ d)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree B S, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x *
        (if ε < |(∑ k, terms k (encode read x)) - t.eval x|
         then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          s / (etaC d τ ^ 2 * w0C
            (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n + τ / ε ^ 2 := by
  exact route1_wyner_general ν hν0 hν1
    (fun x => ∑ k, terms k (encode read x)) hf01 d hd
    (pulled_raw_terms_have_degree read terms R d hsupp hsize)
    τ hτ hτ1 ε hε n hn s hs

#print axioms Nightfall.PhaseBlockRoute1.pulled_raw_terms_have_degree
#print axioms Nightfall.PhaseBlockRoute1.route1_for_phase_encoded_raw_terms

end Nightfall.PhaseBlockRoute1
