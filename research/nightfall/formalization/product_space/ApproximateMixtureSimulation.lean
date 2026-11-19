import MixtureSimulation

/-!
# NIGHTFALL: total-variation stability of the Jensen mixture simulator

The target law q need not itself be an exact mixture. If it is within
total variation η of an M-component product mixture, any event's probability
increases by at most η, so the same deterministic decision tree works
under q with failure bound δ+η.

The finite TV metric is represented as the sum of positive parts of q-r.
A named lemma checks its equality to (1/2) times the usual ℓ¹ distance for
laws with the same total mass. All finite atoms may have probability zero.
-/

namespace Nightfall.ProductSpace.ApproximateMixture

open Finset
open Nightfall.ProductSpace

variable {ι α Θ : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
  [Fintype Θ]

/-- The explicit mass function of a weighted finite mixture of product laws. -/
noncomputable def mixMass (P : Θ → ι → α → ℝ) (w : Θ → ℝ) (x : ι → α) : ℝ :=
  ∑ θ : Θ, w θ * Transfer.prodMass (P θ) x

theorem mixMass_nonneg (P : Θ → ι → α → ℝ) (w : Θ → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hw0 : ∀ θ, 0 ≤ w θ) (x : ι → α) :
    0 ≤ mixMass P w x := by
  unfold mixMass
  exact Finset.sum_nonneg fun θ _ =>
    mul_nonneg (hw0 θ) (Influence.prodMass_nonneg' (P θ) (hP0 θ) x)

theorem mixMass_sum_one (P : Θ → ι → α → ℝ) (w : Θ → ℝ)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1) (hw1 : ∑ θ, w θ = 1) :
    ∑ x : ι → α, mixMass P w x = 1 := by
  unfold mixMass
  rw [Finset.sum_comm]
  calc
    (∑ θ : Θ, ∑ x : ι → α, w θ * Transfer.prodMass (P θ) x) =
      ∑ θ : Θ, w θ * ∑ x : ι → α, Transfer.prodMass (P θ) x := by
        exact Finset.sum_congr rfl fun θ _ => (Finset.mul_sum).symm
    _ = ∑ θ : Θ, w θ := by
      simp_rw [Influence.sum_prodMass (p := P _) (hP1 _)]
      simp
    _ = 1 := hw1

/-- Unnormalized mixture expectation equals its explicit mass-table integral. -/
theorem Ex_eq_mass_sum (P : Θ → ι → α → ℝ) (w : Θ → ℝ)
    (F : (ι → α) → ℝ) :
    Mixture.Ex P w F =
      ∑ x : ι → α, mixMass P w x * F x := by
  unfold Mixture.Ex Transfer.pexp mixMass
  calc
    (∑ θ : Θ, w θ * ∑ x : ι → α, Transfer.prodMass (P θ) x * F x) =
      ∑ θ : Θ, ∑ x : ι → α, w θ * (Transfer.prodMass (P θ) x * F x) := by
        exact Finset.sum_congr rfl fun θ _ => Finset.mul_sum _ _ _
    _ = ∑ x : ι → α, ∑ θ : Θ, w θ * (Transfer.prodMass (P θ) x * F x) :=
      Finset.sum_comm
    _ = ∑ x : ι → α, (∑ θ : Θ, w θ * Transfer.prodMass (P θ) x) * F x := by
      exact Finset.sum_congr rfl fun x _ => by
        rw [Finset.sum_mul]
        exact Finset.sum_congr rfl fun θ _ => by ring

/-- The positive-variation formula for finite total-variation distance. -/
noncomputable def tvPositive {Ω : Type} [Fintype Ω]
    (q r : Ω → ℝ) : ℝ := ∑ x : Ω, max (q x - r x) 0

/-- For equally normalized finite laws, positive variation equals half ℓ¹. -/
theorem two_tvPositive_eq_l1 {Ω : Type} [Fintype Ω]
    (q r : Ω → ℝ) (hsum : (∑ x, q x) = ∑ x, r x) :
    2 * tvPositive q r = ∑ x : Ω, |q x - r x| := by
  have hzero : (∑ x : Ω, (q x - r x)) = 0 := by
    rw [Finset.sum_sub_distrib, hsum]
    ring
  have hpoint (x : Ω) :
      2 * max (q x - r x) 0 = |q x - r x| + (q x - r x) := by
    by_cases h : 0 ≤ q x - r x
    · rw [max_eq_left h, abs_of_nonneg h]
      ring
    · have h' : q x - r x ≤ 0 := le_of_not_ge h
      rw [max_eq_right h', abs_of_nonpos h']
      ring
  calc
    2 * tvPositive q r = ∑ x : Ω, 2 * max (q x - r x) 0 := by
      unfold tvPositive
      rw [Finset.mul_sum]
    _ = ∑ x : Ω, (|q x - r x| + (q x - r x)) :=
      Finset.sum_congr rfl fun x _ => hpoint x
    _ = ∑ x : Ω, |q x - r x| := by
      rw [Finset.sum_add_distrib, hzero]
      ring

/-- An event can gain at most positive total variation, including zero atoms. -/
theorem tv_event_transfer {Ω : Type} [Fintype Ω]
    (q r : Ω → ℝ) (η : ℝ)
    (hTV : tvPositive q r ≤ η)
    (E : Ω → Prop) [DecidablePred E] :
    (∑ x : Ω, q x * (if E x then (1 : ℝ) else 0)) ≤
      (∑ x : Ω, r x * (if E x then (1 : ℝ) else 0)) + η := by
  have hpt (x : Ω) :
      (q x - r x) * (if E x then (1 : ℝ) else 0) ≤ max (q x - r x) 0 := by
    by_cases h : E x
    · simp only [if_pos h, mul_one]
      exact le_max_left _ _
    · simp only [if_neg h, mul_zero]
      exact le_max_right _ _
  have hsum := Finset.sum_le_sum (s := (Finset.univ : Finset Ω)) fun x _ => hpt x
  have heq :
      (∑ x : Ω, (q x - r x) * (if E x then (1 : ℝ) else 0)) =
        (∑ x : Ω, q x * (if E x then (1 : ℝ) else 0)) -
        (∑ x : Ω, r x * (if E x then (1 : ℝ) else 0)) := by
    simp_rw [sub_mul]
    rw [Finset.sum_sub_distrib]
  rw [heq] at hsum
  unfold tvPositive at hTV
  linarith

/-- **Finite TV-stable mixture simulation.** The target law q can have arbitrary
dependence. A certificate of TV(q, mixture)≤η transfers the existing
worst-case-depth Jensen tree, with additive η failure probability. -/
theorem approximate_mixture_simulation_jensen [Nonempty α]
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (q : (ι → α) → ℝ)
    (hq0 : ∀ x, 0 ≤ q x)
    (hq1 : ∑ x, q x = 1)
    (η : ℝ) (hη : 0 ≤ η)
    (hTV : tvPositive q (mixMass P w) ≤ η)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d)
    (hdeg : RowBound.HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      (∑ x : ι → α, q x *
        (if ε < |f x - t.eval x| then (1 : ℝ) else 0)) ≤
      (3 * Real.sqrt 2 * Real.pi ^ 6 * (d : ℝ) ^ 6 *
          Fintype.card Θ / (τ * Real.sqrt τ) +
        512 * (d : ℝ) ^ 4 *
          (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n + τ / ε ^ 2 + η := by
  classical
  obtain ⟨t, hq, herr⟩ := Mixture.mixture_simulation_jensen P hP0 hP1 w hw0 hw1
    f hf01 d hd hdeg τ hτ hτ2 ε hε n hn
  refine ⟨t, hq, ?_⟩
  have ht := tv_event_transfer q (mixMass P w) η hTV
    (fun x => ε < |f x - t.eval x|)
  rw [← Ex_eq_mass_sum] at ht
  linarith

end Nightfall.ProductSpace.ApproximateMixture

#print axioms Nightfall.ProductSpace.ApproximateMixture.two_tvPositive_eq_l1
#print axioms Nightfall.ProductSpace.ApproximateMixture.tv_event_transfer
#print axioms Nightfall.ProductSpace.ApproximateMixture.approximate_mixture_simulation_jensen
