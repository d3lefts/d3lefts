import Mathlib

/-!
# Exact weighted greedy matching domination

For every finite family of graph edges with arbitrary real weights,
this theorem constructs a matching such that each input edge meets a
selected edge with weight at least as large. Neither a covering
certificate nor the final quadratic matching bound is assumed.
-/
namespace Nightfall.Observability.WeightedGreedy
open Finset
variable {ι E : Type*} [DecidableEq ι] [DecidableEq E]

/-- Two graph edges have no common endpoints. -/
def separated (u v : E → ι) (e f : E) : Prop :=
  u e ≠ u f ∧ u e ≠ v f ∧ v e ≠ u f ∧ v e ≠ v f

theorem separated_symm (u v : E → ι) (e f : E) :
    separated u v e f → separated u v f e := by
  rintro ⟨h1, h2, h3, h4⟩
  exact ⟨h1.symm, h3.symm, h2.symm, h4.symm⟩

theorem not_separated_self (u v : E → ι) (e : E) :
    ¬ separated u v e e := by
  intro h
  exact h.1 rfl

def IsMatching (u v : E → ι) (S : Finset E) : Prop :=
  ∀ e ∈ S, ∀ f ∈ S, e ≠ f → separated u v e f

/-- Weighted greedy maximal matching, with full constructive
dominance over the entire finite edge set. -/
theorem exists_weighted_dominating_matching
    [Fintype E] (u v : E → ι) (w : E → ℝ) (T : Finset E) :
    ∃ S : Finset E, S ⊆ T ∧ IsMatching u v S ∧
      ∀ e ∈ T, ∃ f ∈ S,
        ¬ separated u v e f ∧ w e ≤ w f := by
  classical
  induction T using Finset.strongInductionOn with
  | H T ih =>
    by_cases hne : T.Nonempty
    · obtain ⟨a, haT, hmax⟩ := Finset.exists_max_image T w hne
      let R := T.filter (fun e => separated u v e a)
      have hsub : R ⊆ T := Finset.filter_subset T _
      have haNotR : a ∉ R := by
        simp only [R, Finset.mem_filter]
        intro h
        exact not_separated_self u v a h.2
      have hstrict : R ⊂ T := by
        apply Finset.ssubset_iff_subset_ne.mpr
        refine ⟨hsub, ?_⟩
        intro hEq
        exact haNotR (hEq ▸ haT)
      obtain ⟨M, hMsub, hmatch, hdom⟩ := ih R hstrict
      refine ⟨insert a M, ?_, ?_, ?_⟩
      · intro e he
        rcases Finset.mem_insert.mp he with heq | heM
        · exact heq ▸ haT
        · exact hsub (hMsub heM)
      · intro e he f hf hef
        rcases Finset.mem_insert.mp he with heq | heM
        · rcases Finset.mem_insert.mp hf with hfEq | hfM
          · exact False.elim (hef (heq.trans hfEq.symm))
          · subst e
            exact separated_symm u v f a
              (Finset.mem_filter.mp (hMsub hfM)).2
        · rcases Finset.mem_insert.mp hf with hfEq | hfM
          · subst f
            exact (Finset.mem_filter.mp (hMsub heM)).2
          · exact hmatch e heM f hfM hef
      · intro e he
        by_cases hsep : separated u v e a
        · have heR : e ∈ R := Finset.mem_filter.mpr ⟨he, hsep⟩
          obtain ⟨f, hf, htouch, hweight⟩ := hdom e heR
          exact ⟨f, Finset.mem_insert.mpr (Or.inr hf), htouch, hweight⟩
        · exact ⟨a, by simp, hsep, hmax e he⟩
    · refine ⟨∅, by simp, ?_, ?_⟩
      · intro e he
        exact (Finset.not_mem_empty e he).elim
      · intro e he
        exact (hne ⟨e, he⟩).elim

end Nightfall.Observability.WeightedGreedy
