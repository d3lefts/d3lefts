import LatentMixtureVariance

/-!
# From latent factorized masses to true coordinate conditional variance

For a selected coordinate A and the remaining-coordinate fibre Γ, the
correlated mixture has mass
  ν(γ,a) = Σθ wθ * qθ(γ) * pθ(a).
The theorem proves, for *any* rowwise prediction z(γ), that its weighted
squared loss under ν dominates the weighted component conditional variances.
When z is the ν conditional mean this is exactly the true correlated heat-bath
influence lower bound. No joint-density positivity requirement is used.
-/
namespace Nightfall.LatentMixture

open Finset

variable {Θ Γ A : Type*} [Fintype Θ] [DecidableEq Θ]
  [Fintype Γ] [DecidableEq Γ] [Fintype A] [DecidableEq A]

theorem factorized_mixture_conditional_variance
    (w : Θ → ℝ) (q : Θ → Γ → ℝ) (p : Θ → A → ℝ)
    (g : Γ → A → ℝ) (z : Γ → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (hq : ∀ θ γ, 0 ≤ q θ γ)
    (hp : ∀ θ, (∑ a, p θ a) = 1)
    (hp0 : ∀ θ a, 0 ≤ p θ a) :
    (∑ θ : Θ, w θ * (∑ γ : Γ, q θ γ *
        (∑ a : A, p θ a * (g γ a - mean (p θ) (g γ))^2))) ≤
    (∑ γ : Γ, ∑ a : A,
        (∑ θ : Θ, w θ * q θ γ * p θ a) * (g γ a - z γ)^2) := by
  have hh := conditional_mixture_fibre_dominance
    w q p g z hw hq hp hp0
  have hleft :
      (∑ γ : Γ, ∑ θ : Θ, (w θ * q θ γ) *
         (∑ a : A, p θ a * (g γ a - mean (p θ) (g γ))^2)) =
      (∑ θ : Θ, w θ * (∑ γ : Γ, q θ γ *
         (∑ a : A, p θ a * (g γ a - mean (p θ) (g γ))^2))) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro θ hθ
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro γ hγ
    ring
  have hright :
      (∑ γ : Γ, ∑ θ : Θ, (w θ * q θ γ) *
         (∑ a : A, p θ a * (g γ a - z γ)^2)) =
      (∑ γ : Γ, ∑ a : A,
        (∑ θ : Θ, w θ * q θ γ * p θ a) * (g γ a - z γ)^2) := by
    apply Finset.sum_congr rfl
    intro γ hγ
    rw [Finset.sum_mul]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro a ha
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro θ hθ
    ring
  rw [hleft, hright] at hh
  exact hh

end Nightfall.LatentMixture
