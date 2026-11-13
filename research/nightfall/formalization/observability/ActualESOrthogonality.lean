import ActualESPairMatchingBridge
import ActualESQuadraticRectangles

/-!
# Actual source Efron–Stein orthogonality

Orthogonality is proved by resampling a coordinate that belongs to one
component support but not the other. Degeneracy and support dependence
are derived from the genuine source component. No source energy identity
or quadratic influence bound is assumed.
-/

namespace Nightfall.Observability.ActualESOrthogonality

open Finset Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESQuadraticRectangles

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Product-law orthogonality for two genuine source components when a
coordinate is in the first support but absent from the second. -/
theorem actual_es_components_cross_zero_of_missing
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (S T : Finset ι) (i : ι)
    (hiS : i ∈ S) (hiT : i ∉ T) :
    (∑ x : ι → α,
      prodMass p x * (esComp p S f x * esComp p T f x)) = 0 := by
  classical
  let H : (ι → α) → ℝ := esComp p S f
  let G : (ι → α) → ℝ := esComp p T f
  have hcent (x : ι → α) :
      (∑ b : α, p i b * H (Function.update x i b)) = 0 :=
    actual_esComp_centered p hp1 f S i hiS x
  have hsame (x : ι → α) (b : α) :
      G (Function.update x i b) = G x :=
    dependsOn_update_outside T G
      (esComp_dependsOn p T f) i hiT x b
  have hfactor (x : ι → α) :
      (∑ b : α, prodMass p x * p i b *
        (H (Function.update x i b) *
          G (Function.update x i b))) =
        prodMass p x *
          ((∑ b : α, p i b *
            H (Function.update x i b)) * G x) := by
    calc
      (∑ b : α, prodMass p x * p i b *
        (H (Function.update x i b) *
          G (Function.update x i b))) =
        ∑ b : α, prodMass p x * p i b *
          (H (Function.update x i b) * G x) := by
            apply Finset.sum_congr rfl
            intro b _
            rw [hsame]
      _ = ∑ b : α, (prodMass p x *
        (p i b * H (Function.update x i b))) * G x := by
            apply Finset.sum_congr rfl
            intro b _
            ring
      _ = (∑ b : α, prodMass p x *
        (p i b * H (Function.update x i b))) * G x := by
            rw [Finset.sum_mul]
      _ = prodMass p x *
        ((∑ b : α, p i b *
          H (Function.update x i b)) * G x) := by
            rw [Finset.mul_sum]
  have hres := resample_sum p hp1 i (fun x => H x * G x)
  calc
    (∑ x : ι → α, prodMass p x * (H x * G x)) =
      ∑ x : ι → α, ∑ b : α, prodMass p x * p i b *
        (H (Function.update x i b) *
          G (Function.update x i b)) := hres.symm
    _ = ∑ x : ι → α,
      prodMass p x * ((∑ b : α, p i b *
        H (Function.update x i b)) * G x) := by
          apply Finset.sum_congr rfl
          intro x _
          exact hfactor x
    _ = 0 := by simp [hcent]

end Nightfall.Observability.ActualESOrthogonality
