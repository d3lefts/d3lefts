import Route1MaximalConditionalKernel
import Route1StarCoupling

/-!
# Route 1 concrete star marginal terminal from actual maximal kernels

No assumed conditional kernel is passed to this theorem. For a finite
common alphabet, each target q_theta has a normalized maximal K built
from exact finite min-residual mass. Applying the existing verified
starMass construction yields all simultaneous component marginals.
-/

namespace Nightfall.Route1StarMaximalTerminal

open Finset
open Nightfall.Route1FiniteMaxCoupling
open Nightfall.Route1StarCoupling

variable {Θ A : Type} [Fintype Θ] [DecidableEq Θ]
    [Fintype A] [DecidableEq A]

noncomputable def concreteStarMass (p : A → ℝ) (q : Θ → A → ℝ)
    (a : A) (bs : Θ → A) : ℝ :=
  starMass p (fun θ => maximalKernel p (q θ)) a bs

theorem concreteStar_reference
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ b, q θ b) = 1)
    (a : A) :
    (∑ bs, concreteStarMass p q a bs) = p a := by
  have hK : ∀ θ a, (∑ b, maximalKernel p (q θ) a b) = 1 := by
    intro θ x
    exact maximalKernel_row p (q θ) hp (hq θ) x
  exact starMass_reference p (fun θ => maximalKernel p (q θ)) hK a

theorem concreteStar_component
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a)
    (hq0 : ∀ θ b, 0 ≤ q θ b)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ b, q θ b) = 1)
    (θ₀ : Θ) (b : A) :
    (∑ a : A, ∑ bs : Θ → A,
      if bs θ₀ = b then concreteStarMass p q a bs else 0) =
        q θ₀ b := by
  have hK : ∀ θ a, (∑ x, maximalKernel p (q θ) a x) = 1 := by
    intro θ x
    exact maximalKernel_row p (q θ) hp (hq θ) x
  have hpush : ∀ θ x,
      (∑ a, p a * maximalKernel p (q θ) a x) = q θ x := by
    intro θ x
    exact maximalKernel_push p (q θ) hp0 (hq0 θ) hp (hq θ) x
  exact starMass_component p q (fun θ => maximalKernel p (q θ))
    hK hpush θ₀ b

/-- Fully simultaneous marginal star, independent of the number
    of components. This is a genuine no-assumed-K composition, NOT the
    full FUR-free polylog-M quantum simulation terminal. -/
theorem concreteStar_all_marginals
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a)
    (hq0 : ∀ θ b, 0 ≤ q θ b)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ b, q θ b) = 1) :
    (∀ a, (∑ bs, concreteStarMass p q a bs) = p a) ∧
    (∀ θ₀ b, (∑ a : A, ∑ bs : Θ → A,
      if bs θ₀ = b then concreteStarMass p q a bs else 0) = q θ₀ b) := by
  constructor
  · intro a
    exact concreteStar_reference p q hp hq a
  · intro θ₀ b
    exact concreteStar_component p q hp0 hq0 hp hq θ₀ b

end Nightfall.Route1StarMaximalTerminal

#print axioms Nightfall.Route1StarMaximalTerminal.concreteStar_reference
#print axioms Nightfall.Route1StarMaximalTerminal.concreteStar_component
#print axioms Nightfall.Route1StarMaximalTerminal.concreteStar_all_marginals
