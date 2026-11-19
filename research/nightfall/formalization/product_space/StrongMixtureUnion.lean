import Mathlib

/-!
# Frozen mixture tournament: finite event and source-weight union bounds

An actual finite probability-space bridge, rather than only scalar error
budget arithmetic.  This module assumes per-component bad-event bounds
and per-ordered-pair loss-event bounds; these must be supplied by the
product simulator and likelihood/Hellinger classifier.

It does not assume equal mixture weights or equal posterior leaf weights.
No `sorry`, global axioms or simulator existence assumption is introduced.
-/

namespace Nightfall.StrongMixtureUnion

open Finset

noncomputable def eventIndicator (E : Prop) : ℝ := by
  classical
  exact if E then 1 else 0

theorem indicator_nonneg (E : Prop) : 0 ≤ eventIndicator E := by
  classical
  by_cases h : E <;> simp [eventIndicator, h]

/-- The error event must be covered by either local simulation failure or
one of the frozen pair-duel losses. Then its indicator is bounded by the
sum of those event indicators. This is a deterministic set-theoretic fact. -/
theorem indicator_union_bound
    {J : Type*} (s : Finset J)
    (E A : Prop) (L : J → Prop)
    (hcover : E → A ∨ ∃ j ∈ s, L j) :
    eventIndicator E ≤ eventIndicator A +
      ∑ j ∈ s, eventIndicator (L j) := by
  classical
  have hsum0 : 0 ≤ ∑ j ∈ s, eventIndicator (L j) :=
    Finset.sum_nonneg (fun j hj => indicator_nonneg (L j))
  have ha0 := indicator_nonneg A
  change 0 ≤ (if A then (1 : ℝ) else 0) at ha0
  change 0 ≤ ∑ j ∈ s, (if L j then (1 : ℝ) else 0) at hsum0
  by_cases he : E
  · rcases hcover he with ha | ⟨j, hj, hlj⟩
    · simp [eventIndicator, he, ha]
    · have heq : eventIndicator (L j) = 1 := by simp [eventIndicator, hlj]
      have heqsum : ∑ k ∈ s, eventIndicator (L k) =
            (∑ k ∈ s.erase j, eventIndicator (L k)) +
              eventIndicator (L j) :=
        (Finset.sum_erase_add s (fun k => eventIndicator (L k)) hj).symm
      have hrest : 0 ≤ ∑ k ∈ s.erase j, eventIndicator (L k) :=
        Finset.sum_nonneg (fun k hk => indicator_nonneg (L k))
      have hbig : 1 ≤ ∑ k ∈ s, eventIndicator (L k) := by
        rw [heqsum, heq]
        linarith
      change 1 ≤ (if A then (1 : ℝ) else 0) +
        ∑ k ∈ s, (if L k then (1 : ℝ) else 0)
      change 1 ≤ ∑ k ∈ s, (if L k then (1 : ℝ) else 0) at hbig
      linarith
  · change (if E then (1 : ℝ) else 0) ≤
      (if A then (1 : ℝ) else 0) +
        ∑ k ∈ s, (if L k then (1 : ℝ) else 0)
    rw [if_neg he]
    linarith

/-- A finite nonnegative source law obeys an error mass union bound using
the exact event predicates. The tested pairs are fixed before their
outcomes and may have overlapping queried coordinates. -/
theorem component_failure_le
    {J Ω : Type*} [Fintype Ω]
    (s : Finset J) (P : Ω → ℝ)
    (E A : Ω → Prop) (L : J → Ω → Prop)
    (ρ β : ℝ)
    (hP : ∀ x, 0 ≤ P x)
    (hcover : ∀ x, E x → A x ∨ ∃ j ∈ s, L j x)
    (hown : (∑ x : Ω, P x * eventIndicator (A x)) ≤ ρ)
    (hpair : ∀ j ∈ s,
      (∑ x : Ω, P x * eventIndicator (L j x)) ≤ β) :
    (∑ x : Ω, P x * eventIndicator (E x)) ≤
      ρ + (s.card : ℝ) * β := by
  classical
  have hp : ∀ x : Ω, P x * eventIndicator (E x) ≤
      P x * (eventIndicator (A x) +
        ∑ j ∈ s, eventIndicator (L j x)) := by
    intro x
    exact mul_le_mul_of_nonneg_left
      (indicator_union_bound s (E x) (A x) (fun j => L j x)
        (hcover x)) (hP x)
  have hsum : (∑ x : Ω, P x * eventIndicator (E x)) ≤
      (∑ x : Ω, P x * eventIndicator (A x)) +
      (∑ j ∈ s, ∑ x : Ω, P x * eventIndicator (L j x)) := by
    calc
      (∑ x : Ω, P x * eventIndicator (E x))
          ≤ ∑ x : Ω, P x *
            (eventIndicator (A x) +
              ∑ j ∈ s, eventIndicator (L j x)) :=
                Finset.sum_le_sum (fun x _ => hp x)
      _ = (∑ x : Ω, P x * eventIndicator (A x)) +
          (∑ j ∈ s, ∑ x : Ω, P x * eventIndicator (L j x)) := by
        simp only [mul_add, Finset.sum_add_distrib, Finset.mul_sum]
        rw [Finset.sum_comm]
  calc
    (∑ x : Ω, P x * eventIndicator (E x))
        ≤ (∑ x : Ω, P x * eventIndicator (A x)) +
            (∑ j ∈ s, ∑ x : Ω, P x * eventIndicator (L j x)) := hsum
    _ ≤ ρ + ∑ _j ∈ s, β := by
      apply add_le_add hown
      exact Finset.sum_le_sum (fun j hj => hpair j hj)
    _ = ρ + (s.card : ℝ) * β := by simp

/-- The finite source-mixture identity for an arbitrary event. Mixture
weights may be zero, and no independence assumption is needed for this
purely measure-theoretic averaging identity. -/
theorem mixture_event_mass_eq
    {J Ω : Type*} [Fintype J] [Fintype Ω]
    (w : J → ℝ) (P : J → Ω → ℝ) (E : Ω → Prop) :
    (∑ x : Ω, (∑ j : J, w j * P j x) * eventIndicator (E x)) =
    ∑ j : J, w j * (∑ x : Ω, P j x * eventIndicator (E x)) := by
  classical
  calc
    (∑ x : Ω, (∑ j : J, w j * P j x) * eventIndicator (E x)) =
      ∑ x : Ω, ∑ j : J, w j * (P j x * eventIndicator (E x)) := by
        apply Finset.sum_congr rfl
        intro x hx
        rw [Finset.sum_mul]
        apply Finset.sum_congr rfl
        intro j hj
        ring
    _ = ∑ j : J, ∑ x : Ω,
          w j * (P j x * eventIndicator (E x)) := Finset.sum_comm
    _ = ∑ j : J, w j * (∑ x : Ω, P j x * eventIndicator (E x)) := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [Finset.mul_sum]

/-- If each latent component has error mass at most B, then so does the
full mixture; this theorem treats the entire mixture, not an average of
posterior normalized conditional errors. -/
theorem mixture_event_mass_le
    {J Ω : Type*} [Fintype J] [Fintype Ω]
    (w : J → ℝ) (P : J → Ω → ℝ)
    (E : Ω → Prop) (B : ℝ)
    (hw : ∀ j, 0 ≤ w j)
    (hwsum : (∑ j : J, w j) = 1)
    (hcomponent : ∀ j : J,
      (∑ x : Ω, P j x * eventIndicator (E x)) ≤ B) :
    (∑ x : Ω, (∑ j : J, w j * P j x) *
      eventIndicator (E x)) ≤ B := by
  rw [mixture_event_mass_eq]
  calc
    (∑ j : J, w j * (∑ x : Ω, P j x * eventIndicator (E x))) ≤
      ∑ j : J, w j * B := by
        apply Finset.sum_le_sum
        intro j hj
        exact mul_le_mul_of_nonneg_left (hcomponent j) (hw j)
    _ = (∑ j : J, w j) * B := by rw [Finset.sum_mul]
    _ = B := by rw [hwsum, one_mul]

end Nightfall.StrongMixtureUnion
