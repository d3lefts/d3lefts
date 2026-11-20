import Mathlib

/-!
# Tensor subcube: exact algebraic kernel targets through L = 3

The source-closed rows are masks of rank-one tensors over F₂:
selector 0 = e₀, 1 = e₁, 2 = e₀+e₁.
The explicit 1/2/3-level row tables are proved equal to that generator.
The separate split bounds certify the *arithmetic* of the 3-slice argument.
They do not, by themselves, identify a general subspace with slice dimensions.
The quotient computations below use specifically exhibited subspaces.
-/

set_option maxRecDepth 12000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeL3

def tensorMask (L : Nat) (u : Fin L → Fin 3) : Nat :=
  (Finset.range (2 ^ L)).sum (fun z =>
    if ∀ i : Fin L, (u i).val = 2 ∨ (u i).val = (z / 2 ^ i.val) % 2
    then 2 ^ z else 0)

def tensorRows (L : Nat) : Finset Nat :=
  (Finset.univ : Finset (Fin L → Fin 3)).image (tensorMask L)

def rows1 : Finset Nat := {1, 2, 3}
def rows2 : Finset Nat := {1, 2, 3, 4, 5, 8, 10, 12, 15}
def rows3 : Finset Nat :=
  {1, 2, 3, 4, 5, 8, 10, 12, 15, 16, 17, 32, 34, 48,
   51, 64, 68, 80, 85, 128, 136, 160, 170, 192, 204, 240, 255}

theorem rows1_source : rows1 = tensorRows 1 := by decide
theorem rows2_source : rows2 = tensorRows 2 := by decide
theorem rows3_source : rows3 = tensorRows 3 := by decide

theorem rows_cardinalities :
    rows1.card = 3 ∧ rows2.card = 9 ∧ rows3.card = 27 := by decide

/-! The recursion budget counts possible rows inside the three tensor slices. -/

def cap0 (q : Nat) : Nat := if q = 0 then 0 else 1
def cap1 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else 3
def cap2 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else
    if q = 2 then 3 else if q = 3 then 5 else 9
def cap3 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else if q = 2 then 3 else
    if q = 3 then 5 else if q = 4 then 9 else if q = 5 then 11 else
      if q = 6 then 15 else if q = 7 then 19 else 27

/-- Exact base-level triple arithmetic, including the q=0 boundary. -/
theorem slice_arithmetic_L1 :
    ∀ q : Fin 3, ∀ a b c : Fin 2,
      a.val + b.val ≤ q.val →
      a.val + c.val ≤ q.val →
      b.val + c.val ≤ q.val →
      cap0 a.val + cap0 b.val + cap0 c.val ≤ cap1 q.val := by
  decide

/-- Exact second-level triple arithmetic. -/
theorem slice_arithmetic_L2 :
    ∀ q : Fin 5, ∀ a b c : Fin 3,
      a.val + b.val ≤ q.val →
      a.val + c.val ≤ q.val →
      b.val + c.val ≤ q.val →
      cap1 a.val + cap1 b.val + cap1 c.val ≤ cap2 q.val := by
  decide

/-- Exact third-level triple arithmetic for all admissible slice dimensions. -/
theorem slice_arithmetic_L3 :
    ∀ q : Fin 9, ∀ a b c : Fin 5,
      a.val + b.val ≤ q.val →
      a.val + c.val ≤ q.val →
      b.val + c.val ≤ q.val →
      cap2 a.val + cap2 b.val + cap2 c.val ≤ cap3 q.val := by
  decide

theorem caps_L3_exact :
    (List.range 9).map cap3 = [0, 1, 3, 5, 9, 11, 15, 19, 27] := by
  decide

/-!
  An ordered XOR pair fiber is a source-grounded finite set:
  for nonzero z each a determines the distinct partner b=a XOR z.
-/
def orderedFiber (A : Finset Nat) (z : Nat) : Nat :=
  (A.filter (fun a => Nat.xor a z ∈ A)).card

def original : Finset Nat := insert 0 rows3

theorem original_ordered_mu_upper :
    ∀ z : Fin 256, z.val ≠ 0 → orderedFiber original z.val ≤ 8 := by
  decide

theorem original_ordered_mu_witness : orderedFiber original 192 = 8 := by decide

/-! Quotient witness q=1: span{23}; q=2: span{97,6}, RREF pivots 0 and 1. -/
def reduceQ1 (z : Nat) : Nat :=
  if z % 2 = 1 then Nat.xor z 23 else z

def reduceQ2 (z : Nat) : Nat :=
  let t := if z / 2 % 2 = 1 then Nat.xor z 6 else z
  if t % 2 = 1 then Nat.xor t 97 else t

def quotientRows (f : Nat → Nat) : Finset Nat :=
  insert 0 (rows3.image f)

theorem rank1_quotient_ordered_mu_upper :
    ∀ z : Fin 256, z.val ≠ 0 →
      orderedFiber (quotientRows reduceQ1) z.val ≤ 14 := by
  decide

theorem rank1_quotient_ordered_mu_witness :
    orderedFiber (quotientRows reduceQ1) 2 = 14 := by decide

theorem rank2_quotient_ordered_mu_upper :
    ∀ z : Fin 256, z.val ≠ 0 →
      orderedFiber (quotientRows reduceQ2) z.val ≤ 20 := by
  decide

theorem rank2_quotient_ordered_mu_witness :
    orderedFiber (quotientRows reduceQ2) 96 = 20 := by decide

/-! The dual simplex-tensor evaluation code has minimum weight 8 at L=3. -/
def oddOverlap (r v : Nat) : Bool :=
  (((Finset.range 8).filter (fun i =>
    Nat.testBit r i = true ∧ Nat.testBit v i = true)).card % 2 == 1)

theorem dual_min_distance_L3 :
    ∀ v : Fin 256, v.val ≠ 0 →
      (rows3.filter (fun r => oddOverlap r v.val = true)).card ≥ 8 := by
  decide

theorem dual_min_distance_witness_L3 :
    (rows3.filter (fun r => oddOverlap r 1 = true)).card = 8 := by decide


/-!
  Secant-fiber exact controls for the two exhibited quotient subspaces.
  Each secant is an XOR of two original zero-or-row words.
  These are not the maximum over all q-dimensional subspaces.
-/
def secants : Finset Nat :=
  original.biUnion (fun a => original.image (fun b => Nat.xor a b))

def secantFiber (f : Nat → Nat) (z : Nat) : Nat :=
  (secants.filter (fun s => f s = z)).card

theorem secant_q0_witness : secantFiber (fun z => z) 1 = 1 := by decide

theorem secant_q1_upper :
    ∀ z : Fin 256, z.val ≠ 0 → secantFiber reduceQ1 z.val ≤ 2 := by
  decide

theorem secant_q1_witness : secantFiber reduceQ1 2 = 2 := by decide

theorem secant_q2_upper :
    ∀ z : Fin 256, z.val ≠ 0 → secantFiber reduceQ2 z.val ≤ 4 := by
  decide

theorem secant_q2_witness : secantFiber reduceQ2 96 = 4 := by decide

theorem quotient_pair_vs_secant_rank1 :
    ∀ z : Fin 256, z.val ≠ 0 →
      orderedFiber (quotientRows reduceQ1) z.val ≤
        8 * secantFiber reduceQ1 z.val := by
  decide

theorem quotient_pair_vs_secant_rank2 :
    ∀ z : Fin 256, z.val ≠ 0 →
      orderedFiber (quotientRows reduceQ2) z.val ≤
        8 * secantFiber reduceQ2 z.val := by
  decide

end Nightfall.StructuralInformation.SubcubeL3

#print axioms Nightfall.StructuralInformation.SubcubeL3.rows3_source
#print axioms Nightfall.StructuralInformation.SubcubeL3.slice_arithmetic_L3
#print axioms Nightfall.StructuralInformation.SubcubeL3.original_ordered_mu_upper
#print axioms Nightfall.StructuralInformation.SubcubeL3.rank1_quotient_ordered_mu_upper
#print axioms Nightfall.StructuralInformation.SubcubeL3.rank2_quotient_ordered_mu_upper
#print axioms Nightfall.StructuralInformation.SubcubeL3.dual_min_distance_L3

#print axioms Nightfall.StructuralInformation.SubcubeL3.secant_q1_upper
#print axioms Nightfall.StructuralInformation.SubcubeL3.secant_q2_upper
#print axioms Nightfall.StructuralInformation.SubcubeL3.quotient_pair_vs_secant_rank1
#print axioms Nightfall.StructuralInformation.SubcubeL3.quotient_pair_vs_secant_rank2
