import Mathlib

/-!
# Two-character Reynolds averaging, source-pinned Lean certification

The four-term average is the explicit projector onto either of the two
characters of (Z/2)^2 acting by independent sign changes. The sign identities
and projection identities do not depend on the topology zero theorem.

This formalizes a precise piece of the equivariant approximation step in the
NIGHTFALL ProductSphereZero parity-cobordism route (#1024).

IMPORTANT: Nothing in this file proves ProductSphereZero, general equivariant
transversality, or odd boundary parity of a compact one-manifold.
-/

namespace Nightfall.ProductBUCharacterAverage

variable {X : Type*} [AddCommGroup X]

/-- Odd in the first input, even in the second input. -/
noncomputable def charU (f : X → X → ℝ) (u v : X) : ℝ :=
  (f u v - f (-u) v + f u (-v) - f (-u) (-v)) / 4

/-- Even in the first input, odd in the second input. -/
noncomputable def charV (f : X → X → ℝ) (u v : X) : ℝ :=
  (f u v + f (-u) v - f u (-v) - f (-u) (-v)) / 4

theorem charU_flip_left (f : X → X → ℝ) (u v : X) :
    charU f (-u) v = -charU f u v := by
  simp only [charU, neg_neg]
  ring

theorem charU_flip_right (f : X → X → ℝ) (u v : X) :
    charU f u (-v) = charU f u v := by
  simp only [charU, neg_neg]
  ring

theorem charV_flip_left (f : X → X → ℝ) (u v : X) :
    charV f (-u) v = charV f u v := by
  simp only [charV, neg_neg]
  ring

theorem charV_flip_right (f : X → X → ℝ) (u v : X) :
    charV f u (-v) = -charV f u v := by
  simp only [charV, neg_neg]
  ring

/-- Averaging fixes any map that already has the required character. -/
theorem charU_fixed (f : X → X → ℝ)
    (hleft : ∀ u v, f (-u) v = -f u v)
    (hright : ∀ u v, f u (-v) = f u v) (u v : X) :
    charU f u v = f u v := by
  have hboth : f (-u) (-v) = -f u v := by
    rw [hright (-u) v, hleft u v]
  unfold charU
  rw [hleft u v, hright u v, hboth]
  ring

theorem charV_fixed (f : X → X → ℝ)
    (hleft : ∀ u v, f (-u) v = f u v)
    (hright : ∀ u v, f u (-v) = -f u v) (u v : X) :
    charV f u v = f u v := by
  have hboth : f (-u) (-v) = -f u v := by
    rw [hright (-u) v, hleft u v]
  unfold charV
  rw [hleft u v, hright u v, hboth]
  ring

theorem charU_idempotent (f : X → X → ℝ) (u v : X) :
    charU (charU f) u v = charU f u v :=
  charU_fixed (charU f) (charU_flip_left f) (charU_flip_right f) u v

theorem charV_idempotent (f : X → X → ℝ) (u v : X) :
    charV (charV f) u v = charV f u v :=
  charV_fixed (charV f) (charV_flip_left f) (charV_flip_right f) u v

/-- The two distinct pure-character projectors are orthogonal. -/
theorem charU_charV_zero (f : X → X → ℝ) (u v : X) :
    charU (charV f) u v = 0 := by
  simp only [charU, charV, neg_neg]
  ring

theorem charV_charU_zero (f : X → X → ℝ) (u v : X) :
    charV (charU f) u v = 0 := by
  simp only [charU, charV, neg_neg]
  ring

section Continuous

variable [TopologicalSpace X] [ContinuousNeg X]

/-- The exact sign projection preserves global continuity. -/
theorem continuous_charU (f : X → X → ℝ)
    (hf : Continuous (fun p : X × X => f p.1 p.2)) :
    Continuous (fun p : X × X => charU f p.1 p.2) := by
  have hneg1 : Continuous (fun p : X × X => -p.1) :=
    continuous_neg.comp continuous_fst
  have hneg2 : Continuous (fun p : X × X => -p.2) :=
    continuous_neg.comp continuous_snd
  have h1 : Continuous (fun p : X × X => f (-p.1) p.2) :=
    hf.comp (hneg1.prodMk continuous_snd)
  have h2 : Continuous (fun p : X × X => f p.1 (-p.2)) :=
    hf.comp (continuous_fst.prodMk hneg2)
  have h3 : Continuous (fun p : X × X => f (-p.1) (-p.2)) :=
    hf.comp (hneg1.prodMk hneg2)
  have h := ((hf.sub h1).add h2).sub h3
  simpa only [charU, Pi.sub_apply, Pi.add_apply] using h.div_const 4

theorem continuous_charV (f : X → X → ℝ)
    (hf : Continuous (fun p : X × X => f p.1 p.2)) :
    Continuous (fun p : X × X => charV f p.1 p.2) := by
  have hneg1 : Continuous (fun p : X × X => -p.1) :=
    continuous_neg.comp continuous_fst
  have hneg2 : Continuous (fun p : X × X => -p.2) :=
    continuous_neg.comp continuous_snd
  have h1 : Continuous (fun p : X × X => f (-p.1) p.2) :=
    hf.comp (hneg1.prodMk continuous_snd)
  have h2 : Continuous (fun p : X × X => f p.1 (-p.2)) :=
    hf.comp (continuous_fst.prodMk hneg2)
  have h3 : Continuous (fun p : X × X => f (-p.1) (-p.2)) :=
    hf.comp (hneg1.prodMk hneg2)
  have h := ((hf.add h1).sub h2).sub h3
  simpa only [charV, Pi.sub_apply, Pi.add_apply] using h.div_const 4

end Continuous

#print axioms charU_flip_left
#print axioms charU_flip_right
#print axioms charV_flip_left
#print axioms charV_flip_right
#print axioms charU_fixed
#print axioms charV_fixed
#print axioms charU_idempotent
#print axioms charV_idempotent
#print axioms charU_charV_zero
#print axioms charV_charU_zero
#print axioms continuous_charU
#print axioms continuous_charV

end Nightfall.ProductBUCharacterAverage
