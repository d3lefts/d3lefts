import ShiftedOwnerScalar

/-!
# Shifted-owner interpolation from explicit moment inequalities

These are source-INDEPENDENT algebraic theorems with their precise
fourth-moment and Holder inequalities as explicit premises.
A separate source-matched Hilbert proof must establish those premises
for the actual owned-neighbor source before any C2=273 conclusion can
be called original-source certified.
-/

namespace Nightfall.Observability.ShiftedOwnerScalarMoments

open Finset
open Nightfall.Observability.ShiftedOwnerScalar

/-- Fourth-moment and Holder inequalities imply the shifted c/3 bound.
The moment bounds are hypotheses, not produced by this theorem. -/
theorem shifted_c3_from_moments
    (e u c q : ℝ)
    (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hholder : e^3 ≤ u^2*q)
    (hfourth : q ≤ 3*e^2 + 2*c*e*Real.sqrt e + c^2*e) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/3 := by
  by_cases hezero : e = 0
  · rw [hezero, Real.sqrt_zero]
    have hr : (0:ℝ) ≤ Real.sqrt 3 := Real.sqrt_nonneg _
    have hcu : 0 ≤ c/3 := by positivity
    nlinarith [mul_nonneg hr hu]
  · have hepos : 0 < e := lt_of_le_of_ne he (Ne.symm hezero)
    let t : ℝ := Real.sqrt e
    have ht : 0 ≤ t := Real.sqrt_nonneg _
    have htpos : 0 < t := Real.sqrt_pos.2 hepos
    have ht2 : t^2 = e := Real.sq_sqrt he
    let D : ℝ := 3*t^2+2*c*t+c^2
    have hq : q ≤ t^2*D := by
      calc
        q ≤ 3*e^2 + 2*c*e*t+c^2*e := hfourth
        _ = t^2*D := by dsimp [D]; rw [← ht2]; ring
    have hh : t^6 ≤ u^2*q := by
      calc
        t^6 = e^3 := by rw [← ht2]; ring
        _ ≤ u^2*q := hholder
    have hcanc : t^4*t^2 ≤ (u^2*D)*t^2 := by
      calc
        t^4*t^2 = t^6 := by ring
        _ ≤ u^2*q := hh
        _ ≤ u^2*(t^2*D) :=
          mul_le_mul_of_nonneg_left hq (sq_nonneg u)
        _ = (u^2*D)*t^2 := by ring
    have ht4 : t^4 ≤ u^2*D :=
      (mul_le_mul_iff_of_pos_right (sq_pos_of_pos htpos)).mp hcanc
    change Real.sqrt e ≤ Real.sqrt 3*u+c/3
    exact shifted_c3_of_fourth_interpolation t u c ht hu hc (by
      simpa only [D] using ht4)

variable {ι : Type*} [Fintype ι]

/-- A rigorously conditional source-budget composition. The q_i are
unverified fourth moments of shifted actual owned sums until the
source-level Hilbert shift theorem has been connected. -/
theorem conditional_shifted_budget_273
    (e u c q : ι → ℝ)
    (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (he : ∀ i, 0 ≤ e i)
    (hu : ∀ i, 0 ≤ u i)
    (hc : ∀ i, 0 ≤ c i)
    (hcap : ∀ i, e i ≤ M)
    (hholder : ∀ i, (e i)^3 ≤ (u i)^2 * q i)
    (hfourth : ∀ i,
      q i ≤ 3*(e i)^2 + 2*(c i)*(e i)*Real.sqrt (e i) +
        (c i)^2*(e i))
    (hsection : (∑ i : ι, u i) ≤ 8*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ (8*Real.sqrt 3+8/3)^2 * B^2 * M := by
  classical
  let r : ℝ := Real.sqrt 3
  have hr : 0 ≤ r := Real.sqrt_nonneg _
  have hsite (i : ι) :
      e i ≤ Real.sqrt M*(r*u i+c i/3) := by
    have hshift := shifted_c3_from_moments
      (e i) (u i) (c i) (q i)
      (he i) (hu i) (hc i) (hholder i) (hfourth i)
    exact shifted_site_c3 (e i) (u i) (c i) M
      (he i) (hu i) (hc i) hM (hcap i) (by
        simpa only [r] using hshift)
  have hsum : V ≤
      ∑ i : ι, Real.sqrt M*(r*u i+c i/3) := by
    rw [hvariance]
    exact Finset.sum_le_sum (fun i _ => hsite i)
  have hsumId :
      (∑ i : ι, Real.sqrt M*(r*u i+c i/3)) =
      Real.sqrt M*(r*(∑ i : ι, u i)+(∑ i : ι, c i)/3) := by
    simp only [mul_add, Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_div]
  have hUb : r*(∑ i : ι, u i) ≤ r*(8*B) :=
    mul_le_mul_of_nonneg_left hsection hr
  have hCb : (∑ i : ι, c i)/3 ≤ (8*B)/3 := by
    linarith [hcover]
  have hbudget :
      r*(∑ i : ι, u i)+(∑ i : ι, c i)/3
        ≤ (8*r+8/3)*B := by
    nlinarith [hUb, hCb]
  have hroot : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hVbound :
      V ≤ (8*r+8/3)*B*Real.sqrt M := by
    calc
      V ≤ Real.sqrt M*
        (r*(∑ i : ι, u i)+(∑ i : ι, c i)/3) := by
          simpa only [hsumId] using hsum
      _ ≤ Real.sqrt M*((8*r+8/3)*B) :=
          mul_le_mul_of_nonneg_left hbudget hroot
      _ = (8*r+8/3)*B*Real.sqrt M := by ring
  have hV0 : 0 ≤ V := by
    rw [hvariance]
    exact Finset.sum_nonneg (fun i _ => he i)
  have hR0 : 0 ≤ (8*r+8/3)*B*Real.sqrt M := by
    dsimp [r]
    positivity
  have hVsq :
      V^2 ≤ ((8*r+8/3)*B*Real.sqrt M)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVbound)
      (add_nonneg hR0 hV0)]
  calc
    V^2 ≤ ((8*r+8/3)*B*Real.sqrt M)^2 := hVsq
    _ = (8*Real.sqrt 3+8/3)^2*B^2*M := by
      dsimp [r]
      calc
        ((8*Real.sqrt 3+8/3)*B*Real.sqrt M)^2 =
          (8*Real.sqrt 3+8/3)^2*B^2*(Real.sqrt M)^2 := by ring
        _ = (8*Real.sqrt 3+8/3)^2*B^2*M := by
          rw [Real.sq_sqrt hM]

end Nightfall.Observability.ShiftedOwnerScalarMoments
