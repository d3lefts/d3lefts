import QueryLocalFactorTransfer

/-!
# NIGHTFALL — support-local and TV-robust form of query-local factor Theorem 2

This strengthens the exact factor transfer to the paper's stated decoder
assumption: Z_j needs to be recoverable from X=Phi(Z) only for latent Z
with positive source probability. A sum-over-atoms argument discards
zero-mass latent inputs without assuming any uniform atom lower bound.

The observed law is explicitly the pushforward of the latent mixture.
For a target law within positive total variation eta of that pushforward,
the same observed tree incurs at most +eta additional event error.

The TV event lemma is the elementary argument also used in PR #880
(ApproximateMixtureSimulation), not a novelty claim.
-/

namespace Nightfall.ProductSpace.QueryLocalSource

open Finset
open Nightfall.ProductSpace
open Nightfall.ProductSpace.QueryLocalDegree
open Nightfall.ProductSpace.QueryDecoderLift
open Nightfall.ProductSpace.QueryLocalFactor

variable {I J α β Θ : Type}
  [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype α] [DecidableEq α]
  [Fintype β] [DecidableEq β] [Nonempty β]
  [Fintype Θ] [Nonempty Θ]

/-- Explicit latent mixture probability at a particular latent input. -/
noncomputable def latentMass (P : Θ → J → β → ℝ) (w : Θ → ℝ)
    (z : J → β) : ℝ :=
  ∑ θ, w θ * Transfer.prodMass (P θ) z

theorem latentMass_nonneg (P : Θ → J → β → ℝ)
    (hP0 : ∀ θ j v, 0 ≤ P θ j v)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (z : J → β) : 0 ≤ latentMass P w z := by
  unfold latentMass
  apply Finset.sum_nonneg
  intro θ _
  exact mul_nonneg (hw0 θ)
    (Transfer.prodMass_nonneg' (P θ) (hP0 θ) z)

/-- The certified Jensen mixture expectation is expectation under the
pointwise mixture mass; makes source support exact and checkable. -/
theorem ex_eq_mass (P : Θ → J → β → ℝ) (w : Θ → ℝ)
    (F : (J → β) → ℝ) :
    Mixture.Ex P w F = ∑ z, latentMass P w z * F z := by
  calc
    Mixture.Ex P w F =
        ∑ θ, ∑ z, w θ * (Transfer.prodMass (P θ) z * F z) := by
          unfold Mixture.Ex Transfer.pexp
          apply Finset.sum_congr rfl
          intro θ _
          rw [Finset.mul_sum]
    _ = ∑ z, ∑ θ, w θ * (Transfer.prodMass (P θ) z * F z) :=
      Finset.sum_comm
    _ = ∑ z, (∑ θ, w θ * Transfer.prodMass (P θ) z) * F z := by
      apply Finset.sum_congr rfl
      intro z _
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro θ _
      ring
    _ = ∑ z, latentMass P w z * F z := rfl

/-- Pushforward of the latent mixture by the local encoding. -/
noncomputable def observedMass
    (P : Θ → J → β → ℝ) (w : Θ → ℝ)
    (Phi : (J → β) → (I → α)) (x : I → α) : ℝ :=
  ∑ z : J → β, if Phi z = x then latentMass P w z else 0

/-- The finite pushforward change-of-variables identity, without
injectivity or full-support assumptions. -/
theorem pushExpectation
    (P : Θ → J → β → ℝ) (w : Θ → ℝ)
    (Phi : (J → β) → (I → α))
    (H : (I → α) → ℝ) :
    (∑ x, observedMass P w Phi x * H x) =
      Mixture.Ex P w (fun z => H (Phi z)) := by
  rw [ex_eq_mass]
  unfold observedMass
  calc
    (∑ x : I → α, (∑ z : J → β,
        if Phi z = x then latentMass P w z else 0) * H x) =
      ∑ x : I → α, ∑ z : J → β,
        (if Phi z = x then latentMass P w z else 0) * H x := by
        apply Finset.sum_congr rfl
        intro x _
        rw [Finset.sum_mul]
    _ = ∑ z : J → β, ∑ x : I → α,
        (if Phi z = x then latentMass P w z else 0) * H x :=
      Finset.sum_comm
    _ = ∑ z : J → β, latentMass P w z * H (Phi z) := by
      apply Finset.sum_congr rfl
      intro z _
      simp [ite_mul]

/-- A source-supported decoder is required to recover Z_j only at atoms
that can occur with positive probability. -/
def SourceDecoder
    (P : Θ → J → β → ℝ) (w : Θ → ℝ)
    (Phi : (J → β) → (I → α))
    (dec : J → DecoderTree I α β) : Prop :=
  ∀ z, 0 < latentMass P w z →
    ∀ j, (dec j).eval (Phi z) = z j

/-- **Full exact-source structural Theorem 2.** No pointwise decoding
requirement on zero-mass inputs, and one depth-bounded observed tree on
the *entire* observed alphabet (not only on encoded observations).
The error is measured under the explicit pushforward source. -/
theorem factor_mixture_simulation_support
    (P : Θ → J → β → ℝ)
    (hP0 : ∀ θ j v, 0 ≤ P θ j v)
    (hP1 : ∀ θ j, ∑ v, P θ j v = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ)
    (hPhi : LocalEncoding Phi deps b)
    (dec : J → DecoderTree I α β)
    (r : ℕ)
    (hdec : SourceDecoder P w Phi dec)
    (hcost : ∀ j x, (dec j).queries x ≤ r)
    (f : (I → α) → ℝ)
    (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : RowBound.HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree I α,
      (∀ x, t.queries x ≤ r * n) ∧
      (∑ x : I → α, observedMass P w Phi x *
        (if ε < |f x - t.eval x| then (1 : ℝ) else 0)) ≤
        jensenError (max 1 (b * d)) (Fintype.card Θ) n τ ε := by
  classical
  let g : (J → β) → ℝ := fun z => f (Phi z)
  let D := max 1 (b * d)
  have hD : 1 ≤ D := Nat.le_max_left 1 (b * d)
  let θ₀ : Θ := Classical.choice inferInstance
  have h0 : RowBound.HasProdDegreeLE g (b * d) :=
    degree_pullback (P θ₀) (hP1 θ₀) Phi deps b hPhi f d hd
  have hdegree : RowBound.HasProdDegreeLE g D := by
    obtain ⟨a, ha, hrep⟩ := h0
    refine ⟨a, ?_, hrep⟩
    intro S hS ζ
    exact ha S (lt_of_le_of_lt (Nat.le_max_right 1 (b * d)) hS) ζ
  have hg01 : ∀ z, 0 ≤ g z ∧ g z ≤ 1 := fun z => hf01 (Phi z)
  obtain ⟨u, hu, herr⟩ :=
    Mixture.mixture_simulation_jensen P hP0 hP1
      w hw0 hw1 g hg01 D hD hdegree τ hτ hτ2 ε hε n hn
  let t := substitute dec r n u
  refine ⟨t, fun x => substitute_queries dec r n u x, ?_⟩
  rw [pushExpectation P w Phi]
  rw [ex_eq_mass P w]
  rw [ex_eq_mass P w] at herr
  have hterm (z : J → β) :
      latentMass P w z *
        (if ε < |f (Phi z) - t.eval (Phi z)| then (1 : ℝ) else 0) =
      latentMass P w z *
        (if ε < |g z - u.eval z| then (1 : ℝ) else 0) := by
    rcases (latentMass_nonneg P hP0 w hw0 z).eq_or_lt with hz | hp
    · simp [hz.symm]
    · have heval := substitute_eval_at dec Phi r hcost n u z
        (hu z) (hdec z hp)
      change latentMass P w z *
          (if ε < |f (Phi z) -
              (substitute dec r n u).eval (Phi z)| then (1 : ℝ) else 0) =
        latentMass P w z *
          (if ε < |f (Phi z) - u.eval z| then (1 : ℝ) else 0)
      rw [heval]
  change (∑ z, latentMass P w z *
      (if ε < |f (Phi z) - t.eval (Phi z)| then (1 : ℝ) else 0)) ≤
    (3 * Real.sqrt 2 * Real.pi ^ 6 * (D : ℝ) ^ 6 * Fintype.card Θ /
       (τ * Real.sqrt τ) +
     512 * (D : ℝ) ^ 4 * (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n +
     τ / ε ^ 2
  calc
    _ = ∑ z, latentMass P w z *
        (if ε < |g z - u.eval z| then (1 : ℝ) else 0) :=
      Finset.sum_congr rfl fun z _ => hterm z
    _ ≤ _ := herr

/-- Finite positive variation. For normalized probability laws it is
identical to half their ℓ¹ distance, i.e. total variation. -/
noncomputable def tvPositive {Ω : Type} [Fintype Ω]
    (q p : Ω → ℝ) : ℝ := ∑ x : Ω, max (q x - p x) 0

/-- Elementary event-transfer inequality; also used in PR #880. -/
theorem tv_event_transfer {Ω : Type} [Fintype Ω]
    (q p : Ω → ℝ) (η : ℝ)
    (hTV : tvPositive q p ≤ η)
    (E : Ω → Prop) [DecidablePred E] :
    (∑ x : Ω, q x * (if E x then (1 : ℝ) else 0)) ≤
      (∑ x : Ω, p x * (if E x then (1 : ℝ) else 0)) + η := by
  have hpt (x : Ω) :
      (q x - p x) * (if E x then (1 : ℝ) else 0) ≤ max (q x - p x) 0 := by
    by_cases h : E x
    · simp only [if_pos h, mul_one]
      exact le_max_left _ _
    · simp only [if_neg h, mul_zero]
      exact le_max_right _ _
  have hsum := Finset.sum_le_sum (s := (Finset.univ : Finset Ω))
    fun x _ => hpt x
  have heq :
      (∑ x : Ω, (q x - p x) *
          (if E x then (1 : ℝ) else 0)) =
        (∑ x : Ω, q x * (if E x then (1 : ℝ) else 0)) -
        (∑ x : Ω, p x * (if E x then (1 : ℝ) else 0)) := by
    simp_rw [sub_mul]
    rw [Finset.sum_sub_distrib]
  rw [heq] at hsum
  unfold tvPositive at hTV
  linarith

/-- **Robust Theorem 2.** The same observed classical simulator achieves
additive +eta error when a (possibly dependent) target law is within
positive total variation eta of the query-local pushforward mixture. -/
theorem factor_mixture_simulation_tv
    (P : Θ → J → β → ℝ)
    (hP0 : ∀ θ j v, 0 ≤ P θ j v)
    (hP1 : ∀ θ j, ∑ v, P θ j v = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ)
    (hPhi : LocalEncoding Phi deps b)
    (dec : J → DecoderTree I α β)
    (r : ℕ)
    (hdec : SourceDecoder P w Phi dec)
    (hcost : ∀ j x, (dec j).queries x ≤ r)
    (f : (I → α) → ℝ)
    (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : RowBound.HasProdDegreeLE f d)
    (q : (I → α) → ℝ)
    (η : ℝ)
    (hTV : tvPositive q (observedMass P w Phi) ≤ η)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree I α,
      (∀ x, t.queries x ≤ r * n) ∧
      (∑ x : I → α, q x *
        (if ε < |f x - t.eval x| then (1 : ℝ) else 0)) ≤
        jensenError (max 1 (b * d)) (Fintype.card Θ) n τ ε + η := by
  classical
  obtain ⟨t, ht, herr⟩ :=
    factor_mixture_simulation_support P hP0 hP1 w hw0 hw1
      Phi deps b hPhi dec r hdec hcost f hf01 d hd
      τ hτ hτ2 ε hε n hn
  refine ⟨t, ht, ?_⟩
  exact (tv_event_transfer q (observedMass P w Phi) η hTV
      (fun x => ε < |f x - t.eval x|)).trans
    (add_le_add_right herr η)

end Nightfall.ProductSpace.QueryLocalSource
