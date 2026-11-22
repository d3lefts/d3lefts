import ProductRowBound

/-!
# Conditional K = π² d²/2 finite-product row construction

Formalizes the entire competing-symbol Chebyshev/packing/LP transfer
from the *precisely stated* Filmus–Hatami–Keller–Lifshitz pointwise
bound, which is not yet kernel-proved in this library. The missing
input is explicit as a Prop parameter; there is no axiom, sorry,
opaque placeholder, or promotion of the final sharp row theorem.
-/

namespace Nightfall.ProductSpace.RowBound

open Finset Polynomial AaronsonAmbainis AaronsonAmbainis.Row

/-- Precisely the currently missing sharp sensitivity theorem on arbitrary
finite Boolean cubes (FHKL, Theorem 3.3), in the normalization used by
the competing-symbol product selector. -/
def CubeSharpSensitivity : Prop :=
  ∀ (β : Type) [Fintype β] [DecidableEq β]
    (G : Cube β → ℝ) (D : ℕ),
    (∀ w, |G w| ≤ 1) → HasDegreeLE G D →
    (∑ b, |G (Row.zero β) - G (Row.unit b)|) ≤ 2 * (D : ℝ) ^ 2

section Selector
variable {ι α β : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

theorem product_block_inequality_of_sharp_sensitivity
    (hsharp : CubeSharpSensitivity) (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α) (y : β → ι → α) (N m : ℕ) (hm : 0 < m)
    (hN : ∀ i, (univ.filter fun b : β => i ∈ disagree x (y b)).card ≤ N)
    (hNc : (N : ℝ) * (1 - Real.cos (Real.pi / (m : ℝ))) ≤ 2) :
    ∑ b, |f x - f (y b)| ≤ 2 * (d : ℝ) ^ 2 * (m : ℝ) ^ 2 := by
  have hc : 0 ≤ 1 - Real.cos (Real.pi / (m : ℝ)) := sub_nonneg.mpr (Real.cos_le_one _)
  have hG := abs_Gsel_le_one f hf x (fun b => disagree x (y b)) y N m _ hc hN hNc
  have hdeg := hasDegreeLE_Gsel d f hd x (fun b => disagree x (y b)) y m hm
    (1 - Real.cos (Real.pi / (m : ℝ)))
  have key := hsharp β _ (d * m) hG hdeg
  have hz : Gsel f x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ)))
      (Row.zero β) = f x :=
    sum_mul_prod_delta f
      (fun i s => Pv x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ))) i
        (Row.zero β) s) x
      (fun i s => Pv_zero x _ y m _ i s)
  have hu : ∀ b0, Gsel f x (fun b => disagree x (y b)) y m
      (1 - Real.cos (Real.pi / (m : ℝ))) (Row.unit b0) = f (y b0) := fun b0 =>
    sum_mul_prod_delta f
      (fun i s => Pv x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ))) i
        (Row.unit b0) s) (y b0)
      (fun i s => Pv_unit x y m hm b0 i s)
  calc ∑ b, |f x - f (y b)|
      = ∑ b, |Gsel f x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ)))
            (Row.zero β) - Gsel f x (fun b => disagree x (y b)) y m
            (1 - Real.cos (Real.pi / (m : ℝ))) (Row.unit b)| := by
        refine Finset.sum_congr rfl fun b _ => ?_
        rw [hz, hu b]
    _ ≤ 2 * ((d * m : ℕ) : ℝ) ^ 2 := key
    _ = 2 * (d : ℝ) ^ 2 * (m : ℝ) ^ 2 := by push_cast; ring


end Selector

section RowBound
variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

theorem product_scaled_bound_of_sharp_sensitivity
    (hsharp : CubeSharpSensitivity) (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α)
    (κ : Finset ι → ℝ) (hκ : ∀ S, 0 ≤ κ S)
    (hpack : ∀ i, ∑ S ∈ univ.filter (fun S : Finset ι => i ∈ S), κ S ≤ 1)
    (M : ℕ) (hM : 0 < M) :
    (M : ℝ) ^ 2 * ∑ S, κ S * |f x - f (ysel f x S)|
      ≤ ((d : ℝ) ^ 2 / 2) * (Real.pi * (M : ℝ) + 2) ^ 2 + ∑ S, |f x - f (ysel f x S)| := by
  let k : Finset ι → ℕ := fun S => ⌊((M ^ 2 : ℕ) : ℝ) * κ S⌋₊
  have hN : ∀ i, (univ.filter fun b : (Σ S : Finset ι, Fin (k S)) =>
      i ∈ disagree x (ysel f x b.1)).card ≤ M ^ 2 := by
    intro i
    refine le_trans (Finset.card_le_card ?_) (Pack.card_blocks_le κ hκ hpack (M ^ 2) i)
    intro b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb ⊢
    exact ysel_sub f x b.1 hb
  have hblock : ∑ b : (Σ S : Finset ι, Fin (k S)), |f x - f (ysel f x b.1)|
      ≤ 2 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2 :=
    product_block_inequality_of_sharp_sensitivity hsharp d f hf hd x
    (fun b : (Σ S : Finset ι, Fin (k S)) => ysel f x b.1) (M ^ 2)
    ⌈Real.pi * (M : ℝ) / 2⌉₊ (Pack.gate_pos M hM) hN (Pack.gate_cos M hM)
  have hsum : (∑ b : (Σ S : Finset ι, Fin (k S)), |f x - f (ysel f x b.1)|)
      = ∑ S, (k S : ℝ) * |f x - f (ysel f x S)| :=
    Pack.sum_blocks k (fun S => |f x - f (ysel f x S)|)
  rw [hsum] at hblock
  have hcast : ((M ^ 2 : ℕ) : ℝ) = (M : ℝ) ^ 2 := by push_cast; ring
  have hd2 : (0 : ℝ) ≤ (d : ℝ) ^ 2 := sq_nonneg _
  have hright : 2 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2
      ≤ ((d : ℝ) ^ 2 / 2) * (Real.pi * (M : ℝ) + 2) ^ 2 := by
    calc
      2 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2
          = ((d : ℝ) ^ 2 / 2) *
              (4 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2) := by ring
      _ ≤ ((d : ℝ) ^ 2 / 2) * (Real.pi * (M : ℝ) + 2) ^ 2 :=
        mul_le_mul_of_nonneg_left (Pack.gate_sq M) (by positivity)
  have hterm : ∀ S : Finset ι, (M : ℝ) ^ 2 * (κ S * |f x - f (ysel f x S)|)
      ≤ (k S : ℝ) * |f x - f (ysel f x S)| + |f x - f (ysel f x S)| := by
    intro S
    have hlt : ((M ^ 2 : ℕ) : ℝ) * κ S < (k S : ℝ) + 1 := Nat.lt_floor_add_one _
    have habs : (0 : ℝ) ≤ |f x - f (ysel f x S)| := abs_nonneg _
    calc (M : ℝ) ^ 2 * (κ S * |f x - f (ysel f x S)|)
        = (((M ^ 2 : ℕ) : ℝ) * κ S) * |f x - f (ysel f x S)| := by rw [hcast]; ring
      _ ≤ ((k S : ℝ) + 1) * |f x - f (ysel f x S)| :=
          mul_le_mul_of_nonneg_right hlt.le habs
      _ = (k S : ℝ) * |f x - f (ysel f x S)| + |f x - f (ysel f x S)| := by ring
  calc (M : ℝ) ^ 2 * ∑ S, κ S * |f x - f (ysel f x S)|
      = ∑ S, (M : ℝ) ^ 2 * (κ S * |f x - f (ysel f x S)|) := by rw [Finset.mul_sum]
    _ ≤ ∑ S, ((k S : ℝ) * |f x - f (ysel f x S)| + |f x - f (ysel f x S)|) :=
        Finset.sum_le_sum fun S _ => hterm S
    _ = ∑ S, (k S : ℝ) * |f x - f (ysel f x S)| + ∑ S, |f x - f (ysel f x S)| :=
        Finset.sum_add_distrib
    _ ≤ ((d : ℝ) ^ 2 / 2) * (Real.pi * (M : ℝ) + 2) ^ 2 + ∑ S, |f x - f (ysel f x S)| := by
        have h4 : ∑ S, (k S : ℝ) * |f x - f (ysel f x S)|
            ≤ 2 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2 := hblock
        linarith


theorem product_packing_bound_of_sharp_sensitivity
    (hsharp : CubeSharpSensitivity) (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α)
    (κ : Finset ι → ℝ) (hκ : ∀ S, 0 ≤ κ S)
    (hpack : ∀ i, ∑ S ∈ univ.filter (fun S : Finset ι => i ∈ S), κ S ≤ 1) :
    ∑ S, κ S * |f x - f (ysel f x S)| ≤ Real.pi ^ 2 * (d : ℝ) ^ 2 / 2 := by
  have key :
      2 * (∑ S, κ S * |f x - f (ysel f x S)|) ≤ Real.pi ^ 2 * (d : ℝ) ^ 2 :=
    Pack.le_of_scaled _ (2 * ∑ S, |f x - f (ysel f x S)|) d (fun M hM => by
      have hscaled := product_scaled_bound_of_sharp_sensitivity
        hsharp d f hf hd x κ hκ hpack M hM
      calc
        (M : ℝ) ^ 2 * (2 * ∑ S, κ S * |f x - f (ysel f x S)|)
            = 2 * ((M : ℝ) ^ 2 * ∑ S, κ S * |f x - f (ysel f x S)|) := by ring
        _ ≤ 2 * (((d : ℝ) ^ 2 / 2) * (Real.pi * (M : ℝ) + 2) ^ 2 +
            ∑ S, |f x - f (ysel f x S)|) :=
              mul_le_mul_of_nonneg_left hscaled (by norm_num)
        _ = (d : ℝ) ^ 2 * (Real.pi * (M : ℝ) + 2) ^ 2 +
            2 * ∑ S, |f x - f (ysel f x S)| := by ring)
  linarith



theorem product_row_bound_of_sharp_sensitivity
    (hsharp : CubeSharpSensitivity) (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α) :
    ∃ a : ι → ℝ, (∀ i, 0 ≤ a i) ∧ ∑ i, a i ≤ (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) ∧
      ∀ y, |f x - f y| ≤ ∑ i ∈ disagree x y, a i := by
  have hK : 0 ≤ (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) := by positivity
  have ht0 : |f x - f (ysel f x ∅)| ≤ 0 := by rw [ysel_empty, sub_self, abs_zero]
  obtain ⟨a, ha0, hasum, hcov⟩ := coverDuality ι (fun S => |f x - f (ysel f x S)|)
    ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2)) hK ht0
    (fun κ hκ hpack => product_packing_bound_of_sharp_sensitivity hsharp d f hf hd x κ hκ hpack)
  exact ⟨a, ha0, hasum, fun y => (ysel_max f x y).trans (hcov (disagree x y))⟩


end RowBound

end Nightfall.ProductSpace.RowBound
