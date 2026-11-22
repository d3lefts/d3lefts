import ProductBUMixedRadius

/-!
# Scale-free genuine-prefix product-sphere transfer

Author-side formal continuation. The original topology hypothesis
'ProductSphereZero n r s' is explicitly an input, NEVER proved here.

Instead of rescaling a sensing policy on potentially unreachable histories,
precompose the actual genuine-prefix test maps with signal dilation.
This preserves continuity by composition with a continuous linear map and
preserves the two independent antipodal sign characters exactly.
The resulting witness uses the ORIGINAL physical oracle.

This module also transfers quantitative collision geometry to an arbitrary
Euclidean radius and supplies a decoder-independent squared-risk floor.
No full product-sphere Borsuk–Ulam theorem or novelty is claimed.
-/

open scoped BigOperators

namespace Nightfall.ProductBUScaledPrefix

open Nightfall.ProductSphereObstruction
open Nightfall.ProductSphereCausal
open Nightfall.ProductBUQuantitativeCollision
open Nightfall.ProductBUDecoderRiskFloor
open Nightfall.GenuinePrefixPhase

def scaledTestU {n : ℕ} (a : CausalRows n) (λ : ℝ) (r : ℕ)
    (u v : Signal n) (i : Fin r) : ℝ :=
  testU a r (λ • u) (λ • v) i

def scaledTestV {n : ℕ} (a : CausalRows n) (λ : ℝ) (r s : ℕ)
    (u v : Signal n) (i : Fin s) : ℝ :=
  testV a r s (λ • u) (λ • v) i

theorem continuous_scaledTestU {n r : ℕ}
    (a : CausalRows n) (ha : ReachableContinuous a)
    (λ : ℝ) (i : Fin r) :
    Continuous (fun p : (Signal n) × (Signal n) =>
      scaledTestU a λ r p.1 p.2 i) := by
  have hs : Continuous (fun p : (Signal n) × (Signal n) =>
      ((λ • p.1), (λ • p.2))) := by fun_prop
  simpa only [Function.comp_def, scaledTestU] using
    (continuous_testU a ha i).comp hs

theorem continuous_scaledTestV {n r s : ℕ}
    (a : CausalRows n) (ha : ReachableContinuous a)
    (λ : ℝ) (i : Fin s) :
    Continuous (fun p : (Signal n) × (Signal n) =>
      scaledTestV a λ r s p.1 p.2 i) := by
  have hs : Continuous (fun p : (Signal n) × (Signal n) =>
      ((λ • p.1), (λ • p.2))) := by fun_prop
  simpa only [Function.comp_def, scaledTestV] using
    (continuous_testV a ha i).comp hs

theorem scaledTestU_flip_left {n r : ℕ} (a : CausalRows n)
    (λ : ℝ) (u v : Signal n) (i : Fin r) :
    scaledTestU a λ r (-u) v i = -scaledTestU a λ r u v i := by
  simpa only [scaledTestU, smul_neg] using
    testU_flip_left a (λ • u) (λ • v) i

theorem scaledTestU_flip_right {n r : ℕ} (a : CausalRows n)
    (λ : ℝ) (u v : Signal n) (i : Fin r) :
    scaledTestU a λ r u (-v) i = scaledTestU a λ r u v i := by
  simpa only [scaledTestU, smul_neg] using
    testU_flip_right a (λ • u) (λ • v) i

theorem scaledTestV_flip_left {n r s : ℕ} (a : CausalRows n)
    (λ : ℝ) (u v : Signal n) (i : Fin s) :
    scaledTestV a λ r s (-u) v i = scaledTestV a λ r s u v i := by
  simpa only [scaledTestV, smul_neg] using
    testV_flip_left a (λ • u) (λ • v) i

theorem scaledTestV_flip_right {n r s : ℕ} (a : CausalRows n)
    (λ : ℝ) (u v : Signal n) (i : Fin s) :
    scaledTestV a λ r s u (-v) i = -scaledTestV a λ r s u v i := by
  simpa only [scaledTestV, smul_neg] using
    testV_flip_right a (λ • u) (λ • v) i

/-- Direct signal-dilation transfer: no inverse protocol and no continuity
assumption outside actual attainable histories. ProductSphereZero is an
EXPLICIT topological premise of this theorem. -/
theorem scaled_causal_collision_of_product_sphere_zero
    (n r s : ℕ) (a : CausalRows n) (ha : ReachableContinuous a)
    (hBU : ProductSphereZero n r s) (λ : ℝ) :
    ∃ u v : Signal n, UnitVec n u ∧ UnitVec n v ∧
      transcript (amp a) (r + s) ((λ • u) + (λ • v)) =
      transcript (amp a) (r + s) ((λ • u) - (λ • v)) := by
  obtain ⟨u, v, hu, hv, hU, hV⟩ :=
    hBU (scaledTestU a λ r) (scaledTestV a λ r s)
      (fun i => (continuous_scaledTestU a ha λ i).continuousOn)
      (fun i => (continuous_scaledTestV a ha λ i).continuousOn)
      (fun u v i _ _ => scaledTestU_flip_left a λ u v i)
      (fun u v i _ _ => scaledTestU_flip_right a λ u v i)
      (fun u v i _ _ => scaledTestV_flip_left a λ u v i)
      (fun u v i _ _ => scaledTestV_flip_right a λ u v i)
  have hz : ∀ j < r + s,
      comparison (amp a) j (λ • u) (λ • v) (λ • u) = 0 ∨
      comparison (amp a) j (λ • u) (λ • v) (λ • v) = 0 := by
    intro j hj
    by_cases h : j < r
    · left
      simpa [scaledTestU, testU] using hU ⟨j, h⟩
    · right
      have hs : j - r < s := by omega
      have hr : r + (j - r) = j := by omega
      simpa [scaledTestV, testV, hr] using hV ⟨j - r, hs⟩
  have heq :=
    causal_collision_of_genuine_prefix_zeros
      (amp a) (amp_add a) (amp_sub a) (λ • u) (λ • v) (r + s) hz
  exact ⟨u, v, hu, hv, heq⟩

theorem sqNorm_smul (n : ℕ) (λ : ℝ) (x : Signal n) :
    sqNorm n (λ • x) = λ ^ 2 * sqNorm n x := by
  unfold sqNorm
  simp only [Pi.smul_apply, smul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem unit_sqNorm_add_le_four (n : ℕ) (u v : Signal n)
    (hu : UnitVec n u) (hv : UnitVec n v) :
    sqNorm n (u + v) ≤ 4 := by
  change (∑ i : Fin n, (u i + v i) ^ 2) ≤ 4
  change (∑ i : Fin n, (u i) ^ 2) = 1 at hu
  change (∑ i : Fin n, (v i) ^ 2) = 1 at hv
  have hi (i : Fin n) :
      (u i + v i) ^ 2 ≤ 2 * (u i) ^ 2 + 2 * (v i) ^ 2 := by
    nlinarith [sq_nonneg (u i - v i)]
  calc
    (∑ i : Fin n, (u i + v i) ^ 2) ≤
        ∑ i : Fin n, (2 * (u i) ^ 2 + 2 * (v i) ^ 2) :=
      Finset.sum_le_sum (fun i _ => hi i)
    _ = 2 * (∑ i : Fin n, (u i) ^ 2) +
        2 * (∑ i : Fin n, (v i) ^ 2) := by
      simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    _ = 4 := by rw [hu, hv]; norm_num

theorem unit_sqNorm_sub_le_four (n : ℕ) (u v : Signal n)
    (hu : UnitVec n u) (hv : UnitVec n v) :
    sqNorm n (u - v) ≤ 4 := by
  change (∑ i : Fin n, (u i - v i) ^ 2) ≤ 4
  change (∑ i : Fin n, (u i) ^ 2) = 1 at hu
  change (∑ i : Fin n, (v i) ^ 2) = 1 at hv
  have hi (i : Fin n) :
      (u i - v i) ^ 2 ≤ 2 * (u i) ^ 2 + 2 * (v i) ^ 2 := by
    nlinarith [sq_nonneg (u i + v i)]
  calc
    (∑ i : Fin n, (u i - v i) ^ 2) ≤
        ∑ i : Fin n, (2 * (u i) ^ 2 + 2 * (v i) ^ 2) :=
      Finset.sum_le_sum (fun i _ => hi i)
    _ = 2 * (∑ i : Fin n, (u i) ^ 2) +
        2 * (∑ i : Fin n, (v i) ^ 2) := by
      simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    _ = 4 := by rw [hu, hv]; norm_num

/-- Collision anywhere in the physical R-ball, squared sign separation R².
Unlike rescaled-policy arguments this uses the original row policy. -/
theorem ball_collision_of_product_sphere_zero
    (n r s : ℕ) (a : CausalRows n) (ha : ReachableContinuous a)
    (hBU : ProductSphereZero n r s) (R : ℝ) (hR : 0 < R) :
    ∃ x y : Signal n,
      transcript (amp a) (r + s) x = transcript (amp a) (r + s) y ∧
      sqNorm n x ≤ R ^ 2 ∧ sqNorm n y ≤ R ^ 2 ∧
      sqNorm n (x - y) = R ^ 2 ∧ sqNorm n (x + y) = R ^ 2 := by
  let λ : ℝ := R / 2
  obtain ⟨u, v, hu, hv, heq⟩ :=
    scaled_causal_collision_of_product_sphere_zero n r s a ha hBU λ
  have hboundPlus : sqNorm n (λ • u + λ • v) ≤ R ^ 2 := by
    calc
      sqNorm n (λ • u + λ • v) = λ ^ 2 * sqNorm n (u + v) := by
        rw [← smul_add, sqNorm_smul]
      _ ≤ λ ^ 2 * 4 :=
        mul_le_mul_of_nonneg_left (unit_sqNorm_add_le_four n u v hu hv)
          (sq_nonneg λ)
      _ = R ^ 2 := by dsimp [λ]; ring
  have hboundMinus : sqNorm n (λ • u - λ • v) ≤ R ^ 2 := by
    calc
      sqNorm n (λ • u - λ • v) = λ ^ 2 * sqNorm n (u - v) := by
        rw [← smul_sub, sqNorm_smul]
      _ ≤ λ ^ 2 * 4 :=
        mul_le_mul_of_nonneg_left (unit_sqNorm_sub_le_four n u v hu hv)
          (sq_nonneg λ)
      _ = R ^ 2 := by dsimp [λ]; ring
  have hdiffVec :
      (λ • u + λ • v) - (λ • u - λ • v) = λ • (v + v) := by
    rw [smul_add]
    abel
  have hsumVec :
      (λ • u + λ • v) + (λ • u - λ • v) = λ • (u + u) := by
    rw [smul_add]
    abel
  have hsep : sqNorm n ((λ • u + λ • v) - (λ • u - λ • v)) =
      R ^ 2 := by
    rw [hdiffVec, sqNorm_smul, sqNorm_add_self_of_unit n v hv]
    dsimp [λ]
    ring
  have hsep' : sqNorm n ((λ • u + λ • v) + (λ • u - λ • v)) =
      R ^ 2 := by
    rw [hsumVec, sqNorm_smul, sqNorm_add_self_of_unit n u hu]
    dsimp [λ]
    ring
  exact ⟨λ • u + λ • v, λ • u - λ • v,
    heq, hboundPlus, hboundMinus, hsep, hsep'⟩

#print axioms continuous_scaledTestU
#print axioms continuous_scaledTestV
#print axioms scaled_causal_collision_of_product_sphere_zero
#print axioms sqNorm_smul
#print axioms unit_sqNorm_add_le_four
#print axioms unit_sqNorm_sub_le_four
#print axioms ball_collision_of_product_sphere_zero

end Nightfall.ProductBUScaledPrefix
