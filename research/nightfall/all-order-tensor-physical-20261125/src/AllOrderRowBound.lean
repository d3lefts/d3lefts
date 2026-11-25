import AllOrderMixedNorm

namespace Nightfall.AllOrder
open Finset
variable {A : Type*} [Fintype A] [DecidableEq A]

/-- Actual L1 lower bound for every block-multilinear Rademacher chaos. -/
theorem chaos_l1 (n : ℕ) (c : (Fin n → A) → ℝ) :
    Real.sqrt (energy c) ≤ Real.sqrt ((3 : ℝ)^n) * avg (fun x => |chaos c x|) := by
  let e := energy c
  let p := avg (fun x => |chaos c x|)
  have he : 0 ≤ e := energy_nonneg c
  have hp : 0 ≤ p := avg_nonneg _ (fun _ => abs_nonneg _)
  have h3 : 0 ≤ (3 : ℝ)^n := by positivity
  change Real.sqrt e ≤ Real.sqrt ((3 : ℝ)^n) * p
  by_cases hz : e = 0
  · rw [hz, Real.sqrt_zero]
    exact mul_nonneg (Real.sqrt_nonneg _) hp
  have hpos : 0 < e := lt_of_le_of_ne he (Ne.symm hz)
  have hi := avg_moment_interpolation (chaos c)
  rw [chaos_second] at hi
  have hh : e^3 ≤ p^2 * ((3 : ℝ)^n * e^2) := hi.trans (mul_le_mul_of_nonneg_left (chaos_fourth n c) (sq_nonneg p))
  have hc : e ≤ (3 : ℝ)^n * p^2 := by
    have hh' : e^2 * e ≤ e^2 * ((3 : ℝ)^n * p^2) := by
      calc
        e^2 * e = e^3 := by ring
        _ ≤ p^2 * ((3 : ℝ)^n * e^2) := hh
        _ = _ := by ring
    exact le_of_mul_le_mul_left hh' (sq_pos_of_pos hpos)
  have hs : (Real.sqrt e)^2 ≤ (Real.sqrt ((3 : ℝ)^n) * p)^2 := by
    rw [Real.sq_sqrt he, mul_pow, Real.sq_sqrt h3]
    exact hc
  have hn : 0 ≤ Real.sqrt ((3 : ℝ)^n) * p := mul_nonneg (Real.sqrt_nonneg _) hp
  nlinarith [Real.sqrt_nonneg e]

theorem first_row_energy {n : ℕ} (c : (Fin (n+1) → A) → ℝ) (a : A) :
    rowNorm c 0 a = Real.sqrt (energy (fun b : Fin n → A => c (Fin.cons a b))) := by
  classical
  unfold rowNorm energy
  congr 1
  rw [Finset.sum_filter, sum_cons]
  simp only [Fin.cons_zero]
  rw [Finset.sum_eq_single a]
  · simp
  · intro b _ hb
    simp [hb]
  · simp

/-- First-slot sign maximization; the tail signs are the actual random blocks. -/
theorem first_row_mixed_bound {n : ℕ} (c : (Fin (n+1) → A) → ℝ) (K : ℝ)
    (hK : ∀ x : Fin (n+1) → A → Bool, |chaos c x| ≤ K) :
    (∑ a, rowNorm c 0 a) ≤ Real.sqrt ((3 : ℝ)^n) * K := by
  classical
  let v (a : A) (y : Fin n → A → Bool) := chaos (fun b => c (Fin.cons a b)) y
  have hs (y : Fin n → A → Bool) : ∑ a, |v a y| ≤ K := by
    let x : A → Bool := fun a => decide (0 ≤ v a y)
    have hv : signedSum (fun a => v a y) x = ∑ a, |v a y| := by
      unfold signedSum
      apply Finset.sum_congr rfl
      intro a _
      by_cases hh : 0 ≤ v a y
      · simp [x,rad,hh,abs_of_nonneg hh]
      · have hneg : v a y < 0 := lt_of_not_ge hh
        simp [x,rad,hh,abs_of_neg hneg]
    have hh := hK (Fin.cons x y)
    rw [chaos_cons] at hh
    change |signedSum (fun a => v a y) x| ≤ K at hh
    rw [hv, abs_of_nonneg (Finset.sum_nonneg (fun a _ => abs_nonneg (v a y)))] at hh
    exact hh
  calc
    _ = ∑ a, Real.sqrt (energy (fun b : Fin n → A => c (Fin.cons a b))) := by simp_rw [first_row_energy]
    _ ≤ ∑ a, Real.sqrt ((3 : ℝ)^n) * avg (fun y => |v a y|) :=
      Finset.sum_le_sum (fun a _ => chaos_l1 n _)
    _ = Real.sqrt ((3 : ℝ)^n) * avg (fun y => ∑ a, |v a y|) := by
      rw [avg_sum, Finset.mul_sum]
    _ ≤ _ := by
      apply mul_le_mul_of_nonneg_left _ (Real.sqrt_nonneg _)
      have h := avg_mono (fun y => ∑ a, |v a y|) (fun _ => K) hs
      rwa [avg_const] at h

/-- Source-connected mixed row bound at every actual slot, with no assumed
    row-norm or chaos-moment inequality. -/
theorem all_slot_mixed_bound {n : ℕ} (c : (Fin (n+1) → A) → ℝ) (i : Fin (n+1)) (K : ℝ)
    (hK : ∀ x : Fin (n+1) → A → Bool, |chaos c x| ≤ K) :
    (∑ a, rowNorm c i a) ≤ Real.sqrt ((3 : ℝ)^n) * K := by
  classical
  let e := Equiv.swap (0 : Fin (n+1)) i
  let E := Equiv.arrowCongr e (Equiv.refl A)
  let X := Equiv.arrowCongr e (Equiv.refl (A → Bool))
  let c' : (Fin (n+1) → A) → ℝ := fun b => c (E b)
  have hzero : e.symm i = 0 := by simp [e, Equiv.swap_apply_right]
  have hr (a : A) : rowNorm c' 0 a = rowNorm c i a := by
    unfold rowNorm
    congr 1
    simp only [Finset.sum_filter]
    apply Fintype.sum_equiv E _ _
    intro b
    have h : E b i = b 0 := by simp [E, Equiv.arrowCongr_apply,hzero]
    simp [c',h]
  have hform (x : Fin (n+1) → A → Bool) : chaos c' x = chaos c (X x) := by
    unfold chaos
    apply Fintype.sum_equiv E _ _
    intro b
    unfold c'
    congr 1
    symm
    exact e.symm.prod_comp (fun j => rad (x j (b j)))
  have hb := first_row_mixed_bound c' K (fun x => by rw [hform]; exact hK _)
  simpa only [hr] using hb

#print axioms chaos_l1
#print axioms first_row_energy
#print axioms first_row_mixed_bound
#print axioms all_slot_mixed_bound
end Nightfall.AllOrder
