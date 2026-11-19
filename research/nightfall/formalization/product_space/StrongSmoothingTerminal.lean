import StrongSmoothingUniform
import StrongSmoothingBase

/-!
# Explicit strong event smoother: complete algebraic tail certificate

The base k = floor(2/(5 ε²)) is certified in StrongSmoothingBase.
The cubic-amplifier polynomial and degree bounds are imported from
StrongSmoothingUniform and StrongSmoothingPolynomial.

Unlike the original binomial/Hoeffding approximator, this is a *different*
polynomial with elementary proofs for its two tails. For 0 < ε ≤ 1/2,
|z| ≤ 1 and any natural n:

* if |z| ≤ ε, 3 * smoothPoly(k,n)(z) ≤ (3/4)^(2^n);
* if |z| ≥ 2 ε, 3 * (1-smoothPoly(k,n)(z)) ≤ (3/4)^(2^n);
* 0 ≤ smoothPoly(k,n)(z) ≤ 1;
* polynomial degree ≤ 2*k*3^(n+3).

The η-form bounds require the explicit numerical parameter budget
(3/4)^(2^n) ≤ 3 η. The existence/complexity of a suitable n,
quantum oracle transfer, and mixture theorem are separate gates.
-/

namespace Nightfall.StrongSimulation.SmoothingTerminal

open Nightfall.StrongSmoothing
open Nightfall.StrongSimulation.SmoothingBase

noncomputable def eventPoly (ε : ℝ) (n : ℕ) : Polynomial ℝ :=
  smoothPoly (thresholdCount ε) n

theorem eventPoly_eval (ε z : ℝ) (n : ℕ) :
    (eventPoly ε n).eval z =
      amp (n + 3) (base (thresholdCount ε) z) := by
  change (smoothPoly (thresholdCount ε) n).eval z =
    amp (n + 3) (base (thresholdCount ε) z)
  rw [smoothPoly_eval]
  rfl

theorem eventPoly_degree (ε : ℝ) (n : ℕ) :
    (eventPoly ε n).natDegree ≤
      2 * thresholdCount ε * 3 ^ (n + 3) := by
  exact smoothPoly_natDegree_le (thresholdCount ε) n

theorem eventPoly_mem_unit (ε z : ℝ) (n : ℕ)
    (hz : |z| ≤ 1) :
    0 ≤ (eventPoly ε n).eval z ∧
      (eventPoly ε n).eval z ≤ 1 := by
  exact smoothPoly_mem_unit (thresholdCount ε) n hz

theorem eventPoly_tails (ε z : ℝ) (n : ℕ)
    (hε : 0 < ε) (hεmax : ε ≤ 1 / 2)
    (hz : |z| ≤ 1) :
    (|z| ≤ ε →
      3 * (eventPoly ε n).eval z ≤ (3 / 4 : ℝ) ^ (2 ^ n)) ∧
    (2 * ε ≤ |z| →
      3 * (1 - (eventPoly ε n).eval z) ≤ (3 / 4 : ℝ) ^ (2 ^ n)) := by
  have hb := base_separator ε z hε hεmax hz
  have hmem := baseValue_mem_unit (thresholdCount ε) hz
  have hbeq : baseValue (thresholdCount ε) z =
      base (thresholdCount ε) z := rfl
  constructor
  · intro hsmall
    rw [eventPoly_eval]
    exact amp_low_tail n hmem.1 (by simpa [← hbeq] using hb.1 hsmall)
  · intro hlarge
    rw [eventPoly_eval]
    exact amp_high_tail n (by simpa [← hbeq] using hb.2 hlarge) hmem.2

/-- The event polynomial satisfies both desired strong-simulation
threshold inequalities, provided n has the explicit scalar budget.
No Hoeffding or Bernstein lemma appears in the hypotheses. -/
theorem eventPoly_failure_bounds
    (ε η z : ℝ) (n : ℕ)
    (hε : 0 < ε) (hεmax : ε ≤ 1 / 2)
    (hz : |z| ≤ 1)
    (hbudget : (3 / 4 : ℝ) ^ (2 ^ n) ≤ 3 * η) :
    (|z| ≤ ε → (eventPoly ε n).eval z ≤ η) ∧
    (2 * ε ≤ |z| → 1 - η ≤ (eventPoly ε n).eval z) := by
  obtain ⟨hsmall, hlarge⟩ := eventPoly_tails ε z n hε hεmax hz
  constructor
  · intro hzsmall
    have h := hsmall hzsmall
    linarith
  · intro hzlarge
    have h := hlarge hzlarge
    linarith

end Nightfall.StrongSimulation.SmoothingTerminal
