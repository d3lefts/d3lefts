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


/-- The character projector is nonexpansive in the uniform scalar
error bound. This is the exact stability step needed after approximating
a continuous map by a smooth map, before the topological parity argument. -/
theorem charU_error_le (f g : X → X → ℝ) (ε : ℝ)
    (h : ∀ u v, |f u v - g u v| ≤ ε) (u v : X) :
    |charU f u v - charU g u v| ≤ ε := by
  let a := f u v - g u v
  let b := f (-u) v - g (-u) v
  let c := f u (-v) - g u (-v)
  let d := f (-u) (-v) - g (-u) (-v)
  have heq : charU f u v - charU g u v =
      (a - b + c - d) / 4 := by
    dsimp [a,b,c,d,charU]
    ring
  have htri : |a - b + c - d| ≤ |a| + |b| + |c| + |d| := by
    have hA := abs_sub (a - b + c) d
    have hB := abs_add (a - b) c
    have hC := abs_sub a b
    linarith
  have hbound : |a - b + c - d| ≤ 4 * ε := by
    have ha := h u v
    have hb := h (-u) v
    have hc := h u (-v)
    have hd := h (-u) (-v)
    dsimp [a,b,c,d] at htri
    dsimp [a,b,c,d] at *
    linarith
  rw [heq, abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 4)]
  exact (div_le_iff₀ (by norm_num : (0 : ℝ) < 4)).mpr hbound

/-- The second character projection is the first after swapping factors. -/
theorem charV_eq_charU_swap (f : X → X → ℝ) (u v : X) :
    charV f u v = charU (fun x y => f y x) v u := by
  simp only [charU, charV]
  ring

theorem charV_error_le (f g : X → X → ℝ) (ε : ℝ)
    (h : ∀ u v, |f u v - g u v| ≤ ε) (u v : X) :
    |charV f u v - charV g u v| ≤ ε := by
  rw [charV_eq_charU_swap, charV_eq_charU_swap]
  exact charU_error_le (fun x y => f y x) (fun x y => g y x)
    ε (fun x y => h y x) v u

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
#print axioms charU_error_le
#print axioms charV_eq_charU_swap
#print axioms charV_error_le
#print axioms continuous_charU
#print axioms continuous_charV

end Nightfall.ProductBUCharacterAverage
