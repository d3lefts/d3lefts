import Mathlib
import StrongMixtureDuel
import LatentLikelihoodRatio

/-!
# CONDITIONAL terminal: finite latent-mixture probability composition

This is a named kernel theorem, not an unconditional quantum-simulation
terminal. The explicitly quantified inputs are:
 * per-component product simulator estimates T_j, and proven error ≤ rho;
 * a frozen pairwise-duel failure predicate and proven error ≤ beta;
 * the deterministic tournament implication that a good estimate and no lost
   true-component duel guarantee output accuracy ≤ 5 epsilon.

The theorem then proves the **actual mixture failure event** has probability
≤rho+beta, with no assumption that the final output succeeds.

The *quantum oracle pullback, BDST uniform simulator, bias-free rounding,
and genuine likelihood-test construction* are not supplied by this theorem;
they remain independent prerequisites for instantiating hproduct/hduel.
No hidden axiom, sorry, or parameter treated as a completed construction.
-/

namespace Nightfall.StrongMixtureTerminal

open Finset
open Classical

variable {ι Ω : Type*} [Fintype ι] [Fintype Ω]

/-- A concrete failure-event indicator on a finite sample space. -/
noncomputable def failIndicator (f a : Ω → ℝ) (ε : ℝ) (x : Ω) : ℝ :=
  if ε < |f x - a x| then 1 else 0

/-- A true-component good estimate and no lost true-component duel imply
that final failure is covered by the union of the two predecessor events. -/
theorem final_bad_le_source_bad_add_duel
    (f : Ω → ℝ) (estimate : ι → Ω → ℝ) (select : Ω → ι)
    (duelLost : ι → Ω → Prop) (θ : ι) (x : Ω) (ε : ℝ)
    (hgood : |f x - estimate θ x| ≤ ε →
      ¬duelLost θ x →
      |f x - estimate (select x) x| ≤ 5 * ε) :
    failIndicator f (fun y => estimate (select y) y) (5 * ε) x ≤
      failIndicator f (estimate θ) ε x +
        (if duelLost θ x then (1 : ℝ) else 0) := by
  classical
  unfold failIndicator
  by_cases hbad : 5 * ε < |f x - estimate (select x) x|
  · by_cases hs : ε < |f x - estimate θ x|
    · simp [hbad, hs]
    · have hd : duelLost θ x := by
        by_contra hnd
        have hg := hgood (le_of_not_gt hs) hnd
        exact (not_lt_of_ge hg) hbad
      simp [hbad, hs, hd]
  · simp [hbad]

/-- Main final terminal: under the explicit product-source and pairwise
duel error certificates, the mixture failure event at tolerance 5ε is
at most rho + beta. No error of the *final* output is assumed. -/
theorem strong_latent_mixture_terminal_conditional
    (π : ι → ℝ) (p : ι → Ω → ℝ)
    (f : Ω → ℝ) (estimate : ι → Ω → ℝ)
    (select : Ω → ι) (duelLost : ι → Ω → Prop)
    (ε rho beta : ℝ)
    (hπ0 : ∀ j, 0 ≤ π j)
    (hπ1 : (∑ j : ι, π j) = 1)
    (hp : ∀ j x, 0 ≤ p j x)
    (hproduct : ∀ j, (∑ x : Ω,
      p j x * failIndicator f (estimate j) ε x) ≤ rho)
    (hduel : ∀ j, (∑ x : Ω,
      p j x * (if duelLost j x then (1 : ℝ) else 0)) ≤ beta)
    (hgood : ∀ j x,
      |f x - estimate j x| ≤ ε → ¬duelLost j x →
        |f x - estimate (select x) x| ≤ 5 * ε) :
    (∑ j : ι, π j * (∑ x : Ω,
      p j x * failIndicator f
        (fun y => estimate (select y) y) (5 * ε) x)) ≤ rho + beta := by
  classical
  have hsingle : ∀ j : ι,
      (∑ x : Ω, p j x * failIndicator f
        (fun y => estimate (select y) y) (5 * ε) x) ≤ rho + beta := by
    intro j
    have hb : (∑ x : Ω, p j x * failIndicator f
        (fun y => estimate (select y) y) (5 * ε) x) ≤
      (∑ x : Ω, p j x * failIndicator f (estimate j) ε x) +
      (∑ x : Ω, p j x *
        (if duelLost j x then (1 : ℝ) else 0)) := by
      calc
        (∑ x : Ω, p j x * failIndicator f
          (fun y => estimate (select y) y) (5 * ε) x) ≤
          ∑ x : Ω, p j x * (failIndicator f (estimate j) ε x +
            (if duelLost j x then (1 : ℝ) else 0)) := by
            apply Finset.sum_le_sum
            intro x hx
            exact mul_le_mul_of_nonneg_left
              (final_bad_le_source_bad_add_duel f estimate select
                duelLost j x ε (hgood j x)) (hp j x)
        _ = (∑ x : Ω, p j x * failIndicator f (estimate j) ε x) +
          (∑ x : Ω, p j x *
            (if duelLost j x then (1 : ℝ) else 0)) := by
              simp only [mul_add, Finset.sum_add_distrib]
    linarith [hproduct j, hduel j]
  calc
    (∑ j : ι, π j * (∑ x : Ω,
      p j x * failIndicator f
        (fun y => estimate (select y) y) (5 * ε) x)) ≤
        ∑ j : ι, π j * (rho + beta) := by
          apply Finset.sum_le_sum
          intro j hj
          exact mul_le_mul_of_nonneg_left (hsingle j) (hπ0 j)
    _ = rho + beta := by
          rw [← Finset.sum_mul, hπ1, one_mul]

end Nightfall.StrongMixtureTerminal
