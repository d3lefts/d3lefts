import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Basic.Real.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Push

/-! All-order graph component zero-XOR and contraction core. -/
namespace Nightfall.AllOrder
open Finset

variable {I G C : Type*} [DecidableEq I] [AddCommGroup G] [DecidableEq C]

def MinimalZero (a : I → G) (E : Finset I) : Prop :=
  E.Nonempty ∧ (∑ i ∈ E, a i) = 0 ∧
    ∀ D : Finset I, D ⊂ E → D.Nonempty → (∑ i ∈ D, a i) ≠ 0

theorem minimal_zero_exists (a : I → G) (S : Finset I)
    (hne : S.Nonempty) (hz : (∑ i ∈ S, a i) = 0) :
    ∃ E ⊆ S, MinimalZero a E := by
  classical
  induction S using Finset.strongInductionOn with
  | _ S ih =>
    by_cases hm : ∀ D : Finset I, D ⊂ S → D.Nonempty → (∑ i ∈ D, a i) ≠ 0
    · exact ⟨S, Subset.rfl, hne, hz, hm⟩
    · push_neg at hm
      obtain ⟨D, hD, hneD, hzD⟩ := hm
      obtain ⟨E, hED, hE⟩ := ih D hD hneD hzD
      exact ⟨E, hED.trans hD.subset, hE⟩

/-- Every zero-sum subset has zero sum in each component if all minimal
    zero-sum subsets lie in single components. Slots may carry repeated labels. -/
theorem zero_sum_each_component (a : I → G) (comp : I → C)
    (hloc : ∀ E : Finset I, MinimalZero a E → ∃ c, ∀ i ∈ E, comp i = c)
    (S : Finset I) (hz : (∑ i ∈ S, a i) = 0) (c : C) :
    (∑ i ∈ S.filter (fun i => comp i = c), a i) = 0 := by
  classical
  induction S using Finset.strongInductionOn with
  | _ S ih =>
    by_cases hS : S.Nonempty
    · obtain ⟨E, hES, hE⟩ := minimal_zero_exists a S hS hz
      obtain ⟨cE, hcomp⟩ := hloc E hE
      have hproper : S \ E ⊂ S := by
        refine Finset.ssubset_iff_subset_ne.mpr ⟨Finset.sdiff_subset, ?_⟩
        intro heq
        obtain ⟨i, hi⟩ := hE.1
        have hiD : i ∈ S \ E := heq.symm ▸ hES hi
        exact (Finset.mem_sdiff.mp hiD).2 hi
      have hrest : (∑ i ∈ S \ E, a i) = 0 := by
        have h := Finset.sum_sdiff (f := a) hES
        rw [hE.2.1, add_zero, hz] at h
        exact h
      have hr := ih (S \ E) hproper hrest
      have hdis : Disjoint (E.filter (fun i => comp i = c))
          ((S \ E).filter (fun i => comp i = c)) := by
        apply Finset.disjoint_left.mpr
        intro i hi hi'
        exact (Finset.mem_sdiff.mp (Finset.mem_filter.mp hi').1).2 (Finset.mem_filter.mp hi).1
      have hu : E.filter (fun i => comp i = c) ∪ (S \ E).filter (fun i => comp i = c) =
          S.filter (fun i => comp i = c) := by
        ext i
        simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_sdiff]
        constructor
        · rintro (⟨he,hc⟩ | ⟨⟨hs,_⟩,hc⟩)
          · exact ⟨hES he,hc⟩
          · exact ⟨hs,hc⟩
        · rintro ⟨hs,hc⟩
          by_cases he : i ∈ E
          · exact Or.inl ⟨he,hc⟩
          · exact Or.inr ⟨⟨hs,he⟩,hc⟩
      have hezero : (∑ i ∈ E.filter (fun i => comp i = c), a i) = 0 := by
        by_cases hcc : cE = c
        · have heq : E.filter (fun i => comp i = c) = E := by
            ext i
            simp only [Finset.mem_filter]
            exact ⟨And.left, fun hi => ⟨hi, (hcomp i hi).trans hcc⟩⟩
          rw [heq, hE.2.1]
        · have heq : E.filter (fun i => comp i = c) = ∅ := by
            apply Finset.eq_empty_iff_forall_notMem.mpr
            intro i hi
            obtain ⟨hiE,hic⟩ := Finset.mem_filter.mp hi
            exact hcc ((hcomp i hiE).symm.trans hic)
          simp [heq]
      rw [← hu, Finset.sum_union hdis, hezero, hr, add_zero]
    · rw [Finset.not_nonempty_iff_eq_empty.mp hS]
      simp

/-- Nonzero component implies a nonzero total active frequency. -/
theorem active_total_ne_zero (a : I → G) (comp : I → C)
    (hloc : ∀ E : Finset I, MinimalZero a E → ∃ c, ∀ i ∈ E, comp i = c)
    (S : Finset I) (c : C)
    (hc : (∑ i ∈ S.filter (fun i => comp i = c), a i) ≠ 0) :
    (∑ i ∈ S, a i) ≠ 0 := fun hz => hc (zero_sum_each_component a comp hloc S hz c)

/-- Exact deletion of an inactive zero-sum block preserves the active frequency. -/
theorem zero_block_contract (a : I → G) (S E : Finset I) (hES : E ⊆ S)
    (hz : (∑ i ∈ E, a i) = 0) :
    (∑ i ∈ S \ E, a i) = ∑ i ∈ S, a i := by
  have h := Finset.sum_sdiff (f := a) hES
  rwa [hz, add_zero] at h

section Masks
variable {A B W : Type*} [Fintype A] [Fintype B] [Fintype W]

/-- Exact signed mask expansion and summation over inactive coordinates. -/
theorem contraction_eval (c : A → B → ℝ) (mask : A → B → ℝ) (v : A → ℝ) :
    (∑ a, (∑ b, c a b * mask a b) * v a) =
      ∑ a, ∑ b, c a b * mask a b * v a := by
  simp_rw [Finset.sum_mul]

/-- Norm-controlled signed mask averaging; weights need not be positive. -/
theorem signed_average_bound (w y : W → ℝ) (M : ℝ)
    (hM : 0 ≤ M) (hy : ∀ i, |y i| ≤ M) :
    |∑ i, w i * y i| ≤ (∑ i, |w i|) * M := by
  calc
    _ ≤ ∑ i, |w i * y i| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ i, |w i| * |y i| := by simp_rw [abs_mul]
    _ ≤ ∑ i, |w i| * M := Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hy i) (abs_nonneg _))
    _ = _ := (Finset.sum_mul _ _ _).symm

/-- Costs of independent signed mask expansions multiply exactly. -/
theorem signed_cost_mul (u : A → ℝ) (v : B → ℝ) :
    (∑ a, ∑ b, |u a * v b|) = (∑ a, |u a|) * (∑ b, |v b|) := by
  simp_rw [abs_mul, ← Finset.mul_sum, Finset.sum_mul]

end Masks

#print axioms minimal_zero_exists
#print axioms zero_sum_each_component
#print axioms active_total_ne_zero
#print axioms zero_block_contract
#print axioms contraction_eval
#print axioms signed_average_bound
#print axioms signed_cost_mul
end Nightfall.AllOrder
