import Mathlib
import ProductBUPerturbation

/-!
# Algebraic full-rank witness for the augmented Euclidean Sard family

For N=k≥1, add the sphere equations ‖u‖²−1 and ‖v‖²−1 as
two additional coordinates to the equivariant parametric homotopy.

At every unit u,v and every t ≠ 0,1, its full derivative is surjective:
radial variations hit the norm equations while independent rank-one matrix
parameter variations correct the first 2k target coordinates.

The source proves the UNIVERSAL ALGEBRAIC SURJECTIVITY SCHEME for an
arbitrary base spatial derivative D, not the differentiability or precise
fderiv formula of the concrete H_(A,B). It is a reusable kernel-checked
witness needed for the exact Euclidean parametricSard interface.

This extends #1032's rank-one perturbation proof to *all* t≠0,1,
not just 0<t<1, as required by the GLOBAL external parametric Sard.
The t=0 endpoint derivative and the empty t=1 fiber are separate
proof obligations. It does NOT assert ProductSphereZero.
-/

namespace Nightfall.ProductBUAugmentedRank
open Nightfall.ProductBUPerturbation
open Nightfall.ProductSphereObstruction

abbrev V (k : ℕ) := Fin (k + 1) → ℝ
abbrev W (k : ℕ) := Fin k → ℝ

/-- No positivity requirement: any NONZERO scalar weighted rank-one
parameter family surjects onto a k-coordinate response block. -/
theorem weighted_param_surjective_of_ne_zero (k : ℕ)
    (u : V k) (hu : UnitVec (k + 1) u)
    (c : ℝ) (hc : c ≠ 0) (y : W k) :
    ∃ A : Param k, ∀ i : Fin k,
      c * applyParam k A u i = y i := by
  refine ⟨rankOne k u (fun i => y i / c), ?_⟩
  intro i
  rw [congrFun (applyParam_rankOne_unit k u hu (fun i => y i / c)) i]
  field_simp

/-- Independent radial variation hits an arbitrary unit-norm
constraint derivative: d (‖u‖²−1) at u along (a/2)u equals a. -/
theorem radial_derivative_target (k : ℕ)
    (u : V k) (hu : UnitVec (k + 1) u) (a : ℝ) :
    2 * (∑ j : Fin (k + 1), u j * ((a / 2) * u j)) = a := by
  have hs : (∑ j : Fin (k + 1), u j * ((a / 2) * u j)) =
      (a / 2) * ∑ j : Fin (k + 1), u j ^ 2 := by
    calc
      (∑ j : Fin (k + 1), u j * ((a / 2) * u j)) =
          ∑ j : Fin (k + 1), (a / 2) * u j ^ 2 := by
            apply Finset.sum_congr rfl
            intro j _
            ring
      _ = (a / 2) * ∑ j : Fin (k + 1), u j ^ 2 := by
        rw [Finset.mul_sum]
  change (∑ j : Fin (k + 1), u j ^ 2) = 1 at hu
  rw [hs, hu]
  ring

/-- FULL augmented-parameter algebraic surjectivity at any t except
the two endpoints: arbitrary base spatial derivative D may be
compensated by matrix parameter directions, while radial variations
hit the last two constraint coordinates exactly.

Quantifies all u,v of squared norm 1 and all t ∈ ℝ \ {0,1}.
No transversality or Sard theorem is assumed here. -/
theorem augmented_full_rank_witness (k : ℕ)
    (u v : V k)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (t : ℝ) (ht0 : t ≠ 0) (ht1 : t ≠ 1)
    (D : (V k × V k) → (W k × W k))
    (yU yV : W k) (a b : ℝ) :
    ∃ A B : Param k, ∃ du dv : V k,
      (∀ i : Fin k,
        (D (du,dv)).1 i + t * (1 - t) * applyParam k A u i = yU i) ∧
      (∀ i : Fin k,
        (D (du,dv)).2 i + t * (1 - t) * applyParam k B v i = yV i) ∧
      2 * (∑ j : Fin (k + 1), u j * du j) = a ∧
      2 * (∑ j : Fin (k + 1), v j * dv j) = b := by
  have hc : t * (1 - t) ≠ 0 :=
    mul_ne_zero ht0 (sub_ne_zero.mpr ht1.symm)
  let du : V k := fun j => (a / 2) * u j
  let dv : V k := fun j => (b / 2) * v j
  let yU' : W k := fun i => yU i - (D (du,dv)).1 i
  let yV' : W k := fun i => yV i - (D (du,dv)).2 i
  obtain ⟨A, hA⟩ :=
    weighted_param_surjective_of_ne_zero k u hu (t * (1 - t)) hc yU'
  obtain ⟨B, hB⟩ :=
    weighted_param_surjective_of_ne_zero k v hv (t * (1 - t)) hc yV'
  refine ⟨A, B, du, dv, ?_, ?_, ?_, ?_⟩
  · intro i
    have h := hA i
    dsimp [yU'] at h
    linarith
  · intro i
    have h := hB i
    dsimp [yV'] at h
    linarith
  · dsimp [du]
    exact radial_derivative_target k u hu a
  · dsimp [dv]
    exact radial_derivative_target k v hv b

#print weighted_param_surjective_of_ne_zero
#print axioms weighted_param_surjective_of_ne_zero
#print radial_derivative_target
#print axioms radial_derivative_target
#print augmented_full_rank_witness
#print axioms augmented_full_rank_witness

end Nightfall.ProductBUAugmentedRank
