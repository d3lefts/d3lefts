import ActualSourceQ2CoupledScalarClosure

/-!
# Q2 energy-dual 736.673: exact site SOS, not a source-only certificate

Unlike the older 1064 scalar, use the SINGLE shared coordinate cap
  a_i^2 + ownedMoment2_i <= M.
This theorem is strictly deterministic. A separate original-source Lean
bridge must derive that cap without adding it as a terminal hypothesis.
-/

namespace Nightfall.Observability.ActualSourceQ2EnergyDualScalar

open Finset

variable {ι : Type*} [Fintype ι]

/-- A new local energy-dual certificate; rho^2=3, rho>=0.
The original-source owned fourth moment is UNCHANGED. -/
theorem energy_dual_site
    (a u c z s T ρ : ℝ)
    (hρ : 0 ≤ ρ) (hρ2 : ρ^2 = 3)
    (ha : 0 ≤ a) (hc : 0 ≤ c) (hT : 0 ≤ T)
    (hau : a ≤ u) (hzu : z ≤ u+a)
    (hstep : s ≤ z*(c+ρ*T))
    (henergy : a^2+s ≤ T^2) :
    a^2+s ≤
      (37/40+ρ/2)*T*u +
      (9/8+ρ/2)*T*a +
      (2/5)*T*c := by
  let p : ℝ := 37/40+ρ/2
  let W : ℝ := u+a
  have hW : 0 ≤ W := by dsimp [W]; linarith
  have ha2W : 2*a ≤ W := by dsimp [W]; linarith
  have hρmax : ρ ≤ (7/4 : ℝ) := by nlinarith [hρ2]
  have hpρ : ρ ≤ p := by dsimp [p]; linarith
  have hmult : 0 ≤ c+ρ*T :=
    add_nonneg hc (mul_nonneg hρ hT)
  have hsrough : s ≤ W*(c+ρ*T) := by
    have h := mul_le_mul_of_nonneg_right hzu hmult
    linarith
  by_cases htzero : T = 0
  · subst T
    nlinarith [henergy]
  have htpos : 0 < T := lt_of_le_of_ne hT (Ne.symm htzero)
  by_cases hsmall : 5*W ≤ 2*T
  · have haT : 5*a ≤ T := by linarith [ha2W]
    have hasq : 5*a^2 ≤ T*a := by
      nlinarith [mul_nonneg ha (sub_nonneg.mpr (by linarith : 0 ≤ T-5*a))]
    have hcW : 5*W*c ≤ 2*T*c := by
      nlinarith [mul_nonneg hc (sub_nonneg.mpr (by linarith : 0 ≤ 2*T-5*W))]
    have hrW : ρ*T*W ≤ p*T*W := by
      have h := mul_nonneg
        (sub_nonneg.mpr hpρ) (mul_nonneg hT hW)
      nlinarith
    dsimp [p, W] at *
    nlinarith [hsrough, hasq, hcW, hrW]
  · have hlarge : 0 ≤ 5*W-2*T := by linarith
    have hWpos : 0 < W := by
      have hb : 0 < 2*T := by positivity
      linarith
    have hcoef : (5+2*ρ)^2 = 37+20*ρ := by
      nlinarith [hρ2]
    have hSosEq :
        8*((5*p)*W^2-(5+2*ρ)*W*T+2*T^2+a*(W-2*a)) =
        ((5+2*ρ)*W-4*T)^2 + 8*a*(W-2*a) := by
      calc
        8*((5*p)*W^2-(5+2*ρ)*W*T+2*T^2+a*(W-2*a)) =
          (37+20*ρ)*W^2-8*(5+2*ρ)*W*T+
            16*T^2+8*a*(W-2*a) := by dsimp [p]; ring
        _ = (5+2*ρ)^2*W^2-8*(5+2*ρ)*W*T+
              16*T^2+8*a*(W-2*a) := by rw [hcoef]
        _ = ((5+2*ρ)*W-4*T)^2+8*a*(W-2*a) := by ring
    have hArem : 0 ≤ a*(W-2*a) :=
      mul_nonneg ha (by linarith : 0 ≤ W-2*a)
    have hSOS :
        0 ≤ (5*p)*W^2-(5+2*ρ)*W*T+2*T^2+a*(W-2*a) := by
      nlinarith [hSosEq, sq_nonneg ((5+2*ρ)*W-4*T), hArem]
    have hpos1 :
        0 ≤ (5*W-2*T)*(T^2-(a^2+s)) :=
      mul_nonneg hlarge (by linarith)
    have hpos2 :
        0 ≤ (2*T)*(a^2+W*(c+ρ*T)-(a^2+s)) :=
      mul_nonneg (by linarith : 0 ≤ 2*T) (by linarith [hsrough])
    have hpos3 :
        0 ≤ T*((5*p)*W^2-(5+2*ρ)*W*T+
           2*T^2+a*(W-2*a)) :=
      mul_nonneg hT hSOS
    have hid :
      (5*W-2*T)*(T^2-(a^2+s))+
        (2*T)*(a^2+W*(c+ρ*T)-(a^2+s))+
        T*((5*p)*W^2-(5+2*ρ)*W*T+2*T^2+a*(W-2*a)) =
      5*W*(p*T*u+(p+1/5)*T*a+(2/5)*T*c-(a^2+s)) := by
      dsimp [W]
      ring
    have hpositive :
      0 ≤ 5*W*(p*T*u+(p+1/5)*T*a+(2/5)*T*c-(a^2+s)) := by
      linarith [hpos1, hpos2, hpos3, hid]
    have hgoal :
        a^2+s ≤ p*T*u+(p+1/5)*T*a+(2/5)*T*c := by
      by_contra hn
      have hneg :
          p*T*u+(p+1/5)*T*a+(2/5)*T*c-(a^2+s)<0 := by
        linarith
      have hpneg :
          5*W*(p*T*u+(p+1/5)*T*a+(2/5)*T*c-(a^2+s)) < 0 :=
        mul_neg_of_pos_of_neg (by linarith : 0 < 5*W) hneg
      linarith
    dsimp [p] at hgoal
    convert hgoal using 1 <;> ring


/-- Deterministic Q2 endpoint from the same actual row's combined
singleton-plus-owned influence cap. Global source budgets retain their
previously certified 8B, 8B, 2(1+sqrt2)B values. -/
theorem energy_dual_scalar_endpoint
    (a u c z s : ι → ℝ) (B T M V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (hau : ∀ i, a i ≤ u i)
    (hzu : ∀ i, z i ≤ u i + a i)
    (hmoment : ∀ i, s i ≤ z i*(c i+Real.sqrt 3*T))
    (hjoint : ∀ i, (a i)^2+s i ≤ M)
    (hsection : (∑ i : ι, u i) ≤ 8*B)
    (hadd : (∑ i : ι, a i) ≤ 2*(1+Real.sqrt 2)*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hvariance : V = (∑ i : ι, (a i)^2) + (∑ i : ι, s i))
    (hT2 : T^2=M) :
    V^2 ≤
      (257/20+(9/4)*Real.sqrt 2+5*Real.sqrt 3+
        Real.sqrt 6)^2 * B^2 * M := by
  classical
  let ρ : ℝ := Real.sqrt 3
  let p : ℝ := 37/40+ρ/2
  let q : ℝ := 9/8+ρ/2
  let A : ℝ := 2*(1+Real.sqrt 2)
  let K : ℝ := 8*p+A*q+(2/5:ℝ)*8
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
      p*T*(∑ i : ι, u i) ≤ p*T*(8*B) :=
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
      K = 257/20+(9/4)*Real.sqrt 2+5*Real.sqrt 3+
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
    _ = (257/20+(9/4)*Real.sqrt 2+5*Real.sqrt 3+
        Real.sqrt 6)^2 * B^2 * M := by
          rw [← hT2, hKexact]
          ring

end Nightfall.Observability.ActualSourceQ2EnergyDualScalar
