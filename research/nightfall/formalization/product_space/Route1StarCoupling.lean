import Mathlib

/-!
# Route 1: finite star kernel, simultaneous marginals

This file formalizes the FINITE STAR CONSTRUCTION once each component's
conditional kernel K_theta(b|a) is supplied. It does not construct maximal
coupling kernels or prove the entire Route 1 simulation theorem.

No new axioms or sorry. The independent conditional kernels are combined
over a finite latent alphabet by a product and their joint law has the exact
required pairwise marginals. In particular no all-pairs correlated-sampling
theorem is needed for the star coupling.
-/

namespace Nightfall.Route1StarCoupling

open Finset

variable {Θ A : Type*} [Fintype Θ] [DecidableEq Θ]
  [Fintype A] [DecidableEq A]

private theorem sum_prod_eq_prod_sum (F : Θ → A → ℝ) :
    (∑ bs : Θ → A, ∏ θ, F θ (bs θ)) = ∏ θ, ∑ a, F θ a := by
  rw [Finset.prod_univ_sum, Fintype.piFinset_univ]

/-- Conditional probability of a whole vector of component letters,
    given a fixed common reference letter. -/
noncomputable def conditionalStarMass
    (K : Θ → A → A → ℝ) (a : A) (bs : Θ → A) : ℝ :=
  ∏ θ, K θ a (bs θ)

/-- Probability of the shared reference and all component letters. -/
noncomputable def starMass
    (p : A → ℝ) (K : Θ → A → A → ℝ) (a : A) (bs : Θ → A) : ℝ :=
  p a * conditionalStarMass K a bs

/-- Each conditional vector law is normalized if all its kernels are. -/
theorem conditionalStarMass_sum
    (K : Θ → A → A → ℝ)
    (hK : ∀ θ a, ∑ b, K θ a b = 1) (a : A) :
    (∑ bs : Θ → A, conditionalStarMass K a bs) = 1 := by
  unfold conditionalStarMass
  rw [sum_prod_eq_prod_sum]
  simp [hK]

/-- Projecting a conditional vector to one named component recovers
    exactly that component's conditional kernel, including zero entries. -/
theorem conditionalStarMass_coord
    (K : Θ → A → A → ℝ)
    (hK : ∀ θ a, ∑ b, K θ a b = 1)
    (a : A) (θ₀ : Θ) (b : A) :
    (∑ bs : Θ → A,
      if bs θ₀ = b then conditionalStarMass K a bs else 0) = K θ₀ a b := by
  let F : Θ → A → ℝ :=
    fun θ c => if θ = θ₀ then (if c = b then K θ a c else 0) else K θ a c
  have hpoint : ∀ bs : Θ → A,
      (∏ θ, F θ (bs θ)) =
        if bs θ₀ = b then (∏ θ, K θ a (bs θ)) else 0 := by
    intro bs
    by_cases hb : bs θ₀ = b
    · have hF : ∀ θ, F θ (bs θ) = K θ a (bs θ) := by
        intro θ
        by_cases he : θ = θ₀
        · subst θ
          simp [F, hb]
        · simp [F, he]
      calc
        (∏ θ, F θ (bs θ)) = ∏ θ, K θ a (bs θ) :=
          Finset.prod_congr rfl (fun θ _ => hF θ)
        _ = (if bs θ₀ = b then (∏ θ, K θ a (bs θ)) else 0) := by simp [hb]
    · have hzero : F θ₀ (bs θ₀) = 0 := by simp [F, hb]
      have hp : (∏ θ, F θ (bs θ)) = 0 :=
        Finset.prod_eq_zero (Finset.mem_univ θ₀) hzero
      simp [hp, hb]
  have hFsum : ∀ θ, (∑ c, F θ c) = if θ = θ₀ then K θ₀ a b else 1 := by
    intro θ
    by_cases he : θ = θ₀
    · subst θ
      simp [F]
    · simp [F, he, hK θ a]
  calc
    (∑ bs : Θ → A,
        if bs θ₀ = b then conditionalStarMass K a bs else 0)
      = ∑ bs : Θ → A, ∏ θ, F θ (bs θ) := by
          unfold conditionalStarMass
          exact Finset.sum_congr rfl (fun bs _ => (hpoint bs).symm)
    _ = ∏ θ, ∑ c, F θ c := sum_prod_eq_prod_sum F
    _ = ∏ θ, if θ = θ₀ then K θ₀ a b else 1 :=
      Finset.prod_congr rfl (fun θ _ => hFsum θ)
    _ = K θ₀ a b := by simp

/-- The shared-reference marginal is exactly p. -/
theorem starMass_reference
    (p : A → ℝ) (K : Θ → A → A → ℝ)
    (hK : ∀ θ a, ∑ b, K θ a b = 1) (a : A) :
    (∑ bs : Θ → A, starMass p K a bs) = p a := by
  calc
    (∑ bs : Θ → A, starMass p K a bs)
        = p a * (∑ bs : Θ → A, conditionalStarMass K a bs) := by
            simp only [starMass, Finset.mul_sum]
    _ = p a := by rw [conditionalStarMass_sum K hK a]; ring

/-- Every component/reference PAIR has precisely the specified
    conditional marginal p(a) K_theta(b|a), simultaneously. -/
theorem starMass_pair
    (p : A → ℝ) (K : Θ → A → A → ℝ)
    (hK : ∀ θ a, ∑ b, K θ a b = 1)
    (a : A) (θ₀ : Θ) (b : A) :
    (∑ bs : Θ → A, if bs θ₀ = b then starMass p K a bs else 0)
      = p a * K θ₀ a b := by
  calc
    (∑ bs : Θ → A, if bs θ₀ = b then starMass p K a bs else 0)
        = ∑ bs : Θ → A, p a *
            (if bs θ₀ = b then conditionalStarMass K a bs else 0) := by
              apply Finset.sum_congr rfl
              intro bs _
              by_cases hb : bs θ₀ = b <;> simp [starMass, hb]
    _ = p a * (∑ bs : Θ → A,
        if bs θ₀ = b then conditionalStarMass K a bs else 0) := by
          rw [Finset.mul_sum]
    _ = p a * K θ₀ a b := by
          rw [conditionalStarMass_coord K hK a θ₀ b]

/-- Each component's marginal is q_theta if the conditional kernels
    push the common reference p to q_theta. -/
theorem starMass_component
    (p : A → ℝ) (q : Θ → A → ℝ) (K : Θ → A → A → ℝ)
    (hK : ∀ θ a, ∑ b, K θ a b = 1)
    (hpush : ∀ θ b, (∑ a, p a * K θ a b) = q θ b)
    (θ₀ : Θ) (b : A) :
    (∑ a : A, ∑ bs : Θ → A,
      if bs θ₀ = b then starMass p K a bs else 0) = q θ₀ b := by
  simp_rw [starMass_pair p K hK]
  exact hpush θ₀ b

end Nightfall.Route1StarCoupling

#print axioms Nightfall.Route1StarCoupling.conditionalStarMass_sum
#print axioms Nightfall.Route1StarCoupling.conditionalStarMass_coord
#print axioms Nightfall.Route1StarCoupling.starMass_reference
#print axioms Nightfall.Route1StarCoupling.starMass_pair
#print axioms Nightfall.Route1StarCoupling.starMass_component
