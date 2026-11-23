import Mathlib

/-!
# Finite mixture information: an exact Shannon chain identity

For arbitrary finite latent Θ and output X, normalized component masses
Q θ : X → ℝ (zero atoms allowed) and arbitrary latent weights w, the
unconditional finite-sum entropy identity shows that mutual information's
posterior-entropy expression equals output entropy minus expected
component entropy.

When ∑θ wθ=1, the left-hand side is precisely the mutInfo expression
already used in Route1WynerSimulation, after substituting Qθ=prodMass Pθ.
This source-free reusable algebra is not itself the affine-code C_W identity;
the source connection, conditional entropy bound and infimum witness remain
separate proof gates. No positivity floor or approximation is needed.
-/

namespace Nightfall.FiniteMixtureEntropyChain

open Finset Real

variable {Θ X : Type*} [Fintype Θ] [Fintype X]

/-- Finite Shannon chain law in raw negMulLog form. This exact equality
requires only component normalization ∑_x Qθ(x)=1; the algebra
also works for signed w because negMulLog's Mathlib multiplication
identity holds algebraically on the real extension. Applications to
probability distributions add nonnegativity and total weight one. -/
theorem finite_mixture_entropy_chain
    (w : Θ → ℝ) (Q : Θ → X → ℝ)
    (hQ1 : ∀ θ, ∑ x, Q θ x = 1) :
    (∑ θ, negMulLog (w θ)) -
      (∑ x, (∑ θ, negMulLog (w θ * Q θ x)) -
        negMulLog (∑ θ, w θ * Q θ x)) =
    (∑ x, negMulLog (∑ θ, w θ * Q θ x)) -
      (∑ θ, w θ * (∑ x, negMulLog (Q θ x))) := by
  classical
  have hfactor (θ : Θ) :
      (∑ x : X, negMulLog (w θ * Q θ x)) =
        negMulLog (w θ) + w θ * (∑ x : X, negMulLog (Q θ x)) := by
    calc
      (∑ x : X, negMulLog (w θ * Q θ x)) =
          ∑ x : X, (Q θ x * negMulLog (w θ) +
            w θ * negMulLog (Q θ x)) := by
              apply Finset.sum_congr rfl
              intro x _
              rw [Real.negMulLog_mul]
      _ = (∑ x : X, Q θ x) * negMulLog (w θ) +
          w θ * (∑ x : X, negMulLog (Q θ x)) := by
            rw [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
      _ = negMulLog (w θ) +
          w θ * (∑ x : X, negMulLog (Q θ x)) := by
            rw [hQ1 θ, one_mul]
  have hswap :
      (∑ x : X, ∑ θ : Θ, negMulLog (w θ * Q θ x)) =
        (∑ θ : Θ, negMulLog (w θ)) +
          (∑ θ : Θ, w θ * (∑ x : X, negMulLog (Q θ x))) := by
    calc
      (∑ x : X, ∑ θ : Θ, negMulLog (w θ * Q θ x)) =
          ∑ θ : Θ, ∑ x : X, negMulLog (w θ * Q θ x) :=
            Finset.sum_comm
      _ = ∑ θ : Θ, (negMulLog (w θ) +
            w θ * (∑ x : X, negMulLog (Q θ x))) := by
              exact Finset.sum_congr rfl (fun θ _ => hfactor θ)
      _ = (∑ θ : Θ, negMulLog (w θ)) +
          (∑ θ : Θ, w θ * (∑ x : X, negMulLog (Q θ x))) := by
            rw [Finset.sum_add_distrib]
  have hsplit :
      (∑ x : X, (∑ θ : Θ, negMulLog (w θ * Q θ x)) -
        negMulLog (∑ θ : Θ, w θ * Q θ x)) =
      (∑ x : X, ∑ θ : Θ, negMulLog (w θ * Q θ x)) -
        (∑ x : X, negMulLog (∑ θ : Θ, w θ * Q θ x)) := by
          exact Finset.sum_sub_distrib
            (fun x : X => ∑ θ : Θ, negMulLog (w θ * Q θ x))
            (fun x : X => negMulLog (∑ θ : Θ, w θ * Q θ x))
  rw [hsplit, hswap]
  ring

end Nightfall.FiniteMixtureEntropyChain

#print axioms Nightfall.FiniteMixtureEntropyChain.finite_mixture_entropy_chain
