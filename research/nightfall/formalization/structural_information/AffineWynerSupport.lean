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

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.axis_mem_of_codewords_differ
#print axioms Nightfall.AffineWyner.nonfree_coordinate_fixed
#print axioms Nightfall.AffineWyner.rectangular_support_nonfree_singleton
