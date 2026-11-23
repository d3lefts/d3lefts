import Mathlib

/-!
# NIGHTFALL T2 — original-label heavy queries and finite uniform tail terminal

This formalizes the *actual nonadaptive classical query protocol* from the
unrestricted complex T2 manuscript, independently of the still-unformalized
quantum frame-to-Walsh Fourier tail estimate.

Heavy labels are chosen before the hidden secret is revealed, exclusively
from an original legal set R. With p,q nonnegative and independently
normalized, the set has cardinality * eta <= 2. The second theorem is
the uniform finite-source quadratic-tail-to-probability conversion for a
deterministic function of exactly those queried original labels.

The L2 Fourier tail itself must be proved from the genuine quantum
operator paths, not assumed as an axiom or silently promoted.
-/

namespace Nightfall.StructuralInformation.T2HeavyQuery

open Finset

variable {D : Type*} [Fintype D] [DecidableEq D]

/-- Choose only legal original labels with large first- or second-stage
incoherent mass; zero oracle label is never charged unless it is legal. -/
noncomputable def heavyLabels
    (R : Finset D) (p q : D → ℝ) (eta : ℝ) : Finset D :=
  R.filter (fun a => eta ≤ p a ∨ eta ≤ q a)

theorem heavyLabels_subset_legal
    (R : Finset D) (p q : D → ℝ) (eta : ℝ) :
    heavyLabels R p q eta ⊆ R := by
  intro a ha
  exact (Finset.mem_filter.mp ha).1

/-- Count the heavy original rows directly from stage-normalized
incoherent mass, without charging synthetic XOR labels. -/
theorem heavy_query_mass_budget
    (R : Finset D) (p q : D → ℝ) (eta : ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ a, 0 ≤ q a)
    (hp1 : (∑ a ∈ R, p a) ≤ 1)
    (hq1 : (∑ a ∈ R, q a) ≤ 1) :
    ((heavyLabels R p q eta).card : ℝ) * eta ≤ 2 := by
  classical
  let H := heavyLabels R p q eta
  have hsubset : H ⊆ R := heavyLabels_subset_legal R p q eta
  have hh : ∀ a ∈ H, eta ≤ p a + q a := by
    intro a ha
    have hheavy := (Finset.mem_filter.mp ha).2
    change eta ≤ p a ∨ eta ≤ q a at hheavy
    rcases hheavy with h | h
    · linarith [hq a]
    · linarith [hp a]
  have hfirst : (H.card : ℝ) * eta ≤ ∑ a ∈ H, (p a + q a) := by
    calc
      (H.card : ℝ) * eta = ∑ a ∈ H, eta := by simp
      _ ≤ ∑ a ∈ H, (p a + q a) := by
        apply Finset.sum_le_sum
        intro a ha
        exact hh a ha
  have hpsum : (∑ a ∈ H, p a) ≤ ∑ a ∈ R, p a := by
    apply Finset.sum_le_sum_of_subset_of_nonneg hsubset
    intro a ha hnot
    exact hp a
  have hqsum : (∑ a ∈ H, q a) ≤ ∑ a ∈ R, q a := by
    apply Finset.sum_le_sum_of_subset_of_nonneg hsubset
    intro a ha hnot
    exact hq a
  have htotal : (∑ a ∈ H, (p a + q a)) ≤ 2 := by
    rw [Finset.sum_add_distrib]
    linarith
  exact hfirst.trans htotal

theorem heavy_query_card_real
    (R : Finset D) (p q : D → ℝ) (eta : ℝ)
    (heta : 0 < eta)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ a, 0 ≤ q a)
    (hp1 : (∑ a ∈ R, p a) ≤ 1)
    (hq1 : (∑ a ∈ R, q a) ≤ 1) :
    ((heavyLabels R p q eta).card : ℝ) ≤ 2 / eta := by
  apply (le_div_iff₀ heta).mpr
  exact heavy_query_mass_budget R p q eta hp hq hp1 hq1

variable {S : Type*} [Fintype S]

/-- An actual answer transcript consisting *only* of observed legal
characters. This function does not inspect any unqueried row. -/
def observed
    (R : Finset D) (response : D → S → Bool)
    (s : S) : (↑R → Bool) :=
  fun h => response h.1 s

/-- Bad secrets, with the estimator depending exclusively on the
fixed, preselected original-label answer transcript. -/
noncomputable def badSecrets
    (R : Finset D) (response : D → S → Bool)
    (f : S → ℝ) (g : (↑R → Bool) → ℝ)
    (eps : ℝ) : Finset S :=
  Finset.univ.filter
    (fun s => eps < |f s - g (observed R response s)|)

/-- The source-independent last quantitative step of T2:
uniform-secret L2 control implies at most delta bad mass.
No secret-dependent/adaptive selection and no non-original labels.
The energy bound here is a *legitimate, visible theorem hypothesis*:
the missing quantum Fourier estimate must separately establish it. -/
theorem finite_markov_actual_legal_queries
    (R : Finset D) (response : D → S → Bool)
    (f : S → ℝ) (g : (↑R → Bool) → ℝ)
    (eps delta : ℝ) (heps : 0 < eps)
    (henergy :
       (∑ s : S, (f s - g (observed R response s)) ^ 2) ≤
       (Fintype.card S : ℝ) * eps ^ 2 * delta) :
    ((badSecrets R response f g eps).card : ℝ) ≤
      (Fintype.card S : ℝ) * delta := by
  classical
  let B := badSecrets R response f g eps
  let z : S → ℝ := fun s => f s - g (observed R response s)
  have hbad : ∀ s ∈ B, eps ^ 2 ≤ z s ^ 2 := by
    intro s hs
    have hs' : eps < |z s| :=
      (Finset.mem_filter.mp hs).2
    have hsq : eps ^ 2 ≤ |z s| ^ 2 :=
      (sq_le_sq₀ heps.le (abs_nonneg _)).mpr hs'.le
    simpa only [sq_abs] using hsq
  have hfirst : (B.card : ℝ) * eps ^ 2 ≤ ∑ s ∈ B, z s ^ 2 := by
    calc
      (B.card : ℝ) * eps ^ 2 = ∑ s ∈ B, eps ^ 2 := by simp
      _ ≤ ∑ s ∈ B, z s ^ 2 := by
        apply Finset.sum_le_sum
        intro s hs
        exact hbad s hs
  have hsecond : (∑ s ∈ B, z s ^ 2) ≤ ∑ s : S, z s ^ 2 := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
    intro s hs hnot
    exact sq_nonneg (z s)
  have hthird : (∑ s : S, z s ^ 2) ≤
      (Fintype.card S : ℝ) * eps ^ 2 * delta := by
    simpa only [z] using henergy
  have hmul :
      (B.card : ℝ) * eps ^ 2 ≤
        ((Fintype.card S : ℝ) * delta) * eps ^ 2 := by
    calc
      (B.card : ℝ) * eps ^ 2 ≤ ∑ s ∈ B, z s ^ 2 := hfirst
      _ ≤ ∑ s : S, z s ^ 2 := hsecond
      _ ≤ (Fintype.card S : ℝ) * eps ^ 2 * delta := hthird
      _ = ((Fintype.card S : ℝ) * delta) * eps ^ 2 := by ring
  by_contra hn
  have hstrict : (Fintype.card S : ℝ) * delta < (B.card : ℝ) :=
    lt_of_not_ge hn
  have hpositive :
      0 < ((B.card : ℝ) - (Fintype.card S : ℝ) * delta) *
          eps ^ 2 :=
    mul_pos (sub_pos.mpr hstrict) (pow_pos heps 2)
  nlinarith

#print axioms Nightfall.StructuralInformation.T2HeavyQuery.heavy_query_mass_budget
#print axioms Nightfall.StructuralInformation.T2HeavyQuery.heavy_query_card_real
#print axioms Nightfall.StructuralInformation.T2HeavyQuery.finite_markov_actual_legal_queries

end Nightfall.StructuralInformation.T2HeavyQuery
