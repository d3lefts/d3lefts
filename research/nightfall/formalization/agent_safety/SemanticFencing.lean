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
    exact add_le_add_left
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
  decide

/-- The initially safe-certified set admits a one-bit further observation
and one check, costing exactly 1+4 = 5 quarter-units instead of 8. -/
theorem two_bit_post_certificate_gain :
    PlanValid twoBitModel twoBitObservation twoBitBaseline twoBitJointPolicy ∧
    worstCost (fun _ => 1) (fun _ => 4) twoBitJointPolicy = 5 ∧
    fenceCost (fun _ => 4) (Finset.univ : Finset (Fin 2)) = 8 := by
  decide

end Nightfall.SemanticFencing
