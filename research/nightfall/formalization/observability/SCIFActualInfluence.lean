import ActualSourceInfluenceEnergy

/-!
# SCIF actual-source influence law-change bridge — finite, arbitrary degree

Unlike pair-table-only identities, these declarations use the SAME
original full-product influence and mass definitions used by the Q2 theorem.
Changing the marginal of k is NOT assumed to preserve any other law;
only the explicitly displayed unchanged coordinate assumption is used.
The formulas hold for arbitrary f, irrespective of Efron–Stein degree,
and include zero-mass atoms. Nonnegative normalized probability laws
are needed only when interpreting the weights probabilistically.

These are not a terminal SCOF owner package or canonical pair recentering.
-/

namespace Nightfall.Observability.SCIFActualInfluence
open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]

noncomputable def residual (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (i : ι) (x : ι → α) : ℝ :=
  f x - ∑ a : α, p i a * f (Function.update x i a)

noncomputable def lawDelta (p q : ι → α → ℝ)
    (f : (ι → α) → ℝ) (i : ι) (x : ι → α) : ℝ :=
  ∑ a : α, (q i a - p i a) * f (Function.update x i a)

/-- The actual source resampling influence is precisely residual square energy. -/
theorem source_influence_eq_residual_energy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) :
    sourceInfluence p f i =
      ∑ x : ι → α, originalMass p x * (residual p f i x)^2 := by
  rfl

/-- Pointwise exact law-change formula, including formerly impossible atoms. -/
theorem residual_law_change
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) :
    residual q f i x = residual p f i x - lawDelta p q f i x := by
  classical
  have hd :
      lawDelta p q f i x =
        (∑ a : α, q i a * f (Function.update x i a)) -
        (∑ a : α, p i a * f (Function.update x i a)) := by
    unfold lawDelta
    simp_rw [sub_mul]
    rw [Finset.sum_sub_distrib]
  rw [hd]
  unfold residual
  ring

/-- Only the edited marginal can change a centered residual at a fixed
full input x; a neighbor's influence can still change through the mass. -/
theorem residual_unchanged_coordinate
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (h : p i = q i) (x : ι → α) :
    residual q f i x = residual p f i x := by
  simp only [residual, ← h]

/-- Exact full-product influence change for any unedited coordinate.
This is an identity of the actual Efron–Stein resampling influences,
not an auxiliary pair energy. -/
theorem source_influence_unedited_exact
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (h : p i = q i) :
    sourceInfluence q f i - sourceInfluence p f i =
      ∑ x : ι → α, (originalMass q x - originalMass p x) *
        (residual p f i x)^2 := by
  classical
  rw [source_influence_eq_residual_energy,
      source_influence_eq_residual_energy,
      ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro x _
  rw [residual_unchanged_coordinate p q f i h x]
  ring

/-- The edited-coordinate influence is the exact source integral
of the old centered residual minus the law-change correction. -/
theorem source_influence_edited_exact
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) :
    sourceInfluence q f i =
      ∑ x : ι → α, originalMass q x *
        (residual p f i x - lawDelta p q f i x)^2 := by
  classical
  rw [source_influence_eq_residual_energy]
  apply Finset.sum_congr rfl
  intro x _
  rw [residual_law_change]

/-- Fully expanded exact source influence difference, including
the change of full-product mass and the cross and quadratic terms. -/
theorem source_influence_edited_difference
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) :
    sourceInfluence q f i - sourceInfluence p f i =
      (∑ x : ι → α,
        (originalMass q x - originalMass p x) * (residual p f i x)^2) -
      2 * (∑ x : ι → α,
        originalMass q x * residual p f i x * lawDelta p q f i x) +
      (∑ x : ι → α,
        originalMass q x * (lawDelta p q f i x)^2) := by
  classical
  rw [source_influence_edited_exact p q f i,
      source_influence_eq_residual_energy p f i]
  calc
    (∑ x : ι → α,
      originalMass q x *
        (residual p f i x - lawDelta p q f i x)^2) -
      (∑ x : ι → α, originalMass p x * (residual p f i x)^2) =
      ∑ x : ι → α,
        (originalMass q x *
          (residual p f i x - lawDelta p q f i x)^2 -
          originalMass p x * (residual p f i x)^2) := by
            rw [Finset.sum_sub_distrib]
    _ = ∑ x : ι → α,
          ((originalMass q x - originalMass p x) * (residual p f i x)^2 -
            (2 * (originalMass q x * residual p f i x *
              lawDelta p q f i x)) +
            originalMass q x * (lawDelta p q f i x)^2) := by
          apply Finset.sum_congr rfl
          intro x _
          ring
    _ = (∑ x : ι → α,
          (originalMass q x - originalMass p x) * (residual p f i x)^2) -
        2 * (∑ x : ι → α,
          originalMass q x * residual p f i x * lawDelta p q f i x) +
        (∑ x : ι → α,
          originalMass q x * (lawDelta p q f i x)^2) := by
          rw [Finset.sum_add_distrib, Finset.sum_sub_distrib,
            ← Finset.mul_sum]

end Nightfall.Observability.SCIFActualInfluence
