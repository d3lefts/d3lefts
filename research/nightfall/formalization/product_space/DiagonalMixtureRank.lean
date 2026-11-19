import Mathlib

/-!
# NIGHTFALL: exact latent product-mixture rank on a diagonal graph

A uniform distribution on (Z,Z), with Z a vector of N fair bits,
has an exponential full-coordinate product-mixture rank, even though
the second N coordinates duplicate the first N verbatim.

This shows why mixture component count is *not necessary* for
query-efficient simulation: a coordinate-identification quotient can
restore an independent source without losing any observable information.

The proof below is an unconditional FINITE table/rectangle certificate.
It uses no Shannon entropy, no Gaussian hypothesis, and allows zero
mixture weights and zero component masses.
-/

namespace Nightfall.Structure.DiagonalMixtureRank

open Finset

variable {F Θ : Type*} [Fintype F] [Fintype Θ]

/-- A nonnegative mixture of block-product tables whose off-diagonal
    entries vanish but all diagonal entries are positive needs at
    least one distinct latent component per diagonal entry.

    Within each block, component distributions can be arbitrary;
    only conditional independence between blocks is used. -/
theorem diagonal_requires_components
    (w : Θ → ℝ) (a b : Θ → F → ℝ)
    (hw : ∀ θ, 0 ≤ w θ)
    (ha : ∀ θ f, 0 ≤ a θ f)
    (hb : ∀ θ f, 0 ≤ b θ f)
    (hdiag : ∀ f, 0 < ∑ θ : Θ, (w θ * a θ f) * b θ f)
    (hoff : ∀ f g, f ≠ g → (∑ θ : Θ, (w θ * a θ f) * b θ g) = 0) :
    Fintype.card F ≤ Fintype.card Θ := by
  classical
  have hex : ∀ f : F, ∃ θ : Θ, 0 < (w θ * a θ f) * b θ f := by
    intro f
    by_contra h
    push_neg at h
    have hs : (∑ θ : Θ, (w θ * a θ f) * b θ f) ≤ 0 :=
      Finset.sum_nonpos fun θ _ => h θ
    exact (not_le_of_gt (hdiag f)) hs
  choose pick hpick using hex
  have hinj : Function.Injective pick := by
    intro f g hpfg
    by_contra hfg
    have hf := hpick f
    have hg := hpick g
    rw [← hpfg] at hg
    have hwpos : 0 < w (pick f) := by
      rcases (hw (pick f)).eq_or_lt with hz | hh
      · rw [← hz] at hf
        simp at hf
      · exact hh
    have hap : 0 < a (pick f) f := by
      rcases (ha (pick f) f).eq_or_lt with hz | hh
      · rw [← hz] at hf
        simp at hf
      · exact hh
    have hbp : 0 < b (pick f) g := by
      rcases (hb (pick f) g).eq_or_lt with hz | hh
      · rw [← hz] at hg
        simp at hg
      · exact hh
    have hcross : 0 < (w (pick f) * a (pick f) f) * b (pick f) g :=
      mul_pos (mul_pos hwpos hap) hbp
    have hterm : (w (pick f) * a (pick f) f) * b (pick f) g ≤
        ∑ θ : Θ, (w θ * a θ f) * b θ g := by
      exact Finset.single_le_sum
        (fun θ (_ : θ ∈ Finset.univ) =>
          mul_nonneg (mul_nonneg (hw θ) (ha θ f)) (hb θ g))
        (Finset.mem_univ (pick f))
    rw [hoff f g hfg] at hterm
    linarith
  exact Fintype.card_le_of_injective pick hinj

/-- For a vector of N Boolean coordinates, the diagonal table requires
    at least 2^N latent block-product components, even before imposing
    independence *inside* the two N-coordinate blocks. -/
theorem boolean_diagonal_exponential
    {N : ℕ} {Θ : Type*} [Fintype Θ]
    (w : Θ → ℝ) (a b : Θ → (Fin N → Bool) → ℝ)
    (hw : ∀ θ, 0 ≤ w θ)
    (ha : ∀ θ f, 0 ≤ a θ f)
    (hb : ∀ θ f, 0 ≤ b θ f)
    (hdiag : ∀ f, 0 < ∑ θ : Θ, (w θ * a θ f) * b θ f)
    (hoff : ∀ f g, f ≠ g →
      (∑ θ : Θ, (w θ * a θ f) * b θ g) = 0) :
    2 ^ N ≤ Fintype.card Θ := by
  have h := diagonal_requires_components w a b hw ha hb hdiag hoff
  simpa only [Fintype.card_fun, Fintype.card_fin, Fintype.card_bool] using h

#print axioms Nightfall.Structure.DiagonalMixtureRank.diagonal_requires_components
#print axioms Nightfall.Structure.DiagonalMixtureRank.boolean_diagonal_exponential

end Nightfall.Structure.DiagonalMixtureRank
