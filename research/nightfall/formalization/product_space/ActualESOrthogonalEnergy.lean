import ActualESPairMatchingBridge
import ActualESQuadraticRectangles

/-!
# Actual product-law orthogonality of Efron–Stein source components

Proof by genuine resampling: a canonical component is mean-zero in
each coordinate in its support, and a second component that does not
depend on that coordinate remains fixed. Their product expectation
vanishes. This is the missing actual-source L2 orthogonality interface
for the source variance/influence bookkeeping.

Only normalized marginals are used; no supplied orthogonality or
energy certificate is assumed. The separately constructed global
sum-of-energies identity is the next stage.
-/

namespace Nightfall.Observability.ActualESOrthogonalEnergy

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESQuadraticRectangles

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact source inner-product expectation. -/
noncomputable def sourceInner
    (p : ι → α → ℝ)
    (g h : (ι → α) → ℝ) : ℝ :=
  ∑ x : ι → α, prodMass p x * (g x * h x)

/-- If g is actually centered at k and h genuinely ignores k,
the full product-law inner product is zero. -/
theorem source_inner_zero_of_centered_hidden
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (g h : (ι → α) → ℝ)
    (S : Finset ι) (hdep : DependsOn S h)
    (k : ι) (hk : k ∉ S)
    (hcent : ∀ x : ι → α,
      (∑ a : α, p k a * g (Function.update x k a)) = 0) :
    sourceInner p g h = 0 := by
  have hconst (x : ι → α) (a : α) :
      h (Function.update x k a) = h x :=
    dependsOn_update_outside S h hdep k hk x a
  unfold sourceInner
  calc
    (∑ x : ι → α, prodMass p x * (g x * h x)) =
      (∑ x : ι → α, ∑ a : α,
        prodMass p x * p k a *
          (g (Function.update x k a) *
            h (Function.update x k a))) :=
        (resample_sum p hp1 k (fun x => g x * h x)).symm
    _ = (∑ x : ι → α, prodMass p x *
      ((∑ a : α, p k a * g (Function.update x k a)) * h x)) := by
        apply Finset.sum_congr rfl
        intro x _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro a _
        rw [hconst x a]
        ring
    _ = 0 := by simp [hcent]

/-- Genuine canonical Efron–Stein components with a support
coordinate present in U and absent from V are orthogonal. -/
theorem actual_esComp_orthogonal_missing
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (U V : Finset ι)
    (k : ι) (hkU : k ∈ U) (hkV : k ∉ V) :
    sourceInner p (esComp p U f) (esComp p V f) = 0 := by
  exact source_inner_zero_of_centered_hidden
    p hp1 (esComp p U f) (esComp p V f)
    V (esComp_dependsOn p V f) k hkV
    (fun x => actual_esComp_centered p hp1 f U k hkU x)

/-! Further pair-energy Fubini reduction is intentionally omitted until proven. -/

/-- Commutativity of the actual weighted source inner product. -/
theorem sourceInner_comm
    (p : ι → α → ℝ)
    (g h : (ι → α) → ℝ) :
    sourceInner p g h = sourceInner p h g := by
  unfold sourceInner
  apply Finset.sum_congr rfl
  intro x _
  ring

/-- ANY two distinct canonical Efron–Stein support components of the
same genuine source function are orthogonal under the true product
mass. No independent orthogonality certificate is given. -/
theorem actual_esComp_orthogonal_distinct
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (U V : Finset ι) (hne : U ≠ V) :
    sourceInner p (esComp p U f) (esComp p V f) = 0 := by
  classical
  by_cases hsub : U ⊆ V
  · have hnsub : ¬ V ⊆ U := by
      intro hVU
      exact hne (Finset.Subset.antisymm hsub hVU)
    have hmiss : ∃ k : ι, k ∈ V ∧ k ∉ U := by
      by_contra hnot
      apply hnsub
      intro k hkV
      by_contra hkU
      exact hnot ⟨k, hkV, hkU⟩
    obtain ⟨k, hkV, hkU⟩ := hmiss
    rw [sourceInner_comm]
    exact actual_esComp_orthogonal_missing p hp1 f V U k hkV hkU
  · have hmiss : ∃ k : ι, k ∈ U ∧ k ∉ V := by
      by_contra hnot
      apply hsub
      intro k hkU
      by_contra hkV
      exact hnot ⟨k, hkU, hkV⟩
    obtain ⟨k, hkU, hkV⟩ := hmiss
    exact actual_esComp_orthogonal_missing p hp1 f U V k hkU hkV

/-- Genuine source-inner-product finite linearity in its first slot. -/
theorem sourceInner_sum_left
    {J : Type} [Fintype J]
    (p : ι → α → ℝ)
    (G : J → (ι → α) → ℝ)
    (h : (ι → α) → ℝ) :
    sourceInner p (fun x => ∑ j : J, G j x) h =
      ∑ j : J, sourceInner p (G j) h := by
  unfold sourceInner
  calc
    (∑ x : ι → α, prodMass p x *
      ((∑ j : J, G j x) * h x)) =
      ∑ x : ι → α, ∑ j : J,
        prodMass p x * (G j x * h x) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.sum_mul, Finset.mul_sum]
    _ = ∑ j : J, ∑ x : ι → α,
        prodMass p x * (G j x * h x) := Finset.sum_comm

/-- Genuine source-inner-product finite linearity in its second slot. -/
theorem sourceInner_sum_right
    {J : Type} [Fintype J]
    (p : ι → α → ℝ)
    (g : (ι → α) → ℝ)
    (G : J → (ι → α) → ℝ) :
    sourceInner p g (fun x => ∑ j : J, G j x) =
      ∑ j : J, sourceInner p g (G j) := by
  calc
    sourceInner p g (fun x => ∑ j : J, G j x) =
      sourceInner p (fun x => ∑ j : J, G j x) g :=
        sourceInner_comm p _ _
    _ = ∑ j : J, sourceInner p (G j) g :=
        sourceInner_sum_left p G g
    _ = ∑ j : J, sourceInner p g (G j) := by
      apply Finset.sum_congr rfl
      intro j _
      exact sourceInner_comm p _ _

/-- Finite exact Parseval identity for any already orthogonal family
under the *actual* product-source inner product. -/
theorem sourceInner_parseval_of_orthogonal
    {J : Type} [Fintype J] [DecidableEq J]
    (p : ι → α → ℝ)
    (G : J → (ι → α) → ℝ)
    (hortho : ∀ j k : J, j ≠ k →
      sourceInner p (G j) (G k) = 0) :
    sourceInner p (fun x => ∑ j : J, G j x)
      (fun x => ∑ j : J, G j x) =
      ∑ j : J, sourceInner p (G j) (G j) := by
  calc
    sourceInner p (fun x => ∑ j : J, G j x)
      (fun x => ∑ j : J, G j x) =
      ∑ j : J, sourceInner p (G j)
        (fun x => ∑ k : J, G k x) :=
          sourceInner_sum_left p G _
    _ = ∑ j : J, ∑ k : J, sourceInner p (G j) (G k) := by
          apply Finset.sum_congr rfl
          intro j _
          exact sourceInner_sum_right p (G j) G
    _ = ∑ j : J, sourceInner p (G j) (G j) := by
          apply Finset.sum_congr rfl
          intro j _
          rw [Finset.sum_eq_single j]
          · intro k _ hkj
            exact hortho j k hkj.symm
          · intro hj
            exact (hj (Finset.mem_univ j)).elim

/-- Exact Parseval expansion of the genuine finite degree-two source.
No abstract family of orthogonal kernels or variance decomposition is
passed to this theorem: the family is extracted from f by the
canonical product-law Efron–Stein decomposition. -/
theorem quadratic_actual_source_parseval
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    sourceInner p f f =
      ∑ S : Finset ι,
        if S.card ≤ 2 then
          sourceInner p (esComp p S f) (esComp p S f)
        else 0 := by
  classical
  let G : Finset ι → (ι → α) → ℝ := fun S x =>
    if S.card ≤ 2 then esComp p S f x else 0
  have hdec (x : ι → α) :
      f x = ∑ S : Finset ι, G S x := by
    simpa only [G] using
      quadratic_hoeffding_decomposition p hp1 f hdegree x
  have hortho : ∀ S T : Finset ι, S ≠ T →
      sourceInner p (G S) (G T) = 0 := by
    intro S T hne
    by_cases hs : S.card ≤ 2
    · by_cases ht : T.card ≤ 2
      · simpa only [G, if_pos hs, if_pos ht] using
          (actual_esComp_orthogonal_distinct p hp1 f S T hne)
      · simp [sourceInner, G, hs, ht]
    · simp [sourceInner, G, hs]
  calc
    sourceInner p f f =
      sourceInner p (fun x => ∑ S : Finset ι, G S x)
        (fun x => ∑ S : Finset ι, G S x) := by
          unfold sourceInner
          apply Finset.sum_congr rfl
          intro x _
          rw [← hdec x]
    _ = ∑ S : Finset ι, sourceInner p (G S) (G S) :=
          sourceInner_parseval_of_orthogonal p G hortho
    _ = ∑ S : Finset ι,
        if S.card ≤ 2 then
          sourceInner p (esComp p S f) (esComp p S f)
        else 0 := by
          apply Finset.sum_congr rfl
          intro S _
          by_cases hs : S.card ≤ 2
          · simp [G, hs]
          · simp [sourceInner, G, hs]

/-- The empty-support canonical component is the literal source
expectation, with no positivity or normalization premise. -/
theorem actual_esComp_empty_eq_source_mean
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (x : ι → α) :
    esComp p (∅ : Finset ι) f x = pexp p f := by
  classical
  simp [esComp, condExp, merge, pexp]

/-- The empty-support ANOVA energy is exactly the square of the
actual source expectation under normalized product marginals. -/
theorem actual_source_empty_energy_eq_mean_sq
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) :
    sourceInner p
      (esComp p (∅ : Finset ι) f)
      (esComp p (∅ : Finset ι) f) =
      (pexp p f)^2 := by
  unfold sourceInner
  simp_rw [actual_esComp_empty_eq_source_mean p f]
  rw [← Finset.sum_mul, sum_prodMass' p hp1]
  ring

/-- The genuine finite degree-two VARIANCE is the sum of source
component L2 energies over all nonempty supports of size at most two.
No artificial energy list, Hoeffding orthogonality premise, or
variance decomposition is supplied to this theorem. -/
theorem actual_quadratic_source_variance_parseval
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    pvar p f =
      ((Finset.univ : Finset (Finset ι)).erase ∅).sum
        (fun S => if S.card ≤ 2 then
          sourceInner p (esComp p S f) (esComp p S f)
        else 0) := by
  classical
  let A : Finset ι → ℝ := fun S =>
    if S.card ≤ 2 then
      sourceInner p (esComp p S f) (esComp p S f)
    else 0
  have hpar :
      sourceInner p f f =
        (Finset.univ : Finset (Finset ι)).sum A := by
    simpa only [A] using
      (quadratic_actual_source_parseval p hp1 f hdegree)
  have hconst : A (∅ : Finset ι) = (pexp p f)^2 := by
    simpa [A] using actual_source_empty_energy_eq_mean_sq p hp1 f
  have hsplit :
      ((Finset.univ : Finset (Finset ι)).erase ∅).sum A +
        A (∅ : Finset ι) =
      (Finset.univ : Finset (Finset ι)).sum A :=
    Finset.sum_erase_add _ _ (Finset.mem_univ _)
  have hvar : pvar p f = sourceInner p f f - (pexp p f)^2 := by
    rw [pvar_eq p hp1 f]
    unfold sourceInner
    congr 1
    apply Finset.sum_congr rfl
    intro x _
    ring
  calc
    pvar p f = sourceInner p f f - (pexp p f)^2 := hvar
    _ = (Finset.univ : Finset (Finset ι)).sum A -
      A (∅ : Finset ι) := by rw [hpar, hconst]
    _ = ((Finset.univ : Finset (Finset ι)).erase ∅).sum A := by
          linarith [hsplit]
    _ = ((Finset.univ : Finset (Finset ι)).erase ∅).sum
        (fun S => if S.card ≤ 2 then
          sourceInner p (esComp p S f) (esComp p S f)
        else 0) := rfl

end Nightfall.Observability.ActualESOrthogonalEnergy
