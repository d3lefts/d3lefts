import ProductRowBound
import WrightTotalIncrementFromEnergy

/-!
# Unconditional pointwise 4d² radius sensitivity on finite products

No FHKL/Sarantopoulos 2d² theorem is required. Use Turturean's
kernel-proved 4D² sensitivity via NIGHTFALL's competing-symbol
Chebyshev selector, with one maximizing coordinate replacement
per coordinate (block overlap N = 1 and polynomial degree d).

The resulting actual-coordinate resampling increment uses the exact
rho = 4 - 2 sqrt 3 finite-fiber certificate from PR #404.

This proves the weaker unconditional 4d² route, not the missing
sharp 2d² derivative theorem or K = pi² d² / 2 row.
-/

namespace Nightfall.Wright.UnconditionalFour

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Influence
open Nightfall.Wright.ActualIncrement
open Nightfall.Wright.CanonicalFiber
open Nightfall.Wright.SharpLimit

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The real canonical fiber radius budget from the actual bounded,
degree-d function, with no externally supplied pointwise estimate. -/
theorem canonical_radius_budget_four
    (d : ℕ) (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α) :
    ∑ j, radius f (fiberLo f) (fiberHi f) x j ≤
      4 * (d : ℝ) ^ 2 := by
  classical
  have hmax (j : ι) :
      ∃ b : α, ∀ c : α,
        |f x - f (Function.update x j c)| ≤
        |f x - f (Function.update x j b)| := by
    obtain ⟨b, -, hb⟩ := Finset.exists_max_image
      (Finset.univ : Finset α)
      (fun c => |f x - f (Function.update x j c)|)
      Finset.univ_nonempty
    exact ⟨b, fun c => hb c (Finset.mem_univ c)⟩
  choose b hb using hmax
  let y : ι → ι → α := fun j => Function.update x j (b j)
  have hradius (j : ι) :
      radius f (fiberLo f) (fiberHi f) x j ≤ |f x - f (y j)| := by
    let R : ℝ := |f x - f (y j)|
    have hl : f x - R ≤ fiberLo f x j := by
      unfold fiberLo
      refine Finset.le_inf' Finset.univ_nonempty _ ?_
      intro c _
      have hbc : |f x - f (Function.update x j c)| ≤ R := by
        simpa [R, y] using hb j c
      have ha : f x - f (Function.update x j c) ≤
          |f x - f (Function.update x j c)| := le_abs_self _
      linarith
    have hh : fiberHi f x j ≤ f x + R := by
      unfold fiberHi
      refine Finset.sup'_le Finset.univ_nonempty _ ?_
      intro c _
      have hbc : |f x - f (Function.update x j c)| ≤ R := by
        simpa [R, y] using hb j c
      have ha : f (Function.update x j c) - f x ≤
          |f x - f (Function.update x j c)| := by
        have h := neg_le_abs (f x - f (Function.update x j c))
        linarith
      linarith
    change max (f x - fiberLo f x j) (fiberHi f x j - f x) ≤ R
    exact max_le (by linarith) (by linarith)
  have hN : ∀ i : ι,
      (Finset.univ.filter (fun j : ι => i ∈ Nightfall.ProductSpace.RowBound.disagree x (y j))).card ≤ 1 := by
    intro i
    have hsub :
        (Finset.univ.filter (fun j : ι => i ∈ Nightfall.ProductSpace.RowBound.disagree x (y j))) ⊆
          ({i} : Finset ι) := by
      intro j hj
      have hmem : i ∈ Nightfall.ProductSpace.RowBound.disagree x (Function.update x j (b j)) := by
        simpa only [y] using (Finset.mem_filter.mp hj).2
      have hmem' : i ∈ Nightfall.ProductSpace.Transfer.disagree x (Function.update x j (b j)) := by
        simpa [Nightfall.ProductSpace.RowBound.disagree, Nightfall.ProductSpace.Transfer.disagree] using hmem
      have hieq : i = j := Finset.mem_singleton.mp
        (Nightfall.ProductSpace.Influence.disagree_update_single x j (b j) hmem')
      exact Finset.mem_singleton.mpr hieq.symm
    simpa using (Finset.card_le_card hsub)
  have hc : ((1 : ℕ) : ℝ) * (1 - Real.cos (Real.pi / ((1 : ℕ) : ℝ))) ≤ 2 := by
    norm_num [Real.cos_pi]
  have hblock :
      ∑ j, |f x - f (y j)| ≤ 4 * (d : ℝ) ^ 2 := by
    have h := Nightfall.ProductSpace.RowBound.product_block_inequality d f hf hd x y 1 1
      (by decide) hN hc
    simpa using h
  exact (Finset.sum_le_sum (fun j _ => hradius j)).trans hblock

/-- Exact law-weighted consequence of the pointwise four-bound. -/
theorem canonical_radius_energy_four
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (d : ℕ) (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1) (hd : HasProdDegreeLE f d) :
    (∑ j, ∑ x : ι → α,
       prodMass p x * radius f (fiberLo f) (fiberHi f) x j) ≤
      4 * (d : ℝ) ^ 2 := by
  have heq :
      (∑ j, ∑ x : ι → α,
        prodMass p x * radius f (fiberLo f) (fiberHi f) x j) =
      (∑ x : ι → α,
        prodMass p x * (∑ j, radius f (fiberLo f) (fiberHi f) x j)) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro x _
    rw [Finset.mul_sum]
  rw [heq]
  calc
    (∑ x : ι → α,
      prodMass p x * (∑ j, radius f (fiberLo f) (fiberHi f) x j)) ≤
      ∑ x : ι → α, prodMass p x * (4 * (d : ℝ) ^ 2) := by
      apply Finset.sum_le_sum
      intro x _
      exact mul_le_mul_of_nonneg_left
        (canonical_radius_budget_four d f hf hd x) (prodMass_nonneg' p hp x)
    _ = 4 * (d : ℝ) ^ 2 := by
      rw [← Finset.sum_mul, sum_prodMass p hp1, one_mul]

/-- Actual unconditional global pincr budget using the finite-fiber
sharp rho certificate but only the already-proved 4d² cube sensitivity:
L_v8 = 2 sum pincr <= 8 rho d².

This is weaker by a factor two than the v8 sharp 2d²-budget endpoint.
-/
theorem actual_total_increment_four
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (d : ℕ) (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1) (hd : HasProdDegreeLE f d) :
    2 * (∑ j, pincr p f j) ≤
      8 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 := by
  let r : ℝ := 4 - 2 * Real.sqrt 3
  have hr : 0 ≤ r := by
    simpa [r, Nightfall.Wright.SharpLimit.rho] using
      Nightfall.Wright.SharpLimit.rho_nonnegative
  have hlohi : ∀ x j, fiberLo f x j ≤ fiberHi f x j := by
    intro x j
    let b : α := Classical.choice (inferInstance : Nonempty α)
    exact (fiberLo_le f x j b).trans (le_fiberHi f x j b)
  have hsum : (∑ j, pincr p f j) ≤
      ∑ j, r * (∑ x : ι → α,
        prodMass p x * radius f (fiberLo f) (fiberHi f) x j) := by
    apply Finset.sum_le_sum
    intro j _
    exact actual_pincr_le_rho_radius p hp hp1 f (fiberLo f) (fiberHi f)
      hlohi (fiberLo_le f) (le_fiberHi f)
      (fiberLo_update f) (fiberHi_update f) j
  have hbudget := canonical_radius_energy_four p hp hp1 d f hf hd
  have hbudget' : r * (∑ j, ∑ x : ι → α,
      prodMass p x * radius f (fiberLo f) (fiberHi f) x j) ≤
      r * (4 * (d : ℝ) ^ 2) :=
    mul_le_mul_of_nonneg_left hbudget hr
  have hcoef : (∑ j, r *
      (∑ x : ι → α, prodMass p x *
        radius f (fiberLo f) (fiberHi f) x j)) =
      r * (∑ j, ∑ x : ι → α,
        prodMass p x * radius f (fiberLo f) (fiberHi f) x j) := by
    rw [Finset.mul_sum]
  calc
    2 * (∑ j, pincr p f j) ≤
      2 * (∑ j, r *
        (∑ x : ι → α, prodMass p x *
          radius f (fiberLo f) (fiberHi f) x j)) := by
          linarith
    _ = 2 * (r * (∑ j, ∑ x : ι → α,
        prodMass p x * radius f (fiberLo f) (fiberHi f) x j)) := by rw [hcoef]
    _ ≤ 2 * (r * (4 * (d : ℝ) ^ 2)) := by linarith
    _ = 8 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 := by dsimp [r]; ring

end Nightfall.Wright.UnconditionalFour
