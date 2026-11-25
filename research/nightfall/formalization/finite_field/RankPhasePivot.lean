import Mathlib

/-! A constructive rank-increasing pivot without an abstract rank oracle.
On the actual coordinate space, one new free coordinate is normalized to the
unsquared reading while all previously frozen coordinates stay fixed.
This is a proof candidate, not a certified optimal-tree theorem. -/
namespace Nightfall.FiniteField.RankPhasePivot
open Finset
variable {K I : Type*} [Field K] [Fintype I] [DecidableEq I]
abbrev V (K I : Type*) := I → K

def unit (p : I) : V K I := Pi.single p 1

@[simp] theorem unit_at (p : I) : unit (K := K) p p = 1 := by
  simp [unit]

theorem unit_off (p i : I) (h : i ≠ p) : unit (K := K) p i = 0 := by
  simp [unit, Pi.single_eq_of_ne h]

def coord (p : I) : V K I →ₗ[K] K where
  toFun x := x p
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

@[simp] theorem coord_apply (p : I) (x : V K I) : coord p x = x p := rfl

def pivotF (a : V K I →ₗ[K] K) (p : I) : V K I →ₗ[K] V K I :=
  LinearMap.id + ((a (unit p))⁻¹ • (coord p - a)).smulRight (unit p)

def pivotG (a : V K I →ₗ[K] K) (p : I) : V K I →ₗ[K] V K I :=
  LinearMap.id + (a - coord p).smulRight (unit p)

theorem pivotF_apply (a : V K I →ₗ[K] K) (p : I) (z : V K I) :
    pivotF a p z = z + ((z p - a z) / a (unit p)) • unit p := by
  simp [pivotF, div_eq_mul_inv, mul_comm]

theorem pivotG_apply (a : V K I →ₗ[K] K) (p : I) (x : V K I) :
    pivotG a p x = x + (a x - x p) • unit p := by
  simp [pivotG]

theorem pivotF_off (a : V K I →ₗ[K] K) (p i : I) (hi : i ≠ p)
    (z : V K I) : pivotF a p z i = z i := by
  rw [pivotF_apply]
  change z i + ((z p - a z) / a (unit p)) * unit p i = z i
  rw [unit_off p i hi, mul_zero, add_zero]

theorem pivotG_off (a : V K I →ₗ[K] K) (p i : I) (hi : i ≠ p)
    (x : V K I) : pivotG a p x i = x i := by
  rw [pivotG_apply]
  change x i + (a x - x p) * unit p i = x i
  rw [unit_off p i hi, mul_zero, add_zero]

theorem pivotF_reading (a : V K I →ₗ[K] K) (p : I)
    (hc : a (unit p) ≠ 0) (z : V K I) : a (pivotF a p z) = z p := by
  rw [pivotF_apply, map_add, map_smul]
  change a z + ((z p - a z) / a (unit p)) * a (unit p) = z p
  field_simp [hc] <;> ring

theorem pivotG_at (a : V K I →ₗ[K] K) (p : I) (x : V K I) :
    pivotG a p x p = a x := by
  rw [pivotG_apply]
  change x p + (a x - x p) * unit p p = a x
  rw [unit_at, mul_one]
  ring

theorem pivot_left_inverse (a : V K I →ₗ[K] K) (p : I)
    (hc : a (unit p) ≠ 0) : Function.LeftInverse (pivotG a p) (pivotF a p) := by
  intro z
  funext i
  by_cases hi : i = p
  · subst i
    rw [pivotG_at, pivotF_reading a p hc]
  · rw [pivotG_off a p i hi, pivotF_off a p i hi]

theorem pivot_right_inverse (a : V K I →ₗ[K] K) (p : I)
    (hc : a (unit p) ≠ 0) : Function.RightInverse (pivotG a p) (pivotF a p) := by
  intro x
  funext i
  by_cases hi : i = p
  · subst i
    rw [pivotF_apply]
    change pivotG a p x p +
      ((pivotG a p x p - a (pivotG a p x)) / a (unit p)) * unit p p = x p
    rw [unit_at, mul_one, pivotG_at]
    have h : a (pivotG a p x) = a x + (a x - x p) * a (unit p) := by
      rw [pivotG_apply, map_add, map_smul]
      rfl
    rw [h]
    field_simp [hc] <;> ring
  · rw [pivotF_off a p i hi, pivotG_off a p i hi]

noncomputable def pivotEquiv (a : V K I →ₗ[K] K) (p : I)
    (hc : a (unit p) ≠ 0) : V K I ≃ₗ[K] V K I :=
  LinearEquiv.ofBijective (pivotF a p)
    ⟨(pivot_left_inverse a p hc).injective, (pivot_right_inverse a p hc).surjective⟩

theorem pivot_equiv_reading (a : V K I →ₗ[K] K) (p : I)
    (hc : a (unit p) ≠ 0) (z : V K I) : a (pivotEquiv a p hc z) = z p :=
  pivotF_reading a p hc z

theorem pivot_equiv_off (a : V K I →ₗ[K] K) (p i : I)
    (hc : a (unit p) ≠ 0) (hi : i ≠ p) (z : V K I) :
    pivotEquiv a p hc z i = z i :=
  pivotF_off a p i hi z

def swapMap (r p : I) : V K I →ₗ[K] V K I where
  toFun z := fun i => z (Equiv.swap r p i)
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

theorem swap_involutive (r p : I) : Function.Involutive (swapMap (K := K) r p) := by
  intro z
  funext i
  change z (Equiv.swap r p (Equiv.swap r p i)) = z i
  simp

noncomputable def swapEquiv (r p : I) : V K I ≃ₗ[K] V K I :=
  LinearEquiv.ofBijective (swapMap r p)
    ⟨(swap_involutive r p).injective, (swap_involutive r p).surjective⟩

theorem swap_at (r p : I) (z : V K I) : swapEquiv r p z p = z r := by
  change z (Equiv.swap r p p) = z r
  simp

theorem swap_off (r p i : I) (hr : i ≠ r) (hp : i ≠ p) (z : V K I) :
    swapEquiv r p z i = z i := by
  change z (Equiv.swap r p i) = z i
  rw [Equiv.swap_apply_of_ne_of_ne hr hp]

/-- Rank increase in the free coordinate set, with a specified next index.
The actual transformation is invertible and preserves every other frozen
coordinate, not merely the set of possible powered responses. -/
theorem rank_increase_normalize (a : V K I →ₗ[K] K) (r p : I)
    (hc : a (unit p) ≠ 0) :
    ∃ L : V K I ≃ₗ[K] V K I,
      (∀ z, a (L z) = z r) ∧
      (∀ z i, i ≠ r → i ≠ p → L z i = z i) := by
  refine ⟨(swapEquiv r p).trans (pivotEquiv a p hc), ?_, ?_⟩
  · intro z
    change a (pivotEquiv a p hc (swapEquiv r p z)) = z r
    rw [pivot_equiv_reading, swap_at]
  · intro z i hr hp
    change pivotEquiv a p hc (swapEquiv r p z) i = z i
    rw [pivot_equiv_off a p i hc hp, swap_off r p i hr hp]

/-- Every linear row is the sum of its actual coordinate coefficients. -/
theorem row_coordinate_expansion (a : V K I →ₗ[K] K) (z : V K I) :
    a z = ∑ i : I, z i * a (unit i) := by
  classical
  have hz : (∑ i : I, z i • unit i) = z := by
    funext j
    rw [Finset.sum_apply]
    rw [Finset.sum_eq_single j]
    · change z j * unit j j = z j
      simp
    · intro b hb hbj
      change z b * unit b j = 0
      rw [unit_off b j (Ne.symm hbj), mul_zero]
    · intro hj
      exact (hj (Finset.mem_univ j)).elim
  conv_lhs => rw [← hz]
  rw [map_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [map_smul]
  rfl

/-- If a row has no coefficient in a free coordinate, it depends only on
the frozen coordinates. This is the actual legal dependent-row query. -/
theorem dependent_row_agrees (a : V K I →ₗ[K] K) (A : Finset I)
    (ha : ∀ i, i ∉ A → a (unit i) = 0)
    (x y : V K I) (hxy : ∀ i ∈ A, x i = y i) : a x = a y := by
  rw [row_coordinate_expansion, row_coordinate_expansion]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : i ∈ A
  · rw [hxy i hi]
  · rw [ha i hi, mul_zero, mul_zero]

#print axioms rank_increase_normalize
#print axioms row_coordinate_expansion
#print axioms dependent_row_agrees
end Nightfall.FiniteField.RankPhasePivot
