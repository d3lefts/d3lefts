import Mathlib
import WeightedGreedyMatching

/-!
# Actual finite weighted matching to endpoint-cover certificate

The graph-cover budget is derived from an *existing matching* and its
weights, not supplied as a vertex-cost premise. The final theorem combines
the strictly verified max-first greedy existence construction with the
double-counted endpoint cost identity and a matching-mass hypothesis.
This is a structural subtheorem, not yet the real-function influence bound.
-/
namespace Nightfall.Observability.WeightedGreedyCover
open Finset Nightfall.Observability.WeightedGreedy
variable {ι E : Type*} [Fintype ι] [Fintype E]
  [DecidableEq ι] [DecidableEq E]

/-- Each selected edge pays its full weight to both endpoints. -/
noncomputable def cost (u v : E → ι) (w : E → ℝ)
    (S : Finset E) (i : ι) : ℝ :=
  ∑ e ∈ S,
    ((if u e = i then w e else 0) +
     (if v e = i then w e else 0))

theorem cost_nonneg (u v : E → ι) (w : E → ℝ) (S : Finset E)
    (hw : ∀ e ∈ S, 0 ≤ w e) (i : ι) :
    0 ≤ cost u v w S i := by
  unfold cost
  apply Finset.sum_nonneg
  intro e he
  have hwe := hw e he
  have hl : 0 ≤ (if u e = i then w e else 0) := by split_ifs <;> positivity
  have hr : 0 ≤ (if v e = i then w e else 0) := by split_ifs <;> positivity
  exact add_nonneg hl hr

/-- Exact total endpoint cost: twice the selected edge mass, even with
self-loops, heterogeneous weights and nonzero collisions. -/
theorem sum_cost_twice (u v : E → ι) (w : E → ℝ) (S : Finset E) :
    (∑ i : ι, cost u v w S i) = 2 * (∑ e ∈ S, w e) := by
  classical
  calc
    (∑ i : ι, cost u v w S i) =
        ∑ e ∈ S, ∑ i : ι,
          ((if u e = i then w e else 0) +
           (if v e = i then w e else 0)) := by
          unfold cost
          exact Finset.sum_comm
    _ = ∑ e ∈ S, (w e + w e) := by
          apply Finset.sum_congr rfl
          intro e _
          rw [Finset.sum_add_distrib]
          simp
    _ = 2 * (∑ e ∈ S, w e) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro e _
          ring

/-- A nonnegative edge's weight is paid for by every incident endpoint. -/
theorem cost_ge_incident (u v : E → ι) (w : E → ℝ) (S : Finset E)
    (hw : ∀ e ∈ S, 0 ≤ w e) (f : E) (hf : f ∈ S) (i : ι)
    (hinc : u f = i ∨ v f = i) :
    w f ≤ cost u v w S i := by
  classical
  have hterm (e : E) (he : e ∈ S) :
      0 ≤ (if u e = i then w e else 0) +
          (if v e = i then w e else 0) := by
    have hwe := hw e he
    split_ifs <;> positivity
  have hself :
      w f ≤ (if u f = i then w f else 0) +
              (if v f = i then w f else 0) := by
    by_cases hu : u f = i <;> by_cases hv : v f = i <;>
      simp [hu, hv] at hinc ⊢ <;> nlinarith [hw f hf]
  calc
    w f ≤ (if u f = i then w f else 0) +
              (if v f = i then w f else 0) := hself
    _ ≤ ∑ e ∈ S, ((if u e = i then w e else 0) +
                   (if v e = i then w e else 0)) :=
      Finset.single_le_sum (fun e he => hterm e he) hf
    _ = cost u v w S i := rfl

/-- Every finite nonnegative weighted graph has a matching-generated
nonnegative endpoint cover costing exactly twice its matched edge mass. -/
theorem matching_endpoint_cover
    (u v : E → ι) (w : E → ℝ) (T : Finset E)
    (hw : ∀ e ∈ T, 0 ≤ w e) :
    ∃ (S : Finset E) (c : ι → ℝ),
      S ⊆ T ∧ IsMatching u v S ∧
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) = 2 * (∑ e ∈ S, w e) ∧
      (∀ e ∈ T, w e ≤ max (c (u e)) (c (v e))) := by
  classical
  obtain ⟨S, hSsub, hmatch, hdom⟩ :=
    exists_weighted_dominating_matching u v w T
  let c := cost u v w S
  refine ⟨S, c, hSsub, hmatch, ?_, ?_, ?_⟩
  · intro i
    exact cost_nonneg u v w S (fun e he => hw e (hSsub he)) i
  · exact sum_cost_twice u v w S
  · intro e he
    obtain ⟨f, hfS, htouch, hweight⟩ := hdom e he
    have hcontact :
        u e = u f ∨ u e = v f ∨ v e = u f ∨ v e = v f := by
      by_contra hnot
      push_neg at hnot
      exact htouch ⟨hnot.1, hnot.2.1, hnot.2.2.1, hnot.2.2.2⟩
    have hwS : ∀ g ∈ S, 0 ≤ w g :=
      fun g hg => hw g (hSsub hg)
    rcases hcontact with h1 | h2 | h3 | h4
    · calc
        w e ≤ w f := hweight
        _ ≤ c (u e) :=
          cost_ge_incident u v w S hwS f hfS (u e) (Or.inl h1.symm)
        _ ≤ max (c (u e)) (c (v e)) := le_max_left _ _
    · calc
        w e ≤ w f := hweight
        _ ≤ c (u e) :=
          cost_ge_incident u v w S hwS f hfS (u e) (Or.inr h2.symm)
        _ ≤ max (c (u e)) (c (v e)) := le_max_left _ _
    · calc
        w e ≤ w f := hweight
        _ ≤ c (v e) :=
          cost_ge_incident u v w S hwS f hfS (v e) (Or.inl h3.symm)
        _ ≤ max (c (u e)) (c (v e)) := le_max_right _ _
    · calc
        w e ≤ w f := hweight
        _ ≤ c (v e) :=
          cost_ge_incident u v w S hwS f hfS (v e) (Or.inr h4.symm)
        _ ≤ max (c (u e)) (c (v e)) := le_max_right _ _

/-- Completely derived weighted endpoint cover, given only a matching-mass
bound. No matching, domination or cover is passed as a hypothesis. -/
theorem matching_budget_to_endpoint_budget
    (u v : E → ι) (w : E → ℝ) (T : Finset E)
    (B : ℝ) (hw : ∀ e ∈ T, 0 ≤ w e)
    (hmass : ∀ S : Finset E, S ⊆ T → IsMatching u v S →
      (∑ e ∈ S, w e) ≤ 4 * B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ e ∈ T, w e ≤ max (c (u e)) (c (v e))) := by
  obtain ⟨S, c, hsub, hmatch, hc, htotal, hcover⟩ :=
    matching_endpoint_cover u v w T hw
  refine ⟨c, hc, ?_, hcover⟩
  have h := hmass S hsub hmatch
  nlinarith [htotal]

end Nightfall.Observability.WeightedGreedyCover
