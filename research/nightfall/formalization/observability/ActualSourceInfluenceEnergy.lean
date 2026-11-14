import ActualSourceSingletonProjection
import ArbitraryLawFourthMoment

/-!
# Q2: current-pin actual-coordinate energy equals resampling influence

A TRUE actual source f with arbitrary finite independent law p is used.
The genuine integrated coordinate-section energy equals the resampling
influence defined directly from f, not an assumed energy certificate.

This proof is independent of the Hoeffding degree hypothesis and valid
for zero-mass atoms, and proves the exact variance/pair-resampling algebra
under normalized weights without using probabilistic theorems as axioms.

It does NOT alone identify selected pair energies with source influence,
nor close the terminal dimension-free quadratic influence theorem.
-/

namespace Nightfall.Observability.ActualSourceInfluenceEnergy

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.QuadraticMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Weighted finite Popoviciu/variance-resampling identity, exact
for arbitrary normalized weights, even signed ones. -/
theorem weighted_centered_eq_pair
    {A : Type*} [Fintype A]
    (q : A → ℝ) (g : A → ℝ)
    (hq1 : (∑ a : A, q a) = 1) :
    (∑ a : A,
      q a * (g a - ∑ b : A, q b * g b)^2) =
    ∑ a : A, ∑ b : A,
      q a * q b * ((g a - g b)^2 / 2) := by
  classical
  let m : ℝ := ∑ a : A, q a * g a
  let s : ℝ := ∑ a : A, q a * (g a)^2
  have hleft :
      (∑ a : A, q a * (g a - m)^2) = s - m^2 := by
    calc
      (∑ a : A, q a * (g a - m)^2) =
        ∑ a : A, (q a * (g a)^2 -
          (2*m) * (q a * g a) + m^2 * q a) := by
            apply Finset.sum_congr rfl
            intro a _
            ring
      _ = (∑ a : A, q a * (g a)^2) -
            ∑ a : A, (2*m) * (q a * g a) +
            ∑ a : A, m^2 * q a := by
              rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
      _ = s - (2*m)*m + m^2*1 := by
            rw [← Finset.mul_sum, ← Finset.mul_sum, hq1]
      _ = s - m^2 := by ring
  have hpair1 :
      (∑ a : A, ∑ b : A, (q a * (g a)^2) * q b) = s := by
    calc
      _ = (∑ a : A, q a * (g a)^2) *
            (∑ b : A, q b) := tensor_sum_factor _ _
      _ = s := by rw [hq1, mul_one]
  have hpair2 :
      (∑ a : A, ∑ b : A, q a * (q b * (g b)^2)) = s := by
    calc
      _ = (∑ a : A, q a) *
            (∑ b : A, q b * (g b)^2) := tensor_sum_factor _ _
      _ = s := by rw [hq1, one_mul]
  have hpair3 :
      (∑ a : A, ∑ b : A, (q a * g a) * (q b * g b)) = m^2 := by
    calc
      _ = (∑ a : A, q a * g a) *
            (∑ b : A, q b * g b) := tensor_sum_factor _ _
      _ = m^2 := by dsimp [m]; ring
  have hright :
      (∑ a : A, ∑ b : A,
        q a * q b * ((g a - g b)^2 / 2)) = s - m^2 := by
    calc
      _ = ∑ a : A, ∑ b : A,
        ((q a * (g a)^2) * q b +
          q a * (q b * (g b)^2) -
          2 * ((q a * g a) * (q b * g b))) / 2 := by
            apply Finset.sum_congr rfl
            intro a _
            apply Finset.sum_congr rfl
            intro b _
            ring
      _ = (∑ a : A, ∑ b : A, (q a * (g a)^2) * q b) / 2 +
          (∑ a : A, ∑ b : A, q a * (q b * (g b)^2)) / 2 -
          (∑ a : A, ∑ b : A, (q a * g a) * (q b * g b)) := by
            simp only [sub_div, add_div, Finset.sum_add_distrib,
              Finset.sum_sub_distrib, Finset.sum_div]
            ring_nf
      _ = s - m^2 := by rw [hpair1, hpair2, hpair3]; ring
  change (∑ a : A, q a * (g a - m)^2) =
    ∑ a : A, ∑ b : A, q a * q b * ((g a - g b)^2 / 2)
  exact hleft.trans hright.symm

/-- Exact resampling influence in the SAME original coordinate law.
No external product influence or historical compiler import. -/
noncomputable def actualSourceInfluence
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, originalMass p x *
    (∑ b : α, p i b * ((f x - f (Function.update x i b))^2 / 2))

/-- The true source coordinate-section energy, with no synthetic
neighbor sampling and no externally supplied energy budget. -/
noncomputable def sourceSectionEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, originalMass p x *
    (∑ a : α, p i a * (originalSourceSection p f i x a)^2)

/-- The original source's coordinate section has L² energy exactly
equal to its resampling influence. The proof uses only genuine
finite product resampling and the weighted pair identity. -/
theorem actual_source_section_energy_eq_influence
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    sourceSectionEnergy p f i = actualSourceInfluence p f i := by
  let G : (ι → α) → ℝ := fun x =>
    ∑ b : α, p i b *
      ((f x - f (Function.update x i b))^2 / 2)
  have hpoint (x : ι → α) :
      (∑ a : α, p i a * (originalSourceSection p f i x a)^2) =
      ∑ a : α, ∑ b : α,
        p i a * p i b *
          ((f (Function.update x i a) -
            f (Function.update x i b))^2 / 2) := by
    simpa only [sourceSection] using
      weighted_centered_eq_pair (p i)
        (fun a => f (Function.update x i a)) (hp1 i)
  have hG (x : ι → α) (a : α) :
      G (Function.update x i a) =
       ∑ b : α, p i b *
          ((f (Function.update x i a) -
            f (Function.update x i b))^2 / 2) := by
    dsimp [G]
    apply Finset.sum_congr rfl
    intro b _
    simp
  calc
    sourceSectionEnergy p f i =
      ∑ x : ι → α, originalMass p x *
        (∑ a : α, ∑ b : α, p i a * p i b *
          ((f (Function.update x i a) -
            f (Function.update x i b))^2 / 2)) := by
          unfold sourceSectionEnergy
          apply Finset.sum_congr rfl
          intro x _
          rw [hpoint x]
    _ = ∑ x : ι → α, ∑ a : α,
        originalMass p x * p i a * G (Function.update x i a) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          rw [hG x a]
          simp only [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring
    _ = ∑ x : ι → α, originalMass p x * G x := by
          exact actual_source_resample_sum p hp1 i G
    _ = actualSourceInfluence p f i := by
          unfold actualSourceInfluence G
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring

end Nightfall.Observability.ActualSourceInfluenceEnergy
