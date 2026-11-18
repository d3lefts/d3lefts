import Mathlib

/-!
# NIGHTFALL: overlapping-selector weighted row certificate

The row lemma below is an *unconditional, exact, finite source-weighted*
Cauchy-Schwarz inequality. The weights may be zero. The active address
fibers for different sites are arbitrary and MAY OVERLAP.

The scalar terminal explicitly requires original-source total-variance
and Efron--Stein hypotheses. It is NOT the end-to-end finite-product
selector theorem until those native operator hypotheses are discharged
from the product law. No universal UE2(6) conjecture is assumed/proved.

Credit: classical finite Cauchy--Schwarz, Efron--Stein, Popoviciu.
-/

namespace Nightfall.SelectorOverlap

open scoped BigOperators
open Finset

variable {Address Sample Site : Type*}
variable [Fintype Address] [Fintype Sample] [Fintype Site]
variable [DecidableEq Address] [DecidableEq Sample] [DecidableEq Site]

/-- Exact weighted Cauchy-Schwarz, including zero-weight address atoms.
No positivity floor and no disjointness are required. -/
theorem finite_weighted_cauchy
    (s : Finset Address) (p z : Address → ℝ)
    (hp : ∀ a ∈ s, 0 ≤ p a) :
    (∑ a ∈ s, p a * z a) ^ 2 ≤
      (∑ a ∈ s, p a) * (∑ a ∈ s, p a * (z a) ^ 2) := by
  have hpz : ∀ a ∈ s, (0 : ℝ) ≤ p a * (z a) ^ 2 := by
    intro a ha
    exact mul_nonneg (hp a ha) (sq_nonneg _)
  have hlocal : ∀ a ∈ s,
      (p a * z a) ^ 2 ≤ p a * (p a * (z a) ^ 2) := by
    intro a ha
    apply le_of_eq
    ring
  exact Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul
    (R := ℝ) s hp hpz hlocal

/-- For each leaf site and each original leaf-world, the selector mean
row pays the activation probability times its original-source row energy.
The active fibers can have arbitrary overlap between sites. -/
theorem finite_source_weighted_row_energy
    (p : Address → ℝ) (q : Sample → ℝ)
    (active : Address → Site → Bool)
    (z : Address → Site → Sample → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ y, 0 ≤ q y)
    (i : Site) :
    (∑ y : Sample, q y *
      (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
        p a * z a i y) ^ 2) ≤
    (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
        p a) *
      (∑ y : Sample, q y *
        (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
          p a * (z a i y) ^ 2)) := by
  let s : Finset Address := Finset.univ.filter (fun a : Address => active a i)
  have hpoint (y : Sample) :
      (∑ a ∈ s, p a * z a i y) ^ 2 ≤
        (∑ a ∈ s, p a) *
          (∑ a ∈ s, p a * (z a i y) ^ 2) :=
    finite_weighted_cauchy s p (fun a => z a i y) (by
      intro a ha
      exact hp a)
  have hsum :
      (∑ y : Sample, q y * (∑ a ∈ s, p a * z a i y) ^ 2) ≤
      ∑ y : Sample, q y *
        ((∑ a ∈ s, p a) * (∑ a ∈ s, p a * (z a i y) ^ 2)) :=
    Finset.sum_le_sum (by
      intro y hy
      exact mul_le_mul_of_nonneg_left (hpoint y) (hq y))
  calc
    (∑ y : Sample, q y *
      (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
        p a * z a i y) ^ 2) =
      ∑ y : Sample, q y * (∑ a ∈ s, p a * z a i y) ^ 2 := rfl
    _ ≤ ∑ y : Sample, q y *
      ((∑ a ∈ s, p a) * (∑ a ∈ s, p a * (z a i y) ^ 2)) := hsum
    _ = (∑ a ∈ s, p a) *
      (∑ y : Sample, q y *
        (∑ a ∈ s, p a * (z a i y) ^ 2)) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro y hy
        ring
    _ = (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)), p a) *
      (∑ y : Sample, q y *
        (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
          p a * (z a i y) ^ 2)) := rfl

/-- The row-energy inequality holds for every site simultaneously, with
the SAME original categorical weights p and the SAME source worlds q. -/
theorem finite_source_weighted_overlap_energy
    (p : Address → ℝ) (q : Sample → ℝ)
    (active : Address → Site → Bool)
    (z : Address → Site → Sample → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ y, 0 ≤ q y) :
    (∑ i : Site, ∑ y : Sample, q y *
      (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
        p a * z a i y) ^ 2) ≤
    (∑ i : Site,
      (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)), p a) *
      (∑ y : Sample, q y *
        (∑ a ∈ (Finset.univ.filter (fun a : Address => active a i)),
          p a * (z a i y) ^ 2))) := by
  exact Finset.sum_le_sum (by
    intro i hi
    exact finite_source_weighted_row_energy p q active z hp hq i)


/-- Genuine source activation budget: total leaf occupancy is the
original-address-law expectation of the active leaf-set size.
No disjointness of address rows and no lower bound on p are used. -/
theorem source_activation_budget
    (p : Address → ℝ) (active : Address → Site → Bool)
    (t : ℕ)
    (hp : ∀ a, 0 ≤ p a)
    (hnorm : (∑ a : Address, p a) = 1)
    (hcap : ∀ a : Address,
      ((Finset.univ.filter (fun i : Site => active a i)).card ≤ t)) :
    (∑ i : Site, ∑ a : Address,
      if active a i then p a else 0) ≤ (t : ℝ) := by
  let support : Address → Finset Site :=
    fun a => Finset.univ.filter (fun i : Site => active a i)
  have hrewrite :
      (∑ i : Site, ∑ a : Address,
        if active a i then p a else 0) =
      ∑ a : Address, p a * ((support a).card : ℝ) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro a ha
    calc
      (∑ i : Site, if active a i then p a else 0) =
          ∑ i ∈ support a, p a := by
            simp only [support, Finset.sum_filter]
      _ = ((support a).card : ℝ) * p a := by simp
      _ = p a * ((support a).card : ℝ) := by ring
  have hsum :
      (∑ a : Address, p a * ((support a).card : ℝ)) ≤
      ∑ a : Address, p a * (t : ℝ) := by
    apply Finset.sum_le_sum
    intro a ha
    have haCard : ((support a).card : ℝ) ≤ (t : ℝ) := by
      exact_mod_cast hcap a
    exact mul_le_mul_of_nonneg_left haCard (hp a)
  calc
    (∑ i : Site, ∑ a : Address,
      if active a i then p a else 0) =
      ∑ a : Address, p a * ((support a).card : ℝ) := hrewrite
    _ ≤ ∑ a : Address, p a * (t : ℝ) := hsum
    _ = (∑ a : Address, p a) * (t : ℝ) := by rw [Finset.sum_mul]
    _ = (t : ℝ) := by rw [hnorm, one_mul]

/-- Pure scalar budget consequence. hsource and haddr are *explicit*
conditional total-variance / original-law Efron--Stein obligations; they
are not derived from f in this declaration. -/
theorem selector_weighted_terminal_from_source_obligations
    (k : ℕ) (t B M V addressVar : ℝ)
    (activation influence : Site → ℝ)
    (hM : 0 ≤ M) (hV : 0 ≤ V) (hB : V ≤ B ^ 2)
    (haddr : addressVar ≤ (k : ℝ) * M)
    (hsource : V ≤ addressVar +
      (∑ i : Site, activation i * influence i))
    (hw : ∀ i, 0 ≤ activation i)
    (hI : ∀ i, influence i ≤ M)
    (hbudget : (∑ i : Site, activation i) ≤ t) :
    V ^ 2 ≤ ((k : ℝ) + t) * B ^ 2 * M := by
  have hcontrol :
      (∑ i : Site, activation i * influence i) ≤
        (∑ i : Site, activation i) * M := by
    calc
      _ ≤ ∑ i : Site, activation i * M :=
        Finset.sum_le_sum (by
          intro i hi
          exact mul_le_mul_of_nonneg_left (hI i) (hw i))
      _ = (∑ i : Site, activation i) * M := by rw [Finset.sum_mul]
  have hbudgetMul :
      (∑ i : Site, activation i) * M ≤ t * M :=
    mul_le_mul_of_nonneg_right hbudget hM
  have hbound : V ≤ ((k : ℝ) + t) * M := by
    nlinarith [hsource, haddr, hcontrol, hbudgetMul]
  have hp1 : V * V ≤ B ^ 2 * V :=
    mul_le_mul_of_nonneg_right hB hV
  have hp2 : B ^ 2 * V ≤ B ^ 2 * (((k : ℝ) + t) * M) :=
    mul_le_mul_of_nonneg_left hbound (sq_nonneg B)
  nlinarith [hp1, hp2]

#print axioms Nightfall.SelectorOverlap.finite_weighted_cauchy
#print axioms Nightfall.SelectorOverlap.finite_source_weighted_row_energy
#print axioms Nightfall.SelectorOverlap.finite_source_weighted_overlap_energy
#print axioms Nightfall.SelectorOverlap.source_activation_budget
#print axioms Nightfall.SelectorOverlap.selector_weighted_terminal_from_source_obligations

end Nightfall.SelectorOverlap
