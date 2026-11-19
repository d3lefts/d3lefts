import Mathlib

/-!
# NIGHTFALL: finite two-block mixture exponential-moment certificate

This file certifies a generic information-theoretic operator without
Gaussian assumptions, and with zero-weight components permitted.
The upstream Gaussian sign / Walsh-Hadamard specialization remains paper only.
-/

namespace Nightfall.Forrelation.Information

open Finset

variable {Θ F G : Type*} [Fintype Θ] [Fintype F] [Fintype G]

/-- A full-block mixture cannot allocate more mass to a block-
    coordinate than its actual first marginal. Zero weights are allowed. -/
theorem weighted_component_le_marginal
    (w : Θ → ℝ) (a : Θ → F → ℝ) (u : F → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (ha : ∀ θ f, 0 ≤ a θ f)
    (hmarg : ∀ f, (∑ θ : Θ, w θ * a θ f) = u f)
    (θ : Θ) (f : F) : w θ * a θ f ≤ u f := by
  rw [← hmarg f]
  exact Finset.single_le_sum
    (fun j _ => mul_nonneg (hw j) (ha j f)) (Finset.mem_univ θ)

/-- The basic M-fold exponential-moment bound for latent mixtures.
    Each component has independent *blocks* F and G (not necessarily
    independent coordinates within each block). The marginal of F is u.
    No posterior division, entropy convention, or positive-atom hypothesis. -/
theorem mixture_kernel_domination
    (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (u : F → ℝ) (K : F → G → ℝ) (C : ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (ha : ∀ θ f, 0 ≤ a θ f)
    (hb : ∀ θ g, 0 ≤ b θ g)
    (hbsum : ∀ θ, (∑ g : G, b θ g) = 1)
    (hmarg : ∀ f, (∑ θ : Θ, w θ * a θ f) = u f)
    (hK : ∀ f g, 0 ≤ K f g)
    (hU : ∀ g, (∑ f : F, u f * K f g) ≤ C) :
    (∑ θ : Θ, w θ * (∑ f : F, a θ f * (∑ g : G, b θ g * K f g))) ≤
      (Fintype.card Θ : ℝ) * C := by
  have hθ (θ : Θ) :
      w θ * (∑ f : F, a θ f * (∑ g : G, b θ g * K f g)) ≤ C := by
    calc
      _ = ∑ f : F, (w θ * a θ f) * (∑ g : G, b θ g * K f g) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro f _
            ring
      _ ≤ ∑ f : F, u f * (∑ g : G, b θ g * K f g) := by
            apply Finset.sum_le_sum
            intro f _
            apply mul_le_mul_of_nonneg_right
              (weighted_component_le_marginal w a u hw ha hmarg θ f)
            exact Finset.sum_nonneg (fun g _ => mul_nonneg (hb θ g) (hK f g))
      _ = ∑ g : G, b θ g * (∑ f : F, u f * K f g) := by
            calc
              _ = ∑ f : F, ∑ g : G, u f * (b θ g * K f g) := by
                apply Finset.sum_congr rfl
                intro f _
                rw [Finset.mul_sum]
              _ = ∑ g : G, ∑ f : F, u f * (b θ g * K f g) :=
                Finset.sum_comm
              _ = ∑ g : G, b θ g * (∑ f : F, u f * K f g) := by
                apply Finset.sum_congr rfl
                intro g _
                rw [Finset.mul_sum]
                apply Finset.sum_congr rfl
                intro f _
                ring
      _ ≤ ∑ g : G, b θ g * C := by
            apply Finset.sum_le_sum
            intro g _
            exact mul_le_mul_of_nonneg_left (hU g) (hb θ g)
      _ = C := by rw [← Finset.sum_mul, hbsum θ, one_mul]
  calc
    _ ≤ ∑ _θ : Θ, C := Finset.sum_le_sum (fun θ _ => hθ θ)
    _ = (Fintype.card Θ : ℝ) * C := by simp

/-- Jensen's exponential inequality for an arbitrary normalized finite table. -/
theorem finite_exp_jensen {Ω : Type*} [Fintype Ω]
    (p : Ω → ℝ) (hp : ∀ x, 0 ≤ p x)
    (hp1 : (∑ x : Ω, p x) = 1) (z : Ω → ℝ) :
    Real.exp (∑ x : Ω, p x * z x) ≤
      ∑ x : Ω, p x * Real.exp (z x) := by
  have h := convexOn_exp.map_sum_le (t := Finset.univ)
    (w := p) (p := z) (fun x _ => hp x)
    (by simpa using hp1) (fun _ _ => Set.mem_univ _)
  simpa only [smul_eq_mul] using h

end Nightfall.Forrelation.Information
