import AllOrderCore
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Finset.Card
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.FinCases

namespace Nightfall.AllOrder.Geometry
open Finset

variable {I J A U : Type*} [Fintype J] [DecidableEq J] [DecidableEq I] [DecidableEq A]

/-- Evaluation of a pure row against a product of local dual test vectors.
    This coordinate-free test representation can be identified with the ordinary
    coefficient tensor by expansion in the local standard basis. -/
def evalTensor (f : I → J → A) (pair : A → U → ZMod 2) (i : I) (x : J → U) : ZMod 2 :=
  ∏ j, pair (f i j) (x j)

/-- If a family of sites has the same local row partition, and there is a distinct
    test site for each unwanted row, the chosen partition class is itself a
    zero-sum subfamily.  This is the elementary alternative to circuit splitting. -/
theorem repeated_pattern_split (f : I → J → A) (pair : A → U → ZMod 2)
    (E : Finset I) (j₀ : J) (a : A) (e : I → J)
    (sep : ∀ b, b ≠ a → ∃ u, pair a u = 1 ∧ pair b u = 0)
    (hpat : ∀ i ∈ E, ∀ k ∈ E, f i (e k) = f i j₀)
    (hinj : Set.InjOn e ↑E)
    (hz : ∀ x : J → U, ∑ i ∈ E, evalTensor f pair i x = 0) :
    ∀ x : J → U, ∑ i ∈ E.filter (fun i => f i j₀ = a), evalTensor f pair i x = 0 := by
  classical
  intro x
  let D := E.filter (fun i => f i j₀ ≠ a)
  let test : I → U := fun i => if h : f i j₀ ≠ a then Classical.choose (sep (f i j₀) h) else x (e i)
  have htest (i : I) (hi : i ∈ D) : pair a (test i) = 1 ∧ pair (f i j₀) (test i) = 0 := by
    have hn := (Finset.mem_filter.mp hi).2
    simp only [test, dif_pos hn]
    exact Classical.choose_spec (sep _ hn)
  let y : J → U := fun j => if h : ∃ i ∈ D, e i = j then test (Classical.choose h) else x j
  have hy (i : I) (hi : i ∈ D) : y (e i) = test i := by
    have he : ∃ k ∈ D, e k = e i := ⟨i,hi,rfl⟩
    simp only [y, dif_pos he]
    congr 1
    have hc := Classical.choose_spec he
    exact hinj (Finset.mem_filter.mp hc.1).1 (Finset.mem_filter.mp hi).1 hc.2
  have hkill (i : I) (hi : i ∈ D) : evalTensor f pair i y = 0 := by
    unfold evalTensor
    apply Finset.prod_eq_zero (Finset.mem_univ (e i))
    rw [hy i hi, hpat i (Finset.mem_filter.mp hi).1 i (Finset.mem_filter.mp hi).1]
    exact (htest i hi).2
  by_cases hbad : ∃ i ∈ D, pair a (x (e i)) = 0
  · obtain ⟨k,hk,hkx⟩ := hbad
    apply Finset.sum_eq_zero
    intro i hi
    obtain ⟨hiE,hia⟩ := Finset.mem_filter.mp hi
    unfold evalTensor
    apply Finset.prod_eq_zero (Finset.mem_univ (e k))
    rw [hpat i hiE k (Finset.mem_filter.mp hk).1, hia, hkx]
  · have hkeep (i : I) (hi : i ∈ E) (hia : f i j₀ = a) :
        evalTensor f pair i y = evalTensor f pair i x := by
      unfold evalTensor
      apply Finset.prod_congr rfl
      intro j _
      by_cases he : ∃ k ∈ D, e k = j
      · obtain ⟨k,hk,rfl⟩ := he
        rw [hy k hk, hpat i hi k (Finset.mem_filter.mp hk).1, hia, (htest k hk).1]
        have hn : pair a (x (e k)) ≠ 0 := fun hz => hbad ⟨k,hk,hz⟩
        have hcases : pair a (x (e k)) = 0 ∨ pair a (x (e k)) = 1 := by
          generalize pair a (x (e k)) = z
          fin_cases z
          · exact Or.inl rfl
          · exact Or.inr rfl
        exact (hcases.resolve_left hn).symm
      · simp [y, he]
    have hsum : ∑ i ∈ E.filter (fun i => f i j₀ = a), evalTensor f pair i x =
        ∑ i ∈ E, evalTensor f pair i y := by
      rw [Finset.sum_filter]
      apply Finset.sum_congr rfl
      intro i hi
      by_cases ha : f i j₀ = a
      · simp only [if_pos ha]
        exact (hkeep i hi ha).symm
      · simp only [if_neg ha]
        exact (hkill i (Finset.mem_filter.mpr ⟨hi,ha⟩)).symm
    rw [hsum, hz]

theorem sum_eval (E : Finset I) (g : I → (J → U) → ZMod 2) (x : J → U) :
    (∑ i ∈ E, g i) x = ∑ i ∈ E, g i x := by
  classical
  induction E using Finset.induction_on with
  | empty => simp
  | insert a s ha ih => simp [Finset.sum_insert, ha, Pi.add_apply, ih]

/-- A minimal circuit cannot have a nonconstant local pattern that repeats
    enough times to assign one distinct test site per row. -/
theorem minimal_pattern_constant (f : I → J → A) (pair : A → U → ZMod 2)
    (E : Finset I) (j₀ : J) (e : I → J)
    (sep : ∀ a b, b ≠ a → ∃ u, pair a u = 1 ∧ pair b u = 0)
    (hpat : ∀ i ∈ E, ∀ k ∈ E, f i (e k) = f i j₀)
    (hinj : Set.InjOn e ↑E)
    (hm : MinimalZero (evalTensor f pair) E) :
    ∀ i ∈ E, ∀ k ∈ E, f i j₀ = f k j₀ := by
  classical
  intro i hi k hk
  by_contra hn
  let S := E.filter (fun r => f r j₀ = f i j₀)
  have hS : S.Nonempty := ⟨i,Finset.mem_filter.mpr ⟨hi,rfl⟩⟩
  have hsub : S ⊂ E := by
    refine Finset.ssubset_iff_subset_ne.mpr ⟨Finset.filter_subset _ _, ?_⟩
    intro he
    have hmem : k ∈ S := he.symm ▸ hk
    exact hn ((Finset.mem_filter.mp hmem).2.symm)
  apply hm.2.2 S hsub hS
  funext x
  have hzero : ∀ x : J → U, ∑ r ∈ E, evalTensor f pair r x = 0 := by
    intro x
    have h := congrFun hm.2.1 x
    simpa only [sum_eval, Pi.zero_apply] using h
  have h := repeated_pattern_split f pair E j₀ (f i j₀) e (sep _) hpat hinj hzero x
  simpa only [sum_eval, Pi.zero_apply, S] using h

#print axioms repeated_pattern_split
#print axioms minimal_pattern_constant
end Nightfall.AllOrder.Geometry
