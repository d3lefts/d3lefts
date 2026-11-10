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
