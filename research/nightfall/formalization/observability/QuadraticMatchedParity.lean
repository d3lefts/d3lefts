import Mathlib
import ParityBlockCancellation

/-!
# Global matching-block parity identity, actual finite selector products

The two experiments choose a fair selector in each disjoint matching block.
In the even experiment right and left endpoints use the same selector; in
the odd experiment the right selector is flipped. Each inter-block pair term
has the same expected value, regardless of its two endpoint sides. The only
surviving terms are the within-block quadratic rectangles.

This is a proof for *all finite quadratic block polynomials*, not yet the
Efron–Stein theorem for a general bounded product function.
-/

namespace Nightfall.Observability.QuadraticMatching
open Finset Nightfall.Observability.ParityBlocks
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Each block selector is equally often false and true. -/
theorem selector_double_sum (i : ι) (g : Bool → ℝ) :
    (2 : ℝ) * (∑ σ : ι → Bool, g (σ i)) =
      (Fintype.card (ι → Bool) : ℝ) * (g false + g true) := by
  have hh := sum_flip i (fun σ : ι → Bool => g (!(σ i)))
  have hswap :
      (∑ σ : ι → Bool, g (σ i)) =
        ∑ σ : ι → Bool, g (!(σ i)) := by
    simpa only [flip_self, Bool.not_not] using hh
  calc
    (2 : ℝ) * (∑ σ : ι → Bool, g (σ i)) =
        (∑ σ : ι → Bool, g (σ i)) +
        (∑ σ : ι → Bool, g (!(σ i))) := by rw [← hswap]; ring
    _ = ∑ σ : ι → Bool, (g (σ i) + g (!(σ i))) :=
       (Finset.sum_add_distrib).symm
    _ = ∑ _σ : ι → Bool, (g false + g true) := by
      apply Finset.sum_congr rfl
      intro σ _
      cases σ i <;> simp [add_comm]
    _ = _ := by simp [mul_add]

/-- Exact within-block mixed rectangle, no probabilistic approximation. -/
theorem rectangle_identity (i : ι) (w : Bool → Bool → ℝ) :
    (2:ℝ) * ((∑ σ : ι → Bool, w (σ i) (σ i)) -
      (∑ σ : ι → Bool, w (σ i) (!(σ i)))) =
    (Fintype.card (ι → Bool) : ℝ) *
      (w false false + w true true - w false true - w true false) := by
  have h1 := selector_double_sum i (fun b => w b b)
  have h2 := selector_double_sum i (fun b => w b (!b))
  simp only [Bool.not_false, Bool.not_true] at h2
  nlinarith

/-- Fubini for two finite matching-block coefficient indices. -/
theorem double_swap (h : ι → ι → (ι → Bool) → ℝ) :
    (∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι, h i j σ) =
      ∑ i : ι, ∑ j : ι, ∑ σ : ι → Bool, h i j σ := by
  calc
    (∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι, h i j σ) =
        ∑ i : ι, ∑ σ : ι → Bool, ∑ j : ι, h i j σ :=
        Finset.sum_comm
    _ = ∑ i : ι, ∑ j : ι, ∑ σ : ι → Bool, h i j σ := by
      apply Finset.sum_congr rfl
      intro i _
      exact Finset.sum_comm

/-- Every cross-block pair term cancels, for all four endpoint sides. -/
theorem cross_sum_cancellation
    (h : ι → ι → Bool → Bool → ℝ) (s t : Bool) :
    (∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
      if i = j then 0 else h i j (σ i) (σ j)) =
    ∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
      if i = j then 0 else
        h i j (if s then !(σ i) else σ i)
              (if t then !(σ j) else σ j) := by
  rw [double_swap, double_swap]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  by_cases hij : i = j
  · simp [hij]
  · simp only [if_neg hij]
    have allcases :=
      cross_block_all_sides
        (fun (_ : ι) (b : Bool) => b) (fun (_ : ι) (b : Bool) => b)
        (fun (_ : ι) (b : Bool) => b) (fun (_ : ι) (b : Bool) => b)
        (h i j) i j hij
    cases s <;> cases t
    · simpa using allcases false false
    · simpa using allcases false true
    · simpa using allcases true false
    · simpa using allcases true true

/-- Match-paired polynomial; the four off-block orientations are separate. -/
structure BlockPolynomial (ι : Type*) where
  offset : ℝ
  left : ι → Bool → ℝ
  right : ι → Bool → ℝ
  inside : ι → Bool → Bool → ℝ
  outside : Bool → Bool → ι → ι → Bool → Bool → ℝ

noncomputable def evaluate (P : BlockPolynomial ι)
    (odd : Bool) (σ : ι → Bool) : ℝ :=
  P.offset +
    (∑ i : ι, P.left i (σ i)) +
    (∑ i : ι, P.right i (if odd then !(σ i) else σ i)) +
    (∑ i : ι, P.inside i (σ i) (if odd then !(σ i) else σ i)) +
    (∑ s : Bool, ∑ t : Bool, ∑ i : ι, ∑ j : ι,
      if i = j then 0 else P.outside s t i j
        (if odd && s then !(σ i) else σ i)
        (if odd && t then !(σ j) else σ j))

noncomputable def rectangle (P : BlockPolynomial ι) (i : ι) : ℝ :=
  P.inside i false false + P.inside i true true -
    P.inside i false true - P.inside i true false

/-- Exact global difference of both product experiments. -/
theorem global_parity_identity (P : BlockPolynomial ι) :
    (2:ℝ) * ((∑ σ : ι → Bool, evaluate P false σ) -
      (∑ σ : ι → Bool, evaluate P true σ)) =
    (Fintype.card (ι → Bool):ℝ) * ∑ i : ι, rectangle P i := by
  classical
  have hright (i : ι) :
      (∑ σ : ι → Bool, P.right i (σ i)) =
        ∑ σ : ι → Bool, P.right i (!(σ i)) := by
    have h := sum_flip i (fun σ : ι → Bool => P.right i (σ i))
    simpa only [flip_self] using h.symm
  have hinside (i : ι) :
      (2:ℝ) * ((∑ σ : ι → Bool, P.inside i (σ i) (σ i)) -
        (∑ σ : ι → Bool, P.inside i (σ i) (!(σ i)))) =
      (Fintype.card (ι → Bool):ℝ) * rectangle P i :=
    rectangle_identity i (P.inside i)
  have hout (s t : Bool) :
      (∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
        if i = j then 0 else P.outside s t i j (σ i) (σ j)) =
      (∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
        if i = j then 0 else P.outside s t i j
          (if s then !(σ i) else σ i)
          (if t then !(σ j) else σ j)) :=
    cross_sum_cancellation (P.outside s t) s t
  have hcomm1 (h : ι → (ι → Bool) → ℝ) :
      (∑ σ : ι → Bool, ∑ i : ι, h i σ) =
        ∑ i : ι, ∑ σ : ι → Bool, h i σ := Finset.sum_comm
  have hcomm2 (h : Bool → Bool → (ι → Bool) → ℝ) :
      (∑ σ : ι → Bool, ∑ s : Bool, ∑ t : Bool, h s t σ) =
        ∑ s : Bool, ∑ t : Bool, ∑ σ : ι → Bool, h s t σ := by
    calc
      _ = ∑ s : Bool, ∑ σ : ι → Bool, ∑ t : Bool, h s t σ :=
        Finset.sum_comm
      _ = ∑ s : Bool, ∑ t : Bool, ∑ σ : ι → Bool, h s t σ := by
        apply Finset.sum_congr rfl
        intro s _
        exact Finset.sum_comm
  have he :
      (∑ σ : ι → Bool, evaluate P false σ) =
      (∑ σ : ι → Bool, P.offset) +
      (∑ i : ι, ∑ σ : ι → Bool, P.left i (σ i)) +
      (∑ i : ι, ∑ σ : ι → Bool, P.right i (σ i)) +
      (∑ i : ι, ∑ σ : ι → Bool, P.inside i (σ i) (σ i)) +
      (∑ s : Bool, ∑ t : Bool, ∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
        if i = j then 0 else P.outside s t i j (σ i) (σ j)) := by
    simp only [evaluate, Bool.false_and, Bool.false_eq_true, ite_false,
      Finset.sum_add_distrib]
    rw [hcomm1, hcomm1, hcomm1, hcomm2]
  have ho :
      (∑ σ : ι → Bool, evaluate P true σ) =
      (∑ σ : ι → Bool, P.offset) +
      (∑ i : ι, ∑ σ : ι → Bool, P.left i (σ i)) +
      (∑ i : ι, ∑ σ : ι → Bool, P.right i (!(σ i))) +
      (∑ i : ι, ∑ σ : ι → Bool, P.inside i (σ i) (!(σ i))) +
      (∑ s : Bool, ∑ t : Bool, ∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
        if i = j then 0 else P.outside s t i j
          (if s then !(σ i) else σ i)
          (if t then !(σ j) else σ j)) := by
    simp only [evaluate, Bool.true_and, ite_true,
      Finset.sum_add_distrib]
    rw [hcomm1, hcomm1, hcomm1, hcomm2]
  have hre :
      (∑ i : ι, ∑ σ : ι → Bool, P.right i (σ i)) =
      (∑ i : ι, ∑ σ : ι → Bool, P.right i (!(σ i))) := by
    apply Finset.sum_congr rfl
    intro i _
    exact hright i
  have hce :
      (∑ s : Bool, ∑ t : Bool, ∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
        if i = j then 0 else P.outside s t i j (σ i) (σ j)) =
      (∑ s : Bool, ∑ t : Bool, ∑ σ : ι → Bool, ∑ i : ι, ∑ j : ι,
        if i = j then 0 else P.outside s t i j
          (if s then !(σ i) else σ i)
          (if t then !(σ j) else σ j)) := by
    apply Finset.sum_congr rfl
    intro s _
    apply Finset.sum_congr rfl
    intro t _
    exact hout s t
  have hme :
      (2:ℝ) * ((∑ i : ι, ∑ σ : ι → Bool, P.inside i (σ i) (σ i)) -
        (∑ i : ι, ∑ σ : ι → Bool, P.inside i (σ i) (!(σ i)))) =
      (Fintype.card (ι → Bool):ℝ) * ∑ i : ι, rectangle P i := by
    rw [← Finset.sum_sub_distrib]
    simp only [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    exact hinside i
  rw [he, ho, ← hre, ← hce]
  nlinarith [hme]

end Nightfall.Observability.QuadraticMatching
