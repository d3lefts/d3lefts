import Mathlib

/-!
# NIGHTFALL — finite Shannon mutual-information chain rule

This file certifies the algebraic chain rule for actual finite joint mass
arrays using the Shannon-entropy formula, including arrays containing zeros.
No positivity or normalization is required for the cancellation identity;
probabilistic interpretation of these expressions does require probability
masses. This is a necessary component of the Route 1/Wyner potential
argument, NOT the posterior drift or final simulator.
-/

namespace Nightfall.Route1FiniteInformationChain

open Finset

variable {Θ A B : Type*}
  [Fintype Θ] [Fintype A] [Fintype B]
  [DecidableEq Θ] [DecidableEq A] [DecidableEq B]

/-- Finite Shannon entropy in nats. The zero-mass convention is
given by `Real.log 0 = 0` in Lean. -/
noncomputable def entropy {T : Type*} [Fintype T]
    (q : T → ℝ) : ℝ :=
  -(∑ t, q t * Real.log (q t))

noncomputable def massW (p : Θ → A → B → ℝ) : Θ → ℝ :=
  fun θ => ∑ a : A, ∑ b : B, p θ a b

noncomputable def massA (p : Θ → A → B → ℝ) : A → ℝ :=
  fun a => ∑ θ : Θ, ∑ b : B, p θ a b

noncomputable def massB (p : Θ → A → B → ℝ) : B → ℝ :=
  fun b => ∑ θ : Θ, ∑ a : A, p θ a b

noncomputable def massWA (p : Θ → A → B → ℝ) : Θ × A → ℝ :=
  fun z => ∑ b : B, p z.1 z.2 b

noncomputable def massWB (p : Θ → A → B → ℝ) : Θ × B → ℝ :=
  fun z => ∑ a : A, p z.1 a z.2

noncomputable def massAB (p : Θ → A → B → ℝ) : A × B → ℝ :=
  fun z => ∑ θ : Θ, p θ z.1 z.2

noncomputable def massWAB (p : Θ → A → B → ℝ) : Θ × (A × B) → ℝ :=
  fun z => p z.1 z.2.1 z.2.2

/-- Information between W and both observed blocks. -/
noncomputable def informationWAB (p : Θ → A → B → ℝ) : ℝ :=
  entropy (massW p) + entropy (massAB p) - entropy (massWAB p)

/-- Information between W and first block A. -/
noncomputable def informationWA (p : Θ → A → B → ℝ) : ℝ :=
  entropy (massW p) + entropy (massA p) - entropy (massWA p)

/-- Conditional information I(W;B|A) in joint entropy form. -/
noncomputable def conditionalInformationWB_givenA
    (p : Θ → A → B → ℝ) : ℝ :=
  entropy (massWA p) + entropy (massAB p) -
    entropy (massA p) - entropy (massWAB p)

/-- Source-defined finite Shannon chain rule:
    I(W;A,B) = I(W;A) + I(W;B|A).
No independence, nonzero-atom, or posterior assumption is hidden. -/
theorem finite_information_chain (p : Θ → A → B → ℝ) :
    informationWAB p = informationWA p +
      conditionalInformationWB_givenA p := by
  unfold informationWAB informationWA conditionalInformationWB_givenA
  ring

/-- Symmetric chain order, corresponding to querying B before A. -/
noncomputable def informationWB (p : Θ → A → B → ℝ) : ℝ :=
  entropy (massW p) + entropy (massB p) - entropy (massWB p)

noncomputable def conditionalInformationWA_givenB
    (p : Θ → A → B → ℝ) : ℝ :=
  entropy (massWB p) + entropy (massAB p) -
    entropy (massB p) - entropy (massWAB p)

theorem finite_information_chain_reverse (p : Θ → A → B → ℝ) :
    informationWAB p = informationWB p +
      conditionalInformationWA_givenB p := by
  unfold informationWAB informationWB conditionalInformationWA_givenB
  ring

end Nightfall.Route1FiniteInformationChain

#print axioms Nightfall.Route1FiniteInformationChain.finite_information_chain
#print axioms Nightfall.Route1FiniteInformationChain.finite_information_chain_reverse
