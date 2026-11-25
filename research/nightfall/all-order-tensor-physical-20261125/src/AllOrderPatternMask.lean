import AllOrderPatternGeometry
import AllOrderNearMask
import Mathlib.Data.Fintype.Powerset

namespace Nightfall.AllOrder.Geometry
open Finset
open Nightfall.AllOrder
variable {I J K : Type*} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

abbrev Test (I : Type*) := I ⊕ ((I × I) ⊕ Finset I)
abbrev Pattern (I : Type*) := Test I → Bool

/-- Complete finite truth table.  We deliberately include every zero-subset
    test, not just component tests, to avoid dependent graph indexing. -/
noncomputable def patternOf (a : I → Label J K) (r : ℕ) : Pattern I := by
  classical
  exact Sum.elim (fun i => (a i).isSome) (Sum.elim
    (fun p => decide (nearOption r (a p.1) (a p.2)))
    (fun S => decide ((∑ i ∈ S, optionLabel (a i)) = 0)))

theorem pattern_graph_eq (a b : I → Label J K) (r : ℕ) (h : patternOf a r = patternOf b r) :
    optionGraph a r = optionGraph b r := by
  classical
  ext i j
  have he := congrFun h (.inr (.inl (i,j)))
  have hn : nearOption r (a i) (a j) ↔ nearOption r (b i) (b j) := by
    change decide (nearOption r (a i) (a j)) = decide (nearOption r (b i) (b j)) at he
    by_cases h1 : nearOption r (a i) (a j) <;> by_cases h2 : nearOption r (b i) (b j) <;> simp [h1,h2] at he ⊢
  exact and_congr Iff.rfl hn

theorem pattern_keep_eq (a b : I → Label J K) (r : ℕ) (h : patternOf a r = patternOf b r) :
    keepSet a r = keepSet b r := by
  classical
  have hg := pattern_graph_eq a b r h
  ext i
  have hs : (a i).isSome = (b i).isSome := congrFun h (.inl i)
  have hslots : compSlots a r i = compSlots b r i := by unfold compSlots; rw [hg]
  have hz := congrFun h (.inr (.inr (compSlots a r i)))
  have hz' : compSum a r i = 0 ↔ compSum b r i = 0 := by
    change decide ((∑ j ∈ compSlots a r i, optionLabel (a j)) = 0) =
      decide ((∑ j ∈ compSlots a r i, optionLabel (b j)) = 0) at hz
    rw [hslots] at hz
    have hslot : (∑ j ∈ compSlots b r i, optionLabel (a j)) = compSum a r i := by unfold compSum; rw [hslots]
    rw [hslot] at hz
    change decide (compSum a r i = 0) = decide (compSum b r i = 0) at hz
    by_cases h1 : compSum a r i = 0 <;> by_cases h2 : compSum b r i = 0 <;> simp [h1,h2] at hz ⊢
  unfold keepSet
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  rw [hs]
  exact and_congr Iff.rfl (not_congr hz')

noncomputable def neighbors (r : ℕ) (a : Label J K) : Finset (Label J K) :=
  a.elim ∅ (fun row => (ball row r).image some)

theorem mem_neighbors (r : ℕ) (a b : Label J K) : b ∈ neighbors r a ↔ nearOption r a b := by
  classical
  cases a with
  | none => simp [neighbors,nearOption]
  | some u =>
    cases b with
    | none => simp [neighbors,nearOption]
    | some v => simp [neighbors,nearOption,ball]

theorem neighbors_card (r : ℕ) (a : Label J K) :
    (neighbors r a).card ≤ rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r := by
  classical
  cases a with
  | none => simp [neighbors]
  | some u =>
    exact (Finset.card_image_le (s := ball u r) (f := some)).trans (ball_card_le u r)

noncomputable def testMask (r : ℕ) (t : Test I) (a : I → Label J K) : ℝ := if patternOf a r t then 1 else 0

theorem test_mask_cost (r : ℕ) (t : Test I) :
    MaskCost (testMask (J := J) (K := K) r t)
      ((rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r : ℝ)+1) := by
  classical
  let D := rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r
  have hD : (0:ℝ) ≤ D := by positivity
  rcases t with i | t
  · have h := slot_mask_cost i (fun a : Label J K => if a.isSome then (1:ℝ) else 0) (by intro a; split <;> norm_num)
    apply mask_cost_mono _ 1 _ _ (by linarith)
    exact h
  · rcases t with p | S
    · have h := neighbor_mask_cost (neighbors (J := J) (K := K) r) D (neighbors_card r) p.1 p.2
      apply mask_cost_mono _ (D:ℝ) _ _ (by linarith)
      have he : testMask (J := J) (K := K) r (.inr (.inl p)) = fun b => if b p.2 ∈ neighbors r (b p.1) then 1 else 0 := by
        funext a
        unfold testMask
        change (if decide (nearOption r (a p.1) (a p.2)) then (1:ℝ) else 0) = _
        simp only [mem_neighbors]
        by_cases hn : nearOption r (a p.1) (a p.2) <;> simp [hn]
      rw [he]
      exact h
    · have h := zero_subset_mask_cost (I := I) (A := Label J K) optionLabel tensor_add_self S
      apply mask_cost_mono _ 1 _ _ (by linarith)
      have he : testMask (J := J) (K := K) r (.inr (.inr S)) = fun a => if (∑ i ∈ S, optionLabel (a i)) = 0 then 1 else 0 := by
        funext a
        unfold testMask
        change (if decide ((∑ i ∈ S, optionLabel (a i)) = 0) then (1:ℝ) else 0) = _
        by_cases hz : (∑ i ∈ S, optionLabel (a i)) = 0 <;> simp [hz]
      rw [he]
      exact h

noncomputable def matchMask (r : ℕ) (p : Pattern I) (t : Test I) (a : I → Label J K) : ℝ :=
  if patternOf a r t = p t then 1 else 0

theorem match_mask_cost (r : ℕ) (p : Pattern I) (t : Test I) :
    MaskCost (matchMask (J := J) (K := K) r p t)
      ((rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r : ℝ)+2) := by
  classical
  let D := rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r
  by_cases hp : p t = true
  · have he : matchMask (J := J) (K := K) r p t = testMask r t := by funext a; simp [matchMask,testMask,hp]
    rw [he]
    exact mask_cost_mono _ ((D:ℝ)+1) _ (test_mask_cost r t) (by linarith)
  · have hp' : p t = false := by cases h : p t <;> simp [h] at hp ⊢
    have he : matchMask (J := J) (K := K) r p t = fun a => 1-testMask r t a := by
      funext a
      cases h : patternOf a r t <;> simp [matchMask,testMask,hp',h]
    rw [he]
    apply mask_cost_mono _ (1+((D:ℝ)+1)) _ (mask_cost_complement _ _ (test_mask_cost r t))
    ring_nf
    exact le_rfl

noncomputable def patternMask (r : ℕ) (p : Pattern I) (a : I → Label J K) : ℝ := if patternOf a r = p then 1 else 0

theorem patternMask_prod (r : ℕ) (p : Pattern I) :
    patternMask (J := J) (K := K) r p = fun a => ∏ t : Test I, matchMask r p t a := by
  classical
  funext a
  by_cases h : patternOf a r = p
  · simp [patternMask,matchMask,h]
  · have hn : ∃ t, patternOf a r t ≠ p t := by
      by_contra! h'; exact h (funext h')
    obtain ⟨t,ht⟩ := hn
    have hz : matchMask r p t a = 0 := by simp [matchMask,ht]
    simp only [patternMask,if_neg h]
    exact (Finset.prod_eq_zero (Finset.mem_univ t) hz).symm

theorem pattern_mask_cost (r : ℕ) (p : Pattern I) :
    MaskCost (patternMask (J := J) (K := K) r p)
      (((rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r : ℝ)+2)^Fintype.card (Test I)) := by
  classical
  rw [patternMask_prod]
  simpa using mask_cost_prod (univ : Finset (Test I)) (matchMask (J := J) (K := K) r p)
    (fun _ => ((rowBallBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) r : ℝ)+2))
    (fun t _ => match_mask_cost r p t)

theorem test_card : Fintype.card (Test I) = Fintype.card I + (Fintype.card I)^2 + 2^(Fintype.card I) := by
  simp [Test,Fintype.card_sum,Fintype.card_prod,Fintype.card_finset,pow_two, Nat.add_assoc]

theorem pattern_card : Fintype.card (Pattern I) = 2^(Fintype.card I + (Fintype.card I)^2 + 2^(Fintype.card I)) := by
  change Fintype.card (Test I → Bool) = _
  rw [Fintype.card_fun, test_card]
  simp

#print axioms pattern_keep_eq
#print axioms pattern_mask_cost
#print axioms pattern_card
end Nightfall.AllOrder.Geometry
