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
    _ = w * P.card := by simp [Nat.mul_comm]
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

/-- A family of blocks is pairwise disjoint in the classical packing sense. -/
def DisjointPacking (P : Finset (Finset Sensor)) : Prop :=
  ∀ B ∈ P, ∀ C ∈ P, B ≠ C → Disjoint B C

/-- Identifiability rules out an empty sensitive block. -/
theorem sensitive_nonempty_of_identifiable
    (read : State → Sensor → Answer) (f : State → Output)
    (hIdent : Identifiable read f) (x : State) (B : Finset Sensor)
    (hSensitive : SensitiveAt read f x B) : B.Nonempty := by
  by_contra hEmpty
  have hBempty : B = ∅ := Finset.not_nonempty_iff_eq_empty.mp hEmpty
  obtain ⟨y, hChange, hOut⟩ := hSensitive
  have hAll : ∀ i, read x i = read y i := by
    intro i
    apply hOut i
    simp [hBempty]
  exact hChange (hIdent x y hAll).symm

/-- A disjoint sensitive packing saturating a valid rank upper bound must
hit every sensitive block. Thus its union yields a pointwise certificate. -/
theorem saturated_packing_hits
    (read : State → Sensor → Answer) (f : State → Output)
    (hIdent : Identifiable read f) (x : State)
    (P : Finset (Finset Sensor)) (r : ℕ)
    (hSensitive : ∀ B ∈ P, SensitiveAt read f x B)
    (hPairwise : DisjointPacking P)
    (hCard : P.card = r)
    (hRank : ∀ Q : Finset (Finset Sensor),
      (∀ B ∈ Q, SensitiveAt read f x B) →
      DisjointPacking Q → Q.card ≤ r) :
    HitsSensitive read f x P := by
  intro B hB
  by_contra hNoHit
  have hBdisj : ∀ C ∈ P, Disjoint B C := by
    intro C hC
    by_contra hNotDisjoint
    apply hNoHit
    exact ⟨C, hC, hNotDisjoint⟩
  have hBnonempty : B.Nonempty :=
    sensitive_nonempty_of_identifiable read f hIdent x B hB
  have hNotMem : B ∉ P := by
    intro hMem
    have hSelf : Disjoint B B := hBdisj B hMem
    have hEmpty : B = ∅ := disjoint_self.mp hSelf
    exact hBnonempty.ne_empty hEmpty
  have hSensitiveNew : ∀ C ∈ insert B P, SensitiveAt read f x C := by
    intro C hC
    rcases Finset.mem_insert.mp hC with rfl | hOld
    · exact hB
    · exact hSensitive C hOld
  have hPairwiseNew : DisjointPacking (insert B P) := by
    intro C hC D hD hNe
    rcases Finset.mem_insert.mp hC with hEqC | hOldC
    · subst C
      rcases Finset.mem_insert.mp hD with hEqD | hOldD
      · exact False.elim (hNe hEqD.symm)
      · exact hBdisj D hOldD
    · rcases Finset.mem_insert.mp hD with hEqD | hOldD
      · subst D
        exact (hBdisj C hOldC).symm
      · exact hPairwise C hOldC D hOldD hNe
  have hBound := hRank (insert B P) hSensitiveNew hPairwiseNew
  have hCardNew : (insert B P).card = P.card + 1 :=
    Finset.card_insert_of_not_mem hNotMem
  omega

/-- A size-r sensitive packing of width w certifies the target with at
most w*r sensors, provided r is the actual upper bound on all packings. -/
theorem saturated_packing_certificate
    (read : State → Sensor → Answer) (f : State → Output)
    (hIdent : Identifiable read f) (x : State)
    (P : Finset (Finset Sensor)) (w r : ℕ)
    (hSensitive : ∀ B ∈ P, SensitiveAt read f x B)
    (hPairwise : DisjointPacking P)
    (hCard : P.card = r)
    (hRank : ∀ Q : Finset (Finset Sensor),
      (∀ B ∈ Q, SensitiveAt read f x B) →
      DisjointPacking Q → Q.card ≤ r)
    (hWidth : ∀ B ∈ P, B.card ≤ w) :
    CertificateAt read f x (observedUnion P) ∧
      (observedUnion P).card ≤ w * r :=
  witness_packing_certificate read f x P w r
    (saturated_packing_hits read f hIdent x P r
      hSensitive hPairwise hCard hRank) hWidth hCard.le

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
