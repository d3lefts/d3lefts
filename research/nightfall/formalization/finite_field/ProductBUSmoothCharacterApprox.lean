import Mathlib
import ProductBUCharacterAverage

/-!
# Smooth two-character approximation: source-pinned Lean continuation

We continue the independently authored four-term character projection from
#1032. Pinned Mathlib already proves smooth approximation on finite-dimensional
normed spaces (Continuous.exists_contDiff_approx, SmoothApprox.lean).

The certified target is that a GLOBAL continuous real scalar response on
(R^n × R^n) with either pure antipodal character has arbitrarily close
smooth approximations with the SAME character. The proof uses a smooth
ambient approximant and the explicit Reynolds projector, which is a
contraction in the uniform/sup norm.

Caution: original ProductSphereZero maps are continuous ONLY on the
product of unit spheres. A separate continuous extension / manifold
smooth-approximation bridge must be formalized before using this theorem
directly on those inputs. More importantly, no relative transversality,
one-manifold boundary parity, or ProductSphereZero theorem is proved here.
-/

namespace Nightfall.ProductBUSmooth
open Nightfall.ProductBUCharacterAverage

abbrev V (n : ℕ) := Fin n → ℝ

/-- The four-point Reynolds character projections contract strict
pointwise uniform error bounds. This is an exact analytic inequality,
not a topological theorem. -/
theorem charU_uniform_error {X : Type*} [AddCommGroup X]
    (p f : X → X → ℝ) (ε : ℝ)
    (herr : ∀ u v, |p u v - f u v| < ε) (u v : X) :
    |charU p u v - charU f u v| < ε := by
  obtain ⟨h0l,h0u⟩ := abs_lt.mp (herr u v)
  obtain ⟨h1l,h1u⟩ := abs_lt.mp (herr (-u) v)
  obtain ⟨h2l,h2u⟩ := abs_lt.mp (herr u (-v))
  obtain ⟨h3l,h3u⟩ := abs_lt.mp (herr (-u) (-v))
  have hid : 4 * (charU p u v - charU f u v) =
      (p u v - f u v) - (p (-u) v - f (-u) v) +
      (p u (-v) - f u (-v)) -
      (p (-u) (-v) - f (-u) (-v)) := by
    unfold charU
    ring
  apply abs_lt.mpr
  constructor <;> linarith

theorem charV_uniform_error {X : Type*} [AddCommGroup X]
    (p f : X → X → ℝ) (ε : ℝ)
    (herr : ∀ u v, |p u v - f u v| < ε) (u v : X) :
    |charV p u v - charV f u v| < ε := by
  obtain ⟨h0l,h0u⟩ := abs_lt.mp (herr u v)
  obtain ⟨h1l,h1u⟩ := abs_lt.mp (herr (-u) v)
  obtain ⟨h2l,h2u⟩ := abs_lt.mp (herr u (-v))
  obtain ⟨h3l,h3u⟩ := abs_lt.mp (herr (-u) (-v))
  have hid : 4 * (charV p u v - charV f u v) =
      (p u v - f u v) + (p (-u) v - f (-u) v) -
      (p u (-v) - f u (-v)) -
      (p (-u) (-v) - f (-u) (-v)) := by
    unfold charV
    ring
  apply abs_lt.mpr
  constructor <;> linarith

/-- Smoothness of either projected character. This uses only
smoothness of the approximant on the ambient normed vector space. -/
theorem contDiff_charU (n : ℕ) (p : (V n × V n) → ℝ)
    (hp : ContDiff ℝ ⊤ p) :
    ContDiff ℝ ⊤ (fun z : V n × V n =>
      charU (fun u v => p (u,v)) z.1 z.2) := by
  have hleft : ContDiff ℝ ⊤ (fun z : V n × V n => (-z.1,z.2)) :=
    (contDiff_neg.comp contDiff_fst).prodMk contDiff_snd
  have hright : ContDiff ℝ ⊤ (fun z : V n × V n => (z.1,-z.2)) :=
    contDiff_fst.prodMk (contDiff_neg.comp contDiff_snd)
  have hboth : ContDiff ℝ ⊤ (fun z : V n × V n => (-z.1,-z.2)) :=
    (contDiff_neg.comp contDiff_fst).prodMk (contDiff_neg.comp contDiff_snd)
  have h := ((hp.sub (hp.comp hleft)).add (hp.comp hright)).sub (hp.comp hboth)
  simpa only [charU] using h.div_const 4

theorem contDiff_charV (n : ℕ) (p : (V n × V n) → ℝ)
    (hp : ContDiff ℝ ⊤ p) :
    ContDiff ℝ ⊤ (fun z : V n × V n =>
      charV (fun u v => p (u,v)) z.1 z.2) := by
  have hleft : ContDiff ℝ ⊤ (fun z : V n × V n => (-z.1,z.2)) :=
    (contDiff_neg.comp contDiff_fst).prodMk contDiff_snd
  have hright : ContDiff ℝ ⊤ (fun z : V n × V n => (z.1,-z.2)) :=
    contDiff_fst.prodMk (contDiff_neg.comp contDiff_snd)
  have hboth : ContDiff ℝ ⊤ (fun z : V n × V n => (-z.1,-z.2)) :=
    (contDiff_neg.comp contDiff_fst).prodMk (contDiff_neg.comp contDiff_snd)
  have h := ((hp.add (hp.comp hleft)).sub (hp.comp hright)).sub (hp.comp hboth)
  simpa only [charV] using h.div_const 4

/-- Global smooth approximation retaining U-odd/V-even symmetry.
This uses the already-pinned Mathlib smoothing theorem. -/
theorem exists_smooth_charU_approx (n : ℕ)
    (f : V n → V n → ℝ)
    (hf : Continuous (fun z : V n × V n => f z.1 z.2))
    (hleft : ∀ u v, f (-u) v = -f u v)
    (hright : ∀ u v, f u (-v) = f u v)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ g : V n → V n → ℝ,
      ContDiff ℝ ⊤ (fun z : V n × V n => g z.1 z.2) ∧
      (∀ u v, |g u v - f u v| < ε) ∧
      (∀ u v, g (-u) v = -g u v) ∧
      (∀ u v, g u (-v) = g u v) := by
  obtain ⟨p, hp, hd, _⟩ :=
    (Continuous.exists_contDiff_approx ⊤ hf
      (continuous_const : Continuous (fun _ : V n × V n => ε))
      (fun _ => hε))
  let g (u v : V n) : ℝ := charU (fun a b => p (a,b)) u v
  refine ⟨g, contDiff_charU n p hp, ?_, ?_, ?_⟩
  · intro u v
    have he : ∀ a b : V n, |p (a,b) - f a b| < ε := by
      intro a b
      simpa [Real.dist_eq] using hd (a,b)
    have he' := charU_uniform_error (fun a b => p (a,b)) f ε he u v
    simpa only [g, charU_fixed f hleft hright u v] using he'
  · intro u v
    exact charU_flip_left (fun a b => p (a,b)) u v
  · intro u v
    exact charU_flip_right (fun a b => p (a,b)) u v

/-- Symmetric V-even/U-odd variant. -/
theorem exists_smooth_charV_approx (n : ℕ)
    (f : V n → V n → ℝ)
    (hf : Continuous (fun z : V n × V n => f z.1 z.2))
    (hleft : ∀ u v, f (-u) v = f u v)
    (hright : ∀ u v, f u (-v) = -f u v)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ g : V n → V n → ℝ,
      ContDiff ℝ ⊤ (fun z : V n × V n => g z.1 z.2) ∧
      (∀ u v, |g u v - f u v| < ε) ∧
      (∀ u v, g (-u) v = g u v) ∧
      (∀ u v, g u (-v) = -g u v) := by
  obtain ⟨p, hp, hd, _⟩ :=
    (Continuous.exists_contDiff_approx ⊤ hf
      (continuous_const : Continuous (fun _ : V n × V n => ε))
      (fun _ => hε))
  let g (u v : V n) : ℝ := charV (fun a b => p (a,b)) u v
  refine ⟨g, contDiff_charV n p hp, ?_, ?_, ?_⟩
  · intro u v
    have he : ∀ a b : V n, |p (a,b) - f a b| < ε := by
      intro a b
      simpa [Real.dist_eq] using hd (a,b)
    have he' := charV_uniform_error (fun a b => p (a,b)) f ε he u v
    simpa only [g, charV_fixed f hleft hright u v] using he'
  · intro u v
    exact charV_flip_left (fun a b => p (a,b)) u v
  · intro u v
    exact charV_flip_right (fun a b => p (a,b)) u v

#print axioms charU_uniform_error
#print axioms charV_uniform_error
#print axioms contDiff_charU
#print axioms contDiff_charV
#print exists_smooth_charU_approx
#print axioms exists_smooth_charU_approx
#print exists_smooth_charV_approx
#print axioms exists_smooth_charV_approx

end Nightfall.ProductBUSmooth
