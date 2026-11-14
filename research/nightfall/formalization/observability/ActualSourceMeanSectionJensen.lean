import ActualSourceIntegratedSections
import ActualSourceInfluenceEnergy

/-!
# Original-product mean-section Jensen, no auxiliary scalar budget

The original finite categorical law p determines both the centering
section U_i and its expected L2(p_i) norm. Weighted Hilbert Jensen
implies the L2 norm of the mean section is at most that expected norm.
No synthetic source distribution or lower atom-mass assumption.
-/

namespace Nightfall.Observability.ActualSourceMeanSectionJensen

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]

noncomputable def sqNorm (q : α → ℝ) (v : α → ℝ) : ℝ :=
  ∑ a : α, q a * (v a)^2

noncomputable def norm (q : α → ℝ) (v : α → ℝ) : ℝ :=
  Real.sqrt (sqNorm q v)

theorem sqNorm_nonneg (q : α → ℝ)
    (hq : ∀ a, 0 ≤ q a) (v : α → ℝ) :
    0 ≤ sqNorm q v := by
  unfold sqNorm
  exact Finset.sum_nonneg (fun a _ => mul_nonneg (hq a) (sq_nonneg (v a)))

/-- Weighted Euclidean Cauchy: dot(v,w) ≤ ||v||_q ||w||_q.
The nonnegativity of q, not normalization, is the only weight premise. -/
theorem weighted_dot_le_norm_mul
    (q : α → ℝ) (hq : ∀ a, 0 ≤ q a)
    (v w : α → ℝ) :
    (∑ a : α, q a * v a * w a) ≤ norm q v * norm q w := by
  classical
  have hcs := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
    (s := (Finset.univ : Finset α))
    (r := fun a => q a * v a * w a)
    (f := fun a => q a * (v a)^2)
    (g := fun a => q a * (w a)^2)
    (fun a _ => mul_nonneg (hq a) (sq_nonneg _))
    (fun a _ => mul_nonneg (hq a) (sq_nonneg _))
    (fun a _ => by ring)
  let A : ℝ := norm q v
  let C : ℝ := norm q w
  have hA0 : 0 ≤ A := Real.sqrt_nonneg _
  have hC0 : 0 ≤ C := Real.sqrt_nonneg _
  have hAsq : A^2 = sqNorm q v :=
    Real.sq_sqrt (sqNorm_nonneg q hq v)
  have hCsq : C^2 = sqNorm q w :=
    Real.sq_sqrt (sqNorm_nonneg q hq w)
  have hdot :
      (∑ a : α, q a * v a * w a)^2 ≤ (A*C)^2 := by
    dsimp [sqNorm] at hAsq hCsq
    nlinarith [hcs]
  have hnonneg : 0 ≤ A*C := mul_nonneg hA0 hC0
  by_cases hd : (∑ a : α, q a * v a * w a) ≤ 0
  · exact hd.trans hnonneg
  · have hd0 : 0 ≤ (∑ a : α, q a * v a * w a) :=
      le_of_lt (lt_of_not_ge hd)
    change (∑ a : α, q a * v a * w a) ≤ A*C
    nlinarith [hdot]

/-- The L1-Jensen form of finite weighted Hilbert contraction, proven
from Cauchy rather than postulated as a conditional expectation axiom. -/
theorem weighted_hilbert_jensen
    (μ : Ω → ℝ) (q : α → ℝ) (Y : Ω → α → ℝ)
    (hμ : ∀ y, 0 ≤ μ y)
    (hq : ∀ a, 0 ≤ q a) :
    norm q (fun a => ∑ y : Ω, μ y * Y y a) ≤
      ∑ y : Ω, μ y * norm q (Y y) := by
  classical
  let w : α → ℝ := fun a => ∑ y : Ω, μ y * Y y a
  let A : ℝ := norm q w
  let z : ℝ := ∑ y : Ω, μ y * norm q (Y y)
  have hA : 0 ≤ A := Real.sqrt_nonneg _
  have hz : 0 ≤ z := by
    dsimp [z]
    apply Finset.sum_nonneg
    intro y _
    exact mul_nonneg (hμ y) (Real.sqrt_nonneg _)
  have hdot (y : Ω) :
      (∑ a : α, q a * w a * Y y a) ≤ A * norm q (Y y) :=
    weighted_dot_le_norm_mul q hq w (Y y)
  have hmean :
      sqNorm q w =
      ∑ y : Ω, μ y * (∑ a : α, q a * w a * Y y a) := by
    unfold sqNorm
    calc
      (∑ a : α, q a * (w a)^2) =
          ∑ a : α, (q a * w a) *
            (∑ y : Ω, μ y * Y y a) := by
          apply Finset.sum_congr rfl
          intro a _
          dsimp [w]
          ring
      _ = ∑ a : α, ∑ y : Ω,
            (q a * w a) * (μ y * Y y a) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
      _ = ∑ a : α, ∑ y : Ω,
            μ y * (q a * w a * Y y a) := by
          apply Finset.sum_congr rfl
          intro a _
          apply Finset.sum_congr rfl
          intro y _
          ring
      _ = ∑ y : Ω, ∑ a : α,
            μ y * (q a * w a * Y y a) := Finset.sum_comm
      _ = ∑ y : Ω, μ y *
            (∑ a : α, q a * w a * Y y a) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
  have hsum :
      sqNorm q w ≤ A * z := by
    calc
      sqNorm q w =
          ∑ y : Ω, μ y *
            (∑ a : α, q a * w a * Y y a) := hmean
      _ ≤ ∑ y : Ω, μ y * (A * norm q (Y y)) := by
          apply Finset.sum_le_sum
          intro y _
          exact mul_le_mul_of_nonneg_left (hdot y) (hμ y)
      _ = A * z := by
          dsimp [z]
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro y _
          ring
  have hAsq : A^2 = sqNorm q w :=
    Real.sq_sqrt (sqNorm_nonneg q hq w)
  have hbound : A^2 ≤ A*z := by nlinarith [hsum]
  by_cases hzero : A = 0
  · change A ≤ z
    rw [hzero]
    exact hz
  have hpos : 0 < A := lt_of_le_of_ne hA (Ne.symm hzero)
  have hAz : A ≤ z := by
    by_contra hnot
    have hs : z < A := lt_of_not_ge hnot
    have hprod := mul_lt_mul_of_pos_left hs hpos
    nlinarith [hprod, hbound]
  exact hAz


noncomputable def originalSingletonNorm
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  Real.sqrt (∑ a : α, p i a *
    (∑ x : ι → α, originalMass p x *
      sourceCenteredSection p f i x a)^2)

/-- The genuine singleton-mean L2 norm is no greater than the
expected original-source centered-section L2 norm. -/
theorem original_singleton_norm_le_source_mean_section_norm
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ) (i : ι) :
    originalSingletonNorm p f i ≤ sourceMeanSectionNorm p f i := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun j _ => hp j (x j))
  have h := weighted_hilbert_jensen
    (originalMass p) (p i)
    (fun x a => sourceCenteredSection p f i x a)
    hm (hp i)
  simpa only [originalSingletonNorm, sourceMeanSectionNorm,
    sourceSectionNorm, sourceCenteredSection,
    norm, sqNorm] using h

/-- The author-analytic 8B section bound supplies the additive
mean-section budget for the same genuine source law, by Jensen. -/
theorem original_singleton_norm_sum_le_eight
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.Observability.ActualSourceANOVA.ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B) :
    (∑ i : ι, originalSingletonNorm p f i) ≤ 8 * B := by
  calc
    (∑ i : ι, originalSingletonNorm p f i) ≤
      ∑ i : ι, sourceMeanSectionNorm p f i :=
        Finset.sum_le_sum (fun i _ =>
          original_singleton_norm_le_source_mean_section_norm p hp f i)
    _ ≤ 8 * B :=
      actual_source_integrated_eight_budget p hp hp1 f hdegree B hB hf

end Nightfall.Observability.ActualSourceMeanSectionJensen
