import Route1MaximalConditionalKernel
import Route1StarCoupling

/-!
# Route 1: constructive finite reference-star maximal coupling

Compiles the exact pair-maximal kernel and the simultaneous star
construction into a source-law theorem with no assumed kernel.

This is a finite coordinate-level construction, NOT the full
polylog-M decision-tree simulation theorem.
-/

namespace Nightfall.Route1StarMaximalBridge

open Finset
open Nightfall.Route1FiniteMaxCoupling
open Nightfall.Route1StarCoupling

variable {Θ A : Type*} [Fintype Θ] [DecidableEq Θ]
  [Fintype A] [DecidableEq A]

noncomputable def canonicalStarKernel
    (p : A → ℝ) (q : Θ → A → ℝ) (θ : Θ) (a b : A) : ℝ :=
  maximalKernel p (q θ) a b

theorem canonicalStarKernel_nonneg
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hq0 : ∀ θ a, 0 ≤ q θ a)
    (θ : Θ) (a b : A) :
    0 ≤ canonicalStarKernel p q θ a b :=
  maximalKernel_nonneg p (q θ) hp0 (hq0 θ) a b

theorem canonicalStarKernel_sum
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ a, q θ a) = 1)
    (θ : Θ) (a : A) :
    (∑ b, canonicalStarKernel p q θ a b) = 1 :=
  maximalKernel_row p (q θ) hp (hq θ) a

theorem canonicalStarKernel_push
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hq0 : ∀ θ a, 0 ≤ q θ a)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ a, q θ a) = 1)
    (θ : Θ) (b : A) :
    (∑ a, p a * canonicalStarKernel p q θ a b) = q θ b :=
  maximalKernel_push p (q θ) hp0 (hq0 θ) hp (hq θ) b

theorem canonicalStarMass_reference
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ a, q θ a) = 1)
    (a : A) :
    (∑ bs : Θ → A,
      starMass p (canonicalStarKernel p q) a bs) = p a :=
  starMass_reference p (canonicalStarKernel p q)
    (canonicalStarKernel_sum p q hp hq) a

theorem canonicalStarMass_component
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hq0 : ∀ θ a, 0 ≤ q θ a)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ a, q θ a) = 1)
    (θ : Θ) (b : A) :
    (∑ a : A, ∑ bs : Θ → A,
      if bs θ = b then
        starMass p (canonicalStarKernel p q) a bs else 0) = q θ b :=
  starMass_component p q (canonicalStarKernel p q)
    (canonicalStarKernel_sum p q hp hq)
    (canonicalStarKernel_push p q hp0 hq0 hp hq) θ b

theorem canonicalStarMass_mismatch
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hq0 : ∀ θ a, 0 ≤ q θ a)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ a, q θ a) = 1)
    (θ : Θ) :
    (∑ a : A, ∑ bs : Θ → A,
      if bs θ = a then 0 else
        starMass p (canonicalStarKernel p q) a bs) =
      mismatchMass p (q θ) := by
  classical
  let K : Θ → A → A → ℝ := canonicalStarKernel p q
  have hK : ∀ θ a, (∑ b, K θ a b) = 1 :=
    canonicalStarKernel_sum p q hp hq
  change (∑ a : A, ∑ bs : Θ → A,
    if bs θ = a then 0 else starMass p K a bs) =
    mismatchMass p (q θ)
  calc
    (∑ a : A, ∑ bs : Θ → A,
      if bs θ = a then 0 else starMass p K a bs) =
      ∑ a : A, (p a - p a * K θ a a) := by
        apply Finset.sum_congr rfl
        intro a _
        calc
          (∑ bs : Θ → A, if bs θ = a then 0 else starMass p K a bs) =
            (∑ bs : Θ → A, starMass p K a bs) -
            (∑ bs : Θ → A,
              if bs θ = a then starMass p K a bs else 0) := by
                rw [← Finset.sum_sub_distrib]
                apply Finset.sum_congr rfl
                intro bs _
                by_cases hab : bs θ = a <;> simp [hab]
          _ = p a - p a * K θ a a := by
                rw [starMass_reference p K hK a]
                rw [starMass_pair p K hK a θ a]
    _ = 1 - ∑ a : A, p a * K θ a a := by
          rw [Finset.sum_sub_distrib, hp]
    _ = 1 - ∑ a : A, overlap p (q θ) a := by
          congr 1
          apply Finset.sum_congr rfl
          intro a _
          calc
            p a * K θ a a = pairMass p (q θ) a a :=
              maximalKernel_weighted_pair p (q θ)
                hp0 (hq0 θ) hp (hq θ) a a
            _ = overlap p (q θ) a :=
              pairMass_diag_normalized p (q θ) hp (hq θ) a
    _ = mismatchMass p (q θ) :=
      (mismatchMass_eq_one_sub_overlap p (q θ) hp).symm

/-- No existentially assumed conditional kernel: the exact
    common-reference joint probability is produced constructively. -/
theorem finite_star_maximal_exists
    (p : A → ℝ) (q : Θ → A → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hq0 : ∀ θ a, 0 ≤ q θ a)
    (hp : (∑ a, p a) = 1)
    (hq : ∀ θ, (∑ a, q θ a) = 1) :
    ∃ K : Θ → A → A → ℝ,
      (∀ θ a b, 0 ≤ K θ a b) ∧
      (∀ θ a, (∑ b, K θ a b) = 1) ∧
      (∀ a, (∑ bs : Θ → A, starMass p K a bs) = p a) ∧
      (∀ θ b, (∑ a : A, ∑ bs : Θ → A,
        if bs θ = b then starMass p K a bs else 0) = q θ b) ∧
      (∀ θ, (∑ a : A, ∑ bs : Θ → A,
        if bs θ = a then 0 else starMass p K a bs) =
        mismatchMass p (q θ)) := by
  refine ⟨canonicalStarKernel p q, ?_, ?_, ?_, ?_, ?_⟩
  · exact canonicalStarKernel_nonneg p q hp0 hq0
  · exact canonicalStarKernel_sum p q hp hq
  · exact canonicalStarMass_reference p q hp hq
  · exact canonicalStarMass_component p q hp0 hq0 hp hq
  · exact canonicalStarMass_mismatch p q hp0 hq0 hp hq

end Nightfall.Route1StarMaximalBridge

#print axioms Nightfall.Route1StarMaximalBridge.canonicalStarKernel_sum
#print axioms Nightfall.Route1StarMaximalBridge.canonicalStarMass_component
#print axioms Nightfall.Route1StarMaximalBridge.canonicalStarMass_mismatch
#print axioms Nightfall.Route1StarMaximalBridge.finite_star_maximal_exists
