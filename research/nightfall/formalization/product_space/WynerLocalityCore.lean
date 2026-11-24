import Mathlib

namespace Nightfall.WynerLocality

open Finset

/-- Total adaptive binary query trees. -/
inductive Tree (ι α : Type) where
  | leaf : α → Tree ι α
  | query : ι → Tree ι α → Tree ι α → Tree ι α

namespace Tree
variable {ι α : Type} [DecidableEq ι]

def eval : Tree ι α → (ι → Bool) → α
  | .leaf a, _ => a
  | .query i l r, x => if x i then r.eval x else l.eval x

def depth : Tree ι α → ℕ
  | .leaf _ => 0
  | .query _ l r => max l.depth r.depth + 1

def trace : Tree ι α → (ι → Bool) → Finset ι
  | .leaf _, _ => ∅
  | .query i l r, x => insert i (if x i then r.trace x else l.trace x)

theorem trace_card (t : Tree ι α) (x : ι → Bool) :
    (t.trace x).card ≤ t.depth := by
  induction t with
  | leaf a => simp [trace, depth]
  | query i l r hl hr =>
    by_cases h : x i = true
    · simp only [trace, depth, h, if_true]
      calc
        (insert i (r.trace x)).card ≤ (r.trace x).card + 1 := Finset.card_insert_le _ _
        _ ≤ max l.depth r.depth + 1 := Nat.add_le_add_right (hr.trans (le_max_right _ _)) _
    · have hf : x i = false := by cases hx : x i <;> simp_all
      simp only [trace, depth, hf, Bool.false_eq_true, if_false]
      calc
        (insert i (l.trace x)).card ≤ (l.trace x).card + 1 := Finset.card_insert_le _ _
        _ ≤ max l.depth r.depth + 1 := Nat.add_le_add_right (hl.trans (le_max_left _ _)) _

theorem eval_agree (t : Tree ι α) (x y : ι → Bool)
    (h : ∀ i ∈ t.trace x, y i = x i) : t.eval y = t.eval x := by
  induction t with
  | leaf a => rfl
  | query i l r hl hr =>
    have hi : y i = x i := h i (by simp [trace])
    by_cases hb : x i = true
    · have ht : ∀ j ∈ r.trace x, y j = x j := by
        intro j hj
        apply h j
        simp [trace, hb, hj]
      simpa [eval, hi, hb] using hr ht
    · have hf : x i = false := by cases hx : x i <;> simp_all
      have ht : ∀ j ∈ l.trace x, y j = x j := by
        intro j hj
        apply h j
        simp [trace, hf, hj]
      simpa [eval, hi, hf] using hl ht

end Tree

variable {ι κ α : Type} [DecidableEq ι] [DecidableEq κ]

def FullProjection (S : Set (ι → Bool)) (t : ℕ) : Prop :=
  ∀ (A : Finset ι), A.card ≤ t → ∀ y : ι → Bool,
    ∃ x ∈ S, ∀ i ∈ A, x i = y i

def Local (E : (κ → α) → (ι → Bool)) (L : ι → Finset κ) : Prop :=
  ∀ j z z', (∀ l ∈ L j, z l = z' l) → E z j = E z' j

def decode (D : κ → Tree ι α) (x : ι → Bool) : κ → α :=
  fun l => (D l).eval x

def obsTrace (D : κ → Tree ι α) (L : ι → Finset κ)
    (x : ι → Bool) (j : ι) : Finset ι :=
  (L j).biUnion fun l => (D l).trace x

theorem obsTrace_card (D : κ → Tree ι α) (L : ι → Finset κ)
    (b r : ℕ) (hL : ∀ j, (L j).card ≤ b) (hD : ∀ l, (D l).depth ≤ r)
    (x : ι → Bool) (j : ι) : (obsTrace D L x j).card ≤ b*r := by
  unfold obsTrace
  calc
    _ ≤ ∑ l ∈ L j, ((D l).trace x).card := Finset.card_biUnion_le
    _ ≤ ∑ _l ∈ L j, r := Finset.sum_le_sum fun l _ => ((D l).trace_card x).trans (hD l)
    _ = (L j).card * r := by simp
    _ ≤ b*r := Nat.mul_le_mul_right r (hL j)

theorem composed_agree (E : (κ → α) → (ι → Bool))
    (D : κ → Tree ι α) (L : ι → Finset κ) (hE : Local E L)
    (x y : ι → Bool) (j : ι)
    (h : ∀ i ∈ obsTrace D L x j, y i = x i) :
    E (decode D y) j = E (decode D x) j := by
  apply hE
  intro l hl
  apply Tree.eval_agree
  intro i hi
  exact h i (Finset.mem_biUnion.mpr ⟨l, hl, hi⟩)

theorem shallow_retraction_identity (S : Set (ι → Bool)) (t b r : ℕ)
    (E : (κ → α) → (ι → Bool)) (D : κ → Tree ι α) (L : ι → Finset κ)
    (hE : Local E L) (hL : ∀ j, (L j).card ≤ b) (hD : ∀ l, (D l).depth ≤ r)
    (hS : FullProjection S t) (hsmall : b*r+1 ≤ t)
    (hfix : ∀ x ∈ S, E (decode D x) = x) :
    ∀ y, E (decode D y) = y := by
  intro y
  funext j
  let A := insert j (obsTrace D L y j)
  have hA : A.card ≤ t := by
    calc
      A.card ≤ (obsTrace D L y j).card + 1 := Finset.card_insert_le _ _
      _ ≤ b*r+1 := Nat.add_le_add_right (obsTrace_card D L b r hL hD y j) _
      _ ≤ t := hsmall
  obtain ⟨x, hx, hxy⟩ := hS A hA y
  have hc := composed_agree E D L hE y x j (fun i hi => hxy i (by simp [A, hi]))
  rw [hfix x hx] at hc
  exact hc.symm.trans (hxy j (by simp [A]))

/-- Product-support obstruction stated for any proper full-projection source.
    The range premise is exactly what an independent latent with full marginal
    support provides. -/
theorem product_range_obstruction (S : Set (ι → Bool)) (t b r : ℕ)
    (E : (κ → α) → (ι → Bool)) (D : κ → Tree ι α) (L : ι → Finset κ)
    (hE : Local E L) (hL : ∀ j, (L j).card ≤ b) (hD : ∀ l, (D l).depth ≤ r)
    (hS : FullProjection S t) (hfix : ∀ x ∈ S, E (decode D x) = x)
    (hrange : ∀ z, E z ∈ S) (hproper : ∃ y, y ∉ S) :
    t ≤ b*r := by
  by_contra h
  have hsmall : b*r+1 ≤ t := by omega
  obtain ⟨y, hy⟩ := hproper
  have he := shallow_retraction_identity S t b r E D L hE hL hD hS hsmall hfix y
  exact hy (he ▸ hrange (decode D y))

/-- Each forbidden output of a decoder tree has a rejecting cylinder of
    width at most its depth. This is the exact support-CNF bridge. -/
theorem rectangle_preimage_local_exclusion (D : κ → Tree ι α) (r : ℕ)
    (R : κ → Set α) (hD : ∀ l, (D l).depth ≤ r)
    (y : ι → Bool) (hy : ¬ ∀ l, decode D y l ∈ R l) :
    ∃ A : Finset ι, A.card ≤ r ∧
      ∀ x : ι → Bool, (∀ i ∈ A, x i = y i) →
        ¬ ∀ l, decode D x l ∈ R l := by
  classical
  push Not at hy
  obtain ⟨l, hl⟩ := hy
  refine ⟨(D l).trace y, ((D l).trace_card y).trans (hD l), ?_⟩
  intro x hx hall
  have he := (D l).eval_agree y x hx
  exact hl (by simpa [decode, he] using hall l)

/-- Pull back any rectangle whose image lies in the source, without assuming
    the entire encoder range is in the source. -/
theorem rectangle_preimage_subset (S : Set (ι → Bool))
    (E : (κ → α) → (ι → Bool)) (D : κ → Tree ι α)
    (R : κ → Set α) (hid : ∀ y, E (decode D y) = y)
    (hrange : ∀ z, (∀ l, z l ∈ R l) → E z ∈ S) :
    ∀ y, (∀ l, decode D y l ∈ R l) → y ∈ S := by
  intro y hy
  simpa only [hid y] using hrange (decode D y) hy

end Nightfall.WynerLocality

#print axioms Nightfall.WynerLocality.shallow_retraction_identity
#print axioms Nightfall.WynerLocality.product_range_obstruction
#print axioms Nightfall.WynerLocality.rectangle_preimage_local_exclusion
#print axioms Nightfall.WynerLocality.rectangle_preimage_subset
