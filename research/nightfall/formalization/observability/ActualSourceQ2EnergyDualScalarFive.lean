import ActualSourceQ2EnergyDualScalar
/-! Source-independent energy-dual scalar closure with a 5B section budget. -/
namespace Nightfall.Observability.ActualSourceQ2EnergyDualScalarFive
open Finset
open Nightfall.Observability.ActualSourceQ2EnergyDualScalar
variable {ι : Type*} [Fintype ι]
theorem energy_dual_scalar_endpoint_five
    (a u c z s : ι → ℝ) (B T M V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (hau : ∀ i, a i ≤ u i)
    (hzu : ∀ i, z i ≤ u i + a i)
    (hmoment : ∀ i, s i ≤ z i*(c i+Real.sqrt 3*T))
    (hjoint : ∀ i, (a i)^2+s i ≤ M)
    (hsection : (∑ i : ι, u i) ≤ 5*B)
    (hadd : (∑ i : ι, a i) ≤ 2*(1+Real.sqrt 2)*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hvariance : V = (∑ i : ι, (a i)^2) + (∑ i : ι, s i))
    (hT2 : T^2=M) :
    V^2 ≤
      (403/40+(9/4)*Real.sqrt 2+(7/2)*Real.sqrt 3+
        Real.sqrt 6)^2 * B^2 * M := by
  classical
  let ρ : ℝ := Real.sqrt 3
  let p : ℝ := 37/40+ρ/2
  let q : ℝ := 9/8+ρ/2
  let A : ℝ := 2*(1+Real.sqrt 2)
  let K : ℝ := 5*p+A*q+(2/5:ℝ)*8
  have hρ0 : 0 ≤ ρ := Real.sqrt_nonneg 3
  have hρ2 : ρ^2=3 := Real.sq_sqrt (by norm_num)
  have hp0 : 0 ≤ p := by dsimp [p]; positivity
  have hq0 : 0 ≤ q := by dsimp [q]; positivity
  have hA0 : 0 ≤ A := by dsimp [A]; positivity
  have hK0 : 0 ≤ K := by dsimp [K]; positivity
  have hsite (i : ι) :
      (a i)^2+s i ≤
        p*T*(u i)+q*T*(a i)+(2/5:ℝ)*T*(c i) := by
    have hjoint2 : (a i)^2+s i ≤ T^2 := by rw [hT2]; exact hjoint i
    have h := energy_dual_site
      (a i) (u i) (c i) (z i) (s i) T ρ
      hρ0 hρ2 (ha i) (hc i) hT (hau i) (hzu i)
      (hmoment i) hjoint2
    simpa only [p,q,ρ] using h
  have hsum :
      V ≤ p*T*(∑ i : ι, u i)+
        q*T*(∑ i : ι, a i)+(2/5:ℝ)*T*(∑ i : ι, c i) := by
    calc
      V = ∑ i : ι, ((a i)^2+s i) := by
        rw [hvariance, Finset.sum_add_distrib]
      _ ≤ ∑ i : ι,
          (p*T*(u i)+q*T*(a i)+(2/5:ℝ)*T*(c i)) :=
            Finset.sum_le_sum (fun i _ => hsite i)
      _ = p*T*(∑ i : ι, u i)+
          q*T*(∑ i : ι, a i)+(2/5:ℝ)*T*(∑ i : ι, c i) := by
            simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
  have huB :
      p*T*(∑ i : ι, u i) ≤ p*T*(5*B) :=
    mul_le_mul_of_nonneg_left hsection (mul_nonneg hp0 hT)
  have haB :
      q*T*(∑ i : ι, a i) ≤ q*T*(A*B) := by
    dsimp [A]
    exact mul_le_mul_of_nonneg_left hadd (mul_nonneg hq0 hT)
  have hcB :
      (2/5:ℝ)*T*(∑ i : ι, c i) ≤
        (2/5:ℝ)*T*(8*B) :=
    mul_le_mul_of_nonneg_left hcover (mul_nonneg (by norm_num) hT)
  have hVbound : V ≤ K*B*T := by
    dsimp [K]
    nlinarith [hsum, huB, haB, hcB]
  have hKBT : 0 ≤ K*B*T :=
    mul_nonneg (mul_nonneg hK0 hB) hT
  have hVsq : V^2 ≤ (K*B*T)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVbound)
      (add_nonneg hKBT hV)]
  have hKexact :
      K = 403/40+(9/4)*Real.sqrt 2+(7/2)*Real.sqrt 3+
        Real.sqrt 6 := by
    dsimp [K,p,q,A,ρ]
    have hroot :
        Real.sqrt 6 = Real.sqrt 2 * Real.sqrt 3 := by
      calc
        Real.sqrt 6 = Real.sqrt ((2:ℝ)*3) := by norm_num
        _ = Real.sqrt 2 * Real.sqrt 3 :=
          Real.sqrt_mul (by norm_num : (0:ℝ) ≤ 2) (3:ℝ)
    rw [hroot]
    ring
  calc
    V^2 ≤ (K*B*T)^2 := hVsq
    _ = (403/40+(9/4)*Real.sqrt 2+(7/2)*Real.sqrt 3+
        Real.sqrt 6)^2 * B^2 * M := by
          rw [← hT2, hKexact]
          ring

end Nightfall.Observability.ActualSourceQ2EnergyDualScalarFive
