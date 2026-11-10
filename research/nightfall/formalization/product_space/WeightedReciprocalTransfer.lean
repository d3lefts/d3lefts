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

end Nightfall.ProductSpace.Transfer
