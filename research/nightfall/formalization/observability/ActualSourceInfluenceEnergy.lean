import ActualSourceVarianceEnergy

/-!
# Genuine source influence equals canonical Hoeffding interaction energy

Port of legacy #428/433 influence identity, but using the exact
current-pin actual originalMass and new canonical Efron–Stein components.
No supplemental energy cap. A direct centered-section equality yields
the source heat-bath L² influence, avoiding any synthetic resampling law.
-/
namespace Nightfall.Observability.ActualSourceInfluenceEnergy
open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceCentered
open Nightfall.Observability.ActualSourceOrthogonality
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def sourceCenteredSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) : ℝ :=
  f (Function.update x i a) -
    ∑ b : α, p i b * f (Function.update x i b)

noncomputable def sourceInfluence
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, originalMass p x *
    (f x - ∑ b : α, p i b * f (Function.update x i b))^2

theorem actual_source_section_eq_interaction_sum
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) :
    sourceCenteredSection p f i x a =
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
    sourceCenteredSection p f i x a =
      (∑ S : Finset ι, esComp p S f (Function.update x i a)) -
      (∑ b : α, p i b *
        (∑ S : Finset ι,
          esComp p S f (Function.update x i b))) := by
            unfold sourceCenteredSection
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



/-- Efron–Stein exact same-source per-coordinate resampling influence.
Only source normalization, not quadratic degree, is necessary. -/
theorem original_source_influence_eq_interaction_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    sourceInfluence p f i =
      ∑ S : Finset ι,
        if i ∈ S then
          ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
        else 0 := by
  classical
  let g : Finset ι → (ι → α) → ℝ := fun S x =>
    if i ∈ S then esComp p S f x else 0
  have hsection (x : ι → α) :
      f x - ∑ b : α, p i b * f (Function.update x i b) =
        ∑ S : Finset ι, g S x := by
    have h := actual_source_section_eq_interaction_sum p hp1 f i x (x i)
    simpa [sourceCenteredSection, g] using h
  have horth :
      ∀ S T : Finset ι, S ≠ T →
      (∑ x : ι → α, originalMass p x * g S x * g T x) = 0 := by
    intro S T hne
    by_cases hS : i ∈ S
    · by_cases hT : i ∈ T
      · simpa [g, hS, hT] using
          actual_esComp_orthogonal p hp1 f S T hne
      · simp [g, hT]
    · simp [g, hS]
  unfold sourceInfluence
  calc
    (∑ x : ι → α, originalMass p x *
      (f x - ∑ b : α, p i b * f (Function.update x i b))^2) =
      ∑ x : ι → α, originalMass p x *
        (∑ S : Finset ι, g S x)^2 := by
          apply Finset.sum_congr rfl
          intro x _
          rw [hsection]
    _ = ∑ S : Finset ι, ∑ x : ι → α,
      originalMass p x * (g S x)^2 :=
        weighted_orthogonal_sum_sq (originalMass p) g horth
    _ = ∑ S : Finset ι,
        if i ∈ S then
          ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
        else 0 := by
          apply Finset.sum_congr rfl
          intro S _
          by_cases hS : i ∈ S <;> simp [g, hS]

/-- Restrict exact influence decomposition to the genuine singleton and
pair sectors of a source Efron–Stein degree-two function. -/
theorem original_source_degree_two_influence_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (hdegree : ESDegreeLE p f 2) (i : ι) :
    sourceInfluence p f i =
      ∑ S : Finset ι,
        if i ∈ S ∧ S.card ≤ 2 then
          ∑ x : ι → α, originalMass p x * (esComp p S f x)^2
        else 0 := by
  rw [original_source_influence_eq_interaction_energy p hp1 f i]
  apply Finset.sum_congr rfl
  intro S _
  by_cases hi : i ∈ S
  · by_cases hs : S.card ≤ 2
    · simp [hi, hs]
    · have hz (x : ι → α) : esComp p S f x = 0 :=
        hdegree S (by omega) x
      simp [hi, hs, hz]
  · simp [hi]

end Nightfall.Observability.ActualSourceInfluenceEnergy
