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

/-- Zero padding of the response blocks makes the maximal smooth zero
statement sufficient for every smaller response dimension. -/
theorem smoothPureZero_mono (n k m : ℕ) (hkm : k ≤ m)
    (hm : SmoothPureZero n m) : SmoothPureZero n k := by
  unfold SmoothPureZero at hm ⊢
  intro fU fV hcU hcV hoU heU heV hoV
  let pad (f : X n → X n → Fin k → ℝ) (u v : X n) (i : Fin m) : ℝ :=
    if h : i.val < k then f u v ⟨i.val,h⟩ else 0
  have hUc : ∀ i : Fin m, ContDiff ℝ (⊤ : ℕ∞)
      (fun p : X n × X n => pad fU p.1 p.2 i) := by
    intro i
    by_cases h : i.val < k
    · simpa only [pad,dif_pos h] using hcU ⟨i.val,h⟩
    · simp only [pad,dif_neg h]
      exact contDiff_const
  have hVc : ∀ i : Fin m, ContDiff ℝ (⊤ : ℕ∞)
      (fun p : X n × X n => pad fV p.1 p.2 i) := by
    intro i
    by_cases h : i.val < k
    · simpa only [pad,dif_pos h] using hcV ⟨i.val,h⟩
    · simp only [pad,dif_neg h]
      exact contDiff_const
  have hUo : ∀ u v i, pad fU (-u) v i = -pad fU u v i := by
    intro u v i
    by_cases h : i.val < k <;> simp [pad,h,hoU]
  have hUe : ∀ u v i, pad fU u (-v) i = pad fU u v i := by
    intro u v i
    by_cases h : i.val < k <;> simp [pad,h,heU]
  have hVe : ∀ u v i, pad fV (-u) v i = pad fV u v i := by
    intro u v i
    by_cases h : i.val < k <;> simp [pad,h,heV]
  have hVo : ∀ u v i, pad fV u (-v) i = -pad fV u v i := by
    intro u v i
    by_cases h : i.val < k <;> simp [pad,h,hoV]
  obtain ⟨u,v,hu,hv,hzu,hzv⟩ := hm (pad fU) (pad fV) hUc hVc hUo hUe hVe hVo
  refine ⟨u,v,hu,hv,?_,?_⟩
  · intro i
    let j : Fin m := ⟨i.val,lt_of_lt_of_le i.isLt hkm⟩
    have h := hzu j
    simpa [pad,j,i.isLt] using h
  · intro i
    let j : Fin m := ⟨i.val,lt_of_lt_of_le i.isLt hkm⟩
    have h := hzv j
    simpa [pad,j,i.isLt] using h

/-- Negative control: no theorem may discharge SmoothPureZero at or above
the ambient dimension. The coordinate projection is a globally smooth
counterexample with the exact required characters. -/
theorem not_smoothPureZero_of_dim_le (n k : ℕ) (hnk : n ≤ k) :
    ¬ SmoothPureZero n k := by
  intro hs
  let pad (u : X n) (i : Fin k) : ℝ :=
    if h : i.val < n then u ⟨i.val,h⟩ else 0
  have hcU : ∀ i : Fin k, ContDiff ℝ (⊤ : ℕ∞)
      (fun p : X n × X n => pad p.1 i) := by
    intro i
    by_cases hi : i.val < n
    · simp only [pad,dif_pos hi]
      fun_prop
    · simp only [pad,dif_neg hi]
      exact contDiff_const
  have hcV : ∀ i : Fin k, ContDiff ℝ (⊤ : ℕ∞)
      (fun p : X n × X n => pad p.2 i) := by
    intro i
    by_cases hi : i.val < n
    · simp only [pad,dif_pos hi]
      fun_prop
    · simp only [pad,dif_neg hi]
      exact contDiff_const
  have hn : ∀ u i, pad (-u) i = -pad u i := by
    intro u i
    by_cases hi : i.val < n <;> simp [pad,hi]
  obtain ⟨u,v,hu,hv,hzu,hzv⟩ := hs (fun u _ => pad u) (fun _ v => pad v)
    hcU hcV (fun u _ i => hn u i) (fun _ _ _ => rfl)
    (fun _ _ _ => rfl) (fun _ v i => hn v i)
  have hz : u = 0 := by
    funext i
    let j : Fin k := ⟨i.val,lt_of_lt_of_le i.isLt hnk⟩
    have h := hzu j
    simpa [pad,j,i.isLt] using h
  rw [hz] at hu
  simp [UnitVec] at hu

/-- Exact maximal-dimension target for the smooth-to-continuous bridge.
This does not assume a smooth theorem at impossible dimensions. -/
theorem continuous_zero_of_maximal_smooth (n k : ℕ) (hn : 1 ≤ n)
    (hk : k < n) (hm : SmoothPureZero n (n-1)) :
    ProductSphereZero n k k :=
  continuous_zero_of_smooth n k hn (smoothPureZero_mono n k (n-1) (by omega) hm)

#print axioms smoothPureZero_mono
#print axioms not_smoothPureZero_of_dim_le
#print axioms continuous_zero_of_maximal_smooth

end Nightfall.PaperIIIContinuousReduction
