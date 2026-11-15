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

noncomputable def WorstCost [Fintype Observation]
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


/-- A concrete execution trace of the modeled actual system. The environment
may choose any permitted observation sequence. This is an operational *trace*
type, not an asserted Linux/AWS/physical refinement. -/
inductive Execution
    (M : Model Belief Action Observation)
    {Actual : Type z} (R : OperationalRefinement M Actual) :
    {n : ℕ} → Actual → Policy Action Observation n → List Actual → Prop where
  | finish (x : Actual) :
      Execution M R x (.finish) [x]
  | execute {n : ℕ} {x y : Actual} {a : Action} {o : Observation}
      {k : Observation → Policy Action Observation n}
      {rest : List Actual}
      (hstep : R.actualStep x a o y)
      (hrest : Execution M R y (k o) rest) :
      Execution M R x (.execute a k) (x :: rest)

/-- The entire finite operational execution is safe, not only its first step.
This holds for EVERY horizon and EVERY adversarial observation trace, provided
the actual-to-belief forward simulation and policy validity hypotheses hold. -/
theorem execution_all_safe
    (M : Model Belief Action Observation)
    {Actual : Type z} (R : OperationalRefinement M Actual)
    {n : ℕ} {x : Actual} {p : Policy Action Observation n}
    {trace : List Actual} (hr : Execution M R x p trace) :
    Valid M (R.abstract x) p →
      ∀ y, y ∈ trace → M.safe (R.abstract y) := by
  induction hr with
  | finish x =>
      intro hp y hy
      simp only [List.mem_singleton] at hy
      subst y
      exact valid_state_safe M hp
  | execute hstep hrest ih =>
      intro hp y hy
      rcases List.mem_cons.mp hy with heq | htail
      · subst y
        exact valid_state_safe M hp
      · exact ih (operational_step_safe M R hp hstep).2 y htail

/-- Source-aware certificate reuse across a changed version assignment. -/
def Reusable {Source : Type*} (dependencies : Finset Source)
    (certificateVersion currentVersion : Source → ℕ) : Prop :=
  ∀ i, i ∈ dependencies → certificateVersion i = currentVersion i

theorem reusable_after_irrelevant_change {Source : Type*}
    (dependencies : Finset Source)
    (certificateVersion oldVersion newVersion : Source → ℕ)
    (hvalid : Reusable dependencies certificateVersion oldVersion)
    (hunchanged : ∀ i, i ∈ dependencies →
      oldVersion i = newVersion i) :
    Reusable dependencies certificateVersion newVersion := by
  intro i hi
  exact (hvalid i hi).trans (hunchanged i hi)

theorem changed_dependency_invalidates {Source : Type*}
    (dependencies : Finset Source)
    (certificateVersion oldVersion newVersion : Source → ℕ)
    (hvalid : Reusable dependencies certificateVersion oldVersion)
    {i : Source} (hi : i ∈ dependencies)
    (hchanged : oldVersion i ≠ newVersion i) :
    ¬ Reusable dependencies certificateVersion newVersion := by
  intro hnew
  apply hchanged
  exact (hvalid i hi).symm.trans (hnew i hi)

theorem reusable_union_iff {Source : Type*} [DecidableEq Source]
    (D E : Finset Source) (certificateVersion currentVersion : Source → ℕ) :
    Reusable (D ∪ E) certificateVersion currentVersion ↔
      Reusable D certificateVersion currentVersion ∧
        Reusable E certificateVersion currentVersion := by
  constructor
  · intro h
    constructor
    · intro i hi
      exact h i (Finset.mem_union.mpr (Or.inl hi))
    · intro i hi
      exact h i (Finset.mem_union.mpr (Or.inr hi))
  · intro h i hi
    rcases Finset.mem_union.mp hi with hD | hE
    · exact h.1 i hD
    · exact h.2 i hE

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
  rw [hcost]
  exact Nat.find_min' hex ⟨q, hq, rfl⟩

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


/-- Bellman root theorem: for any FIXED admissible first lifecycle action
with a feasible contingent completion, replacing each attainable observation
branch by its global optimal continuation cannot increase worst-case cost.
This is not a supplied recurrence premise. It follows from actual policy
validity, exact branch minimizers, and the adversarial finite supremum. -/
theorem fixed_first_action_bellman
    [Fintype Observation]
    (M : Model Belief Action Observation)
    {n : ℕ} {b : Belief} {a : Action}
    (hroot : ∃ k : Observation → Policy Action Observation n,
      Valid M b (.execute a k)) :
    ∃ kopt : Observation → Policy Action Observation n,
      Valid M b (.execute a kopt) ∧
      ∀ k : Observation → Policy Action Observation n,
        Valid M b (.execute a k) →
          WorstCost M b (.execute a kopt) ≤
            WorstCost M b (.execute a k) := by
  classical
  obtain ⟨k₀, hk₀⟩ := hroot
  let chosen (o : Observation) (ho : M.possible b a o) :
      Policy Action Observation n :=
    Classical.choose (globally_optimal_lifecycle_policy_exists M
      ⟨k₀ o, hk₀.2.2.2 o ho⟩)
  let kopt (o : Observation) : Policy Action Observation n :=
    if ho : M.possible b a o then chosen o ho else .finish
  have hchosen_valid (o : Observation) (ho : M.possible b a o) :
      Valid M (M.post b a o) (chosen o ho) := by
    exact (Classical.choose_spec
      (globally_optimal_lifecycle_policy_exists M
        ⟨k₀ o, hk₀.2.2.2 o ho⟩)).1
  have hchosen_best (o : Observation) (ho : M.possible b a o)
      (q : Policy Action Observation n)
      (hq : Valid M (M.post b a o) q) :
      WorstCost M (M.post b a o) (chosen o ho) ≤
        WorstCost M (M.post b a o) q := by
    exact (Classical.choose_spec
      (globally_optimal_lifecycle_policy_exists M
        ⟨k₀ o, hk₀.2.2.2 o ho⟩)).2 q hq
  have hvalid : Valid M b (.execute a kopt) := by
    refine ⟨hk₀.1, hk₀.2.1, hk₀.2.2.1, ?_⟩
    intro o ho
    simpa [kopt, ho] using hchosen_valid o ho
  refine ⟨kopt, hvalid, ?_⟩
  intro k hk
  unfold WorstCost
  apply Nat.add_le_add_left
  apply Finset.sup_le
  intro o homem
  have hpoint :
      (if M.possible b a o then
          WorstCost M (M.post b a o) (kopt o) else 0) ≤
      (if M.possible b a o then
          WorstCost M (M.post b a o) (k o) else 0) := by
    by_cases ho : M.possible b a o
    · have h := hchosen_best o ho (k o) (hk.2.2.2 o ho)
      simpa [kopt, ho] using h
    · simp [ho]
  exact hpoint.trans (Finset.le_sup (s := Finset.univ)
    (f := fun o : Observation =>
      if M.possible b a o then
        WorstCost M (M.post b a o) (k o) else 0) homem)

end Nightfall.LifecycleAuthority
