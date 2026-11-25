import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Algebra.BigOperators.Fin

/-! Paper III Theorem 4.1: exact balanced-ternary decoding core.
This proves the sign and last-coordinate uniqueness used by the adaptive
annular upper construction. It does not assert the topology lower bound. -/
namespace Nightfall.AnnularBalancedDecode
open Finset

def code {n : ℕ} (s : Fin n → ℤ) : ℤ := ∑ i, 3^i.val * s i

theorem code_succ {n : ℕ} (s : Fin (n+1) → ℤ) :
    code s = s 0 + 3 * code (fun i : Fin n => s i.succ) := by
  unfold code
  rw [Fin.sum_univ_succ, Finset.mul_sum]
  simp only [Fin.val_zero, pow_zero, one_mul, Fin.val_succ]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [pow_succ]
  ring

theorem balanced_code_injective {n : ℕ} (s t : Fin n → ℤ)
    (hs : ∀ i, -1 ≤ s i ∧ s i ≤ 1)
    (ht : ∀ i, -1 ≤ t i ∧ t i ≤ 1)
    (h : code s = code t) : s = t := by
  induction n with
  | zero => funext i; exact Fin.elim0 i
  | succ n ih =>
    rw [code_succ, code_succ] at h
    have h0 := hs 0
    have h1 := ht 0
    have he : s 0 = t 0 := by omega
    have htail : code (fun i : Fin n => s i.succ) =
        code (fun i : Fin n => t i.succ) := by omega
    have hrec := ih (fun i : Fin n => s i.succ) (fun i : Fin n => t i.succ)
      (fun i => hs i.succ) (fun i => ht i.succ) htail
    funext i
    refine Fin.cases he (fun j => congrFun hrec j) i

/-- The decoded real value is an integer balanced-ternary code plus a
last-coordinate residual in [-1/4,1/4]. Distinct admissible signed digits
and residuals cannot produce the same reading. -/
theorem balanced_residual_injective {n : ℕ} (s t : Fin n → ℤ)
    (hs : ∀ i, -1 ≤ s i ∧ s i ≤ 1)
    (ht : ∀ i, -1 ≤ t i ∧ t i ≤ 1)
    (R x y : ℝ) (hR : 0 < R)
    (hx : -R ≤ x ∧ x ≤ R) (hy : -R ≤ y ∧ y ≤ R)
    (h : (code s : ℝ) + x/(4*R) = (code t : ℝ) + y/(4*R)) :
    s=t ∧ x=y := by
  have hden : 0 < 4*R := by positivity
  have hxlo : -(1/4 : ℝ) ≤ x/(4*R) := by
    apply (le_div_iff₀ hden).2
    linarith [hx.1]
  have hxhi : x/(4*R) ≤ (1/4 : ℝ) := by
    apply (div_le_iff₀ hden).2
    linarith [hx.2]
  have hylo : -(1/4 : ℝ) ≤ y/(4*R) := by
    apply (le_div_iff₀ hden).2
    linarith [hy.1]
  have hyhi : y/(4*R) ≤ (1/4 : ℝ) := by
    apply (div_le_iff₀ hden).2
    linarith [hy.2]
  have he : code s = code t := by
    by_contra hn
    rcases lt_or_gt_of_ne hn with hl|hg
    · have hi : code s + 1 ≤ code t := by omega
      have hr : (code s : ℝ) + 1 ≤ (code t : ℝ) := by exact_mod_cast hi
      linarith
    · have hi : code t + 1 ≤ code s := by omega
      have hr : (code t : ℝ) + 1 ≤ (code s : ℝ) := by exact_mod_cast hi
      linarith
  refine ⟨balanced_code_injective s t hs ht he, ?_⟩
  rw [he] at h
  have hxy : x/(4*R) = y/(4*R) := add_left_cancel h
  exact (div_left_inj' hden.ne').mp hxy

#print axioms balanced_code_injective
#print axioms balanced_residual_injective
end Nightfall.AnnularBalancedDecode
