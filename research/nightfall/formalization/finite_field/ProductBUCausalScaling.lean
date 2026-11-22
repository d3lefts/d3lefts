import ProductBUMixedRadius

/-!
# Exact quadratic rescaling of genuine causal phase-retrieval transcripts

A causal row selector is evaluated on prior INTENSITIES, which rescale
quadratically when the signal is scaled. This exact oracle identity is
proved for arbitrary real factors (including zero and negative factors),
without a fictitious global continuity condition on unreachable histories.

For actual CausalRows, the sole required input is linearity of each
chosen sensor. The source's transcript stores readings newest first.
This file proves the exact finite-recursion identity, NOT the separate
Claim that reachability-continuity transfers to the scaled policy.
The latter remains an explicit gate in the all-radius risk corollary.

No ProductSphereZero theorem or topological axiom is asserted.
-/

open scoped BigOperators

namespace Nightfall.ProductBUCausalScaling

open Nightfall.GenuinePrefixPhase
open Nightfall.ProductSphereCausal

/-- Scale every intensity in a finite history by the *square*
of a scalar. -/
def scaleHistory (c : ℝ) (h : List ℝ) : List ℝ :=
  h.map (fun t => c ^ 2 * t)

@[simp] theorem scaleHistory_nil (c : ℝ) :
    scaleHistory c [] = [] := rfl

@[simp] theorem scaleHistory_cons (c t : ℝ) (h : List ℝ) :
    scaleHistory c (t :: h) = c ^ 2 * t :: scaleHistory c h := rfl

variable {V : Type*} [AddCommGroup V] [Module ℝ V]

/-- Rescale only the history argument of an arbitrary scalar oracle. -/
def scaledOracle (c : ℝ) (a : GenuinePrefixPhase.Oracle V) :
    GenuinePrefixPhase.Oracle V :=
  fun h x => a (scaleHistory c h) x

/-- Exact induction: rescaling a signal by c scales all genuine
intensities by c², provided the sensor oracle is c-homogeneous in
the current input signal. Crucially the policy is reindexed by c²
times the REAL history, not by a hypothetical virtual history. -/
theorem transcript_scale_history
    (c : ℝ) (a : GenuinePrefixPhase.Oracle V)
    (hhom : ∀ h x, a h (c • x) = c * a h x)
    (m : ℕ) (x : V) :
    GenuinePrefixPhase.transcript a m (c • x) =
      scaleHistory c
        (GenuinePrefixPhase.transcript (scaledOracle c a) m x) := by
  induction m with
  | zero => rfl
  | succ j ih =>
      change
        (a (GenuinePrefixPhase.transcript a j (c • x)) (c • x)) ^ 2 ::
          GenuinePrefixPhase.transcript a j (c • x)
        =
        scaleHistory c
          (((scaledOracle c a)
            (GenuinePrefixPhase.transcript (scaledOracle c a) j x) x) ^ 2 ::
              GenuinePrefixPhase.transcript (scaledOracle c a) j x)
      rw [ih]
      rw [scaleHistory_cons]
      congr 1
      dsimp [scaledOracle]
      rw [hhom]
      ring

/-- The reindexed sensor policy still takes actual history to a
real continuous linear functional on the signal space. -/
def scaledRows (n : ℕ) (c : ℝ) (a : CausalRows n) :
    CausalRows n :=
  fun h => a (scaleHistory c h)

/-- The constructed row policy is extensionally the history-scaled
amplitude oracle, without changing or normalizing the sensor itself. -/
theorem scaledOracle_amp (n : ℕ) (c : ℝ) (a : CausalRows n) :
    scaledOracle c (amp a) = amp (scaledRows n c a) := rfl

/-- Exact physical squared-linear causal-history scaling for
EVERY finite reading count and arbitrary real scale factor. -/
theorem causal_transcript_scaling
    (n : ℕ) (a : CausalRows n) (c : ℝ)
    (m : ℕ) (x : Signal n) :
    GenuinePrefixPhase.transcript (amp a) m (c • x) =
      scaleHistory c
        (GenuinePrefixPhase.transcript (amp (scaledRows n c a)) m x) := by
  rw [← scaledOracle_amp n c a]
  apply transcript_scale_history c (amp a)
  intro h y
  change (a h) (c • y) = c * (a h) y
  simpa only [smul_eq_mul] using (map_smul (a h) c y)

/-- Coordinate-exact squared Euclidean norm is homogeneous of
degree two; this does not substitute the function-space sup norm. -/
theorem sqNorm_smul (n : ℕ) (c : ℝ) (x : Signal n) :
    Nightfall.ProductSphereObstruction.sqNorm n (c • x) =
      c ^ 2 * Nightfall.ProductSphereObstruction.sqNorm n x := by
  change (∑ i : Fin n, (c * x i) ^ 2) =
    c ^ 2 * (∑ i : Fin n, x i ^ 2)
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  ring

#check scaleHistory_cons
#print axioms scaleHistory_cons
#check transcript_scale_history
#print axioms transcript_scale_history
#check scaledOracle_amp
#print axioms scaledOracle_amp
#check causal_transcript_scaling
#print axioms causal_transcript_scaling
#check sqNorm_smul
#print axioms sqNorm_smul

end Nightfall.ProductBUCausalScaling
