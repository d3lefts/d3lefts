import Mathlib

/-!
# NIGHTFALL finite-horizon source-bound lifecycle assurance

Finite belief states, adversarial observations, authenticated certificates,
effect-time version binding, mission completion, four separate cost phases.
The forward refinement from actual effects to model beliefs is an explicit
premise. No claim about physical implementation, infinite horizon, or
the novelty of the well-ordering argument is made here.
-/

namespace Nightfall.LifecycleAuthority

universe u v w z

structure Model (Belief : Type u) (Action : Type v)
    (Observation : Type w) where
  safe : Belief → Prop
  goal : Belief → Prop
  authenticated : Belief → Action → Prop
  isEffect : Action → Prop
  sourceEpoch : Belief → ℕ
  certificateEpoch : Belief → ℕ
  possible : Belief → Action → Observation → Prop
  post : Belief → Action → Observation → Belief
  acquireCost : Belief → Action → ℕ
  verifyCost : Belief → Action → ℕ
  repairCost : Belief → Action → ℕ
  enforceCost : Belief → Action → ℕ

variable {Belief : Type u} {Action : Type v} {Observation : Type w}

def Admitted (M : Model Belief Action Observation)
    (b : Belief) (a : Action) : Prop :=
  M.authenticated b a ∧
  (M.isEffect a → M.sourceEpoch b = M.certificateEpoch b) ∧
  (∀ o, M.possible b a o → M.safe (M.post b a o))

def PhaseCost (M : Model Belief Action Observation)
    (b : Belief) (a : Action) : ℕ :=
  M.acquireCost b a + M.verifyCost b a +
    M.repairCost b a + M.enforceCost b a

/-- Finite mission plans branch on the full observed outcome history. -/
inductive Policy (Action : Type v) (Observation : Type w) : ℕ → Type (max v w) where
  | finish {n : ℕ} : Policy Action Observation n
  | execute {n : ℕ} (a : Action)
      (next : Observation → Policy Action Observation n) :
      Policy Action Observation (n + 1)

def Valid (M : Model Belief Action Observation) :
    {n : ℕ} → Belief → Policy Action Observation n → Prop
  | _, b, .finish => M.safe b ∧ M.goal b
  | _, b, .execute a k =>
      M.safe b ∧ Admitted M b a ∧
      (∃ o, M.possible b a o) ∧
      (∀ o, M.possible b a o →
        Valid M (M.post b a o) (k o))

def WorstCost [Fintype Observation]
    (M : Model Belief Action Observation) :
    {n : ℕ} → Belief → Policy Action Observation n → ℕ
  | _, _, .finish => 0
  | _, b, .execute a k => by
      classical
      exact PhaseCost M b a +
        Finset.univ.sup (fun o : Observation =>
          if M.possible b a o
          then WorstCost M (M.post b a o) (k o)
          else 0)

theorem admitted_effect_current
    (M : Model Belief Action Observation) {b : Belief} {a : Action}
    (ha : Admitted M b a) (he : M.isEffect a) :
    M.sourceEpoch b = M.certificateEpoch b :=
  ha.2.1 he

theorem admitted_successor_safe
    (M : Model Belief Action Observation)
    {b : Belief} {a : Action} {o : Observation}
    (ha : Admitted M b a) (ho : M.possible b a o) :
    M.safe (M.post b a o) :=
  ha.2.2 o ho

theorem valid_state_safe
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief}
    {p : Policy Action Observation n}
    (hp : Valid M b p) : M.safe b := by
  cases p with
  | finish => exact hp.1
  | execute a k => exact hp.1

theorem valid_successor
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief} {a : Action}
    {k : Observation → Policy Action Observation n}
    (hp : Valid M b (.execute a k)) {o : Observation}
    (ho : M.possible b a o) :
    Valid M (M.post b a o) (k o) :=
  hp.2.2.2 o ho

theorem valid_step_safe
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief} {a : Action}
    {k : Observation → Policy Action Observation n}
    (hp : Valid M b (.execute a k))
    {o : Observation} (ho : M.possible b a o) :
    M.safe (M.post b a o) :=
  admitted_successor_safe M hp.2.1 ho

structure OperationalRefinement
    (M : Model Belief Action Observation) (Actual : Type z) where
  abstract : Actual → Belief
  actualStep : Actual → Action → Observation → Actual → Prop
  modelsEveryStep :
    ∀ x a o y, actualStep x a o y →
      M.possible (abstract x) a o ∧
        abstract y = M.post (abstract x) a o

theorem operational_step_safe
    (M : Model Belief Action Observation)
    {Actual : Type z} (R : OperationalRefinement M Actual)
    {n : ℕ} {x y : Actual} {a : Action} {o : Observation}
    {k : Observation → Policy Action Observation n}
    (hp : Valid M (R.abstract x) (.execute a k))
    (hstep : R.actualStep x a o y) :
    M.safe (R.abstract y) ∧
      Valid M (R.abstract y) (k o) := by
  obtain ⟨ho, heq⟩ := R.modelsEveryStep x a o y hstep
  rw [heq]
  exact ⟨valid_step_safe M hp ho, valid_successor M hp ho⟩

theorem operational_effect_has_fresh_certificate
    (M : Model Belief Action Observation)
    {Actual : Type z} (R : OperationalRefinement M Actual)
    {n : ℕ} {x y : Actual} {a : Action} {o : Observation}
    {k : Observation → Policy Action Observation n}
    (hp : Valid M (R.abstract x) (.execute a k))
    (_hstep : R.actualStep x a o y)
    (he : M.isEffect a) :
    M.sourceEpoch (R.abstract x) =
      M.certificateEpoch (R.abstract x) :=
  admitted_effect_current M hp.2.1 he

def Feasible (M : Model Belief Action Observation)
    (n : ℕ) (b : Belief) : Prop :=
  ∃ p : Policy Action Observation n, Valid M b p

private theorem feasible_cost_nonempty
    [Fintype Observation]
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief} (h : Feasible M n b) :
    ∃ c : ℕ, ∃ p : Policy Action Observation n,
      Valid M b p ∧ WorstCost M b p = c := by
  obtain ⟨p, hp⟩ := h
  exact ⟨WorstCost M b p, p, hp, rfl⟩

/-- Exact matching upper and lower bound over all history-dependent
finite-horizon policies, with observation, verification, repair and
enforcement costs. The result is conditional on the model and feasibility,
not a certificate that physical operations satisfy the model. -/
theorem globally_optimal_lifecycle_policy_exists
    [Fintype Observation]
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief} (h : Feasible M n b) :
    ∃ p : Policy Action Observation n,
      Valid M b p ∧
      ∀ q : Policy Action Observation n,
        Valid M b q → WorstCost M b p ≤ WorstCost M b q := by
  classical
  let property (c : ℕ) : Prop :=
    ∃ p : Policy Action Observation n, Valid M b p ∧ WorstCost M b p = c
  have hex : ∃ c, property c := feasible_cost_nonempty M h
  obtain ⟨p, hp, hcost⟩ := Nat.find_spec hex
  refine ⟨p, hp, ?_⟩
  intro q hq
  by_contra hnot
  have hlt : WorstCost M b q < Nat.find hex := Nat.lt_of_not_ge hnot
  exact (Nat.find_min' hex hlt) ⟨q, hq, rfl⟩

theorem min_cost_attained
    [Fintype Observation]
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief} (h : Feasible M n b) :
    ∃ (c : ℕ) (p : Policy Action Observation n),
      Valid M b p ∧ WorstCost M b p = c ∧
      ∀ q : Policy Action Observation n,
        Valid M b q → c ≤ WorstCost M b q := by
  obtain ⟨p, hp, hbest⟩ :=
    globally_optimal_lifecycle_policy_exists M h
  exact ⟨WorstCost M b p, p, hp, rfl, hbest⟩

end Nightfall.LifecycleAuthority
