import PaperIIISmoothApprox
import ProductBUSphereCompact

/-! Paper III Lemma 3.1: reduce the maximal continuous separate-character
zero theorem to its smooth ambient version using actual compact-sphere
uniform approximation. The remaining smooth zero theorem is explicit. -/
namespace Nightfall.PaperIIIContinuousReduction
open scoped ContDiff
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSmoothApprox
open Nightfall.ProductBUSphereCompact
abbrev X (n : ℕ) := Fin n → ℝ

def SmoothPureZero (n k : ℕ) : Prop :=
  ∀ (fU fV : X n → X n → Fin k → ℝ),
    (∀ i, ContDiff ℝ (⊤ : ℕ∞) (fun p : X n × X n => fU p.1 p.2 i)) →
    (∀ i, ContDiff ℝ (⊤ : ℕ∞) (fun p : X n × X n => fV p.1 p.2 i)) →
    (∀ u v i, fU (-u) v i = -fU u v i) →
    (∀ u v i, fU u (-v) i = fU u v i) →
    (∀ u v i, fV (-u) v i = fV u v i) →
    (∀ u v i, fV u (-v) i = -fV u v i) →
    ∃ u v, UnitVec n u ∧ UnitVec n v ∧
      (∀ i, fU u v i = 0) ∧ (∀ i, fV u v i = 0)

theorem continuous_zero_of_smooth (n k : ℕ) (hn : 1 ≤ n)
    (hsmooth : SmoothPureZero n k) : ProductSphereZero n k k := by
  classical
  unfold ProductSphereZero
  intro fU fV hcU hcV hoU heU heV hoV
  by_contra hno
  have hnone : ∀ p ∈ SpherePair n,
      ¬ ((∀ i : Fin k, fU p.1 p.2 i = 0) ∧
         (∀ i : Fin k, fV p.1 p.2 i = 0)) := by
    intro p hp hz
    exact hno ⟨p.1,p.2,hp.1,hp.2,hz.1,hz.2⟩
  obtain ⟨δ,hδ,hgap⟩ :=
    exists_positive_energy_gap n k hn fU fV hcU hcV hnone
  let eps : ℝ := min 1 (δ/(4*((k : ℝ)+1)))
  have hden : 0 < 4*((k : ℝ)+1) := by positivity
  have heps : 0 < eps := lt_min one_pos (div_pos hδ hden)
  have heps1 : eps ≤ 1 := min_le_left _ _
  have hsmall : eps*(4*((k : ℝ)+1)) ≤ δ :=
    (le_div_iff₀ hden).mp (min_le_right _ _)
  have eU := fun i : Fin k => exists_smooth_pureU n
    (fun u v => fU u v i) (hcU i) (fun u v => hoU u v i)
    (fun u v => heU u v i) eps heps
  have eV := fun i : Fin k => exists_smooth_pureV n
    (fun u v => fV u v i) (hcV i) (fun u v => heV u v i)
    (fun u v => hoV u v i) eps heps
  choose gU hgUc hgUo hgUe hgUerr using eU
  choose gV hgVc hgVe hgVo hgVerr using eV
  obtain ⟨u,v,hu,hv,hzU,hzV⟩ := hsmooth
    (fun u v i => gU i u v) (fun u v i => gV i u v)
    hgUc hgVc (fun u v i => hgUo i u v) (fun u v i => hgUe i u v)
    (fun u v i => hgVe i u v) (fun u v i => hgVo i u v)
  have hsq (x : ℝ) (hx : |x| ≤ eps) : x^2 ≤ eps^2 := by
    simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg x) heps.le).mpr hx
  have hU : (∑ i : Fin k, (fU u v i)^2) ≤ (k : ℝ)*eps^2 := by
    calc
      _ ≤ ∑ _i : Fin k, eps^2 := by
        apply Finset.sum_le_sum
        intro i _
        apply hsq
        have h := hgUerr i u v hu hv
        rw [show gU i u v = 0 from hzU i, zero_sub, abs_neg] at h
        exact h
      _ = _ := by simp
  have hV : (∑ i : Fin k, (fV u v i)^2) ≤ (k : ℝ)*eps^2 := by
    calc
      _ ≤ ∑ _i : Fin k, eps^2 := by
        apply Finset.sum_le_sum
        intro i _
        apply hsq
        have h := hgVerr i u v hu hv
        rw [show gV i u v = 0 from hzV i, zero_sub, abs_neg] at h
        exact h
      _ = _ := by simp
  have hg := hgap (u,v) ⟨hu,hv⟩
  unfold pureEnergy at hg
  have hsqeps : eps^2 ≤ eps := by
    nlinarith [mul_nonneg heps.le (sub_nonneg.mpr heps1)]
  have hk : 0 ≤ (k : ℝ) := by positivity
  have hmul := mul_le_mul_of_nonneg_left hsqeps hk
  have hkeps := mul_nonneg hk heps.le
  nlinarith only [hg,hU,hV,hmul,hsmall,hkeps,heps]

#print axioms continuous_zero_of_smooth
end Nightfall.PaperIIIContinuousReduction
