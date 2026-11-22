import Mathlib

/-!
# NIGHTFALL — affine-code Wyner support rigidity

This file proves an algebraic part of the affine-code Wyner identity in the
*exact finite-field signal model*. It is **not** the end-to-end entropy/Wyner
identity yet. No abstract support-edge theorem is taken as an axiom.

For L ≤ F^ι and affine code a+L:
* if two codewords differ at exactly coordinate i then the unit axis e_i lies
  in L;
* any Cartesian product of nonempty coordinate supports entirely contained
  in a+L is deterministic in every coordinate whose unit axis is not in L.

This is the hard support-rectangle implication needed to show that *every*
conditionally independent Wyner component determines all nonfree coordinates.
The remaining explicit entropy/attaining-latent step is kept as an open gate.
-/

namespace Nightfall.AffineWyner

variable {ι 𝔽 : Type*} [Fintype ι] [DecidableEq ι] [Field 𝔽]

def axis (i : ι) : ι → 𝔽 := fun j => if j = i then 1 else 0

def InAffineCode (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽) : Prop :=
  x - a ∈ L

theorem sub_of_affine_code (L : Submodule 𝔽 (ι → 𝔽))
    (a x y : ι → 𝔽) (hx : InAffineCode L a x) (hy : InAffineCode L a y) :
    x - y ∈ L := by
  have hh : (x - a) - (y - a) ∈ L := L.sub_mem hx hy
  have heq : (x - a) - (y - a) = x - y := by
    ext j
    simp only [Pi.sub_apply]
    ring
  rw [heq] at hh
  exact hh

theorem sub_eq_smul_axis (i : ι) (x y : ι → 𝔽)
    (hxy : ∀ j, j ≠ i → x j = y j) :
    x - y = (x i - y i) • axis i := by
  ext j
  by_cases hj : j = i
  · subst j
    simp [axis, Pi.smul_apply, smul_eq_mul]
  · simp [axis, Pi.smul_apply, smul_eq_mul, hj, hxy j hj]

theorem axis_mem_of_codewords_differ (L : Submodule 𝔽 (ι → 𝔽))
    (a x y : ι → 𝔽) (i : ι)
    (hx : InAffineCode L a x) (hy : InAffineCode L a y)
    (hxy : ∀ j, j ≠ i → x j = y j) (hi : x i ≠ y i) :
    axis i ∈ L := by
  have hsub : x - y ∈ L := sub_of_affine_code L a x y hx hy
  have heq : x - y = (x i - y i) • axis i :=
    sub_eq_smul_axis i x y hxy
  rw [heq] at hsub
  have hcoef : x i - y i ≠ 0 := sub_ne_zero.mpr hi
  have hscaled := L.smul_mem ((x i - y i)⁻¹) hsub
  simpa [smul_smul, inv_mul_cancel₀ hcoef] using hscaled

theorem nonfree_coordinate_fixed (L : Submodule 𝔽 (ι → 𝔽))
    (a x y : ι → 𝔽) (i : ι)
    (hi : axis i ∉ L)
    (hx : InAffineCode L a x) (hy : InAffineCode L a y)
    (hxy : ∀ j, j ≠ i → x j = y j) :
    x i = y i := by
  by_contra h
  exact hi (axis_mem_of_codewords_differ L a x y i hx hy hxy h)

theorem rectangular_support_nonfree_singleton
    (L : Submodule 𝔽 (ι → 𝔽)) (a : ι → 𝔽)
    (P : ι → Set 𝔽)
    (hP : ∀ j, (P j).Nonempty)
    (hrectangle : ∀ x : ι → 𝔽, (∀ j, x j ∈ P j) → InAffineCode L a x)
    (i : ι) (hi : axis i ∉ L) :
    ∀ u ∈ P i, ∀ v ∈ P i, u = v := by
  classical
  let base : ι → 𝔽 := fun j => Classical.choose (hP j)
  have hbase : ∀ j, base j ∈ P j := fun j => Classical.choose_spec (hP j)
  intro u hu v hv
  let x : ι → 𝔽 := Function.update base i u
  let y : ι → 𝔽 := Function.update base i v
  have hxP : ∀ j, x j ∈ P j := by
    intro j
    by_cases hj : j = i
    · subst j
      simpa [x] using hu
    · simpa [x, Function.update_noteq hj] using hbase j
  have hyP : ∀ j, y j ∈ P j := by
    intro j
    by_cases hj : j = i
    · subst j
      simpa [y] using hv
    · simpa [y, Function.update_noteq hj] using hbase j
  have hxy : ∀ j, j ≠ i → x j = y j := by
    intro j hj
    simp [x, y, Function.update_noteq hj]
  have hfix := nonfree_coordinate_fixed L a x y i hi (hrectangle x hxP)
    (hrectangle y hyP) hxy
  simpa [x, y] using hfix


/-! ## The actual conditional-product source interface -/

variable [Fintype 𝔽] [DecidableEq 𝔽]

/-- The **actual** mass assigned by a product law to a full codeword. -/
noncomputable def productMass (p : ι → 𝔽 → ℝ) (x : ι → 𝔽) : ℝ :=
  ∏ j, p j (x j)

/-- If a normalized coordinate-product law charges only affine-code words,
every nonfree coordinate is *Dirac*, not merely singleton-supported.
This is a source-level version of the lower-bound step of Wyner's formula;
no entropy upper bound or Wyner infimum is silently supplied. -/
theorem supported_product_nonfree_dirac
    (L : Submodule 𝔽 (ι → 𝔽)) (a : ι → 𝔽)
    (p : ι → 𝔽 → ℝ)
    (hp0 : ∀ j v, 0 ≤ p j v)
    (hp1 : ∀ j, ∑ v, p j v = 1)
    (hsupport : ∀ x, 0 < productMass p x → InAffineCode L a x)
    (i : ι) (hi : axis i ∉ L) :
    ∃ v : 𝔽, p i v = 1 ∧ ∀ t : 𝔽, t ≠ v → p i t = 0 := by
  classical
  let S : ι → Set 𝔽 := fun j => {v | 0 < p j v}
  have hne : ∀ j, (S j).Nonempty := by
    intro j
    have h : ∃ v : 𝔽, 0 < p j v := by
      by_contra h
      push_neg at h
      have hle : (∑ v : 𝔽, p j v) ≤ 0 :=
        Finset.sum_nonpos (fun v _ => h v)
      linarith [hp1 j]
    exact h
  have hrectangle : ∀ x : ι → 𝔽, (∀ j, x j ∈ S j) → InAffineCode L a x := by
    intro x hx
    apply hsupport x
    unfold productMass
    exact Finset.prod_pos (fun j _ => hx j)
  have huniq := rectangular_support_nonfree_singleton L a S hne hrectangle i hi
  obtain ⟨v, hv⟩ := hne i
  have hzero : ∀ t : 𝔽, t ≠ v → p i t = 0 := by
    intro t ht
    have hn : ¬ 0 < p i t := by
      intro htpos
      exact ht (huniq t htpos v hv)
    exact le_antisymm (le_of_not_gt hn) (hp0 i t)
  have hsum : (∑ t : 𝔽, p i t) = p i v := by
    apply Finset.sum_eq_single v
    · intro t _ ht
      exact hzero t ht
    · intro h
      exact False.elim (h (Finset.mem_univ v))
  refine ⟨v, ?_, hzero⟩
  exact hsum.symm.trans (hp1 i)

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.axis_mem_of_codewords_differ
#print axioms Nightfall.AffineWyner.nonfree_coordinate_fixed
#print axioms Nightfall.AffineWyner.rectangular_support_nonfree_singleton
#print axioms Nightfall.AffineWyner.supported_product_nonfree_dirac
