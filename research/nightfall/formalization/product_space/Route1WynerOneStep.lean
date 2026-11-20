import Route1PolylogSimulation

/-!
# NIGHTFALL Route 1 — one-coordinate source-connected Wyner information split

Let `v θ` be unnormalised mixture weights and `R θ b` a finite
conditional observation channel. The unnormalised mutual-information
potential is

  RemainingInfo R v = Ent v - ∑ b, Ent (fun θ => v θ * R θ b).

For a head channel `P θ a` and a residual channel `R θ b`, the
conditional-product observation law is `P θ a * R θ b`.
The source-level identities below prove exactly

  J(P ⊗ R, v) = [Ent(v) - ∑a Ent(v * P_a)]
                 + ∑a J(R, v * P_a),

and identify the bracketed term with both a weighted KL information charge
and a squared-TV lower bound, including zero-mass posterior branches.

This is a substantive source-level lemma for the Wyner extension of PR #970,
NOT the fully adaptive remaining-coordinate DTree terminal or the infimum
over conditional-product representations.
-/

namespace Nightfall.Route1WynerOneStep

open Finset
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Mixture

variable {Θ A B : Type}
  [Fintype Θ] [DecidableEq Θ]
  [Fintype A] [DecidableEq A]
  [Fintype B] [DecidableEq B]

/-- Unnormalised information between a latent label and one arbitrary finite
observation channel. Its normalised interpretation is V*I(W;Y). -/
noncomputable def remainingInfo (R : Θ → B → ℝ) (v : Θ → ℝ) : ℝ :=
  Ent v - ∑ b : B, Ent (fun θ => v θ * R θ b)

/-- Independent head and residual observations conditional on θ. -/
noncomputable def jointChannel (P : Θ → A → ℝ) (R : Θ → B → ℝ) :
    Θ → (A × B) → ℝ :=
  fun θ z => P θ z.1 * R θ z.2

/-- Unnormalised posterior weights after observing a head symbol. -/
def childWeight (P : Θ → A → ℝ) (v : Θ → ℝ) (a : A) : Θ → ℝ :=
  fun θ => v θ * P θ a

/-- Posterior predictive distribution of the head coordinate. -/
noncomputable def predictive (P : Θ → A → ℝ) (v : Θ → ℝ) : A → ℝ :=
  fun a => (∑ θ, v θ * P θ a) / Vs v

/-- The *exact* algebraic information chain, without positivity assumptions:
the future-information potential of a product channel splits into the
one-coordinate entropy decrease and the total child information potential. -/
theorem remainingInfo_joint_chain
    (P : Θ → A → ℝ) (R : Θ → B → ℝ) (v : Θ → ℝ) :
    remainingInfo (jointChannel P R) v =
      (Ent v - ∑ a : A, Ent (childWeight P v a)) +
      ∑ a : A, remainingInfo R (childWeight P v a) := by
  classical
  have hterm : ∀ (a : A) (b : B),
      (fun θ : Θ => v θ * (P θ a * R θ b)) =
      (fun θ : Θ => (v θ * P θ a) * R θ b) := by
    intro a b
    funext θ
    ring
  simp only [remainingInfo, jointChannel, childWeight, Fintype.sum_prod_type]
  simp only [hterm]
  rw [Finset.sum_sub_distrib]
  ring

/-- Source-level entropy charge from the already-certified Route 1 entropy
theorem. The relevant product measure has one observed head coordinate. -/
theorem entropy_head_eq_weightedKL
    (P : Θ → A → ℝ)
    (hP0 : ∀ θ a, 0 ≤ P θ a)
    (hP1 : ∀ θ, ∑ a, P θ a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (hV : 0 < Vs v) :
    Ent v - ∑ a : A, Ent (childWeight P v a) =
      ∑ θ, v θ * kl (P θ) (predictive P v) := by
  let Q : Θ → Unit → A → ℝ := fun θ _ a => P θ a
  have hQ0 : ∀ θ i a, 0 ≤ Q θ i a := by
    intro θ i a
    exact hP0 θ a
  have hQ1 : ∀ θ i, ∑ a, Q θ i a = 1 := by
    intro θ i
    exact hP1 θ
  have h := ent_children Q hQ0 hQ1 v hv hV ()
  change (∑ a : A, Ent (childWeight P v a)) =
    Ent v - ∑ θ, v θ * kl (P θ) (predictive P v) at h
  rw [h]
  ring

/-- The one-step decomposition already has the **real source KL charge**,
not merely a formal information identity. -/
theorem remainingInfo_joint_KL
    (P : Θ → A → ℝ) (R : Θ → B → ℝ)
    (hP0 : ∀ θ a, 0 ≤ P θ a)
    (hP1 : ∀ θ, ∑ a, P θ a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (hV : 0 < Vs v) :
    remainingInfo (jointChannel P R) v =
      (∑ θ, v θ * kl (P θ) (predictive P v)) +
      ∑ a : A, remainingInfo R (childWeight P v a) := by
  rw [remainingInfo_joint_chain]
  rw [entropy_head_eq_weightedKL P hP0 hP1 v hv hV]

/-- The exact future-information change pays for the same squared
total-variation statistic used in the certified Route 1 crux. -/
theorem remainingInfo_joint_charge
    (P : Θ → A → ℝ) (R : Θ → B → ℝ)
    (hP0 : ∀ θ a, 0 ≤ P θ a)
    (hP1 : ∀ θ, ∑ a, P θ a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (hV : 0 < Vs v) :
    (∑ θ, v θ * tvd (P θ) (predictive P v) ^ 2) ≤
      remainingInfo (jointChannel P R) v -
        ∑ a : A, remainingInfo R (childWeight P v a) := by
  let Q : Θ → Unit → A → ℝ := fun θ _ a => P θ a
  have hQ0 : ∀ θ i a, 0 ≤ Q θ i a := by
    intro θ i a
    exact hP0 θ a
  have hQ1 : ∀ θ i, ∑ a, Q θ i a = 1 := by
    intro θ i
    exact hP1 θ
  have hdrop := ent_drop_ge Q hQ0 hQ1 v hv hV ()
  change (∑ θ, v θ * tvd (P θ) (predictive P v) ^ 2) ≤
    Ent v - ∑ a : A, Ent (childWeight P v a) at hdrop
  rw [remainingInfo_joint_chain]
  linarith

/-- The remaining-information potential is nonnegative for an actual
finite conditional channel, including v=0 and zero observation atoms.
This is necessary for the stopping-time potential proof. -/
theorem remainingInfo_nonneg
    (R : Θ → B → ℝ)
    (hR0 : ∀ θ b, 0 ≤ R θ b)
    (hR1 : ∀ θ, ∑ b, R θ b = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) :
    0 ≤ remainingInfo R v := by
  have hV0 : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
  by_cases hV : 0 < Vs v
  · let Q : Θ → Unit → B → ℝ := fun θ _ b => R θ b
    have hQ0 : ∀ θ i b, 0 ≤ Q θ i b := by
      intro θ i b
      exact hR0 θ b
    have hQ1 : ∀ θ i, ∑ b, Q θ i b = 1 := by
      intro θ i
      exact hR1 θ
    have hdrop := ent_drop_ge Q hQ0 hQ1 v hv hV ()
    have hsq : 0 ≤ ∑ θ, v θ * tvd (R θ) (predictive R v) ^ 2 :=
      Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (sq_nonneg _)
    change (∑ θ, v θ * tvd (R θ) (predictive R v) ^ 2) ≤
      Ent v - ∑ b : B, Ent (fun θ => v θ * R θ b) at hdrop
    exact hsq.trans hdrop
  · have hVeq : Vs v = 0 := le_antisymm (le_of_not_gt hV) hV0
    have hvzero : ∀ θ, v θ = 0 := fun θ =>
      (Finset.sum_eq_zero_iff_of_nonneg (fun θ _ => hv θ)).mp hVeq θ (mem_univ θ)
    simp [remainingInfo, Ent, Vs, hvzero]

end Nightfall.Route1WynerOneStep

#print axioms Nightfall.Route1WynerOneStep.remainingInfo_joint_chain
#print axioms Nightfall.Route1WynerOneStep.entropy_head_eq_weightedKL
#print axioms Nightfall.Route1WynerOneStep.remainingInfo_joint_KL
#print axioms Nightfall.Route1WynerOneStep.remainingInfo_joint_charge
#print axioms Nightfall.Route1WynerOneStep.remainingInfo_nonneg
