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

/-! ## Certificate-guided randomized observation -/

namespace Nightfall.ProductSpace.Discovery

open Finset

/-- A weighted Cauchy--Schwarz inequality with nonnegative weights.
This is the quantitative link between certificate overlap and expected
squared influence of a coordinate sampled from those weights. -/
theorem weighted_sqrt_cauchy
    {κ : Type*} [Fintype κ]
    (c q : κ → ℝ) (hc : ∀ j, 0 ≤ c j) (hq : ∀ j, 0 ≤ q j) :
    (∑ j, q j * Real.sqrt (c j)) ^ 2 ≤
      (∑ j, q j) * (∑ j, q j * c j) := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset κ)
    (fun j => Real.sqrt (q j))
    (fun j => Real.sqrt (q j) * Real.sqrt (c j))
  have hL : (∑ j, Real.sqrt (q j) *
      (Real.sqrt (q j) * Real.sqrt (c j))) =
      ∑ j, q j * Real.sqrt (c j) := by
    apply Finset.sum_congr rfl
    intro j _
    rw [← mul_assoc, Real.mul_self_sqrt (hq j)]
  have hA : (∑ j, (Real.sqrt (q j)) ^ 2) = ∑ j, q j := by
    apply Finset.sum_congr rfl
    intro j _
    exact Real.sq_sqrt (hq j)
  have hB : (∑ j, (Real.sqrt (q j) * Real.sqrt (c j)) ^ 2) =
      ∑ j, q j * c j := by
    apply Finset.sum_congr rfl
    intro j _
    rw [mul_pow, Real.sq_sqrt (hq j), Real.sq_sqrt (hc j)]
  rw [hL, hA, hB] at h
  exact h

/-- Certificate-overlap sampling turns the localized two-sided
inequality into a guaranteed *expected* coordinate influence.
There is no search for the maximum-influence coordinate.

The sampling probabilities are proportional to sqrt(P_j Q_j);
their normalization is positive because V1*V0 > 0. -/
theorem certificate_overlap_sampler
    {κ : Type*} [Fintype κ] (c P Q : κ → ℝ) (V1 V0 : ℝ)
    (hc : ∀ j, 0 ≤ c j) (hP : ∀ j, 0 ≤ P j)
    (hQ : ∀ j, 0 ≤ Q j)
    (hPsum : ∑ j, P j = V1) (hQsum : ∑ j, Q j = V0)
    (hV : 0 < V1 * V0)
    (hloc : V1 * V0 ≤
      ∑ j, Real.sqrt (c j) * Real.sqrt (P j * Q j)) :
    0 < ∑ j, Real.sqrt (P j * Q j) ∧
      (V1 * V0) ^ 2 ≤
        (∑ j, Real.sqrt (P j * Q j)) ^ 2 *
          (∑ j, (Real.sqrt (P j * Q j) /
            (∑ k, Real.sqrt (P k * Q k))) * c j) ∧
      V1 * V0 ≤
        ∑ j, (Real.sqrt (P j * Q j) /
          (∑ k, Real.sqrt (P k * Q k))) * c j := by
  let V : ℝ := V1 * V0
  let q : κ → ℝ := fun j => Real.sqrt (P j * Q j)
  let S : ℝ := ∑ j, q j
  let C : ℝ := ∑ j, q j * c j
  have hq : ∀ j, 0 ≤ q j := fun j => Real.sqrt_nonneg _
  have hqsum : 0 ≤ S := Finset.sum_nonneg (fun j _ => hq j)
  have hterm : 0 ≤ ∑ j, q j * Real.sqrt (c j) :=
    Finset.sum_nonneg (fun j _ => mul_nonneg (hq j) (Real.sqrt_nonneg _))
  have hlocal : V ≤ ∑ j, q j * Real.sqrt (c j) := by
    calc
      V ≤ ∑ j, Real.sqrt (c j) * Real.sqrt (P j * Q j) := hloc
      _ = ∑ j, q j * Real.sqrt (c j) := by
        apply Finset.sum_congr rfl
        intro j _
        exact mul_comm _ _
  have hsq : V ^ 2 ≤ (∑ j, q j * Real.sqrt (c j)) ^ 2 := by
    nlinarith [hlocal, hterm, hV]
  have hbound : V ^ 2 ≤ S * C := by
    exact le_trans hsq (weighted_sqrt_cauchy c q hc hq)
  have hSpos : 0 < S := by
    by_contra hn
    have hz : S = 0 := le_antisymm (le_of_not_gt hn) hqsum
    rw [hz] at hbound
    dsimp [V] at hbound
    nlinarith [sq_pos_of_pos hV]
  have hS2 : S ^ 2 ≤ V := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset κ)
      (fun j => Real.sqrt (P j)) (fun j => Real.sqrt (Q j))
    have hL : (∑ j, Real.sqrt (P j) * Real.sqrt (Q j)) = S := by
      apply Finset.sum_congr rfl
      intro j _
      exact (Real.sqrt_mul (hP j) (Q j)).symm
    have hA : (∑ j, (Real.sqrt (P j)) ^ 2) = V1 := by
      calc
        (∑ j, (Real.sqrt (P j)) ^ 2) = ∑ j, P j := by
          apply Finset.sum_congr rfl
          intro j _
          exact Real.sq_sqrt (hP j)
        _ = V1 := hPsum
    have hB : (∑ j, (Real.sqrt (Q j)) ^ 2) = V0 := by
      calc
        (∑ j, (Real.sqrt (Q j)) ^ 2) = ∑ j, Q j := by
          apply Finset.sum_congr rfl
          intro j _
          exact Real.sq_sqrt (hQ j)
        _ = V0 := hQsum
    rw [hL, hA, hB] at h
    exact h
  let A : ℝ := ∑ j, (q j / S) * c j
  have hSC : S * A = C := by
    dsimp [A, C]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    field_simp [hSpos.ne']
  have hV2 : V * S ^ 2 ≤ V ^ 2 := by
    have h := mul_le_mul_of_nonneg_left hS2 hV.le
    nlinarith
  have hVA : V * S ^ 2 ≤ A * S ^ 2 := by
    calc
      V * S ^ 2 ≤ V ^ 2 := hV2
      _ ≤ S * C := hbound
      _ = A * S ^ 2 := by rw [← hSC]; ring
  have hA : V ≤ A := by
    have hs : 0 < S ^ 2 := sq_pos_of_pos hSpos
    exact (mul_le_mul_iff_of_pos_left hs).mp (by nlinarith [hVA])
  have hsharp : V ^ 2 ≤ S ^ 2 * A := by
    calc
      V ^ 2 ≤ S * C := hbound
      _ = S ^ 2 * A := by rw [← hSC]; ring
  exact ⟨hSpos, hsharp, hA⟩

/-- Formal potential descent for an influence-guided randomized query.
The analytic information is entirely in the gain premise; the one-step
descent identity itself is exact. -/
theorem weighted_potential_descent
    {κ : Type*} [Fintype κ]
    (π influence after : κ → ℝ) (T gain : ℝ)
    (hπ : ∑ j, π j = 1)
    (hgain : gain ≤ ∑ j, π j * influence j)
    (hafter : ∀ j, after j = T - influence j) :
    (∑ j, π j * after j) ≤ T - gain := by
  calc
    (∑ j, π j * after j) =
        T * (∑ j, π j) - ∑ j, π j * influence j := by
          calc
            (∑ j, π j * after j) =
                ∑ j, (T * π j - π j * influence j) := by
                  apply Finset.sum_congr rfl
                  intro j _
                  rw [hafter j]
                  ring
            _ = T * (∑ j, π j) - ∑ j, π j * influence j := by
                  rw [Finset.sum_sub_distrib, Finset.mul_sum]
    _ = T - ∑ j, π j * influence j := by rw [hπ, mul_one]
    _ ≤ T - gain := sub_le_sub_left hgain T

/-- Iteration of a one-step contraction; suitable for unconditional
expectations of adaptive query-tree potentials. -/
theorem geometric_potential_decay
    (a : ℕ → ℝ) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hstep : ∀ t, a (t + 1) ≤ ρ * a t) :
    ∀ t, a t ≤ ρ ^ t * a 0 := by
  intro t
  induction t with
  | zero => simp
  | succ t ih =>
      calc
        a (t + 1) ≤ ρ * a t := hstep t
        _ ≤ ρ * (ρ ^ t * a 0) :=
          mul_le_mul_of_nonneg_left ih hρ
        _ = ρ ^ (t + 1) * a 0 := by rw [pow_succ]; ring


/-- Sharpness of the certificate-overlap sampler's information-only bound.
For ANY proposed coordinate-sampling probability law pi (mass one),
the abstract localized inequality admits a constant influence vector
saturating V^2 / (sum q)^2. The constructive sampler pi ∝ q obtains
that lower bound by weighted Cauchy. This does not assert realizability
of the adversarial vector by a Boolean product-space function. -/
theorem overlap_information_sharp
    {κ : Type*} [Fintype κ] (q π : κ → ℝ) (V : ℝ)
    (hS : 0 < ∑ j, q j) (hV : 0 ≤ V)
    (hπ : ∑ j, π j = 1) :
    ∃ c : κ → ℝ, (∀ j, 0 ≤ c j) ∧
      V = ∑ j, q j * Real.sqrt (c j) ∧
      (∑ j, π j * c j) = V ^ 2 / (∑ j, q j) ^ 2 := by
  let S : ℝ := ∑ j, q j
  let r : ℝ := V / S
  have hr : 0 ≤ r := div_nonneg hV hS.le
  have hsqrt : Real.sqrt (r ^ 2) = r := by
    rw [Real.sqrt_sq_eq_abs, abs_of_nonneg hr]
  have hsum : (∑ j, q j * r) = V := by
    rw [← Finset.sum_mul]
    change S * (V / S) = V
    rw [div_eq_mul_inv]
    calc
      S * (V * S⁻¹) = (S * S⁻¹) * V := by ring
      _ = V := by rw [mul_inv_cancel₀ hS.ne', one_mul]
  refine ⟨fun _ => r ^ 2, ?_, ?_, ?_⟩
  · intro j
    exact sq_nonneg r
  · simpa only [hsqrt] using hsum.symm
  · calc
      (∑ j, π j * r ^ 2) = (∑ j, π j) * r ^ 2 := by
        rw [Finset.sum_mul]
      _ = V ^ 2 / S ^ 2 := by
        rw [hπ, one_mul, div_pow]

end Nightfall.ProductSpace.Discovery


/-! ## Exact finite Bayesian posterior and adaptive Markov bridge

The Bayesian posterior acts on an arbitrary finite sample space. For a product
law the sample can be a pair of independent configurations, and `edge k x`
its coordinate-resampling crossing indicator. The posterior excludes the
already observed coordinate `j`. There is no ANOVA hypothesis in the
posterior decrement identity. -/

namespace Nightfall.ProductSpace.Posterior

open Finset

/-- Observable-class partition: the conditional numerator sums recover the
unconditional expectation. This identity has no measure normalization
assumption and is exact even for zero-mass states. -/
theorem finite_observation_partition
    {X A : Type*} [Fintype X] [Fintype A] [DecidableEq A]
    (observable : X → A) (F : X → ℝ) :
    (∑ a : A, ∑ x : X, if observable x = a then F x else 0) =
      ∑ x : X, F x := by
  classical
  calc
    (∑ a : A, ∑ x : X, if observable x = a then F x else 0) =
        ∑ x : X, ∑ a : A, if observable x = a then F x else 0 :=
          Finset.sum_comm
    _ = ∑ x : X, F x := by
          apply Finset.sum_congr rfl
          intro x _
          simp

/-- Posterior influence of a remaining coordinate under observation
`observable x=a`. The observed coordinate `j` is removed explicitly.
For normalized masses m with marginal p, the numerator/p a is the
ordinary conditional expectation of `edge k`. -/
noncomputable def posteriorEdge
    {X A J : Type*} [Fintype X] [Fintype A] [DecidableEq A]
    [DecidableEq J]
    (m : X → ℝ) (observable : X → A) (p : A → ℝ)
    (edge : J → X → ℝ) (j : J) (a : A) (k : J) : ℝ :=
  if k = j then 0 else
    (∑ x : X, if observable x = a then m x * edge k x else 0) / p a

/-- Exact posterior expectation of each remaining influence. -/
theorem posterior_edge_mean
    {X A J : Type*} [Fintype X] [Fintype A] [DecidableEq A]
    [DecidableEq J]
    (m : X → ℝ) (observable : X → A) (p : A → ℝ)
    (hp : ∀ a, 0 < p a) (edge : J → X → ℝ)
    (j k : J) :
    (∑ a : A, p a * posteriorEdge m observable p edge j a k) =
      if k = j then 0 else ∑ x : X, m x * edge k x := by
  classical
  by_cases hkj : k = j
  · simp [posteriorEdge, hkj]
  · simp only [posteriorEdge, if_neg hkj]
    calc
      (∑ a : A, p a *
        ((∑ x : X, if observable x = a then m x * edge k x else 0) / p a)) =
          ∑ a : A, ∑ x : X,
            if observable x = a then m x * edge k x else 0 := by
              apply Finset.sum_congr rfl
              intro a _
              field_simp [(hp a).ne']
      _ = ∑ x : X, m x * edge k x :=
        finite_observation_partition observable (fun x => m x * edge k x)

/-- Exact finite Bayesian decrement of *total* resampling influence.
No product structure or interaction-degree hypothesis is needed for this
identity. The sampler later chooses j using a certificate profile. -/
theorem posterior_total_mean
    {X A J : Type*} [Fintype X] [Fintype A] [Fintype J]
    [DecidableEq A] [DecidableEq J]
    (m : X → ℝ) (observable : X → A) (p : A → ℝ)
    (hp : ∀ a, 0 < p a) (edge : J → X → ℝ)
    (j : J) :
    (∑ a : A, p a * (∑ k : J, posteriorEdge m observable p edge j a k)) =
      (∑ k : J, ∑ x : X, m x * edge k x) -
        (∑ x : X, m x * edge j x) := by
  classical
  let c : J → ℝ := fun k => ∑ x : X, m x * edge k x
  calc
    (∑ a : A, p a * (∑ k : J, posteriorEdge m observable p edge j a k)) =
        ∑ k : J, ∑ a : A, p a * posteriorEdge m observable p edge j a k := by
          simp_rw [Finset.mul_sum]
          rw [Finset.sum_comm]
    _ = ∑ k : J, if k = j then 0 else c k := by
          apply Finset.sum_congr rfl
          intro k _
          exact posterior_edge_mean m observable p hp edge j k
    _ = (∑ k : J, c k) - c j := by
          have hh : ∀ k : J, (if k = j then (0 : ℝ) else c k) =
              c k - (if k = j then c k else 0) := by
                intro k
                by_cases h : k = j <;> simp [h]
          simp_rw [hh, Finset.sum_sub_distrib]
          simp
    _ = (∑ k : J, ∑ x : X, m x * edge k x) -
        (∑ x : X, m x * edge j x) := rfl

/-- Exact conditional mass on the event observable=a. -/
noncomputable def conditionalMass
    {X A : Type*} [DecidableEq A]
    (m : X → ℝ) (observable : X → A) (p : A → ℝ)
    (a : A) (x : X) : ℝ :=
  if observable x = a then m x / p a else 0

/-- Normalization of the actual posterior from a finite marginal. -/
theorem conditional_mass_one
    {X A : Type*} [Fintype X] [DecidableEq A]
    (m : X → ℝ) (observable : X → A) (p : A → ℝ)
    (a : A) (hp : 0 < p a)
    (hmargin : (∑ x : X, if observable x = a then m x else 0) = p a) :
    (∑ x : X, conditionalMass m observable p a x) = 1 := by
  classical
  have hdiv : (∑ x : X, conditionalMass m observable p a x) =
      (∑ x : X, if observable x = a then m x else 0) / p a := by
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro x _
    by_cases h : observable x = a <;>
      simp [conditionalMass, h]
  rw [hdiv, hmargin]
  exact div_self (hp.ne')

/-! ## A finite Markov kernel and adaptive expected-potential decay -/

/-- Push a finite distribution through a transition kernel. -/
noncomputable def push
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν : S → ℝ) (b : S) : ℝ :=
  ∑ a : S, ν a * P a b

/-- Expected state potential under a finite distribution. -/
def expectation
    {S : Type*} [Fintype S]
    (ν T : S → ℝ) : ℝ :=
  ∑ s : S, ν s * T s

/-- Exact Fubini identity for a randomized adaptive transition. -/
theorem push_expectation
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν T : S → ℝ) :
    expectation (push P ν) T =
      ∑ a : S, ν a * (∑ b : S, P a b * T b) := by
  calc
    expectation (push P ν) T =
        ∑ b : S, ∑ a : S, ν a * P a b * T b := by
          unfold expectation push
          apply Finset.sum_congr rfl
          intro b _
          rw [Finset.sum_mul]
    _ = ∑ a : S, ∑ b : S, ν a * P a b * T b := Finset.sum_comm
    _ = ∑ a : S, ν a * (∑ b : S, P a b * T b) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring

theorem push_nonneg
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν : S → ℝ)
    (hP : ∀ a b, 0 ≤ P a b)
    (hν : ∀ a, 0 ≤ ν a) :
    ∀ b, 0 ≤ push P ν b := by
  intro b
  unfold push
  exact Finset.sum_nonneg (fun a _ => mul_nonneg (hν a) (hP a b))

theorem push_mass_one
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν : S → ℝ)
    (hP : ∀ a, ∑ b : S, P a b = 1)
    (hν : ∑ a : S, ν a = 1) :
    (∑ b : S, push P ν b) = 1 := by
  calc
    (∑ b : S, push P ν b) =
        ∑ a : S, ν a * (∑ b : S, P a b) := by
          simpa only [expectation, mul_one] using
            (push_expectation P ν (fun _ => (1 : ℝ)))
    _ = ∑ a : S, ν a := by simp_rw [hP, mul_one]
    _ = 1 := hν

theorem push_potential_bound
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν T : S → ℝ) (ρ : ℝ)
    (hν : ∀ a, 0 ≤ ν a)
    (hstep : ∀ a, (∑ b : S, P a b * T b) ≤ ρ * T a) :
    expectation (push P ν) T ≤ ρ * expectation ν T := by
  calc
    expectation (push P ν) T =
        ∑ a : S, ν a * (∑ b : S, P a b * T b) :=
          push_expectation P ν T
    _ ≤ ∑ a : S, ν a * (ρ * T a) := by
          apply Finset.sum_le_sum
          intro a _
          exact mul_le_mul_of_nonneg_left (hstep a) (hν a)
    _ = ρ * expectation ν T := by
          unfold expectation
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          ring

/-- Recursive application of the same finite adaptive Markov kernel. -/
noncomputable def evolve
    {S : Type*} [Fintype S] (P : S → S → ℝ)
    (ν : S → ℝ) : ℕ → S → ℝ
  | 0 => ν
  | n + 1 => push P (evolve P ν n)

theorem evolve_nonneg
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν : S → ℝ)
    (hP : ∀ a b, 0 ≤ P a b)
    (hν : ∀ a, 0 ≤ ν a) :
    ∀ n a, 0 ≤ evolve P ν n a := by
  intro n
  induction n with
  | zero =>
      intro a
      exact hν a
  | succ n ih =>
      intro a
      exact push_nonneg P (evolve P ν n) hP ih a

/-- Fully generic finite-state adaptive process:
one-step drift plus nonnegative transition probabilities imply the complete
geometric expected-potential guarantee for every time horizon. -/
theorem adaptive_markov_decay
    {S : Type*} [Fintype S]
    (P : S → S → ℝ) (ν T : S → ℝ) (ρ : ℝ)
    (hρ : 0 ≤ ρ)
    (hP : ∀ a b, 0 ≤ P a b)
    (hν : ∀ a, 0 ≤ ν a)
    (hstep : ∀ a, (∑ b : S, P a b * T b) ≤ ρ * T a) :
    ∀ n, expectation (evolve P ν n) T ≤
      ρ ^ n * expectation ν T := by
  have hdec : ∀ n,
      expectation (evolve P ν (n + 1)) T ≤
      ρ * expectation (evolve P ν n) T := by
    intro n
    change expectation (push P (evolve P ν n)) T ≤
      ρ * expectation (evolve P ν n) T
    exact push_potential_bound P (evolve P ν n) T ρ
      (evolve_nonneg P ν hP hν n) hstep
  simpa only [evolve] using
    (Nightfall.ProductSpace.Discovery.geometric_potential_decay
      (fun n => expectation (evolve P ν n) T) ρ hρ hdec)

/-- General dimension-free posterior-to-adaptive drift theorem for a finite
query-response process. Premises separate the exact posterior identity,
the sampler gain, and the variance-vs-potential information budget. -/
theorem adaptive_query_contraction
    {S J A : Type*} [Fintype S] [Fintype J] [Fintype A]
    (T : S → ℝ) (π : S → J → ℝ) (p : S → J → A → ℝ)
    (after : S → J → A → ℝ) (I : S → J → ℝ)
    (gap : S → ℝ) (budget : ℝ)
    (hbudget : 0 < budget)
    (hπ : ∀ s, ∑ j : J, π s j = 1)
    (hp : ∀ s j, ∑ a : A, p s j a = 1)
    (hposterior : ∀ s j, (∑ a : A, p s j a * after s j a) = T s - I s j)
    (hsampler : ∀ s, gap s ≤ ∑ j : J, π s j * I s j)
    (hgap : ∀ s, T s / budget ≤ gap s) :
    ∀ s, (∑ j : J, π s j * (∑ a : A, p s j a * after s j a)) ≤
      (1 - 1 / budget) * T s := by
  intro s
  calc
    (∑ j : J, π s j * (∑ a : A, p s j a * after s j a)) =
        ∑ j : J, π s j * (T s - I s j) := by
          apply Finset.sum_congr rfl
          intro j _
          rw [hposterior s j]
    _ = T s - ∑ j : J, π s j * I s j := by
          calc
            (∑ j : J, π s j * (T s - I s j)) =
                ∑ j : J, (T s * π s j - π s j * I s j) := by
                  apply Finset.sum_congr rfl
                  intro j _
                  ring
            _ = T s * (∑ j : J, π s j) -
                ∑ j : J, π s j * I s j := by
                  rw [Finset.sum_sub_distrib, Finset.mul_sum]
            _ = T s - ∑ j : J, π s j * I s j := by
                  rw [hπ s, mul_one]
    _ ≤ T s - gap s := sub_le_sub_left (hsampler s) (T s)
    _ ≤ (1 - 1 / budget) * T s := by
          have h := hgap s
          apply le_trans (sub_le_sub_left h (T s))
          ring_nf
          rfl


/-! ## Concrete product-space instantiation of the certificate sampler -/

/-- The generic sampler has no unproved localization premise once specialized
to the actual positive finite product law, global certificate rows, and
the proved `localized_two_sided_product` theorem from PR #298.
All loads and influences are the original product-space definitions. -/
theorem concrete_product_overlap_sampler
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : Transfer.IsProductRow g lam)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (hV : 0 <
      (∑ x : {x : ι → α // g x = true},
        Transfer.prodMass p x.1 * invCost (lam x.1)) *
      (∑ y : {y : ι → α // g y = false},
        Transfer.prodMass p y.1 * invCost (lam y.1))) :
    let V1 : ℝ := ∑ x : {x : ι → α // g x = true},
      Transfer.prodMass p x.1 * invCost (lam x.1)
    let V0 : ℝ := ∑ y : {y : ι → α // g y = false},
      Transfer.prodMass p y.1 * invCost (lam y.1)
    let P : ι → ℝ := fun j =>
      ∑ x : {x : ι → α // g x = true},
        Transfer.prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j
    let Q : ι → ℝ := fun j =>
      ∑ y : {y : ι → α // g y = false},
        Transfer.prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j
    let c : ι → ℝ := fun j =>
      ∑ z, Transfer.pairMass p z * Transfer.edgeCross g j z
    let S : ℝ := ∑ j, Real.sqrt (P j * Q j)
    0 < S ∧ V1 * V0 ≤
      ∑ j, (Real.sqrt (P j * Q j) / S) * c j := by
  classical
  intro V1 V0 P Q c S
  have hpm : ∀ x, 0 ≤ Transfer.prodMass p x :=
    fun x => (Transfer.prodMass_pos p hp x).le
  have hc : ∀ j, 0 ≤ c j := by
    intro j
    change 0 ≤ ∑ z, Transfer.pairMass p z * Transfer.edgeCross g j z
    exact Finset.sum_nonneg fun z _ =>
      mul_nonneg
        (Transfer.pairMass_nonneg p (fun i a => (hp i a).le) z)
        (Transfer.edgeCross_nonneg g j z)
  have hP : ∀ j, 0 ≤ P j := by
    intro j
    change 0 ≤ ∑ x : {x : ι → α // g x = true},
      Transfer.prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j
    exact Finset.sum_nonneg fun x _ =>
      mul_nonneg
        (mul_nonneg (hpm x.1) (sq_nonneg _)) (hrow.1 x.1 j)
  have hQ : ∀ j, 0 ≤ Q j := by
    intro j
    change 0 ≤ ∑ y : {y : ι → α // g y = false},
      Transfer.prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j
    exact Finset.sum_nonneg fun y _ =>
      mul_nonneg
        (mul_nonneg (hpm y.1) (sq_nonneg _)) (hrow.1 y.1 j)
  have hPsum : (∑ j, P j) = V1 := by
    change
      (∑ j, ∑ x : {x : ι → α // g x = true},
        Transfer.prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j) =
      ∑ x : {x : ι → α // g x = true},
        Transfer.prodMass p x.1 * invCost (lam x.1)
    exact Transfer.mass_load_sum
      (fun x : {x : ι → α // g x = true} => Transfer.prodMass p x.1)
      (fun x j => lam x.1 j) (fun x => hnorm x.1)
  have hQsum : (∑ j, Q j) = V0 := by
    change
      (∑ j, ∑ y : {y : ι → α // g y = false},
        Transfer.prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j) =
      ∑ y : {y : ι → α // g y = false},
        Transfer.prodMass p y.1 * invCost (lam y.1)
    exact Transfer.mass_load_sum
      (fun y : {y : ι → α // g y = false} => Transfer.prodMass p y.1)
      (fun y j => lam y.1 j) (fun y => hnorm y.1)
  have hloc : V1 * V0 ≤
      ∑ j, Real.sqrt (c j) * Real.sqrt (P j * Q j) :=
    Transfer.localized_two_sided_product p hp g lam hrow
  have hV' : 0 < V1 * V0 := hV
  have hs := Discovery.certificate_overlap_sampler
    c P Q V1 V0 hc hP hQ hPsum hQsum hV' hloc
  exact ⟨hs.1, hs.2.2⟩

/-- The first genuinely *product-specific* posterior-to-selection bridge.
It uses the verified certificate sampler with no manual hloc input, and
the exact finite Bayesian posterior identity with the physical observable
`z ↦ z.1 j` and edge crossing `edgeCross g k z`.

The response value `a` is distributed with the original marginal
`p j a`; normalization of those marginals is assumed for its probabilistic
reading, but the finite-sum identity itself does not require it. -/
theorem concrete_product_one_step
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : Transfer.IsProductRow g lam)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (hV : 0 <
      (∑ x : {x : ι → α // g x = true},
        Transfer.prodMass p x.1 * invCost (lam x.1)) *
      (∑ y : {y : ι → α // g y = false},
        Transfer.prodMass p y.1 * invCost (lam y.1))) :
    let V1 : ℝ := ∑ x : {x : ι → α // g x = true},
      Transfer.prodMass p x.1 * invCost (lam x.1)
    let V0 : ℝ := ∑ y : {y : ι → α // g y = false},
      Transfer.prodMass p y.1 * invCost (lam y.1)
    let P : ι → ℝ := fun j =>
      ∑ x : {x : ι → α // g x = true},
        Transfer.prodMass p x.1 * invCost (lam x.1) ^ 2 * lam x.1 j
    let Q : ι → ℝ := fun j =>
      ∑ y : {y : ι → α // g y = false},
        Transfer.prodMass p y.1 * invCost (lam y.1) ^ 2 * lam y.1 j
    let S : ℝ := ∑ j, Real.sqrt (P j * Q j)
    let π : ι → ℝ := fun j => Real.sqrt (P j * Q j) / S
    let T : ℝ := ∑ k, ∑ z,
      Transfer.pairMass p z * Transfer.edgeCross g k z
    (∑ j, π j *
      (∑ a : α, p j a *
        (∑ k, posteriorEdge
          (Transfer.pairMass p)
          (fun z : Transfer.PairSample ι α => z.1 j)
          (p j) (Transfer.edgeCross g) j a k))) ≤
      T - V1 * V0 := by
  classical
  intro V1 V0 P Q S π T
  let c : ι → ℝ := fun j =>
    ∑ z, Transfer.pairMass p z * Transfer.edgeCross g j z
  have hsampler : 0 < S ∧ V1 * V0 ≤ ∑ j, π j * c j :=
    concrete_product_overlap_sampler p hp g lam hrow hnorm hV
  have hπsum : (∑ j, π j) = 1 := by
    change (∑ j, Real.sqrt (P j * Q j) / S) = 1
    rw [← Finset.sum_div]
    exact div_self hsampler.1.ne'
  have hpost : ∀ j, (∑ a : α, p j a *
      (∑ k, posteriorEdge
        (Transfer.pairMass p)
        (fun z : Transfer.PairSample ι α => z.1 j)
        (p j) (Transfer.edgeCross g) j a k)) =
        T - c j := by
    intro j
    exact posterior_total_mean
      (Transfer.pairMass p)
      (fun z : Transfer.PairSample ι α => z.1 j)
      (p j) (hp j) (Transfer.edgeCross g) j
  calc
    (∑ j, π j *
      (∑ a : α, p j a *
        (∑ k, posteriorEdge
          (Transfer.pairMass p)
          (fun z : Transfer.PairSample ι α => z.1 j)
          (p j) (Transfer.edgeCross g) j a k))) =
      ∑ j, π j * (T - c j) := by
        apply Finset.sum_congr rfl
        intro j _
        rw [hpost j]
    _ = T - ∑ j, π j * c j := by
          calc
            (∑ j, π j * (T - c j)) =
              ∑ j, (T * π j - π j * c j) := by
                apply Finset.sum_congr rfl
                intro j _
                ring
            _ = T * (∑ j, π j) - ∑ j, π j * c j := by
                  rw [Finset.sum_sub_distrib, Finset.mul_sum]
            _ = T - ∑ j, π j * c j := by
                  rw [hπsum, mul_one]
    _ ≤ T - V1 * V0 := sub_le_sub_left hsampler.2 T


/-! ## Actual adaptive query-transition kernel, not a hypothetical Markov P -/

/-- A query selects `j` by `π`, observes `a` with conditional law `p`,
and moves from state `s` to `next s j a`. Duplicate successor states are
combined exactly. -/
noncomputable def queryKernel
    {S J A : Type*} [Fintype J] [Fintype A] [DecidableEq S]
    (next : S → J → A → S) (π : S → J → ℝ)
    (p : S → J → A → ℝ) (s t : S) : ℝ :=
  ∑ u : J × A,
    if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0

/-- The query-response transition has no negative mass. -/
theorem query_kernel_nonneg
    {S J A : Type*} [Fintype J] [Fintype A] [DecidableEq S]
    (next : S → J → A → S) (π : S → J → ℝ)
    (p : S → J → A → ℝ)
    (hπ : ∀ s j, 0 ≤ π s j) (hp : ∀ s j a, 0 ≤ p s j a) :
    ∀ s t, 0 ≤ queryKernel next π p s t := by
  intro s t
  unfold queryKernel
  exact Finset.sum_nonneg (fun u _ => by
    by_cases h : next s u.1 u.2 = t
    · simp [h, mul_nonneg (hπ s u.1) (hp s u.1 u.2)]
    · simp [h])

/-- Normalization of the *constructed* query kernel. -/
theorem query_kernel_mass_one
    {S J A : Type*} [Fintype S] [Fintype J] [Fintype A]
    [DecidableEq S]
    (next : S → J → A → S) (π : S → J → ℝ)
    (p : S → J → A → ℝ)
    (hπ : ∀ s, ∑ j : J, π s j = 1)
    (hp : ∀ s j, ∑ a : A, p s j a = 1) :
    ∀ s, (∑ t : S, queryKernel next π p s t) = 1 := by
  intro s
  change (∑ t : S, ∑ u : J × A,
    if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0) = 1
  calc
    (∑ t : S, ∑ u : J × A,
      if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0) =
        ∑ u : J × A, π s u.1 * p s u.1 u.2 :=
          finite_observation_partition
            (fun u : J × A => next s u.1 u.2)
            (fun u : J × A => π s u.1 * p s u.1 u.2)
    _ = ∑ j : J, π s j * (∑ a : A, p s j a) := by
          rw [Fintype.sum_prod_type]
          apply Finset.sum_congr rfl
          intro j _
          rw [Finset.mul_sum]
    _ = ∑ j : J, π s j := by
          simp_rw [hp, mul_one]
    _ = 1 := hπ s

/-- Fubini and pushforward yield the exact expected successor potential
for the explicit stochastic query-and-response kernel. -/
theorem query_kernel_expected
    {S J A : Type*} [Fintype S] [Fintype J] [Fintype A]
    [DecidableEq S]
    (next : S → J → A → S) (π : S → J → ℝ)
    (p : S → J → A → ℝ) (T : S → ℝ) (s : S) :
    (∑ t : S, queryKernel next π p s t * T t) =
      ∑ j : J, π s j * (∑ a : A, p s j a * T (next s j a)) := by
  classical
  change
    (∑ t : S, (∑ u : J × A,
      if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0) * T t) =
      ∑ j : J, π s j * (∑ a : A, p s j a * T (next s j a))
  calc
    (∑ t : S, (∑ u : J × A,
      if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0) * T t) =
      ∑ t : S, ∑ u : J × A,
        (if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0) * T t := by
          apply Finset.sum_congr rfl
          intro t _
          rw [Finset.sum_mul]
    _ = ∑ u : J × A, ∑ t : S,
        (if next s u.1 u.2 = t then π s u.1 * p s u.1 u.2 else 0) * T t :=
          Finset.sum_comm
    _ = ∑ u : J × A,
        π s u.1 * p s u.1 u.2 * T (next s u.1 u.2) := by
          apply Finset.sum_congr rfl
          intro u _
          have hh : (∑ t : S,
              (if next s u.1 u.2 = t then
                π s u.1 * p s u.1 u.2 else 0) * T t) =
              ∑ t : S, if next s u.1 u.2 = t then
                π s u.1 * p s u.1 u.2 * T t else 0 := by
                  apply Finset.sum_congr rfl
                  intro t _
                  split_ifs <;> simp
          rw [hh]
          simp
    _ = ∑ j : J, ∑ a : A,
        π s j * p s j a * T (next s j a) := by
          rw [Fintype.sum_prod_type]
    _ = ∑ j : J, π s j * (∑ a : A, p s j a * T (next s j a)) := by
          apply Finset.sum_congr rfl
          intro j _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          ring

/-- **Full finite-state adaptive recursion, with the transition kernel
constructed from coordinate-selection and response probabilities.**

The posterior identity, sampler gain, and uniform budget are supplied
per state; the theorem *derives* the full time-t expectation, rather
than assuming a Markov drift or an `evolve` bound.

Product-specific discharge of per-state certificate rows and degree/variance
budgets is the remaining interface to arbitrary-product probability theory. -/
theorem certificate_guided_adaptive_decay
    {S J A : Type*} [Fintype S] [Fintype J] [Fintype A]
    [DecidableEq S]
    (next : S → J → A → S)
    (T : S → ℝ) (π : S → J → ℝ) (p : S → J → A → ℝ)
    (I : S → J → ℝ) (gap : S → ℝ)
    (budget : ℝ) (hbudget : 1 ≤ budget)
    (hπ_nonneg : ∀ s j, 0 ≤ π s j)
    (hp_nonneg : ∀ s j a, 0 ≤ p s j a)
    (hπ : ∀ s, ∑ j : J, π s j = 1)
    (hp : ∀ s j, ∑ a : A, p s j a = 1)
    (hposterior : ∀ s j,
      (∑ a : A, p s j a * T (next s j a)) = T s - I s j)
    (hsampler : ∀ s, gap s ≤ ∑ j : J, π s j * I s j)
    (hgap : ∀ s, T s / budget ≤ gap s)
    (ν : S → ℝ) (hν : ∀ s, 0 ≤ ν s) :
    ∀ n, expectation (evolve (queryKernel next π p) ν n) T ≤
      (1 - 1 / budget) ^ n * expectation ν T := by
  have hbudget_pos : 0 < budget := lt_of_lt_of_le (by norm_num) hbudget
  have hρ : 0 ≤ (1 : ℝ) - 1 / budget := by
    have hh : (1 : ℝ) / budget ≤ 1 :=
      (div_le_iff₀ hbudget_pos).mpr (by nlinarith [hbudget])
    linarith
  have hstep0 := adaptive_query_contraction T π p
    (fun s j a => T (next s j a)) I gap budget
    hbudget_pos hπ hp hposterior hsampler hgap
  have hstep : ∀ s,
      (∑ t : S, queryKernel next π p s t * T t) ≤
        (1 - 1 / budget) * T s := by
    intro s
    rw [query_kernel_expected]
    exact hstep0 s
  exact adaptive_markov_decay
    (queryKernel next π p) ν T (1 - 1 / budget)
    hρ (query_kernel_nonneg next π p hπ_nonneg hp_nonneg)
    hν hstep



/-! ## Certificate inheritance under arbitrary partial observations -/

/-- Pin every coordinate previously observed in the finite assignment `s`. -/
def pinConfiguration
    {ι α : Type} (s : ι → Option α) (x : ι → α) : ι → α :=
  fun i => (s i).getD (x i)

/-- Boolean output after applying the partial observation assignment. -/
def restrictedOutput
    {ι α : Type} (s : ι → Option α)
    (g : (ι → α) → Bool) (x : ι → α) : Bool :=
  g (pinConfiguration s x)

/-- The original fractional-certificate row restricted to unobserved
coordinates; all pinned-coordinate loads become exactly zero. -/
def restrictedRow
    {ι α : Type} [DecidableEq α]
    (s : ι → Option α) (lam : (ι → α) → ι → ℝ)
    (x : ι → α) (j : ι) : ℝ :=
  if s j = none then lam (pinConfiguration s x) j else 0

/-- Pinning can only remove disagreements. -/
theorem pin_disagree_subset
    {ι α : Type} [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (s : ι → Option α) (x y : ι → α) :
    Transfer.disagree (pinConfiguration s x) (pinConfiguration s y) ⊆
      Transfer.disagree x y := by
  intro j hj
  have hneq : pinConfiguration s x j ≠ pinConfiguration s y j :=
    (Finset.mem_filter.mp hj).2
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ j, ?_⟩
  intro hxy
  apply hneq
  unfold pinConfiguration
  cases h : s j with
  | none => simp [h, hxy]
  | some a => simp [h]

/-- Every original product-space fractional certificate remains valid for
the restricted function, with the observed coordinates deleted. -/
theorem restricted_row_is_product_row
    {ι α : Type} [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (s : ι → Option α)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : Transfer.IsProductRow g lam) :
    Transfer.IsProductRow (restrictedOutput s g) (restrictedRow s lam) := by
  constructor
  · intro x j
    by_cases hj : s j = none
    · simpa [restrictedRow, hj] using hrow.1 (pinConfiguration s x) j
    · simp [restrictedRow, hj]
  · intro x y hxy
    have hcontrast :
        g (pinConfiguration s y) ≠ g (pinConfiguration s x) := hxy
    have hsub := pin_disagree_subset s x y
    have hterm : ∀ j ∈
        Transfer.disagree (pinConfiguration s x) (pinConfiguration s y),
        restrictedRow s lam x j = lam (pinConfiguration s x) j := by
      intro j hj
      have hneq : pinConfiguration s x j ≠ pinConfiguration s y j :=
        (Finset.mem_filter.mp hj).2
      cases h : s j with
      | none => simp [restrictedRow, h]
      | some a =>
          have heq : pinConfiguration s x j = pinConfiguration s y j := by
            simp [pinConfiguration, h]
          exact False.elim (hneq heq)
    calc
      (1 : ℝ) ≤
        ∑ j ∈ Transfer.disagree (pinConfiguration s x) (pinConfiguration s y),
          lam (pinConfiguration s x) j :=
            hrow.2 (pinConfiguration s x) (pinConfiguration s y) hcontrast
      _ = ∑ j ∈ Transfer.disagree (pinConfiguration s x) (pinConfiguration s y),
          restrictedRow s lam x j := by
            apply Finset.sum_congr rfl
            intro j hj
            exact (hterm j hj).symm
      _ ≤ ∑ j ∈ Transfer.disagree x y, restrictedRow s lam x j :=
          Finset.sum_le_sum_of_subset_of_nonneg hsub
            (fun j _ _ => by
              by_cases hj : s j = none
              · simpa [restrictedRow, hj] using
                  hrow.1 (pinConfiguration s x) j
              · simp [restrictedRow, hj])

/-- Observing more coordinates never increases any restricted row's
ℓ₁ cost, even before optimizing the certificates. -/
theorem restricted_row_cost_le
    {ι α : Type} [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (s : ι → Option α)
    (lam : (ι → α) → ι → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (x : ι → α) :
    (∑ j, restrictedRow s lam x j) ≤
      ∑ j, lam (pinConfiguration s x) j := by
  apply Finset.sum_le_sum
  intro j _
  by_cases hj : s j = none
  · simp [restrictedRow, hj]
  · simpa [restrictedRow, hj] using
      (hlam (pinConfiguration s x) j)

/-- Update an unobserved coordinate to the revealed symbol. -/
def observeCoordinate
    {ι α : Type} [DecidableEq ι]
    (s : ι → Option α) (j : ι) (a : α) : ι → Option α :=
  Function.update s j (some a)

/-- For a previously unobserved coordinate, conditioning the restricted
function is exactly the restriction associated with the updated state. -/
theorem pin_observe_eq
    {ι α : Type} [DecidableEq ι]
    (s : ι → Option α) (j : ι) (a : α) (x : ι → α)
    (hfree : s j = none) :
    pinConfiguration (observeCoordinate s j a) x =
      pinConfiguration s (Function.update x j a) := by
  funext k
  by_cases hk : k = j
  · subst k
    simp [pinConfiguration, observeCoordinate, hfree]
  · simp [pinConfiguration, observeCoordinate, Function.update, hk]

theorem restricted_output_observe
    {ι α : Type} [DecidableEq ι]
    (s : ι → Option α) (j : ι) (a : α)
    (g : (ι → α) → Bool) (x : ι → α)
    (hfree : s j = none) :
    restrictedOutput (observeCoordinate s j a) g x =
      restrictedOutput s g (Function.update x j a) := by
  exact congrArg g (pin_observe_eq s j a x hfree)



/-! ## Interaction-degree invariance of partial evaluation -/

/-- A finite-coordinate function depends only on `S` if agreement on `S`
forces its outputs to agree. -/
def DependsOnlyOn
    {ι α : Type} (f : (ι → α) → ℝ) (S : Finset ι) : Prop :=
  ∀ x y, (∀ j, j ∈ S → x j = y j) → f x = f y

/-- Finite interaction degree is represented by a sum of terms supported on
at most `d` coordinates. For finite products with full support, this agrees
with the vanishing of high-order Hoeffding components. -/
def HasInteractionDegreeAtMost
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∃ terms : Finset ι → (ι → α) → ℝ,
    (∀ x, f x = ∑ S : Finset ι, terms S x) ∧
    (∀ S, d < S.card → ∀ x, terms S x = 0) ∧
    (∀ S, DependsOnlyOn (terms S) S)

/-- Partial observation never creates interactions of higher degree,
regardless of atom weights or alphabet cardinality. -/
theorem interaction_degree_under_pinning
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    (f : (ι → α) → ℝ) (d : ℕ)
    (hdegree : HasInteractionDegreeAtMost f d)
    (s : ι → Option α) :
    HasInteractionDegreeAtMost
      (fun x => f (pinConfiguration s x)) d := by
  rcases hdegree with ⟨terms, hsum, hhigh, hdepends⟩
  refine ⟨(fun S x => terms S (pinConfiguration s x)), ?_, ?_, ?_⟩
  · intro x
    exact hsum (pinConfiguration s x)
  · intro S hcard x
    exact hhigh S hcard (pinConfiguration s x)
  · intro S x y hxy
    apply hdepends S (pinConfiguration s x) (pinConfiguration s y)
    intro j hj
    cases hs : s j with
    | none =>
        simpa [pinConfiguration, hs] using hxy j hj
    | some a =>
        simp [pinConfiguration, hs]

/-- The degree/variance ANOVA budget, abstracted to nonnegative component
energies. To use it for a specific product law, additionally establish the
Hoeffding energy identity for that function and measure. -/
theorem anova_degree_energy_budget
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (energy : Finset ι → ℝ) (d : ℕ)
    (henergy : ∀ S, 0 ≤ energy S)
    (hdegree : ∀ S, d < S.card → energy S = 0) :
    (∑ S : Finset ι, (S.card : ℝ) * energy S) ≤
      (d : ℝ) * (∑ S : Finset ι,
        if S = ∅ then (0 : ℝ) else energy S) := by
  calc
    (∑ S : Finset ι, (S.card : ℝ) * energy S) ≤
        ∑ S : Finset ι,
          (d : ℝ) * (if S = ∅ then (0 : ℝ) else energy S) := by
            apply Finset.sum_le_sum
            intro S _
            by_cases he : S = ∅
            · subst S
              simp
            · by_cases hc : S.card ≤ d
              · have hle : (S.card : ℝ) ≤ (d : ℝ) := by
                  exact_mod_cast hc
                simpa [he] using
                  mul_le_mul_of_nonneg_right hle (henergy S)
              · have hz : energy S = 0 :=
                  hdegree S (Nat.lt_of_not_ge hc)
                simp [he, hz]
    _ = (d : ℝ) * (∑ S : Finset ι,
          if S = ∅ then (0 : ℝ) else energy S) := by
            rw [Finset.mul_sum]



/-- An exact "uncertainty principle" for opposing certificate profiles.
The sharp sampling inequality, certificate-cost domination, and a degree
energy bound force a nontrivial overlap, independent of dimension.
Here `S²/V` is the squared Bhattacharyya overlap of the two load laws.
All three inputs are explicit so mathematical scope travels with the claim. -/
theorem certificate_overlap_necessary
    (V S T variance K degree : ℝ)
    (hV : 0 < V) (hK : 0 < K) (hd : 0 < degree)
    (hsharp : V ^ 2 ≤ S ^ 2 * T)
    (hcost : variance ≤ K ^ 2 * V)
    (hdegree : T ≤ degree * variance) :
    1 / (degree * K ^ 2) ≤ S ^ 2 / V := by
  have hDK : 0 < degree * K ^ 2 :=
    mul_pos hd (sq_pos_of_pos hK)
  have hchain : V ^ 2 ≤ (degree * K ^ 2 * S ^ 2) * V := by
    calc
      V ^ 2 ≤ S ^ 2 * T := hsharp
      _ ≤ S ^ 2 * (degree * variance) :=
        mul_le_mul_of_nonneg_left hdegree (sq_nonneg S)
      _ ≤ S ^ 2 * (degree * (K ^ 2 * V)) := by
        exact mul_le_mul_of_nonneg_left
          (mul_le_mul_of_nonneg_left hcost hd.le) (sq_nonneg S)
      _ = (degree * K ^ 2 * S ^ 2) * V := by ring
  have hVle : V ≤ degree * K ^ 2 * S ^ 2 := by
    apply (mul_le_mul_iff_of_pos_right hV).mp
    nlinarith [hchain]
  apply (div_le_div_iff₀ hDK hV).mpr
  nlinarith [hVle]



/-! ## Product-law normalization for the posterior probabilistic reading -/

/-- A finite product of normalized coordinate masses has total mass one. -/
theorem product_mass_normalized
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ)
    (hnorm : ∀ i, (∑ a : α, p i a) = 1) :
    (∑ x : ι → α, Transfer.prodMass p x) = 1 := by
  classical
  have hsum : (∑ x : ι → α, Transfer.prodMass p x) =
      ∏ i, ∑ a : α, p i a := by
    simpa [Transfer.prodMass] using
      (Finset.sum_prod_piFinset (s := (Finset.univ : Finset α)) (g := p))
  calc
    (∑ x : ι → α, Transfer.prodMass p x) =
      ∏ i, ∑ a : α, p i a := hsum
    _ = 1 := by simp [hnorm]

/-- Two independent draws have total joint product mass one, an explicit
normalization obligation for regarding `posteriorEdge` as a conditional
probability rather than merely a ratio of finite sums. -/
theorem pair_mass_normalized
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ)
    (hnorm : ∀ i, (∑ a : α, p i a) = 1) :
    (∑ z : Transfer.PairSample ι α, Transfer.pairMass p z) = 1 := by
  classical
  calc
    (∑ z : Transfer.PairSample ι α, Transfer.pairMass p z) =
        ∑ x : ι → α, ∑ y : ι → α,
          Transfer.prodMass p x * Transfer.prodMass p y := by
            rw [Fintype.sum_prod_type]
            apply Finset.sum_congr rfl
            intro x _
            apply Finset.sum_congr rfl
            intro y _
            exact Transfer.pairMass_eq_prodMass p (x, y)
    _ = ∑ x : ι → α, Transfer.prodMass p x *
          (∑ y : ι → α, Transfer.prodMass p y) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
    _ = (∑ x : ι → α, Transfer.prodMass p x) *
          (∑ y : ι → α, Transfer.prodMass p y) := by
            rw [Finset.sum_mul]
    _ = 1 := by
          simp [product_mass_normalized p hnorm]



/-- The observed coordinate's marginal of a normalized finite product law
is *exactly* its given symbol weight. This supplies the Bayesian normalization
premise rather than merely assuming it. -/
theorem single_product_marginal
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ)
    (hnorm : ∀ i, (∑ b : α, p i b) = 1)
    (j : ι) (a : α) :
    (∑ x : ι → α,
      if x j = a then Transfer.prodMass p x else 0) = p j a := by
  classical
  let q : ι → α → ℝ := fun i b =>
    if i = j then (if b = a then p i b else 0) else p i b
  have hterm : ∀ x : ι → α, Transfer.prodMass q x =
      if x j = a then Transfer.prodMass p x else 0 := by
    intro x
    by_cases hx : x j = a
    · have heq : ∀ i, q i (x i) = p i (x i) := by
        intro i
        by_cases hij : i = j
        · subst i
          simp [q, hx]
        · simp [q, hij]
      change (∏ i, q i (x i)) =
        if x j = a then (∏ i, p i (x i)) else 0
      rw [if_pos hx]
      exact Finset.prod_congr rfl (fun i _ => heq i)
    · have hz : q j (x j) = 0 := by
        simp [q, hx]
      have hprod : (∏ i, q i (x i)) = 0 :=
        Finset.prod_eq_zero (Finset.mem_univ j) hz
      change (∏ i, q i (x i)) =
        if x j = a then (∏ i, p i (x i)) else 0
      rw [if_neg hx]
      exact hprod
  have hqsum : ∀ i, (∑ b : α, q i b) =
      if i = j then p j a else 1 := by
    intro i
    by_cases hij : i = j
    · subst i
      simp [q]
    · simp [q, hij, hnorm i]
  have hprod : (∏ i, ∑ b : α, q i b) = p j a := by
    calc
      (∏ i, ∑ b : α, q i b) =
          ∏ i, if i = j then p j a else (1 : ℝ) := by
            apply Finset.prod_congr rfl
            intro i _
            exact hqsum i
      _ = p j a := by simp
  calc
    (∑ x : ι → α,
      if x j = a then Transfer.prodMass p x else 0) =
        ∑ x : ι → α, Transfer.prodMass q x := by
          apply Finset.sum_congr rfl
          intro x _
          exact (hterm x).symm
    _ = ∏ i, ∑ b : α, q i b := by
          simpa [Transfer.prodMass] using
            (Finset.sum_prod_piFinset
              (s := (Finset.univ : Finset α)) (g := q))
    _ = p j a := hprod

/-- The observed first-coordinate value of an independent pair has exactly
its specified marginal. The pair posterior numerator therefore normalizes
to one using `conditional_mass_one` with no extra assumption. -/
theorem pair_first_marginal
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ)
    (hnorm : ∀ i, (∑ b : α, p i b) = 1)
    (j : ι) (a : α) :
    (∑ z : Transfer.PairSample ι α,
      if z.1 j = a then Transfer.pairMass p z else 0) = p j a := by
  classical
  calc
    (∑ z : Transfer.PairSample ι α,
      if z.1 j = a then Transfer.pairMass p z else 0) =
      ∑ x : ι → α, ∑ y : ι → α,
        if x j = a then
          Transfer.prodMass p x * Transfer.prodMass p y else 0 := by
          rw [Fintype.sum_prod_type]
          apply Finset.sum_congr rfl
          intro x _
          apply Finset.sum_congr rfl
          intro y _
          by_cases hx : x j = a
          · simp [hx, Transfer.pairMass_eq_prodMass]
          · simp [hx]
    _ = ∑ x : ι → α,
          (if x j = a then Transfer.prodMass p x else 0) *
          (∑ y : ι → α, Transfer.prodMass p y) := by
          apply Finset.sum_congr rfl
          intro x _
          by_cases hx : x j = a
          · simp [hx, Finset.mul_sum]
          · simp [hx]
    _ = (∑ x : ι → α, if x j = a then Transfer.prodMass p x else 0) *
          (∑ y : ι → α, Transfer.prodMass p y) := by
          rw [Finset.sum_mul]
    _ = p j a := by
          rw [single_product_marginal p hnorm j a,
            product_mass_normalized p hnorm]
          ring



/-- The posterior influence numerator really is an expectation under the
explicitly conditioned finite mass, not an arbitrary reciprocal expression. -/
theorem posterior_edge_is_conditional_expectation
    {X A J : Type*} [Fintype X] [DecidableEq A] [DecidableEq J]
    (m : X → ℝ) (observable : X → A) (p : A → ℝ)
    (edge : J → X → ℝ) (j : J) (a : A) (k : J) :
    posteriorEdge m observable p edge j a k =
      if k = j then 0 else
        ∑ x : X, conditionalMass m observable p a x * edge k x := by
  classical
  by_cases hk : k = j
  · simp [posteriorEdge, hk]
  · simp only [posteriorEdge, if_neg hk]
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro x _
    by_cases hx : observable x = a
    · simp [conditionalMass, hx, div_eq_mul_inv]
      ring
    · simp [conditionalMass, hx]

/-- For independent normalized draws, conditioning on the observed symbol
of the first draw produces a bona fide probability measure on the pair. -/
theorem concrete_pair_posterior_is_probability
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 < p i a)
    (hnorm : ∀ i, (∑ b : α, p i b) = 1)
    (j : ι) (a : α) :
    (∑ z : Transfer.PairSample ι α,
      conditionalMass (Transfer.pairMass p)
        (fun z : Transfer.PairSample ι α => z.1 j)
        (p j) a z) = 1 := by
  exact conditional_mass_one
    (Transfer.pairMass p)
    (fun z : Transfer.PairSample ι α => z.1 j)
    (p j) a (hp j a) (pair_first_marginal p hnorm j a)



/-! ## Degree-free certificate-overlap rigidity (stronger than d-dependent bound) -/

/-- A single coordinate's ANOVA energy cannot exceed total nonconstant
variance energy. The low-degree assumption is unnecessary for this fact. -/
theorem anova_coordinate_energy_le_variance
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (energy : Finset ι → ℝ) (j : ι)
    (henergy : ∀ S, 0 ≤ energy S) :
    (∑ S : Finset ι, if j ∈ S then energy S else 0) ≤
      ∑ S : Finset ι, if S = ∅ then (0 : ℝ) else energy S := by
  apply Finset.sum_le_sum
  intro S _
  by_cases hj : j ∈ S
  · have hne : S ≠ ∅ := by
      intro he
      subst S
      simpa using hj
    simp [hj, hne]
  · by_cases he : S = ∅
    · simp [hj, he]
    · simpa [hj, he] using henergy S

/-- **Dimension- and degree-free overlap rigidity.** Let V=V1*V0>0 and
S=sum sqrt(P_j Q_j), so S²/V is the squared Bhattacharyya overlap.
The sharp sampler bound and maximal single-coordinate influence ≤ variance,
together with bounded certificate cost K, imply B²≥K⁻².
Unlike `certificate_overlap_necessary`, no degree budget appears.

The hypotheses are kept explicit because the function-to-ANOVA identity
and the row-cost-to-variance inequality have their own proof obligations. -/
theorem certificate_overlap_degree_free
    (V S variance K : ℝ)
    (hV : 0 < V) (hVar : 0 < variance) (hK : 0 < K)
    (hsharp : V ^ 2 ≤ S ^ 2 * variance)
    (hcost : variance ≤ K ^ 2 * V) :
    1 / K ^ 2 ≤ S ^ 2 / V := by
  have hK2 : 0 < K ^ 2 := sq_pos_of_pos hK
  have hchain : V ^ 2 ≤ (K ^ 2 * S ^ 2) * V := by
    calc
      V ^ 2 ≤ S ^ 2 * variance := hsharp
      _ ≤ S ^ 2 * (K ^ 2 * V) :=
        mul_le_mul_of_nonneg_left hcost (sq_nonneg S)
      _ = (K ^ 2 * S ^ 2) * V := by ring
  have hVle : V ≤ K ^ 2 * S ^ 2 := by
    apply (mul_le_mul_iff_of_pos_right hV).mp
    nlinarith [hchain]
  apply (div_le_div_iff₀ hK2 hV).mpr
  nlinarith [hVle]


end Nightfall.ProductSpace.Posterior

