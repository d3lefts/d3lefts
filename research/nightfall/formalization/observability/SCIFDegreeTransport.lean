import SCIFSourceGraph

/-!
# SCIF: pointwise Efron–Stein degree survives changes of product law

The proof starts from the actual old-law canonical ANOVA decomposition,
whose equality to f holds at EVERY configuration, including old zero-mass
states. Every degree-one or degree-two component depends on at most two
actual coordinates. The new-law Mobius component on any larger set
therefore vanishes by exact coordinate-toggle cancellation.

There is no new-law degree hypothesis, no ratio of marginal weights,
and no old/new support-containment premise.
-/

namespace Nightfall.Observability.SCIFDegreeTransport

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.SCIFSourceGraph

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Pointwise finite degree two is a property of the function and
coordinate partition, not of the chosen normalized product law. -/
theorem degree_two_preserved_by_any_law
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdp : ESDegreeLE p f 2) :
    ESDegreeLE q f 2 := by
  classical
  intro S hS x
  let c : Finset ι → ℝ := fun T => if T.card ≤ 2 then 1 else 0
  let g : Finset ι → (ι → α) → ℝ := fun T => esComp p T f
  have hpoint (y : ι → α) :
      (∑ T : Finset ι, c T * g T y) = f y := by
    calc
      (∑ T : Finset ι, c T * g T y) =
        ∑ T : Finset ι,
          if T.card ≤ 2 then esComp p T f y else 0 := by
            apply Finset.sum_congr rfl
            intro T _
            by_cases hT : T.card ≤ 2 <;> simp [c, g, hT]
      _ = f y :=
        actual_degree_two_source_decomposition p hp1 f hdp y
  calc
    esComp q S f x =
        esComp q S (fun y => ∑ T : Finset ι, c T * g T y) x := by
          apply congrArg (fun F : (ι → α) → ℝ => esComp q S F x)
          funext y
          exact (hpoint y).symm
    _ = ∑ T : Finset ι, c T * esComp q S (g T) x :=
      esComp_lin q S c g x
    _ = 0 := by
      apply Finset.sum_eq_zero
      intro T _
      by_cases hT : T.card ≤ 2
      · have hnot : ¬ S ⊆ T := by
          intro hs
          have hcard : S.card ≤ T.card := Finset.card_le_card hs
          omega
        have hmiss : ∃ k ∈ S, k ∉ T := by
          by_contra hh
          push_neg at hh
          exact hnot (fun k hk => hh k hk)
        obtain ⟨k, hkS, hkT⟩ := hmiss
        have hignore :
            ∀ y : ι → α, ∀ a : α,
              g T (Function.update y k a) = g T y := by
          intro y a
          dsimp [g]
          exact dependsOn_update_outside T (esComp p T f)
            (esComp_dependsOn p T f) k hkT y a
        have hzero := esComp_indep q S (g T) x k hkS hignore
        simp [c, hT, hzero]
      · simp [c, hT]

/-- Fully source-level graph invariance with only the old-law degree
hypothesis, by transferring degree first and then applying the
canonical original-source mixed-rectangle theorem. -/
theorem canonical_pair_graph_invariant_after_any_law_change
    (p q : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (hq1 : ∀ t, (∑ a : α, q t a) = 1)
    (f : (ι → α) → ℝ)
    (hdp : ESDegreeLE p f 2)
    (i j : ι) (hij : i ≠ j) :
    HasCanonicalPairRectangle p f i j ↔
      HasCanonicalPairRectangle q f i j := by
  exact canonical_pair_graph_invariant p q hp1 hq1 f hdp
    (degree_two_preserved_by_any_law p q hp1 f hdp) i j hij

end Nightfall.Observability.SCIFDegreeTransport
