import Mathlib

/-!
# Nonnegative interaction support sums: the set-function end of quantum ANOVA

A product-average quantum estimator must first be shown to admit a nonnegative
orthogonal support decomposition. This file proves the consequent universal
monotonicity/supermodularity *without* assuming any unproved quantum identity.
It is not the end-to-end physical Personick/conditional-expectation terminal.
-/

namespace Nightfall.Quantum.PositiveSupportANOVA

variable {ι : Type*} [DecidableEq ι] [Fintype ι]

def supportGain (gamma : Finset ι → ℝ) (Q : Finset ι) : ℝ :=
  ∑ S ∈ (Finset.univ : Finset ι).powerset,
    if S ⊆ Q then gamma S else 0

theorem supportGain_mono
    (gamma : Finset ι → ℝ)
    (hgamma : ∀ S, 0 ≤ gamma S)
    (A B : Finset ι) (hAB : A ⊆ B) :
    supportGain gamma A ≤ supportGain gamma B := by
  unfold supportGain
  apply Finset.sum_le_sum
  intro S hS
  by_cases hA : S ⊆ A
  · have hB : S ⊆ B := hA.trans hAB
    simp [hA, hB]
  · by_cases hB : S ⊆ B
    · simpa [hA, hB] using hgamma S
    · simp [hA, hB]

theorem supportGain_supermodular
    (gamma : Finset ι → ℝ)
    (hgamma : ∀ S, 0 ≤ gamma S)
    (A B : Finset ι) :
    supportGain gamma A + supportGain gamma B ≤
      supportGain gamma (A ∪ B) + supportGain gamma (A ∩ B) := by
  let U : Finset (Finset ι) := (Finset.univ : Finset ι).powerset
  have hterm (S : Finset ι) :
      (if S ⊆ A then gamma S else 0) +
          (if S ⊆ B then gamma S else 0) ≤
        (if S ⊆ A ∪ B then gamma S else 0) +
          (if S ⊆ A ∩ B then gamma S else 0) := by
    by_cases ha : S ⊆ A
    · have hu : S ⊆ A ∪ B := by
        intro j hj
        exact Finset.mem_union.mpr (Or.inl (ha hj))
      by_cases hb : S ⊆ B
      · have hi : S ⊆ A ∩ B := by
          intro j hj
          exact Finset.mem_inter.mpr ⟨ha hj, hb hj⟩
        simp [ha, hb, hu, hi]
      · have hi : ¬ S ⊆ A ∩ B := by
          intro hs
          exact hb (fun j hj => (Finset.mem_inter.mp (hs hj)).2)
        simp [ha, hb, hu, hi]
    · by_cases hb : S ⊆ B
      · have hu : S ⊆ A ∪ B := by
          intro j hj
          exact Finset.mem_union.mpr (Or.inr (hb hj))
        have hi : ¬ S ⊆ A ∩ B := by
          intro hs
          exact ha (fun j hj => (Finset.mem_inter.mp (hs hj)).1)
        simp [ha, hb, hu, hi]
      · have hi : ¬ S ⊆ A ∩ B := by
          intro hs
          exact ha (fun j hj => (Finset.mem_inter.mp (hs hj)).1)
        by_cases hu : S ⊆ A ∪ B
        · simpa [ha, hb, hu, hi] using hgamma S
        · simp [ha, hb, hu, hi]
  calc
    supportGain gamma A + supportGain gamma B =
        ∑ S ∈ U, ((if S ⊆ A then gamma S else 0) +
          (if S ⊆ B then gamma S else 0)) := by
          simp [supportGain, U, Finset.sum_add_distrib]
    _ ≤ ∑ S ∈ U, ((if S ⊆ A ∪ B then gamma S else 0) +
          (if S ⊆ A ∩ B then gamma S else 0)) := by
          apply Finset.sum_le_sum
          intro S hS
          exact hterm S
    _ = supportGain gamma (A ∪ B) +
        supportGain gamma (A ∩ B) := by
          simp [supportGain, U, Finset.sum_add_distrib]

#print axioms Nightfall.Quantum.PositiveSupportANOVA.supportGain_mono
#print axioms Nightfall.Quantum.PositiveSupportANOVA.supportGain_supermodular

end Nightfall.Quantum.PositiveSupportANOVA
