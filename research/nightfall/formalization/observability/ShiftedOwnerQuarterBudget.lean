import ShiftedOwnerQuarterMoments

/-!
# Conditional c/4 shifted-owner source budgets

This combines the EXACT scalar Bernstein certificate and algebraic
moment-to-L1 theorem with explicit families of fourth-moment and
Holder premises. These q_i premises are NOT yet proved for the actual
finite original-law owned-neighbor Hilbert sums. No source-only
unconditional 251 or 107 theorem is asserted here.
-/

namespace Nightfall.Observability.ShiftedOwnerQuarterBudget

open Finset
open Nightfall.Observability.ShiftedOwnerQuarterMoments

variable {ι : Type*} [Fintype ι]

theorem conditional_shifted_quarter_budget
    (a s u c q : ι → ℝ)
    (B M V U : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M) (hU : 0 ≤ U)
    (ha : ∀ i, 0 ≤ a i) (hs : ∀ i, 0 ≤ s i)
    (hu : ∀ i, 0 ≤ u i) (hc : ∀ i, 0 ≤ c i)
    (hcap : ∀ i, (a i)^2+s i ≤ M)
    (hholder : ∀ i, ((a i)^2+s i)^3 ≤ (u i)^2*q i)
    (hfourth : ∀ i,
      q i ≤ 3*((a i)^2+s i)^2 - 2*(a i)^4 +
        4*(a i)*(c i)*(s i)+(c i)^2*(s i))
    (hsection : (∑ i : ι, u i) ≤ U*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hvariance : V = ∑ i : ι, ((a i)^2+s i)) :
    V^2 ≤ (Real.sqrt 3*U+2)^2*B^2*M := by
  classical
  let r : ℝ := Real.sqrt 3
  have hr : 0 ≤ r := Real.sqrt_nonneg _
  have hlocal (i : ι) :
      (a i)^2+s i ≤ Real.sqrt M*(r*u i+c i/4) := by
    let e : ℝ := (a i)^2+s i
    let t : ℝ := Real.sqrt e
    have he : 0 ≤ e := by dsimp [e]; positivity
    have ht : 0 ≤ t := Real.sqrt_nonneg _
    have heq : t^2 = e := Real.sq_sqrt he
    have hholderT : t^6 ≤ (u i)^2*q i := by
      calc
        t^6 = (t^2)^3 := by ring
        _ = e^3 := by rw [heq]
        _ ≤ (u i)^2*q i := hholder i
    have hfourthT :
        q i ≤ 3*t^4-2*(a i)^4+
          4*(a i)*(c i)*(s i)+(c i)^2*(s i) := by
      calc
        q i ≤ 3*e^2-2*(a i)^4+
          4*(a i)*(c i)*(s i)+(c i)^2*(s i) := hfourth i
        _ = 3*t^4-2*(a i)^4+
          4*(a i)*(c i)*(s i)+(c i)^2*(s i) := by
            rw [← heq]
            ring
    have hshift : t ≤ r*u i+c i/4 := by
      simpa only [r] using
        (shifted_c4_from_moments t (a i) (s i) (c i) (u i) (q i)
          ht (ha i) (hs i) (hc i) (hu i) (by
            simpa only [e] using heq) hholderT hfourthT)
    have hrootM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
    have hrootE : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
    have hrootOrder : Real.sqrt e ≤ Real.sqrt M :=
      Real.sqrt_le_sqrt (by simpa only [e] using hcap i)
    calc
      (a i)^2+s i = t*t := by dsimp [e,t] at *; nlinarith [heq]
      _ ≤ Real.sqrt M*t :=
        mul_le_mul_of_nonneg_right hrootOrder (by simpa only [t] using hrootE)
      _ ≤ Real.sqrt M*(r*u i+c i/4) :=
        mul_le_mul_of_nonneg_left hshift hrootM
  have hsum : V ≤ ∑ i : ι,
      Real.sqrt M*(r*u i+c i/4) := by
    rw [hvariance]
    exact Finset.sum_le_sum (fun i _ => hlocal i)
  have hsumId :
      (∑ i : ι, Real.sqrt M*(r*u i+c i/4)) =
      Real.sqrt M*(r*(∑ i : ι, u i)+(∑ i : ι, c i)/4) := by
    simp only [mul_add, Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_div]
  have hUb : r*(∑ i : ι, u i) ≤ r*(U*B) :=
    mul_le_mul_of_nonneg_left hsection hr
  have hCb : (∑ i : ι, c i)/4 ≤ (8*B)/4 := by
    linarith [hcover]
  have hbudget :
      r*(∑ i : ι, u i)+(∑ i : ι, c i)/4 ≤
        (r*U+2)*B := by
    nlinarith [hUb,hCb]
  have hrootM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hVbound :
      V ≤ (r*U+2)*B*Real.sqrt M := by
    calc
      V ≤ Real.sqrt M*
          (r*(∑ i : ι, u i)+(∑ i : ι, c i)/4) := by
            simpa only [hsumId] using hsum
      _ ≤ Real.sqrt M*((r*U+2)*B) :=
        mul_le_mul_of_nonneg_left hbudget hrootM
      _ = (r*U+2)*B*Real.sqrt M := by ring
  have hV0 : 0 ≤ V := by
    rw [hvariance]
    exact Finset.sum_nonneg (fun i _ => by
      have : 0 ≤ (a i)^2 := sq_nonneg _
      exact add_nonneg this (hs i))
  have hK0 : 0 ≤ r*U+2 := by
    exact add_nonneg (mul_nonneg hr hU) (by norm_num)
  have hR0 : 0 ≤ (r*U+2)*B*Real.sqrt M :=
    mul_nonneg (mul_nonneg hK0 hB) hrootM
  have hVsq :
      V^2 ≤ ((r*U+2)*B*Real.sqrt M)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVbound)
      (add_nonneg hR0 hV0)]
  calc
    V^2 ≤ ((r*U+2)*B*Real.sqrt M)^2 := hVsq
    _ = (Real.sqrt 3*U+2)^2*B^2*M := by
      dsimp [r]
      calc
        ((Real.sqrt 3*U+2)*B*Real.sqrt M)^2 =
          (Real.sqrt 3*U+2)^2*B^2*(Real.sqrt M)^2 := by ring
        _ = (Real.sqrt 3*U+2)^2*B^2*M := by rw [Real.sq_sqrt hM]

end Nightfall.Observability.ShiftedOwnerQuarterBudget
