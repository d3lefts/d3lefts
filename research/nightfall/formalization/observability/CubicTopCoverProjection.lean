import CubicTopCoverEnergy
import ActualSourceConditionalProjection
import ActualSourceQ2107Terminal

/-!
# Original-source cubic top-cover projection

Bridge from exact canonical finite-product Hoeffding interaction energies
to the genuine conditional expectation on the complement of a finite cover.

The target is source-only degree three with a cover meeting *all nonzero*
cubic interactions. No unrestricted cubic exponent-two claim is made.
-/

namespace Nightfall.Observability.CubicTopCoverProjection

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceConditionalProjection
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceQ2107Terminal
open Nightfall.Observability.CubicTopCoverEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Canonical components are eigenvectors of their own ANOVA projector,
and all other projectors annihilate them. -/
theorem esComp_of_esComp
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (S T : Finset ι) (x : ι → α) :
    esComp p S (esComp p T f) x =
      if S = T then esComp p T f x else 0 := by
  classical
  by_cases heq : S = T
  · subst S
    rw [if_pos rfl]
    change (∑ V ∈ T.powerset,
      (-1 : ℝ) ^ (T.card - V.card) *
        condExp p V (esComp p T f) x) = _
    rw [Finset.sum_eq_single T]
    · rw [condExp_esComp_eq_ite p hp1 f T T x]
      simp
    · intro V hV hne
      have hTV : ¬ T ⊆ V := by
        intro h
        exact hne (Finset.Subset.antisymm (Finset.mem_powerset.mp hV) h)
      rw [condExp_esComp_eq_ite p hp1 f V T x, if_neg hTV]
      ring
    · intro hn
      exact (hn (Finset.mem_powerset.mpr (subset_refl T))).elim
  · rw [if_neg heq]
    by_cases hTS : T ⊆ S
    · have hmiss : ∃ k, k ∈ S ∧ k ∉ T := by
        by_contra hn
        push_neg at hn
        apply heq
        apply Finset.Subset.antisymm
        · intro k hk
          by_contra hkt
          exact hn k hk hkt
        · exact hTS
      obtain ⟨k, hkS, hkT⟩ := hmiss
      apply esComp_indep p S (esComp p T f) x k hkS
      intro z a
      apply esComp_dependsOn p T f
      intro j hj
      have hjk : j ≠ k := by
        intro h
        exact hkT (h ▸ hj)
      exact Function.update_of_ne hjk a z
    · change (∑ V ∈ S.powerset,
        (-1 : ℝ) ^ (S.card - V.card) *
          condExp p V (esComp p T f) x) = 0
      apply Finset.sum_eq_zero
      intro V hV
      have hTV : ¬ T ⊆ V := by
        intro h
        exact hTS (h.trans (Finset.mem_powerset.mp hV))
      rw [condExp_esComp_eq_ite p hp1 f V T x, if_neg hTV]
      ring

/-- Full conditional expectation acts diagonally on exact source
Efron–Stein sectors, not merely in an abstract energy model. -/
theorem esComp_condExp
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (U S : Finset ι) (x : ι → α) :
    esComp p S (condExp p U f) x =
      if S ⊆ U then esComp p S f x else 0 := by
  classical
  have hrep : condExp p U f =
      (fun y => ∑ T : Finset ι,
        (if T ⊆ U then (1 : ℝ) else 0) * esComp p T f y) := by
    funext y
    rw [actual_condExp_es_expansion p hp1 f U y]
    apply Finset.sum_congr rfl
    intro T _
    by_cases h : T ⊆ U <;> simp [h]
  calc
    esComp p S (condExp p U f) x =
        esComp p S (fun y => ∑ T : Finset ι,
          (if T ⊆ U then (1 : ℝ) else 0) * esComp p T f y) x := by
            rw [hrep]
    _ = ∑ T : Finset ι,
        (if T ⊆ U then (1 : ℝ) else 0) *
          esComp p S (esComp p T f) x := by
            exact esComp_lin (κ := Finset ι) p S
              (fun T => if T ⊆ U then 1 else 0)
              (fun T => esComp p T f) x
    _ = ∑ T : Finset ι,
        (if T ⊆ U then (1 : ℝ) else 0) *
          (if S = T then esComp p T f x else 0) := by
            apply Finset.sum_congr rfl
            intro T _
            rw [esComp_of_esComp p hp1 f S T x]
    _ = if S ⊆ U then esComp p S f x else 0 := by
          rw [Finset.sum_eq_single S]
          · by_cases h : S ⊆ U <;> simp [h]
          · intro T _ hne
            simp [Ne.symm hne]
          · intro hn
            exact (hn (Finset.mem_univ S)).elim

/-- A set S lies outside the cover H precisely when its canonical
coordinate support is retained by conditioning on univ \ H. -/
theorem subset_complement_iff_no_touch (H S : Finset ι) :
    S ⊆ (Finset.univ \ H) ↔ ¬ touches H S := by
  constructor
  · intro h ⟨i, hiH, hiS⟩
    have hi := h hiS
    simp only [Finset.mem_sdiff, Finset.mem_univ, true_and] at hi
    exact hi hiH
  · intro h i hiS
    have hi : i ∉ H := by
      intro hiH
      exact h ⟨i, hiH, hiS⟩
    simp [hi]

/-- Sector energy transforms exactly under genuine original-source
conditional projection. -/
theorem sector_energy_condExp
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (U S : Finset ι) :
    sourceSectorEnergy p (condExp p U f) S =
      if S ⊆ U then sourceSectorEnergy p f S else 0 := by
  classical
  by_cases he : S = ∅
  · simp [sourceSectorEnergy, he]
  · by_cases h : S ⊆ U
    · rw [if_pos h]
      unfold sourceSectorEnergy
      simp only [if_neg he]
      apply Finset.sum_congr rfl
      intro x _
      rw [esComp_condExp p hp1 f U S x, if_pos h]
    · rw [if_neg h]
      unfold sourceSectorEnergy
      simp [he, esComp_condExp p hp1 f U S, h]

/-- Exactly identifies the remaining source variance with the
variance of the conditional projection, without assuming Parseval anew. -/
theorem projected_variance_eq_outside_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (H : Finset ι) :
    sourceVariance p (condExp p (Finset.univ \ H) f) =
      outsideSourceEnergy p f H := by
  classical
  rw [actual_source_variance_es_energy p hp1 (condExp p (Finset.univ \ H) f)]
  unfold outsideSourceEnergy
  apply Finset.sum_congr rfl
  intro S _
  change sourceSectorEnergy p (condExp p (Finset.univ \ H) f) S =
    (if touches H S then 0 else sourceSectorEnergy p f S)
  rw [sector_energy_condExp p hp1 f (Finset.univ \ H) S]
  by_cases h : touches H S
  · have hno : ¬ S ⊆ (Finset.univ \ H) := by
      intro hs
      exact (subset_complement_iff_no_touch H S).mp hs h
    simp [h, hno]
  · have hs : S ⊆ (Finset.univ \ H) :=
      (subset_complement_iff_no_touch H S).mpr h
    simp [h, hs]

/-- The true source influence cannot increase after conditioning on
a subset U of its coordinates. -/
theorem projected_influence_le_original
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (U : Finset ι) (i : ι) :
    sourceInfluence p (condExp p U f) i ≤ sourceInfluence p f i := by
  classical
  have hraw (g : (ι → α) → ℝ) :
      sourceInfluence p g i =
        ∑ S : Finset ι,
          if i ∈ S then sourceSectorEnergy p g S else 0 := by
    rw [original_source_influence_eq_interaction_energy p hp1 g i]
    apply Finset.sum_congr rfl
    intro S _
    by_cases hi : i ∈ S
    · have hne : S ≠ ∅ := by
        intro he
        simp [he] at hi
      simp [hi, sourceSectorEnergy, hne]
    · simp [hi]
  rw [hraw (condExp p U f), hraw f]
  apply Finset.sum_le_sum
  intro S _
  by_cases hi : i ∈ S
  · rw [if_pos hi, if_pos hi, sector_energy_condExp p hp1 f U S]
    by_cases hSU : S ⊆ U
    · simp [hSU]
    · simpa [hSU] using sourceSectorEnergy_nonneg p hp f S
  · simp [hi]

/-- A normalized finite source conditional expectation preserves the
pointwise amplitude bound, also when coordinate atoms have zero mass. -/
theorem conditional_amplitude_le
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (U : Finset ι)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B)
    (x : ι → α) :
    |condExp p U f x| ≤ B := by
  classical
  have hmass (y : ι → α) : 0 ≤ originalMass p y := by
    unfold originalMass
    exact Finset.prod_nonneg fun i _ => hp i (y i)
  have hlo (y : ι → α) : -B ≤ f (merge U x y) :=
    (abs_le.mp (hf (merge U x y))).1
  have hhi (y : ι → α) : f (merge U x y) ≤ B :=
    (abs_le.mp (hf (merge U x y))).2
  have hsumlo : (∑ y : ι → α, originalMass p y * (-B)) ≤
      ∑ y : ι → α, originalMass p y * f (merge U x y) := by
    apply Finset.sum_le_sum
    intro y _
    exact mul_le_mul_of_nonneg_left (hlo y) (hmass y)
  have hsumhi : (∑ y : ι → α, originalMass p y * f (merge U x y)) ≤
      ∑ y : ι → α, originalMass p y * B := by
    apply Finset.sum_le_sum
    intro y _
    exact mul_le_mul_of_nonneg_left (hhi y) (hmass y)
  have hmass1 := sum_originalMass' p hp1
  have hlow : -B ≤ condExp p U f x := by
    unfold condExp
    rw [← Finset.sum_mul, hmass1, one_mul] at hsumlo
    exact hsumlo
  have hupp : condExp p U f x ≤ B := by
    unfold condExp
    rw [← Finset.sum_mul, hmass1, one_mul] at hsumhi
    exact hsumhi
  exact abs_le.mpr ⟨hlow, hupp⟩

/-- Covering every nonzero genuine cubic sector leaves a degree-two
conditional projection, on the source itself. -/
theorem covered_projection_degree_two
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 3)
    (H : Finset ι)
    (hcover : ∀ S : Finset ι, S.card = 3 →
      ¬ touches H S → ∀ x, esComp p S f x = 0) :
    ESDegreeLE p (condExp p (Finset.univ \ H) f) 2 := by
  intro S hS x
  rw [esComp_condExp p hp1 f (Finset.univ \ H) S x]
  by_cases hSU : S ⊆ (Finset.univ \ H)
  · rw [if_pos hSU]
    by_cases hg : 3 < S.card
    · exact hdegree S hg x
    · have hcard : S.card = 3 := by omega
      have hnot : ¬ touches H S :=
        (subset_complement_iff_no_touch H S).mp hSU
      exact hcover S hcard hnot x
  · rw [if_neg hSU]

/-- Fully source-owned finite cubic top-degree-cover inequality.
Uses the existing unconditional finite Q2 theorem with coefficient
(2(1+sqrt 2)sqrt 3 + 2)^2; no projected-Q2 premise is supplied.
This is stronger than the historical 16(1+sqrt 3) cover coefficient.
The C105.416 projected endpoint remains separately conditional. -/
theorem actual_source_cubic_top_cover_107
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 3)
    (H : Finset ι)
    (hcover : ∀ S : Finset ι, S.card = 3 →
      ¬ touches H S → ∀ x, esComp p S f x = 0)
    (B M : ℝ) (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hf : ∀ x, |f x| ≤ B)
    (hI : ∀ i, sourceInfluence p f i ≤ M) :
    sourceVariance p f ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 2) *
      B * Real.sqrt M + (H.card : ℝ) * M := by
  classical
  let U : Finset ι := Finset.univ \ H
  let g : (ι → α) → ℝ := condExp p U f
  have hgd : ESDegreeLE p g 2 :=
    covered_projection_degree_two p hp1 f hdegree H hcover
  have hgB : ∀ x, |g x| ≤ B :=
    conditional_amplitude_le p hp hp1 f U B hf
  have hgI : ∀ i, sourceInfluence p g i ≤ M := by
    intro i
    exact (projected_influence_le_original p hp hp1 f U i).trans (hI i)
  have hq := actual_source_q2_107_unconditional
    p hp hp1 g hgd B hB hgB M hM hgI
  have hproj : sourceVariance p g =
      outsideSourceEnergy p f H :=
    projected_variance_eq_outside_energy p hp1 f H
  let D : ℝ := (2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 2
  have hD : 0 ≤ D := by dsimp [D]; positivity
  have hVg : 0 ≤ sourceVariance p g := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    apply mul_nonneg
    · unfold originalMass
      exact Finset.prod_nonneg fun i _ => hp i (x i)
    · exact sq_nonneg _
  have hR : 0 ≤ D * B * Real.sqrt M := by positivity
  have hq' : (sourceVariance p g)^2 ≤ (D * B * Real.sqrt M)^2 := by
    calc
      (sourceVariance p g)^2 ≤ D^2 * B^2 * M := hq
      _ = D^2 * B^2 * (Real.sqrt M)^2 := by rw [Real.sq_sqrt hM]
      _ = (D * B * Real.sqrt M)^2 := by ring
  have hVgBound : sourceVariance p g ≤ D * B * Real.sqrt M := by
    nlinarith [sq_nonneg (sourceVariance p g + D * B * Real.sqrt M)]
  have hcost := source_variance_loss_le_cover_influences p hp hp1 f H
  have hcoverI :
      (∑ i ∈ H, sourceInfluence p f i) ≤ (H.card : ℝ) * M := by
    calc
      (∑ i ∈ H, sourceInfluence p f i) ≤ ∑ _i ∈ H, M := by
        apply Finset.sum_le_sum
        intro i _
        exact hI i
      _ = (H.card : ℝ) * M := by simp [nsmul_eq_mul]
  dsimp [D] at hVgBound
  change sourceVariance p f ≤ D * B * Real.sqrt M + (H.card : ℝ) * M
  dsimp [D]
  dsimp [g, U] at hproj hVgBound
  linarith [hcost]

end Nightfall.Observability.CubicTopCoverProjection
