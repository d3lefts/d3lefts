import AaronsonAmbainis.DetTheorem
import AaronsonAmbainis.TwoSided.Antipodal
import AaronsonAmbainis.Bridge.Positivity

/-!
NIGHTFALL product-space weighted reciprocal transfer.
The external Aaronson--Ambainis formalization is imported at pinned commit
2a6ceaef872ae993708950f951989134084b851a, Lean 4.33.0.

Provenance: David Turturean, arXiv:2611.09773, Theorem 4.3.
The exact product-space conversion is a separate theorem; do not confuse
an exchangeability identity with the sought reciprocal inequality.
-/

namespace Nightfall.ProductSpace.Transfer

open Finset
open AaronsonAmbainis

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

abbrev PairSample (ι α : Type) := (ι → α) × (ι → α)

/-- Coordinatewise exchange of two independent draws under a Boolean mask. -/
def flipPair (mask : ι → Bool) (z : PairSample ι α) : PairSample ι α :=
  (fun i => if mask i then z.2 i else z.1 i,
   fun i => if mask i then z.1 i else z.2 i)

/-- Masked exchange is an involution, including on repeated atoms. -/
theorem flipPair_involutive (mask : ι → Bool) (z : PairSample ι α) :
    flipPair mask (flipPair mask z) = z := by
  apply Prod.ext
  · funext i
    cases h : mask i <;> simp [flipPair, h]
  · funext i
    cases h : mask i <;> simp [flipPair, h]

/-- Equivalence for reindexing two-draw sums. -/
def flipPairEquiv (mask : ι → Bool) : PairSample ι α ≃ PairSample ι α where
  toFun := flipPair mask
  invFun := flipPair mask
  left_inv := flipPair_involutive mask
  right_inv := flipPair_involutive mask

/-- Unnormalized product mass on two independent draws, with heterogeneous
coordinate masses and arbitrary finite alphabets. -/
def pairMass (p : ι → α → ℝ) (z : PairSample ι α) : ℝ :=
  ∏ i, p i (z.1 i) * p i (z.2 i)

theorem pairMass_nonneg (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (z : PairSample ι α) :
    0 ≤ pairMass p z := by
  unfold pairMass
  exact Finset.prod_nonneg (fun i hi =>
    mul_nonneg (hp i (z.1 i)) (hp i (z.2 i)))

/-- Crucial orientation identity: every mask has exactly the same mass. -/
theorem pairMass_flipPair (p : ι → α → ℝ)
    (z : PairSample ι α) (mask : ι → Bool) :
    pairMass p (flipPair mask z) = pairMass p z := by
  unfold pairMass
  apply Finset.prod_congr rfl
  intro i _
  cases h : mask i <;> simp [flipPair, h, mul_comm]

/-- Exact pushforward invariance, without assuming equal or positive atoms. -/
theorem weighted_sum_flipPair (p : ι → α → ℝ)
    (F : PairSample ι α → ℝ) (mask : ι → Bool) :
    (∑ z, pairMass p z * F (flipPair mask z)) =
      ∑ z, pairMass p z * F z := by
  apply Fintype.sum_equiv (flipPairEquiv mask)
  intro z
  simp only [flipPairEquiv, Equiv.coe_fn_mk]
  rw [pairMass_flipPair]

/-- Two-draw averaging preserves every weighted pair functional. -/
theorem weighted_sum_all_orientations (p : ι → α → ℝ)
    (F : PairSample ι α → ℝ) :
    (∑ mask : ι → Bool, ∑ z, pairMass p z * F (flipPair mask z)) =
      (Fintype.card (ι → Bool) : ℝ) * (∑ z, pairMass p z * F z) := by
  simp_rw [weighted_sum_flipPair p F]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]


/-! ## The restricted fractional-certificate row on every oriented cube -/

/-- Coordinates on which two product configurations differ. -/
def disagree (x y : ι → α) : Finset ι :=
  Finset.univ.filter (fun i => x i ≠ y i)

/-- Fractional certificate rows on an arbitrary finite product alphabet. -/
def IsProductRow (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) : Prop :=
  (∀ x j, 0 ≤ lam x j) ∧
    (∀ x y, g y ≠ g x → 1 ≤ ∑ j ∈ disagree x y, lam x j)

/-- The restriction of a product-space Boolean function to the cube
formed by a coordinatewise pair of samples. -/
def cubeG (g : (ι → α) → Bool) (z : PairSample ι α)
    (mask : ι → Bool) : Bool :=
  g ((flipPair mask z).1)

/-- Crucially, repeated atoms are assigned zero restricted-row weight. -/
def cubeLam (lam : (ι → α) → ι → ℝ) (z : PairSample ι α)
    (mask : ι → Bool) (j : ι) : ℝ :=
  if z.1 j = z.2 j then 0 else lam ((flipPair mask z).1) j

theorem cubeLam_nonneg (lam : (ι → α) → ι → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j)
    (z : PairSample ι α) (mask : ι → Bool) (j : ι) :
    0 ≤ cubeLam lam z mask j := by
  by_cases h : z.1 j = z.2 j
  · simp [cubeLam, h]
  · simp [cubeLam, h, hlam]

/-- Every product-space fractional certificate restricts to a bona fide
fractional certificate on the induced Boolean cube, including repeated atoms. -/
theorem cubeLam_isRow (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) (hrow : IsProductRow g lam)
    (z : PairSample ι α) (mask : ι → Bool) :
    IsRow (cubeG g z) mask (cubeLam lam z mask) := by
  constructor
  · exact cubeLam_nonneg lam hrow.1 z mask
  · intro S hflip
    let x : ι → α := (flipPair mask z).1
    let y : ι → α := (flipPair (flipSet mask S) z).1
    change g y ≠ g x at hflip
    have hsub : disagree x y ⊆ S := by
      intro j hj
      by_contra hjS
      have hmask : (flipSet mask S) j = mask j := by
        simp [flipSet, hjS]
      have hs : x j = y j := by
        dsimp [x, y, flipPair]
        rw [hmask]
      exact (Finset.mem_filter.mp hj).2 hs
    have hterm : ∀ j ∈ disagree x y,
        cubeLam lam z mask j = lam x j := by
      intro j hj
      have hneq : z.1 j ≠ z.2 j := by
        intro heq
        have hs : x j = y j := by
          simp [x, y, flipPair, heq]
        exact (Finset.mem_filter.mp hj).2 hs
      simp [cubeLam, hneq, x]
    calc
      (1 : ℝ) ≤ ∑ j ∈ disagree x y, lam x j := hrow.2 x y hflip
      _ = ∑ j ∈ disagree x y, cubeLam lam z mask j := by
        apply Finset.sum_congr rfl
        intro j hj
        exact (hterm j hj).symm
      _ ≤ ∑ j ∈ S, cubeLam lam z mask j :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub
          (fun j _ _ => cubeLam_nonneg lam hrow.1 z mask j)

/-- Complementary orientations exchange the two endpoints. -/
theorem flipPair_antipode_fst (z : PairSample ι α)
    (mask : ι → Bool) :
    (flipPair (antipode mask) z).1 = (flipPair mask z).2 := by
  funext j
  cases h : mask j <;> simp [flipPair, antipode, h]

/-- Exact denominator identity: repeated coordinates have zero cost, and
antipodal restricted rows recover precisely the original pair cost. -/
theorem cubeCost_eq (lam : (ι → α) → ι → ℝ)
    (z : PairSample ι α) (mask : ι → Bool) (w : ι → ℝ) :
    (∑ j, w j * cubeLam lam z mask j *
      cubeLam lam z (antipode mask) j) =
    (∑ j ∈ disagree (flipPair mask z).1 (flipPair mask z).2,
       w j * lam ((flipPair mask z).1) j *
         lam ((flipPair mask z).2) j) := by
  unfold disagree
  rw [Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro j _
  cases hmask : mask j <;>
    by_cases heq : z.1 j = z.2 j <;>
      simp [cubeLam, flipPair, antipode, hmask, heq]

/-- The product-space reciprocal integrand, zero away from crossing pairs. -/
def crossTerm (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) (w : ι → ℝ)
    (z : PairSample ι α) : ℝ :=
  if g z.1 = true ∧ g z.2 = false then
    (∑ j ∈ disagree z.1 z.2, w j * lam z.1 j * lam z.2 j)⁻¹
  else 0

end Nightfall.ProductSpace.Transfer
