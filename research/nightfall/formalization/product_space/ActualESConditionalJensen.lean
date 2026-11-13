import ActualESConditionalSection

/-!
# Source-conditioned Hilbert L1 Jensen (arbitrary finite categorical laws)

Proves norm(E Y | S) ≤ E(norm Y | S), with the actual independent source
product law, and L2 norm defined by coordinate i's own weights.
The theorem allows zero-probability symbols and needs NO positive atom
floor, Hoeffding degree, fourth-moment oracle, synthetic neighbor map,
or externally supplied Jensen contraction.

The vector is a finite real table with weighted Euclidean norm. A
weighted Cauchy-Schwarz duality argument proves the finite weighted
Minkowski contraction. The application uses the genuine centered
sourceSection f and S, a Finset of distinct actual neighbors.

This is a pointwise conditional contraction. Its identification with
a canonical pair-sum and the final integration/energy identities are
separate proof obligations toward Q2.
-/

namespace Nightfall.Observability.ActualESConditionalJensen

open Finset
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESConditionalSection

variable {Ω α : Type*} [Fintype Ω] [Fintype α]

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

/-- Actual conditional Jensen for the L2(p_i) norm of a centered section.
Finite neighbor sets are genuine coordinate subsets, so repeated-neighbor
sampling is impossible. This is the missing norm-contraction operator.
-/
theorem actual_source_section_hilbert_jensen
    {ι : Type} [Fintype ι] [DecidableEq ι]
    [DecidableEq α]
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι)
    (x : ι → α) :
    norm (p i) (fun a => averageSourceSection p f i S x a) ≤
      ∑ y : ι → α, prodMass p y *
        norm (p i) (sourceSection p f i (merge S x y)) := by
  unfold averageSourceSection
  exact weighted_hilbert_jensen
    (prodMass p) (p i)
    (fun y a => sourceSection p f i (merge S x y) a)
    (prodMass_nonneg' p hp) (hp i)

end Nightfall.Observability.ActualESConditionalJensen
