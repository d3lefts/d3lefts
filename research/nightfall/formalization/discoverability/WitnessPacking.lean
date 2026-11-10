import Mathlib

/-!
NIGHTFALL: finite sensor-agnostic witness packing and certificate bounds.

No probabilistic distribution, product independence, Boolean alphabet, Fourier
or Hoeffding theorem is assumed. The result is a classical maximal packing
observation, not a historical novelty claim and not an end-to-end adaptive
policy construction.
-/

namespace Nightfall.Discoverability

open Finset

variable {State Sensor Answer Output : Type*}
variable [Fintype Sensor] [DecidableEq Sensor]

/-- Two states agree on the queried sensor coordinates. -/
def AgreeOn (read : State → Sensor → Answer)
    (Q : Finset Sensor) (x y : State) : Prop :=
  ∀ i ∈ Q, read x i = read y i

/-- Two states agree outside the sensors in B. -/
def AgreeOutside (read : State → Sensor → Answer)
    (B : Finset Sensor) (x y : State) : Prop :=
  ∀ i, i ∉ B → read x i = read y i

/-- A block-sensitive change requires an actual admissible state.
State is the type of admissible states. -/
def SensitiveAt (read : State → Sensor → Answer)
    (f : State → Output) (x : State) (B : Finset Sensor) : Prop :=
  ∃ y : State, f y ≠ f x ∧ AgreeOutside read B x y

/-- A set of observations certifies the target at a particular state. -/
def CertificateAt (read : State → Sensor → Answer)
    (f : State → Output) (x : State) (Q : Finset Sensor) : Prop :=
  ∀ y : State, AgreeOn read Q x y → f y = f x

/-- Complete sensor transcripts determine all target labels. -/
def Identifiable (read : State → Sensor → Answer)
    (f : State → Output) : Prop :=
  ∀ x y : State, (∀ i, read x i = read y i) → f x = f y

/-- Union of the blocks selected by a packing. -/
def observedUnion (P : Finset (Finset Sensor)) : Finset Sensor :=
  P.biUnion id

/-- Every sensitive block intersects at least one chosen block. -/
def HitsSensitive (read : State → Sensor → Answer)
    (f : State → Output) (x : State)
    (P : Finset (Finset Sensor)) : Prop :=
  ∀ B : Finset Sensor, SensitiveAt read f x B →
    ∃ C ∈ P, ¬ Disjoint B C

/-- A hitting family of sensitive blocks gives an exact target certificate. -/
theorem hitting_implies_certificate
    (read : State → Sensor → Answer) (f : State → Output)
    (x : State) (P : Finset (Finset Sensor))
    (hHits : HitsSensitive read f x P) :
    CertificateAt read f x (observedUnion P) := by
  intro y hAgree
  by_contra hDifferent
  let Q : Finset Sensor := observedUnion P
  let B : Finset Sensor := Finset.univ \ Q
  have hOut : AgreeOutside read B x y := by
    intro i hiB
    have hiQ : i ∈ Q := by
      by_contra hiQ
      exact hiB (Finset.mem_sdiff.mpr ⟨Finset.mem_univ _, hiQ⟩)
    exact hAgree i hiQ
  have hSensitive : SensitiveAt read f x B := ⟨y, hDifferent, hOut⟩
  obtain ⟨C, hC, hIntersect⟩ := hHits B hSensitive
  have hDisjoint : Disjoint B C := by
    apply Finset.disjoint_left.mpr
    intro i hiB hiC
    have hiQ : i ∈ Q := Finset.mem_biUnion.mpr ⟨C, hC, hiC⟩
    exact (Finset.mem_sdiff.mp hiB).2 hiQ
  exact hIntersect hDisjoint

/-- A union of at most r blocks of width w costs at most w*r sensors. -/
theorem bounded_union_cost
    (P : Finset (Finset Sensor)) (w r : ℕ)
    (hWidth : ∀ B ∈ P, B.card ≤ w)
    (hRank : P.card ≤ r) :
    (observedUnion P).card ≤ w * r := by
  calc
    (observedUnion P).card ≤ ∑ B ∈ P, B.card := Finset.card_biUnion_le
    _ ≤ ∑ _B ∈ P, w := Finset.sum_le_sum (fun B hB => hWidth B hB)
    _ = P.card * w := by simp
    _ = w * P.card := by omega
    _ ≤ w * r := Nat.mul_le_mul_left w hRank

/-- An exact finite certificate with independently checkable hitting and width. -/
theorem witness_packing_certificate
    (read : State → Sensor → Answer) (f : State → Output)
    (x : State) (P : Finset (Finset Sensor)) (w r : ℕ)
    (hHits : HitsSensitive read f x P)
    (hWidth : ∀ B ∈ P, B.card ≤ w)
    (hRank : P.card ≤ r) :
    CertificateAt read f x (observedUnion P) ∧
      (observedUnion P).card ≤ w * r := by
  exact ⟨hitting_implies_certificate read f x P hHits,
    bounded_union_cost P w r hWidth hRank⟩

/-- A conflicting pair with identical complete sensor records rules out any certificate. -/
theorem conflicting_twins_block_all_certificates
    (read : State → Sensor → Answer) (f : State → Output)
    (x y : State)
    (hSame : ∀ i, read x i = read y i)
    (hConflict : f x ≠ f y) (Q : Finset Sensor) :
    ¬ CertificateAt read f x Q := by
  intro hCert
  exact hConflict (hCert y (fun i hi => hSame i)).symm

/-- Identifiability supplies a potentially expensive full sensor certificate. -/
theorem full_transcript_certifies
    (read : State → Sensor → Answer) (f : State → Output)
    (hIdent : Identifiable read f) (x : State) :
    CertificateAt read f x Finset.univ := by
  intro y hAgree
  exact (hIdent x y (fun i => hAgree i (Finset.mem_univ _))).symm

end Nightfall.Discoverability
