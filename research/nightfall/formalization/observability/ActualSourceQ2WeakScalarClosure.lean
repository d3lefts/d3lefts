import ActualProductQ2ScalarClosure

/-!
# Q2 scalar closure using ONLY the original-source section budget

The additive L1 budget is *not independent*: if a_i is the norm of
the original-law mean of centered section U_i, Jensen gives a_i ≤ u_i.
Thus an 8B bound on the actual section norms implies BOTH
sum a_i ≤ 8B and sum z_i ≤ 16B by soft-noise contraction.

This is deliberately a conditional scalar theorem: original-source
Jensen/section, greedy matching and fourth-moment premises remain
visible, not silently imported as axioms. The weaker constant is
256(1+sqrt 3)^2 for rho=sqrt 3, independent of dimension and bias.
-/

namespace Nightfall.Observability.ActualSourceQ2WeakScalarClosure

open Finset
open Nightfall.Observability.ActualProductQ2ScalarClosure

variable {ι : Type*} [Fintype ι]

/-- The exact fourth-moment scalar conclusion with no separate
additive-oscillation hypothesis. Only one 8B source-section budget
is required; owner-wise Jensen supplies the rest. -/
theorem q2_scalar_from_single_source_section_budget
    (a u c z s : ι → ℝ)
    (B T ρ V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hρ : 0 ≤ ρ)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (haca : ∀ i, a i ≤ T) (hzca : ∀ i, z i ≤ T)
    (hJensen : ∀ i, a i ≤ u i)
    (hnoise : ∀ i, z i ≤ u i + a i)
    (hsection : (∑ i : ι, u i) ≤ 8 * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hmoment : ∀ i, s i ≤ z i * (c i + ρ * T))
    (hvariance : V = (∑ i : ι, (a i)^2) + ∑ i : ι, s i) :
    V ≤ 16 * (1 + ρ) * B * T := by
  classical
  have ha_total : (∑ i : ι, a i) ≤ 8 * B := by
    have h := Finset.sum_le_sum
      (s := (Finset.univ : Finset ι))
      (fun i _ => hJensen i)
    exact le_trans h hsection
  have hz_total : (∑ i : ι, z i) ≤ 16 * B := by
    have h := Finset.sum_le_sum
      (s := (Finset.univ : Finset ι))
      (fun i _ => hnoise i)
    rw [Finset.sum_add_distrib] at h
    linarith
  have h := q2_scalar_endpoint a c z s B T 8 ρ V
    hB hT (by norm_num) hρ ha hc hz haca hzca hmoment
    (by simpa only [mul_comm] using ha_total)
    hcover
    (by norm_num at hz_total ⊢; exact hz_total)
    hvariance
  norm_num at h ⊢
  exact h

/-- Explicit squared version, with T²=M; this closes the exact
target coefficient from the same *conditional* single-section budget.
The genuine source-to-numeric hypotheses are not yet all derived. -/
theorem q2_scalar_squared_from_single_source_section_budget
    (a u c z s : ι → ℝ)
    (B T M ρ V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (hρ : 0 ≤ ρ)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (haca : ∀ i, a i ≤ T) (hzca : ∀ i, z i ≤ T)
    (hJensen : ∀ i, a i ≤ u i)
    (hnoise : ∀ i, z i ≤ u i + a i)
    (hsection : (∑ i : ι, u i) ≤ 8 * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hmoment : ∀ i, s i ≤ z i * (c i + ρ * T))
    (hvariance : V = (∑ i : ι, (a i)^2) + ∑ i : ι, s i)
    (hT2 : T ^ 2 = M) :
    V ^ 2 ≤ (16 * (1 + ρ)) ^ 2 * B ^ 2 * M := by
  have h := q2_scalar_from_single_source_section_budget
    a u c z s B T ρ V hB hT hρ ha hc hz haca hzca
    hJensen hnoise hsection hcover hmoment hvariance
  have hupper : 0 ≤ 16 * (1 + ρ) * B * T := by
    apply mul_nonneg
    · apply mul_nonneg
      · nlinarith
      · exact hB
    · exact hT
  have hsq : V ^ 2 ≤ (16 * (1 + ρ) * B * T)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr h) (add_nonneg hupper hV)]
  calc
    V ^ 2 ≤ (16 * (1 + ρ) * B * T)^2 := hsq
    _ = (16 * (1 + ρ)) ^ 2 * B ^ 2 * M := by
      rw [← hT2]
      ring

end Nightfall.Observability.ActualSourceQ2WeakScalarClosure
