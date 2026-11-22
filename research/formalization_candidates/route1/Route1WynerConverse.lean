import Route1WynerGeneral
import Route1DensityDomination

/-!
# NIGHTFALL Route 1 / Wyner quantitative converse

Uses the actual distributional high-probability acceptance-polynomial
simulation theorem, without replacing it with a promise-task lower bound.

This proves the exact numeric lower bound on Wyner common information from
the explicit premise that *every depth-n deterministic decision tree*
has excessive distributional approximation error. It does not pretend
that a classical Forrelation distinction theorem directly has that type.
The external discrimination-to-approximation lemma is separate.

The constants and strict bad-event convention are verbatim those of
the merged Route1WynerGeneral.lean source. Only standard axioms allowed.
-/

namespace Nightfall.Route1Polylog

open Finset
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Quantitative converse of the merged Wyner-general simulation theorem.

If no deterministic tree of worst-case depth ≤n approximates f with
Pr(|f-t|>ε) ≤δ, then the common information must be large.
The conclusion is exact, with no big-O and no hidden promise/error
conversion. This remains valid when the right-hand side is negative. -/
theorem wyner_converse_from_approximation_hardness
    (ν : (ι → α) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ)
    (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) (δ : ℝ)
    (hhard : ∀ t : DTree ι α,
      (∀ x, t.queries x ≤ n) →
        δ < ∑ x, ν x *
          (if ε < |f x - t.eval x| then (1 : ℝ) else 0)) :
    (etaC d τ ^ 2 * w0C
        (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ) *
      ((n : ℝ) * (δ - τ / ε ^ 2) -
        (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ)) ≤
      wynerGen ν := by
  let K : ℝ := Real.pi ^ 2 * (d : ℝ) ^ 2 / 2
  let A : ℝ := K / (2 * gam d τ)
  let B : ℝ := etaC d τ ^ 2 * w0C K d τ
  have hdpos : (0 : ℝ) < (d : ℝ) := by
    exact_mod_cast (lt_of_lt_of_le (by decide : (0 : ℕ) < 1) hd)
  have hgpos : 0 < gam d τ := gam_pos d τ hτ
  have hK : 0 < K := by dsimp [K]; positivity
  have heta : 0 < etaC d τ := by unfold etaC; positivity
  have hw0 : 0 < w0C K d τ := by unfold w0C; positivity
  have hB : 0 < B := by dsimp [B]; positivity
  have hnreal : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hs (s : ℝ) (hsi : wynerGen ν < s) :
      B * ((n : ℝ) * (δ - τ / ε ^ 2) - A) < s := by
    obtain ⟨t, hdepth, herr⟩ :=
      route1_wyner_general ν hν0 hν1 f hf01 d hd hdeg
        τ hτ hτ1 ε hε n hn s hsi
    have hhard_t := hhard t hdepth
    have hupper : δ < (A + s / B) / (n : ℝ) + τ / ε ^ 2 := by
      have h := lt_of_lt_of_le hhard_t herr
      change δ < (A + s / B) / (n : ℝ) + τ / ε ^ 2 at h
      exact h
    have hstep : δ - τ / ε ^ 2 <
        (A + s / B) / (n : ℝ) := by linarith
    have hmul := (lt_div_iff₀ hnreal).mp hstep
    have hstep2 : (n : ℝ) * (δ - τ / ε ^ 2) - A < s / B := by
      nlinarith
    have hmul2 := (lt_div_iff₀ hB).mp hstep2
    nlinarith
  have hlimit :
      B * ((n : ℝ) * (δ - τ / ε ^ 2) - A) ≤ wynerGen ν := by
    by_contra hnot
    have hstrict : wynerGen ν <
        B * ((n : ℝ) * (δ - τ / ε ^ 2) - A) :=
      lt_of_not_ge hnot
    let s : ℝ := (wynerGen ν +
      B * ((n : ℝ) * (δ - τ / ε ^ 2) - A)) / 2
    have hleft : wynerGen ν < s := by dsimp [s]; linarith
    have hright :
        s < B * ((n : ℝ) * (δ - τ / ε ^ 2) - A) := by
      dsimp [s]
      linarith
    have hc := hs s hleft
    linarith
  simpa only [B, A, K] using hlimit


/-- Exact finite-law transfer of the *actual merged* Route1 simulator:
    if ν is pointwise dominated by R Q, every Q-guarantee is inherited
    by ν with its error-probability bound multiplied by R.

    The theorem does not assume Q has any particular mixture shape:
    callers can supply the separate existing Wyner-CI premise for Q.
    Its depth bound is unchanged, and it does not claim grouped-coordinate
    oracle semantics (that is a later formalization obligation). -/
theorem route1_wyner_dominated
    (ν Q : (ι → α) → ℝ)
    (hQ0 : ∀ x, 0 ≤ Q x) (hQ1 : ∑ x, Q x = 1)
    (R : ℝ) (hR : 0 ≤ R)
    (hdom : ∀ x, ν x ≤ R * Q x)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen Q < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      (∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0)) ≤
        R * (((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          s / (etaC d τ ^ 2 * w0C
            (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n +
          τ / ε ^ 2) := by
  obtain ⟨t, htq, herr⟩ := route1_wyner_general Q hQ0 hQ1
    f hf01 d hd hdeg τ hτ hτ1 ε hε n hn s hs
  refine ⟨t, htq, ?_⟩
  have hchange :=
    Nightfall.Route1DensityDomination.event_probability_dominated
      ν Q R hdom (fun x => ε < |f x - t.eval x|)
  exact hchange.trans (mul_le_mul_of_nonneg_left herr hR)

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.wyner_converse_from_approximation_hardness
#print axioms Nightfall.Route1Polylog.route1_wyner_dominated
