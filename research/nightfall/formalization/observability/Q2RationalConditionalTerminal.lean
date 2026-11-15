import Q2RationalTwoFifths

/-!
The precise conditional rational sub-100 Q2 owner-energy telescope.
This derives a global variance-squared bound from explicit hypotheses
on source owner energies, shifted L1, 29/6 source sections, and 8B cover.
It does NOT assert the remaining source / probabilistic premises.
-/

namespace Nightfall.Q2RationalTwoFifths
open Finset

variable {ι : Type*} [Fintype ι]

theorem conditional_rational_owner_99
    (e u c : ι → ℝ) (B M V : ℝ)
    (he : ∀ i, 0 ≤ e i) (hM : 0 ≤ M) (hB : 0 ≤ B)
    (hV : 0 ≤ V)
    (hcap : ∀ i, e i ≤ M)
    (hshift : ∀ i, Real.sqrt (e i) ≤ Real.sqrt 3*u i+c i/5)
    (hsection : (∑ i : ι, u i) ≤ (29/6:ℝ)*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ ((29/6:ℝ)*Real.sqrt 3+8/5)^2*B^2*M := by
  classical
  let T : ℝ := Real.sqrt M
  let K : ℝ := (29/6:ℝ)*Real.sqrt 3+8/5
  have hT : 0 ≤ T := Real.sqrt_nonneg _
  have hT2 : T^2 = M := Real.sq_sqrt hM
  have hsite (i : ι) :
      e i ≤ T*(Real.sqrt 3*u i+c i/5) := by
    have hroot : Real.sqrt (e i) ≤ T :=
      Real.sqrt_le_sqrt (hcap i)
    have hp : Real.sqrt (e i) * Real.sqrt (e i) ≤
        T * Real.sqrt (e i) :=
      mul_le_mul_of_nonneg_right hroot (Real.sqrt_nonneg _)
    calc
      e i = (Real.sqrt (e i))^2 := (Real.sq_sqrt (he i)).symm
      _ ≤ T*Real.sqrt (e i) := by nlinarith [hp]
      _ ≤ T*(Real.sqrt 3*u i+c i/5) :=
        mul_le_mul_of_nonneg_left (hshift i) hT
  have hfactor :
      (∑ i : ι, (Real.sqrt 3*u i+c i/5)) =
        Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/5 := by
    rw [Finset.sum_add_distrib]
    rw [← Finset.mul_sum, ← Finset.sum_div]
  have hVsite :
      V ≤ T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/5) := by
    calc
      V = ∑ i : ι, e i := hvariance
      _ ≤ ∑ i : ι, T*(Real.sqrt 3*u i+c i/5) :=
        Finset.sum_le_sum (fun i _ => hsite i)
      _ = T*(∑ i : ι, (Real.sqrt 3*u i+c i/5)) := by rw [Finset.mul_sum]
      _ = T*(Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/5) := by rw [hfactor]
  have hu := mul_le_mul_of_nonneg_left hsection (Real.sqrt_nonneg (3:ℝ))
  have hc := mul_le_mul_of_nonneg_left hcover (show (0:ℝ) ≤ 1/5 by norm_num)
  have hbudget :
      Real.sqrt 3*(∑ i : ι, u i)+(∑ i : ι, c i)/5 ≤ K*B := by
    dsimp [K]
    nlinarith [hu, hc]
  have hupper : V ≤ T*(K*B) :=
    hVsite.trans (mul_le_mul_of_nonneg_left hbudget hT)
  have hK : 0 ≤ K := by dsimp [K]; positivity
  have hright : 0 ≤ T*(K*B) :=
    mul_nonneg hT (mul_nonneg hK hB)
  have hquad : V^2 ≤ (T*(K*B))^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hupper) (add_nonneg hright hV)]
  calc
    V^2 ≤ (T*(K*B))^2 := hquad
    _ = ((29/6:ℝ)*Real.sqrt 3+8/5)^2*B^2*M := by
      rw [← hT2]
      dsimp [K]
      ring

theorem conditional_rational_owner_strict_hundred
    (e u c : ι → ℝ) (B M V : ℝ)
    (he : ∀ i, 0 ≤ e i) (hM : 0 ≤ M) (hB : 0 ≤ B)
    (hV : 0 ≤ V)
    (hcap : ∀ i, e i ≤ M)
    (hshift : ∀ i, Real.sqrt (e i) ≤ Real.sqrt 3*u i+c i/5)
    (hsection : (∑ i : ι, u i) ≤ (29/6:ℝ)*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ 100*B^2*M := by
  have h := conditional_rational_owner_99 e u c B M V
    he hM hB hV hcap hshift hsection hcover hvariance
  have hk := rational_c5_coefficient_lt_hundred
  have hBM : 0 ≤ B^2*M := mul_nonneg (sq_nonneg B) hM
  have hh := mul_le_mul_of_nonneg_right (le_of_lt hk) hBM
  nlinarith [h, hh]

end Nightfall.Q2RationalTwoFifths
