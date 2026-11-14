import ActualProductSourcePairCentering

/-!
# Source-attained categorical pair amplitudes (legacy PR #430 port)

Finite categorical pair kernels derived from the original input f admit
actual attained maximal amplitudes, with no supplied edge weights. The
source table is defined by literal original finite-product averaging,
including zero-mass atoms. This module does not yet prove the
matching-amplitude 4B inequality or total endpoint cost 8B.
-/

namespace Nightfall.Observability.ActualSourcePairAmplitudes

open Finset
open Nightfall.Observability.ActualProductSourcePairCentering

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem source_pair_amplitude_max_attained
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) :
    ∃ ab : α × α, ∀ cd : α × α,
      |sourceDoubleCenteredPair p f i j cd.1 cd.2| ≤
      |sourceDoubleCenteredPair p f i j ab.1 ab.2| := by
  classical
  let weight : α × α → ℝ := fun ab =>
    |sourceDoubleCenteredPair p f i j ab.1 ab.2|
  obtain ⟨ab, _, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (α × α))
      weight (by simp : (Finset.univ : Finset (α × α)).Nonempty)
  exact ⟨ab, fun cd => hmax cd (Finset.mem_univ cd)⟩

noncomputable def pairAmplitudeMax
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) : α × α :=
  Classical.choose (source_pair_amplitude_max_attained p f i j)

noncomputable def pairAmplitudeWeight
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) : ℝ :=
  |sourceDoubleCenteredPair p f i j
    (pairAmplitudeMax p f i j).1
    (pairAmplitudeMax p f i j).2|

theorem pairAmplitudeWeight_nonneg
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i j : ι) :
    0 ≤ pairAmplitudeWeight p f i j :=
  abs_nonneg _

theorem source_pair_amplitude_dominated
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) (a b : α) :
    |sourceDoubleCenteredPair p f i j a b| ≤
      pairAmplitudeWeight p f i j := by
  unfold pairAmplitudeWeight pairAmplitudeMax
  exact (Classical.choose_spec
    (source_pair_amplitude_max_attained p f i j)) (a,b)

end Nightfall.Observability.ActualSourcePairAmplitudes
