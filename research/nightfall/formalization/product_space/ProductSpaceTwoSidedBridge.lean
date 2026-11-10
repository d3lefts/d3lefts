import Mathlib
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
  have hf : (flipPair (antipode mask) z).1 =
      (flipPair mask z).2 := flipPair_antipode_fst z mask
  have hd : ((flipPair mask z).1 j ≠ (flipPair mask z).2 j) ↔
      (z.1 j ≠ z.2 j) := by
    cases hm : mask j <;> simp [flipPair, hm, ne_comm]
  by_cases hz : z.1 j = z.2 j
  · have hEq : (flipPair mask z).1 j = (flipPair mask z).2 j := by
      by_contra hne
      exact (hd.mp hne) hz
    simp [cubeLam, hz, hEq]
  · have hNe : (flipPair mask z).1 j ≠ (flipPair mask z).2 j :=
      hd.mpr hz
    simp [cubeLam, hz, hNe, hf]

/-- The product-space reciprocal integrand, zero away from crossing pairs. -/
noncomputable def crossTerm (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) (w : ι → ℝ)
    (z : PairSample ι α) : ℝ :=
  if g z.1 = true ∧ g z.2 = false then
    (∑ j ∈ disagree z.1 z.2, w j * lam z.1 j * lam z.2 j)⁻¹
  else 0


/-! ## Pinned antipodal inequality on each induced product cube -/

/-- This invokes the fully proved upstream Turturean determinant theorem, not
a new assumption. Product rows restrict to Boolean rows by cubeLam_isRow. -/
theorem pinned_antipodal_on_product_cube
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) (z : PairSample ι α)
    (w : ι → ℝ) (hw : ∀ j, 0 < w j) :
    (∑ mask ∈ zone (cubeG g z),
       (∑ j, w j * cubeLam lam z mask j *
         cubeLam lam z (antipode mask) j)⁻¹) ≤
      ∑ j, (bdry (cubeG g z) j : ℝ) / w j := by
  have hanti : AntipodalInequality := antipodal_of_det detInequality
  exact hanti ι (cubeG g z) w hw (cubeLam lam z)
    (cubeLam_isRow g lam hrow z)

/-- The antipodal reciprocal inequality survives arbitrary nonnegative
heterogeneous masses, with no normalisation or atom-size hypothesis. -/
theorem weighted_antipodal_on_product_cubes
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) (w : ι → ℝ) (hw : ∀ j, 0 < w j) :
    (∑ z, pairMass p z *
      (∑ mask ∈ zone (cubeG g z),
        (∑ j, w j * cubeLam lam z mask j *
          cubeLam lam z (antipode mask) j)⁻¹)) ≤
    ∑ z, pairMass p z * (∑ j, (bdry (cubeG g z) j : ℝ) / w j) := by
  apply Finset.sum_le_sum
  intro z _
  exact mul_le_mul_of_nonneg_left
    (pinned_antipodal_on_product_cube g lam hrow z w hw)
    (pairMass_nonneg p hp z)

/-- Antipodal reciprocal costs are exactly crossing-pair costs after
orienting both samples. This includes repeated atoms. -/
theorem cube_zone_sum_eq_crossTerm
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (w : ι → ℝ) (z : PairSample ι α) :
    (∑ mask ∈ zone (cubeG g z),
      (∑ j, w j * cubeLam lam z mask j *
        cubeLam lam z (antipode mask) j)⁻¹) =
      ∑ mask, crossTerm g lam w (flipPair mask z) := by
  unfold zone
  rw [Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro mask _
  have hcond : (cubeG g z mask = true ∧ cubeG g z (antipode mask) = false) ↔
      (g (flipPair mask z).1 = true ∧ g (flipPair mask z).2 = false) := by
    simp [cubeG, flipPair_antipode_fst]
  by_cases hc : g (flipPair mask z).1 = true ∧ g (flipPair mask z).2 = false
  · have hz : cubeG g z mask = true ∧ cubeG g z (antipode mask) = false :=
      hcond.mpr hc
    rw [if_pos hz]
    unfold crossTerm
    rw [if_pos hc]
    exact congrArg (fun s : ℝ => s⁻¹) (cubeCost_eq lam z mask w)
  · have hz : ¬ (cubeG g z mask = true ∧ cubeG g z (antipode mask) = false) :=
      fun h => hc (hcond.mp h)
    rw [if_neg hz]
    simp [crossTerm, hc]

/-- Exact reciprocal transfer to the product-pair law.
The right side still uses the expected restricted-cube boundary; identifying
it with the resampling boundary is the next, separate lemma. -/
theorem weighted_orbit_reciprocal_bound
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) (w : ι → ℝ) (hw : ∀ j, 0 < w j) :
    (Fintype.card (ι → Bool) : ℝ) *
      (∑ z, pairMass p z * crossTerm g lam w z) ≤
    ∑ z, pairMass p z * (∑ j, (bdry (cubeG g z) j : ℝ) / w j) := by
  have h := weighted_antipodal_on_product_cubes p hp g lam hrow w hw
  have hL :
      (∑ z, pairMass p z *
        (∑ mask ∈ zone (cubeG g z),
          (∑ j, w j * cubeLam lam z mask j *
            cubeLam lam z (antipode mask) j)⁻¹)) =
        (Fintype.card (ι → Bool) : ℝ) *
          (∑ z, pairMass p z * crossTerm g lam w z) := by
    simp_rw [cube_zone_sum_eq_crossTerm]
    simp_rw [Finset.mul_sum]
    rw [Finset.sum_comm]
    simpa only [Finset.mul_sum] using
      (weighted_sum_all_orientations p (crossTerm g lam w))
  rw [hL] at h
  exact h


/-! ## Boundary normalization: the dimension-free resampling coefficient -/

/-- Replace precisely coordinate j of the first draw with the second draw. -/
def replaceFromSecond (z : PairSample ι α) (j : ι) : ι → α :=
  fun i => if i = j then z.2 i else z.1 i

/-- The directed crossing indicator for a fresh resampling at coordinate j. -/
def edgeCross (g : (ι → α) → Bool) (j : ι) (z : PairSample ι α) : ℝ :=
  if g z.1 = true ∧ g (replaceFromSecond z j) = false then 1 else 0

/-- Flipping a single orientation bit is exactly one-coordinate resampling. -/
theorem flipPair_flipSet_fst (z : PairSample ι α)
    (mask : ι → Bool) (j : ι) :
    (flipPair (flipSet mask {j}) z).1 =
      replaceFromSecond (flipPair mask z) j := by
  funext i
  by_cases hi : i = j
  · subst i
    cases hm : mask j <;> simp [replaceFromSecond, flipPair, flipSet, hm]
  · simp [replaceFromSecond, flipPair, flipSet, hi]

/-- Restricted-cube boundary counts are sums of directed resampling edges. -/
theorem cube_bdry_eq_edgeCross_sum (g : (ι → α) → Bool)
    (z : PairSample ι α) (j : ι) :
    (bdry (cubeG g z) j : ℝ) =
      ∑ mask, edgeCross g j (flipPair mask z) := by
  classical
  calc
    (bdry (cubeG g z) j : ℝ) =
        ∑ mask ∈ (Finset.univ.filter
          (fun mask : ι → Bool =>
            cubeG g z mask = true ∧ cubeG g z (flipSet mask {j}) = false)),
          (1 : ℝ) := by
            simp [bdry]
    _ = ∑ mask, if cubeG g z mask = true ∧
          cubeG g z (flipSet mask {j}) = false then (1 : ℝ) else 0 := by
            rw [Finset.sum_filter]
    _ = ∑ mask, edgeCross g j (flipPair mask z) := by
          apply Finset.sum_congr rfl
          intro mask _
          simp [edgeCross, cubeG, flipPair_flipSet_fst]

/-- Exact identity between expected induced-cube boundary and the ordinary
product-measure resampling boundary; no assumptions on atom sizes. -/
theorem weighted_bdry_eq_resampling
    (p : ι → α → ℝ) (g : (ι → α) → Bool) (j : ι) :
    (∑ z, pairMass p z * (bdry (cubeG g z) j : ℝ)) =
      (Fintype.card (ι → Bool) : ℝ) *
        (∑ z, pairMass p z * edgeCross g j z) := by
  simp_rw [cube_bdry_eq_edgeCross_sum]
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  simpa only [Finset.mul_sum] using
    (weighted_sum_all_orientations p (edgeCross g j))

/-- Dimension-free product-space reciprocal inequality, with precisely the
directed resampling boundary on the right. This theorem is about finite
product spaces and global nonnegative fractional-certificate rows. -/
theorem weighted_product_reciprocal
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) (w : ι → ℝ) (hw : ∀ j, 0 < w j) :
    (∑ z, pairMass p z * crossTerm g lam w z) ≤
      ∑ j, (∑ z, pairMass p z * edgeCross g j z) / w j := by
  have h := weighted_orbit_reciprocal_bound p hp g lam hrow w hw
  have hR :
      (∑ z, pairMass p z *
        (∑ j, (bdry (cubeG g z) j : ℝ) / w j)) =
        (Fintype.card (ι → Bool) : ℝ) *
          (∑ j, (∑ z, pairMass p z * edgeCross g j z) / w j) := by
    calc
      (∑ z, pairMass p z *
        (∑ j, (bdry (cubeG g z) j : ℝ) / w j)) =
          ∑ j, (∑ z, pairMass p z * (bdry (cubeG g z) j : ℝ)) / w j := by
            simp_rw [Finset.mul_sum]
            rw [Finset.sum_comm]
            apply Finset.sum_congr rfl
            intro j _
            rw [Finset.sum_div]
            apply Finset.sum_congr rfl
            intro z _
            ring
      _ = ∑ j, ((Fintype.card (ι → Bool) : ℝ) *
            (∑ z, pairMass p z * edgeCross g j z)) / w j := by
            apply Finset.sum_congr rfl
            intro j _
            rw [weighted_bdry_eq_resampling]
      _ = (Fintype.card (ι → Bool) : ℝ) *
          (∑ j, (∑ z, pairMass p z * edgeCross g j z) / w j) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro j _
            ring
  rw [hR] at h
  have hcard : 0 < (Fintype.card (ι → Bool) : ℝ) := by
    exact_mod_cast (Fintype.card_pos : 0 < Fintype.card (ι → Bool))
  exact (mul_le_mul_iff_of_pos_left hcard).mp h


/-- Positive denominator on every crossing pair. This closes the Lean
zero-inverse loophole: the reciprocal integrand is a genuine positive cost. -/
theorem cross_pair_cost_pos
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) (w : ι → ℝ) (hw : ∀ j, 0 < w j)
    (z : PairSample ι α) (hcross : g z.1 = true ∧ g z.2 = false) :
    0 < ∑ j ∈ disagree z.1 z.2,
      w j * lam z.1 j * lam z.2 j := by
  let u : ι → Bool := fun _ => false
  have hfu : (flipPair u z).1 = z.1 := by
    funext i
    simp [u, flipPair]
  have hsu : (flipPair u z).2 = z.2 := by
    funext i
    simp [u, flipPair]
  have hanti : (flipPair (antipode u) z).1 = z.2 := by
    rw [flipPair_antipode_fst, hsu]
  have hzone : u ∈ zone (cubeG g z) := by
    apply (mem_zone).mpr
    constructor
    · change g (flipPair u z).1 = true
      rw [hfu]
      exact hcross.1
    · change g (flipPair (antipode u) z).1 = false
      rw [hanti]
      exact hcross.2
  have h1 := cubeLam_isRow g lam hrow z u
  have h2 := cubeLam_isRow g lam hrow z (antipode u)
  have hh : 0 < ∑ j, w j * cubeLam lam z u j *
      cubeLam lam z (antipode u) j :=
    Bridge.antipodal_inner_pos hzone hw h1 h2
  rw [cubeCost_eq lam z u w, hfu, hsu] at hh
  exact hh

end Nightfall.ProductSpace.Transfer


/-!
# Localized weight removal (Certificate Engine v2, Lemma 4.1) — complete form

NIGHTFALL product-space programme. This file formalizes, for arbitrary finite
index types and *nonnegative* (possibly zero) coefficients:

1. `reg_weight_mul_le`, `div_reg_weight_le`: the ε-regularized weight bounds.
2. `le_of_forall_reg`: the ε → 0 limit, by an explicit ε–δ argument.
3. `localized_weight_optimization`: if `V² ≤ (∑ wᵢAᵢ)(∑ βᵢ/wᵢ)` for every positive `w`,
   then `V ≤ ∑ √βᵢ √Aᵢ`. This removes the strict-positivity hypotheses of
   `localized_weight_optimization_positive` (PR #289).
4. `cs_reciprocal`, `cs_reciprocal2`: Cauchy–Schwarz with reciprocal weights.
5. `localized_weight_removal`: the full lemma. If for every positive `w` the pair sums
   `s_xy(w) = ∑_{j ∈ J x y} wⱼ λₓⱼ γᵧⱼ` are positive and `∑ₓ ∑ᵧ s_xy(w)⁻¹ ≤ ∑ⱼ cⱼ / wⱼ`, then
   `(∑ₓ ‖λₓ‖⁻¹)(∑ᵧ ‖γᵧ‖⁻¹) ≤ ∑ⱼ √cⱼ · √(Xⱼ Yⱼ)`.
6. `weight_removal_max`: Turturean's form (Lemma 5.3 of arXiv:2611.09773), recovered:
   `(∑ₓ ‖λₓ‖⁻¹)(∑ᵧ ‖γᵧ‖⁻¹) ≤ M` whenever every `cⱼ ≤ M`.

The probabilistic input (the all-pairs inequality on product spaces, Theorem 1.2) is
NOT formalized here. Combined with it, item 5 is the localized two-sided inequality.
No `sorry`, no custom axioms.
-/

namespace Nightfall.ProductSpace

open Finset

/-! ## 1. Regularized weights -/

lemma reg_weight_pos {b a ε : ℝ} (hε : 0 < ε) :
    0 < (Real.sqrt b + ε) / (Real.sqrt a + ε) :=
  div_pos (add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε)
    (add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε)

lemma reg_weight_mul_le {b a ε : ℝ} (ha : 0 ≤ a) (hε : 0 < ε) :
    (Real.sqrt b + ε) / (Real.sqrt a + ε) * a ≤ (Real.sqrt b + ε) * Real.sqrt a := by
  have hA : 0 < Real.sqrt a + ε := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε
  have hB : 0 ≤ Real.sqrt b + ε := add_nonneg (Real.sqrt_nonneg _) hε.le
  have hsa : 0 ≤ Real.sqrt a := Real.sqrt_nonneg _
  have hs : Real.sqrt a * Real.sqrt a = a := Real.mul_self_sqrt ha
  rw [div_mul_eq_mul_div, div_le_iff₀ hA]
  calc (Real.sqrt b + ε) * a
      = (Real.sqrt b + ε) * Real.sqrt a * Real.sqrt a := by rw [mul_assoc, hs]
    _ ≤ (Real.sqrt b + ε) * Real.sqrt a * (Real.sqrt a + ε) :=
        mul_le_mul_of_nonneg_left (by linarith) (mul_nonneg hB hsa)

lemma div_reg_weight_le {b a ε : ℝ} (hb : 0 ≤ b) (hε : 0 < ε) :
    b / ((Real.sqrt b + ε) / (Real.sqrt a + ε)) ≤ Real.sqrt b * (Real.sqrt a + ε) := by
  have hA : 0 < Real.sqrt a + ε := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε
  have hB : 0 < Real.sqrt b + ε := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε
  have hsb : 0 ≤ Real.sqrt b := Real.sqrt_nonneg _
  have hs : Real.sqrt b * Real.sqrt b = b := Real.mul_self_sqrt hb
  rw [div_div_eq_mul_div, div_le_iff₀ hB]
  calc b * (Real.sqrt a + ε)
      = Real.sqrt b * Real.sqrt b * (Real.sqrt a + ε) := by rw [hs]
    _ = Real.sqrt b * (Real.sqrt a + ε) * Real.sqrt b := by ring
    _ ≤ Real.sqrt b * (Real.sqrt a + ε) * (Real.sqrt b + ε) :=
        mul_le_mul_of_nonneg_left (by linarith) (mul_nonneg hsb hA.le)

/-! ## 2. The limit ε → 0 -/

lemma le_of_forall_reg (V S a b : ℝ) (hS : 0 ≤ S) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (key : ∀ ε : ℝ, 0 < ε → V ^ 2 ≤ (S + ε * a) * (S + ε * b)) : V ≤ S := by
  by_contra hlt
  push_neg at hlt
  have hVS : 0 < V + S := by linarith
  have hgap : 0 < V ^ 2 - S ^ 2 := by nlinarith [mul_pos (sub_pos.2 hlt) hVS]
  have hC : 0 ≤ a * S + b * S + a * b := by
    have h1 := mul_nonneg ha hS
    have h2 := mul_nonneg hb hS
    have h3 := mul_nonneg ha hb
    linarith
  have hpos : 0 < 2 * (a * S + b * S + a * b + 1) := by linarith
  obtain ⟨ε, hεdef⟩ : ∃ ε, ε = min 1 ((V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1))) :=
    ⟨_, rfl⟩
  have hε : 0 < ε := by rw [hεdef]; exact lt_min one_pos (div_pos hgap hpos)
  have hε1 : ε ≤ 1 := by rw [hεdef]; exact min_le_left _ _
  have hε2 : ε ≤ (V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1)) := by
    rw [hεdef]; exact min_le_right _ _
  have hk := key ε hε
  have hsq : ε ^ 2 * (a * b) ≤ ε * (a * b) := by
    refine mul_le_mul_of_nonneg_right ?_ (mul_nonneg ha hb)
    nlinarith [mul_nonneg hε.le (sub_nonneg.2 hε1)]
  have hexp : (S + ε * a) * (S + ε * b) = S ^ 2 + ε * (a * S + b * S) + ε ^ 2 * (a * b) := by
    ring
  have h3 : ε * (a * S + b * S + a * b) ≤
      (V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1)) * (a * S + b * S + a * b) :=
    mul_le_mul_of_nonneg_right hε2 hC
  have h4 : (V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1)) * (a * S + b * S + a * b) ≤
      (V ^ 2 - S ^ 2) / 2 := by
    rw [div_mul_eq_mul_div, div_le_iff₀ hpos]
    nlinarith [hgap.le]
  have h5 : ε * (a * S + b * S + a * b) = ε * (a * S + b * S) + ε * (a * b) := by ring
  linarith

/-! ## 3. Weight optimization with zero coefficients allowed -/

/-- Localized weight optimization: nonnegative coefficients, finite support, no positivity
assumption on `β` or `A`. -/
theorem localized_weight_optimization {ι : Type*} (s : Finset ι)
    (β A : ι → ℝ) (V : ℝ)
    (hβ : ∀ i ∈ s, 0 ≤ β i) (hA : ∀ i ∈ s, 0 ≤ A i)
    (hweighted : ∀ w : ι → ℝ, (∀ i ∈ s, 0 < w i) →
      V ^ 2 ≤ (∑ i ∈ s, w i * A i) * (∑ i ∈ s, β i / w i)) :
    V ≤ ∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i) := by
  have hS : 0 ≤ ∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i) :=
    sum_nonneg fun i _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have ha : 0 ≤ ∑ i ∈ s, Real.sqrt (A i) := sum_nonneg fun i _ => Real.sqrt_nonneg _
  have hb : 0 ≤ ∑ i ∈ s, Real.sqrt (β i) := sum_nonneg fun i _ => Real.sqrt_nonneg _
  refine le_of_forall_reg V (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i))
    (∑ i ∈ s, Real.sqrt (A i)) (∑ i ∈ s, Real.sqrt (β i)) hS ha hb ?_
  intro ε hε
  have hW := hweighted (fun i => (Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε))
    (fun i _ => reg_weight_pos hε)
  beta_reduce at hW
  have h1 : (∑ i ∈ s, (Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε) * A i) ≤
      (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (A i) := by
    calc (∑ i ∈ s, (Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε) * A i)
        ≤ ∑ i ∈ s, (Real.sqrt (β i) + ε) * Real.sqrt (A i) :=
          sum_le_sum fun i hi => reg_weight_mul_le (hA i hi) hε
      _ = (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (A i) := by
          rw [mul_sum, ← sum_add_distrib]
          exact sum_congr rfl fun i _ => by ring
  have h2 : (∑ i ∈ s, β i / ((Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε))) ≤
      (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (β i) := by
    calc (∑ i ∈ s, β i / ((Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε)))
        ≤ ∑ i ∈ s, Real.sqrt (β i) * (Real.sqrt (A i) + ε) :=
          sum_le_sum fun i hi => div_reg_weight_le (hβ i hi) hε
      _ = (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (β i) := by
          rw [mul_sum, ← sum_add_distrib]
          exact sum_congr rfl fun i _ => by ring
  have hpos2 : 0 ≤ ∑ i ∈ s, β i / ((Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε)) :=
    sum_nonneg fun i hi => div_nonneg (hβ i hi) (reg_weight_pos hε).le
  have hR : 0 ≤ (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (A i) :=
    add_nonneg hS (mul_nonneg hε.le ha)
  exact le_trans hW (mul_le_mul h1 h2 hpos2 hR)

/-! ## 4. Cauchy–Schwarz with reciprocal weights -/

lemma cs_reciprocal {κ : Type*} [Fintype κ] (a s : κ → ℝ) (hs : ∀ k, 0 < s k) :
    (∑ k, a k) ^ 2 ≤ (∑ k, a k ^ 2 * s k) * (∑ k, (s k)⁻¹) := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun k => a k * Real.sqrt (s k)) (fun k => (Real.sqrt (s k))⁻¹)
  have e1 : ∀ k, a k * Real.sqrt (s k) * (Real.sqrt (s k))⁻¹ = a k := fun k =>
    mul_inv_cancel_right₀ (Real.sqrt_pos.2 (hs k)).ne' (a k)
  have e2 : ∀ k, (a k * Real.sqrt (s k)) ^ 2 = a k ^ 2 * s k := fun k => by
    rw [mul_pow, Real.sq_sqrt (hs k).le]
  have e3 : ∀ k, ((Real.sqrt (s k))⁻¹) ^ 2 = (s k)⁻¹ := fun k => by
    rw [inv_pow, Real.sq_sqrt (hs k).le]
  simp only [e1, e2, e3] at h
  exact h

lemma cs_reciprocal2 {α γ : Type*} [Fintype α] [Fintype γ] (a s : α → γ → ℝ)
    (hs : ∀ x y, 0 < s x y) :
    (∑ x, ∑ y, a x y) ^ 2 ≤
      (∑ x, ∑ y, a x y ^ 2 * s x y) * (∑ x, ∑ y, (s x y)⁻¹) := by
  have h := cs_reciprocal (fun p : α × γ => a p.1 p.2) (fun p => s p.1 p.2)
    (fun p => hs p.1 p.2)
  simp only [Fintype.sum_prod_type] at h
  exact h

/-! ## 5. Localized weight removal -/

/-- Inverse ℓ¹ cost of a row. -/
noncomputable def invCost {κ : Type*} [Fintype κ] (r : κ → ℝ) : ℝ := (∑ j, r j)⁻¹

/-- Coordinate load `Xⱼ = ∑ₓ ‖λₓ‖⁻² λₓⱼ`. -/
noncomputable def load {α : Type*} [Fintype α] {κ : Type*} [Fintype κ] (lam : α → κ → ℝ) (j : κ) : ℝ :=
  ∑ x, invCost (lam x) ^ 2 * lam x j

lemma load_nonneg {α : Type*} [Fintype α] {κ : Type*} [Fintype κ] (lam : α → κ → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (j : κ) : 0 ≤ load lam j :=
  sum_nonneg fun x _ => mul_nonneg (sq_nonneg _) (hlam x j)

/-- Localized weight removal (Certificate Engine v2, Lemma 4.1). -/
theorem localized_weight_removal {α γ : Type*} [Fintype α] [Fintype γ] {κ : Type*} [Fintype κ]
    (lam : α → κ → ℝ) (gam : γ → κ → ℝ) (J : α → γ → Finset (κ))
    (c : κ → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (hgam : ∀ y j, 0 ≤ gam y j) (hc : ∀ j, 0 ≤ c j)
    (hpos : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * lam x j * gam y j)
    (hrecip : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ ≤ ∑ j, c j / w j) :
    (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) ≤
      ∑ j, Real.sqrt (c j) * Real.sqrt (load lam j * load gam j) := by
  refine localized_weight_optimization Finset.univ c (fun j => load lam j * load gam j)
    ((∑ x, invCost (lam x)) * (∑ y, invCost (gam y)))
    (fun j _ => hc j)
    (fun j _ => mul_nonneg (load_nonneg lam hlam j) (load_nonneg gam hgam j)) ?_
  intro w hw'
  have hw : ∀ j, 0 < w j := fun j => hw' j (Finset.mem_univ j)
  -- Cauchy–Schwarz over pairs
  have cs := cs_reciprocal2 (fun x y => invCost (lam x) * invCost (gam y))
    (fun x y => ∑ j ∈ J x y, w j * lam x j * gam y j) (fun x y => hpos w hw x y)
  beta_reduce at cs
  have hV : (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) =
      ∑ x, ∑ y, invCost (lam x) * invCost (gam y) := by
    rw [Finset.sum_mul_sum]
  -- enlarge J x y to all coordinates
  have hterm : ∀ x y, 0 ≤ ∑ j, w j * lam x j * gam y j := fun x y =>
    sum_nonneg fun j _ => mul_nonneg (mul_nonneg (hw j).le (hlam x j)) (hgam y j)
  have h1 : (∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
        ∑ j ∈ J x y, w j * lam x j * gam y j) ≤
      ∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
        ∑ j, w j * lam x j * gam y j := by
    refine sum_le_sum fun x _ => sum_le_sum fun y _ => ?_
    refine mul_le_mul_of_nonneg_left ?_ (sq_nonneg _)
    exact sum_le_sum_of_subset_of_nonneg (subset_univ _)
      (fun j _ _ => mul_nonneg (mul_nonneg (hw j).le (hlam x j)) (hgam y j))
  -- rearrange into coordinate loads
  have expand : (∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
        ∑ j, w j * lam x j * gam y j) =
      ∑ j, w j * (load lam j * load gam j) := by
    symm
    calc ∑ j, w j * (load lam j * load gam j)
        = ∑ j, ∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            (w j * lam x j * gam y j) := by
          refine sum_congr rfl fun j _ => ?_
          unfold load
          rw [Finset.sum_mul_sum, Finset.mul_sum]
          refine sum_congr rfl fun x _ => ?_
          rw [Finset.mul_sum]
          refine sum_congr rfl fun y _ => ?_
          ring
      _ = ∑ x, ∑ j, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            (w j * lam x j * gam y j) := Finset.sum_comm
      _ = ∑ x, ∑ y, ∑ j, (invCost (lam x) * invCost (gam y)) ^ 2 *
            (w j * lam x j * gam y j) := by
          refine sum_congr rfl fun x _ => ?_
          exact Finset.sum_comm
      _ = ∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            ∑ j, w j * lam x j * gam y j := by
          refine sum_congr rfl fun x _ => sum_congr rfl fun y _ => ?_
          rw [Finset.mul_sum]
  have hrec_nonneg : 0 ≤ ∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ :=
    sum_nonneg fun x _ => sum_nonneg fun y _ => (inv_pos.2 (hpos w hw x y)).le
  have hload_nonneg : 0 ≤ ∑ j, w j * (load lam j * load gam j) :=
    sum_nonneg fun j _ =>
      mul_nonneg (hw j).le (mul_nonneg (load_nonneg lam hlam j) (load_nonneg gam hgam j))
  calc ((∑ x, invCost (lam x)) * (∑ y, invCost (gam y))) ^ 2
      = (∑ x, ∑ y, invCost (lam x) * invCost (gam y)) ^ 2 := by rw [hV]
    _ ≤ (∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            ∑ j ∈ J x y, w j * lam x j * gam y j) *
          (∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹) := cs
    _ ≤ (∑ j, w j * (load lam j * load gam j)) * (∑ j, c j / w j) :=
        mul_le_mul (h1.trans expand.le) (hrecip w hw) hrec_nonneg hload_nonneg

/-! ## 6. Turturean's form (unlocalized) as a corollary -/

lemma sum_load_eq {α : Type*} [Fintype α] {κ : Type*} [Fintype κ] (lam : α → κ → ℝ)
    (hnl : ∀ x, 0 < ∑ j, lam x j) :
    ∑ j, load lam j = ∑ x, invCost (lam x) := by
  unfold load
  rw [Finset.sum_comm]
  refine sum_congr rfl fun x _ => ?_
  rw [← Finset.mul_sum]
  unfold invCost
  have h : (∑ j, lam x j) ≠ 0 := (hnl x).ne'
  rw [sq, mul_assoc, inv_mul_cancel₀ h, mul_one]

/-- Recovering the unlocalized weight-removal bound from the localized one. -/
theorem weight_removal_max {α γ : Type*} [Fintype α] [Fintype γ] {κ : Type*} [Fintype κ]
    (lam : α → κ → ℝ) (gam : γ → κ → ℝ) (J : α → γ → Finset (κ))
    (c : κ → ℝ) (M : ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (hgam : ∀ y j, 0 ≤ gam y j) (hc : ∀ j, 0 ≤ c j)
    (hM : ∀ j, c j ≤ M) (hM0 : 0 ≤ M)
    (hnl : ∀ x, 0 < ∑ j, lam x j) (hng : ∀ y, 0 < ∑ j, gam y j)
    (hpos : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * lam x j * gam y j)
    (hrecip : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ ≤ ∑ j, c j / w j) :
    (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) ≤ M := by
  have hloc := localized_weight_removal lam gam J c hlam hgam hc hpos hrecip
  have hXn := load_nonneg lam hlam
  have hYn := load_nonneg gam hgam
  have hVA : 0 ≤ ∑ x, invCost (lam x) :=
    sum_nonneg fun x _ => inv_nonneg.2 (hnl x).le
  have hVB : 0 ≤ ∑ y, invCost (gam y) :=
    sum_nonneg fun y _ => inv_nonneg.2 (hng y).le
  set V := (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) with hVdef
  have hV : 0 ≤ V := mul_nonneg hVA hVB
  set T := ∑ j, Real.sqrt (load lam j) * Real.sqrt (load gam j) with hTdef
  have hT : 0 ≤ T := sum_nonneg fun j _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  -- V ≤ √M · T
  have hle : V ≤ Real.sqrt M * T := by
    refine le_trans hloc ?_
    rw [hTdef, Finset.mul_sum]
    refine sum_le_sum fun j _ => ?_
    have hcM : Real.sqrt (c j) ≤ Real.sqrt M := Real.sqrt_le_sqrt (hM j)
    have hXY : 0 ≤ Real.sqrt (load lam j) * Real.sqrt (load gam j) :=
      mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
    rw [Real.sqrt_mul (hXn j)]
    exact mul_le_mul_of_nonneg_right hcM hXY
  -- T² ≤ V by Cauchy–Schwarz over coordinates
  have hT2 : T ^ 2 ≤ V := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun j => Real.sqrt (load lam j)) (fun j => Real.sqrt (load gam j))
    have eX : ∀ j, Real.sqrt (load lam j) ^ 2 = load lam j := fun j => Real.sq_sqrt (hXn j)
    have eY : ∀ j, Real.sqrt (load gam j) ^ 2 = load gam j := fun j => Real.sq_sqrt (hYn j)
    simp only [eX, eY] at h
    rw [sum_load_eq lam hnl, sum_load_eq gam hng] at h
    exact h
  -- conclude
  have hVV : V * V ≤ M * V := by
    have h1 : V * V ≤ (Real.sqrt M * T) * (Real.sqrt M * T) := mul_self_le_mul_self hV hle
    have h2 : (Real.sqrt M * T) * (Real.sqrt M * T) = M * T ^ 2 := by
      have := Real.mul_self_sqrt hM0
      calc (Real.sqrt M * T) * (Real.sqrt M * T)
          = (Real.sqrt M * Real.sqrt M) * T ^ 2 := by ring
        _ = M * T ^ 2 := by rw [this]
    have h3 : M * T ^ 2 ≤ M * V := mul_le_mul_of_nonneg_left hT2 hM0
    linarith
  rcases eq_or_lt_of_le hV with h0 | hpos'
  · rw [← h0]; exact hM0
  · exact le_of_mul_le_mul_right hVV hpos'

end Nightfall.ProductSpace


/-!
Mass absorption for the conditional localized weight-removal theorem.
For strictly positive sample weights p and q, replacing rows
  lambda(x,j) by lambda(x,j)/p(x)
turns inverse row costs into p(x) times the original inverse cost, and
reciprocal pair costs into p(x)q(y) times the original reciprocal pair cost.

This is algebraically independent of the probabilistic antipodal transfer.
It does not prove the latter's reciprocal premise. Zero-mass points
are handled by restricting the finite index sets to their supports.
-/

namespace Nightfall.ProductSpace

open Finset

lemma invCost_scaled {κ : Type*} [Fintype κ] (r : κ → ℝ) {m : ℝ} (hm : 0 < m) :
    invCost (fun j => r j / m) = m * invCost r := by
  unfold invCost
  change (∑ j, r j / m)⁻¹ = m * (∑ j, r j)⁻¹
  rw [← Finset.sum_div, inv_div, div_eq_mul_inv]

lemma scaled_pair_sum {α γ : Type*} [Fintype α] [Fintype γ]
    {κ : Type*} [Fintype κ] (lam : α → κ → ℝ) (gam : γ → κ → ℝ)
    (J : α → γ → Finset (κ)) (w : κ → ℝ)
    (p : α → ℝ) (q : γ → ℝ)
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y) (x : α) (y : γ) :
    (∑ j ∈ J x y, w j * (lam x j / p x) * (gam y j / q y)) =
      (∑ j ∈ J x y, w j * lam x j * gam y j) / (p x * q y) := by
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  field_simp [(hp x).ne', (hq y).ne']

lemma scaled_pair_inv {α γ : Type*} [Fintype α] [Fintype γ]
    {κ : Type*} [Fintype κ] (lam : α → κ → ℝ) (gam : γ → κ → ℝ)
    (J : α → γ → Finset (κ)) (w : κ → ℝ)
    (p : α → ℝ) (q : γ → ℝ)
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y) (x : α) (y : γ) :
    (∑ j ∈ J x y, w j * (lam x j / p x) * (gam y j / q y))⁻¹ =
      p x * q y * (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ := by
  rw [scaled_pair_sum lam gam J w p q hp hq x y, inv_div, div_eq_mul_inv]

lemma load_scaled {α : Type*} [Fintype α] {κ : Type*} [Fintype κ]
    (lam : α → κ → ℝ) (p : α → ℝ) (hp : ∀ x, 0 < p x)
    (j : κ) :
    load (fun x i => lam x i / p x) j =
      ∑ x, p x * invCost (lam x) ^ 2 * lam x j := by
  unfold load
  apply Finset.sum_congr rfl
  intro x _
  rw [invCost_scaled (lam x) (hp x)]
  have hx : p x ≠ 0 := (hp x).ne'
  field_simp [hx]

/-- The already-certified unweighted localized weight-removal lemma
extends exactly to finite strictly-positive masses by row scaling.
The only reciprocal premise is a mass-weighted one, not a new axiom. -/
theorem localized_weight_removal_mass
    {α γ : Type*} [Fintype α] [Fintype γ] {κ : Type*} [Fintype κ]
    (lam : α → κ → ℝ) (gam : γ → κ → ℝ)
    (J : α → γ → Finset (κ))
    (p : α → ℝ) (q : γ → ℝ)
    (c : κ → ℝ)
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y)
    (hlam : ∀ x j, 0 ≤ lam x j)
    (hgam : ∀ y j, 0 ≤ gam y j)
    (hc : ∀ j, 0 ≤ c j)
    (hpos : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * lam x j * gam y j)
    (hrecip : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      (∑ x, ∑ y, p x * q y *
        (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹) ≤
        ∑ j, c j / w j) :
    (∑ x, p x * invCost (lam x)) *
      (∑ y, q y * invCost (gam y)) ≤
      ∑ j, Real.sqrt (c j) *
        Real.sqrt ((∑ x, p x * invCost (lam x) ^ 2 * lam x j) *
                   (∑ y, q y * invCost (gam y) ^ 2 * gam y j)) := by
  let ls : α → κ → ℝ := fun x j => lam x j / p x
  let gs : γ → κ → ℝ := fun y j => gam y j / q y
  have hls : ∀ x j, 0 ≤ ls x j :=
    fun x j => div_nonneg (hlam x j) (hp x).le
  have hgs : ∀ y j, 0 ≤ gs y j :=
    fun y j => div_nonneg (hgam y j) (hq y).le
  have hpos' : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * ls x j * gs y j := by
    intro w hw x y
    change 0 < ∑ j ∈ J x y, w j * (lam x j / p x) * (gam y j / q y)
    rw [scaled_pair_sum lam gam J w p q hp hq x y]
    exact div_pos (hpos w hw x y) (mul_pos (hp x) (hq y))
  have hrecip' : ∀ w : κ → ℝ, (∀ j, 0 < w j) →
      (∑ x, ∑ y, (∑ j ∈ J x y, w j * ls x j * gs y j)⁻¹) ≤
      ∑ j, c j / w j := by
    intro w hw
    have h := hrecip w hw
    convert h using 1
    apply Finset.sum_congr rfl
    intro x _
    apply Finset.sum_congr rfl
    intro y _
    exact scaled_pair_inv lam gam J w p q hp hq x y
  have hcore := localized_weight_removal ls gs J c hls hgs hc hpos' hrecip'
  calc
    (∑ x, p x * invCost (lam x)) * (∑ y, q y * invCost (gam y)) =
        (∑ x, invCost (ls x)) * (∑ y, invCost (gs y)) := by
          congr 1
          · apply Finset.sum_congr rfl
            intro x _
            exact (invCost_scaled (lam x) (hp x)).symm
          · apply Finset.sum_congr rfl
            intro y _
            exact (invCost_scaled (gam y) (hq y)).symm
    _ ≤ ∑ j, Real.sqrt (c j) * Real.sqrt (load ls j * load gs j) := hcore
    _ = ∑ j, Real.sqrt (c j) *
        Real.sqrt ((∑ x, p x * invCost (lam x) ^ 2 * lam x j) *
                   (∑ y, q y * invCost (gam y) ^ 2 * gam y j)) := by
        apply Finset.sum_congr rfl
        intro j _
        rw [load_scaled lam p hp j, load_scaled gam q hq j]

end Nightfall.ProductSpace

/-!
## End-to-end bridge: the localized two-sided inequality on finite product spaces

Composes, in one pinned toolchain (Lean 4.33.0, Turturean's workspace):
* `weighted_product_reciprocal` and `cross_pair_cost_pos` (PR #295, two-draw transfer of
  Turturean's antipodal theorem), and
* `localized_weight_removal_mass` (PR #293 / #295, generalized here from `Fin n` to any finite
  coordinate type).

Result (Certificate Engine v2, Theorem 1.3, unnormalized form): for strictly positive
coordinate masses, a Boolean `g` with fractional-certificate rows `lam` satisfies
  `V₁ · V₀ ≤ ∑ⱼ √(Bⱼ) · √(Pⱼ Qⱼ)`,
where `V₁ = ∑_{g x} μ(x)/‖λˣ‖`, `V₀ = ∑_{¬g y} μ(y)/‖λʸ‖`, `Pⱼ, Qⱼ` are the mass-weighted
coordinate loads and `Bⱼ = ∑_{x,y} μ(x)μ(y) 1[g x, ¬g(x with j from y)]` is the directed
resampling boundary (equal to the influence `Iⱼ(g)` when the masses are normalized).
-/

namespace Nightfall.ProductSpace.Transfer

open Finset

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-- Product mass of a single configuration. -/
def prodMass (p : ι → α → ℝ) (x : ι → α) : ℝ := ∏ i, p i (x i)

theorem prodMass_pos (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a) (x : ι → α) :
    0 < prodMass p x :=
  Finset.prod_pos fun i _ => hp i (x i)

theorem pairMass_eq_prodMass (p : ι → α → ℝ) (z : PairSample ι α) :
    pairMass p z = prodMass p z.1 * prodMass p z.2 := by
  unfold pairMass prodMass
  exact Finset.prod_mul_distrib

theorem edgeCross_nonneg (g : (ι → α) → Bool) (j : ι) (z : PairSample ι α) :
    0 ≤ edgeCross g j z := by
  unfold edgeCross
  split_ifs <;> norm_num

/-- Sum over a subtype of configurations as an indicator-weighted full sum. -/
theorem sum_subtype_eq_ite (P : (ι → α) → Prop) [DecidablePred P] (F : (ι → α) → ℝ) :
    (∑ x : {x : ι → α // P x}, F x.1) = ∑ x, if P x then F x else 0 := by
  rw [← Finset.sum_filter]
  exact (Finset.sum_subtype (Finset.univ.filter P) (fun x => by simp) F).symm

/-- The crossing-pair reciprocal sum, written over the two output classes, is exactly the
`crossTerm` sum of the transfer theorem. -/
theorem cross_sum_eq (p : ι → α → ℝ) (g : (ι → α) → Bool)
    (lam : (ι → α) → ι → ℝ) (w : ι → ℝ) :
    (∑ x : {x : ι → α // g x = true}, ∑ y : {y : ι → α // g y = false},
      prodMass p x.1 * prodMass p y.1 *
        (∑ j ∈ disagree x.1 y.1, w j * lam x.1 j * lam y.1 j)⁻¹) =
    ∑ z, pairMass p z * crossTerm g lam w z := by
  have h1 : ∀ x y : ι → α, pairMass p (x, y) * crossTerm g lam w (x, y) =
      if g x = true then
        (if g y = false then prodMass p x * prodMass p y *
          (∑ j ∈ disagree x y, w j * lam x j * lam y j)⁻¹ else 0)
      else 0 := by
    intro x y
    rw [pairMass_eq_prodMass]
    unfold crossTerm
    by_cases hx : g x = true <;> by_cases hy : g y = false <;> simp [hx, hy]
  calc
    (∑ x : {x : ι → α // g x = true}, ∑ y : {y : ι → α // g y = false},
      prodMass p x.1 * prodMass p y.1 *
        (∑ j ∈ disagree x.1 y.1, w j * lam x.1 j * lam y.1 j)⁻¹)
        = ∑ x : {x : ι → α // g x = true}, ∑ y : ι → α,
            (if g y = false then prodMass p x.1 * prodMass p y *
              (∑ j ∈ disagree x.1 y, w j * lam x.1 j * lam y j)⁻¹ else 0) := by
          apply Finset.sum_congr rfl
          intro x _
          exact sum_subtype_eq_ite (fun y => g y = false)
            (fun y => prodMass p x.1 * prodMass p y *
              (∑ j ∈ disagree x.1 y, w j * lam x.1 j * lam y j)⁻¹)
    _ = ∑ x : ι → α, if g x = true then
            (∑ y : ι → α, if g y = false then prodMass p x * prodMass p y *
              (∑ j ∈ disagree x y, w j * lam x j * lam y j)⁻¹ else 0) else 0 :=
          sum_subtype_eq_ite (fun x => g x = true)
            (fun x => ∑ y : ι → α, if g y = false then prodMass p x * prodMass p y *
              (∑ j ∈ disagree x y, w j * lam x j * lam y j)⁻¹ else 0)
    _ = ∑ x : ι → α, ∑ y : ι → α, pairMass p (x, y) * crossTerm g lam w (x, y) := by
          apply Finset.sum_congr rfl
          intro x _
          simp only [h1]
          by_cases hx : g x = true
          · simp [hx]
          · simp [hx]
    _ = ∑ z, pairMass p z * crossTerm g lam w z := by
          rw [Fintype.sum_prod_type]

/-- **Localized two-sided inequality on finite product spaces**, fully composed:
no reciprocal or positivity hypothesis remains. -/
theorem localized_two_sided_product
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) :
    (∑ x : {x : ι → α // g x = true}, prodMass p x.1 * invCost (lam x.1)) *
      (∑ y : {y : ι → α // g y = false}, prodMass p y.1 * invCost (lam y.1)) ≤
    ∑ j, Real.sqrt (∑ z, pairMass p z * edgeCross g j z) *
      Real.sqrt ((∑ x : {x : ι → α // g x = true},
          prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j) *
        (∑ y : {y : ι → α // g y = false},
          prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j)) := by
  have hpm := prodMass_pos p hp
  have hc : ∀ j, 0 ≤ ∑ z, pairMass p z * edgeCross g j z := fun j =>
    Finset.sum_nonneg fun z _ =>
      mul_nonneg (pairMass_nonneg p (fun i a => (hp i a).le) z) (edgeCross_nonneg g j z)
  exact localized_weight_removal_mass
    (fun (x : {x : ι → α // g x = true}) j => lam x.1 j)
    (fun (y : {y : ι → α // g y = false}) j => lam y.1 j)
    (fun x y => disagree x.1 y.1)
    (fun x => prodMass p x.1) (fun y => prodMass p y.1)
    (fun j => ∑ z, pairMass p z * edgeCross g j z)
    (fun x => hpm x.1) (fun y => hpm y.1)
    (fun x j => hrow.1 x.1 j) (fun y j => hrow.1 y.1 j) hc
    (fun w hw x y => cross_pair_cost_pos g lam hrow w hw (x.1, y.1) ⟨x.2, y.2⟩)
    (fun w hw => (cross_sum_eq p g lam w).trans_le
      (weighted_product_reciprocal p (fun i a => (hp i a).le) g lam hrow w hw))

/-- Mass-weighted loads sum to the mass-weighted inverse costs. -/
theorem mass_load_sum {β : Type*} [Fintype β] {κ : Type*} [Fintype κ]
    (m : β → ℝ) (r : β → κ → ℝ) (hn : ∀ x, 0 < ∑ j, r x j) :
    (∑ j, ∑ x, m x * invCost (r x) ^ 2 * r x j) = ∑ x, m x * invCost (r x) := by
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  have h : (∑ j, r x j) ≠ 0 := (hn x).ne'
  rw [← Finset.mul_sum]
  unfold invCost
  rw [sq, mul_assoc, mul_assoc, inv_mul_cancel₀ h, mul_one]

/-- Pure algebra: the localized bound implies the unlocalized `≤ M` bound. -/
theorem two_sided_of_localized {κ : Type*} [Fintype κ]
    (V1 V0 M : ℝ) (c P Q : κ → ℝ) (hM0 : 0 ≤ M) (hcM : ∀ j, c j ≤ M)
    (hP : ∀ j, 0 ≤ P j) (hQ : ∀ j, 0 ≤ Q j)
    (hsP : ∑ j, P j = V1) (hsQ : ∑ j, Q j = V0)
    (hloc : V1 * V0 ≤ ∑ j, Real.sqrt (c j) * Real.sqrt (P j * Q j)) :
    V1 * V0 ≤ M := by
  have hV1 : 0 ≤ V1 := hsP ▸ Finset.sum_nonneg fun j _ => hP j
  have hV0 : 0 ≤ V0 := hsQ ▸ Finset.sum_nonneg fun j _ => hQ j
  have hV : 0 ≤ V1 * V0 := mul_nonneg hV1 hV0
  have hT : 0 ≤ ∑ j, Real.sqrt (P j) * Real.sqrt (Q j) :=
    Finset.sum_nonneg fun j _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hle : V1 * V0 ≤ Real.sqrt M * ∑ j, Real.sqrt (P j) * Real.sqrt (Q j) := by
    refine le_trans hloc ?_
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun j _ => ?_
    rw [Real.sqrt_mul (hP j)]
    exact mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt (hcM j))
      (mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))
  have hT2 : (∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) ^ 2 ≤ V1 * V0 := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun j => Real.sqrt (P j)) (fun j => Real.sqrt (Q j))
    have eP : ∀ j, Real.sqrt (P j) ^ 2 = P j := fun j => Real.sq_sqrt (hP j)
    have eQ : ∀ j, Real.sqrt (Q j) ^ 2 = Q j := fun j => Real.sq_sqrt (hQ j)
    simp only [eP, eQ] at h
    rw [hsP, hsQ] at h
    exact h
  have hVV : (V1 * V0) * (V1 * V0) ≤ M * (V1 * V0) := by
    have h1 := mul_self_le_mul_self hV hle
    have h2 : (Real.sqrt M * ∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) *
        (Real.sqrt M * ∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) =
        M * (∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) ^ 2 := by
      have hm := Real.mul_self_sqrt hM0
      calc (Real.sqrt M * ∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) *
            (Real.sqrt M * ∑ j, Real.sqrt (P j) * Real.sqrt (Q j))
          = (Real.sqrt M * Real.sqrt M) *
              (∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) ^ 2 := by ring
        _ = M * (∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) ^ 2 := by rw [hm]
    have h3 := mul_le_mul_of_nonneg_left hT2 hM0
    linarith
  rcases eq_or_lt_of_le hV with h0 | hpos
  · rw [← h0]; exact hM0
  · exact le_of_mul_le_mul_right hVV hpos

/-- **Turturean's two-sided inequality on finite product spaces** (Certificate Engine v2,
Theorem 1.3(a)): `V₁ · V₀ ≤ M` whenever every directed resampling boundary is at most `M`. -/
theorem two_sided_product
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam) (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (M : ℝ) (hM0 : 0 ≤ M) (hM : ∀ j, (∑ z, pairMass p z * edgeCross g j z) ≤ M) :
    (∑ x : {x : ι → α // g x = true}, prodMass p x.1 * invCost (lam x.1)) *
      (∑ y : {y : ι → α // g y = false}, prodMass p y.1 * invCost (lam y.1)) ≤ M := by
  have hpm := prodMass_pos p hp
  exact two_sided_of_localized _ _ M
    (fun j => ∑ z, pairMass p z * edgeCross g j z)
    (fun j => ∑ x : {x : ι → α // g x = true},
      prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j)
    (fun j => ∑ y : {y : ι → α // g y = false},
      prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j)
    hM0 hM
    (fun j => Finset.sum_nonneg fun x _ =>
      mul_nonneg (mul_nonneg (hpm x.1).le (sq_nonneg _)) (hrow.1 x.1 j))
    (fun j => Finset.sum_nonneg fun y _ =>
      mul_nonneg (mul_nonneg (hpm y.1).le (sq_nonneg _)) (hrow.1 y.1 j))
    (mass_load_sum (fun x : {x : ι → α // g x = true} => prodMass p x.1)
      (fun x j => lam x.1 j) (fun x => hnorm x.1))
    (mass_load_sum (fun y : {y : ι → α // g y = false} => prodMass p y.1)
      (fun y j => lam y.1 j) (fun y => hnorm y.1))
    (localized_two_sided_product p hp g lam hrow)

end Nightfall.ProductSpace.Transfer
