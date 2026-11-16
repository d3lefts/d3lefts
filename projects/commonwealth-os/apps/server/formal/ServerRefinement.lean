import Mathlib

/-!
Commonwealth OS — concrete server-command *reference abstraction*.

This is a separately typed, executable Lean model of the synthetic SQLite
server's critical item-phase and epoch guards. It is NOT a translation of the
JavaScript compiler, nor proof that its runtime/SQLite code implements 'step'.

All role/roster/quorum bits are inputs supplied by a trusted institutional
oracle. 'review' is a nonbinding DEMONSTRATION status, NOT an official effect.
-/

namespace Commonwealth.Server

inductive Phase where
  | draft | inReview | agendaSet | deliberating | motionLocked
  | ballotOpen | ballotClosed | reviewedDemo
  deriving DecidableEq, Repr

structure LockStamp where
  policyVersion : Nat
  eligibilityVersion : Nat
  documentRevision : Nat
  deriving DecidableEq, Repr

structure State where
  phase : Phase
  itemVersion : Nat
  revision : Nat
  policyVersion : Nat
  eligibilityVersion : Nat
  locked : Option LockStamp
  castBy : Finset String

/-- Single authoritative snapshot, as required before opening/casting/review. -/
def stamp (s : State) : LockStamp :=
  ⟨s.policyVersion, s.eligibilityVersion, s.revision⟩

def fresh (s : State) : Bool := decide (s.locked = some (stamp s))

/-- Role/eligibility/quorum flags are externally checked facts.
The two edits are trusted administrative actions affecting an institution
epoch; they do not modify the item's optimistic itemVersion. -/
inductive Command where
  | revise (actorAllowed : Bool)
  | submit (actorAllowed : Bool)
  | agenda (chair : Bool)
  | begin (chair : Bool)
  | attend (clerk : Bool)
  | lock (chair quorum : Bool)
  | open (chair : Bool)
  | cast (voter : String) (eligible present : Bool)
  | close (chair : Bool)
  | review (clerkIndependent quorum : Bool)
  | policyEdit
  | eligibilityEdit

/-- Increment the item version on a successful phase transition. -/
def advancePhase (s : State) (phase : Phase) : State :=
  let updated : State := {s with phase := phase}
  {updated with itemVersion := s.itemVersion + 1}

/-- The accepted mutation path corresponds to the in-scope server transitions.
Never infer that this reference implementation verifies the JS runtime. -/
def step (s : State) : Command → Option State
  | .revise allowed =>
      if (s.phase == .draft || s.phase == .inReview) && allowed then
        let updated : State := {s with revision := s.revision + 1}
        some {updated with itemVersion := s.itemVersion + 1}
      else none
  | .submit allowed =>
      if s.phase == .draft && allowed then
        some (advancePhase s .inReview)
      else none
  | .agenda chair =>
      if s.phase == .inReview && chair then
        some (advancePhase s .agendaSet)
      else none
  | .begin chair =>
      if s.phase == .agendaSet && chair then
        some (advancePhase s .deliberating)
      else none
  | .attend clerk =>
      if s.phase == .deliberating && clerk then
        some {s with itemVersion := s.itemVersion + 1}
      else none
  | .lock chair quorum =>
      if s.phase == .deliberating && chair && quorum then
        let updated := advancePhase s .motionLocked
        some {updated with locked := some (stamp s)}
      else none
  | .open chair =>
      if s.phase == .motionLocked && chair && fresh s then
        some (advancePhase s .ballotOpen)
      else none
  | .cast voter eligible present =>
      if s.phase == .ballotOpen && fresh s && eligible && present &&
          decide (voter ∉ s.castBy) then
        let updated : State := {s with castBy := insert voter s.castBy}
        some {updated with itemVersion := s.itemVersion + 1}
      else none
  | .close chair =>
      if s.phase == .ballotOpen && chair && fresh s then
        some (advancePhase s .ballotClosed)
      else none
  | .review clerkIndependent quorum =>
      if s.phase == .ballotClosed && clerkIndependent && quorum && fresh s then
        some (advancePhase s .reviewedDemo)
      else none
  | .policyEdit =>
      some {s with policyVersion := s.policyVersion + 1}
  | .eligibilityEdit =>
      some {s with eligibilityVersion := s.eligibilityVersion + 1}

theorem fresh_iff_locked_stamp (s : State) :
    fresh s = true ↔ s.locked = some (stamp s) := by
  simp [fresh]

/-- Every stale lock blocks all four sensitive legislative operations. -/
theorem stale_open_rejected (s : State) (chair : Bool)
    (h : fresh s = false) : step s (.open chair) = none := by
  simp [step, h]

theorem stale_cast_rejected (s : State) (voter : String)
    (eligible present : Bool) (h : fresh s = false) :
    step s (.cast voter eligible present) = none := by
  simp [step, h]

theorem stale_close_rejected (s : State) (chair : Bool)
    (h : fresh s = false) : step s (.close chair) = none := by
  simp [step, h]

theorem stale_review_rejected (s : State)
    (clerkIndependent quorum : Bool) (h : fresh s = false) :
    step s (.review clerkIndependent quorum) = none := by
  simp [step, h]

/-- Duplicate casts cannot produce another accepted transition. -/
theorem duplicate_cast_rejected (s : State) (voter : String)
    (eligible present : Bool) (hv : voter ∈ s.castBy) :
    step s (.cast voter eligible present) = none := by
  simp [step, hv]

/-- Changing a locked document is disallowed after locking. -/
theorem revision_after_lock_rejected (s : State) (allowed : Bool)
    (h : s.phase = .motionLocked) :
    step s (.revise allowed) = none := by
  simp [step, h]

/-- Successful CAST requires a current locked policy+electorate+revision. -/
theorem accepted_cast_is_fresh (s after : State) (voter : String)
    (eligible present : Bool)
    (h : step s (.cast voter eligible present) = some after) :
    fresh s = true := by
  cases hval : fresh s with
  | false => simp [step, hval] at h
  | true => simp [hval]

/-- The same legal/procedural version obligation applies to review. -/
theorem accepted_review_is_fresh (s after : State)
    (clerkIndependent quorum : Bool)
    (h : step s (.review clerkIndependent quorum) = some after) :
    fresh s = true := by
  cases hval : fresh s with
  | false => simp [step, hval] at h
  | true => simp [hval]

/-- A committed vote must have been new to that exact pre-state. -/
theorem accepted_cast_was_new (s after : State) (voter : String)
    (eligible present : Bool)
    (h : step s (.cast voter eligible present) = some after) :
    voter ∉ s.castBy := by
  by_contra hmem
  have hrejected := duplicate_cast_rejected s voter eligible present
    (by simpa using hmem)
  rw [hrejected] at h
  cases h

/-- The returned reviewed status alone is NOT present authority:
the calling operation has to recheck the current locked stamp. -/
def currentDemoReview (s : State) : Bool :=
  (s.phase == .reviewedDemo) && fresh s

theorem stale_demo_review_not_current (s : State)
    (h : fresh s = false) : currentDemoReview s = false := by
  simp [currentDemoReview, h]

end Commonwealth.Server
