import Mathlib

/-!
# Exact version-only semantic fencing

The unsafe-history hypergraph is formed from *permitted* transitions out of
coherently certified baseline states. A guard checks equality of version
counters for a finite set of sources. Authentic, monotone, ABA-free source
versions and full capture of consequential changes are operational assumptions:
the field `changed` must encode exactly the differences detected by those
version checks.

This file proves the structural hitting-set equivalence, an impossibility
result for invisible unsafe changes, and existence of a minimum-cost fence
under explicit source coverage. It does not claim that a physical monitor
implements the model.
-/

namespace Nightfall.SemanticFencing

universe u v

structure System (Source : Type u) (World : Type v) where
  safe : World → Prop
  permitted : World → World → Prop
  changed : World → World → Finset Source

variable {Source : Type u} {World : Type v}

/-- An unsafe permitted change history with exactly this detected support. -/
def UnsafeEdge (M : System Source World) (B : Set World)
    (edge : Finset Source) : Prop :=
  ∃ b, b ∈ B ∧ ∃ y, M.permitted b y ∧ ¬ M.safe y ∧ M.changed b y = edge

/-- The source-version tests jointly detect the changed support. -/
def Hit (guard edge : Finset Source) : Prop :=
  ∃ i, i ∈ guard ∧ i ∈ edge

/-- Under faithful version counters, these are precisely the histories
accepted by an atomic version-only compare. -/
def Accept (M : System Source World) (guard : Finset Source)
    (b y : World) : Prop :=
  ∀ i, i ∈ guard → i ∉ M.changed b y

/-- Every accepted, permitted transition from the evidence set is safe. -/
def FenceSound (M : System Source World) (B : Set World)
    (guard : Finset Source) : Prop :=
  ∀ b, b ∈ B → ∀ y, M.permitted b y →
    Accept M guard b y → M.safe y

/-- Exact equivalence: robust version-only safety iff every unsafe history
intersects the guarded source set. Both directions are constructive. -/
theorem fence_sound_iff_hits
    (M : System Source World) (B : Set World) (guard : Finset Source) :
    FenceSound M B guard ↔
      ∀ edge, UnsafeEdge M B edge → Hit guard edge := by
  constructor
  · intro hsound edge hedge
    obtain ⟨b, hb, y, hpermit, hbad, heq⟩ := hedge
    by_contra hnot
    have haccept : Accept M guard b y := by
      intro i hi hj
      apply hnot
      exact ⟨i, hi, heq ▸ hj⟩
    exact hbad (hsound b hb y hpermit haccept)
  · intro hhits b hb y hpermit haccept
    by_contra hbad
    obtain ⟨i, hi, hj⟩ :=
      hhits (M.changed b y) ⟨b, hb, y, hpermit, hbad, rfl⟩
    exact (haccept i hi) hj

/-- An unsafe change invisible to all source version counters cannot be
protected by any fence consisting exclusively of those counters. -/
theorem invisible_unsafe_change_impossible
    (M : System Source World) (B : Set World)
    (h : UnsafeEdge M B ∅) :
    ∀ guard : Finset Source, ¬ FenceSound M B guard := by
  intro guard hsound
  obtain ⟨i, _, hi⟩ :=
    (fence_sound_iff_hits M B guard).mp hsound ∅ h
  simpa using hi

/-- The additive successful-path cost of atomic source-version tests. -/
def fenceCost (w : Source → ℕ) (guard : Finset Source) : ℕ :=
  ∑ i ∈ guard, w i

/-- Explicit source-coverage assumption: every permitted transition from
the certified baseline to an unsafe state touches some authenticated source. -/
def CompleteCoverage (M : System Source World) (B : Set World) : Prop :=
  ∀ b, b ∈ B → ∀ y, M.permitted b y → ¬ M.safe y →
    ∃ i, i ∈ M.changed b y

theorem all_sources_sound [Fintype Source] [DecidableEq Source]
    (M : System Source World) (B : Set World)
    (hcomplete : CompleteCoverage M B) :
    FenceSound M B (Finset.univ : Finset Source) := by
  intro b hb y hpermit haccept
  by_contra hbad
  obtain ⟨i, hi⟩ := hcomplete b hb y hpermit hbad
  exact (haccept i (Finset.mem_univ i)) hi

/-- Existence of a globally minimum-cost version-only source fence
over *all* finite source subsets (not a heuristic local optimum).
The matching hitting-set characterization is the previous theorem. -/
theorem optimal_fence_exists [Fintype Source] [DecidableEq Source]
    (M : System Source World) (B : Set World)
    (w : Source → ℕ) (hcomplete : CompleteCoverage M B) :
    ∃ guard : Finset Source,
      FenceSound M B guard ∧
      ∀ other : Finset Source,
        FenceSound M B other →
          fenceCost w guard ≤ fenceCost w other := by
  classical
  let choices : Finset (Finset Source) :=
    Finset.univ.filter (FenceSound M B)
  have hnonempty : choices.Nonempty := by
    refine ⟨Finset.univ, ?_⟩
    simp [choices, all_sources_sound M B hcomplete]
  obtain ⟨guard, hguard, hminimum⟩ :=
    Finset.exists_min_image choices (fenceCost w) hnonempty
  refine ⟨guard, (Finset.mem_filter.mp hguard).2, ?_⟩
  intro other hother
  apply hminimum other
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, hother⟩

/-! ## Finite adaptive evidence plans and Bellman read-step composition -/

/-- A finite adaptive observation tree. A read branches on its exact
coherent-snapshot answer; a successful leaf retains a source-version fence. -/
inductive EvidencePlan (Source : Type u) where
  | deny : EvidencePlan Source
  | grant (guard : Finset Source) : EvidencePlan Source
  | read (i : Source) (no yes : EvidencePlan Source) : EvidencePlan Source

/-- An exact binary observation fiber of the original coherent baseline. -/
def readFiber (B : Set World) (obs : Source → World → Bool)
    (i : Source) (bit : Bool) : Set World :=
  {x | x ∈ B ∧ obs i x = bit}

/-- The decision tree must classify the initial snapshot correctly,
read only genuinely separating observations, and fence every grant.
The gate checks source versions at effect time, after these reads. -/
def PlanValid (M : System Source World) (obs : Source → World → Bool)
    (B : Set World) : EvidencePlan Source → Prop
  | .deny => ∀ x, x ∈ B → ¬ M.safe x
  | .grant guard => (∀ x, x ∈ B → M.safe x) ∧ FenceSound M B guard
  | .read i no yes =>
      (∃ x, x ∈ readFiber B obs i false) ∧
      (∃ x, x ∈ readFiber B obs i true) ∧
      PlanValid M obs (readFiber B obs i false) no ∧
      PlanValid M obs (readFiber B obs i true) yes

/-- Exact worst-case additive observation and successful-fence cost. -/
def worstCost (readPrice checkPrice : Source → ℕ) :
    EvidencePlan Source → ℕ
  | .deny => 0
  | .grant guard => fenceCost checkPrice guard
  | .read i no yes =>
      readPrice i + max (worstCost readPrice checkPrice no)
        (worstCost readPrice checkPrice yes)

/-- The Bellman minimax *read* operator is exact: if each answer-fiber
continuation is optimal, their common read-cost plus maximum is an
attainable lower bound for every policy that starts with this read.
Global minimization over all possible root reads remains a separate
finite-depth synthesis problem. -/
theorem optimal_read_step
    (M : System Source World) (obs : Source → World → Bool)
    (B : Set World) (i : Source)
    (readPrice checkPrice : Source → ℕ)
    (hzero : ∃ x, x ∈ readFiber B obs i false)
    (hone : ∃ x, x ∈ readFiber B obs i true)
    (pzero pone : EvidencePlan Source)
    (hvzero : PlanValid M obs (readFiber B obs i false) pzero)
    (hvone : PlanValid M obs (readFiber B obs i true) pone)
    (hoptzero : ∀ q, PlanValid M obs (readFiber B obs i false) q →
      worstCost readPrice checkPrice pzero ≤ worstCost readPrice checkPrice q)
    (hoptone : ∀ q, PlanValid M obs (readFiber B obs i true) q →
      worstCost readPrice checkPrice pone ≤ worstCost readPrice checkPrice q) :
    PlanValid M obs B (.read i pzero pone) ∧
    ∀ qzero qone,
      PlanValid M obs (readFiber B obs i false) qzero →
      PlanValid M obs (readFiber B obs i true) qone →
      worstCost readPrice checkPrice (.read i pzero pone) ≤
        worstCost readPrice checkPrice (.read i qzero qone) := by
  constructor
  · exact ⟨hzero, hone, hvzero, hvone⟩
  · intro qzero qone hqzero hqone
    simp only [worstCost]
    exact add_le_add_right
      (max_le_max (hoptzero qzero hqzero) (hoptone qone hqone))
      (readPrice i)

/-- The exact least-cost direct grant is a valid stopping policy when the
snapshot label is already known safe. Subsequent reads may still improve it. -/
theorem optimal_safe_stopping_plan [Fintype Source] [DecidableEq Source]
    (M : System Source World) (obs : Source → World → Bool)
    (B : Set World) (readPrice checkPrice : Source → ℕ)
    (hsafe : ∀ x, x ∈ B → M.safe x)
    (hcomplete : CompleteCoverage M B) :
    ∃ p : EvidencePlan Source,
      PlanValid M obs B p ∧
      ∀ guard : Finset Source,
        PlanValid M obs B (.grant guard) →
        worstCost readPrice checkPrice p ≤
          worstCost readPrice checkPrice (.grant guard) := by
  obtain ⟨guard, hguard, hoptimal⟩ :=
    optimal_fence_exists M B checkPrice hcomplete
  refine ⟨.grant guard, ⟨hsafe, hguard⟩, ?_⟩
  intro other hother
  exact hoptimal other hother.2

/-- Bellman root principle on an already safely classified snapshot.
Given matching optimal subplans for EVERY splitting observation, a
globally optimal finite evidence/guard policy exists. The proof considers
every possible first action and uses a finite minimax witness rather
than assuming the Bellman recurrence as a definition.

To obtain an executable finite-world dynamic program, one must separately
construct the optimal subplans by well-founded induction on shrinking
evidence fibers. That synthesis bridge is not claimed by this theorem. -/
theorem bellman_root_optimal [Fintype Source] [DecidableEq Source]
    (M : System Source World) (obs : Source → World → Bool)
    (B : Set World) (readPrice checkPrice : Source → ℕ)
    (hne : ∃ x, x ∈ B)
    (hsafe : ∀ x, x ∈ B → M.safe x)
    (hcomplete : CompleteCoverage M B)
    (pzero pone : Source → EvidencePlan Source)
    (hbranches : ∀ i : Source,
      ((∃ x, x ∈ readFiber B obs i false) ∧
       (∃ x, x ∈ readFiber B obs i true)) →
      PlanValid M obs (readFiber B obs i false) (pzero i) ∧
      PlanValid M obs (readFiber B obs i true) (pone i) ∧
      (∀ q, PlanValid M obs (readFiber B obs i false) q →
        worstCost readPrice checkPrice (pzero i) ≤
          worstCost readPrice checkPrice q) ∧
      (∀ q, PlanValid M obs (readFiber B obs i true) q →
        worstCost readPrice checkPrice (pone i) ≤
          worstCost readPrice checkPrice q)) :
    ∃ p : EvidencePlan Source,
      PlanValid M obs B p ∧
      ∀ q, PlanValid M obs B q →
        worstCost readPrice checkPrice p ≤ worstCost readPrice checkPrice q := by
  classical
  obtain ⟨guard, hguard, hbest⟩ :=
    optimal_fence_exists M B checkPrice hcomplete
  let splitting : Finset Source :=
    Finset.univ.filter (fun i =>
      (∃ x, x ∈ readFiber B obs i false) ∧
      (∃ x, x ∈ readFiber B obs i true))
  let choices : Finset (EvidencePlan Source) :=
    insert (.grant guard)
      (splitting.image (fun i => .read i (pzero i) (pone i)))
  have hnonempty : choices.Nonempty := by
    refine ⟨.grant guard, ?_⟩
    simp [choices]
  have hvalid : ∀ p ∈ choices, PlanValid M obs B p := by
    intro p hp
    rcases Finset.mem_insert.mp hp with heq | himg
    · subst p
      exact ⟨hsafe, hguard⟩
    · obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp himg
      have hisplit : (∃ x, x ∈ readFiber B obs i false) ∧
          (∃ x, x ∈ readFiber B obs i true) :=
        (Finset.mem_filter.mp hi).2
      obtain ⟨hzero, hone, _, _⟩ := hbranches i hisplit
      exact ⟨hisplit.1, hisplit.2, hzero, hone⟩
  have hcover : ∀ p, PlanValid M obs B p →
      ∃ candidate ∈ choices,
        worstCost readPrice checkPrice candidate ≤
          worstCost readPrice checkPrice p := by
    intro p hp
    cases p with
    | deny =>
        obtain ⟨x, hx⟩ := hne
        exact False.elim ((hp x hx) (hsafe x hx))
    | grant other =>
        refine ⟨.grant guard, ?_, ?_⟩
        · simp [choices]
        · exact hbest other hp.2
    | read i qzero qone =>
        obtain ⟨hzero, hone, hqzero, hqone⟩ := hp
        obtain ⟨_, _, hlo, hhi⟩ := hbranches i ⟨hzero, hone⟩
        refine ⟨.read i (pzero i) (pone i), ?_, ?_⟩
        · apply Finset.mem_insert.mpr
          right
          apply Finset.mem_image.mpr
          refine ⟨i, ?_, rfl⟩
          exact Finset.mem_filter.mpr
            ⟨Finset.mem_univ i, ⟨hzero, hone⟩⟩
        · exact add_le_add_right
            (max_le_max (hlo qzero hqzero) (hhi qone hqone))
            (readPrice i)
  obtain ⟨best, hbestmem, hleast⟩ :=
    Finset.exists_min_image choices (worstCost readPrice checkPrice) hnonempty
  refine ⟨best, hvalid best hbestmem, ?_⟩
  intro q hq
  obtain ⟨candidate, hcandidate, hbound⟩ := hcover q hq
  exact (hleast candidate hcandidate).trans hbound

/-! ## Lean-checked two-source post-certification witness -/

/-- Binary states 00, 01, 10 are safe; 11 is unsafe. Each changed
coordinate is individually reflected in its authenticated version. -/
def twoBitModel : System (Fin 2) (Fin 4) where
  safe := fun x => x.val ≠ 3
  permitted := fun _ _ => True
  changed := fun b y =>
    Finset.univ.filter (fun i : Fin 2 =>
      Nat.testBit b.val i.val ≠ Nat.testBit y.val i.val)

def twoBitBaseline : Set (Fin 4) := {x | x.val < 3}

def twoBitObservation (i : Fin 2) (x : Fin 4) : Bool :=
  Nat.testBit x.val i.val

def twoBitJointPolicy : EvidencePlan (Fin 2) :=
  .read 0 (.grant {0}) (.grant {1})

/-- Any direct version-only fence has at least two unit checks. -/
theorem two_bit_direct_cost_at_least_eight :
    ∀ guard : Finset (Fin 2),
      FenceSound twoBitModel twoBitBaseline guard →
      8 ≤ fenceCost (fun _ => 4) guard := by
  intro guard hsound
  have hEzero : UnsafeEdge twoBitModel twoBitBaseline
      ({0} : Finset (Fin 2)) := by
    refine ⟨(2 : Fin 4), ?_, (3 : Fin 4), ?_, ?_, ?_⟩ <;> decide
  have hEone : UnsafeEdge twoBitModel twoBitBaseline
      ({1} : Finset (Fin 2)) := by
    refine ⟨(1 : Fin 4), ?_, (3 : Fin 4), ?_, ?_, ?_⟩ <;> decide
  have hzero : (0 : Fin 2) ∈ guard := by
    obtain ⟨i, hi, hmem⟩ :=
      (fence_sound_iff_hits twoBitModel twoBitBaseline guard).mp
        hsound ({0} : Finset (Fin 2)) hEzero
    have heq : i = 0 := by simpa using hmem
    simpa [heq] using hi
  have hone : (1 : Fin 2) ∈ guard := by
    obtain ⟨i, hi, hmem⟩ :=
      (fence_sound_iff_hits twoBitModel twoBitBaseline guard).mp
        hsound ({1} : Finset (Fin 2)) hEone
    have heq : i = 1 := by simpa using hmem
    simpa [heq] using hi
  have hall : guard = Finset.univ := by
    apply Finset.eq_univ_of_forall
    intro i
    fin_cases i
    · exact hzero
    · exact hone
  rw [hall]
  decide

/-- Explicit safety checks for each observation fiber. -/
private theorem two_bit_zero_fiber_safe :
    (∀ x, x ∈ readFiber twoBitBaseline twoBitObservation 0 false →
      twoBitModel.safe x) ∧
    FenceSound twoBitModel
      (readFiber twoBitBaseline twoBitObservation 0 false)
      ({0} : Finset (Fin 2)) := by
  constructor
  · intro x hx
    fin_cases x <;>
      simp_all [readFiber, twoBitBaseline, twoBitObservation, twoBitModel]
  · intro b hb y _ haccept
    have hv := haccept (0 : Fin 2) (by simp)
    fin_cases b <;> fin_cases y <;>
      simp_all [readFiber, twoBitBaseline, twoBitObservation,
        twoBitModel, Accept, Finset.mem_filter]

private theorem two_bit_one_fiber_safe :
    (∀ x, x ∈ readFiber twoBitBaseline twoBitObservation 0 true →
      twoBitModel.safe x) ∧
    FenceSound twoBitModel
      (readFiber twoBitBaseline twoBitObservation 0 true)
      ({1} : Finset (Fin 2)) := by
  constructor
  · intro x hx
    fin_cases x <;>
      simp_all [readFiber, twoBitBaseline, twoBitObservation, twoBitModel]
  · intro b hb y _ haccept
    have hv := haccept (1 : Fin 2) (by simp)
    fin_cases b <;> fin_cases y <;>
      simp_all [readFiber, twoBitBaseline, twoBitObservation,
        twoBitModel, Accept, Finset.mem_filter]

/-- Reading one already-safe baseline bit costs 1 and leaves a single
version check of cost 4 in either observation fiber. -/
theorem two_bit_post_certificate_gain :
    PlanValid twoBitModel twoBitObservation twoBitBaseline twoBitJointPolicy ∧
    worstCost (fun _ => 1) (fun _ => 4) twoBitJointPolicy = 5 ∧
    fenceCost (fun _ => 4) (Finset.univ : Finset (Fin 2)) = 8 := by
  constructor
  · exact ⟨⟨(0 : Fin 4), by decide⟩, ⟨(1 : Fin 4), by decide⟩,
      two_bit_zero_fiber_safe, two_bit_one_fiber_safe⟩
  · constructor <;> decide

end Nightfall.SemanticFencing
