import ActualSourceInfluenceEnergy

/-!
# Actual original-source Efron–Stein, all finite interaction orders

No degree bound, no minimum atom mass, no supplied variance-energy
budget, no generated owner certificate. The same original source
p is used by canonical energy, sourceVariance and sourceInfluence.
This supplies the finite inequality needed downstream of a genuine
Measure.infinitePi finite-projection transfer.

Not an arbitrary-index theorem: Fintype ι is explicit.
-/
namespace Nightfall.Observability.ActualSourceEfronStein
open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def sectorEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (S : Finset ι) : ℝ :=
  ∑ x : ι → α, originalMass p x * (esComp p S f x)^2

theorem sector_energy_nonneg
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (S : Finset ι) :
    0 ≤ sectorEnergy p f S := by
  classical
  unfold sectorEnergy
  apply Finset.sum_nonneg
  intro x _
  apply mul_nonneg
  · unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (x i))
  · positivity

/-- Every nonempty ANOVA sector is counted at least once in the
sum of coordinate influences; precise source energies are nonnegative. -/
theorem sector_below_coordinate_incidence
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (f : (ι → α) → ℝ) (S : Finset ι) :
    (if S = ∅ then 0 else sectorEnergy p f S) ≤
      ∑ i : ι, if i ∈ S then sectorEnergy p f S else 0 := by
  classical
  by_cases hS : S = ∅
  · simp [hS]
  · have hcardNat : 1 ≤ S.card := by
      have hn : 0 < S.card :=
        Finset.card_pos.mpr (Finset.nonempty_iff_ne_empty.mpr hS)
      omega
    have hcard : (1 : ℝ) ≤ (S.card : ℝ) := by
      exact_mod_cast hcardNat
    have hE : 0 ≤ sectorEnergy p f S :=
      sector_energy_nonneg p hp f S
    have hsum : (∑ i : ι, if i ∈ S then sectorEnergy p f S else 0) =
        (S.card : ℝ) * sectorEnergy p f S := by
      simp [Finset.sum_ite]
    rw [if_neg hS, hsum]
    nlinarith [mul_nonneg (sub_nonneg.mpr hcard) hE]

/-- FULL FINITE PRODUCT EFRON-STEIN: no restriction on interaction degree.
The variance and influence are derived directly from one source p,f. -/
theorem original_source_all_degree_efron_stein
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) :
    sourceVariance p f ≤ ∑ i : ι, sourceInfluence p f i := by
  classical
  let e : Finset ι → ℝ := sectorEnergy p f
  have hsite (S : Finset ι) :
      (if S = ∅ then 0 else e S) ≤
      ∑ i : ι, if i ∈ S then e S else 0 :=
    sector_below_coordinate_incidence p hp f S
  calc
    sourceVariance p f =
      ∑ S : Finset ι, if S = ∅ then 0 else e S := by
        simpa only [e, sectorEnergy] using
          actual_source_variance_es_energy p hp1 f
    _ ≤ ∑ S : Finset ι, ∑ i : ι,
          if i ∈ S then e S else 0 := by
        apply Finset.sum_le_sum
        intro S _
        exact hsite S
    _ = ∑ i : ι, ∑ S : Finset ι,
          if i ∈ S then e S else 0 := Finset.sum_comm
    _ = ∑ i : ι, sourceInfluence p f i := by
        apply Finset.sum_congr rfl
        intro i _
        rw [original_source_influence_eq_interaction_energy p hp1 f i]
        rfl

end Nightfall.Observability.ActualSourceEfronStein
