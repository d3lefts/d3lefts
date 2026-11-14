import SCIFInfluence

/-!
# SCIF IV: fixed-owner source-law transfer with quantitative cost

This is a real weighted-table certificate: every edge e keeps its
previous owner, while its first-coordinate law is replaced by q.
The only perturbation input is the literal finite L1 difference
sum |q-p|, with no positive-atom lower bound.

This file certifies the fixed-owner amplitude-cover layer, not the
new-law fourth moment or the whole Q2 scalar theorem.
-/

namespace Nightfall.SCIF
open Finset

variable {A B V E : Type*}
  [Fintype A] [Fintype B] [Fintype V] [Fintype E]

/-- Finite-law expectation perturbation using the actual old centering.
No support conditions; zero-probability atoms remain legal. -/
theorem centered_firstMean_abs_le_l1
    (p q : A → ℝ) (H : A → B → ℝ) (b : B)
    (C eta : ℝ)
    (hC : 0 ≤ C)
    (hmean : (∑ a : A, p a * H a b) = 0)
    (hbound : ∀ a : A, |H a b| ≤ C)
    (hl1 : (∑ a : A, |q a - p a|) ≤ eta) :
    |firstMean q H b| ≤ eta * C := by
  classical
  have hdiff :
      firstMean q H b =
        ∑ a : A, (q a - p a) * H a b := by
    unfold firstMean
    simp_rw [sub_mul, Finset.sum_sub_distrib]
    rw [hmean]
    ring
  calc
    |firstMean q H b| =
        |∑ a : A, (q a - p a) * H a b| := by rw [hdiff]
    _ ≤ ∑ a : A, |(q a - p a) * H a b| :=
      Finset.abs_sum_le_sum_abs _ _
    _ = ∑ a : A, |q a - p a| * |H a b| := by
      apply Finset.sum_congr rfl
      intro a _
      rw [abs_mul]
    _ ≤ ∑ a : A, |q a - p a| * C := by
      apply Finset.sum_le_sum
      intro a _
      exact mul_le_mul_of_nonneg_left (hbound a) (abs_nonneg _)
    _ = (∑ a : A, |q a - p a|) * C := by rw [Finset.sum_mul]
    _ ≤ eta * C := mul_le_mul_of_nonneg_right hl1 hC

/-- Source-specific zero-reassignment amplitude cover:
every edge remains with the same owner, and only the costs scale.
eta is the actual weighted L1 difference between old and new laws. -/
theorem fixed_owner_recenter_cover
    (p q : A → ℝ)
    (owner : E → V)
    (H : E → A → B → ℝ)
    (c : V → ℝ) (eta : ℝ)
    (hc : ∀ i : V, 0 ≤ c i)
    (hl1 : (∑ a : A, |q a - p a|) ≤ eta)
    (hcenter : ∀ e : E, ∀ b : B,
      (∑ a : A, p a * H e a b) = 0)
    (hcover : ∀ e : E, ∀ a : A, ∀ b : B,
      |H e a b| ≤ c (owner e)) :
    ∀ e : E, ∀ a : A, ∀ b : B,
      |pairRecenter q (H e) a b| ≤
         (1 + eta) * c (owner e) := by
  intro e a b
  have hmean : |firstMean q (H e) b| ≤
      eta * c (owner e) :=
    centered_firstMean_abs_le_l1 p q (H e) b
      (c (owner e)) eta (hc (owner e)) (hcenter e b)
      (fun x => hcover e x b) hl1
  calc
    |pairRecenter q (H e) a b| =
      |H e a b + (- firstMean q (H e) b)| := by
        dsimp [pairRecenter]
        ring
    _ ≤ |H e a b| + |- firstMean q (H e) b| :=
      abs_add_le _ _
    _ = |H e a b| + |firstMean q (H e) b| := by
      rw [abs_neg]
    _ ≤ c (owner e) + eta * c (owner e) :=
      add_le_add (hcover e a b) hmean
    _ = (1 + eta) * c (owner e) := by ring

/-- The unchanged owner map also retains a dimension-independent
total cost cap; source law validity is handled above. -/
theorem fixed_owner_scaled_total_cost
    (c : V → ℝ) (eta C : ℝ)
    (heta : 0 ≤ eta)
    (hcost : (∑ i : V, c i) ≤ C) :
    (∑ i : V, (1 + eta) * c i) ≤ (1 + eta) * C := by
  calc
    (∑ i : V, (1 + eta) * c i) =
      (1 + eta) * (∑ i : V, c i) := by
        rw [Finset.mul_sum]
    _ ≤ (1 + eta) * C :=
      mul_le_mul_of_nonneg_left hcost (by linarith)

end Nightfall.SCIF
