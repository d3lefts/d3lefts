import Route1Lift

/-!
# NIGHTFALL QW: reference-marginal-preserving finite star coupling

The existing Route 1 SeedCoupling records the component marginals and
mismatch, but its structure does not retain the marginal law of the
common reference letter. Applying product Q2 to that reference would be
unjustified without the missing source equality.

The original finite maximal star theorem already *does* prove that
reference marginal. This module keeps the receipt in a strengthened,
source-exact coupled object. All masses can be zero.

This is a necessary QW construction lemma, not the quadratic Wyner
simulation terminal or a proof of the variance-information crux.
-/

namespace Nightfall.QuadraticWynerReferenceCoupling

open Finset
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ]

/-- Exact marginals for the common reference coordinate in every seed. -/
def HasReferenceMarginal (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) : Prop :=
  ∀ j a, ∑ bs : Θ → α, κ j (a, bs) = q j a

/-- Strong coupling: all old Route 1 properties, plus reference law. -/
structure ExactReferenceSeedCoupling
    (P : Θ → ι → α → ℝ) (q : ι → α → ℝ)
    (κ : ι → Seed α Θ → ℝ) : Prop where
  ordinary : SeedCoupling P q κ
  reference : HasReferenceMarginal q κ

/-- Construct reference-marginal preserving joint seed laws using the
source-verified finite maximal star kernel. No existence assumption on
a coupling kernel is introduced and no weights are bounded away from 0. -/
theorem exact_reference_seed_coupling_exists
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (q : ι → α → ℝ)
    (hq0 : ∀ j a, 0 ≤ q j a)
    (hq1 : ∀ j, ∑ a, q j a = 1) :
    ∃ κ : ι → Seed α Θ → ℝ,
      ExactReferenceSeedCoupling P q κ := by
  classical
  have hK := fun j => Nightfall.Route1StarMaximalBridge.finite_star_maximal_exists
    (q j) (fun θ => P θ j) (hq0 j)
    (fun θ a => hP0 θ j a) (hq1 j) (fun θ => hP1 θ j)
  choose K hK0 _hK1 href hcomp hmis using hK
  let κ : ι → Seed α Θ → ℝ :=
    fun j v => Nightfall.Route1StarCoupling.starMass (q j) (K j) v.1 v.2
  refine ⟨κ, ⟨?_, ?_⟩⟩
  · -- Original Route1 SeedCoupling record, preserving source semantics.
    refine ⟨?_, ?_, ?_, ?_⟩
    · intro j v
      unfold κ Nightfall.Route1StarCoupling.starMass
        Nightfall.Route1StarCoupling.conditionalStarMass
      exact mul_nonneg (hq0 j _) (Finset.prod_nonneg fun θ _ => hK0 j θ _ _)
    · intro j
      rw [Fintype.sum_prod_type]
      simp only [κ, href j]
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
          Nightfall.Route1StarCoupling.starMass (q j) (K j) a bs) := by
        exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun bs _ => by
          by_cases h : bs θ = a <;> simp [h]
      change (∑ a, ∑ bs : Θ → α, if bs θ ≠ a then
        Nightfall.Route1StarCoupling.starMass (q j) (K j) a bs else 0) ≤
        tvd (P θ j) (q j)
      rw [heq, hm]
      unfold Nightfall.Route1FiniteMaxCoupling.mismatchMass
        Nightfall.Route1FiniteMaxCoupling.leftResidual
        Nightfall.Route1FiniteMaxCoupling.overlap tvd
      rw [Finset.sum_sub_distrib, hq1 j]
      exact le_of_eq (by congr 1; exact Finset.sum_congr rfl fun a _ => min_comm _ _)
  · -- Crucial new source evidence: the reference law is exactly q.
    intro j a
    change ∑ bs : Θ → α,
      Nightfall.Route1StarCoupling.starMass (q j) (K j) a bs = q j a
    exact href j a



/-- Reference atoms as an actual marginal of the independent seed table. -/
theorem reference_filtered_mass
    (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ)
    (href : HasReferenceMarginal q κ) (j : ι) (a : α) :
    ∑ v ∈ univ.filter (fun v : Seed α Θ => v.1 = a), κ j v = q j a := by
  classical
  rw [Finset.sum_filter, Fintype.sum_prod_type]
  calc
    (∑ b : α, ∑ bs : Θ → α, if b = a then κ j (b, bs) else 0)
      = ∑ b : α, if b = a then ∑ bs : Θ → α, κ j (b, bs) else 0 := by
          apply Finset.sum_congr rfl
          intro b _
          split_ifs <;> simp
    _ = ∑ bs : Θ → α, κ j (a, bs) := by simp
    _ = q j a := href j a

/-- Applying ANY observable to the reference letters has exactly the
product-of-marginals expectation. No coupling-model approximation. -/
theorem reference_pushforward
    (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ)
    (href : HasReferenceMarginal q κ)
    (F : (ι → α) → ℝ) :
    ∑ u : ι → Seed α Θ, seedMass κ u * F (refOf u) =
      pexp q F := by
  have hpush := sum_push κ (fun (_ : ι) (v : Seed α Θ) => v.1) F
  change (∑ u, seedMass κ u * F (refOf u)) =
    ∑ x, (∏ i, ∑ v ∈ univ.filter
      (fun v : Seed α Θ => v.1 = x i), κ i v) * F x at hpush
  rw [hpush]
  unfold pexp prodMass
  apply Finset.sum_congr rfl
  intro x _
  congr 1
  exact Finset.prod_congr rfl fun i _ => reference_filtered_mass q κ href i (x i)

/-- Original source Q-variance is exactly the reference-seed variance. -/
theorem reference_variance
    (q : ι → α → ℝ) (κ : ι → Seed α Θ → ℝ)
    (href : HasReferenceMarginal q κ)
    (f : (ι → α) → ℝ) :
    ∑ u : ι → Seed α Θ,
      seedMass κ u * (f (refOf u) - pexp q f) ^ 2 =
      pvar q f := by
  simpa only [pvar] using
    reference_pushforward q κ href (fun x => (f x - pexp q f) ^ 2)

#print axioms Nightfall.QuadraticWynerReferenceCoupling.exact_reference_seed_coupling_exists
#print axioms Nightfall.QuadraticWynerReferenceCoupling.reference_filtered_mass
#print axioms Nightfall.QuadraticWynerReferenceCoupling.reference_pushforward
#print axioms Nightfall.QuadraticWynerReferenceCoupling.reference_variance
end Nightfall.QuadraticWynerReferenceCoupling
