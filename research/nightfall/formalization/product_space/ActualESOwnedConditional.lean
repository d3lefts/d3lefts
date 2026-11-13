import ActualESConditionalSection
import ActualESConditionalProjection

/-!
# Actual conditional-source section identity for arbitrary observed sites

The original finite source f has real Efron–Stein degree at most two.
For a fixed coordinate i and output symbol a, its genuine centered
section U_i(a; X_{-i}) is conditionally averaged over the exact set N of
observed neighbors. The result retains exactly those canonical
Hoeffding components containing i whose remaining support lies in N.

This is the actual *conditional-expectation representation*, not an
ideal independent-copy experiment, a supplied ANOVA decomposition, or
a supplied Jensen budget. No atom floor or fairness assumption.

An owner i with selected distinct-neighbor set N_i can specialize this
theorem; invoking the Hilbert fourth moment additionally requires
identifying the finite owned-neighbor product laws and source energies.
-/

namespace Nightfall.Observability.ActualESOwnedConditional

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESConditionalSection
open Nightfall.Observability.ActualESConditionalProjection
open Nightfall.Observability.ActualESPairMatching

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Conditioning a source component after fixing its output coordinate
retains it whenever all its other support coordinates are observed. -/
theorem actual_fixed_component_visible
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (a : α) (N U : Finset ι)
    (hsub : U.erase i ⊆ N) (x : ι → α) :
    condExp p N
      (fun y => esComp p U f (Function.update y i a)) x =
      esComp p U f (Function.update x i a) := by
  have hconstant (y : ι → α) :
      esComp p U f (Function.update (merge N x y) i a) =
        esComp p U f (Function.update x i a) := by
    apply esComp_dependsOn p U f
    intro k hk
    by_cases hki : k = i
    · subst k
      simp
    · have hkN : k ∈ N := hsub (Finset.mem_erase.mpr ⟨hki, hk⟩)
      simp [merge, hkN, hki]
  unfold condExp
  simp_rw [hconstant]
  rw [← Finset.sum_mul, sum_prodMass' p hp1, one_mul]

/-- When a different source-support coordinate is hidden, the fixed-i
canonical component has zero conditional expectation by its genuine
Hoeffding degeneracy in that hidden coordinate. -/
theorem actual_fixed_component_hidden
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (i k : ι) (hki : k ≠ i)
    (a : α) (N U : Finset ι)
    (hkU : k ∈ U) (hkN : k ∉ N) (x : ι → α) :
    condExp p N
      (fun y => esComp p U f (Function.update y i a)) x = 0 := by
  have hcomm (y : ι → α) (b : α) :
      Function.update (merge N x (Function.update y k b)) i a =
        Function.update
          (Function.update (merge N x y) i a) k b := by
    rw [merge_update_outside N k hkN x y b]
    exact Function.update_comm hki b a (merge N x y)
  have hcenter (y : ι → α) :
      (∑ b : α, p k b * esComp p U f
        (Function.update
          (Function.update (merge N x y) i a) k b)) = 0 :=
    actual_esComp_centered p hp1 f U k hkU
      (Function.update (merge N x y) i a)
  unfold condExp
  calc
    (∑ y : ι → α, prodMass p y *
      esComp p U f (Function.update (merge N x y) i a)) =
      (∑ y : ι → α, ∑ b : α,
        prodMass p y * p k b *
          esComp p U f
            (Function.update
              (merge N x (Function.update y k b)) i a)) :=
        (resample_sum p hp1 k
          (fun y => esComp p U f
            (Function.update (merge N x y) i a))).symm
    _ = ∑ y : ι → α, prodMass p y *
        (∑ b : α, p k b *
          esComp p U f
            (Function.update
              (Function.update (merge N x y) i a) k b)) := by
        apply Finset.sum_congr rfl
        intro y _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro b _
        rw [hcomm y b]
        ring
    _ = 0 := by simp [hcenter]

/-- The exact conditional projection of the genuine centered section.
For an arbitrary observed set N, only its original degree<=2 source
components supported on i together with sites in N survive.

This theorem contains NO supplied section representation, conditional
expectation equality, independent-copy law, or moment budget.
-/
theorem actual_source_conditional_centered_section
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ b : α, p k b) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (a : α)
    (N : Finset ι) (x : ι → α) :
    condExp p N
      (fun y => actualCenteredSection p f i y a) x =
      ∑ U : Finset ι,
        if U.card ≤ 2 ∧ i ∈ U ∧ U.erase i ⊆ N then
          esComp p U f (Function.update x i a)
        else 0 := by
  classical
  have hsource (y : ι → α) :
      actualCenteredSection p f i y a =
        ∑ U : Finset ι,
          if U.card ≤ 2 ∧ i ∈ U then
            esComp p U f (Function.update y i a) else 0 :=
    actual_centered_section_eq_hilbert_ANOVA p hp1 f hdegree i y a
  let G : Finset ι → (ι → α) → ℝ :=
    fun U y => if U.card ≤ 2 ∧ i ∈ U then
      esComp p U f (Function.update y i a) else 0
  have hlin :
      condExp p N (fun y => actualCenteredSection p f i y a) x =
        ∑ U : Finset ι, condExp p N (G U) x := by
    calc
      condExp p N (fun y => actualCenteredSection p f i y a) x =
        condExp p N (fun y => ∑ U : Finset ι, G U y) x := by
          congr 1
          funext y
          simpa only [G] using hsource y
      _ = ∑ U : Finset ι, condExp p N (G U) x :=
          actual_condExp_sum p N G x
  rw [hlin]
  apply Finset.sum_congr rfl
  intro U _
  by_cases hcard : U.card ≤ 2
  · by_cases hi : i ∈ U
    · by_cases hsub : U.erase i ⊆ N
      · simpa [G, hcard, hi, hsub] using
          (actual_fixed_component_visible
            p hp1 f i a N U hsub x)
      · have hmiss : ∃ k : ι, k ∈ U.erase i ∧ k ∉ N := by
          by_contra hnot
          apply hsub
          intro k hk
          by_contra hkn
          exact hnot ⟨k, hk, hkn⟩
        obtain ⟨k, hkErase, hkN⟩ := hmiss
        have hki : k ≠ i := (Finset.mem_erase.mp hkErase).1
        have hkU : k ∈ U := (Finset.mem_erase.mp hkErase).2
        have hzero :=
          actual_fixed_component_hidden
            p hp1 f i k hki a N U hkU hkN x
        simpa [G, hcard, hi, hsub] using hzero
    · simp [G, hcard, hi, condExp]
  · simp [G, hcard, condExp]

end Nightfall.Observability.ActualESOwnedConditional
