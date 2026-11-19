import Mathlib
import StrongMixtureTerminalConditional

/-!
# Concrete pairwise tournament: discharging `hgood` and `hduel`

`StrongMixtureTerminal.strong_latent_mixture_terminal_conditional` takes the
tournament's correctness implication (`hgood`) and the per-component duel-loss
budget (`hduel`) as hypotheses. This file builds the actual tournament and
proves both:

* candidate values `a j x` (the per-component simulator outputs);
* a duel between `j` and `k` happens exactly when `4ε ≤ |a j x - a k x|`;
* each duel's outcome `winner j k x` is symmetric in `j, k`. The proof does not
  even need the winner to be one of the two players;
* `select x` is any undefeated candidate (an arbitrary default if none exists).

`tournament_good` proves `hgood` outright. `duel_loss_le_sum_pairs` turns
per-pair loss budgets into the per-component `hduel` budget by a union bound.
`strong_latent_mixture_terminal_tournament` is the terminal with `hgood`
discharged. Its only remaining inputs are the per-component product simulator
error and the per-pair duel errors.
-/

namespace Nightfall.StrongMixtureTournament

open Finset Classical
open Nightfall.StrongMixtureTerminal

variable {ι Ω : Type*} [Fintype ι] [Fintype Ω]

/-- `j` and `k` are separated at `x`, so they duel. -/
def separated (a : ι → Ω → ℝ) (ε : ℝ) (j k : ι) (x : Ω) : Prop :=
  4 * ε ≤ |a j x - a k x|

/-- `j` lost some duel at `x`. -/
def lost (a : ι → Ω → ℝ) (ε : ℝ) (winner : ι → ι → Ω → ι) (j : ι) (x : Ω) : Prop :=
  ∃ k, separated a ε j k x ∧ winner j k x ≠ j

/-- Select an undefeated candidate if one exists, otherwise `default0`. -/
noncomputable def select (a : ι → Ω → ℝ) (ε : ℝ) (winner : ι → ι → Ω → ι)
    (default0 : ι) (x : Ω) : ι :=
  if h : ∃ j, ¬ lost a ε winner j x then Classical.choose h else default0

theorem select_undefeated (a : ι → Ω → ℝ) (ε : ℝ) (winner : ι → ι → Ω → ι)
    (default0 : ι) (x : Ω) (h : ∃ j, ¬ lost a ε winner j x) :
    ¬ lost a ε winner (select a ε winner default0 x) x := by
  unfold select
  rw [dite_cond_eq_true (eq_true h)]
  exact Classical.choose_spec h

/-- **Tournament correctness (`hgood`).** If the true component's candidate is
ε-accurate and the true component lost no duel, the selected output is
5ε-accurate. -/
theorem tournament_good (a : ι → Ω → ℝ) (ε : ℝ) (winner : ι → ι → Ω → ι)
    (default0 : ι)
    (hε : 0 < ε)
    (hsymm : ∀ j k x, winner j k x = winner k j x)
    (f : Ω → ℝ) (θ : ι) (x : Ω)
    (htrue : |f x - a θ x| ≤ ε)
    (hnl : ¬ lost a ε winner θ x) :
    |f x - a (select a ε winner default0 x) x| ≤ 5 * ε := by
  set j := select a ε winner default0 x with hj
  have hju : ¬ lost a ε winner j x :=
    select_undefeated a ε winner default0 x ⟨θ, hnl⟩
  have hgap : |a θ x - a j x| ≤ 4 * ε := by
    by_contra hcon
    push_neg at hcon
    have hsep_jθ : separated a ε j θ x := by
      unfold separated; rw [abs_sub_comm]; exact le_of_lt hcon
    have hsep_θj : separated a ε θ j x := by
      unfold separated; exact le_of_lt hcon
    -- j undefeated, so j wins against θ
    have hj_wins : winner j θ x = j := by
      by_contra hne; exact hju ⟨θ, hsep_jθ, hne⟩
    -- θ undefeated, so θ wins against j
    have hθ_wins : winner θ j x = θ := by
      by_contra hne; exact hnl ⟨j, hsep_θj, hne⟩
    have hjθ : j = θ := by rw [← hj_wins, hsymm j θ x, hθ_wins]
    rw [hjθ, sub_self, abs_zero] at hcon
    linarith
  exact Nightfall.StrongMixtureDuel.five_epsilon_from_agreement
    (fun i => a i x) θ j (f x) ε htrue hgap

/-- **Union bound for `hduel`.** Per-pair loss budgets give the
per-component loss budget. -/
theorem duel_loss_le_sum_pairs [DecidableEq ι]
    (a : ι → Ω → ℝ) (ε : ℝ) (winner : ι → ι → Ω → ι)
    (p : ι → Ω → ℝ) (hp : ∀ j x, 0 ≤ p j x)
    (beta : ι → ι → ℝ)
    (hpair : ∀ j k, (∑ x : Ω, p j x *
        (if separated a ε j k x ∧ winner j k x ≠ j then (1 : ℝ) else 0)) ≤ beta j k)
    (j : ι) :
    (∑ x : Ω, p j x * (if lost a ε winner j x then (1 : ℝ) else 0)) ≤
      ∑ k : ι, beta j k := by
  have hpt : ∀ x, p j x * (if lost a ε winner j x then (1 : ℝ) else 0) ≤
      ∑ k : ι, p j x *
        (if separated a ε j k x ∧ winner j k x ≠ j then (1 : ℝ) else 0) := by
    intro x
    by_cases hl : lost a ε winner j x
    · obtain ⟨k, hk⟩ := hl
      rw [if_pos ⟨k, hk⟩, mul_one]
      have hterm : p j x * (if separated a ε j k x ∧ winner j k x ≠ j
          then (1 : ℝ) else 0) = p j x := by rw [if_pos hk, mul_one]
      calc p j x = p j x * (if separated a ε j k x ∧ winner j k x ≠ j
            then (1 : ℝ) else 0) := hterm.symm
        _ ≤ ∑ k' : ι, p j x * (if separated a ε j k' x ∧ winner j k' x ≠ j
            then (1 : ℝ) else 0) := by
          apply Finset.single_le_sum (f := fun k' => p j x *
            (if separated a ε j k' x ∧ winner j k' x ≠ j then (1 : ℝ) else 0))
            (fun k' _ => mul_nonneg (hp j x) (by split_ifs <;> norm_num))
            (Finset.mem_univ k)
    · rw [if_neg hl, mul_zero]
      exact Finset.sum_nonneg (fun k _ => mul_nonneg (hp j x)
        (by split_ifs <;> norm_num))
  calc (∑ x : Ω, p j x * (if lost a ε winner j x then (1 : ℝ) else 0))
      ≤ ∑ x : Ω, ∑ k : ι, p j x *
          (if separated a ε j k x ∧ winner j k x ≠ j then (1 : ℝ) else 0) :=
        Finset.sum_le_sum (fun x _ => hpt x)
    _ = ∑ k : ι, ∑ x : Ω, p j x *
          (if separated a ε j k x ∧ winner j k x ≠ j then (1 : ℝ) else 0) :=
        Finset.sum_comm
    _ ≤ ∑ k : ι, beta j k := Finset.sum_le_sum (fun k _ => hpair j k)

/-- **Terminal with the tournament built in.** The remaining inputs are the
per-component simulator error `rho` and the per-pair duel errors `beta j k`.
The mixture failure mass at tolerance 5ε is at most `rho + max_j Σ_k beta j k`,
stated here with a uniform bound `B` on `Σ_k beta j k`. -/
theorem strong_latent_mixture_terminal_tournament [DecidableEq ι]
    (π : ι → ℝ) (p : ι → Ω → ℝ) (f : Ω → ℝ) (a : ι → Ω → ℝ)
    (winner : ι → ι → Ω → ι) (default0 : ι)
    (ε rho B : ℝ) (beta : ι → ι → ℝ)
    (hε : 0 < ε)
    (hsymm : ∀ j k x, winner j k x = winner k j x)
    (hπ0 : ∀ j, 0 ≤ π j) (hπ1 : (∑ j : ι, π j) = 1)
    (hp : ∀ j x, 0 ≤ p j x)
    (hproduct : ∀ j, (∑ x : Ω, p j x * failIndicator f (a j) ε x) ≤ rho)
    (hpair : ∀ j k, (∑ x : Ω, p j x *
        (if separated a ε j k x ∧ winner j k x ≠ j then (1 : ℝ) else 0)) ≤ beta j k)
    (hB : ∀ j, (∑ k : ι, beta j k) ≤ B) :
    (∑ j : ι, π j * (∑ x : Ω, p j x * failIndicator f
        (fun y => a (select a ε winner default0 y) y) (5 * ε) x)) ≤ rho + B :=
  strong_latent_mixture_terminal_conditional π p f a
    (select a ε winner default0) (lost a ε winner) ε rho B
    hπ0 hπ1 hp hproduct
    (fun j => (duel_loss_le_sum_pairs a ε winner p hp beta hpair j).trans (hB j))
    (fun j x htrue hnl =>
      tournament_good a ε winner default0 hε hsymm f j x htrue hnl)

end Nightfall.StrongMixtureTournament
