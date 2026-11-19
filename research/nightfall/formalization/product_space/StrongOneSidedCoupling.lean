import StrongDyadicRounding

/-!
# Exact one-sided source-to-dyadic-symbol Markov coupling

The rounded target q is constructed by upward rounding of all nonanchor
source masses, debiting a single positive anchor. This file gives the
explicit stochastic kernel C(x,y), including source-zero atoms, and proves
row normalization, nonnegativity and the exact pushforward q(y)=Σp(x)C(x,y).

A separate anchor-budget hypothesis is used. This is the actual coupling
identity, not an assumed stochastic pushforward. The universal choice of
the anchor and N from the theorem's A and epsilon/delta parameters is
tracked separately.
-/

namespace Nightfall.StrongOneSidedCoupling

open Finset
open Nightfall.StrongDyadicRounding

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- A single anchor pays all upward rounding increments.
Every nonanchor symbol remains fixed, including zero-mass symbols. -/
noncomputable def kernel (N : ℕ) (p : α → ℝ) (a x y : α) : ℝ :=
  if x = a then
    if y = a then roundedMass N p a a / p a
    else increment N (p y) / p a
  else if x = y then 1 else 0

theorem kernel_nonneg
    (N : ℕ) (hN : 0 < N) (p : α → ℝ)
    (hp : ∀ b, 0 ≤ p b) (a : α)
    (hroom : (∑ b ∈ Finset.univ.erase a, (1 : ℝ) / (N : ℝ)) < p a)
    (x y : α) :
    0 ≤ kernel N p a x y := by
  have hpa : 0 < p a := by
    have hzero : 0 ≤ (∑ b ∈ Finset.univ.erase a,
        (1 : ℝ) / (N : ℝ)) := by
      apply Finset.sum_nonneg
      intro b hb
      positivity
    linarith
  by_cases hx : x = a
  · subst x
    by_cases hy : y = a
    · subst y
      simp only [kernel, if_pos rfl]
      exact div_nonneg
        (roundedMass_nonneg N hN p hp a hroom a) hpa.le
    · simp only [kernel, if_pos rfl, if_neg hy]
      exact div_nonneg
        (increment_nonneg N hN (p y)) hpa.le
  · by_cases hxy : x = y
    · subst y
      simp [kernel, hx]
    · simp [kernel, hx, hxy]

/-- Every row is a probability law; the nonanchor rows are Dirac masses,
while the anchor row spends its rounding slack. -/
theorem kernel_sum_one
    (N : ℕ) (p : α → ℝ) (a : α)
    (hpa : 0 < p a) (x : α) :
    (∑ y : α, kernel N p a x y) = 1 := by
  classical
  by_cases hx : x = a
  · subst x
    let E : Finset α := Finset.univ.erase a
    have hsplit (f : α → ℝ) :
        (∑ y : α, f y) = (∑ y ∈ E, f y) + f a := by
      simpa [E] using
        (Finset.sum_erase_add (Finset.mem_univ a) (f := f)).symm
    have hE (y : α) (hy : y ∈ E) : y ≠ a :=
      (Finset.mem_erase.mp hy).1
    have hsum :
        (∑ y ∈ E, kernel N p a a y) =
          (∑ y ∈ E, increment N (p y)) / p a := by
      calc
        (∑ y ∈ E, kernel N p a a y) =
            ∑ y ∈ E, increment N (p y) / p a := by
              apply Finset.sum_congr rfl
              intro y hy
              simp [kernel, hE y hy]
        _ = (∑ y ∈ E, increment N (p y)) / p a := by
              rw [Finset.sum_div]
    rw [hsplit (kernel N p a a), hsum]
    have hqa : roundedMass N p a a =
        p a - ∑ y ∈ E, increment N (p y) := by
      simp [roundedMass, E]
    change (∑ y ∈ E, increment N (p y)) / p a +
      roundedMass N p a a / p a = 1
    rw [hqa]
    field_simp [ne_of_gt hpa] <;> ring
  · simp [kernel, hx]

/-- Under the source p, the constructed coupling has exactly the
dyadically rounded target marginal q. -/
theorem kernel_pushforward
    (N : ℕ) (p : α → ℝ) (a : α)
    (hpa : 0 < p a) (y : α) :
    (∑ x : α, p x * kernel N p a x y) =
      roundedMass N p a y := by
  classical
  let E : Finset α := Finset.univ.erase a
  have hsplit (f : α → ℝ) :
      (∑ x : α, f x) = (∑ x ∈ E, f x) + f a := by
    simpa [E] using
      (Finset.sum_erase_add (Finset.mem_univ a) (f := f)).symm
  have hE (x : α) (hx : x ∈ E) : x ≠ a :=
    (Finset.mem_erase.mp hx).1
  have hother :
      (∑ x ∈ E, p x * kernel N p a x y) =
        if y = a then 0 else p y := by
    calc
      (∑ x ∈ E, p x * kernel N p a x y) =
          ∑ x ∈ E, p x * (if x = y then (1 : ℝ) else 0) := by
            apply Finset.sum_congr rfl
            intro x hx
            simp [kernel, hE x hx]
      _ = if y = a then 0 else p y := by
            by_cases hy : y = a
            · subst y
              have haE : a ∉ E := by simp [E]
              simp [haE, E]
            · have hyE : y ∈ E :=
                Finset.mem_erase.mpr ⟨hy, Finset.mem_univ y⟩
              simp [hy, hyE]
  rw [hsplit (fun x => p x * kernel N p a x y), hother]
  by_cases hy : y = a
  · subst y
    change p a * (roundedMass N p a a / p a) =
      roundedMass N p a a
    field_simp [ne_of_gt hpa] <;> ring
  · change p y + p a * (increment N (p y) / p a) =
      roundedMass N p a y
    rw [show roundedMass N p a y = upperGrid N (p y) by
      simp [roundedMass, hy]]
    unfold increment
    field_simp [ne_of_gt hpa] <;> ring

end Nightfall.StrongOneSidedCoupling

#print axioms Nightfall.StrongOneSidedCoupling.kernel_nonneg
#print axioms Nightfall.StrongOneSidedCoupling.kernel_sum_one
#print axioms Nightfall.StrongOneSidedCoupling.kernel_pushforward
