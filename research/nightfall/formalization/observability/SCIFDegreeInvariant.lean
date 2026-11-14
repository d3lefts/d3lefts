import ActualSourceANOVA

/-!
# NIGHTFALL SCIF: genuine finite product Efron–Stein degree invariance

The Efron–Stein degree of a pointwise function is independent of its
normalized finite product source law, including all zero-mass atoms.
The proof is NOT a syntactic polynomial-degree assertion: it works
directly with ActualSourceANOVA.esComp and ESDegreeLE, using the
actual old canonical decomposition and the new source projectors.

No numerical bounds, external proof oracles, source importance ratios,
and no positivity floor appear.
-/

namespace Nightfall.SCIFDegreeInvariant
open Finset
open Nightfall.Observability.ActualSourceANOVA

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Source-derived finite Efron–Stein degree is invariant under
replacement of *all* product-coordinate laws. Only the old product
normalization is used to decompose f; the new projector identity
is algebraic even if the new weights are not normalized. -/
theorem degree_transport_to_any_law
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (d : ℕ)
    (hd : ESDegreeLE p f d) :
    ESDegreeLE q f d := by
  classical
  let g : Finset ι → (ι → α) → ℝ :=
    fun T z => if T.card ≤ d then esComp p T f z else 0
  have hf (z : ι → α) :
      f z = ∑ T : Finset ι, g T z := by
    calc
      f z = ∑ T : Finset ι, esComp p T f z :=
        (es_decomp p hp1 f z).symm
      _ = ∑ T : Finset ι, g T z := by
        apply Finset.sum_congr rfl
        intro T _
        by_cases hT : T.card ≤ d
        · simp [g, hT]
        · have hz : esComp p T f z = 0 :=
            hd T (by omega) z
          simp [g, hT, hz]
  intro S hS x
  have hterm (T : Finset ι) :
      esComp q S (g T) x = 0 := by
    by_cases hT : T.card ≤ d
    · have hnot : ¬ S ⊆ T := by
        intro hST
        have hc := Finset.card_le_card hST
        omega
      have hmissing : ∃ k : ι, k ∈ S ∧ k ∉ T := by
        by_contra hh
        push_neg at hh
        apply hnot
        intro i hi
        exact hh i hi
      obtain ⟨k,hkS,hkT⟩ := hmissing
      have hignored : ∀ z : ι → α, ∀ a : α,
          g T (Function.update z k a) = g T z := by
        intro z a
        change (if T.card ≤ d then
          esComp p T f (Function.update z k a) else 0) =
          (if T.card ≤ d then esComp p T f z else 0)
        simp only [if_pos hT]
        exact esComp_dependsOn p T f
          (Function.update z k a) z
          (by
            intro i hi
            have hik : i ≠ k := by
              intro h
              exact hkT (h ▸ hi)
            exact Function.update_of_ne hik a z)
      exact esComp_indep q S (g T) x k hkS hignored
    · have hzero : g T = (fun _ : ι → α => (0 : ℝ)) := by
        funext z
        simp [g, hT]
      rw [hzero]
      simp [esComp, condExp]
  have hfunc : f = (fun z => ∑ T : Finset ι, g T z) := by
    funext z
    exact hf z
  rw [hfunc]
  have hlin := esComp_lin q S
    (fun _ : Finset ι => (1 : ℝ)) g x
  simp only [one_mul] at hlin
  rw [hlin]
  simp [hterm]

/-- Exact symmetry between any two normalized finite product laws.
Zero-probability atoms are allowed on either side. -/
theorem degree_equiv_between_product_laws
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hq1 : ∀ i, (∑ a : α, q i a) = 1)
    (f : (ι → α) → ℝ) (d : ℕ) :
    ESDegreeLE p f d ↔ ESDegreeLE q f d := by
  constructor
  · exact degree_transport_to_any_law p q hp1 f d
  · exact degree_transport_to_any_law q p hq1 f d

/-- The degree-two predicate does not need re-proving after any change
of normalized product law on the same original coordinates. -/
theorem degree_two_survives_source_edit
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hd : ESDegreeLE p f 2) :
    ESDegreeLE q f 2 :=
  degree_transport_to_any_law p q hp1 f 2 hd

end Nightfall.SCIFDegreeInvariant
