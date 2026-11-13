import ActualESOwnedSectionEnergy
import ActualESOwnedInfluenceBound

/-!
# True source owner-section energy is dominated by actual pinfl_i

This is the direct composition of two fully source-defined identities:

1. Genuine original-product conditional Hilbert section energy equals
   the canonical pair-energy mass greedily assigned to coordinate i.
2. Canonical assigned pair energies are a nonnegative subcollection
   of the true Efron–Stein influence energy of f in coordinate i.

No energy cap, variance, source-row estimate, independent sample table,
or asserted quadratic-influence inequality is a theorem hypothesis.

The exact conclusion is the previously missing s_i <= I_i(f)
bridge. Strict Lean compilation and axiom audit are required before
it is a certified component.
-/

namespace Nightfall.Observability.ActualESOwnedSectionCap

open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESOwnedSectionEnergy
open Nightfall.Observability.ActualESOwnedInfluenceBound

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The actual greedily owned conditional-section energy s_i is bounded
by the actual source coordinate influence. Both are computed from f.
No energy premise is present. -/
theorem actual_owned_section_energy_le_source_influence
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (c : ι → ℝ) (i : ι) :
    actualOwnedSectionEnergy p f c i ≤ pinfl p f i := by
  calc
    actualOwnedSectionEnergy p f c i =
      Nightfall.Observability.ActualESOwnedEnergy.ownedSourceEnergy
        p f base
        Nightfall.Observability.ActualESCanonicalPairGraph.first
        Nightfall.Observability.ActualESCanonicalPairGraph.second c
        (Finset.univ : Finset
          (Nightfall.Observability.ActualESCanonicalPairGraph.Edge ι)) i :=
            actual_owned_section_energy_eq_source_pair_energy
              p hp1 f base c i
    _ ≤ pinfl p f i :=
      canonical_owned_pair_energy_le_actual_influence
        p hp hp1 f hdegree base c i

end Nightfall.Observability.ActualESOwnedSectionCap
