import ProductRowBound

/-!
# Conditional FUR(2) anchored transition row assembly
No new axioms. The source product-space row theorem is invoked directly.
Explicit remaining hypotheses: oscillation cost eight, exact Taylor remainder,
transition remainder bounded by four and indicator degree at most two.
-/

namespace Nightfall.MixtureAA.FUR2

open Finset
open Nightfall.ProductSpace.RowBound

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

def inactive : ι → Option (α × α) := fun _ => none

def transitions (x y : ι → α) : ι → Option (α × α) :=
  fun i => if x i = y i then none else some (x i, y i)

theorem disagree_inactive_transitions (x y : ι → α) :
    disagree (inactive (ι := ι) (α := α)) (transitions x y) = disagree x y := by
  ext i
  by_cases h : x i = y i
  · simp [disagree, inactive, transitions, h]
  · simp [disagree, inactive, transitions, h]

theorem anchored_transition_row
    (H : (ι → Option (α × α)) → ℝ)
    (hzero : H (inactive (ι := ι) (α := α)) = 0)
    (hbound : ∀ t, |H t| ≤ 4)
    (hdegree : HasProdDegreeLE (fun t => H t / 4) 2) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i, c i) ≤ 16 * Real.pi ^ 2 ∧
      (∀ x y : ι → α,
        |H (transitions x y)| ≤ ∑ i ∈ disagree x y, c i) := by
  have hscaled : ∀ t, |H t / 4| ≤ 1 := by
    intro t
    have hb := hbound t
    rw [abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 4)]
    linarith
  obtain ⟨b, hbnonneg, hbcost, hbcover⟩ :=
    product_row_bound 2 (fun t => H t / 4) hscaled hdegree
      (inactive (ι := ι) (α := α))
  refine ⟨fun i => 4 * b i, ?_, ?_, ?_⟩
  · intro i
    exact mul_nonneg (by norm_num) (hbnonneg i)
  · calc
      (∑ i, (4 : ℝ) * b i) = 4 * (∑ i, b i) := by
        rw [Finset.mul_sum]
      _ ≤ 4 * (Real.pi ^ 2 * (2 : ℝ) ^ 2) :=
        mul_le_mul_of_nonneg_left hbcost (by norm_num)
      _ = 16 * Real.pi ^ 2 := by ring
  · intro x y
    have h := hbcover (transitions x y)
    have hbound' :
        |H (transitions x y)| / 4 ≤
          ∑ i ∈ disagree (inactive (ι := ι) (α := α)) (transitions x y), b i := by
      simpa [hzero, abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 4)] using h
    rw [disagree_inactive_transitions x y] at hbound'
    calc
      |H (transitions x y)|
          = 4 * (|H (transitions x y)| / 4) := by ring
      _ ≤ 4 * (∑ i ∈ disagree x y, b i) :=
          mul_le_mul_of_nonneg_left hbound' (by norm_num)
      _ = ∑ i ∈ disagree x y, 4 * b i := by rw [Finset.mul_sum]

def FiberInvariant (a : (ι → α) → ι → ℝ) : Prop :=
  ∀ x i b, a (Function.update x i b) i = a x i

theorem fiber_uniform_row_of_quadratic_transition
    (f : (ι → α) → ℝ)
    (v : (ι → α) → ι → ℝ)
    (H : (ι → Option (α × α)) → ℝ)
    (hvnonneg : ∀ x i, 0 ≤ v x i)
    (hvinvariant : FiberInvariant v)
    (hvcost : ∀ x, (∑ i, v x i) ≤ 8)
    (hquad : ∀ x y,
       |f x - f y| ≤
         (∑ i ∈ disagree x y, v x i) + |H (transitions x y)|)
    (hzero : H (inactive (ι := ι) (α := α)) = 0)
    (hbound : ∀ t, |H t| ≤ 4)
    (hdegree : HasProdDegreeLE (fun t => H t / 4) 2) :
    ∃ a : (ι → α) → ι → ℝ,
      (∀ x i, 0 ≤ a x i) ∧
      FiberInvariant a ∧
      (∀ x, (∑ i, a x i) ≤ 8 + 16 * Real.pi ^ 2) ∧
      (∀ x y,
        |f x - f y| ≤ ∑ i ∈ disagree x y, a x i) := by
  obtain ⟨c, hcpos, hccost, hcrem⟩ :=
    anchored_transition_row H hzero hbound hdegree
  refine ⟨fun x i => v x i + c i, ?_, ?_, ?_, ?_⟩
  · intro x i
    exact add_nonneg (hvnonneg x i) (hcpos i)
  · intro x i b
    exact congrArg (fun z : ℝ => z + c i) (hvinvariant x i b)
  · intro x
    calc
      (∑ i : ι, v x i + c i) =
          (∑ i, v x i) + (∑ i, c i) := by rw [Finset.sum_add_distrib]
      _ ≤ 8 + 16 * Real.pi ^ 2 :=
          add_le_add (hvcost x) hccost
  · intro x y
    calc
      |f x - f y| ≤
          (∑ i ∈ disagree x y, v x i) + |H (transitions x y)| :=
            hquad x y
      _ ≤ (∑ i ∈ disagree x y, v x i) +
          (∑ i ∈ disagree x y, c i) :=
            add_le_add (le_refl _) (hcrem x y)
      _ = (∑ i ∈ disagree x y, v x i + c i) := by
            rw [Finset.sum_add_distrib]

end Nightfall.MixtureAA.FUR2
