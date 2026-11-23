import T2ZeroTripleMultiplicity
import T2CorrectionSix

/-!
# NIGHTFALL T2 — exact zero-triple event → sixfold correction bridge

The existing source-pinned zero-triple Lean kernel proves that four
extended survivor indicators have event multiplicity 0, 1, or 2.
The separate six-lift kernel bounds the actual ordered-pair correction
cover by six times the nonzero pair XOR fiber.

This file *composes those source truths* and proves every exactly-two
survivor tuple lies in that sixfold cover at the actual four-slot XOR
frequency z. This is the missing semantic link needed before using
the 6*M2 correction bound in the coefficient-31 Fourier estimate.

All labels live in a characteristic-two additive group. Repetition,
zero labels and the actual frequency are not treated informally.
This is not the full quantum/light-frame/Fourier terminal.
-/

namespace Nightfall.StructuralInformation.T2CorrectionEventBridge

open Finset
open Nightfall.StructuralInformation.T2ZeroTripleMultiplicity
open Nightfall.StructuralInformation.T2CorrectionSix

variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-- Cancel exactly two occurrences of a repeated nonzero XOR label.
No counting or finite-size hypothesis is involved. -/
theorem drop_two_equal_labels
    (h₂ : ∀ x : G, x + x = 0)
    (u v y w z : G) (hu : u = z) (hv : v = z)
    (hfreq : u + v + y + w = z) : y + w = z := by
  simpa [hu, hv, h₂ z] using hfreq

/-- The complete six-case event-to-cover implication. The actual
four-slot XOR frequency and the two equal survivor labels are derived
from the source zero-triple event equations, not postulated. -/
theorem two_zero_triple_events_in_six_cover
    (h₂ : ∀ x : G, x + x = 0)
    (a b c d z : G)
    (hfreq : a + b + c + d = z)
    (htwo : exactlyTwo (e0 a b c d) (e1 a b c d)
      (e2 a b c d) (e3 a b c d)) :
    correctionCover z a b c d := by
  unfold correctionCover
  rcases htwo with h01 | h02 | h03 | h12 | h13 | h23
  · rcases h01 with ⟨h0, h1, _, _⟩
    have ha : a = z :=
      (((e0_iff_survivor_total a b c d).mp h0).2).symm.trans hfreq
    have hb : b = z :=
      (((e1_iff_survivor_total a b c d).mp h1).2).symm.trans hfreq
    left
    exact ⟨ha, hb, drop_two_equal_labels h₂ a b c d z ha hb hfreq⟩
  · rcases h02 with ⟨h0, _, h2, _⟩
    have ha : a = z :=
      (((e0_iff_survivor_total a b c d).mp h0).2).symm.trans hfreq
    have hc : c = z :=
      (((e2_iff_survivor_total a b c d).mp h2).2).symm.trans hfreq
    have horder : a + c + b + d = z := by
      calc
        a + c + b + d = a + b + c + d := by abel
        _ = z := hfreq
    right
    left
    exact ⟨ha, hc, drop_two_equal_labels h₂ a c b d z ha hc horder⟩
  · rcases h03 with ⟨h0, _, _, h3⟩
    have ha : a = z :=
      (((e0_iff_survivor_total a b c d).mp h0).2).symm.trans hfreq
    have hd : d = z :=
      (((e3_iff_survivor_total a b c d).mp h3).2).symm.trans hfreq
    have horder : a + d + b + c = z := by
      calc
        a + d + b + c = a + b + c + d := by abel
        _ = z := hfreq
    right
    right
    left
    exact ⟨ha, hd, drop_two_equal_labels h₂ a d b c z ha hd horder⟩
  · rcases h12 with ⟨_, h1, h2, _⟩
    have hb : b = z :=
      (((e1_iff_survivor_total a b c d).mp h1).2).symm.trans hfreq
    have hc : c = z :=
      (((e2_iff_survivor_total a b c d).mp h2).2).symm.trans hfreq
    have horder : b + c + a + d = z := by
      calc
        b + c + a + d = a + b + c + d := by abel
        _ = z := hfreq
    right
    right
    right
    left
    exact ⟨hb, hc, drop_two_equal_labels h₂ b c a d z hb hc horder⟩
  · rcases h13 with ⟨_, h1, _, h3⟩
    have hb : b = z :=
      (((e1_iff_survivor_total a b c d).mp h1).2).symm.trans hfreq
    have hd : d = z :=
      (((e3_iff_survivor_total a b c d).mp h3).2).symm.trans hfreq
    have horder : b + d + a + c = z := by
      calc
        b + d + a + c = a + b + c + d := by abel
        _ = z := hfreq
    right
    right
    right
    right
    left
    exact ⟨hb, hd, drop_two_equal_labels h₂ b d a c z hb hd horder⟩
  · rcases h23 with ⟨_, _, h2, h3⟩
    have hc : c = z :=
      (((e2_iff_survivor_total a b c d).mp h2).2).symm.trans hfreq
    have hd : d = z :=
      (((e3_iff_survivor_total a b c d).mp h3).2).symm.trans hfreq
    have horder : c + d + a + b = z := by
      calc
        c + d + a + b = a + b + c + d := by abel
        _ = z := hfreq
    right
    right
    right
    right
    right
    exact ⟨hc, hd, drop_two_equal_labels h₂ c d a b z hc hd horder⟩

/-- The *genuine source-defined* correction-event fiber, rather
than its larger six-pattern cover. -/
noncomputable def eventCorrectionFiber (D : Finset G) (z : G) :
    Finset (G × G × G × G) := by
  classical
  exact (D.product (D.product (D.product D))).filter
    (fun t =>
      t.1 + t.2.1 + t.2.2.1 + t.2.2.2 = z ∧
      exactlyTwo
        (e0 t.1 t.2.1 t.2.2.1 t.2.2.2)
        (e1 t.1 t.2.1 t.2.2.1 t.2.2.2)
        (e2 t.1 t.2.1 t.2.2.1 t.2.2.2)
        (e3 t.1 t.2.1 t.2.2.1 t.2.2.2))

theorem event_correction_subset_six_cover
    (h₂ : ∀ x : G, x + x = 0)
    (D : Finset G) (z : G) :
    eventCorrectionFiber D z ⊆ correctionFiber D z := by
  classical
  intro t ht
  rcases t with ⟨a, b, c, d⟩
  obtain ⟨hsource, ⟨hfreq, htwo⟩⟩ := Finset.mem_filter.mp ht
  change a + b + c + d = z at hfreq
  change exactlyTwo (e0 a b c d) (e1 a b c d)
    (e2 a b c d) (e3 a b c d) at htwo
  exact Finset.mem_filter.mpr
    ⟨hsource, two_zero_triple_events_in_six_cover h₂ a b c d z hfreq htwo⟩

/-- Exact universal upper bound for the paper's joint double-counted
zero-triple correction family, in terms of the ordered original
nonzero-frequency pair fiber. This closes the missing 6*M2 combinatorial
bridge without a finite-only enumeration. -/
theorem event_correction_card_le_six_pair_fiber
    (h₂ : ∀ x : G, x + x = 0)
    (D : Finset G) (z : G) :
    (eventCorrectionFiber D z).card ≤ 6 * (pairFiber D z).card :=
  (Finset.card_le_card (event_correction_subset_six_cover h₂ D z)).trans
    (correction_fiber_card_le_six_pair_fiber D z)

theorem event_correction_card_le_six_M
    (h₂ : ∀ x : G, x + x = 0)
    (D : Finset G) (z : G) (M : ℕ)
    (hM : (pairFiber D z).card ≤ M) :
    (eventCorrectionFiber D z).card ≤ 6 * M :=
  (event_correction_card_le_six_pair_fiber h₂ D z).trans
    (Nat.mul_le_mul_left 6 hM)

#print axioms Nightfall.StructuralInformation.T2CorrectionEventBridge.drop_two_equal_labels
#print axioms Nightfall.StructuralInformation.T2CorrectionEventBridge.two_zero_triple_events_in_six_cover
#print axioms Nightfall.StructuralInformation.T2CorrectionEventBridge.event_correction_subset_six_cover
#print axioms Nightfall.StructuralInformation.T2CorrectionEventBridge.event_correction_card_le_six_pair_fiber
#print axioms Nightfall.StructuralInformation.T2CorrectionEventBridge.event_correction_card_le_six_M

end Nightfall.StructuralInformation.T2CorrectionEventBridge
