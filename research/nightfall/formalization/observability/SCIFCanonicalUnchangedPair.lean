import SCIFCanonicalPairTransport

/-!
# SCIF: unaffected canonical pairs are literally unchanged by one edit

One source marginal i changes; the two tested pair sites j,l are
distinct from i and each other. All expressions use the genuine
full-product f and source-derived Efron–Stein components.
-/
namespace Nightfall.SCIF.CanonicalUnchangedPair

open Finset
open Nightfall.SCIF.RectUnique
open Nightfall.SCIF
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceCentered
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.SCIFDegreeTransport

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual canonical pair {j,l} is pointwise unchanged when only
coordinate i outside the pair changes its marginal law. -/
theorem canonical_unaffected_pair_exact
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i j l : ι) (hij : i ≠ j) (hil : i ≠ l) (hjl : j ≠ l)
    (q : α → ℝ) (hq : (∑ a : α, q a) = 1)
    (x : ι → α) (a b : α) :
    esComp (Function.update p i q) ({j,l} : Finset ι) f
      (Function.update (Function.update x j a) l b) =
    esComp p ({j,l} : Finset ι) f
      (Function.update (Function.update x j a) l b) := by
  classical
  let pp : ι → α → ℝ := Function.update p i q
  have hpp1 (t : ι) : (∑ z : α, pp t z) = 1 := by
    by_cases ht : t = i
    · subst t
      simpa [pp] using hq
    · simpa [pp, ht] using hp1 t
  have hdegq : ESDegreeLE pp f 2 :=
    degree_two_preserved_by_any_law p pp hp1 f hdegree
  let T : Finset ι := {j,l}
  let oldTab : α → α → ℝ :=
    fun u v => esComp p T f (Function.update (Function.update x j u) l v)
  let newTab : α → α → ℝ :=
    fun u v => esComp pp T f (Function.update (Function.update x j u) l v)
  have hjT : j ∈ T := by simp [T]
  have hlT : l ∈ T := by simp [T]
  have hOldCol (u : α) : (∑ v : α, p l v * oldTab u v) = 0 := by
    simpa only [oldTab, T] using
      (actual_esComp_centered p hp1 f T l hlT
        (Function.update x j u))
  have hNewCol (u : α) : (∑ v : α, p l v * newTab u v) = 0 := by
    have hl : pp l = p l := by simp [pp, Ne.symm hil]
    have h := actual_esComp_centered pp hpp1 f T l hlT
      (Function.update x j u)
    simpa only [newTab, hl] using h
  have hOldRow (v : α) : (∑ u : α, p j u * oldTab u v) = 0 := by
    have h := actual_esComp_centered p hp1 f T j hjT
      (Function.update x l v)
    calc
      (∑ u : α, p j u * oldTab u v) =
        ∑ u : α, p j u *
          esComp p T f (Function.update (Function.update x l v) j u) := by
            apply Finset.sum_congr rfl
            intro u _
            dsimp [oldTab]
            rw [Function.update_comm hjl]
      _ = 0 := h
  have hNewRow (v : α) : (∑ u : α, p j u * newTab u v) = 0 := by
    have hj : pp j = p j := by simp [pp, Ne.symm hij]
    have h := actual_esComp_centered pp hpp1 f T j hjT
      (Function.update x l v)
    calc
      (∑ u : α, p j u * newTab u v) =
        ∑ u : α, pp j u *
          esComp pp T f (Function.update (Function.update x l v) j u) := by
            apply Finset.sum_congr rfl
            intro u _
            rw [hj]
            dsimp [newTab]
            rw [Function.update_comm hjl]
      _ = 0 := h
  have hrect (u v w z : α) :
      rectangle newTab u v w z = rectangle oldTab u v w z := by
    have ho := actual_quadratic_rectangle_eq_es_pair
      p hp1 f hdegree j l hjl x u v w z
    have hn := actual_quadratic_rectangle_eq_es_pair
      pp hpp1 f hdegq j l hjl x u v w z
    dsimp [rectangle, oldTab, newTab, T, sourceRectangle] at *
    linarith
  have heq := same_rectangles_imply_equal
    (p j) (p l) (hp1 j) (hp1 l) newTab oldTab
    hNewRow hOldRow hNewCol hOldCol hrect a b
  simpa only [newTab, oldTab, T, pp] using heq

end Nightfall.SCIF.CanonicalUnchangedPair
