import MarginFreeWeightedOriginal

/-!
# Convert a coordinate-local likelihood statistic into a *real* decision tree

The previous classifier theorems prove that a Boolean decision depends
on a set A with |A| <= K. This module constructs the corresponding
nonadaptive DTree explicitly: it reads every coordinate of A once and
then evaluates the statistic on the assembled word.

The construction handles zero-mass atoms because it uses no conditional
probability division. It is valid for any local real-valued function,
and thus transfers beyond the latent-source setting.
-/

namespace Nightfall.MarginFreeWeightedTree

open Nightfall.ProductSpace.Simulation
open Nightfall.MarginFreeLikelihood
open Nightfall.MarginFreeWeightedOriginal

variable {ι α : Type} [DecidableEq ι]

/-- An explicit nonadaptive tree reading a prescribed finite list.
The accumulated word starts at rho and is updated at queried indices. -/
noncomputable def readList
    (g : (ι → α) → ℝ) : List ι → (ι → α) → DTree ι α
  | [], ρ => .leaf (g ρ) false
  | j :: js, ρ => .node j
      (fun c => readList g js (Function.update ρ j c))

/-- The tree makes exactly one query per list entry on every input. -/
theorem readList_queries (g : (ι → α) → ℝ)
    (js : List ι) (ρ x : ι → α) :
    (readList g js ρ).queries x = js.length := by
  induction js generalizing ρ with
  | nil => rfl
  | cons j rest ih =>
    change (readList g rest (Function.update ρ j (x j))).queries x + 1 =
      (j :: rest).length
    simpa using congrArg Nat.succ (ih (Function.update ρ j (x j)))

/-- The output equals evaluation on the word containing the responses
to all preceding queries. -/
theorem readList_eval (g : (ι → α) → ℝ)
    (js : List ι) (ρ x : ι → α) :
    (readList g js ρ).eval x =
      g (js.foldl (fun state j => Function.update state j (x j)) ρ) := by
  induction js generalizing ρ with
  | nil => rfl
  | cons j rest ih =>
    change (readList g rest (Function.update ρ j (x j))).eval x =
      g (rest.foldl (fun state k => Function.update state k (x k))
        (Function.update ρ j (x j)))
    exact ih (Function.update ρ j (x j))

/-- Once a coordinate agrees with x, subsequent queries cannot destroy
agreement: even a repeated query supplies the same x-coordinate. -/
theorem foldl_update_preserves (js : List ι) (ρ x : ι → α) (i : ι)
    (hi : ρ i = x i) :
    (js.foldl (fun state j => Function.update state j (x j)) ρ) i =
      x i := by
  induction js generalizing ρ with
  | nil => exact hi
  | cons j rest ih =>
    change (rest.foldl (fun state k => Function.update state k (x k))
      (Function.update ρ j (x j))) i = x i
    apply ih
    by_cases h : j = i
    · subst j
      simp
    · simpa [Function.update, h] using hi

/-- Every index appearing in the queried list agrees with the source
input in the assembled final word. No distinctness assumption is needed. -/
theorem foldl_update_agrees_of_mem (js : List ι)
    (ρ x : ι → α) (i : ι) (hi : i ∈ js) :
    (js.foldl (fun state j => Function.update state j (x j)) ρ) i =
      x i := by
  induction js generalizing ρ with
  | nil => cases hi
  | cons j rest ih =>
    rcases List.mem_cons.mp hi with h | h
    · subst j
      change (rest.foldl (fun state k => Function.update state k (x k))
        (Function.update ρ i (x i))) i = x i
      exact foldl_update_preserves rest (Function.update ρ i (x i)) x i
        (by simp)
    · change (rest.foldl (fun state k => Function.update state k (x k))
        (Function.update ρ j (x j))) i = x i
      exact ih (Function.update ρ j (x j)) h

/-- Full DTree realization: *every* A-local real function has a
deterministic nonadaptive decision tree of worst-case depth at most |A|,
independent of the ambient number of coordinates or atom masses. -/
theorem exists_local_decision_tree
    [Fintype ι] (A : Finset ι) (a0 : α)
    (g : (ι → α) → ℝ)
    (hg : ∀ x y, (∀ i ∈ A, x i = y i) → g x = g y) :
    ∃ T : DTree ι α,
      (∀ x, T.queries x ≤ A.card) ∧
      (∀ x, T.eval x = g x) := by
  let ρ : ι → α := fun _ => a0
  let T := readList g A.toList ρ
  refine ⟨T, ?_, ?_⟩
  · intro x
    change (readList g A.toList ρ).queries x ≤ A.card
    rw [readList_queries]
    simp
  · intro x
    change (readList g A.toList ρ).eval x = g x
    rw [readList_eval]
    apply hg
    intro i hi
    apply foldl_update_agrees_of_mem A.toList ρ x i
    simpa using hi

/-- In particular the unequal-posterior, original-source likelihood
rule is realized by a concrete |S|-query deterministic symbol tree. -/
theorem weighted_original_likelihood_tree
    [Fintype ι] [Fintype α] [DecidableEq α]
    (S : Finset ι) (a0 : α) (p q : ι → α → ℝ)
    (wP wQ : ℝ) :
    ∃ T : DTree ι α, (∀ x, T.queries x ≤ S.card) ∧
      ∀ x, T.eval x =
        (if choosePWeighted wP wQ
            (prodMass (observedLaw S a0 p))
            (prodMass (observedLaw S a0 q))
            (canonicalObservation S a0 x)
         then (1 : ℝ) else 0) := by
  let C : (ι → α) → Bool :=
    fun x => choosePWeighted wP wQ
      (prodMass (observedLaw S a0 p))
      (prodMass (observedLaw S a0 q))
      (canonicalObservation S a0 x)
  let g : (ι → α) → ℝ := fun x => if C x then 1 else 0
  have hg : ∀ x y, (∀ i ∈ S, x i = y i) → g x = g y := by
    intro x y hxy
    have h : C x = C y :=
      weighted_original_locality S a0 p q wP wQ x y hxy
    simp [g, h]
  exact exists_local_decision_tree S a0 g hg

#print axioms Nightfall.MarginFreeWeightedTree.readList_queries
#print axioms Nightfall.MarginFreeWeightedTree.readList_eval
#print axioms Nightfall.MarginFreeWeightedTree.exists_local_decision_tree
#print axioms Nightfall.MarginFreeWeightedTree.weighted_original_likelihood_tree

end Nightfall.MarginFreeWeightedTree
