import ActualSourceANOVA

/-!
# SCIF source bridge I: actual Efron–Stein degree survives law changes

This is a theorem about the *canonical source-derived* `esComp` and
`ESDegreeLE`, not a free list of pair kernels.  The old marginal law `p`
is normalized. The new product law `q` is arbitrary in this algebraic
statement (normalization is not even needed for cancellation of high-order
components), hence this applies in particular to an edit of one marginal,
including zero-mass symbols, and in fact to simultaneous changes of
all finite-coordinate marginal laws.

It does NOT assert canonical recentering of the low-order components,
the quantitative influence update, or a fixed-owner source certificate.
Those are distinct next interfaces.
-/

namespace Nightfall.SCIF.SourceDegree

open Finset
open Nightfall.Observability.ActualSourceANOVA

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

private theorem canonical_component_ignores_outside
    (p : ι → α → ℝ) (T : Finset ι)
    (f : (ι → α) → ℝ) (k : ι) (hk : k ∉ T) :
    ∀ z : ι → α, ∀ a : α,
      esComp p T f (Function.update z k a) = esComp p T f z := by
  intro z a
  apply esComp_dependsOn p T f
  intro j hj
  have hjk : j ≠ k := by
    intro h
    exact hk (h ▸ hj)
  exact Function.update_of_ne hjk a z

/-- A canonical component supported on at most d coordinates cannot
create an order->d component under any other source-weight array. -/
theorem high_order_of_old_component_zero
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ)
    (S T : Finset ι) (d : ℕ)
    (hS : d < S.card) (hT : T.card ≤ d) (x : ι → α) :
    esComp q S (esComp p T f) x = 0 := by
  have hnot : ¬ S ⊆ T := by
    intro h
    have hc := Finset.card_le_card h
    omega
  have hmiss : ∃ k ∈ S, k ∉ T := by
    by_contra h
    push_neg at h
    exact hnot (fun k hk => h k hk)
  obtain ⟨k, hkS, hkT⟩ := hmiss
  exact esComp_indep q S (esComp p T f) x k hkS
    (canonical_component_ignores_outside p T f k hkT)

/-- Genuine source-product degree is invariant under any finite-product
law change, with no positivity floor. Only the OLD law must be
normalized so that its canonical decomposition represents f. -/
theorem source_degree_invariant_under_new_law
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (d : ℕ)
    (hdegree : ESDegreeLE p f d) :
    ESDegreeLE q f d := by
  classical
  let g : Finset ι → (ι → α) → ℝ :=
    fun T z => if T.card ≤ d then esComp p T f z else 0
  have hsrc : ∀ z : ι → α, f z = ∑ T : Finset ι, g T z := by
    intro z
    calc
      f z = ∑ T : Finset ι, esComp p T f z :=
        (es_decomp p hp1 f z).symm
      _ = ∑ T : Finset ι, g T z := by
        apply Finset.sum_congr rfl
        intro T _
        by_cases hT : T.card ≤ d
        · simp [g, hT]
        · have hz : esComp p T f z = 0 :=
            hdegree T (by omega) z
          simp [g, hT, hz]
  intro S hS x
  have hlinear :
      esComp q S f x = ∑ T : Finset ι, esComp q S (g T) x := by
    calc
      esComp q S f x =
          esComp q S
            (fun z => ∑ T : Finset ι, (1 : ℝ) * g T z) x := by
              congr 1
              funext z
              simpa only [one_mul] using hsrc z
      _ = ∑ T : Finset ι, (1 : ℝ) * esComp q S (g T) x :=
        esComp_lin q S (fun _ : Finset ι => (1 : ℝ)) g x
      _ = ∑ T : Finset ι, esComp q S (g T) x := by simp
  rw [hlinear]
  apply Finset.sum_eq_zero
  intro T _
  by_cases hT : T.card ≤ d
  · have hg : g T = esComp p T f := by
      funext z
      simp [g, hT]
    rw [hg]
    exact high_order_of_old_component_zero p q f S T d hS hT x
  · have hg : g T = fun _ => (0 : ℝ) := by
      funext z
      simp [g, hT]
    rw [hg]
    simp [esComp, condExp]

/-- Degree two is preserved after any source edit, including a single
marginal replacement and any zero-probability atoms. -/
theorem degree_two_source_repair
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    ESDegreeLE q f 2 :=
  source_degree_invariant_under_new_law p q hp1 f 2 hdegree

end Nightfall.SCIF.SourceDegree
