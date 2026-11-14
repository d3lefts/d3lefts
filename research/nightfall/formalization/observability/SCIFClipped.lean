import SCIFOwnerRepair

/-!
# SCIF IVb: clipped-TV and simultaneous two-endpoint amplitude certificates

This strengthens the strictly compiled L1 repair to the sharp
1 + min(L1,1) one-coordinate multiplier. Since L1 = 2 TV for
probability masses, this is 1 + min(2 TV, 1).
It also proves the universal 4x bound for centering both endpoints.
The results are finite typed pair tables and do not assert a new
canonical full-product source projection bridge.
-/

namespace Nightfall.SCIF
open Finset

variable {A B V E : Type*}
  [Fintype A] [Fintype B] [Fintype V] [Fintype E]

/-- Elementary expectation contraction in the actual new probability law. -/
theorem firstMean_abs_le_amplitude
    (q : A → ℝ) (H : A → B → ℝ) (b : B)
    (C : ℝ)
    (hq0 : ∀ a : A, 0 ≤ q a)
    (hq1 : (∑ a : A, q a) = 1)
    (hbound : ∀ a : A, |H a b| ≤ C) :
    |firstMean q H b| ≤ C := by
  classical
  calc
    |firstMean q H b| ≤ ∑ a : A, |q a * H a b| := by
      unfold firstMean
      exact Finset.abs_sum_le_sum_abs _ _
    _ = ∑ a : A, q a * |H a b| := by
      apply Finset.sum_congr rfl
      intro a _
      rw [abs_mul, abs_of_nonneg (hq0 a)]
    _ ≤ ∑ a : A, q a * C := by
      apply Finset.sum_le_sum
      intro a _
      exact mul_le_mul_of_nonneg_left (hbound a) (hq0 a)
    _ = (∑ a : A, q a) * C := by rw [Finset.sum_mul]
    _ = C := by rw [hq1]; ring

/-- The sharp clipped-L1 bound for a normalized updated law and
an old-law centered pair kernel. -/
theorem centered_firstMean_abs_le_clipped_l1
    (p q : A → ℝ) (H : A → B → ℝ) (b : B)
    (C : ℝ)
    (hC : 0 ≤ C)
    (hq0 : ∀ a : A, 0 ≤ q a)
    (hq1 : (∑ a : A, q a) = 1)
    (hmean : (∑ a : A, p a * H a b) = 0)
    (hbound : ∀ a : A, |H a b| ≤ C) :
    |firstMean q H b| ≤
       min (∑ a : A, |q a - p a|) 1 * C := by
  classical
  let D : ℝ := ∑ a : A, |q a - p a|
  have hl1 : |firstMean q H b| ≤ D * C :=
    centered_firstMean_abs_le_l1 p q H b C D hC
      hmean hbound (le_refl D)
  have hampl : |firstMean q H b| ≤ C :=
    firstMean_abs_le_amplitude q H b C hq0 hq1 hbound
  change |firstMean q H b| ≤ min D 1 * C
  by_cases hD : D ≤ 1
  · simpa only [min_eq_left hD] using hl1
  · have hD' : (1 : ℝ) ≤ D := le_of_lt (lt_of_not_ge hD)
    simpa only [min_eq_right hD', one_mul] using hampl

/-- No owner changes, with the exact clipped TV multiplier. -/
theorem fixed_owner_recenter_cover_clipped
    (p q : A → ℝ)
    (owner : E → V)
    (H : E → A → B → ℝ)
    (c : V → ℝ)
    (hc : ∀ i : V, 0 ≤ c i)
    (hq0 : ∀ a : A, 0 ≤ q a)
    (hq1 : (∑ a : A, q a) = 1)
    (hcenter : ∀ e : E, ∀ b : B,
      (∑ a : A, p a * H e a b) = 0)
    (hcover : ∀ e : E, ∀ a : A, ∀ b : B,
      |H e a b| ≤ c (owner e)) :
    ∀ e : E, ∀ a : A, ∀ b : B,
      |pairRecenter q (H e) a b| ≤
        (1 + min (∑ z : A, |q z - p z|) 1) * c (owner e) := by
  intro e a b
  have hm : |firstMean q (H e) b| ≤
      min (∑ z : A, |q z - p z|) 1 * c (owner e) :=
    centered_firstMean_abs_le_clipped_l1 p q (H e) b
      (c (owner e)) (hc (owner e)) hq0 hq1
      (hcenter e b) (fun x => hcover e x b)
  calc
    |pairRecenter q (H e) a b| =
      |H e a b + (-firstMean q (H e) b)| := by
        dsimp [pairRecenter]
        ring
    _ ≤ |H e a b| + |-firstMean q (H e) b| := abs_add_le _ _
    _ = |H e a b| + |firstMean q (H e) b| := by rw [abs_neg]
    _ ≤ c (owner e) +
        min (∑ z : A, |q z - p z|) 1 * c (owner e) :=
      add_le_add (hcover e a b) hm
    _ = (1 + min (∑ z : A, |q z - p z|) 1) * c (owner e) := by ring

/-- Cost of keeping precisely the previous assignment. -/
theorem fixed_owner_clipped_total_cost
    (p q : A → ℝ) (c : V → ℝ) (C : ℝ)
    (hcost : (∑ i : V, c i) ≤ C) :
    (∑ i : V,
       (1 + min (∑ a : A, |q a - p a|) 1) * c i) ≤
       (1 + min (∑ a : A, |q a - p a|) 1) * C := by
  have hD : 0 ≤ (∑ a : A, |q a - p a|) := by
    apply Finset.sum_nonneg
    intro a _
    exact abs_nonneg _
  exact fixed_owner_scaled_total_cost c
    (min (∑ a : A, |q a - p a|) 1) C
    (le_min hD (by norm_num)) hcost

/-- Symmetric second-coordinate recentering. -/
noncomputable def secondMean (r : B → ℝ) (H : A → B → ℝ)
    (a : A) : ℝ := ∑ b : B, r b * H a b

noncomputable def secondRecenter (r : B → ℝ) (H : A → B → ℝ)
    (a : A) (b : B) : ℝ := H a b - secondMean r H a

/-- No centeredness assumption is needed for a 2x norm bound. -/
theorem pairRecenter_abs_le_two
    (q : A → ℝ) (H : A → B → ℝ) (C : ℝ)
    (hq0 : ∀ a : A, 0 ≤ q a)
    (hq1 : (∑ a : A, q a) = 1)
    (hbound : ∀ a : A, ∀ b : B, |H a b| ≤ C) :
    ∀ a : A, ∀ b : B, |pairRecenter q H a b| ≤ 2 * C := by
  intro a b
  have hm : |firstMean q H b| ≤ C :=
    firstMean_abs_le_amplitude q H b C hq0 hq1
      (fun x => hbound x b)
  calc
    |pairRecenter q H a b| =
      |H a b + (-firstMean q H b)| := by
        dsimp [pairRecenter]
        ring
    _ ≤ |H a b| + |-firstMean q H b| := abs_add_le _ _
    _ = |H a b| + |firstMean q H b| := by rw [abs_neg]
    _ ≤ C + C := add_le_add (hbound a b) hm
    _ = 2 * C := by ring

theorem secondRecenter_abs_le_two
    (r : B → ℝ) (H : A → B → ℝ) (C : ℝ)
    (hr0 : ∀ b : B, 0 ≤ r b)
    (hr1 : (∑ b : B, r b) = 1)
    (hbound : ∀ a : A, ∀ b : B, |H a b| ≤ C) :
    ∀ a : A, ∀ b : B, |secondRecenter r H a b| ≤ 2 * C := by
  intro a b
  let F : B → A → ℝ := fun y x => H x y
  have hh : |firstMean r F a| ≤ C :=
    firstMean_abs_le_amplitude r F a C hr0 hr1
      (fun y => hbound a y)
  have hm : |secondMean r H a| ≤ C := by
    simpa only [firstMean, secondMean, F] using hh
  calc
    |secondRecenter r H a b| =
      |H a b + (-secondMean r H a)| := by
        dsimp [secondRecenter]
        ring
    _ ≤ |H a b| + |-secondMean r H a| := abs_add_le _ _
    _ = |H a b| + |secondMean r H a| := by rw [abs_neg]
    _ ≤ C + C := add_le_add (hbound a b) hm
    _ = 2 * C := by ring

/-- Universal fourfold amplitude inflation under two endpoint updates,
independent of alphabet sizes or small atom probabilities. -/
theorem double_recenter_abs_le_four
    (q : A → ℝ) (r : B → ℝ)
    (H : A → B → ℝ) (C : ℝ)
    (hq0 : ∀ a : A, 0 ≤ q a)
    (hq1 : (∑ a : A, q a) = 1)
    (hr0 : ∀ b : B, 0 ≤ r b)
    (hr1 : (∑ b : B, r b) = 1)
    (hbound : ∀ a : A, ∀ b : B, |H a b| ≤ C) :
    ∀ a : A, ∀ b : B,
      |secondRecenter r (pairRecenter q H) a b| ≤ 4 * C := by
  intro a b
  have htwo : ∀ x : A, ∀ y : B, |pairRecenter q H x y| ≤ 2 * C :=
    pairRecenter_abs_le_two q H C hq0 hq1 hbound
  have h := secondRecenter_abs_le_two r (pairRecenter q H)
    (2 * C) hr0 hr1 htwo a b
  nlinarith

end Nightfall.SCIF
