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

end Nightfall.SemanticFencing
