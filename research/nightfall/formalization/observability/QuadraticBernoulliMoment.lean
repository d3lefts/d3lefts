import ActualSourceNoiseEfronStein
import QuadraticSwitchingIdentity

/-!
# Bernoulli switching moments with exact independent masks

The mask probabilities are literal finite products, normalized and
marginalized by the source-proved mask subset-weight identity.
-/
namespace Nightfall.Observability.QuadraticBernoulli
open Finset
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualSourceNoiseEfronStein
open Nightfall.Observability.QuadraticSwitching

variable {ι : Type} [Fintype ι] [DecidableEq ι]

def maskBit (σ : ι → Bool) (i : ι) : ℝ := if σ i then 1 else 0

noncomputable def bernoulliMean (t : ℝ) (G : (ι → Bool) → ℝ) : ℝ :=
  ∑ σ : ι → Bool, maskWeight (fun _ => t) σ * G σ

theorem bernoulliMean_const (t c : ℝ) :
    bernoulliMean (ι := ι) t (fun _ => c) = c := by
  classical
  unfold bernoulliMean
  rw [← Finset.sum_mul, maskWeight_total_one]
  ring

theorem bernoulliMean_add (t : ℝ) (F G : (ι → Bool) → ℝ) :
    bernoulliMean t (fun σ => F σ + G σ) =
      bernoulliMean t F + bernoulliMean t G := by
  classical
  unfold bernoulliMean
  simp only [mul_add, Finset.sum_add_distrib]

theorem bernoulliMean_mul_right (t a : ℝ) (F : (ι → Bool) → ℝ) :
    bernoulliMean t (fun σ => F σ * a) = bernoulliMean t F * a := by
  classical
  unfold bernoulliMean
  calc
    (∑ σ : ι → Bool, maskWeight (fun _ => t) σ * (F σ * a)) =
        ∑ σ : ι → Bool, (maskWeight (fun _ => t) σ * F σ) * a := by
          apply Finset.sum_congr rfl
          intro σ _
          ring
    _ = (∑ σ : ι → Bool, maskWeight (fun _ => t) σ * F σ) * a := by
          rw [Finset.sum_mul]

theorem bernoulliMean_sum {β : Type*} [Fintype β]
    (t : ℝ) (F : β → (ι → Bool) → ℝ) :
    bernoulliMean t (fun σ => ∑ b : β, F b σ) =
      ∑ b : β, bernoulliMean t (F b) := by
  classical
  unfold bernoulliMean
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]

theorem bernoulliMean_bit (t : ℝ) (i : ι) :
    bernoulliMean t (fun σ => maskBit σ i) = t := by
  classical
  have hbit (σ : ι → Bool) :
      maskBit σ i = if ({i} : Finset ι) ⊆ maskSites σ then (1 : ℝ) else 0 := by
    cases hi : σ i <;> simp [maskBit, maskSites, hi]
  unfold bernoulliMean
  calc
    (∑ σ : ι → Bool, maskWeight (fun _ => t) σ * maskBit σ i) =
        ∑ σ : ι → Bool, maskWeight (fun _ => t) σ *
          (if ({i} : Finset ι) ⊆ maskSites σ then (1 : ℝ) else 0) := by
            apply Finset.sum_congr rfl
            intro σ _
            rw [hbit σ]
    _ = ∏ j : ι, if j ∈ ({i} : Finset ι) then t else (1 : ℝ) :=
          original_mask_subset_weight (fun _ => t) {i}
    _ = t := by simp

theorem bernoulliMean_pair (t : ℝ) (i j : ι) (hij : i ≠ j) :
    bernoulliMean t (fun σ => maskBit σ i * maskBit σ j) = t^2 := by
  classical
  have hbits (σ : ι → Bool) :
      maskBit σ i * maskBit σ j =
        if ({i,j} : Finset ι) ⊆ maskSites σ then (1 : ℝ) else 0 := by
    have heq :
        (({i,j} : Finset ι) ⊆ maskSites σ) ↔
          σ i = true ∧ σ j = true := by
      constructor
      · intro h
        constructor
        · have hi : i ∈ maskSites σ := h (by simp)
          simpa [maskSites] using hi
        · have hj : j ∈ maskSites σ := h (by simp)
          simpa [maskSites] using hj
      · intro h k hk
        have hk' : k = i ∨ k = j := by
          simpa only [Finset.mem_insert, Finset.mem_singleton] using hk
        rcases hk' with rfl | rfl
        · simpa [maskSites] using h.1
        · simpa [maskSites] using h.2
    cases hi : σ i <;> cases hj : σ j <;>
      simp [maskBit, hi, hj, heq]
  unfold bernoulliMean
  calc
    (∑ σ : ι → Bool, maskWeight (fun _ => t) σ *
        (maskBit σ i * maskBit σ j)) =
        ∑ σ : ι → Bool, maskWeight (fun _ => t) σ *
          (if ({i,j} : Finset ι) ⊆ maskSites σ then (1 : ℝ) else 0) := by
            apply Finset.sum_congr rfl
            intro σ _
            rw [hbits σ]
    _ = ∏ k : ι, if k ∈ ({i,j} : Finset ι) then t else (1 : ℝ) := by
          exact original_mask_subset_weight (fun _ => t) ({i,j} : Finset ι)
    _ = t^2 := by
      rw [Finset.prod_ite]
      have hfilter :
          (Finset.univ.filter (fun k : ι =>
            k ∈ ({i,j} : Finset ι))) = ({i,j} : Finset ι) := by
        ext k
        simp
      rw [hfilter]
      have hnot : i ∉ ({j} : Finset ι) := by simpa using hij
      simp [hnot, pow_two]

end Nightfall.Observability.QuadraticBernoulli
