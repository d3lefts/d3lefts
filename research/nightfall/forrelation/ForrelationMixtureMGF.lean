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

namespace Nightfall.Forrelation.Information

open Finset

variable {Θ F G : Type*} [Fintype Θ] [Fintype F] [Fintype G]

/-- Unnormalized nonnegative density on a product of the latent state
    and two conditionally independent blocks. -/
noncomputable def latentJoint (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (t : Θ × (F × G)) : ℝ := w t.1 * a t.1 t.2.1 * b t.1 t.2.2

/-- Fubini for the latent mixture, formulated entirely as finite sums. -/
theorem latentJoint_sum_kernel
    (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (K : F → G → ℝ) :
    (∑ t : Θ × (F × G), latentJoint w a b t * K t.2.1 t.2.2) =
      ∑ θ : Θ, w θ * (∑ f : F, a θ f * (∑ g : G, b θ g * K f g)) := by
  classical
  calc
    _ = ∑ θ : Θ, ∑ f : F, ∑ g : G,
          (w θ * a θ f * b θ g) * K f g := by
          simp only [Fintype.sum_prod_type, latentJoint]
    _ = ∑ θ : Θ, w θ * (∑ f : F, a θ f * (∑ g : G, b θ g * K f g)) := by
          apply Finset.sum_congr rfl
          intro θ _
          calc
            _ = ∑ f : F, ∑ g : G, (w θ * a θ f) * (b θ g * K f g) := by
                  apply Finset.sum_congr rfl
                  intro f _
                  apply Finset.sum_congr rfl
                  intro g _
                  ring
            _ = ∑ f : F, (w θ * a θ f) * (∑ g : G, b θ g * K f g) := by
                  apply Finset.sum_congr rfl
                  intro f _
                  rw [Finset.mul_sum]
            _ = _ := by
                  rw [Finset.mul_sum]
                  apply Finset.sum_congr rfl
                  intro f _
                  ring

/-- Normalization is proved from the actual component/source mass identities. -/
theorem latentJoint_sum_one
    (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (hw1 : (∑ θ : Θ, w θ) = 1)
    (ha1 : ∀ θ, (∑ f : F, a θ f) = 1)
    (hb1 : ∀ θ, (∑ g : G, b θ g) = 1) :
    (∑ t : Θ × (F × G), latentJoint w a b t) = 1 := by
  have h := latentJoint_sum_kernel w a b (fun _ _ => (1 : ℝ))
  simp only [mul_one] at h
  rw [h]
  have hx (θ : Θ) :
      (∑ f : F, a θ f * (∑ g : G, b θ g)) = 1 := by
    simp [hb1 θ, ha1 θ]
  simpa [hx, hw1]

/-- All zero weights are legal; a latent product table is nonnegative. -/
theorem latentJoint_nonneg
    (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (ha : ∀ θ f, 0 ≤ a θ f)
    (hb : ∀ θ g, 0 ≤ b θ g)
    (t : Θ × (F × G)) : 0 ≤ latentJoint w a b t := by
  unfold latentJoint
  exact mul_nonneg (mul_nonneg (hw t.1) (ha t.1 t.2.1)) (hb t.1 t.2.2)

/-- Entire finite latent-mixture exponential certificate, with *no* KL,
    positive-atom, Gaussian or quantum assumption. The only analytic input
    is the stated exponential-moment inequality under the first-block law. -/
theorem latent_mixture_exp_certificate
    (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (u : F → ℝ) (S : F → G → ℝ) (lam κ : ℝ)
    (hw : ∀ θ, 0 ≤ w θ)
    (ha : ∀ θ f, 0 ≤ a θ f)
    (hb : ∀ θ g, 0 ≤ b θ g)
    (hw1 : (∑ θ : Θ, w θ) = 1)
    (ha1 : ∀ θ, (∑ f : F, a θ f) = 1)
    (hb1 : ∀ θ, (∑ g : G, b θ g) = 1)
    (hmarg : ∀ f, (∑ θ : Θ, w θ * a θ f) = u f)
    (hmgf : ∀ g, (∑ f : F, u f * Real.exp (lam * S f g)) ≤ Real.exp κ) :
    Real.exp (∑ t : Θ × (F × G), latentJoint w a b t * (lam * S t.2.1 t.2.2)) ≤
      (Fintype.card Θ : ℝ) * Real.exp κ := by
  calc
    _ ≤ ∑ t : Θ × (F × G), latentJoint w a b t *
          Real.exp (lam * S t.2.1 t.2.2) :=
          finite_exp_jensen (latentJoint w a b)
            (latentJoint_nonneg w a b hw ha hb)
            (latentJoint_sum_one w a b hw1 ha1 hb1)
            (fun t => lam * S t.2.1 t.2.2)
    _ = ∑ θ : Θ, w θ * (∑ f : F, a θ f *
          (∑ g : G, b θ g * Real.exp (lam * S f g))) :=
          latentJoint_sum_kernel w a b (fun f g => Real.exp (lam * S f g))
    _ ≤ (Fintype.card Θ : ℝ) * Real.exp κ :=
          mixture_kernel_domination w a b u
            (fun f g => Real.exp (lam * S f g)) (Real.exp κ)
            hw ha hb hb1 hmarg
            (fun f g => (Real.exp_pos (lam * S f g)).le) hmgf

end Nightfall.Forrelation.Information

namespace Nightfall.Forrelation.Information

open Finset

variable {Θ F G : Type*} [Fintype Θ] [Fintype F] [Fintype G]

/-- **Abstract exponential lower bound on mixture size.**
The only analytic hypothesis is the single-block MGF estimate
at the discriminating scale lam = N*c; the rest is kernel-checked
finite latent-mixture algebra and exponential Jensen. The theorem
does not assume Gaussianity, Hadamard matrices or independent coordinates. -/
theorem latent_exp_component_lower_bound
    (w : Θ → ℝ) (a : Θ → F → ℝ) (b : Θ → G → ℝ)
    (u : F → ℝ) (S : F → G → ℝ) (N c : ℝ)
    (hN : 0 < N)
    (hw : ∀ θ, 0 ≤ w θ)
    (ha : ∀ θ f, 0 ≤ a θ f)
    (hb : ∀ θ g, 0 ≤ b θ g)
    (hw1 : (∑ θ : Θ, w θ) = 1)
    (ha1 : ∀ θ, (∑ f : F, a θ f) = 1)
    (hb1 : ∀ θ, (∑ g : G, b θ g) = 1)
    (hmarg : ∀ f, (∑ θ : Θ, w θ * a θ f) = u f)
    (hmean :
      (∑ t : Θ × (F × G), latentJoint w a b t * S t.2.1 t.2.2) = c)
    (hmgf : ∀ g, (∑ f : F, u f * Real.exp ((N * c) * S f g)) ≤
      Real.exp (((N * c) ^ 2) / (2 * N))) :
    Real.exp (N * c ^ 2 / 2) ≤ (Fintype.card Θ : ℝ) := by
  have hbase := latent_mixture_exp_certificate w a b u S
    (N * c) (((N * c) ^ 2) / (2 * N))
    hw ha hb hw1 ha1 hb1 hmarg hmgf
  have hweighted :
      (∑ t : Θ × (F × G),
        latentJoint w a b t * ((N * c) * S t.2.1 t.2.2)) = (N * c) * c := by
    calc
      _ = ∑ t : Θ × (F × G),
          (N * c) * (latentJoint w a b t * S t.2.1 t.2.2) := by
            apply Finset.sum_congr rfl
            intro t _
            ring
      _ = (N * c) * (∑ t : Θ × (F × G),
          latentJoint w a b t * S t.2.1 t.2.2) := by
            rw [Finset.mul_sum]
      _ = (N * c) * c := by rw [hmean]
  rw [hweighted] at hbase
  have hkappa : ((N * c) ^ 2) / (2 * N) = N * c ^ 2 / 2 := by
    field_simp [hN.ne'] <;> ring
  rw [hkappa] at hbase
  have hbound : Real.exp (N * c ^ 2) ≤
      (Fintype.card Θ : ℝ) * Real.exp (N * c ^ 2 / 2) := by
    convert hbase using 1
    congr 1 <;> ring
  have hratio :
      Real.exp (N * c ^ 2) / Real.exp (N * c ^ 2 / 2) ≤
        (Fintype.card Θ : ℝ) :=
    (div_le_iff₀ (Real.exp_pos _)).mpr hbound
  calc
    Real.exp (N * c ^ 2 / 2) =
        Real.exp (N * c ^ 2) / Real.exp (N * c ^ 2 / 2) := by
          rw [← Real.exp_sub]
          congr 1 <;> ring
    _ ≤ _ := hratio

end Nightfall.Forrelation.Information
