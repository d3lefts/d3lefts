import ActualESVarianceEnergy
import ActualESSourceEnergy

/-!
# Original-source influence equals the true Hoeffding-sector energy

For a genuine finite independent product law, the centered coordinate
section of the original function equals the sum of its canonical ANOVA
components containing the coordinate.  This yields the exact source
resampling influence decomposition by original-product orthogonality
and source coordinate resampling; no energy budget is a premise.

This proof uses the strictly compiled actual source variance Parseval module rather than an unverified alternative. It remains an attempt until this exact source compiles.
-/

namespace Nightfall.Observability.ActualESInfluenceParseval

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESOrthogonality
open Nightfall.Observability.ActualESVarianceEnergy
open Nightfall.Observability.ActualESConditionalSection
open Nightfall.Observability.ActualESSourceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual centered resampling section is precisely the sum of all
canonical Efron–Stein terms containing the resampled coordinate. -/
theorem actual_source_section_eq_interaction_sum
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) :
    sourceSection p f i x a =
      ∑ S : Finset ι,
        if i ∈ S then esComp p S f (Function.update x i a) else 0 := by
  classical
  have hdecomp (b : α) :
      f (Function.update x i b) =
        ∑ S : Finset ι,
          esComp p S f (Function.update x i b) :=
    (es_decomp p hp1 f (Function.update x i b)).symm
  have hswap :
      (∑ b : α, p i b *
        (∑ S : Finset ι,
          esComp p S f (Function.update x i b))) =
      ∑ S : Finset ι, ∑ b : α,
        p i b * esComp p S f (Function.update x i b) := by
    simp_rw [Finset.mul_sum]
    exact Finset.sum_comm
  have hterm (S : Finset ι) :
      esComp p S f (Function.update x i a) -
        (∑ b : α, p i b *
          esComp p S f (Function.update x i b)) =
      if i ∈ S then esComp p S f (Function.update x i a) else 0 := by
    by_cases hi : i ∈ S
    · have hc := actual_esComp_centered p hp1 f S i hi x
      rw [if_pos hi, hc]
      ring
    · have hfixed (b : α) :
          esComp p S f (Function.update x i b) =
            esComp p S f x := by
        apply esComp_dependsOn p S f
        intro j hj
        have hji : j ≠ i := by
          intro heq
          exact hi (heq ▸ hj)
        exact Function.update_of_ne hji b x
      rw [if_neg hi, hfixed a]
      simp_rw [hfixed]
      rw [← Finset.sum_mul, hp1 i]
      ring
  calc
    sourceSection p f i x a =
      (∑ S : Finset ι, esComp p S f (Function.update x i a)) -
      (∑ b : α, p i b *
        (∑ S : Finset ι,
          esComp p S f (Function.update x i b))) := by
            unfold sourceSection
            rw [hdecomp a]
            apply congrArg
              (fun t : ℝ => (∑ S : Finset ι,
                esComp p S f (Function.update x i a)) - t)
            apply Finset.sum_congr rfl
            intro b _
            rw [hdecomp b]
    _ = (∑ S : Finset ι, esComp p S f (Function.update x i a)) -
        ∑ S : Finset ι, ∑ b : α,
          p i b * esComp p S f (Function.update x i b) := by
            rw [hswap]
    _ = ∑ S : Finset ι,
          (esComp p S f (Function.update x i a) -
           (∑ b : α, p i b *
             esComp p S f (Function.update x i b))) := by
            rw [Finset.sum_sub_distrib]
    _ = ∑ S : Finset ι,
          if i ∈ S then esComp p S f (Function.update x i a) else 0 := by
            apply Finset.sum_congr rfl
            intro S _
            exact hterm S

/-- Original-source resampling influence is exactly the sum of energies
of canonical ANOVA components whose support contains coordinate i.
This holds for every finite independent law, including zero-mass atoms.
No Hoeffding degree restriction is necessary for this identity. -/
theorem actual_source_influence_eq_interaction_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    pinfl p f i =
      ∑ S : Finset ι,
        if i ∈ S then
          ∑ x : ι → α, prodMass p x * (esComp p S f x)^2
        else 0 := by
  classical
  let g : Finset ι → (ι → α) → ℝ := fun S x =>
    if i ∈ S then esComp p S f x else 0
  let G : (ι → α) → ℝ := fun x =>
    (∑ S : Finset ι, g S x)^2
  have hsection (x : ι → α) (a : α) :
      sourceSection p f i x a =
        ∑ S : Finset ι, g S (Function.update x i a) := by
    exact actual_source_section_eq_interaction_sum p hp1 f i x a
  have horth :
      ∀ S T : Finset ι, S ≠ T →
      (∑ x : ι → α, prodMass p x * g S x * g T x) = 0 := by
    intro S T hne
    by_cases hS : i ∈ S
    · by_cases hT : i ∈ T
      · simpa [g, hS, hT] using
          actual_esComp_orthogonal p hp1 f S T hne
      · simp [g, hT]
    · simp [g, hS]
  have hsource :
      sourceSectionEnergy p f i =
        ∑ x : ι → α, prodMass p x * G x := by
    calc
      sourceSectionEnergy p f i =
        ∑ x : ι → α, ∑ a : α,
          prodMass p x * p i a * G (Function.update x i a) := by
            unfold sourceSectionEnergy
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            rw [hsection x a]
            dsimp [G]
            ring
      _ = ∑ x : ι → α, prodMass p x * G x := by
            exact resample_sum p hp1 i G
  calc
    pinfl p f i = sourceSectionEnergy p f i :=
      (actual_source_section_energy_eq_influence p hp1 f i).symm
    _ = ∑ x : ι → α, prodMass p x * G x := hsource
    _ = ∑ S : Finset ι, ∑ x : ι → α,
          prodMass p x * (g S x)^2 := by
            exact weighted_orthogonal_sum_sq
              (prodMass p) g horth
    _ = ∑ S : Finset ι,
          if i ∈ S then
            ∑ x : ι → α,
              prodMass p x * (esComp p S f x)^2
          else 0 := by
            apply Finset.sum_congr rfl
            intro S _
            by_cases hS : i ∈ S <;> simp [g, hS]

end Nightfall.Observability.ActualESInfluenceParseval
