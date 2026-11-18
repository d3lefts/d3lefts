import LatentMixtureInfluence
import LatentMixtureAmplification

/-!
# True-site latent-mixture influence terminal (finite factorized fibres)

This integrates the finite exact conditional-mixture variance comparison
with weighted Jensen/witness amplification. The assumptions are:
* each original-site fibre has component factorization q_theta(others)*p_theta(site);
* a component AA witness exists in a finite common coordinate set;
* at least κ of total variance remains within mixture components;
* M bounds the actual joint-source conditional-variance energies.

No density floor or global absolute continuity hypothesis is needed.
The *existence* of component AA witnesses from #858 and the identification
of every arbitrary source's conditional measure with these factorized
fibres are downstream source-notation integration obligations.
-/

namespace Nightfall.LatentMixture

open Finset

variable {Θ ι : Type*} [Fintype Θ] [DecidableEq Θ]
  [Fintype ι] [DecidableEq ι]
  {Γ A : ι → Type*}
  [∀ i, Fintype (Γ i)] [∀ i, DecidableEq (Γ i)]
  [∀ i, Fintype (A i)] [∀ i, DecidableEq (A i)]

/-- Exact one-site resampling influence under latent component θ,
after conditioning on all other coordinates γ. -/
noncomputable def componentSiteInfluence
    (q : (i : ι) → Θ → Γ i → ℝ)
    (p : (i : ι) → Θ → A i → ℝ)
    (g : (i : ι) → Γ i → A i → ℝ)
    (θ : Θ) (i : ι) : ℝ :=
    ∑ γ : Γ i, q i θ γ *
      (∑ a : A i, p i θ a * (g i γ a - mean (p i θ) (g i γ))^2)

/-- Exact conditional-variance energy for a rowwise prediction z on the
correlated mixture, with a density represented as a latent mixture. -/
noncomputable def mixedSiteEnergy
    (w : Θ → ℝ)
    (q : (i : ι) → Θ → Γ i → ℝ)
    (p : (i : ι) → Θ → A i → ℝ)
    (g : (i : ι) → Γ i → A i → ℝ)
    (z : (i : ι) → Γ i → ℝ)
    (i : ι) : ℝ :=
      ∑ γ : Γ i, ∑ a : A i,
        (∑ θ : Θ, w θ * q i θ γ * p i θ a) *
          (g i γ a - z i γ)^2

/-- Main integrated **conditional finite** latent-product influence bound:
finite Jensen + true mixed-fibre conditional variance + AA witnesses. -/
theorem finite_mixture_aa_influence_from_witnesses
    (w : Θ → ℝ)
    (q : (i : ι) → Θ → Γ i → ℝ)
    (p : (i : ι) → Θ → A i → ℝ)
    (g : (i : ι) → Γ i → A i → ℝ)
    (z : (i : ι) → Γ i → ℝ)
    (Vθ : Θ → ℝ) (V κ aa M : ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (hsum : (∑ θ, w θ) = 1)
    (hq : ∀ i θ γ, 0 ≤ q i θ γ)
    (hp : ∀ i θ, (∑ a, p i θ a) = 1)
    (hp0 : ∀ i θ a, 0 ≤ p i θ a)
    (hVθ : ∀ θ, 0 ≤ Vθ θ)
    (hV : 0 ≤ V) (hκ : 0 ≤ κ) (haa : 0 ≤ aa)
    (hwithin : κ * V ≤ ∑ θ, w θ * Vθ θ)
    (hwitness : ∀ θ, ∃ i,
      aa * Vθ θ ^ (5 / 2 : ℝ) ≤ componentSiteInfluence q p g θ i)
    (hbound : ∀ i, mixedSiteEnergy w q p g z i ≤ M) :
    aa * (κ * V) ^ (5 / 2 : ℝ) ≤ (Fintype.card Θ : ℝ) * M := by
  apply latent_witness_amplification w Vθ
    (fun θ i => componentSiteInfluence q p g θ i)
    (fun i => mixedSiteEnergy w q p g z i)
    V κ aa M hκ hV haa hw hsum hVθ
  · intro θ i
    unfold componentSiteInfluence
    apply Finset.sum_nonneg
    intro γ hγ
    apply mul_nonneg (hq i θ γ)
    apply Finset.sum_nonneg
    intro a ha
    exact mul_nonneg (hp0 i θ a) (sq_nonneg _)
  · exact hwithin
  · exact hwitness
  · intro i
    unfold componentSiteInfluence mixedSiteEnergy
    exact factorized_mixture_conditional_variance
      w (q i) (p i) (g i) (z i) hw (hq i) (hp i) (hp0 i)
  · exact hbound

end Nightfall.LatentMixture
