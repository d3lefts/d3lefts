import Mathlib

/-!
# An adversary-independent invariant theorem for autonomous systems

This source proves a *conditional* all-horizon safety invariant for an
arbitrarily capable or adversarial action proposer. The prover does not
analyze the proposer. It verifies the behavior of an abstract trusted
boundary with complete mediation and a sound original-state model.

No physical tamper resistance, model accuracy, epoch authenticity, real
time atomicity, observer computability, or universal human safety is proved
by this mathematical theorem. The hypotheses are operational proof
obligations. This is an established invariant/shield mechanism, not a
historical originality claim.
-/

namespace Nightfall.AgentSafety

universe u v w z

variable {State : Type u} {Action : Type v}
variable {Observation : Type w} {Epoch : Type z}

/-- Physical transition system and explicitly identified trusted predicates.
The environment preservation field is an assumption about *all* uncontrolled
events, not a property inferred from the agent's proposed actions. -/
structure Boundary (State : Type u) (Action : Type v)
    (Observation : Type w) (Epoch : Type z) where
  safe : State → Prop
  plant : State → Action → State → Prop
  compatible : Epoch → Observation → State → Prop
  current : Epoch → State → Prop
  environment : State → State → Prop
  environment_preserves :
    ∀ s t, safe s → environment s t → safe t

/-- Strongest sound authorization rule using only the given observation
and epoch: EVERY modeled possible successor from EVERY compatible safe state
must remain safe. This definition need not be computable. -/
def Admissible (B : Boundary State Action Observation Epoch)
    (e : Epoch) (o : Observation) (a : Action) : Prop :=
  ∀ s t, B.compatible e o s → B.safe s →
    B.plant s a t → B.safe t

theorem admissible_sound
    (B : Boundary State Action Observation Epoch)
    (e : Epoch) (o : Observation) (a : Action)
    {s t : State}
    (hcompatible : B.compatible e o s)
    (hsafe : B.safe s)
    (hpermit : Admissible B e o a)
    (hplant : B.plant s a t) : B.safe t :=
  hpermit s t hcompatible hsafe hplant

/-- One modeled unsafe possible outcome forbids robust authorization. -/
theorem bad_successor_forbids_authorization
    (B : Boundary State Action Observation Epoch)
    (e : Epoch) (o : Observation) (a : Action)
    {s t : State}
    (hcompatible : B.compatible e o s)
    (hsafe : B.safe s)
    (hplant : B.plant s a t)
    (hbad : ¬ B.safe t) : ¬ Admissible B e o a := by
  intro hpermit
  exact hbad (admissible_sound B e o a hcompatible hsafe hpermit hplant)

/-- Every observation-only sound rule is a restriction of Admissible:
robust authorization is maximally permissive within the specified interface. -/
theorem admissible_maximal
    (B : Boundary State Action Observation Epoch)
    (Rule : Epoch → Observation → Action → Prop)
    (hsound : ∀ e o a s t, Rule e o a →
      B.compatible e o s → B.safe s →
      B.plant s a t → B.safe t)
    (e : Epoch) (o : Observation) (a : Action)
    (hrule : Rule e o a) : Admissible B e o a := by
  intro s t hcompatible hsafe hplant
  exact hsound e o a s t hrule hcompatible hsafe hplant

/-- The sole permitted kinds of physical steps. The current epoch,
actual-state/evidence consistency, actual effect relation, and approval
all have to be witnessed at the EFFECT boundary. Rejection stutters.
Environmental events are not covered by agent-specific authorization. -/
inductive MediatedStep (B : Boundary State Action Observation Epoch)
    (proposal : ℕ → Action) (n : ℕ) : State → State → Prop where
  | accepted {s t : State} (e : Epoch) (o : Observation)
      (hcurrent : B.current e s)
      (hcompatible : B.compatible e o s)
      (hpermit : Admissible B e o (proposal n))
      (heffect : B.plant s (proposal n) t) :
      MediatedStep B proposal n s t
  | rejected (s : State) : MediatedStep B proposal n s s
  | external {s t : State} (heffect : B.environment s t) :
      MediatedStep B proposal n s t

/-- The operational one-step proof obligation, for ANY action proposer. -/
theorem mediated_step_preserves
    (B : Boundary State Action Observation Epoch)
    (proposal : ℕ → Action) (n : ℕ)
    {s t : State}
    (hstep : MediatedStep B proposal n s t)
    (hsafe : B.safe s) : B.safe t := by
  cases hstep with
  | accepted e o hcurrent hcompatible hpermit heffect =>
      exact admissible_sound B e o (proposal n)
        hcompatible hsafe hpermit heffect
  | rejected =>
      exact hsafe
  | external heffect =>
      exact B.environment_preserves _ _ hsafe heffect

/-- Certified invariant for every finite time in EVERY admitted trace.
There are no honesty, rationality, bounded-computation, or strategy
assumptions on the arbitrarily chosen sequence of proposed actions. -/
theorem arbitrary_agent_all_horizons_safe
    (B : Boundary State Action Observation Epoch)
    (proposal : ℕ → Action) (trace : ℕ → State)
    (hinitial : B.safe (trace 0))
    (hmediation : ∀ n, MediatedStep B proposal n
      (trace n) (trace (n + 1))) :
    ∀ n, B.safe (trace n) := by
  intro n
  induction n with
  | zero =>
      exact hinitial
  | succ n ih =>
      exact mediated_step_preserves B proposal n (hmediation n) ih

/-- Any declared bad-state predicate excluded by the invariant is unreachable. -/
theorem no_declared_bad_state
    (B : Boundary State Action Observation Epoch)
    (proposal : ℕ → Action) (trace : ℕ → State)
    (Bad : State → Prop)
    (hspec : ∀ s, B.safe s → ¬ Bad s)
    (hinitial : B.safe (trace 0))
    (hmediation : ∀ n, MediatedStep B proposal n
      (trace n) (trace (n + 1))) :
    ∀ n, ¬ Bad (trace n) := by
  intro n
  exact hspec _ (arbitrary_agent_all_horizons_safe
    B proposal trace hinitial hmediation n)

end Nightfall.AgentSafety
