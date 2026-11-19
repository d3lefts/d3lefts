import Mathlib

/-!
# One-sided dyadic ceiling rounding: exact local error and anchor budget

For any nonnegative finite source mass p and positive integer grid N,
ceil(N p)/N never deletes positive mass and moves less than 1/N upward.
All this moved mass can be debited from a distinguished anchor. If the
anchor exceeds the sum of one-grid-unit budgets of the other atoms, the
residual anchor stays strictly positive.

This is a real-valued Lean construction, independent of a minimum atom
margin. It does NOT yet provide the universal anchor-selection lemma, the
full stochastic source-to-rounded coupling, a bucket decoder, or BDST.
-/

namespace Nightfall.StrongDyadicRounding

open Finset

/-- Upward rounding to the dyadic grid with denominator N. -/
noncomputable def upperGrid (N : ℕ) (p : ℝ) : ℝ :=
  (Nat.ceil ((N : ℝ) * p) : ℝ) / (N : ℝ)

/-- The rounding increment (nonnegative for N>0). -/
noncomputable def increment (N : ℕ) (p : ℝ) : ℝ := upperGrid N p - p

theorem upperGrid_ge (N : ℕ) (hN : 0 < N) (p : ℝ) :
    p ≤ upperGrid N p := by
  have hpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  unfold upperGrid
  apply (le_div_iff₀ hpos).2
  simpa only [mul_comm] using (Nat.le_ceil ((N : ℝ) * p))

theorem upperGrid_lt (N : ℕ) (hN : 0 < N)
    (p : ℝ) (hp : 0 ≤ p) :
    upperGrid N p < p + 1 / (N : ℝ) := by
  have hpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hceil : ((Nat.ceil ((N : ℝ) * p) : ℕ) : ℝ) <
      (N : ℝ) * p + 1 :=
    Nat.ceil_lt_add_one (mul_nonneg hpos.le hp)
  unfold upperGrid
  apply (div_lt_iff₀ hpos).2
  have hcalc : (p + 1 / (N : ℝ)) * (N : ℝ) =
      (N : ℝ) * p + 1 := by
    field_simp [ne_of_gt hpos]
  rw [hcalc]
  exact hceil

theorem increment_nonneg (N : ℕ) (hN : 0 < N)
    (p : ℝ) : 0 ≤ increment N p := by
  unfold increment
  exact sub_nonneg.mpr (upperGrid_ge N hN p)

theorem increment_lt (N : ℕ) (hN : 0 < N)
    (p : ℝ) (hp : 0 ≤ p) :
    increment N p < 1 / (N : ℝ) := by
  unfold increment
  have h := upperGrid_lt N hN p hp
  linarith

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Non-anchor mass increases by less than one grid unit each.
If the anchor mass exceeds the full available grid-unit budget,
the residual is strictly positive. No lower bound on other atoms. -/
theorem anchor_survives
    (N : ℕ) (hN : 0 < N) (p : α → ℝ)
    (hp : ∀ b, 0 ≤ p b) (a : α)
    (hroom :
      (∑ b ∈ (Finset.univ.erase a), (1 : ℝ) / (N : ℝ)) < p a) :
    0 < p a - ∑ b ∈ (Finset.univ.erase a), increment N (p b) := by
  have hbudget :
      (∑ b ∈ (Finset.univ.erase a), increment N (p b)) ≤
        ∑ b ∈ (Finset.univ.erase a), (1 : ℝ) / (N : ℝ) := by
    exact Finset.sum_le_sum (fun b _ => le_of_lt (increment_lt N hN (p b) (hp b)))
  linarith


/-- Concrete one-sided grid-rounded mass table: all nonanchors are rounded
up, and the anchor pays for their cumulative increments. -/
noncomputable def roundedMass (N : ℕ) (p : α → ℝ) (a b : α) : ℝ :=
  if b = a then
    p a - ∑ c ∈ (Finset.univ.erase a), increment N (p c)
  else upperGrid N (p b)

theorem roundedMass_nonneg
    (N : ℕ) (hN : 0 < N) (p : α → ℝ)
    (hp : ∀ b, 0 ≤ p b) (a : α)
    (hroom :
      (∑ b ∈ (Finset.univ.erase a), (1 : ℝ) / (N : ℝ)) < p a)
    (b : α) :
    0 ≤ roundedMass N p a b := by
  by_cases h : b = a
  · subst b
    simpa [roundedMass] using
      (anchor_survives N hN p hp a hroom).le
  · simp only [roundedMass, if_neg h]
    exact (hp b).trans (upperGrid_ge N hN (p b))

theorem roundedMass_support
    (N : ℕ) (hN : 0 < N) (p : α → ℝ)
    (hp : ∀ b, 0 ≤ p b) (a : α)
    (hroom :
      (∑ b ∈ (Finset.univ.erase a), (1 : ℝ) / (N : ℝ)) < p a)
    (b : α) (hb : 0 < p b) :
    0 < roundedMass N p a b := by
  by_cases h : b = a
  · subst b
    simpa [roundedMass] using
      anchor_survives N hN p hp a hroom
  · simp only [roundedMass, if_neg h]
    exact hb.trans_le (upperGrid_ge N hN (p b))

/-- No probability mass is created or destroyed by rounding: the
anchor debit exactly balances the non-anchor rounding increments. -/
theorem roundedMass_sum (N : ℕ) (p : α → ℝ) (a : α) :
    (∑ b : α, roundedMass N p a b) = ∑ b : α, p b := by
  classical
  let E : Finset α := Finset.univ.erase a
  have hsplit (f : α → ℝ) :
      (∑ b : α, f b) = (∑ b ∈ E, f b) + f a := by
    simpa [E] using (Finset.sum_erase_add (Finset.mem_univ a) (f := f)).symm
  have hE (b : α) (hb : b ∈ E) : b ≠ a :=
    (Finset.mem_erase.mp hb).1
  have hother :
      (∑ b ∈ E, roundedMass N p a b) =
        ∑ b ∈ E, upperGrid N (p b) := by
    apply Finset.sum_congr rfl
    intro b hb
    simp [roundedMass, hE b hb]
  have hinc :
      (∑ b ∈ E, increment N (p b)) =
        (∑ b ∈ E, upperGrid N (p b)) -
          (∑ b ∈ E, p b) := by
    simp_rw [increment]
    rw [Finset.sum_sub_distrib]
  calc
    (∑ b : α, roundedMass N p a b) =
        (∑ b ∈ E, roundedMass N p a b) + roundedMass N p a a := hsplit _
    _ = (∑ b ∈ E, upperGrid N (p b)) +
          (p a - ∑ b ∈ E, increment N (p b)) := by
          rw [hother]
          simp [roundedMass, E]
    _ = (∑ b ∈ E, p b) + p a := by
          rw [hinc]
          ring
    _ = ∑ b : α, p b := (hsplit p).symm


/-- A normalized finite source always has an anchor that can cover every
nonanchor one-grid-unit rounding budget once N exceeds alphabet-size squared.
This is the complete finite pigeonhole step; it requires NO atom floor. -/
theorem exists_anchor_room (N : ℕ) (hN : 0 < N)
    (hgrid : (Fintype.card α : ℝ) ^ 2 < (N : ℝ))
    (p : α → ℝ) (hpSum : (∑ a : α, p a) = 1) :
    ∃ a : α,
      (∑ b ∈ Finset.univ.erase a, (1 : ℝ) / (N : ℝ)) < p a := by
  classical
  let A : ℝ := Fintype.card α
  have hn : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hbudget (a : α) :
      (∑ b ∈ Finset.univ.erase a, (1 : ℝ) / (N : ℝ)) ≤
        A / (N : ℝ) := by
    let E : Finset α := Finset.univ.erase a
    have hsubset : E ⊆ (Finset.univ : Finset α) := by
      intro b hb
      exact Finset.mem_univ b
    have hcNat : E.card ≤ Fintype.card α := by
      simpa using Finset.card_le_card hsubset
    have hc : (E.card : ℝ) ≤ A := by
      exact_mod_cast hcNat
    calc
      (∑ b ∈ Finset.univ.erase a, (1 : ℝ) / (N : ℝ)) =
          (E.card : ℝ) * (1 / (N : ℝ)) := by
            simp [E, nsmul_eq_mul]
      _ ≤ A * (1 / (N : ℝ)) :=
          mul_le_mul_of_nonneg_right hc (by positivity)
      _ = A / (N : ℝ) := by ring
  have hsmall : A * (A / (N : ℝ)) < 1 := by
    have hsq : A * A < (N : ℝ) := by
      simpa [A, pow_two] using hgrid
    calc
      A * (A / (N : ℝ)) = (A * A) / (N : ℝ) := by ring
      _ < 1 := (div_lt_iff₀ hn).2 (by nlinarith)
  by_contra h
  push_neg at h
  have hpUpper (a : α) : p a ≤ A / (N : ℝ) :=
    (h a).trans (hbudget a)
  have hsumUpper : (∑ a : α, p a) ≤
      ∑ _a : α, A / (N : ℝ) :=
    Finset.sum_le_sum (fun a _ => hpUpper a)
  have hconst : (∑ _a : α, A / (N : ℝ)) =
      A * (A / (N : ℝ)) := by
    simp [A, nsmul_eq_mul]
  rw [hpSum, hconst] at hsumUpper
  linarith

/-- Universal finite one-sided rounded law, including zero source atoms,
with no additional anchor supplied by the caller. -/
theorem exists_rounded_law (N : ℕ) (hN : 0 < N)
    (hgrid : (Fintype.card α : ℝ) ^ 2 < (N : ℝ))
    (p : α → ℝ) (hp : ∀ b, 0 ≤ p b)
    (hpSum : (∑ b : α, p b) = 1) :
    ∃ a : α,
      (∀ b, 0 ≤ roundedMass N p a b) ∧
      (∑ b : α, roundedMass N p a b) = 1 ∧
      (∀ b, 0 < p b → 0 < roundedMass N p a b) := by
  obtain ⟨a, ha⟩ := exists_anchor_room N hN hgrid p hpSum
  refine ⟨a, ?_, ?_, ?_⟩
  · exact roundedMass_nonneg N hN p hp a ha
  · rw [roundedMass_sum]
    exact hpSum
  · intro b hb
    exact roundedMass_support N hN p hp a ha b hb

end Nightfall.StrongDyadicRounding

#print axioms Nightfall.StrongDyadicRounding.upperGrid_ge
#print axioms Nightfall.StrongDyadicRounding.upperGrid_lt
#print axioms Nightfall.StrongDyadicRounding.increment_nonneg
#print axioms Nightfall.StrongDyadicRounding.increment_lt
#print axioms Nightfall.StrongDyadicRounding.anchor_survives

#print axioms Nightfall.StrongDyadicRounding.roundedMass_nonneg
#print axioms Nightfall.StrongDyadicRounding.roundedMass_support
#print axioms Nightfall.StrongDyadicRounding.roundedMass_sum

#print axioms Nightfall.StrongDyadicRounding.exists_anchor_room
#print axioms Nightfall.StrongDyadicRounding.exists_rounded_law
