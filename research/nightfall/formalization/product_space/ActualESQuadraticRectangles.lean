import QuadraticHoeffdingBridge

/-!
# Actual source quadratic rectangle reduction

For a genuine finite-product Efron-Stein degree-two source f, a
mixed four-point difference in coordinates i,j equals the mixed
difference of its canonical pair component esComp p {i,j} f.
No abstract block polynomial, matching mass, row budget, or fourth
moment is supplied as a hypothesis. This is an actual-source local
reduction, not the missing multi-block global parity theorem.

The mathematical effect: a mixed i,j rectangle annihilates every
Hoeffding interaction supported on <=2 coordinates other than {i,j}.
The final proof then uses only the existing source decomposition and
coordinate-support dependency of the canonical components.
-/

namespace Nightfall.Observability.ActualESQuadraticRectangles

open Finset Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.QuadraticANOVA

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Four-corner mixed difference of an actual finite-table function. -/
noncomputable def sourceRectangle
    (g : (ι → α) → ℝ) (x : ι → α) (i j : ι)
    (a0 a1 b0 b1 : α) : ℝ :=
  g (Function.update (Function.update x i a0) j b0) -
  g (Function.update (Function.update x i a0) j b1) -
  g (Function.update (Function.update x i a1) j b0) +
  g (Function.update (Function.update x i a1) j b1)

/-- Coordinates outside a canonical support are irrelevant. -/
theorem dependsOn_update_outside
    (S : Finset ι) (g : (ι → α) → ℝ)
    (hdep : DependsOn S g)
    (i : ι) (hi : i ∉ S) (x : ι → α) (a : α) :
    g (Function.update x i a) = g x := by
  apply hdep
  intro k hk
  have hki : k ≠ i := by
    intro heq
    exact hi (heq ▸ hk)
  exact Function.update_of_ne hki a x

/-- A rectangle vanishes for any term missing the right coordinate. -/
theorem sourceRectangle_zero_right
    (S : Finset ι) (g : (ι → α) → ℝ)
    (hdep : DependsOn S g)
    (j : ι) (hj : j ∉ S)
    (x : ι → α) (i : ι)
    (a0 a1 b0 b1 : α) :
    sourceRectangle g x i j a0 a1 b0 b1 = 0 := by
  unfold sourceRectangle
  rw [dependsOn_update_outside S g hdep j hj _ b0,
      dependsOn_update_outside S g hdep j hj _ b1,
      dependsOn_update_outside S g hdep j hj _ b0,
      dependsOn_update_outside S g hdep j hj _ b1]
  ring

/-- A rectangle vanishes for any term missing the left coordinate. -/
theorem sourceRectangle_zero_left
    (S : Finset ι) (g : (ι → α) → ℝ)
    (hdep : DependsOn S g)
    (i j : ι) (hij : i ≠ j) (hi : i ∉ S)
    (x : ι → α) (a0 a1 b0 b1 : α) :
    sourceRectangle g x i j a0 a1 b0 b1 = 0 := by
  have hswap (a b : α) :
      g (Function.update (Function.update x i a) j b) =
      g (Function.update x j b) := by
    rw [Function.update_comm hij]
    exact dependsOn_update_outside S g hdep i hi _ a
  unfold sourceRectangle
  rw [hswap a0 b0, hswap a0 b1, hswap a1 b0, hswap a1 b1]
  ring

/-- Four-point differences distribute exactly through finite sums. -/
theorem sourceRectangle_sum
    {E : Type*} [Fintype E] (h : E → (ι → α) → ℝ)
    (x : ι → α) (i j : ι) (a0 a1 b0 b1 : α) :
    sourceRectangle (fun y => ∑ e : E, h e y) x i j a0 a1 b0 b1 =
      ∑ e : E, sourceRectangle (h e) x i j a0 a1 b0 b1 := by
  unfold sourceRectangle
  simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib]

/-- The actual source's four-point mixed difference has exactly the
contribution of its canonical {i,j} Efron-Stein interaction. The
degree-two hypothesis is used directly, not replaced by a supplied
polynomial representation or a desired matching bound. -/
theorem actual_quadratic_rectangle_eq_es_pair
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i j : ι) (hij : i ≠ j)
    (x : ι → α) (a0 a1 b0 b1 : α) :
    sourceRectangle f x i j a0 a1 b0 b1 =
      sourceRectangle (esComp p ({i,j} : Finset ι) f)
        x i j a0 a1 b0 b1 := by
  classical
  have hdecomp (y : ι → α) :
      f y = ∑ S : Finset ι,
        if S.card ≤ 2 then esComp p S f y else 0 :=
    quadratic_hoeffding_decomposition p hp1 f hdegree y
  have hcard : ({i,j} : Finset ι).card = 2 := by
    simp [hij]
  have hsum :
      (∑ S : Finset ι,
        sourceRectangle
          (fun y => if S.card ≤ 2 then esComp p S f y else 0)
          x i j a0 a1 b0 b1) =
      sourceRectangle (esComp p ({i,j} : Finset ι) f)
        x i j a0 a1 b0 b1 := by
    rw [Finset.sum_eq_single ({i,j} : Finset ι)]
    · simp [hcard]
    · intro S _ hne
      by_cases hs : S.card ≤ 2
      · simp only [if_pos hs]
        have hmiss : i ∉ S ∨ j ∉ S := by
          by_contra hn
          push_neg at hn
          have hsub : ({i,j} : Finset ι) ⊆ S := by
            intro k hk
            have hk' : k = i ∨ k = j := by simpa using hk
            rcases hk' with rfl | rfl
            · exact hn.1
            · exact hn.2
          have hEq : ({i,j} : Finset ι) = S :=
            Finset.eq_of_subset_of_card_le hsub (by omega)
          exact hne hEq.symm
        rcases hmiss with hi | hj
        · exact sourceRectangle_zero_left S (esComp p S f)
            (esComp_dependsOn p S f) i j hij hi x a0 a1 b0 b1
        · exact sourceRectangle_zero_right S (esComp p S f)
            (esComp_dependsOn p S f) j hj x i a0 a1 b0 b1
      · simp [hs, sourceRectangle]
    · intro hn
      exact (hn (Finset.mem_univ _)).elim
  calc
    sourceRectangle f x i j a0 a1 b0 b1 =
      sourceRectangle
        (fun y => ∑ S : Finset ι,
          if S.card ≤ 2 then esComp p S f y else 0)
        x i j a0 a1 b0 b1 := by
          unfold sourceRectangle
          simp only [hdecomp]
    _ = ∑ S : Finset ι,
      sourceRectangle
        (fun y => if S.card ≤ 2 then esComp p S f y else 0)
        x i j a0 a1 b0 b1 :=
          sourceRectangle_sum
            (fun S : Finset ι => fun y =>
              if S.card ≤ 2 then esComp p S f y else 0)
            x i j a0 a1 b0 b1
    _ = sourceRectangle (esComp p ({i,j} : Finset ι) f)
       x i j a0 a1 b0 b1 := hsum


/-- The rectangle of any function depending only on i,j is independent of
all background coordinates. -/
theorem pair_dependent_rectangle_base_independent
    (g : (ι → α) → ℝ) (i j : ι) (hij : i ≠ j)
    (hdep : DependsOn ({i,j} : Finset ι) g)
    (x y : ι → α) (a0 a1 b0 b1 : α) :
    sourceRectangle g x i j a0 a1 b0 b1 =
      sourceRectangle g y i j a0 a1 b0 b1 := by
  have hcorner (a b : α) :
      g (Function.update (Function.update x i a) j b) =
        g (Function.update (Function.update y i a) j b) := by
    apply hdep
    intro k hk
    have hk' : k = i ∨ k = j := by simpa using hk
    rcases hk' with rfl | rfl
    · simp [hij.symm]
    · simp
  unfold sourceRectangle
  rw [hcorner a0 b0, hcorner a0 b1,
      hcorner a1 b0, hcorner a1 b1]

/-- Consequently a mixed rectangle of the genuine degree-two source
does not depend on any unmatched coordinates. This supplies the
pointwise invariance premise for telescoping the parity matching laws. -/
theorem actual_quadratic_rectangle_base_independent
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i j : ι) (hij : i ≠ j)
    (x y : ι → α) (a0 a1 b0 b1 : α) :
    sourceRectangle f x i j a0 a1 b0 b1 =
      sourceRectangle f y i j a0 a1 b0 b1 := by
  rw [actual_quadratic_rectangle_eq_es_pair p hp1 f hdegree i j hij
        x a0 a1 b0 b1,
      actual_quadratic_rectangle_eq_es_pair p hp1 f hdegree i j hij
        y a0 a1 b0 b1]
  exact pair_dependent_rectangle_base_independent
    (esComp p ({i,j} : Finset ι) f) i j hij
    (esComp_dependsOn p ({i,j} : Finset ι) f)
    x y a0 a1 b0 b1


end Nightfall.Observability.ActualESQuadraticRectangles
