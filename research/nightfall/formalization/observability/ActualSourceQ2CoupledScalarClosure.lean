import ActualProductQ2ScalarClosure

/-!
# Coupled Jensen / noise scalar endpoint: a smaller constant than 1228

New step: use a_i <= u_i at the SAME time as z_i <= u_i + a_i
and a_i,z_i <= sqrt(M). Old scalar closure budgeted these separately.

This is a stand-alone deterministic theorem. The source-only
termination is composed separately and requires no new source axioms.

Claim for K =
  [8(1+sqrt(3))+2(1+sqrt(2))(sqrt(3)+1/2)]^2
  = 1064.9584490262937... .
-/

namespace Nightfall.Observability.ActualSourceQ2CoupledScalarClosure

open Finset

variable {ι : Type*} [Fintype ι]

/-- Joint rather than separately maximized singleton and owner cost.
Here rho >= 1/2; this is tight at a=T/2,z=T,u=T/2. -/
theorem coupled_singleton_owner_site
    (a u z T ρ : ℝ)
    (hT : 0 ≤ T) (hρ : (1/2 : ℝ) ≤ ρ)
    (ha : 0 ≤ a) (haT : a ≤ T)
    (hzT : z ≤ T)
    (haU : a ≤ u) (hzU : z ≤ u + a) :
    a^2 + ρ * T * z ≤
      ρ * T * u + (ρ + 1/2) * T * a := by
  have hρ0 : 0 ≤ ρ := by linarith
  have hρT : 0 ≤ ρ * T := mul_nonneg hρ0 hT
  have hzsub := mul_le_mul_of_nonneg_left hzU hρT
  by_cases hsmall : 2 * a ≤ T
  · have hpos : 0 ≤ a * (T - 2 * a) :=
      mul_nonneg ha (by linarith)
    nlinarith
  · have hbig : T ≤ 2 * a := by linarith
    have hseg : 0 ≤ (a - T/2) * (T - a) :=
      mul_nonneg (by linarith) (by linarith)
    have hrest : 0 ≤ (ρ - 1/2) * T * (2*a - T) :=
      mul_nonneg
        (mul_nonneg (by linarith) hT)
        (by linarith)
    have hzupper := mul_le_mul_of_nonneg_left hzT hρT
    have huupper := mul_le_mul_of_nonneg_left haU hρT
    nlinarith

/-- Exact deterministic reduction with finite weighted sums.
No coordinate count, influence or source-product assumption occurs here. -/
theorem coupled_scalar_endpoint
    (a u c z s : ι → ℝ)
    (B T M A ρ V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (hA : 0 ≤ A) (hρ : (1/2 : ℝ) ≤ ρ)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (haT : ∀ i, a i ≤ T)
    (hzT : ∀ i, z i ≤ T)
    (haU : ∀ i, a i ≤ u i)
    (hzU : ∀ i, z i ≤ u i + a i)
    (hsection : (∑ i : ι, u i) ≤ 8 * B)
    (hadd : (∑ i : ι, a i) ≤ A * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hmoment : ∀ i, s i ≤ z i * (c i + ρ * T))
    (hvariance : V = (∑ i : ι, (a i)^2) + ∑ i : ι, s i)
    (hT2 : T^2 = M) :
    V^2 ≤
      (8*(1+ρ)+(ρ+1/2)*A)^2 * B^2 * M := by
  classical
  let K : ℝ := 8*(1+ρ)+(ρ+1/2)*A
  have hρ0 : 0 ≤ ρ := by linarith
  have hρT : 0 ≤ ρ*T := mul_nonneg hρ0 hT
  have hρhalf : 0 ≤ ρ+1/2 := by linarith
  have hsite (i : ι) :
      (a i)^2 + ρ*T*(z i) ≤
        ρ*T*(u i) + (ρ+1/2)*T*(a i) := by
    exact coupled_singleton_owner_site
      (a i) (u i) (z i) T ρ
      hT hρ (ha i) (haT i) (hzT i) (haU i) (hzU i)
  have hsiteSum :
      (∑ i : ι, (a i)^2) + ρ*T*(∑ i : ι, z i) ≤
        ρ*T*(∑ i : ι, u i) + (ρ+1/2)*T*(∑ i : ι, a i) := by
    calc
      (∑ i : ι, (a i)^2) + ρ*T*(∑ i : ι, z i) =
          ∑ i : ι, ((a i)^2 + ρ*T*(z i)) := by
            rw [Finset.sum_add_distrib, ← Finset.mul_sum]
      _ ≤ ∑ i : ι, (ρ*T*(u i) + (ρ+1/2)*T*(a i)) :=
        Finset.sum_le_sum (fun i _ => hsite i)
      _ = ρ*T*(∑ i : ι, u i) + (ρ+1/2)*T*(∑ i : ι, a i) := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  have hcz (i : ι) : c i*z i ≤ T*c i := by
    nlinarith [mul_nonneg (hc i) (sub_nonneg.mpr (hzT i))]
  have hczSum : (∑ i : ι, c i*z i) ≤ T*(∑ i : ι, c i) := by
    calc
      (∑ i : ι, c i*z i) ≤ ∑ i : ι, T*c i :=
        Finset.sum_le_sum (fun i _ => hcz i)
      _ = T*(∑ i : ι, c i) := by rw [← Finset.mul_sum]
  have hsSum : (∑ i : ι, s i) ≤
      (∑ i : ι, c i*z i) + ρ*T*(∑ i : ι, z i) := by
    calc
      (∑ i : ι, s i) ≤ ∑ i : ι, z i*(c i+ρ*T) :=
        Finset.sum_le_sum (fun i _ => hmoment i)
      _ = (∑ i : ι, c i*z i) + ρ*T*(∑ i : ι, z i) := by
        simp only [mul_add, Finset.sum_add_distrib]
        rw [Finset.mul_sum]
        congr 1
        · apply Finset.sum_congr rfl
          intro i _
          ring
        · apply Finset.sum_congr rfl
          intro i _
          ring
  have hrough : V ≤
      T*(∑ i : ι, c i) +
      ρ*T*(∑ i : ι, u i) +
      (ρ+1/2)*T*(∑ i : ι, a i) := by
    rw [hvariance]
    linarith [hsiteSum, hczSum, hsSum]
  have hcbound := mul_le_mul_of_nonneg_left hcover hT
  have hubound := mul_le_mul_of_nonneg_left hsection hρT
  have habound := mul_le_mul_of_nonneg_left hadd
    (mul_nonneg hρhalf hT)
  have hVbound : V ≤ K*B*T := by
    dsimp [K]
    nlinarith [hrough, hcbound, hubound, habound]
  have hK : 0 ≤ K := by
    dsimp [K]
    positivity
  have hcoef : 0 ≤ K*B*T :=
    mul_nonneg (mul_nonneg hK hB) hT
  have hsq : V^2 ≤ (K*B*T)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVbound)
      (add_nonneg hcoef hV)]
  calc
    V^2 ≤ (K*B*T)^2 := hsq
    _ = (8*(1+ρ)+(ρ+1/2)*A)^2 * B^2 * M := by
      rw [← hT2]
      dsimp [K]
      ring

/-- Coefficient improvement with no new source-side assumptions beyond
the old source Jensen inequality, already proved in current Q2. -/
theorem q2_1064_scalar_from_existing_budgets
    (a u c z s : ι → ℝ)
    (B T M V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (haT : ∀ i, a i ≤ T) (hzT : ∀ i, z i ≤ T)
    (haU : ∀ i, a i ≤ u i) (hzU : ∀ i, z i ≤ u i + a i)
    (hsection : (∑ i : ι, u i) ≤ 8 * B)
    (hadd : (∑ i : ι, a i) ≤ (2*(1+Real.sqrt 2))*B)
    (hcover : (∑ i : ι, c i) ≤ 8*B)
    (hmoment : ∀ i, s i ≤ z i*(c i+Real.sqrt 3*T))
    (hvariance : V = (∑ i : ι, (a i)^2) + ∑ i : ι, s i)
    (hT2 : T^2 = M) :
    V^2 ≤ (8*(1+Real.sqrt 3) +
      (Real.sqrt 3+1/2)*2*(1+Real.sqrt 2))^2 * B^2*M := by
  have hA : 0 ≤ (2*(1+Real.sqrt 2) : ℝ) := by positivity
  have hρ : (1/2 : ℝ) ≤ Real.sqrt 3 := by
    have hroot : (Real.sqrt (3 : ℝ))^2 = 3 :=
      Real.sq_sqrt (by norm_num)
    have hn : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
    nlinarith
  have h := coupled_scalar_endpoint a u c z s
    B T M (2*(1+Real.sqrt 2)) (Real.sqrt 3) V
    hB hT hV hA hρ ha hc haT hzT haU hzU
    hsection hadd hcover hmoment hvariance hT2
  convert h using 1 <;> ring

end Nightfall.Observability.ActualSourceQ2CoupledScalarClosure
