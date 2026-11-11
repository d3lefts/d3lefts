import WitnessPacking

/-!
NIGHTFALL adaptive witness-rank decrement.

This module proves the algebraic engine for an adaptive query protocol:
a uniformly sensitive fresh block consumes one unit of disjoint-packing
rank at every state consistent with the observed history.

It does not construct the full decision tree/policy or assert that such
blocks are cheaply computable. It assumes a nonanticipating uniform block
for the whole observation fiber.
-/

namespace Nightfall.Discoverability

open Finset

variable {State Sensor Answer Output : Type*}
variable [Fintype Sensor] [DecidableEq Sensor]

/-- The maximum disjoint packing of sensitive blocks that remain completely
unqueried after Q is bounded by r at state x. -/
def RemainingRankBound (read : State → Sensor → Answer)
    (f : State → Output) (x : State)
    (Q : Finset Sensor) (r : ℕ) : Prop :=
  ∀ P : Finset (Finset Sensor),
    (∀ B ∈ P, SensitiveAt read f x B ∧ Disjoint B Q) →
    DisjointPacking P → P.card ≤ r

/-- One block can be chosen using only the current observation fiber:
it is sensitive for every compatible state and contains no observed sensor. -/
def UniformRevealing
    (read : State → Sensor → Answer)
    (f : State → Output) (x : State)
    (Q : Finset Sensor) (w : ℕ) : Prop :=
  ∃ B : Finset Sensor,
    B.Nonempty ∧ B.card ≤ w ∧ Disjoint B Q ∧
      ∀ y, AgreeOn read Q x y → SensitiveAt read f y B

/-- After reading a fresh sensitive block B, any packing wholly outside
Q∪B can be enlarged by B; hence its rank drops by at least one. -/
theorem remaining_rank_drop
    (read : State → Sensor → Answer) (f : State → Output)
    (x : State) (Q B : Finset Sensor) (r : ℕ)
    (hB : SensitiveAt read f x B)
    (hNonempty : B.Nonempty)
    (hFresh : Disjoint B Q)
    (hRank : RemainingRankBound read f x Q (r+1)) :
    RemainingRankBound read f x (Q ∪ B) r := by
  classical
  intro P hAvail hPack
  have hPDisjointB (C : Finset Sensor) (hC : C ∈ P) : Disjoint C B := by
    apply Finset.disjoint_left.mpr
    intro i hiC hiB
    exact (Finset.disjoint_left.mp (hAvail C hC).2)
      hiC (Finset.mem_union.mpr (Or.inr hiB))
  have hBnot : B ∉ P := by
    intro hMem
    have hSelf : Disjoint B B := hPDisjointB B hMem
    exact hNonempty.ne_empty (disjoint_self.mp hSelf)
  have hAvailNew : ∀ C ∈ insert B P,
      SensitiveAt read f x C ∧ Disjoint C Q := by
    intro C hC
    rcases Finset.mem_insert.mp hC with hEq | hOld
    · subst C
      exact ⟨hB, hFresh⟩
    · obtain ⟨hSens, hD⟩ := hAvail C hOld
      refine ⟨hSens, ?_⟩
      apply Finset.disjoint_left.mpr
      intro i hiC hiQ
      exact (Finset.disjoint_left.mp hD)
        hiC (Finset.mem_union.mpr (Or.inl hiQ))
  have hPackNew : DisjointPacking (insert B P) := by
    intro C hC D hD hNe
    rcases Finset.mem_insert.mp hC with hEqC | hPC
    · subst C
      rcases Finset.mem_insert.mp hD with hEqD | hPD
      · exact False.elim (hNe hEqD.symm)
      · exact (hPDisjointB D hPD).symm
    · rcases Finset.mem_insert.mp hD with hEqD | hPD
      · subst D
        exact hPDisjointB C hPC
      · exact hPack C hPC D hPD hNe
  have hBound := hRank (insert B P) hAvailNew hPackNew
  have hCard : (insert B P).card = P.card + 1 :=
    Finset.card_insert_of_notMem hBnot
  omega

/-- A nonanticipating uniform witness simultaneously reduces the remaining
rank at every state in the same observation fiber. -/
theorem uniform_query_decreases_rank
    (read : State → Sensor → Answer) (f : State → Output)
    (x : State) (Q : Finset Sensor) (w r : ℕ)
    (hW : UniformRevealing read f x Q w)
    (hRank : ∀ y, AgreeOn read Q x y →
      RemainingRankBound read f y Q (r+1)) :
    ∃ B : Finset Sensor,
      B.Nonempty ∧ B.card ≤ w ∧ Disjoint B Q ∧
        ∀ y, AgreeOn read Q x y →
          RemainingRankBound read f y (Q ∪ B) r := by
  obtain ⟨B, hNonempty, hWidth, hFresh, hUniform⟩ := hW
  refine ⟨B, hNonempty, hWidth, hFresh, ?_⟩
  intro y hAgree
  exact remaining_rank_drop read f y Q B r
    (hUniform y hAgree) hNonempty hFresh (hRank y hAgree)

/-- If a valid revealing block exists whenever the target is unresolved,
rank zero implies that the observed sensors already determine the target. -/
theorem remaining_rank_zero_certifies
    (read : State → Sensor → Answer) (f : State → Output)
    (x : State) (Q : Finset Sensor) (w : ℕ)
    (hRank : RemainingRankBound read f x Q 0)
    (hWitness : ¬ CertificateAt read f x Q →
      UniformRevealing read f x Q w) :
    CertificateAt read f x Q := by
  classical
  by_contra hNotCertificate
  obtain ⟨B, hNonempty, _hWidth, hFresh, hUniform⟩ :=
    hWitness hNotCertificate
  have hB : SensitiveAt read f x B :=
    hUniform x (by intro i _; rfl)
  have hAvailable : ∀ C ∈ ({B} : Finset (Finset Sensor)),
      SensitiveAt read f x C ∧ Disjoint C Q := by
    intro C hC
    have hEq : C = B := Finset.mem_singleton.mp hC
    subst C
    exact ⟨hB, hFresh⟩
  have hPack : DisjointPacking ({B} : Finset (Finset Sensor)) := by
    intro C hC D hD hNe
    have hc : C = B := Finset.mem_singleton.mp hC
    have hd : D = B := Finset.mem_singleton.mp hD
    exact False.elim (hNe (hc.trans hd.symm))
  have hBound := hRank {B} hAvailable hPack
  simp at hBound

end Nightfall.Discoverability
