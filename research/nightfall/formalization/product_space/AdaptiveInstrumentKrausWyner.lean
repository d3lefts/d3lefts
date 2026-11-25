import AdaptiveInstrumentWyner
import AdaptiveInstrumentKraus

/-! General-latent Wyner terminal for finite complex Kraus history trees.
The probability is the unnormalized sum of actual squared branch amplitudes.
No hypothesis of degree or acceptance range is supplied to the terminal. -/

namespace Nightfall.KrausAdaptive

open Finset
open Nightfall.AdaptiveInstrument
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.Route1Polylog
open Nightfall.QuantumCircuitNormalization

variable {ι α κ β γ : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
  [Fintype κ] [Fintype β] [Fintype γ]

theorem kraus_indicator_degree {T : ℕ} (P : Tree ι α κ β T)
    (v : γ → κ → ℂ) :
    HasProdDegreeLE (ensembleAccept P v) (2 * T) :=
  degree_to_indicator reference reference_sum (ensemble_degree P v)

theorem kraus_route1_wyner
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (T : ℕ) (hT : 1 ≤ T) (P : Tree ι α κ β T)
    (hvalid : Valid P) (v : γ → κ → ℂ) (hnorm : ∑ c, energy (v c) = 1)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε) (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |ensembleAccept P v x - t.eval x| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) / (2 * gam (2 * T) τ) +
        s / (etaC (2 * T) τ ^ 2 *
          w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) (2 * T) τ)) / n + τ / ε ^ 2 := by
  exact route1_wyner_general ν hν0 hν1 (ensembleAccept P v)
    (ensemble_range P hvalid v hnorm) (2 * T) (by omega)
    (kraus_indicator_degree P v) τ hτ hτ1 ε hε n hn s hs

end Nightfall.KrausAdaptive

#print axioms Nightfall.KrausAdaptive.kraus_indicator_degree
#print axioms Nightfall.KrausAdaptive.kraus_route1_wyner
