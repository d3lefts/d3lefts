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
    dsimp [W]
    linarith
  by_cases htzero : T = 0
  · subst T
    dsimp [p]
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

end Nightfall.Observability.ActualSourceQ2EnergyDualScalar
