import JointPermissionPrice

/-!
# NIGHTFALL — checkpointed within-window authority change and correlation-aware disclosure

The authority can change during a verification window. At a trusted checkpoint,
spent prior worker slots cannot be recovered, and R is the complete set of
post-change fresh *independent* tasks. The authority epoch remains stable after
this checkpoint until final effect commit. Separately, a correlated-world
certificate theorem permits arbitrary correlation, source-support changes and
restricted disclosure. No physical sink, source authenticity, or live adversarial
online-game assumption is proved here.
-/

namespace Nightfall.PriceOfPermission.DynamicBridge

open Nightfall.PriceOfPermission.JointLowerBound

def remainingSlots (m H spent : ℕ) : ℕ := m * H - spent

def checkpointCost {R m H spent N guards : ℕ}
    (p : Plan R (remainingSlots m H spent) N guards)
    (c d sunk : ℕ) : ℕ :=
  sunk + evidenceCost p c d

def checkpointFloor (R m H spent c d sunk : ℕ) : ℕ :=
  sunk + evidenceFloor R (remainingSlots m H spent) c d

/-- Post-change information and capacity lower bound; cached work invalidated
by the authority change is never treated as a current certificate. -/
theorem checkpoint_lower {R m H spent N guards c d sunk : ℕ}
    (p : Plan R (remainingSlots m H spent) N guards)
    (hprice : 2 * c ≤ d) :
    checkpointFloor R m H spent c d sunk ≤ checkpointCost p c d sunk := by
  have hdeep := deep_tests_necessary p
  have hmul := Nat.mul_le_mul_left (d - 2 * c) hdeep
  have hcost := evidence_cost_decomposition p c d hprice
  dsimp [checkpointFloor, checkpointCost, evidenceFloor]
  rw [hcost]
  omega

/-- Matching construction for an authenticated checkpoint with a stable suffix. -/
theorem checkpoint_attainable (R m H spent N guards c d sunk : ℕ)
    (hcap : R ≤ remainingSlots m H spent) (hg : N ≤ guards)
    (hprice : 2 * c ≤ d) :
    ∃ p : Plan R (remainingSlots m H spent) N guards,
      checkpointCost p c d sunk = checkpointFloor R m H spent c d sunk := by
  let p := optimalPlan R (remainingSlots m H spent) N guards hcap hg
  refine ⟨p, ?_⟩
  have hcost := evidence_cost_decomposition p c d hprice
  dsimp [checkpointCost, checkpointFloor, evidenceFloor]
  rw [hcost]
  rw [optimalPlan_direct]

/-- Exact post-change lower/upper matching and collision-free suffix placement.
The trusted physical guard and accurate impact closure remain assumptions. -/
theorem checkpoint_matching_price
    (R m H spent N guards c d sunk : ℕ)
    (hcap : R ≤ remainingSlots m H spent) (hg : N ≤ guards)
    (hprice : 2 * c ≤ d) :
    (∀ p : Plan R (remainingSlots m H spent) N guards,
      checkpointFloor R m H spent c d sunk ≤ checkpointCost p c d sunk) ∧
    (∃ p : Plan R (remainingSlots m H spent) N guards,
      ∃ placement : Fin (2 * p.paired + p.direct) →
        Fin (remainingSlots m H spent),
        Function.Injective placement ∧
        checkpointCost p c d sunk = checkpointFloor R m H spent c d sunk) := by
  constructor
  · intro p
    exact checkpoint_lower p hprice
  · obtain ⟨p, hp⟩ :=
      checkpoint_attainable R m H spent N guards c d sunk hcap hg hprice
    exact ⟨p, operationPlacement p, operationPlacement_injective p, hp⟩

/-- A change can consume so many slots that full admission becomes impossible. -/
theorem checkpoint_shortage (R m H spent N guards : ℕ)
    (h : remainingSlots m H spent < R ∨ guards < N) :
    ¬ Nonempty (Plan R (remainingSlots m H spent) N guards) := by
  exact impossibility_of_shortage R (remainingSlots m H spent) N guards h

/-- Explicit additive prices for disclosing raw halves or only a predicate.
They are accounting fees, not differential-privacy guarantees. -/
def disclosureCost {R m H spent N guards : ℕ}
    (p : Plan R (remainingSlots m H spent) N guards)
    (c d rawFee predicateFee sunk : ℕ) : ℕ :=
  checkpointCost p (c + rawFee) (d + predicateFee) sunk

def disclosureFloor (R m H spent c d rawFee predicateFee sunk : ℕ) : ℕ :=
  checkpointFloor R m H spent (c + rawFee) (d + predicateFee) sunk

/-- Matching privacy-priced suffix optimum in the paired-cost regime. -/
theorem disclosure_matching_price
    (R m H spent N guards c d rawFee predicateFee sunk : ℕ)
    (hcap : R ≤ remainingSlots m H spent) (hg : N ≤ guards)
    (hprice : 2 * (c + rawFee) ≤ d + predicateFee) :
    (∀ p : Plan R (remainingSlots m H spent) N guards,
      disclosureFloor R m H spent c d rawFee predicateFee sunk ≤
        disclosureCost p c d rawFee predicateFee sunk) ∧
    (∃ p : Plan R (remainingSlots m H spent) N guards,
      disclosureCost p c d rawFee predicateFee sunk =
        disclosureFloor R m H spent c d rawFee predicateFee sunk) := by
  constructor
  · intro p
    exact checkpoint_lower p hprice
  · exact checkpoint_attainable R m H spent N guards
      (c + rawFee) (d + predicateFee) sunk hcap hg hprice

/-- Late invalidation incurs a genuine nonadditive evidence/deadline premium. -/
theorem delayed_invalidation_price_witness :
    checkpointFloor 2 2 2 0 1 5 0 = 4 ∧
    checkpointFloor 3 2 2 1 1 5 1 = 16 ∧
    checkpointFloor 3 2 2 1 1 5 1 - checkpointFloor 2 2 2 0 1 5 0 = 12 := by
  decide

/-! ## Correlation-aware finite-world and selective-disclosure calculus.
The independent-action counting price above does not apply to arbitrary
correlated worlds. This model instead accounts for possible-world fibers. -/

def SameTranscript {W S : Type*} (read : S → W → Bool)
    (chosen : Finset S) (w v : W) : Prop :=
  ∀ s ∈ chosen, read s w = read s v

def Certifies {W S : Type*} (possible safe : W → Prop)
    (read : S → W → Bool) (chosen : Finset S) (nominal : W) : Prop :=
  ∀ v, possible v → SameTranscript read chosen nominal v → safe v

/-- Exact correlated-support certificate iff every unsafe world differs on
at least one selected observation; no independence or prior is assumed. -/
theorem certifies_iff_hitting {W S : Type*}
    (possible safe : W → Prop) (read : S → W → Bool)
    (chosen : Finset S) (nominal : W) :
    Certifies possible safe read chosen nominal ↔
      ∀ v, possible v → ¬ safe v →
        ∃ s, s ∈ chosen ∧ read s nominal ≠ read s v := by
  classical
  constructor
  · intro hc v hv hnot
    by_contra hNone
    have same : SameTranscript read chosen nominal v := by
      intro s hs
      by_contra hdiff
      exact hNone ⟨s, hs, hdiff⟩
    exact hnot (hc v hv same)
  · intro h v hv same
    by_contra hnot
    obtain ⟨s, hs, hdiff⟩ := h v hv hnot
    exact hdiff (same s hs)

/-- A private plan can reuse separately authenticated truthful cached
observations; only newly selected disclosures must meet the allowlist. -/
def PrivatePlan {W S : Type*} [DecidableEq S]
    (possible safe : W → Prop) (read : S → W → Bool)
    (cached : Finset S) (allowed : S → Prop) (nominal : W)
    (remaining : ℕ) (fresh : Finset S) : Prop :=
  (∀ s ∈ fresh, allowed s) ∧
    Disjoint fresh cached ∧
    fresh.card ≤ remaining ∧
    Certifies possible safe read (cached ∪ fresh) nominal

theorem private_plan_hitting {W S : Type*} [DecidableEq S]
    (possible safe : W → Prop) (read : S → W → Bool)
    (cached : Finset S) (allowed : S → Prop) (nominal : W)
    (remaining : ℕ) (fresh : Finset S)
    (hp : PrivatePlan possible safe read cached allowed nominal remaining fresh) :
    ∀ v, possible v → ¬ safe v →
      ∃ s, s ∈ cached ∪ fresh ∧ read s nominal ≠ read s v := by
  exact (certifies_iff_hitting possible safe read (cached ∪ fresh) nominal).mp hp.2.2.2

/-- Privacy obstruction: if no allowed sensor can distinguish an unsafe
possible state from the nominal state, no zero-error private plan exists. -/
theorem privacy_obstruction {W S : Type*} [DecidableEq S]
    (possible safe : W → Prop) (read : S → W → Bool)
    (cached : Finset S) (allowed : S → Prop) (nominal bad : W)
    (hpossible : possible bad) (hunsafe : ¬ safe bad)
    (hcache : SameTranscript read cached nominal bad)
    (hallowed : ∀ s, allowed s → read s nominal = read s bad) :
    ∀ remaining fresh, ¬ PrivatePlan possible safe read cached allowed nominal remaining fresh := by
  intro remaining fresh hp
  have same : SameTranscript read (cached ∪ fresh) nominal bad := by
    intro s hs
    rcases Finset.mem_union.mp hs with hold | hnew
    · exact hcache s hold
    · exact hallowed s (hp.1 s hnew)
  exact hunsafe (hp.2.2.2 bad hpossible same)

/-- A best private verification bundle exists whenever at least one feasible
bundle exists. This is finite exhaustive optimization, not efficient POMDP. -/
theorem finite_private_optimum_exists {W S : Type*} [DecidableEq S]
    (possible safe : W → Prop) (read : S → W → Bool)
    (cached : Finset S) (allowed : S → Prop) (nominal : W)
    (remaining : ℕ) (cost : S → ℕ)
    (hfeasible : ∃ fresh : Finset S,
      PrivatePlan possible safe read cached allowed nominal remaining fresh) :
    ∃ best : Finset S,
      PrivatePlan possible safe read cached allowed nominal remaining best ∧
      ∀ other : Finset S,
        PrivatePlan possible safe read cached allowed nominal remaining other →
        best.sum cost ≤ other.sum cost := by
  classical
  let P : ℕ → Prop := fun n => ∃ fresh : Finset S,
    PrivatePlan possible safe read cached allowed nominal remaining fresh ∧
    fresh.sum cost = n
  have hP : ∃ n, P n := by
    obtain ⟨fresh, hfresh⟩ := hfeasible
    exact ⟨fresh.sum cost, fresh, hfresh, rfl⟩
  obtain ⟨best, hbest, heq⟩ := Nat.find_spec hP
  refine ⟨best, hbest, ?_⟩
  intro other hother
  calc
    best.sum cost = Nat.find hP := heq
    _ ≤ other.sum cost := Nat.find_min' hP ⟨other, hother, rfl⟩

def toySafe (w : Bool × Bool) : Prop := w.1 = w.2
def correlatedSupport (w : Bool × Bool) : Prop := w.1 = w.2
def broadSupport (_w : Bool × Bool) : Prop := True

/-- Only sensor 2 releases the action predicate. Raw values remain private. -/
def toyRead (s : Fin 3) (w : Bool × Bool) : Bool :=
  if s.val = 0 then w.1 else if s.val = 1 then w.2 else decide (w.1 = w.2)
def toyAllowed (s : Fin 3) : Prop := s.val = 2

/-- A source-support expansion invalidates an apparently sound zero-read
certificate; the authorized predicate-only check restores soundness. -/
theorem correlation_change_requires_recertification :
    Certifies correlatedSupport toySafe toyRead ∅ (false, false) ∧
    ¬ Certifies broadSupport toySafe toyRead ∅ (false, false) ∧
    Certifies broadSupport toySafe toyRead
      ({⟨2, by decide⟩} : Finset (Fin 3)) (false, false) := by
  constructor
  · intro v hv hsame
    exact hv
  constructor
  · intro h
    have hb := h (true, false) trivial (by simp [SameTranscript])
    exact (by decide : ¬ toySafe (true, false)) hb
  · intro v hv hsame
    have hf := hsame ⟨2, by decide⟩ (by simp)
    simpa [toyRead, toySafe] using hf

theorem predicate_only_allowed :
    ∀ s ∈ ({⟨2, by decide⟩} : Finset (Fin 3)), toyAllowed s := by
  intro s hs
  have heq : s = (⟨2, by decide⟩ : Fin 3) := Finset.mem_singleton.mp hs
  subst s
  decide

theorem toy_private_recertification :
    PrivatePlan broadSupport toySafe toyRead ∅ toyAllowed
      (false, false) 1 ({⟨2, by decide⟩} : Finset (Fin 3)) := by
  refine ⟨predicate_only_allowed, ?_, ?_, ?_⟩
  · simp
  · decide
  · intro v hv hsame
    have hf := hsame ⟨2, by decide⟩ (by simp)
    simpa [toyRead, toySafe] using hf

theorem toy_privacy_requires_slot :
    ¬ PrivatePlan broadSupport toySafe toyRead ∅ toyAllowed
      (false, false) 0 ∅ := by
  intro hp
  have hb := hp.2.2.2 (true, false) trivial (by simp [SameTranscript])
  exact (by decide : ¬ toySafe (true, false)) hb

/-- Decision-class noninterference: the predicate-only output carries no
additional information distinguishing private worlds with the same decision. -/
theorem predicate_only_noninterference (w v : Bool × Bool)
    (h : toySafe w ↔ toySafe v) :
    toyRead ⟨2, by decide⟩ w = toyRead ⟨2, by decide⟩ v := by
  by_cases hw : w.1 = w.2
  · have hv : v.1 = v.2 := h.mp hw
    simp [toyRead, hw, hv]
  · have hv : ¬ v.1 = v.2 := fun hv => hw (h.mpr hv)
    simp [toyRead, hw, hv]

end Nightfall.PriceOfPermission.DynamicBridge
