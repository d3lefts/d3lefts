import Mathlib
import ProductBUSphereExtension
import PaperIIIReynolds

/-! Paper III: actual smooth approximation on a compact subset, followed
by exact character projection. Uses Mathlib's convolution theorem, not
a new smooth approximation hypothesis. -/
namespace Nightfall.ProductBUSmoothApprox
open scoped ContDiff
open Set Metric
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSphereExtension
open Nightfall.ProductBUReynolds
abbrev Vec (n : ℕ) := Fin n → ℝ

theorem spherePair_compact (n : ℕ) : IsCompact (SpherePair n) := by
  let C : Set (Vec n) := {u | ∀ i : Fin n, u i ∈ Set.Icc (-1 : ℝ) 1}
  have hC : IsCompact C := by
    simpa [C] using (isCompact_pi_infinite
      (s := fun _ : Fin n => Set.Icc (-1 : ℝ) 1) (fun _ => isCompact_Icc))
  apply IsCompact.of_isClosed_subset (hC.prod hC) (spherePair_isClosed n)
  intro p hp
  change UnitVec n p.1 ∧ UnitVec n p.2 at hp
  have bound (u : Vec n) (hu : UnitVec n u) (i : Fin n) : |u i| ≤ 1 := by
    have hs : (u i)^2 ≤ ∑ j : Fin n, (u j)^2 :=
      Finset.single_le_sum (fun j _ => sq_nonneg (u j)) (Finset.mem_univ i)
    exact (sq_le_one_iff_abs_le_one (u i)).mp (hs.trans_eq hu)
  exact ⟨fun i => abs_le.mp (bound p.1 hp.1 i),
    fun i => abs_le.mp (bound p.2 hp.2 i)⟩

/-- Compact-uniform scalar smoothing, using the same Mathlib
convolution estimate as its compact-convergence density proof. -/
theorem smooth_on_compact {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (K : Set E) (hK : IsCompact K)
    (f : E → ℝ) (hf : Continuous f) (eps : ℝ) (heps : 0 < eps) :
    ∃ g : E → ℝ, ContDiff ℝ (⊤ : ℕ∞) g ∧
      ∀ x ∈ K, |g x - f x| ≤ eps := by
  have hUC : UniformContinuousOn f (cthickening 1 K) :=
    hK.cthickening.uniformContinuousOn_of_continuous hf.continuousOn
  rcases Metric.uniformContinuousOn_iff.mp hUC (eps/2) (half_pos heps)
    with ⟨δ,hδ,hfδ⟩
  rcases hf.exists_contDiff_dist_le_of_forall_mem_ball_dist_le
    (lt_min one_pos hδ) with ⟨g,hgc,hg⟩
  refine ⟨g,hgc,?_⟩
  intro x hx
  rw [← Real.dist_eq]
  apply (hg x (eps/2) ?_).trans (half_le_self heps.le)
  intro y hy
  rw [mem_ball, lt_min_iff] at hy
  exact (hfδ _ (mem_cthickening_of_dist_le _ x _ _ hx hy.1.le) _
    (self_subset_cthickening _ hx) hy.2).le

theorem exists_smooth_pureU (n : ℕ) (f : Vec n → Vec n → ℝ)
    (hf : ContinuousOn (fun p : Vec n × Vec n => f p.1 p.2) (SpherePair n))
    (hodd : ∀ u v, UnitVec n u → UnitVec n v → f (-u) v = -f u v)
    (heven : ∀ u v, UnitVec n u → UnitVec n v → f u (-v) = f u v)
    (eps : ℝ) (heps : 0 < eps) :
    ∃ g : Vec n → Vec n → ℝ,
      ContDiff ℝ (⊤ : ℕ∞) (fun p : Vec n × Vec n => g p.1 p.2) ∧
      (∀ u v, g (-u) v = -g u v) ∧
      (∀ u v, g u (-v) = g u v) ∧
      ∀ u v, UnitVec n u → UnitVec n v → |g u v - f u v| ≤ eps := by
  obtain ⟨F,hF,hEq⟩ := exists_continuous_extension n _ hf
  obtain ⟨G,hG,hGE⟩ := smooth_on_compact (SpherePair n) (spherePair_compact n) F hF eps heps
  let G' : Vec n → Vec n → ℝ := fun u v => G (u,v)
  refine ⟨pureU G', pureU_smooth G' hG, pureU_odd G', pureU_even G', ?_⟩
  apply pureU_uniform_error G' f eps hodd heven
  intro u v hu hv
  have hp : (u,v) ∈ SpherePair n := ⟨hu,hv⟩
  have h := hGE (u,v) hp
  rw [hEq hp] at h
  exact h

theorem exists_smooth_pureV (n : ℕ) (f : Vec n → Vec n → ℝ)
    (hf : ContinuousOn (fun p : Vec n × Vec n => f p.1 p.2) (SpherePair n))
    (heven : ∀ u v, UnitVec n u → UnitVec n v → f (-u) v = f u v)
    (hodd : ∀ u v, UnitVec n u → UnitVec n v → f u (-v) = -f u v)
    (eps : ℝ) (heps : 0 < eps) :
    ∃ g : Vec n → Vec n → ℝ,
      ContDiff ℝ (⊤ : ℕ∞) (fun p : Vec n × Vec n => g p.1 p.2) ∧
      (∀ u v, g (-u) v = g u v) ∧
      (∀ u v, g u (-v) = -g u v) ∧
      ∀ u v, UnitVec n u → UnitVec n v → |g u v - f u v| ≤ eps := by
  obtain ⟨F,hF,hEq⟩ := exists_continuous_extension n _ hf
  obtain ⟨G,hG,hGE⟩ := smooth_on_compact (SpherePair n) (spherePair_compact n) F hF eps heps
  let G' : Vec n → Vec n → ℝ := fun u v => G (u,v)
  refine ⟨pureV G', pureV_smooth G' hG, pureV_even G', pureV_odd G', ?_⟩
  apply pureV_uniform_error G' f eps heven hodd
  intro u v hu hv
  have hp : (u,v) ∈ SpherePair n := ⟨hu,hv⟩
  have h := hGE (u,v) hp
  rw [hEq hp] at h
  exact h

#print axioms spherePair_compact
#print axioms smooth_on_compact
#print axioms exists_smooth_pureU
#print axioms exists_smooth_pureV
end Nightfall.ProductBUSmoothApprox
