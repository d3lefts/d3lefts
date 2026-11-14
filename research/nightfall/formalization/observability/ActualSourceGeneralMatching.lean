import ActualSourceQuadraticRectangles
import QuadraticHybridTelescoping

/-!
# Genuine original-product global matching rectangle bound (current pin)
Recovered from legacy #424's arbitrary embedded finite matching.
The source Efron–Stein degree and rectangles are current-pin literal
source predicates. Neither matching cost nor polynomial representation
is supplied as a premise. This module proves 4B for chosen oriented
rectangles, not yet global maximal pair amplitudes or terminal Q2.
-/

namespace Nightfall.Observability.ActualSourceGeneralMatching

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.QuadraticHybridTelescoping

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
theorem blockReplace_eq_source_updates
    (x : E × Bool → α) (e : E) (a b : α) :
    QuadraticHybridTelescoping.blockReplace (β := E) x e a b =
      Function.update (Function.update x (e, false) a) (e, true) b := by
  classical
  funext k
  rcases k with ⟨k, s⟩
  by_cases hk : k = e
  · subst k
    cases s <;> simp [QuadraticHybridTelescoping.blockReplace, Function.update]
  · cases s <;> simp [QuadraticHybridTelescoping.blockReplace, Function.update, hk]


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


end Nightfall.Observability.ActualSourceGeneralMatching
