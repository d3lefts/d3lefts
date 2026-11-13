import ActualESPairMatchingBridge
import ActualESQuadraticRectangles

/-!
# Exact source-derived centered section expansion

This theorem starts from the actual finite normalized product-law source
f, with Efron–Stein degree at most two. It proves, pointwise in the
source input and alphabet, that its centered coordinate section equals
the sum of its genuine canonical Hoeffding components of size at most
two containing that coordinate. The representation is derived, never
supplied. Both singleton and pair components are included.

The next bridge is *conditional* expectation over the finite set of
actual owned neighbors. There the unowned pair components vanish by
their proved degeneracy. This file proves the non-conditional equality
needed for that step; it does not claim the terminal variance theorem.
-/

namespace Nightfall.Observability.ActualESConditionalSection

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.QuadraticANOVA
open Nightfall.Observability.ActualESQuadraticRectangles

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- An actual source coordinate section centered under the original
marginal. The base's i-th symbol is irrelevant. -/
noncomputable def actualCenteredSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) : ℝ :=
  f (Function.update x i a) -
    ∑ b : α, p i b * f (Function.update x i b)

/-- Source identity, without an external quadratic decomposition,
oscillation estimate, row certificate, or influence hypothesis:

U_i(a;x_-i) = Σ_{S: |S|≤2, i∈S} esComp(p,S,f)(x_i:=a).

It holds for arbitrary finite normalized real-valued coordinate
weights (nonnegativity is not required for this algebraic identity).
-/
theorem actual_centered_section_eq_hilbert_ANOVA
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (x : ι → α) (a : α) :
    actualCenteredSection p f i x a =
      ∑ S : Finset ι,
        if S.card ≤ 2 ∧ i ∈ S then
          esComp p S f (Function.update x i a)
        else 0 := by
  classical
  let g : Finset ι → (ι → α) → ℝ := fun S y =>
    if S.card ≤ 2 then esComp p S f y else 0
  have hdecomp (y : ι → α) : f y = ∑ S : Finset ι, g S y := by
    simpa only [g] using
      quadratic_hoeffding_decomposition p hp1 f hdegree y
  have hsum :
      (∑ b : α, p i b * f (Function.update x i b)) =
        ∑ S : Finset ι, ∑ b : α, p i b *
          g S (Function.update x i b) := by
    calc
      (∑ b : α, p i b * f (Function.update x i b)) =
        ∑ b : α, p i b *
          (∑ S : Finset ι, g S (Function.update x i b)) := by
            apply Finset.sum_congr rfl
            intro b _
            rw [hdecomp]
      _ = ∑ b : α, ∑ S : Finset ι,
          p i b * g S (Function.update x i b) := by
            simp only [Finset.mul_sum]
      _ = ∑ S : Finset ι, ∑ b : α,
          p i b * g S (Function.update x i b) := Finset.sum_comm
  have hterm (S : Finset ι) :
      g S (Function.update x i a) -
        (∑ b : α, p i b * g S (Function.update x i b)) =
      if S.card ≤ 2 ∧ i ∈ S then
        esComp p S f (Function.update x i a) else 0 := by
    by_cases hs : S.card ≤ 2
    · by_cases hi : i ∈ S
      · have hcenter :=
          actual_esComp_centered p hp1 f S i hi x
        simp only [g, if_pos hs] at *
        simp [hs, hi, hcenter]
      · have hinv (b : α) :
            esComp p S f (Function.update x i b) =
              esComp p S f x :=
          dependsOn_update_outside S (esComp p S f)
            (esComp_dependsOn p S f) i hi x b
        have havg :
            (∑ b : α,
              p i b * esComp p S f (Function.update x i b)) =
            esComp p S f x := by
          simp_rw [hinv]
          rw [← Finset.sum_mul, hp1 i, one_mul]
        simp only [g, if_pos hs]
        rw [hinv a, havg]
        simp [hs, hi]
    · simp [g, hs]
  calc
    actualCenteredSection p f i x a =
        (∑ S : Finset ι, g S (Function.update x i a)) -
        (∑ S : Finset ι, ∑ b : α,
          p i b * g S (Function.update x i b)) := by
          unfold actualCenteredSection
          rw [hdecomp, hsum]
    _ = ∑ S : Finset ι,
        (g S (Function.update x i a) -
          ∑ b : α, p i b * g S (Function.update x i b)) := by
            rw [Finset.sum_sub_distrib]
    _ = ∑ S : Finset ι,
        if S.card ≤ 2 ∧ i ∈ S then
          esComp p S f (Function.update x i a)
        else 0 := by
          apply Finset.sum_congr rfl
          intro S _
          exact hterm S

end Nightfall.Observability.ActualESConditionalSection
