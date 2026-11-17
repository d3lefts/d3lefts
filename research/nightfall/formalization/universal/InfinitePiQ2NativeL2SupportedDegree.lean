import InfinitePiQ2PositiveAtomL2Zero
import InfinitePiQ2TripleResidualDegree
import InfinitePiQ2NativeSupportedTerminal

/-!
# Exact original-source native L² triple degree to positive support degree

The genuine source label table's Hilbert L² degree-two identity gives
ZERO WEIGHTED native residual energy, not global pointwise zero on null
label words. This module composes:
1. the exact native finite original-product positive-atom L²-to-Δ³
   implication from PR #742;
2. the exact weighted heat-bath/mixed third-difference identity from
   PR #738;
3. the native positive-support degree predicate and finite C105.416
   terminal from merged PR #740.

Thus no pointwise extension witness, atom floor or wrong-source label
value is required. It does not construct the source-to-finite-label
projection itself, and is not the unconditional infinite Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2NativeL2SupportedDegree

open Finset
open Nightfall.InfinitePiQ2PositiveAtomL2Zero
open Nightfall.InfinitePiQ2TripleResidualDegree
open Nightfall.InfinitePiQ2NativeSupportedTerminal
open Nightfall.InfinitePiQ2DegreeRetraction

universe u v
variable {ι : Type u} [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (A : ι → Type v) [∀ i, Fintype (A i)] [∀ i, Nonempty (A i)]

/-- Full exact finite native source L² degree-two → native positive
support pointwise degree-two. This theorem does not assume any global
pointwise vanishing at null table entries. -/
theorem native_L2_triple_zero_implies_native_supported_degree_two
    (p : (i : ι) → A i → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (f : ((i : ι) → A i) → ℝ)
    (htriple : ∀ (i j k : ι), i ≠ j → i ≠ k → j ≠ k →
       (∑ x : (i : ι) → A i,
           nativeMass p x *
           (nativeResidual p i
             (nativeResidual p j
               (nativeResidual p k f)) x)^2) = 0) :
    NativeSupportedDegreeTwo A p f := by
  intro i j k hij hik hjk a a' b b' c c' x hx ha ha' hb hb' hc hc'
  have hz :
      delta i a a' (delta j b b' (delta k c c'
        (nativeResidual p i
          (nativeResidual p j (nativeResidual p k f))))) x = 0 :=
    native_L2_zero_implies_supported_mixed_third_zero p hp
      (nativeResidual p i
        (nativeResidual p j (nativeResidual p k f)))
      (htriple i j k hij hik hjk)
      i j k a a' b b' c c' x hx ha ha' hb hb' hc hc'
  have heq := congrFun
    (delta_three_nativeResidual_eq p i j k hij hik hjk
      a a' b b' c c' f) x
  exact heq.symm.trans hz

#print axioms Nightfall.InfinitePiQ2NativeL2SupportedDegree.native_L2_triple_zero_implies_native_supported_degree_two

end Nightfall.InfinitePiQ2NativeL2SupportedDegree
