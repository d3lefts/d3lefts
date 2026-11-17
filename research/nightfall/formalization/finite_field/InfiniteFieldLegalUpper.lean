import Mathlib
import InfiniteFieldSignedStep
import InfiniteFieldAdaptiveLower

/-!
# Causal implementation of the adaptive phase-retrieval upper bound

The first n rows ask for coordinate squares. The final row is chosen
solely from the preceding n observations; no hidden signal is passed to
the strategy. This file links the original adaptiveTranscript with the
very same List-history oracle used by AdaptiveLower.
-/

namespace Nightfall.InfiniteFieldPhase.LegalUpper
open scoped BigOperators
noncomputable section
variable {K : Type*} [Field K] [Infinite K] [NeZero (2 : K)]
variable {n : ℕ}

/-- The coordinate queried is determined by the number of past readings. -/
def coordinatePolicy (past : List K) : Fin n → K :=
  fun i => if i.val = past.length then 1 else 0

def coordinateHistory (x : Fin n → K) (m : ℕ) : List K :=
  AdaptiveLower.history (coordinatePolicy (n := n)) x m

theorem history_length (policy : List K → Fin n → K)
    (x : Fin n → K) (m : ℕ) :
    (AdaptiveLower.history policy x m).length = m := by
  induction m with
  | zero => rfl
  | succ m ih =>
      simp [AdaptiveLower.history, ih]

theorem dot_coordinatePolicy (past : List K) (x : Fin n → K)
    (m : ℕ) (hm : m < n) (hl : past.length = m) :
    AdaptiveLower.dot (coordinatePolicy past) x = x ⟨m, hm⟩ := by
  classical
  have heq (i : Fin n) :
      (i.val = past.length) ↔ i = (⟨m, hm⟩ : Fin n) := by
    simp [hl, Fin.ext_iff]
  unfold AdaptiveLower.dot coordinatePolicy
  simp only [heq]
  simp [mul_ite]

theorem coordinate_step (x : Fin n → K) (m : ℕ) (hm : m < n) :
    coordinateHistory x (m+1) =
      (x ⟨m, hm⟩)^2 :: coordinateHistory x m := by
  change
    (AdaptiveLower.dot
      (coordinatePolicy (coordinateHistory x m)) x)^2 ::
      coordinateHistory x m =
    (x ⟨m, hm⟩)^2 :: coordinateHistory x m
  rw [dot_coordinatePolicy (n := n)
    (coordinateHistory x m) x m hm (history_length _ x m)]

/-- Equal coordinate-observation prefixes determine the squared coordinates. -/
theorem coordinate_history_squares_eq :
    ∀ (m : ℕ), m ≤ n → ∀ (x y : Fin n → K),
      coordinateHistory x m = coordinateHistory y m →
      ∀ i : Fin n, i.val < m → (x i)^2 = (y i)^2 := by
  intro m
  induction m with
  | zero =>
      intro _ x y h i hi
      omega
  | succ m ih =>
      intro hm x y h i hi
      have hsmall : m < n := by omega
      rw [coordinate_step x m hsmall, coordinate_step y m hsmall] at h
      have hhead : (x ⟨m,hsmall⟩)^2 = (y ⟨m,hsmall⟩)^2 :=
        (List.cons.inj h).1
      have htail : coordinateHistory x m = coordinateHistory y m :=
        (List.cons.inj h).2
      by_cases him : i.val = m
      · have hid : i = (⟨m,hsmall⟩ : Fin n) := Fin.ext him
        rw [hid]
        exact hhead
      · exact ih (by omega) x y htail i (by omega)

/-- Decode the previous n readings, using arbitrary defaults off the
reachable histories. All reachable histories have a unique squared-data
vector even when the underlying signed signal is not unique. -/
noncomputable def historyData (past : List K) : Fin n → K := by
  classical
  exact if h : ∃ x : Fin n → K, coordinateHistory x n = past then
    (fun i => ((Classical.choose h) i)^2) else 0

theorem historyData_correct (x : Fin n → K) :
    historyData (coordinateHistory x n) = (fun i => (x i)^2) := by
  classical
  unfold historyData
  split_ifs with hh
  · funext i
    exact coordinate_history_squares_eq n (le_refl n)
      (Classical.choose hh) x (Classical.choose_spec hh) i i.isLt
  · exact False.elim (hh ⟨x, rfl⟩)

/-- A single legal strategy, taking only previous oracle values as input. -/
noncomputable def legalPolicy (past : List K) : Fin n → K := by
  classical
  exact if past.length < n then coordinatePolicy past
    else observedSquareRow (historyData past)

theorem legal_history_prefix :
    ∀ (m : ℕ), m ≤ n → ∀ x : Fin n → K,
      AdaptiveLower.history legalPolicy x m = coordinateHistory x m := by
  intro m
  induction m with
  | zero =>
      intro _ x
      rfl
  | succ m ih =>
      intro hm x
      have hm' : m < n := by omega
      have hprev := ih (by omega) x
      change
        (AdaptiveLower.dot
          (legalPolicy (AdaptiveLower.history legalPolicy x m)) x)^2 ::
          AdaptiveLower.history legalPolicy x m =
        (AdaptiveLower.dot
          (coordinatePolicy (coordinateHistory x m)) x)^2 ::
          coordinateHistory x m
      rw [hprev]
      have hrow : legalPolicy (coordinateHistory x m) =
          coordinatePolicy (coordinateHistory x m) := by
        unfold legalPolicy
        rw [if_pos (by
          have hl : (coordinateHistory x m).length = m := history_length _ x m
          omega)]
      rw [hrow]

theorem legal_final_row (x : Fin n → K) :
    legalPolicy (AdaptiveLower.history legalPolicy x n) =
      observedSquareRow (fun i => (x i)^2) := by
  rw [legal_history_prefix n (le_refl n) x]
  unfold legalPolicy
  have hl : (coordinateHistory x n).length = n := history_length _ x n
  rw [if_neg (by omega)]
  exact congrArg observedSquareRow (historyData_correct x)

/-- The (n+1)-query history of this legal policy exactly realizes the
previously proved adaptiveTranscript, with its n coordinate values stored
in the first component and the final reading in the second. -/
theorem legal_history_as_transcript (x : Fin n → K) :
    AdaptiveLower.history legalPolicy x (n+1) =
      (adaptiveTranscript x).2 :: coordinateHistory x n := by
  change
    (AdaptiveLower.dot
      (legalPolicy (AdaptiveLower.history legalPolicy x n)) x)^2 ::
      AdaptiveLower.history legalPolicy x n =
      (adaptiveTranscript x).2 :: coordinateHistory x n
  rw [legal_history_prefix n (le_refl n) x, ← legal_history_prefix n (le_refl n) x]
  rw [legal_final_row x]
  rfl

/-- Full upper-bound certificate in the identical causal List-history
squared-linear oracle used by the adaptive lower bound. -/
theorem legal_history_injective_mod_sign (x y : Fin n → K)
    (h : AdaptiveLower.history legalPolicy x (n+1) =
         AdaptiveLower.history legalPolicy y (n+1)) :
    x = y ∨ x = -y := by
  rw [legal_history_as_transcript x, legal_history_as_transcript y] at h
  have hlast : (adaptiveTranscript x).2 = (adaptiveTranscript y).2 :=
    (List.cons.inj h).1
  have hprefix : coordinateHistory x n = coordinateHistory y n :=
    (List.cons.inj h).2
  have hdata : (fun i : Fin n => (x i)^2) = (fun i => (y i)^2) := by
    funext i
    exact coordinate_history_squares_eq n (le_refl n) x y hprefix i i.isLt
  have htrans : adaptiveTranscript x = adaptiveTranscript y := by
    apply Prod.ext
    · exact hdata
    · exact hlast
  exact adaptiveTranscript_injective_mod_sign x y htrans

#print axioms Nightfall.InfiniteFieldPhase.LegalUpper.legal_history_injective_mod_sign

end
end Nightfall.InfiniteFieldPhase.LegalUpper
