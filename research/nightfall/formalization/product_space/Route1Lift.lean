import Route1KeyLemma

/-!
# Route 1: the lifted product space

The mixture `∑ π_θ P_θ` is realised as a *product* law on `Option ι → Θ ⊕ Seed`: coordinate `none`
carries the latent label `θ ∼ π`, coordinate `some j` carries a seed `v ∼ κ_j`. The lifted function
`latentLift g h` (`h θ j v = v.2 θ`) has the law of `g` under the mixture. This file computes, for
the lifted law, the mean, the variance, the influence of the label coordinate (bounded by twice the
Key Lemma quantity) and the influence of seed coordinates (the posterior-averaged component
influences). It also constructs the seed coupling from the finite maximal star coupling.
-/

namespace Nightfall.Route1Polylog

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.Route1LatentDegree

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

/-! ## Seed coupling from the finite maximal star -/

theorem seed_coupling_exists (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1) (q : ι → α → ℝ) (hq0 : ∀ j a, 0 ≤ q j a)
    (hq1 : ∀ j, ∑ a, q j a = 1) : ∃ κ : ι → Seed α Θ → ℝ, SeedCoupling P q κ := by
  classical
  have hK := fun j => Nightfall.Route1StarMaximalBridge.finite_star_maximal_exists (q j)
    (fun θ => P θ j) (hq0 j) (fun θ a => hP0 θ j a) (hq1 j) (fun θ => hP1 θ j)
  choose K hK0 _hK1 href hcomp hmis using hK
  refine ⟨fun j v => Nightfall.Route1StarCoupling.starMass (q j) (K j) v.1 v.2, ?_, ?_, ?_, ?_⟩
  · intro j v
    unfold Nightfall.Route1StarCoupling.starMass Nightfall.Route1StarCoupling.conditionalStarMass
    exact mul_nonneg (hq0 j _) (Finset.prod_nonneg fun θ _ => hK0 j θ _ _)
  · intro j
    rw [Fintype.sum_prod_type]
    simp only [href j]
    exact hq1 j
  · intro j θ b
    rw [Finset.sum_filter, Fintype.sum_prod_type]
    exact hcomp j θ b
  · intro j θ
    rw [Finset.sum_filter, Fintype.sum_prod_type]
    have hm := hmis j θ
    have heq : ∑ a, ∑ bs : Θ → α, (if bs θ ≠ a then
        Nightfall.Route1StarCoupling.starMass (q j) (K j) a bs else 0) =
        ∑ a : α, ∑ bs : Θ → α, (if bs θ = a then 0 else
        Nightfall.Route1StarCoupling.starMass (q j) (K j) a bs) :=
      Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun bs _ => by
        by_cases h : bs θ = a <;> simp [h]
    simp only at heq ⊢
    rw [heq, hm]
    unfold Nightfall.Route1FiniteMaxCoupling.mismatchMass
      Nightfall.Route1FiniteMaxCoupling.leftResidual Nightfall.Route1FiniteMaxCoupling.overlap tvd
    rw [Finset.sum_sub_distrib, hq1 j]
    exact le_of_eq (by congr 1; exact Finset.sum_congr rfl fun a _ => min_comm _ _)

/-! ## The lifted law -/

/-- Law of the lifted coordinates. -/
noncomputable def liftLaw (π : Θ → ℝ) (κ : ι → Seed α Θ → ℝ) :
    Option ι → Θ ⊕ Seed α Θ → ℝ
  | none => Sum.elim π (fun _ => 0)
  | some j => Sum.elim (fun _ => 0) (κ j)

/-- Embedding of a label and a seed configuration. -/
def liftz (θ : Θ) (u : ι → Seed α Θ) : Option ι → Θ ⊕ Seed α Θ
  | none => Sum.inl θ
  | some j => Sum.inr (u j)

/-- The component decoder. -/
def dec : Θ → ι → Seed α Θ → α := fun θ _ v => v.2 θ

theorem liftz_injective : Function.Injective (fun p : Θ × (ι → Seed α Θ) => liftz p.1 p.2) := by
  intro p p' h
  have h0 := congrFun h none
  simp only [liftz, Sum.inl.injEq] at h0
  have h1 : p.2 = p'.2 := funext fun j => by
    have := congrFun h (some j); simpa [liftz] using this
  exact Prod.ext h0 h1

theorem latentLift_liftz (F : (ι → α) → ℝ) (θ : Θ) (u : ι → Seed α Θ) :
    latentLift F dec (liftz θ u) = F (compOf θ u) := by
  rfl

theorem prodMass_liftz (π : Θ → ℝ) (κ : ι → Seed α Θ → ℝ) (θ : Θ) (u : ι → Seed α Θ) :
    prodMass (liftLaw π κ) (liftz θ u) = π θ * seedMass κ u := by
  unfold prodMass seedMass
  rw [Fintype.prod_option]
  rfl

theorem prodMass_off_range (π : Θ → ℝ) (κ : ι → Seed α Θ → ℝ) (z : Option ι → Θ ⊕ Seed α Θ)
    (hz : z ∉ Set.range (fun p : Θ × (ι → Seed α Θ) => liftz p.1 p.2)) :
    prodMass (liftLaw π κ) z = 0 := by
  classical
  unfold prodMass
  rw [Fintype.prod_option]
  rcases hzn : z none with θ | v
  · have : ∃ j, ∃ θ', z (some j) = Sum.inl θ' := by
      by_contra hno
      push_neg at hno
      apply hz
      have hr : ∀ j, ∃ v, z (some j) = Sum.inr v := by
        intro j
        rcases h : z (some j) with θ' | v
        · exact absurd h (hno j θ')
        · exact ⟨v, rfl⟩
      choose u hu using hr
      refine ⟨(θ, u), funext fun o => ?_⟩
      cases o with
      | none => simp [liftz, hzn]
      | some j => simp [liftz, hu j]
    obtain ⟨j, θ', hj⟩ := this
    refine mul_eq_zero_of_right _ (Finset.prod_eq_zero (Finset.mem_univ j) ?_)
    simp [liftLaw, hj]
  · simp [liftLaw, hzn]

/-- Sums over the lifted space reduce to label × seed sums. -/
theorem lift_sum (π : Θ → ℝ) (κ : ι → Seed α Θ → ℝ) (F : (Option ι → Θ ⊕ Seed α Θ) → ℝ) :
    ∑ z, prodMass (liftLaw π κ) z * F z =
      ∑ θ, π θ * ∑ u, seedMass κ u * F (liftz θ u) := by
  rw [← Fintype.sum_of_injective (fun p : Θ × (ι → Seed α Θ) => liftz p.1 p.2) liftz_injective
    (fun p => prodMass (liftLaw π κ) (liftz p.1 p.2) * F (liftz p.1 p.2))
    (fun z => prodMass (liftLaw π κ) z * F z)
    (fun z hz => by rw [prodMass_off_range π κ z hz, zero_mul]) (fun _ => rfl)]
  rw [Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun θ _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun u _ => by rw [prodMass_liftz]; ring

variable (P : Θ → ι → α → ℝ)

theorem liftLaw_nonneg (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ) (κ : ι → Seed α Θ → ℝ)
    (hκ0 : ∀ j v, 0 ≤ κ j v) : ∀ o t, 0 ≤ liftLaw π κ o t := by
  intro o t
  cases o with
  | none => cases t with
    | inl θ => exact hπ0 θ
    | inr _ => exact le_refl 0
  | some j => cases t with
    | inl _ => exact le_refl 0
    | inr v => exact hκ0 j v

theorem liftLaw_sum (π : Θ → ℝ) (hπ1 : ∑ θ, π θ = 1) (κ : ι → Seed α Θ → ℝ)
    (hκ1 : ∀ j, ∑ v, κ j v = 1) : ∀ o, ∑ t, liftLaw π κ o t = 1 := by
  intro o
  rw [Fintype.sum_sum_type]
  cases o with
  | none => simp [liftLaw, hπ1]
  | some j => simp [liftLaw, hκ1 j]

/-- Lifted mean. -/
theorem pexp_lift (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (F : (ι → α) → ℝ) :
    pexp (liftLaw π κ) (latentLift F dec) = ∑ θ, π θ * pexp (P θ) F := by
  unfold pexp
  rw [lift_sum π κ]
  refine Finset.sum_congr rfl fun θ _ => ?_
  simp only [latentLift_liftz]
  rw [seed_comp_pexp P q κ hκ θ F]
  rfl

/-- Lifted variance. -/
theorem pvar_lift (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (g : (ι → α) → ℝ) :
    pvar (liftLaw π κ) (latentLift g dec) =
      ∑ θ, π θ * pexp (P θ) (fun x => (g x - ∑ θ', π θ' * pexp (P θ') g) ^ 2) := by
  unfold pvar
  rw [pexp_lift P q κ hκ π g]
  have := pexp_lift P q κ hκ π (fun x => (g x - ∑ θ', π θ' * pexp (P θ') g) ^ 2)
  rw [← this]
  rfl

/-- Influence of a seed coordinate: the posterior average of component influences. -/
theorem pinfl_lift_seed (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) :
    pinfl (liftLaw π κ) (latentLift g dec) (some j) = ∑ θ, π θ * pinfl (P θ) g j := by
  classical
  unfold pinfl
  have hΦ : ∀ z, ∑ t, prodMass (liftLaw π κ) z * liftLaw π κ (some j) t *
      ((latentLift g dec z - latentLift g dec (Function.update z (some j) t)) ^ 2 / 2) =
      prodMass (liftLaw π κ) z * ∑ t, liftLaw π κ (some j) t *
      ((latentLift g dec z - latentLift g dec (Function.update z (some j) t)) ^ 2 / 2) := by
    intro z; rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun t _ => by ring
  simp only [hΦ]
  rw [lift_sum π κ]
  refine Finset.sum_congr rfl fun θ _ => ?_
  congr 1
  -- inner function of `compOf θ u`
  let Ψ : (ι → α) → ℝ := fun x => ∑ b, P θ j b * ((g x - g (Function.update x j b)) ^ 2 / 2)
  have hinner : ∀ u : ι → Seed α Θ, ∑ t, liftLaw π κ (some j) t *
      ((latentLift g dec (liftz θ u) - latentLift g dec (Function.update (liftz θ u) (some j) t)) ^ 2
        / 2) = Ψ (compOf θ u) := by
    intro u
    rw [Fintype.sum_sum_type]
    simp only [liftLaw, Sum.elim_inl, zero_mul, Finset.sum_const_zero, Sum.elim_inr, zero_add]
    have hupd : ∀ v : Seed α Θ, Function.update (liftz θ u) (some j) (Sum.inr v) =
        liftz θ (Function.update u j v) := by
      intro v; funext o
      cases o with
      | none => simp [liftz]
      | some i =>
        by_cases hij : i = j
        · subst hij; simp [liftz]
        · simp [liftz, Function.update_of_ne hij,
            Function.update_of_ne (show some i ≠ some j from fun h => hij (Option.some_inj.mp h))]
    have hcomp : ∀ v : Seed α Θ, compOf θ (Function.update u j v) =
        Function.update (compOf θ u) j (v.2 θ) := by
      intro v; funext i
      by_cases hij : i = j
      · subst hij; simp [compOf]
      · simp [compOf, Function.update_of_ne hij]
    simp only [hupd, latentLift_liftz, hcomp]
    -- group seeds by their `θ` letter
    simp only [Ψ]
    rw [← Finset.sum_fiberwise univ (fun v : Seed α Θ => v.2 θ)]
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [← hκ.comp j θ b, Finset.sum_mul]
    refine Finset.sum_congr rfl fun v hv => ?_
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
    rw [hv]
  simp only [hinner]
  rw [seed_comp_pexp P q κ hκ θ Ψ]
  unfold pexp
  refine Finset.sum_congr rfl fun x _ => ?_
  simp only [Ψ]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun b _ => by ring

/-- Influence of the label coordinate is at most twice the Key Lemma quantity. -/
theorem pinfl_lift_label (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ) (hκ : SeedCoupling P q κ)
    (π : Θ → ℝ) (hπ0 : ∀ θ, 0 ≤ π θ) (hπ1 : ∑ θ, π θ = 1) (g : (ι → α) → ℝ) :
    pinfl (liftLaw π κ) (latentLift g dec) none ≤
      2 * ∑ θ, π θ * ∑ u, seedMass κ u * (g (refOf u) - g (compOf θ u)) ^ 2 := by
  classical
  unfold pinfl
  have hΦ : ∀ z, ∑ t, prodMass (liftLaw π κ) z * liftLaw π κ none t *
      ((latentLift g dec z - latentLift g dec (Function.update z none t)) ^ 2 / 2) =
      prodMass (liftLaw π κ) z * ∑ t, liftLaw π κ none t *
      ((latentLift g dec z - latentLift g dec (Function.update z none t)) ^ 2 / 2) := by
    intro z; rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun t _ => by ring
  simp only [hΦ]
  rw [lift_sum π κ]
  have hupd : ∀ θ θ' (u : ι → Seed α Θ), Function.update (liftz θ u) none (Sum.inl θ') =
      liftz θ' u := by
    intro θ θ' u; funext o
    cases o with
    | none => simp [liftz]
    | some i => simp [liftz]
  have hinner : ∀ θ (u : ι → Seed α Θ), ∑ t, liftLaw π κ none t *
      ((latentLift g dec (liftz θ u) - latentLift g dec (Function.update (liftz θ u) none t)) ^ 2
        / 2) = ∑ θ', π θ' * ((g (compOf θ u) - g (compOf θ' u)) ^ 2 / 2) := by
    intro θ u
    rw [Fintype.sum_sum_type]
    simp only [liftLaw, Sum.elim_inl, Sum.elim_inr, zero_mul, Finset.sum_const_zero, add_zero,
      hupd, latentLift_liftz]
  simp only [hinner]
  have hm0 := seedMass_nonneg κ hκ.nonneg
  have hpt : ∀ θ u, ∑ θ', π θ' * ((g (compOf θ u) - g (compOf θ' u)) ^ 2 / 2) ≤
      (g (refOf u) - g (compOf θ u)) ^ 2 + ∑ θ', π θ' * (g (refOf u) - g (compOf θ' u)) ^ 2 := by
    intro θ u
    have : ∀ θ', π θ' * ((g (compOf θ u) - g (compOf θ' u)) ^ 2 / 2) ≤
        π θ' * ((g (refOf u) - g (compOf θ u)) ^ 2 + (g (refOf u) - g (compOf θ' u)) ^ 2) :=
      fun θ' => mul_le_mul_of_nonneg_left (by
        nlinarith [sq_nonneg (2 * g (refOf u) - g (compOf θ u) - g (compOf θ' u))]) (hπ0 θ')
    refine (Finset.sum_le_sum fun θ' _ => this θ').trans (le_of_eq ?_)
    rw [Finset.sum_congr rfl fun θ' _ => mul_add (π θ') _ _, Finset.sum_add_distrib,
      ← Finset.sum_mul, hπ1, one_mul]
  calc ∑ θ, π θ * ∑ u, seedMass κ u * ∑ θ', π θ' * ((g (compOf θ u) - g (compOf θ' u)) ^ 2 / 2)
      ≤ ∑ θ, π θ * ∑ u, seedMass κ u * ((g (refOf u) - g (compOf θ u)) ^ 2 +
          ∑ θ', π θ' * (g (refOf u) - g (compOf θ' u)) ^ 2) :=
        Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun u _ =>
          mul_le_mul_of_nonneg_left (hpt θ u) (hm0 u)) (hπ0 θ)
    _ = 2 * ∑ θ, π θ * ∑ u, seedMass κ u * (g (refOf u) - g (compOf θ u)) ^ 2 := by
        set a : Θ → (ι → Seed α Θ) → ℝ := fun θ u => (g (refOf u) - g (compOf θ u)) ^ 2 with ha
        have e1 : ∀ θ, π θ * ∑ u, seedMass κ u * (a θ u + ∑ θ', π θ' * a θ' u) =
            π θ * ∑ u, seedMass κ u * a θ u + π θ * ∑ u, seedMass κ u * ∑ θ', π θ' * a θ' u := by
          intro θ; rw [← mul_add, ← Finset.sum_add_distrib]
          congr 1; exact Finset.sum_congr rfl fun u _ => by ring
        have e2 : ∑ θ, π θ * ∑ u, seedMass κ u * ∑ θ', π θ' * a θ' u =
            ∑ θ', π θ' * ∑ u, seedMass κ u * a θ' u := by
          rw [← Finset.sum_mul, hπ1, one_mul]
          simp only [Finset.mul_sum]
          rw [Finset.sum_comm]
          exact Finset.sum_congr rfl fun θ' _ => Finset.sum_congr rfl fun u _ => by ring
        rw [Finset.sum_congr rfl fun θ _ => e1 θ, Finset.sum_add_distrib, e2]
        ring

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.seed_coupling_exists
#print axioms Nightfall.Route1Polylog.lift_sum
#print axioms Nightfall.Route1Polylog.pinfl_lift_seed
#print axioms Nightfall.Route1Polylog.pinfl_lift_label
#print axioms Nightfall.Route1Polylog.key_lemma
