import Mathlib

/-!
# Commonwealth OS: conditionally sound Democratic Assurance Passports

These proofs are about the **declared finite/abstract possible-world model**,
not about the truth of laws, authenticated ballots, coercion, elections,
or the completeness of deployed effect mediation.

They strengthen the separately audited DAP P1–P4 mathematical kernel.
Source and hypotheses must accompany every receipt.
-/

namespace Commonwealth.Assurance

section Evidence

variable {World Query Output : Type*}

/-- Query agreement between the current world and one nominal transcript. -/
def Agreement (read : Query → World → Output) (selected : Finset Query)
    (nominal current : World) : Prop :=
  ∀ q ∈ selected, read q current = read q nominal

/-- All currently admissible unauthorized worlds differ on some selected query. -/
def Covered (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World) : Prop :=
  ∀ w, possible w → ¬ authorized w →
    ∃ q ∈ selected, read q w ≠ read q nominal

/-- No unauthorized possible world can match the selected transcript. -/
def TranscriptSound (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World) : Prop :=
  ∀ w, possible w → Agreement read selected nominal w → authorized w

/-- P1. Exact soundness/cover equivalence, for arbitrary observation functions. -/
theorem transcript_sound_iff_cover
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World) :
    TranscriptSound possible authorized read selected nominal ↔
      Covered possible authorized read selected nominal := by
  classical
  constructor
  · intro hs w hw hbad
    by_contra hnone
    have hAgree : Agreement read selected nominal w := by
      intro q hq
      by_contra hneq
      exact hnone ⟨q, hq, hneq⟩
    exact hbad (hs w hw hAgree)
  · intro hcover w hw hAgree
    by_contra hbad
    obtain ⟨q, hq, hneq⟩ := hcover w hw hbad
    exact hneq (hAgree q hq)

/-- The actual world must be in the modeled possibility set. -/
theorem transcript_sound_actual
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal actual : World)
    (hs : TranscriptSound possible authorized read selected nominal)
    (hworld : possible actual)
    (hobs : Agreement read selected nominal actual) : authorized actual :=
  hs actual hworld hobs

/-- Non-vacuous certificates explicitly reject an empty consistent class. -/
def ValidEvidence (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World) : Prop :=
  (∃ w, possible w ∧ Agreement read selected nominal w) ∧
    TranscriptSound possible authorized read selected nominal

theorem empty_evidence_rejected
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World)
    (hempty : ¬ ∃ w, possible w ∧ Agreement read selected nominal w) :
    ¬ ValidEvidence possible authorized read selected nominal := by
  intro hc
  exact hempty hc.1

/-- The soundness conclusion of a non-vacuous certificate. -/
theorem valid_evidence_actual
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal actual : World)
    (hc : ValidEvidence possible authorized read selected nominal)
    (hworld : possible actual)
    (hobs : Agreement read selected nominal actual) : authorized actual :=
  hc.2 actual hworld hobs

end Evidence

section Composition

variable {World Index : Type*}

/-- P2. Each independent obligation must be interpreted over the SAME world. -/
theorem same_world_composition
    (possible : World → Prop)
    (claims : Index → World → Prop) (indices : Finset Index) :
    (∀ w, possible w → ∀ i ∈ indices, claims i w) ↔
    (∀ i ∈ indices, ∀ w, possible w → claims i w) := by
  constructor
  · intro h i hi w hw
    exact h w hw i hi
  · intro h w hw i hi
    exact h i hi w hw

/-- A passport with all claims over one common world cannot silently mix epochs. -/
theorem joint_claims_actual
    (possible : World → Prop)
    (claims : Index → World → Prop) (indices : Finset Index)
    (actual : World)
    (hworld : possible actual)
    (hcomponents : ∀ i ∈ indices, ∀ w, possible w → claims i w) :
    ∀ i ∈ indices, claims i actual := by
  intro i hi
  exact hcomponents i hi actual hworld

end Composition

section Enforcement

variable {Passport Snapshot Effect EffectId : Type*}

/-- A committed event records the evidence and the snapshot at its commit point. -/
structure Event (Passport Snapshot Effect : Type*) where
  passport : Passport
  snapshot : Snapshot
  effect : Effect

/-- Sequential ledger abstraction; it is NOT itself a distributed transaction. -/
structure Ledger (Passport Snapshot Effect : Type*) where
  entries : List (Event Passport Snapshot Effect)

/-- Every event was permitted at its own commit point and IDs are unique. -/
def Safe (permit : Passport → Snapshot → Effect → Prop)
    (identity : Effect → EffectId)
    (ledger : Ledger Passport Snapshot Effect) : Prop :=
  (∀ ev ∈ ledger.entries, permit ev.passport ev.snapshot ev.effect) ∧
    (ledger.entries.map (fun ev => identity ev.effect)).Nodup

/-- An empty ledger is safe. -/
theorem empty_safe
    (permit : Passport → Snapshot → Effect → Prop)
    (identity : Effect → EffectId) :
    Safe permit identity (⟨[]⟩ : Ledger Passport Snapshot Effect) := by
  simp [Safe]

/-- P3 local step: atomic permission and fresh-ID checks preserve both invariants. -/
theorem accept_preserves_safe
    (permit : Passport → Snapshot → Effect → Prop)
    (identity : Effect → EffectId)
    (ledger : Ledger Passport Snapshot Effect)
    (event : Event Passport Snapshot Effect)
    (hsafe : Safe permit identity ledger)
    (hpermit : permit event.passport event.snapshot event.effect)
    (hunused : ∀ prior ∈ ledger.entries,
      identity prior.effect ≠ identity event.effect) :
    Safe permit identity (⟨event :: ledger.entries⟩ : Ledger Passport Snapshot Effect) := by
  constructor
  · intro ev hev
    simp only [List.mem_cons] at hev
    rcases hev with rfl | hmem
    · exact hpermit
    · exact hsafe.1 ev hmem
  · have hnew : identity event.effect ∉
        ledger.entries.map (fun e => identity e.effect) := by
      intro hmem
      obtain ⟨prior, hprior, hsame⟩ := List.mem_map.mp hmem
      exact (hunused prior hprior) hsame
    exact List.nodup_cons.mpr ⟨hnew, hsafe.2⟩

/-- An abstract sink transition, including rejection or atomic acceptance. -/
def SinkStep (permit : Passport → Snapshot → Effect → Prop)
    (identity : Effect → EffectId)
    (before after : Ledger Passport Snapshot Effect) : Prop :=
  after = before ∨
    ∃ event : Event Passport Snapshot Effect,
      permit event.passport event.snapshot event.effect ∧
      (∀ prior ∈ before.entries,
        identity prior.effect ≠ identity event.effect) ∧
      after = ⟨event :: before.entries⟩

theorem sink_step_preserves_safe
    (permit : Passport → Snapshot → Effect → Prop)
    (identity : Effect → EffectId)
    {before after : Ledger Passport Snapshot Effect}
    (hsafe : Safe permit identity before)
    (hstep : SinkStep permit identity before after) :
    Safe permit identity after := by
  rcases hstep with hreject | ⟨event, hpermit, hunused, haccept⟩
  · rw [hreject]
    exact hsafe
  · rw [haccept]
    exact accept_preserves_safe permit identity before event hsafe hpermit hunused

/-- Explicit reflexive/transitive closure of a transition relation. -/
inductive Reachable {State : Type*} (step : State → State → Prop)
    (initial : State) : State → Prop where
  | start : Reachable step initial initial
  | next {current following} :
      Reachable step initial current →
      step current following →
      Reachable step initial following

/-- P3 end-to-end *within the atomic sink abstraction*: every reachable
recorded event is authorized at its historical commit point, with no replay. -/
theorem reachable_sink_safe
    (permit : Passport → Snapshot → Effect → Prop)
    (identity : Effect → EffectId)
    {initial final : Ledger Passport Snapshot Effect}
    (hinitial : Safe permit identity initial)
    (hreach : Reachable (SinkStep permit identity) initial final) :
    Safe permit identity final := by
  induction hreach with
  | start =>
      exact hinitial
  | next _ hstep ih =>
      exact sink_step_preserves_safe permit identity ih hstep

end Enforcement

section Temporal

variable {World Observation : Type*}

/-- P4. No stale-observation decision can distinguish two worlds
with opposite required actions and identical observable history. -/
theorem indistinguishable_authority_impossibility
    (read : World → Observation)
    (decision : Observation → Bool)
    (authorized revoked : World)
    (hobservations : read authorized = read revoked)
    (hallow : decision (read authorized) = true)
    (hdeny : decision (read revoked) = false) : False := by
  rw [hobservations] at hallow
  simp [hallow] at hdeny

/-- Conservative change transfer: retained authorization is sound only if
new worlds refine the old class AND the relevant rule retains its meaning. -/
theorem recertification_transfer
    (oldPossible newPossible oldAuthorized newAuthorized : World → Prop)
    (hworlds : ∀ w, newPossible w → oldPossible w)
    (hsemantics : ∀ w, newPossible w →
      (oldAuthorized w ↔ newAuthorized w))
    (hold : ∀ w, oldPossible w → oldAuthorized w) :
    ∀ w, newPossible w → newAuthorized w := by
  intro w hnew
  exact (hsemantics w hnew).mp (hold w (hworlds w hnew))

end Temporal


section ExactCost

variable {World Query Output : Type*}

/-- There is a least-cost sound nominal certificate among all available finite
query panels whenever at least one sound panel exists. Cost is a Nat sum, and
the exact feasibility condition is the earlier hitting-set equivalence.
This proves mathematical optimality, not the complexity of computing it. -/
theorem exists_least_cost_sound_panel
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (nominal : World) (cost : Query → Nat)
    (hexists : ∃ selected : Finset Query,
      TranscriptSound possible authorized read selected nominal) :
    ∃ selected : Finset Query,
      TranscriptSound possible authorized read selected nominal ∧
      ∀ alternative : Finset Query,
        TranscriptSound possible authorized read alternative nominal →
        selected.sum cost ≤ alternative.sum cost := by
  classical
  let pricePossible : Nat → Prop := fun n =>
    ∃ s : Finset Query,
      TranscriptSound possible authorized read s nominal ∧ s.sum cost = n
  obtain ⟨s₀, hs₀⟩ := hexists
  have hsome : ∃ n, pricePossible n := ⟨s₀.sum cost, s₀, hs₀, rfl⟩
  obtain ⟨best, hbest, hprice⟩ := Nat.find_spec hsome
  refine ⟨best, hbest, ?_⟩
  intro alternative hgood
  have hminimum : Nat.find hsome ≤ alternative.sum cost :=
    Nat.find_min' hsome ⟨alternative, hgood, rfl⟩
  rw [hprice]
  exact hminimum

end ExactCost

section EndToEnd

variable {World Query Output Effect EffectId : Type*}

/-- Operational contract for a complete proof-passport gate: the passport
evidence is nonempty and robust, and its true commit-time snapshot belongs
to the same possible-world class and agrees with the certified observations.
The two latter facts are EXTERNAL assumptions of the installed guard. -/
def EvidencePermit
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World)
    (_passport : Unit) (snapshot : World) (_effect : Effect) : Prop :=
  ValidEvidence possible authorized read selected nominal ∧
    possible snapshot ∧ Agreement read selected nominal snapshot

/-- Direct bridge between certified evidence and historical permission events.
This theorem proves actual-world authorization for all recorded effects IF the
guarded ledger really contains all in-scope effects and all snapshots are true. -/
theorem ledger_evidence_implies_authority
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World)
    (identity : Effect → EffectId)
    (ledger : Ledger Unit World Effect)
    (hsafe : Safe (EvidencePermit possible authorized read selected nominal)
      identity ledger) :
    ∀ ev ∈ ledger.entries, authorized ev.snapshot := by
  intro ev hev
  obtain ⟨hc, hworld, hobs⟩ := hsafe.1 ev hev
  exact valid_evidence_actual possible authorized read selected nominal
    ev.snapshot hc hworld hobs

/-- End-to-end theorem inside the DECLARED abstract model:
sound evidence + atomic completely mediated sink steps imply every logged
effect's actual snapshot satisfies the legal authorization predicate.
No claim that a real implementation refines SinkStep is made here. -/
theorem reachable_evidence_guard_authority
    (possible authorized : World → Prop)
    (read : Query → World → Output)
    (selected : Finset Query) (nominal : World)
    (identity : Effect → EffectId)
    {initial final : Ledger Unit World Effect}
    (hinitial : Safe (EvidencePermit possible authorized read selected nominal)
      identity initial)
    (hreach : Reachable
      (SinkStep (EvidencePermit possible authorized read selected nominal) identity)
      initial final) :
    (∀ ev ∈ final.entries, authorized ev.snapshot) ∧
      (final.entries.map (fun ev => identity ev.effect)).Nodup := by
  have hsafe := reachable_sink_safe
    (EvidencePermit possible authorized read selected nominal)
    identity hinitial hreach
  exact ⟨ledger_evidence_implies_authority
    possible authorized read selected nominal identity final hsafe, hsafe.2⟩

end EndToEnd

end Commonwealth.Assurance
