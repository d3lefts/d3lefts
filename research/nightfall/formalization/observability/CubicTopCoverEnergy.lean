import ActualSourceInfluenceEnergy

/-!
# Cubic top-cover: exact original-source energy reduction

Finite independent product laws, arbitrary heterogeneous nonnegative
probabilities (including zero atoms), and canonical ANOVA interactions.
This file proves the variance lost by deleting all interactions touching
a chosen finite cover is bounded by the sum of the *actual* influences
on that cover. It also proves that degree-three source interactions
remaining outside a cover are supported in degrees at most two.

The final scalar terminal accepts an explicit projected-Q2 premise;
it does not claim the projected source is yet connected to the existing
Q2 theorem. No unrestricted cubic theorem or novelty claim is made.
-/

namespace Nightfall.Observability.CubicTopCoverEnergy

attribute [local instance] Classical.propDecidable

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The support S contains an element of the proposed cubic cover H. -/
def touches (H S : Finset ι) : Prop :=
  ∃ i, i ∈ H ∧ i ∈ S

/-- Pure combinatorial cover counting, with no graph degree assumption. -/
theorem covered_energy_le_sum_influences
    (H : Finset ι) (w : Finset ι → ℝ)
    (hw : ∀ S, 0 ≤ w S) :
    (∑ S : Finset ι, if touches H S then w S else 0) ≤
      ∑ i ∈ H, ∑ S : Finset ι, if i ∈ S then w S else 0 := by
  classical
  calc
    (∑ S : Finset ι, if touches H S then w S else 0) ≤
        ∑ S : Finset ι, ∑ i ∈ H, if i ∈ S then w S else 0 := by
          apply Finset.sum_le_sum
          intro S _
          by_cases hS : touches H S
          · obtain ⟨i, hiH, hiS⟩ := hS
            have ht : touches H S := ⟨i, hiH, hiS⟩
            rw [if_pos ht]
            calc
              w S = (if i ∈ S then w S else 0) := by simp [hiS]
              _ ≤ ∑ i ∈ H, if i ∈ S then w S else 0 := by
                apply Finset.single_le_sum
                · intro j hj hji
                  by_cases hjS : j ∈ S
                  · simpa [hjS] using hw S
                  · simp [hjS]
                · exact hiH
          · rw [if_neg hS]
            apply Finset.sum_nonneg
            intro j hj
            by_cases hjS : j ∈ S
            · simpa [hjS] using hw S
            · simp [hjS]
    _ = ∑ i ∈ H, ∑ S : Finset ι, if i ∈ S then w S else 0 := by
          rw [Finset.sum_comm]

/-- Splitting a finite ANOVA energy into supports touching H and outside H. -/
theorem total_energy_eq_covered_add_outside
    (H : Finset ι) (w : Finset ι → ℝ) :
    (∑ S : Finset ι, w S) =
      (∑ S : Finset ι, if touches H S then w S else 0) +
      (∑ S : Finset ι, if touches H S then 0 else w S) := by
  classical
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro S _
  by_cases hS : touches H S <;> simp [hS]

/-- The actual canonical energy of a source on nonempty S. -/
noncomputable def sourceSectorEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (S : Finset ι) : ℝ :=
  if S = ∅ then 0 else
    ∑ x : ι → α, originalMass p x * (esComp p S f x)^2

/-- The energy remaining on supports entirely outside H. -/
noncomputable def outsideSourceEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (H : Finset ι) : ℝ :=
  ∑ S : Finset ι,
    if touches H S then 0 else sourceSectorEnergy p f S

theorem sourceSectorEnergy_nonneg
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (S : Finset ι) :
    0 ≤ sourceSectorEnergy p f S := by
  classical
  unfold sourceSectorEnergy
  split_ifs with hS
  · exact le_refl 0
  · apply Finset.sum_nonneg
    intro x _
    apply mul_nonneg
    · unfold originalMass
      exact Finset.prod_nonneg fun i _ => hp i (x i)
    · exact sq_nonneg _

theorem outsideSourceEnergy_nonneg
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (H : Finset ι) :
    0 ≤ outsideSourceEnergy p f H := by
  classical
  unfold outsideSourceEnergy
  apply Finset.sum_nonneg
  intro S _
  split_ifs
  · exact le_refl 0
  · exact sourceSectorEnergy_nonneg p hp f S

/-- Source-exact: deleting covered canonical interactions costs at most
the sum of genuine source influences of the covering coordinates. -/
theorem source_variance_loss_le_cover_influences
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (H : Finset ι) :
    sourceVariance p f - outsideSourceEnergy p f H ≤
      ∑ i ∈ H, sourceInfluence p f i := by
  classical
  let w : Finset ι → ℝ := sourceSectorEnergy p f
  have hw (S : Finset ι) : 0 ≤ w S :=
    sourceSectorEnergy_nonneg p hp f S
  have hvar : sourceVariance p f = ∑ S : Finset ι, w S := by
    rw [actual_source_variance_es_energy p hp1 f]
    rfl
  have hinf (i : ι) :
      (∑ S : Finset ι, if i ∈ S then w S else 0) =
        sourceInfluence p f i := by
    rw [original_source_influence_eq_interaction_energy p hp1 f i]
    apply Finset.sum_congr rfl
    intro S _
    by_cases hi : i ∈ S
    · have hne : S ≠ ∅ := by
        intro he
        simp [he] at hi
      simp [hi, w, sourceSectorEnergy, hne]
    · simp [hi]
  have hsplit := total_energy_eq_covered_add_outside H w
  have hbound := covered_energy_le_sum_influences H w hw
  calc
    sourceVariance p f - outsideSourceEnergy p f H =
        ∑ S : Finset ι, if touches H S then w S else 0 := by
          rw [hvar]
          unfold outsideSourceEnergy
          dsimp only [w]
          linarith [hsplit]
    _ ≤ ∑ i ∈ H, ∑ S : Finset ι, if i ∈ S then w S else 0 := hbound
    _ = ∑ i ∈ H, sourceInfluence p f i := by
          apply Finset.sum_congr rfl
          intro i _
          exact hinf i

/-- Outside a cover of every nonzero cubic support, no degree >= 3
canonical energy remains. This is a *source-level* degree statement. -/
theorem cubic_outside_sector_vanishes
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 3)
    (H : Finset ι)
    (hcover : ∀ S : Finset ι, S.card = 3 →
      ¬ touches H S → ∀ x, esComp p S f x = 0)
    (S : Finset ι) (houtside : ¬ touches H S)
    (hlarge : 2 < S.card) :
    sourceSectorEnergy p f S = 0 := by
  classical
  have hne : S ≠ ∅ := by
    intro he
    simp [he] at hlarge
  have hz : ∀ x, esComp p S f x = 0 := by
    by_cases hgt : 3 < S.card
    · exact hdegree S hgt
    · exact hcover S (by omega) houtside
  simp [sourceSectorEnergy, hne, hz]

/-- Exact C105.416 scalar terminal from a *supplied* quadratic bound
on the outside energy. A later adapter must establish that supplied
premise from the genuine conditional projection of f. -/
theorem cubic_cover_terminal_from_projected_q2
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (H : Finset ι) (B M : ℝ) (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hI : ∀ i, sourceInfluence p f i ≤ M)
    (hprojectedQ2 :
      (outsideSourceEnergy p f H)^2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 +
        11901 / 6250)^2 * B^2 * M) :
    sourceVariance p f ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 +
        11901 / 6250) * B * Real.sqrt M + (H.card : ℝ) * M := by
  classical
  let D : ℝ := (2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250
  let E : ℝ := outsideSourceEnergy p f H
  have hD : 0 ≤ D := by dsimp [D]; positivity
  have hE : 0 ≤ E := outsideSourceEnergy_nonneg p hp f H
  have hroot : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hright : 0 ≤ D * B * Real.sqrt M :=
    mul_nonneg (mul_nonneg hD hB) hroot
  have hsq : E^2 ≤ (D * B * Real.sqrt M)^2 := by
    calc
      E^2 ≤ D^2 * B^2 * M := hprojectedQ2
      _ = (D * B * Real.sqrt M)^2 := by
        calc
          D^2 * B^2 * M = D^2 * B^2 * (Real.sqrt M)^2 := by rw [Real.sq_sqrt hM]
          _ = (D * B * Real.sqrt M)^2 := by ring
  have hEbound : E ≤ D * B * Real.sqrt M := by
    nlinarith [sq_nonneg (E + D * B * Real.sqrt M)]
  have hcost := source_variance_loss_le_cover_influences p hp hp1 f H
  have hcoverI :
      (∑ i ∈ H, sourceInfluence p f i) ≤ (H.card : ℝ) * M := by
    calc
      (∑ i ∈ H, sourceInfluence p f i) ≤ ∑ _i ∈ H, M := by
        apply Finset.sum_le_sum
        intro i hi
        exact hI i
      _ = (H.card : ℝ) * M := by simp [nsmul_eq_mul]
  change sourceVariance p f ≤ D * B * Real.sqrt M + (H.card : ℝ) * M
  dsimp [E] at hEbound
  linarith

end Nightfall.Observability.CubicTopCoverEnergy
