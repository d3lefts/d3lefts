import ActualESOrthogonality

/-!
# Original-product ANOVA variance energy (no synthetic draws)

Two independent ingredients: a finite weighted square expansion and
genuine Efron–Stein pairwise orthogonality.  This file aims to prove
that the original function's variance is exactly the total energy of
its nonconstant canonical components, with zero atoms allowed.

It does NOT claim the maximal-influence or Q2 conclusion.
-/

namespace Nightfall.Observability.ActualESGlobalVariance

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESOrthogonality

/-- Pairwise orthogonal finite families have additive weighted squared
norm.  This identity does not assume nonnegative weights. -/
theorem weighted_square_of_orthogonal_sum
    {Ω κ : Type*} [Fintype Ω] [DecidableEq κ]
    (μ : Ω → ℝ) (g : κ → Ω → ℝ)
    (horth : ∀ i j : κ, i ≠ j →
      (∑ x : Ω, μ x * g i x * g j x) = 0)
    (S : Finset κ) :
    (∑ x : Ω, μ x * (S.sum (fun k => g k x))^2) =
      S.sum (fun k => ∑ x : Ω, μ x * (g k x)^2) := by
  classical
  induction S using Finset.induction_on with
  | empty => simp
  | @insert a S ha ih =>
    have hcross :
        (∑ x : Ω, μ x * g a x *
          (S.sum (fun j => g j x))) = 0 := by
      calc
        (∑ x : Ω, μ x * g a x *
          (S.sum (fun j => g j x))) =
            ∑ x : Ω, S.sum (fun j => μ x * g a x * g j x) := by
              apply Finset.sum_congr rfl
              intro x _
              rw [Finset.mul_sum]
        _ = S.sum (fun j => ∑ x : Ω,
            μ x * g a x * g j x) := Finset.sum_comm
        _ = 0 := by
          apply Finset.sum_eq_zero
          intro j hj
          apply horth a j
          intro heq
          exact ha (heq ▸ hj)
    have hpoint (x : Ω) :
        μ x * (g a x + S.sum (fun j => g j x))^2 =
          μ x * (g a x)^2 +
          μ x * (S.sum (fun j => g j x))^2 +
          2 * (μ x * g a x * (S.sum (fun j => g j x))) := by
      ring
    have hexpand :
        (∑ x : Ω, μ x *
          (g a x + S.sum (fun j => g j x))^2) =
          (∑ x : Ω, μ x * (g a x)^2) +
          (∑ x : Ω, μ x *
            (S.sum (fun j => g j x))^2) +
          2 * (∑ x : Ω,
            μ x * g a x * (S.sum (fun j => g j x))) := by
      calc
        _ = ∑ x : Ω,
          (μ x * (g a x)^2 +
          μ x * (S.sum (fun j => g j x))^2 +
          2 * (μ x * g a x *
            (S.sum (fun j => g j x)))) := by
              apply Finset.sum_congr rfl
              intro x _
              exact hpoint x
        _ = _ := by
          rw [Finset.sum_add_distrib, Finset.sum_add_distrib]
          rw [← Finset.mul_sum]
    calc
      (∑ x : Ω, μ x *
        ((insert a S).sum (fun k => g k x))^2) =
        (∑ x : Ω, μ x *
          (g a x + S.sum (fun j => g j x))^2) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.sum_insert ha]
      _ = (∑ x : Ω, μ x * (g a x)^2) +
          (∑ x : Ω, μ x *
            (S.sum (fun j => g j x))^2) +
          2 * (∑ x : Ω,
            μ x * g a x * (S.sum (fun j => g j x))) := hexpand
      _ = (insert a S).sum
          (fun k => ∑ x : Ω, μ x * (g k x)^2) := by
            rw [ih, hcross, Finset.sum_insert ha]
            ring

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Canonical Efron-Stein terms with the constant sector omitted. -/
noncomputable def nonconstantComp
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (S : Finset ι) (x : ι → α) : ℝ :=
  if S = ∅ then 0 else esComp p S f x

theorem esComp_empty_eq_pexp
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (x : ι → α) :
    esComp p (∅ : Finset ι) f x = pexp p f := by
  have hmerge (y : ι → α) : merge (∅ : Finset ι) x y = y := by
    funext k
    simp [merge]
  simp [esComp, condExp, pexp, hmerge]

theorem actual_source_centered_eq_sum_nonconstant
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (x : ι → α) :
    f x - pexp p f =
      ∑ S : Finset ι, nonconstantComp p f S x := by
  classical
  have hsum :
      (∑ S : Finset ι, nonconstantComp p f S x) =
        (∑ S : Finset ι, esComp p S f x) -
          esComp p (∅ : Finset ι) f x := by
    calc
      (∑ S : Finset ι, nonconstantComp p f S x) =
          ∑ S : Finset ι,
            (esComp p S f x -
              if S = ∅ then esComp p (∅ : Finset ι) f x else 0) := by
                apply Finset.sum_congr rfl
                intro S _
                by_cases hs : S = ∅ <;> simp [nonconstantComp, hs]
      _ = (∑ S : Finset ι, esComp p S f x) -
          (∑ S : Finset ι,
            if S = ∅ then esComp p (∅ : Finset ι) f x else 0) := by
              rw [Finset.sum_sub_distrib]
      _ = (∑ S : Finset ι, esComp p S f x) -
            esComp p (∅ : Finset ι) f x := by simp
  rw [hsum, es_decomp p hp1 f x, esComp_empty_eq_pexp]

/-- Variance of the ACTUAL source is precisely the total squared energy
of all nonconstant canonical Efron–Stein interactions. -/
theorem actual_source_variance_eq_nonconstant_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) :
    pvar p f =
      ∑ S : Finset ι,
        if S = ∅ then (0 : ℝ)
        else ∑ x : ι → α,
          prodMass p x * (esComp p S f x)^2 := by
  classical
  have horth :
      ∀ S T : Finset ι, S ≠ T →
      (∑ x : ι → α, prodMass p x *
        nonconstantComp p f S x *
        nonconstantComp p f T x) = 0 := by
    intro S T hne
    by_cases hS : S = ∅
    · simp [nonconstantComp, hS]
    · by_cases hT : T = ∅
      · simp [nonconstantComp, hT]
      · simpa [nonconstantComp, hS, hT] using
          actual_esComp_orthogonal p hp1 f S T hne
  calc
    pvar p f =
        ∑ x : ι → α, prodMass p x *
          (∑ S : Finset ι, nonconstantComp p f S x)^2 := by
            unfold pvar
            apply Finset.sum_congr rfl
            intro x _
            rw [← actual_source_centered_eq_sum_nonconstant p hp1 f x]
    _ = ∑ S : Finset ι, ∑ x : ι → α,
          prodMass p x * (nonconstantComp p f S x)^2 :=
            weighted_square_of_orthogonal_sum
              (prodMass p) (nonconstantComp p f) horth Finset.univ
    _ = ∑ S : Finset ι,
          if S = ∅ then (0 : ℝ)
          else ∑ x : ι → α,
            prodMass p x * (esComp p S f x)^2 := by
              apply Finset.sum_congr rfl
              intro S _
              by_cases hS : S = ∅ <;> simp [nonconstantComp, hS]

end Nightfall.Observability.ActualESGlobalVariance
