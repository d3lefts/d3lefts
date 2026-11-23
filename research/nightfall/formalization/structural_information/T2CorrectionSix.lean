import Mathlib

/-!
# NIGHTFALL T2 — exact six-lift nonzero correction fiber

The paper's zero-triple overlap correction consists of four-slot paths
whose two repeated survivor positions have value equal to the same
nonzero frequency z and whose two other slots sum to z.

This file proves the *universal, not enumerated* six-lift upper bound
directly from the actual legal label D and its ordered pair fiber:
  correctionFiber(D,z).card <= 6 * pairFiber(D,z).card.
It does not assume the estimate itself or any larger cardinality bound.
The proof is a six-position image covering, with no field-size, tensor
or rank restriction. It remains valid when the pair fiber is empty.

Linking the paper's extended zero-triple event equivalence to the
six-pattern correction predicate, and proving Fourier energy from
physical Hilbert paths, remain separate Lean proof obligations.
-/

namespace Nightfall.StructuralInformation.T2CorrectionSix

open Finset

variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-- Allowed *ordered* pair lifts of z: no zero-frequency cap is presumed. -/
noncomputable def pairFiber (D : Finset G) (z : G) : Finset (G × G) :=
  (D.product D).filter (fun p => p.1 + p.2 = z)

/-- The six possible positions of a repeated survivor equal to z.
This is the raw upper-cover for the paper's R_* correction family;
the other two labels are ordered, and must sum to z. -/
def correctionCover (z a b c d : G) : Prop :=
    (a = z ∧ b = z ∧ c + d = z) ∨
    (a = z ∧ c = z ∧ b + d = z) ∨
    (a = z ∧ d = z ∧ b + c = z) ∨
    (b = z ∧ c = z ∧ a + d = z) ∨
    (b = z ∧ d = z ∧ a + c = z) ∨
    (c = z ∧ d = z ∧ a + b = z)

/-- All correction-cover tuples using *only* labels from D. -/
noncomputable def correctionFiber (D : Finset G) (z : G) :
    Finset (G × G × G × G) := by
  classical
  exact (D.product (D.product (D.product D))).filter
    (fun t => correctionCover z t.1 t.2.1 t.2.2.1 t.2.2.2)

/-- The six legal positions of the repeated label, with ordered
survivor pair p and fixed target z. -/
noncomputable def correctionLift (z : G) (i : Fin 6) (p : G × G) :
    G × G × G × G :=
  if i = 0 then (z, z, p.1, p.2)
  else if i = 1 then (z, p.1, z, p.2)
  else if i = 2 then (z, p.1, p.2, z)
  else if i = 3 then (p.1, z, z, p.2)
  else if i = 4 then (p.1, z, p.2, z)
  else (p.1, p.2, z, z)

/-- Every correction tuple is covered by one of exactly six lifts
of an actual ordered pair in D² with sum z. -/
theorem correction_fiber_subset_six_images
    (D : Finset G) (z : G) :
    correctionFiber D z ⊆
      (((Finset.univ : Finset (Fin 6)).product (pairFiber D z)).image
        (fun p => correctionLift z p.1 p.2)) := by
  classical
  intro t ht
  rcases t with ⟨a, b, c, d⟩
  obtain ⟨hsource, hstar⟩ := Finset.mem_filter.mp ht
  have hmem : a ∈ D ∧ b ∈ D ∧ c ∈ D ∧ d ∈ D := by
    simpa only [Finset.mem_product] using hsource
  rcases hmem with ⟨ha, hb, hc, hd⟩
  have hpair (y w : G) (hy : y ∈ D) (hw : w ∈ D)
      (hsum : y + w = z) : (y, w) ∈ pairFiber D z := by
    exact Finset.mem_filter.mpr
      ⟨Finset.mem_product.mpr ⟨hy, hw⟩, hsum⟩
  rcases hstar with h01 | h02 | h03 | h12 | h13 | h23
  · refine Finset.mem_image.mpr ⟨((0 : Fin 6), (c, d)), ?_, ?_⟩
    · exact Finset.mem_product.mpr
        ⟨Finset.mem_univ _, hpair c d hc hd h01.2.2⟩
    · simp [correctionLift, h01.1, h01.2.1]
  · refine Finset.mem_image.mpr ⟨((1 : Fin 6), (b, d)), ?_, ?_⟩
    · exact Finset.mem_product.mpr
        ⟨Finset.mem_univ _, hpair b d hb hd h02.2.2⟩
    · simp [correctionLift, h02.1, h02.2.1]
  · refine Finset.mem_image.mpr ⟨((2 : Fin 6), (b, c)), ?_, ?_⟩
    · exact Finset.mem_product.mpr
        ⟨Finset.mem_univ _, hpair b c hb hc h03.2.2⟩
    · simp [correctionLift, h03.1, h03.2.1]
  · refine Finset.mem_image.mpr ⟨((3 : Fin 6), (a, d)), ?_, ?_⟩
    · exact Finset.mem_product.mpr
        ⟨Finset.mem_univ _, hpair a d ha hd h12.2.2⟩
    · simp [correctionLift, h12.1, h12.2.1]
  · refine Finset.mem_image.mpr ⟨((4 : Fin 6), (a, c)), ?_, ?_⟩
    · exact Finset.mem_product.mpr
        ⟨Finset.mem_univ _, hpair a c ha hc h13.2.2⟩
    · simp [correctionLift, h13.1, h13.2.1]
  · refine Finset.mem_image.mpr ⟨((5 : Fin 6), (a, b)), ?_, ?_⟩
    · exact Finset.mem_product.mpr
        ⟨Finset.mem_univ _, hpair a b ha hb h23.2.2⟩
    · simp [correctionLift, h23.1, h23.2.1]

/-- The source-exact paper F6 six-times-M₂ bound, proved uniformly
for any finite legal alphabet, with no cardinality inference from
numeric test data. -/
theorem correction_fiber_card_le_six_pair_fiber
    (D : Finset G) (z : G) :
    (correctionFiber D z).card ≤ 6 * (pairFiber D z).card := by
  classical
  let A : Finset ((Fin 6) × (G × G)) :=
    (Finset.univ : Finset (Fin 6)).product (pairFiber D z)
  calc
    (correctionFiber D z).card ≤
        (A.image (fun p => correctionLift z p.1 p.2)).card :=
      Finset.card_le_card (correction_fiber_subset_six_images D z)
    _ ≤ A.card := Finset.card_image_le
    _ = 6 * (pairFiber D z).card := by simp [A]

theorem correction_fiber_card_le_six_M
    (D : Finset G) (z : G) (M : ℕ)
    (hM : (pairFiber D z).card ≤ M) :
    (correctionFiber D z).card ≤ 6 * M :=
  (correction_fiber_card_le_six_pair_fiber D z).trans
    (Nat.mul_le_mul_left 6 hM)

#print axioms Nightfall.StructuralInformation.T2CorrectionSix.correction_fiber_subset_six_images
#print axioms Nightfall.StructuralInformation.T2CorrectionSix.correction_fiber_card_le_six_pair_fiber
#print axioms Nightfall.StructuralInformation.T2CorrectionSix.correction_fiber_card_le_six_M

end Nightfall.StructuralInformation.T2CorrectionSix
