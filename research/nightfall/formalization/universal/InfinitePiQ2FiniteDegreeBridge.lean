import ActualSourceANOVA
import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Finite source: pointwise mixed third differences imply canonical degree <= 2

The C105.416 terminal theorem takes the actual finite-source Mobius
predicate `ESDegreeLE p f 2`. This module derives that predicate directly
from pointwise vanishing third differences, with no assumptions on the
probability masses (not even their normalization).

Mechanism: the anchor difference `f(x)-f(x[i:=a])` leaves every
canonical component on a support containing i unchanged, because its
subtracted term ignores i. Three such anchors annihilate a pointwise
quadratic f, so every component with at least three indices vanishes.
-/

namespace Nightfall.InfinitePiQ2FiniteDegreeBridge

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.InfinitePiQ2DegreeRetraction

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]

def anchorDifference (i : ι) (a : α)
    (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  f x - f (Function.update x i a)

theorem esComp_sub (p : ι → α → ℝ)
    (S : Finset ι) (f g : (ι → α) → ℝ) (x : ι → α) :
    esComp p S (fun z => f z - g z) x =
      esComp p S f x - esComp p S g x := by
  simp [esComp, condExp, Finset.sum_sub_distrib, mul_sub]

/-- All canonical interactions supported on a set containing i survive
the subtraction of a function depending on the other coordinates only. -/
theorem esComp_anchorDifference
    (p : ι → α → ℝ) (S : Finset ι)
    (i : ι) (hi : i ∈ S) (a : α)
    (f : (ι → α) → ℝ) (x : ι → α) :
    esComp p S (anchorDifference i a f) x =
      esComp p S f x := by
  have hignore : ∀ z : ι → α, ∀ b : α,
      f (Function.update (Function.update z i b) i a) =
      f (Function.update z i a) := by
    intro z b
    simp
  have hzero : esComp p S (fun z => f (Function.update z i a)) x = 0 :=
    esComp_indep p S (fun z => f (Function.update z i a)) x i hi
      hignore
  change esComp p S (fun z => f z - f (Function.update z i a)) x =
    esComp p S f x
  rw [esComp_sub, hzero, sub_zero]

private theorem update_self (z : ι → α) (i : ι) :
    Function.update z i (z i) = z := by
  funext j
  by_cases h : j = i
  · subst j
    simp
  · simp [Function.update_of_ne h]

/-- Anchored triple subtraction is the standard mixed third difference.
All three updates must be at distinct indices. -/
theorem anchor_triple_eq_delta
    (f : (ι → α) → ℝ)
    (i j k : ι) (hij : i ≠ j) (hik : i ≠ k) (hjk : j ≠ k)
    (a b c : α) (x : ι → α) :
    anchorDifference i a
      (anchorDifference j b (anchorDifference k c f)) x =
    delta i (x i) a (delta j (x j) b (delta k (x k) c f)) x := by
  simp only [anchorDifference, delta]
  simp [update_self, Function.update_comm, hij, hik, hjk]
  ring

/-- Pointwise degree at most two kills the triple anchored difference
at every source word, including zero-mass words. -/
theorem anchor_triple_zero
    (f : (ι → α) → ℝ) (hf : PointwiseDegreeTwo f)
    (i j k : ι) (hij : i ≠ j) (hik : i ≠ k) (hjk : j ≠ k)
    (a b c : α) (x : ι → α) :
    anchorDifference i a
      (anchorDifference j b (anchorDifference k c f)) x = 0 := by
  rw [anchor_triple_eq_delta f i j k hij hik hjk a b c x]
  exact hf i j k hij hik hjk (x i) a (x j) b (x k) c x

/-- **Exact finite Q2 hypothesis bridge**.
Every pointwise-degree-two finite observable has canonical original
source Efron-Stein degree <= 2, with arbitrary heterogeneous weights
(including arbitrary zeros). No supplied ANOVA decomposition or
source variance/influence hypothesis. -/
theorem pointwiseDegreeTwo_implies_ESDegreeLE
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (hf : PointwiseDegreeTwo f) :
    ESDegreeLE p f 2 := by
  intro S hS x
  obtain ⟨i, hi, j, hj, k, hk, hij, hik, hjk⟩ :=
    (Finset.two_lt_card).mp hS
  let a : α := x i
  let b : α := x j
  let c : α := x k
  have h1 := esComp_anchorDifference p S k hk c f x
  have h2 := esComp_anchorDifference p S j hj b (anchorDifference k c f) x
  have h3 := esComp_anchorDifference p S i hi a
    (anchorDifference j b (anchorDifference k c f)) x
  have hzero : anchorDifference i a
      (anchorDifference j b (anchorDifference k c f)) =
      (fun _ => (0 : ℝ)) := by
    funext z
    exact anchor_triple_zero f hf i j k hij hik hjk a b c z
  calc
    esComp p S f x =
        esComp p S (anchorDifference k c f) x := h1.symm
    _ = esComp p S
        (anchorDifference j b (anchorDifference k c f)) x := h2.symm
    _ = esComp p S
        (anchorDifference i a
          (anchorDifference j b (anchorDifference k c f))) x := h3.symm
    _ = esComp p S (fun _ => (0 : ℝ)) x := by rw [hzero]
    _ = 0 := by simp [esComp, condExp]

end Nightfall.InfinitePiQ2FiniteDegreeBridge
