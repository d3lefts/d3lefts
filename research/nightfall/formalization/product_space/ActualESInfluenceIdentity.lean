import ActualESOrthogonalEnergy
import ActualESConditionalSection

/-!
# Actual product-law influence is the exact interaction-energy sum

No requested inequality is assumed. We use the actual finite product
masses, the actual one-coordinate conditional average (pavg), and
the compiled variance/conditional-expectation identity from
ProductInfluence. First prove the L2 projection identity

 pinfl(p,f,i) = E_p [(f(X)-pavg_i f(X))²].

Then the actual centered-section Efron–Stein decomposition and
orthogonality give the exact ANOVA formula for the influence.

This is the central finite-source energy-cap bridge required by Q2.
The pair-energy Fubini reduction is distinct: relating
sourceInner(esComp_{i,j},esComp_{i,j}) to the table energy
sum_{a,b} p_i(a)p_j(b)h_ij(a,b)².
-/

namespace Nightfall.Observability.ActualESInfluenceIdentity

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESConditionalSection
open Nightfall.Observability.ActualESOrthogonalEnergy

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- For the genuine product law, the conditional mean is orthogonal
to the centered conditional residual. -/
theorem source_conditional_cross_identity
    (p : ι → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    sourceInner p f (pavg p i f) =
      sourceInner p (pavg p i f) (pavg p i f) := by
  classical
  let g := pavg p i f
  have hg (x : ι → α) (b : α) :
      g (Function.update x i b) = g x :=
    pavg_update p i f x b
  unfold sourceInner
  calc
    (∑ x : ι → α, prodMass p x * (f x * g x)) =
        (∑ x : ι → α, ∑ b : α,
          prodMass p x * p i b *
            (f (Function.update x i b) *
              g (Function.update x i b))) :=
      (resample_sum p hp1 i (fun y => f y * g y)).symm
    _ = ∑ x : ι → α, prodMass p x * (g x * g x) := by
      apply Finset.sum_congr rfl
      intro x _
      simp_rw [hg x]
      calc
        (∑ b : α, prodMass p x * p i b *
          (f (Function.update x i b) * g x)) =
          ∑ b : α, (prodMass p x * g x) *
            (p i b * f (Function.update x i b)) := by
              apply Finset.sum_congr rfl
              intro b _
              ring
        _ = (prodMass p x * g x) *
            (∑ b : α, p i b * f (Function.update x i b)) := by
              rw [Finset.mul_sum]
        _ = prodMass p x * (g x * g x) := by
              dsimp [g, pavg]
              ring

/-- Bilinear source energy of the actual residual expands exactly.
No positivity assumption or measure-theoretic inequality is used. -/
theorem source_conditional_residual_square
    (p : ι → α → ℝ)
    (f g : (ι → α) → ℝ) :
    sourceInner p (fun x => f x - g x)
      (fun x => f x - g x) =
      sourceInner p f f - 2 * sourceInner p f g +
        sourceInner p g g := by
  classical
  unfold sourceInner
  calc
    (∑ x : ι → α, prodMass p x *
      ((f x - g x) * (f x - g x))) =
      ∑ x : ι → α,
        (prodMass p x * (f x * f x) -
          2 * (prodMass p x * (f x * g x)) +
          prodMass p x * (g x * g x)) := by
            apply Finset.sum_congr rfl
            intro x _
            ring
    _ = (∑ x : ι → α, prodMass p x * (f x * f x)) -
        2 * (∑ x : ι → α, prodMass p x * (f x * g x)) +
        (∑ x : ι → α, prodMass p x * (g x * g x)) := by
          simp only [Finset.sum_add_distrib,
            Finset.sum_sub_distrib, ← Finset.mul_sum]

/-- The original source influence is the actual product expectation
of the square of the one-site centered section. This is derived from
the already-proved exact variance-under-resampling decomposition,
not introduced as an influence hypothesis. -/
theorem actual_influence_eq_centered_section_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    pinfl p f i =
      sourceInner p (fun x => f x - pavg p i f x)
        (fun x => f x - pavg p i f x) := by
  let g : (ι → α) → ℝ := pavg p i f
  have hvar := pvar_avg p hp1 i f
  have hvf := pvar_eq p hp1 f
  have hvg := pvar_eq p hp1 g
  have hmean : pexp p g = pexp p f :=
    pexp_avg p hp1 i f
  rw [hvf, hvg, hmean] at hvar
  have hsource :
      pinfl p f i = sourceInner p f f - sourceInner p g g := by
    unfold sourceInner
    linarith [hvar]
  have hcross := source_conditional_cross_identity p hp1 f i
  have hres := source_conditional_residual_square p f g
  change sourceInner p f g = sourceInner p g g at hcross
  change pinfl p f i =
    sourceInner p (fun x => f x - g x)
      (fun x => f x - g x)
  linarith [hsource, hres, hcross]

/-- Genuine influence is *exactly* the sum of the original source
Hoeffding L2 energies supported on i, with the degree-two cutoff.
No source energy cap is supplied. -/
theorem actual_quadratic_source_influence_parseval
    (p : ι → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) :
    pinfl p f i =
      ∑ S : Finset ι,
        if S.card ≤ 2 ∧ i ∈ S then
          sourceInner p (esComp p S f) (esComp p S f)
        else 0 := by
  classical
  let G : Finset ι → (ι → α) → ℝ :=
    fun S x => if S.card ≤ 2 ∧ i ∈ S then
      esComp p S f x else 0
  have hsection (x : ι → α) :
      f x - pavg p i f x = ∑ S : Finset ι, G S x := by
    have h := actual_centered_section_eq_hilbert_ANOVA
      p hp1 f hdegree i x (x i)
    simpa only [actualCenteredSection, G, pavg,
      Function.update_eq_self] using h
  have hortho : ∀ S T : Finset ι, S ≠ T →
      sourceInner p (G S) (G T) = 0 := by
    intro S T hne
    by_cases hs : S.card ≤ 2 ∧ i ∈ S
    · by_cases ht : T.card ≤ 2 ∧ i ∈ T
      · simpa only [G, if_pos hs, if_pos ht] using
          (actual_esComp_orthogonal_distinct p hp1 f S T hne)
      · simp [sourceInner, G, ht]
    · simp [sourceInner, G, hs]
  have hp := sourceInner_parseval_of_orthogonal p G hortho
  rw [actual_influence_eq_centered_section_energy p hp1 f i]
  calc
    sourceInner p (fun x => f x - pavg p i f x)
      (fun x => f x - pavg p i f x) =
      sourceInner p (fun x => ∑ S : Finset ι, G S x)
        (fun x => ∑ S : Finset ι, G S x) := by
          unfold sourceInner
          apply Finset.sum_congr rfl
          intro x _
          rw [← hsection x]
    _ = ∑ S : Finset ι, sourceInner p (G S) (G S) := hp
    _ = ∑ S : Finset ι,
        if S.card ≤ 2 ∧ i ∈ S then
          sourceInner p (esComp p S f) (esComp p S f)
        else 0 := by
          apply Finset.sum_congr rfl
          intro S _
          by_cases hs : S.card ≤ 2 ∧ i ∈ S
          · simp [G, hs]
          · simp [sourceInner, G, hs]

end Nightfall.Observability.ActualESInfluenceIdentity
