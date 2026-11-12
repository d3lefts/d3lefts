import HeterogeneousAlphabets

/-!
# End-to-end finite heterogeneous Efron–Stein influence certificate

This new module leaves the historically pinned product-space sources unchanged.
It states a single genuine degree/variance/influence theorem for actual dependent
input alphabets and zero-mass symbols. The numerical coefficient comes from the
kernel-compiled Turturean-based finite theorem. It does not claim the sharper
analytic Wright constant or arbitrary nonatomic/infinite products.
-/

namespace Nightfall.ProductSpace.Heterogeneous

open Finset
open Nightfall.ProductSpace.Transfer Nightfall.ProductSpace.Influence

variable {ι : Type} [Fintype ι] [DecidableEq ι] {β : ι → Type} [∀ i, Fintype (β i)]
  [∀ i, DecidableEq (β i)]

/-! ## Intrinsic Efron–Stein degree on heterogeneous finite products

The support-lift formulation uses the *actual* Efron–Stein components, not a
separately assumed indicator-monomial witness. We quantify over all positive
support choices; a choice exists since each marginal has total mass one.
The subsequent theorem uses the same input function and distribution for its
degree condition, variance, influences, and bound.
-/

/-- Efron–Stein degree for arbitrary finite coordinate-dependent alphabets,
defined via every support-preserving common-alphabet embedding. -/
def DepESDegreeLE (q : ∀ i, β i → ℝ)
    (F : (∀ i, β i) → ℝ) (d : ℕ) : Prop :=
  ∀ (s0 : ∀ i, β i), (∀ i, 0 < q i (s0 i)) →
    EfronStein.ESDegreeLE (liftMass q)
      (fun x : ι → (Σ k, β k) => F (fun i => proj q s0 i (x i))) d

/-- The established dependent indicator-monomial notion implies the actual
Efron–Stein vanishing condition for every support-preserving embedding. -/
theorem depDegree_implies_depESDegree
    (q : ∀ i, β i → ℝ) (hq1 : ∀ i, ∑ b, q i b = 1)
    (F : (∀ i, β i) → ℝ) (d : ℕ)
    (hd : DepDegreeLE F d) : DepESDegreeLE q F d := by
  intro s0 _
  exact EfronStein.esDegree_of_prodDegree
    (liftMass q) (fun x : ι → (Σ k, β k) => F (fun i => proj q s0 i (x i))) d
    (lift_degree q hq1 s0 F d hd)

/-- **End-to-end finite heterogeneous Efron–Stein influence endpoint.**
All input marginal laws may have zero-mass symbols; no minimum atom mass is
used. The coefficient is the weaker *Lean-compiled* constant, not the sharper
analytic Wright manuscript coefficient. This does not cover nonatomic or
infinite-index products. -/
theorem heterogeneous_es_influence
    (q : ∀ i, β i → ℝ) (hq : ∀ i b, 0 ≤ q i b)
    (hq1 : ∀ i, ∑ b, q i b = 1) (d : ℕ)
    (F : (∀ i, β i) → ℝ)
    (hF : ∀ y : ∀ i, β i, (∀ i, 0 < q i (y i)) → |F y| ≤ 1)
    (hd : DepESDegreeLE q F d) (hV : 0 < dvar q F) :
    ∃ j, 3 * dvar q F ^ 5 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * dinfl q F j ^ 2 := by
  choose s0 hs0 using exists_pos q hq1
  have hdeg : RowBound.HasProdDegreeLE
      (fun x : ι → (Σ k, β k) => F (fun i => proj q s0 i (x i))) d :=
    EfronStein.prodDegree_of_esDegree (liftMass q) (liftMass_sum q hq1)
      (fun x : ι → (Σ k, β k) => F (fun i => proj q s0 i (x i))) d
      (hd s0 hs0)
  obtain ⟨j, hj⟩ := Influence.product_influence (liftMass q)
    (liftMass_nonneg q hq) (liftMass_sum q hq1) d
    (fun x => F (fun i => proj q s0 i (x i)))
    (fun x => hF _ (fun i => proj_pos q s0 hs0 i (x i)))
    hdeg (by rw [pvar_lift q hq s0 F]; exact hV)
  refine ⟨j, ?_⟩
  rw [pvar_lift q hq s0 F, pinfl_lift q hq s0 F j] at hj
  exact hj

end Nightfall.ProductSpace.Heterogeneous
