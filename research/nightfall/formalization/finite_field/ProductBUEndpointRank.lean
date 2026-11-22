import Mathlib
import ProductBUParityReference

/-!
# Explicit spatial derivative inverse at the t = 0 reference endpoint

Let F0(u,v)=(tail(u),tail(v)), the reference map used in the
product-sphere parity proof. Introduce both sphere norm constraints:
  E0(u,v)=(tail u, tail v, ‖u‖²-1, ‖v‖²-1).

At any zero with u,v of norm one and zero tails, the derivative of
E0 with respect to (u,v) alone is a linear isomorphism. This module
provides a fully quantified explicit SURJECTIVITY witness, including
every coordinate of the derivative, in all dimensions.

The source is independent of the parallel #1032 parameter branch.
It proves no generic t-regularity, no 1-manifold structure, no orbit
parity and no ProductSphereZero. It is exactly the missing t=0
algebraic boundary transversality input to #1048's augmented
Euclidean parametric-Sard plan.
-/

namespace Nightfall.ProductBUEndpointRank
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUParity

abbrev V (k : ℕ) := Fin (k + 1) → ℝ
abbrev W (k : ℕ) := Fin k → ℝ

/-- The reference zeros are precisely signed axes; in particular their
first coordinates have squared value 1. -/
theorem reference_first_sq_one (k : ℕ) (u : V k)
    (hu : UnitVec (k + 1) u)
    (htail : ∀ i : Fin k, u i.succ = 0) :
    (u 0) ^ 2 = 1 := by
  rcases unit_tail_zero_first_sign k u hu htail with h | h
  · rw [h]
    norm_num
  · rw [h]
    norm_num

/-- At a reference zero, an input variation with prescribed tail
and half-scaled first coordinate hits any prescribed radial derivative. -/
theorem endpoint_radial_inverse (k : ℕ)
    (u : V k) (hu : UnitVec (k + 1) u)
    (htail : ∀ i : Fin k, u i.succ = 0)
    (a : ℝ) (y : W k) :
    2 * mixedDot (k + 1) u
      (Fin.cons ((a / 2) * u 0) y) = a := by
  have h0 : (u 0) ^ 2 = 1 :=
    reference_first_sq_one k u hu htail
  have htailzero : (∑ i : Fin k, u i.succ * y i) = 0 := by
    apply Finset.sum_eq_zero
    intro i _
    rw [htail i]
    ring
  unfold mixedDot
  rw [Fin.sum_univ_succ]
  change 2 * (u 0 * ((a / 2) * u 0) +
    (∑ i : Fin k, u i.succ * y i)) = a
  rw [htailzero]
  calc
    2 * (u 0 * ((a / 2) * u 0) + 0) = a * ((u 0) ^ 2) := by ring
    _ = a := by rw [h0]; ring

/-- The explicit right inverse of the reference end spatial Jacobian:
the 2k tail coordinates and both radial coordinates can be prescribed
arbitrarily, with no change to the time coordinate.

Thus for any parameter matrices A,B, the augmented family at t=0
has surjective full derivative (once its source-exact derivative
formula is identified). There are no unknown assumptions hidden
in the algebraic statement. -/
theorem endpoint_spatial_full_rank_witness (k : ℕ)
    (u v : V k)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (htailU : ∀ i : Fin k, u i.succ = 0)
    (htailV : ∀ i : Fin k, v i.succ = 0)
    (yU yV : W k) (a b : ℝ) :
    ∃ du dv : V k,
      (∀ i : Fin k, du i.succ = yU i) ∧
      (∀ i : Fin k, dv i.succ = yV i) ∧
      2 * mixedDot (k + 1) u du = a ∧
      2 * mixedDot (k + 1) v dv = b := by
  refine ⟨Fin.cons ((a / 2) * u 0) yU,
    Fin.cons ((b / 2) * v 0) yV, ?_, ?_, ?_, ?_⟩
  · intro i
    rfl
  · intro i
    rfl
  · exact endpoint_radial_inverse k u hu htailU a yU
  · exact endpoint_radial_inverse k v hv htailV b yV

#print reference_first_sq_one
#print axioms reference_first_sq_one
#print endpoint_radial_inverse
#print axioms endpoint_radial_inverse
#print endpoint_spatial_full_rank_witness
#print axioms endpoint_spatial_full_rank_witness

end Nightfall.ProductBUEndpointRank
