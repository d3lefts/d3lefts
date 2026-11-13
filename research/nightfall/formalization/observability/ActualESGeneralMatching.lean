import ActualESPairMatchingBridge
import ActualESQuadraticRectangles
import QuadraticHybridTelescoping
import ActualESPackedParity

/-!
# Actual quadratic source: arbitrary embedded finite matching

An injective endpoint map E × Bool → ι specifies a matching of pairs
within an arbitrary larger set of source coordinates. All unmatched
source coordinates are fixed at a base input, and selector changes are
transported through Function.extend. The finite degree-two Efron–Stein
source supplies rectangle background-invariance. The abstract hybrid
coupling is used only *after* the invariance premise has been derived.

No abstract matching mass, polynomial representation, or parity identity
is assumed. The pointwise bound covers every input of the finite source
alphabet. For almost-sure bounds with zero-mass atoms, the supported
domain must be reduced before applying this theorem.

This is a source-level matching proof, not the complete Q2 influence
theorem: greedy energy, sections, and terminal variance/influence remain.
-/

namespace Nightfall.Observability.ActualESGeneralMatching

open Finset Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESQuadraticRectangles
open Nightfall.Observability.QuadraticHybridTelescoping
open Nightfall.Observability.ActualESPackedParity

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual source coordinate belonging to an endpoint of a
selected matching edge. -/
def matchingCoord (u v : E → ι) (k : E × Bool) : ι :=
  if k.2 then v k.1 else u k.1

/-- Lift a block input to all coordinates of the original function.
Unmatched source coordinates retain their base value. -/
noncomputable def liftMatching
    (u v : E → ι) (base : ι → α)
    (x : E × Bool → α) : ι → α :=
  Function.extend (matchingCoord u v) x base

/-- Injective matching coordinates make lifting commute with one
genuine source-coordinate update. This is an elementary representation
lemma, not a bound or a statistical assumption. -/
theorem liftMatching_update
    (u v : E → ι)
    (hmap : Function.Injective (matchingCoord u v))
    (base : ι → α) (x : E × Bool → α)
    (k : E × Bool) (a : α) :
    liftMatching u v base (Function.update x k a) =
      Function.update (liftMatching u v base x)
        (matchingCoord u v k) a := by
  classical
  funext i
  by_cases hi : ∃ t : E × Bool, matchingCoord u v t = i
  · obtain ⟨t, rfl⟩ := hi
    by_cases htk : t = k
    · subst t
      simp [liftMatching, hmap.extend_apply]
    · have hneq : matchingCoord u v t ≠ matchingCoord u v k := by
        intro h
        exact htk (hmap h)
      simp [liftMatching, hmap.extend_apply, Function.update, htk, hneq]
  · have hneq : i ≠ matchingCoord u v k := by
      intro h
      exact hi ⟨k, h.symm⟩
    simp [liftMatching, Function.extend_apply', hi, Function.update, hneq]

/-- Updating a single packed block updates exactly the two
corresponding coordinates of the actual source function. -/
theorem liftMatching_blockReplace
    (u v : E → ι)
    (hmap : Function.Injective (matchingCoord u v))
    (base : ι → α) (x : E × Bool → α)
    (e : E) (a b : α) :
    liftMatching u v base (blockReplace x e a b) =
      Function.update
        (Function.update (liftMatching u v base x) (u e) a)
        (v e) b := by
  rw [blockReplace_eq_source_updates]
  rw [liftMatching_update u v hmap base _ (e, true) b]
  rw [liftMatching_update u v hmap base x (e, false) a]
  rfl

/-- Every packed mixed rectangle of the lifted function is literally
the actual source rectangle on the selected original edge. -/
theorem blockRectangle_liftMatching
    (u v : E → ι)
    (hmap : Function.Injective (matchingCoord u v))
    (base : ι → α) (f : (ι → α) → ℝ)
    (x : E × Bool → α) (e : E)
    (a0 a1 b0 b1 : α) :
    blockRectangle (fun y => f (liftMatching u v base y))
      x e a0 a1 b0 b1 =
    sourceRectangle f (liftMatching u v base x)
      (u e) (v e) a0 a1 b0 b1 := by
  unfold blockRectangle sourceRectangle
  simp only [liftMatching_blockReplace u v hmap base]

/-- Disjoint endpoint embedding forces each selected edge to have two
distinct original coordinates. -/
theorem matchingCoord_endpoints_distinct
    (u v : E → ι)
    (hmap : Function.Injective (matchingCoord u v))
    (e : E) : u e ≠ v e := by
  intro h
  have hc : matchingCoord u v (e, false) =
      matchingCoord u v (e, true) := by simpa [matchingCoord] using h
  have hbad := hmap hc
  simp at hbad

/-- GLOBAL ACTUAL-SOURCE MATCHING RECTANGLE BOUND.

This theorem works for any number of disjoint matching edges embedded
in any larger finite product source. It derives parity cancellation
from ESDegreeLE p f 2, with unmatched coordinates fixed in the lifted
selector experiment. No claimed inequality is passed as a premise.
-/
theorem actual_source_general_matching_rectangles_le_four
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι)
    (hmap : Function.Injective (matchingCoord u v))
    (left right : E → Bool → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    (∑ e : E, sourceRectangle f base (u e) (v e)
      (left e false) (left e true)
      (right e false) (right e true)) ≤ 4 * B := by
  let g : (E × Bool → α) → ℝ :=
    fun x => f (liftMatching u v base x)
  let d : E → ℝ := fun e =>
    sourceRectangle f base (u e) (v e)
      (left e false) (left e true)
      (right e false) (right e true)
  have hrect : ∀ e x,
      blockRectangle g x e
        (left e false) (left e true)
        (right e false) (right e true) = d e := by
    intro e x
    calc
      blockRectangle g x e
          (left e false) (left e true)
          (right e false) (right e true) =
        sourceRectangle f (liftMatching u v base x)
          (u e) (v e)
          (left e false) (left e true)
          (right e false) (right e true) :=
            blockRectangle_liftMatching u v hmap base f x e
              (left e false) (left e true)
              (right e false) (right e true)
      _ = d e :=
        actual_quadratic_rectangle_base_independent
          p hp1 f hdegree (u e) (v e)
          (matchingCoord_endpoints_distinct u v hmap e)
          (liftMatching u v base x) base
          (left e false) (left e true)
          (right e false) (right e true)
  have hgf : ∀ x, |g x| ≤ B := fun x => hf _
  simpa only [d] using
    (hybrid_rectangles_le_four g left right d hrect B hgf)

/-- The canonical pair kernel's rectangle equals the same four-point
difference of the original quadratic source. No kernel source
representation is passed as a hypothesis. -/
theorem sourceRectangle_eq_actualPairKernel_rectangle
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α) (i j : ι) (hij : i ≠ j)
    (a0 a1 b0 b1 : α) :
    sourceRectangle f base i j a0 a1 b0 b1 =
      actualPairKernel p f base i j a0 b0 -
      actualPairKernel p f base i j a0 b1 -
      actualPairKernel p f base i j a1 b0 +
      actualPairKernel p f base i j a1 b1 := by
  rw [actual_quadratic_rectangle_eq_es_pair
    p hp1 f hdegree i j hij base a0 a1 b0 b1]
  rfl

/-- Source-matched global AMPLITUDE certificate, on an arbitrary
disjoint finite matching inside the original index set.

The selected corners dominate every actual canonical pair-kernel value,
and their total oriented source rectangle is at most 4B. The corners
are constructed from source centering, not assumed.
-/
theorem actual_source_general_matching_amplitude_witness
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι)
    (hmap : Function.Injective (matchingCoord u v))
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ a0 a1 b0 b1 : E → α,
      (∀ e s t, |actualPairKernel p f base (u e) (v e) s t| ≤
        sourceRectangle f base (u e) (v e)
          (a0 e) (a1 e) (b0 e) (b1 e)) ∧
      (∑ e : E, sourceRectangle f base (u e) (v e)
        (a0 e) (a1 e) (b0 e) (b1 e)) ≤ 4 * B := by
  have hne : ∀ e, u e ≠ v e :=
    matchingCoord_endpoints_distinct u v hmap
  obtain ⟨a0, a1, b0, b1, hrect⟩ :=
    actual_all_edges_oriented_rectangles p hp hp1 f base u v hne
  let left : E → Bool → α := fun e bit =>
    if bit then a1 e else a0 e
  let right : E → Bool → α := fun e bit =>
    if bit then b1 e else b0 e
  refine ⟨a0, a1, b0, b1, ?_, ?_⟩
  · intro e s t
    rw [sourceRectangle_eq_actualPairKernel_rectangle
      p hp1 f hdegree base (u e) (v e) (hne e)
      (a0 e) (a1 e) (b0 e) (b1 e)]
    exact hrect e s t
  · simpa [left, right] using
      (actual_source_general_matching_rectangles_le_four
        p hp1 f hdegree base u v hmap left right B hf)

end Nightfall.Observability.ActualESGeneralMatching
