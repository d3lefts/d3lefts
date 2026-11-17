import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Residual degree implies pointwise degree: direct mixed-difference cancellation

No Hoeffding expansion, positivity, normalization, or atom floor is
needed for the purely algebraic direction.

For an arbitrary heterogeneous finite alphabet and arbitrary weights,
a coordinate heat bath T_i erases the refreshed coordinate:
  delta_i T_i = 0.
For distinct i,j the finite differences and heat baths commute:
  delta_i T_j = T_j delta_i.
Hence delta_i delta_j delta_k =
delta_i delta_j delta_k (Id-T_i)(Id-T_j)(Id-T_k).
An identically zero triple heat-bath residual therefore implies
pointwise degree two in the exact sense required by the native finite
original-source theorem. This is a structural finite-algebra theorem;
the L²-to-pointwise positive-support step remains separate.
-/

namespace Nightfall.InfinitePiQ2TripleResidualDegree

open Finset
open Nightfall.InfinitePiQ2DegreeRetraction

universe u v
variable {ι : Type u} [DecidableEq ι]
variable {A : ι → Type v} [∀ i, Fintype (A i)]
variable (p : (i : ι) → A i → ℝ)

/-- Original weighted site-refresh on a heterogeneous table; weights
are not assumed normalized for this algebraic lemma. -/
noncomputable def nativeHeatBath (i : ι)
    (f : ((j : ι) → A j) → ℝ)
    (x : (j : ι) → A j) : ℝ :=
  ∑ a : A i, p i a * f (Function.update x i a)

noncomputable def nativeResidual (i : ι)
    (f : ((j : ι) → A j) → ℝ)
    (x : (j : ι) → A j) : ℝ :=
  f x - nativeHeatBath p i f x

/-- Refreshing i erases all dependence on the previous i letter. -/
theorem nativeHeatBath_update_self
    (i : ι) (a : A i)
    (f : ((j : ι) → A j) → ℝ) (x : (j : ι) → A j) :
    nativeHeatBath p i f (Function.update x i a) =
      nativeHeatBath p i f x := by
  classical
  simp [nativeHeatBath, Function.update_idem]

/-- A finite difference in i annihilates the i heat bath. -/
theorem delta_nativeHeatBath_self
    (i : ι) (a b : A i)
    (f : ((j : ι) → A j) → ℝ) :
    delta i a b (nativeHeatBath p i f) = fun _ => 0 := by
  funext x
  simp [delta, nativeHeatBath_update_self]

/-- A finite difference in i commutes with any other coordinate heat
bath, by exact commutation of dependent coordinate updates. -/
theorem delta_nativeHeatBath_ne
    (i j : ι) (hij : i ≠ j)
    (a b : A i) (f : ((j : ι) → A j) → ℝ) :
    delta i a b (nativeHeatBath p j f) =
      nativeHeatBath p j (delta i a b f) := by
  classical
  funext x
  change
    (∑ t : A j, p j t * f (Function.update (Function.update x i a) j t)) -
      (∑ t : A j, p j t * f (Function.update (Function.update x i b) j t)) =
    ∑ t : A j, p j t *
      (f (Function.update (Function.update x j t) i a) -
       f (Function.update (Function.update x j t) i b))
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro t _
  rw [Function.update_comm hij a t x,
    Function.update_comm hij b t x]
  ring

/-- i-differences cancel the i heat-bath correction completely. -/
theorem delta_nativeResidual_self
    (i : ι) (a b : A i)
    (f : ((j : ι) → A j) → ℝ) :
    delta i a b (nativeResidual p i f) = delta i a b f := by
  funext x
  have hzero := congrFun (delta_nativeHeatBath_self p i a b f) x
  have heq :
      delta i a b (nativeResidual p i f) x =
        delta i a b f x -
          delta i a b (nativeHeatBath p i f) x := by
    simp only [delta, nativeResidual]
    ring
  rw [heq, hzero, sub_zero]

/-- i-differences commute with a different-coordinate residual. -/
theorem delta_nativeResidual_ne
    (i j : ι) (hij : i ≠ j)
    (a b : A i) (f : ((j : ι) → A j) → ℝ) :
    delta i a b (nativeResidual p j f) =
      nativeResidual p j (delta i a b f) := by
  funext x
  have hcomm := congrFun (delta_nativeHeatBath_ne p i j hij a b f) x
  have heq :
      delta i a b (nativeResidual p j f) x =
        delta i a b f x -
          delta i a b (nativeHeatBath p j f) x := by
    simp only [delta, nativeResidual]
    ring
  rw [heq, hcomm]
  rfl

/-- Mixed third differences are unchanged by inserting the three
corresponding residual operators. No weights positivity needed. -/
theorem delta_three_nativeResidual_eq
    (i j k : ι) (hij : i ≠ j) (hik : i ≠ k) (hjk : j ≠ k)
    (a a' : A i) (b b' : A j) (c c' : A k)
    (f : ((m : ι) → A m) → ℝ) :
    delta i a a' (delta j b b' (delta k c c'
      (nativeResidual p i (nativeResidual p j (nativeResidual p k f))))) =
    delta i a a' (delta j b b' (delta k c c' f)) := by
  rw [delta_nativeResidual_ne p k i hik.symm c c']
  rw [delta_nativeResidual_ne p k j hjk.symm c c']
  rw [delta_nativeResidual_self p k c c']
  rw [delta_nativeResidual_ne p j i hij.symm b b']
  rw [delta_nativeResidual_self p j b b']
  rw [delta_nativeResidual_self p i a a']

/-- The exact missing finite terminal converse: if all genuine
weighted coordinate triple residuals vanish, the table has global
pointwise degree at most two. A condition only on positive-weight
source words can be reduced to this by positive-cell retraction. -/
theorem tripleResidualZero_implies_pointwiseDegreeTwo
    (f : ((i : ι) → A i) → ℝ)
    (htriple : ∀ (i j k : ι), i ≠ j → i ≠ k → j ≠ k →
      nativeResidual p i (nativeResidual p j (nativeResidual p k f)) =
        (fun _ => 0)) :
    PointwiseDegreeTwo f := by
  intro i j k hij hik hjk a a' b b' c c' x
  have hkey := congrFun
    (delta_three_nativeResidual_eq p i j k hij hik hjk
      a a' b b' c c' f) x
  have hz : delta i a a' (delta j b b' (delta k c c'
      (nativeResidual p i (nativeResidual p j
        (nativeResidual p k f))))) x = 0 := by
    rw [htriple i j k hij hik hjk]
    simp [delta]
  exact hkey.symm.trans hz

#print axioms Nightfall.InfinitePiQ2TripleResidualDegree.delta_nativeHeatBath_self
#print axioms Nightfall.InfinitePiQ2TripleResidualDegree.delta_nativeHeatBath_ne
#print axioms Nightfall.InfinitePiQ2TripleResidualDegree.delta_three_nativeResidual_eq
#print axioms Nightfall.InfinitePiQ2TripleResidualDegree.tripleResidualZero_implies_pointwiseDegreeTwo

end Nightfall.InfinitePiQ2TripleResidualDegree
