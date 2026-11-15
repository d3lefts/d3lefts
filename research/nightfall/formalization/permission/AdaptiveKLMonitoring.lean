import Mathlib.InformationTheory.KullbackLeibler.DataProcessing
import Mathlib.InformationTheory.KullbackLeibler.ChainRule
import Mathlib.Probability.Kernel.Composition.MeasureCompProd

/-!
# NIGHTFALL — adaptive KL evidence-cost lower bound, finite horizon

Prior art: Kaufmann, Cappe, Garivier (JMLR 2016), Lemma 1;
Garivier and Kaufmann (COLT 2016). This is a mechanization and
application of classical sequential change-of-measure, not a novel theorem.

Arbitrary finite-horizon adaptive monitors are represented by two chains of
probability measures on a shared history/state space H, with time-dependent
world-specific Markov observation kernels. The same world-independent
history update rule is applied in both worlds. The state can include
monitor selection, previous observations, and a terminated/absorbing flag.
An arbitrary measurable final authorization decision is post-processing.

Each stage's conditional channel divergence is bounded by rate times the
stage's expected evidence cost. That premise is explicit: this module does
not infer it from unspecified or post-hoc monitor scores. The proof uses
Mathlib's KL chain rule and data-processing inequality, with no axioms beyond
the ordinary standard proof axioms.

The present bound is finite-horizon, and does not on its own prove
almost-surely-finite *unbounded* stopping-time or real deployment assertions.
-/

namespace Nightfall.PricePermission.AdaptiveKL

open MeasureTheory ProbabilityTheory InformationTheory Finset

variable {H : Type*} [MeasurableSpace H]

/-- One adaptive monitoring round: chain rule for the joint observation,
followed by information loss through any common measurable history update. -/
theorem adaptive_one_round_kl
    (safe unsafeWorld : Measure H)
    [IsFiniteMeasure safe] [IsFiniteMeasure unsafeWorld]
    (κ η : Kernel H H)
    [IsMarkovKernel κ] [IsMarkovKernel η]
    (update : H × H → H) (hupdate : Measurable update) :
    klDiv ((safe.compProd κ).map update) ((unsafeWorld.compProd η).map update) ≤
      klDiv safe unsafeWorld + klDiv (safe.compProd κ) (safe.compProd η) := by
  calc
    klDiv ((safe.compProd κ).map update) ((unsafeWorld.compProd η).map update) ≤
        klDiv (safe.compProd κ) (unsafeWorld.compProd η) :=
      klDiv_map_le _ _ hupdate
    _ = klDiv safe unsafeWorld + klDiv (safe.compProd κ) (safe.compProd η) :=
      klDiv_compProd_eq_add safe unsafeWorld κ η

/-- **General finite-horizon adaptive information-cost bound.**

The two worlds share their initial history distribution. Each step may
select an arbitrary stochastic monitor based on all previous observations:
that selection is absorbed into the state-dependent Markov kernels.
Worlds share an update function, so monitor choices cannot reveal the hidden
world except through observed evidence. `budget t` bounds the conditional
expected information acquired at round t. This theorem derives the total
decision KL budget by induction; it does not assume any global transcript
KL bound. The optional absorbing stop flag is part of H. -/
theorem finite_horizon_adaptive_kl_cost
    (safe unsafeWorld : ℕ → Measure H)
    [∀ t, IsFiniteMeasure (safe t)] [∀ t, IsFiniteMeasure (unsafeWorld t)]
    (κ η : ℕ → Kernel H H)
    [∀ t, IsMarkovKernel (κ t)] [∀ t, IsMarkovKernel (η t)]
    (update : ℕ → H × H → H) (hupdate : ∀ t, Measurable (update t))
    (hs : ∀ t, safe (t+1) = ((safe t).compProd (κ t)).map (update t))
    (hu : ∀ t, unsafeWorld (t+1) = ((unsafeWorld t).compProd (η t)).map (update t))
    (hinitial : safe 0 = unsafeWorld 0)
    (rate : ENNReal) (cost : ℕ → ENNReal)
    (hchannel : ∀ t, klDiv ((safe t).compProd (κ t))
        ((safe t).compProd (η t)) ≤ rate * cost t)
    (n : ℕ) (permit : H → Bool) (hpermit : Measurable permit) :
    klDiv ((safe n).map permit) ((unsafeWorld n).map permit) ≤
      rate * (∑ t ∈ Finset.range n, cost t) := by
  have htotal : ∀ k : ℕ,
      klDiv (safe k) (unsafeWorld k) ≤ rate * (∑ t ∈ Finset.range k, cost t) := by
    intro k
    induction k with
    | zero =>
      simp [hinitial]
    | succ k hk =>
      calc
        klDiv (safe (k+1)) (unsafeWorld (k+1)) ≤
            klDiv (safe k) (unsafeWorld k) +
              klDiv ((safe k).compProd (κ k))
                    ((safe k).compProd (η k)) := by
          rw [hs k, hu k]
          exact adaptive_one_round_kl (safe k) (unsafeWorld k)
            (κ k) (η k) (update k) (hupdate k)
        _ ≤ rate * (∑ t ∈ Finset.range k, cost t) + rate * cost k :=
          add_le_add hk (hchannel k)
        _ = rate * (∑ t ∈ Finset.range (k+1), cost t) := by
          rw [Finset.sum_range_succ, mul_add]
  calc
    klDiv ((safe n).map permit) ((unsafeWorld n).map permit) ≤
        klDiv (safe n) (unsafeWorld n) := klDiv_map_le _ _ hpermit
    _ ≤ rate * (∑ t ∈ Finset.range n, cost t) := htotal n

end Nightfall.PricePermission.AdaptiveKL
