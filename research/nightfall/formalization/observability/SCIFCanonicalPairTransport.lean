import SCIFRectUnique
import SCIFRecenter
import SCIFDegreeTransport
import ActualSourceCentered

/-!
# SCIF: actual canonical source pair after one marginal-law change

All terms are Efron–Stein components of the SAME full-product f.
This is not a supplied abstract pair kernel. The proof uses:
1. actual old/new pointwise degree-two and canonical rectangle identities;
2. actual source centering in both pair coordinates;
3. uniqueness of bi-centered kernels from four-corner rectangles;
4. SCIF's exact first-coordinate recentering algebra.

No atom positivity or division by small probabilities.
-/

namespace Nightfall.SCIF.CanonicalPairTransport

open Finset
open Nightfall.SCIF
open Nightfall.SCIF.RectUnique
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceCentered
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.SCIFDegreeTransport

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- When a SINGLE source law p_i is replaced by q, the actual new
canonical pair on i,j equals the old canonical pair minus its new
i-mean. Statement is pointwise on all full-source configurations,
including zero-probability atoms of either law. -/
theorem canonical_incident_pair_recenter_exact
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i j : ι) (hij : i ≠ j)
    (q : α → ℝ) (hq : (∑ a : α, q a) = 1)
    (x : ι → α) (a b : α) :
    esComp (Function.update p i q) ({i,j} : Finset ι) f
      (Function.update (Function.update x i a) j b) =
    esComp p ({i,j} : Finset ι) f
      (Function.update (Function.update x i a) j b) -
    (∑ z : α, q z * esComp p ({i,j} : Finset ι) f
      (Function.update (Function.update x i z) j b)) := by
  classical
  let pp : ι → α → ℝ := Function.update p i q
  have hpp1 (t : ι) : (∑ z : α, pp t z) = 1 := by
    by_cases ht : t = i
    · subst t
      simpa [pp] using hq
    · simpa [pp, ht] using hp1 t
  have hdegq : ESDegreeLE pp f 2 :=
    degree_two_preserved_by_any_law p pp hp1 f hdegree
  let T : Finset ι := {i,j}
  let oldTab : α → α → ℝ :=
    fun u v => esComp p T f (Function.update (Function.update x i u) j v)
  let newTab : α → α → ℝ :=
    fun u v => esComp pp T f (Function.update (Function.update x i u) j v)
  have hiT : i ∈ T := by simp [T]
  have hjT : j ∈ T := by simp [T]
  have hOldCol (u : α) : (∑ v : α, p j v * oldTab u v) = 0 := by
    simpa only [oldTab, T] using
      (actual_esComp_centered p hp1 f T j hjT
        (Function.update x i u))
  have hNewCol (u : α) : (∑ v : α, p j v * newTab u v) = 0 := by
    have hj : pp j = p j := by simp [pp, Ne.symm hij]
    have h := actual_esComp_centered pp hpp1 f T j hjT
      (Function.update x i u)
    simpa only [newTab, hj] using h
  have hNewRow (v : α) : (∑ u : α, q u * newTab u v) = 0 := by
    have hi : pp i = q := by simp [pp]
    have h := actual_esComp_centered pp hpp1 f T i hiT
      (Function.update x j v)
    calc
      (∑ u : α, q u * newTab u v) =
        ∑ u : α, pp i u *
          esComp pp T f (Function.update (Function.update x j v) i u) := by
            apply Finset.sum_congr rfl
            intro u _
            rw [hi]
            dsimp [newTab]
            rw [Function.update_comm hij]
      _ = 0 := h
  have hOldRectangle (u v w z : α) :
      rectangle newTab u v w z = rectangle oldTab u v w z := by
    have ho := actual_quadratic_rectangle_eq_es_pair
      p hp1 f hdegree i j hij x u v w z
    have hn := actual_quadratic_rectangle_eq_es_pair
      pp hpp1 f hdegq i j hij x u v w z
    dsimp [rectangle, oldTab, newTab, T, sourceRectangle] at *
    linarith
  have hRect (u v w z : α) :
      rectangle newTab u v w z =
        rectangle (pairRecenter q oldTab) u v w z := by
    rw [rectangle_pairRecenter]
    exact hOldRectangle u v w z
  have heq := same_rectangles_imply_equal
    q (p j) hq (hp1 j) newTab (pairRecenter q oldTab)
    hNewRow
    (pairRecenter_first_centered q hq oldTab)
    hNewCol
    (pairRecenter_other_centered q (p j) oldTab hOldCol)
    hRect a b
  simpa only [newTab, oldTab, T, pairRecenter, firstMean, pp] using heq

end Nightfall.SCIF.CanonicalPairTransport
