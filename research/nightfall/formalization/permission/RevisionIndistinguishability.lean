import Mathlib

/-!
NIGHTFALL: source-changing authority cannot be both zero-error sound and
universally available if two possible worlds remain observationally identical.

This is a *fully abstract* indistinguishability impossibility certificate:
no assumptions about probabilities, topology, cost, field, or agent intelligence.
It does not establish which real sources are authenticated, whether monitoring
is complete, or the actual effect sink intercepts all actions.

Applied research instance and dual source changes:
research/nightfall/2026-11-crossfrontier/PERMISSION_NEXT_FRONTIER.md
-/

namespace Nightfall.PriceOfPermission.RevisionImpossibility

theorem indistinguishable_revision_forces_deny
    {World Transcript : Type*}
    (obs : World → Transcript) (safe : World → Prop)
    (nominal bad : World)
    (same : obs nominal = obs bad)
    (unsafe_world : ¬ safe bad)
    (permit : Transcript → Bool)
    (sound : ∀ w, permit (obs w) = true → safe w) :
    permit (obs nominal) = false := by
  cases h : permit (obs nominal) with
  | false => exact h
  | true =>
    have badpermit : permit (obs bad) = true := by
      rw [← same]
      exact h
    exact False.elim (unsafe_world (sound bad badpermit))

theorem no_zero_error_sound_and_nominal_live
    {World Transcript : Type*}
    (obs : World → Transcript) (safe : World → Prop)
    (nominal bad : World)
    (same : obs nominal = obs bad)
    (unsafe_world : ¬ safe bad) :
    ¬ ∃ permit : Transcript → Bool,
        (∀ w, permit (obs w) = true → safe w) ∧
        permit (obs nominal) = true := by
  rintro ⟨permit, sound, live⟩
  have denied :=
    indistinguishable_revision_forces_deny obs safe nominal bad
      same unsafe_world permit sound
  rw [live] at denied
  cases denied

-- An explicit two-revision counterexample on a new Boolean safety dimension.
-- Initial observation x=0 is still true in both worlds after a source change;
-- the new unsafe world differs only in the unobserved y.
def observation (w : Bool × Bool) : Bool := w.1
def missionSafe (w : Bool × Bool) : Prop := w.1 = w.2

theorem stale_first_coordinate_no_live_sound_guard
    (permit : Bool → Bool)
    (sound : ∀ w : Bool × Bool,
       permit (observation w) = true → missionSafe w) :
    permit (observation (false, false)) = false := by
  exact indistinguishable_revision_forces_deny observation missionSafe
    (false, false) (false, true) (by rfl) (by decide) permit sound

#print axioms Nightfall.PriceOfPermission.RevisionImpossibility.indistinguishable_revision_forces_deny
#print axioms Nightfall.PriceOfPermission.RevisionImpossibility.no_zero_error_sound_and_nominal_live
#print axioms Nightfall.PriceOfPermission.RevisionImpossibility.stale_first_coordinate_no_live_sound_guard

end Nightfall.PriceOfPermission.RevisionImpossibility
