import Mathlib

/-!
# Dimension-free quadratic endpoint, using only the 8B section budget

The stronger v7/v8 bounds need a separate additive-projection
estimate. A simpler dimension-free exponent-two closure is available:
the *same* real source section budget gives the additive L2 norm
budget by Jensen, at no extra additive-projection cost.

At the scalar level:
  Σ u_i <= 8 B, a_i^norm <= u_i, z_i <= u_i + a_i^norm,
  Σ c_i <= 8 B, z_i <= R,
  additiveEnergy_i <= R a_i^norm,
  pairEnergy_i <= c_i z_i + sqrt(3) R z_i.

Then V <= 16 (1+sqrt(3)) B R.
For R=sqrt(M), V² <= 256(1+sqrt(3))² B² M.

This module is ONLY the exact scalar assembly. Its named interface
hypotheses are mathematical obligations to discharge from the
original source, not a terminal universal influence certificate.
The source matching, section, owned-energy and fourth moment files
are being connected separately. No additional premise is concealed.
-/

namespace Nightfall.Observability.QuadraticSectionOnlyClosure

open Finset

variable {ι : Type} [Fintype ι]

theorem symmetric_section_quadratic_closure
    (B R V : ℝ)
    (c u h z additiveEnergy pairEnergy : ι → ℝ)
    (hR : 0 ≤ R)
    (hB : 0 ≤ B)
    (hcpos : ∀ i, 0 ≤ c i)
    (hV : V ≤ (∑ i : ι, additiveEnergy i) +
      (∑ i : ι, pairEnergy i))
    (hsections : (∑ i : ι, u i) ≤ 8 * B)
    (haddJensen : ∀ i, h i ≤ u i)
    (hcost : (∑ i : ι, c i) ≤ 8 * B)
    (hzbudget : ∀ i, z i ≤ u i + h i)
    (hzmax : ∀ i, z i ≤ R)
    (haddEnergy : ∀ i, additiveEnergy i ≤ R * h i)
    (hquadEnergy : ∀ i, pairEnergy i ≤
      c i * z i + (Real.sqrt 3 * R) * z i) :
    V ≤ (16 * (1 + Real.sqrt 3)) * B * R := by
  classical
  have hsumh : (∑ i : ι, h i) ≤ 8 * B := by
    calc
      (∑ i : ι, h i) ≤ ∑ i : ι, u i :=
        Finset.sum_le_sum (fun i _ => haddJensen i)
      _ ≤ 8 * B := hsections
  have hsumz : (∑ i : ι, z i) ≤ 16 * B := by
    calc
      (∑ i : ι, z i) ≤ ∑ i : ι, (u i + h i) :=
        Finset.sum_le_sum (fun i _ => hzbudget i)
      _ = (∑ i : ι, u i) + (∑ i : ι, h i) :=
        Finset.sum_add_distrib
      _ ≤ 16 * B := by linarith [hsections, hsumh]
  have hcz :
      (∑ i : ι, c i * z i) ≤ 8 * B * R := by
    calc
      (∑ i : ι, c i * z i) ≤ ∑ i : ι, c i * R := by
        apply Finset.sum_le_sum
        intro i _
        exact mul_le_mul_of_nonneg_left (hzmax i) (hcpos i)
      _ = (∑ i : ι, c i) * R := by rw [Finset.sum_mul]
      _ ≤ 8 * B * R :=
        mul_le_mul_of_nonneg_right hcost hR
  have hroot : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg 3
  have hzs :
      (∑ i : ι, (Real.sqrt 3 * R) * z i) ≤
        (Real.sqrt 3 * R) * (16 * B) := by
    calc
      (∑ i : ι, (Real.sqrt 3 * R) * z i) =
          (Real.sqrt 3 * R) * (∑ i : ι, z i) := by
            rw [Finset.mul_sum]
      _ ≤ (Real.sqrt 3 * R) * (16 * B) :=
        mul_le_mul_of_nonneg_left hsumz (mul_nonneg hroot hR)
  have ha :
      (∑ i : ι, additiveEnergy i) ≤ R * (8 * B) := by
    calc
      (∑ i : ι, additiveEnergy i) ≤
          ∑ i : ι, R * h i :=
        Finset.sum_le_sum (fun i _ => haddEnergy i)
      _ = R * (∑ i : ι, h i) := by rw [Finset.mul_sum]
      _ ≤ R * (8 * B) :=
        mul_le_mul_of_nonneg_left hsumh hR
  have hs :
      (∑ i : ι, pairEnergy i) ≤
        8 * B * R + (Real.sqrt 3 * R) * (16 * B) := by
    calc
      (∑ i : ι, pairEnergy i) ≤
          ∑ i : ι, (c i * z i + (Real.sqrt 3 * R) * z i) :=
        Finset.sum_le_sum (fun i _ => hquadEnergy i)
      _ = (∑ i : ι, c i * z i) +
        (∑ i : ι, (Real.sqrt 3 * R) * z i) :=
        Finset.sum_add_distrib
      _ ≤ 8 * B * R + (Real.sqrt 3 * R) * (16 * B) :=
        add_le_add hcz hzs
  calc
    V ≤ R * (8 * B) +
        (8 * B * R + (Real.sqrt 3 * R) * (16 * B)) := by
          linarith [hV, ha, hs]
    _ = (16 * (1 + Real.sqrt 3)) * B * R := by ring

/-- Exact squared terminal coefficient for any completed source
instantiation of the preceding scalar closure. This is not a
replacement for source-level proof obligations. -/
theorem symmetric_section_squared_closure
    (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M) (hV : 0 ≤ V)
    (hbound : V ≤ (16 * (1 + Real.sqrt 3)) * B * Real.sqrt M) :
    V^2 ≤ (256 * (1 + Real.sqrt 3)^2) * B^2 * M := by
  have hC : 0 ≤ 16 * (1 + Real.sqrt 3) := by
    nlinarith [Real.sqrt_nonneg 3]
  have hroot : (Real.sqrt M)^2 = M := Real.sq_sqrt hM
  have hprod : 0 ≤ (16 * (1 + Real.sqrt 3)) * B * Real.sqrt M :=
    mul_nonneg
      (mul_nonneg hC hB) (Real.sqrt_nonneg M)
  have hsq : V^2 ≤
      ((16 * (1 + Real.sqrt 3)) * B * Real.sqrt M)^2 := by
    nlinarith [hV, hbound, hprod]
  calc
    V^2 ≤ ((16 * (1 + Real.sqrt 3)) * B * Real.sqrt M)^2 := hsq
    _ = (256 * (1 + Real.sqrt 3)^2) * B^2 * (Real.sqrt M)^2 := by ring
    _ = (256 * (1 + Real.sqrt 3)^2) * B^2 * M := by rw [hroot]

end Nightfall.Observability.QuadraticSectionOnlyClosure
