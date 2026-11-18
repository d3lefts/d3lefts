import InfinitePiAllDegreeFiniteIndicators
import InfinitePiQ2FiniteDegreeBridge
import Mathlib

/-!
# Every-degree finite original-law residual to indicator-degree bridge

This is the algebraic terminal between the source residual word and
the finite indicator-degree predicate: for each S with |S|>d, if the
ordered heat-bath residual along S.toList vanishes *pointwise*, then
the canonical source ANOVA component on S vanishes, and its full
indicator-monomial expansion has degree at most d.

This statement is source-law-correct even with zero-mass atoms.
The separate L²-supported-to-all-words repair and imported historical
NF-PS-FINITE theorem remain additional explicit gates.
-/

namespace Nightfall.InfinitePiAllDegreeFiniteResidualBridge

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.InfinitePiQ2FiniteDegreeBridge
open Nightfall.InfinitePiAllDegreeFiniteIndicators

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The genuine one-site averaging operation under p_i. -/
noncomputable def nativeHeatBath (p : ι → α → ℝ)
    (i : ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  ∑ a : α, p i a * f (Function.update x i a)

/-- The genuine one-site original-law residual, with no atom floor. -/
noncomputable def nativeResidual (p : ι → α → ℝ)
    (i : ι) (f : (ι → α) → ℝ) (x : ι → α) : ℝ :=
  f x - nativeHeatBath p i f x

/-- The original-law averaging operation ignores the coordinate
it averages out, regardless of whether some atoms have mass zero. -/
theorem nativeHeatBath_ignore (p : ι → α → ℝ)
    (i : ι) (f : (ι → α) → ℝ) (x : ι → α) (b : α) :
    nativeHeatBath p i f (Function.update x i b) =
      nativeHeatBath p i f x := by
  simp [nativeHeatBath, Function.update_idem]

/-- Each canonical ANOVA component containing i is unchanged by
replacing f with the genuine original-law coordinate residual D_i f.
No positivity or normalization is used in this cancellation. -/
theorem esComp_nativeResidual (p : ι → α → ℝ)
    (S : Finset ι) (i : ι) (hi : i ∈ S)
    (f : (ι → α) → ℝ) (x : ι → α) :
    esComp p S (nativeResidual p i f) x = esComp p S f x := by
  have hz : esComp p S (nativeHeatBath p i f) x = 0 :=
    esComp_indep p S (nativeHeatBath p i f) x i hi
      (fun z b => nativeHeatBath_ignore p i f z b)
  unfold nativeResidual
  rw [esComp_sub, hz, sub_zero]

/-- Apply a finite ordered word of true-law heat-bath residuals. -/
noncomputable def iterNativeResidual (p : ι → α → ℝ) :
    List ι → ((ι → α) → ℝ) → ((ι → α) → ℝ)
  | [], f => f
  | i :: rest, f => nativeResidual p i (iterNativeResidual p rest f)

/-- A canonical ANOVA component S survives every residual at a
coordinate in S, for arbitrary length and order. -/
theorem esComp_iterNativeResidual (p : ι → α → ℝ)
    (S : Finset ι) (sites : List ι)
    (f : (ι → α) → ℝ) (x : ι → α)
    (hmem : ∀ i, i ∈ sites → i ∈ S) :
    esComp p S (iterNativeResidual p sites f) x = esComp p S f x := by
  revert hmem
  induction sites with
  | nil =>
      intro _
      rfl
  | cons i rest ih =>
      intro hmem
      have hi : i ∈ S := hmem i (by simp)
      have hrest : ∀ j, j ∈ rest → j ∈ S := by
        intro j hj
        exact hmem j (by simp [hj])
      change esComp p S
          (nativeResidual p i (iterNativeResidual p rest f)) x =
            esComp p S f x
      rw [esComp_nativeResidual p S i hi (iterNativeResidual p rest f) x]
      exact ih hrest

/-- If every original-law residual along the full coordinate
set S vanishes whenever |S|>d, all canonical interactions beyond
order d vanish pointwise. This assumption is a finite-word equality,
not a supplied ANOVA degree oracle. -/
theorem nativeResidualWords_imply_ESDegreeLE
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (d : ℕ)
    (hzero : ∀ S : Finset ι, d < S.card →
      iterNativeResidual p S.toList f = fun _ => 0) :
    ESDegreeLE p f d := by
  intro S hS x
  have hmem : ∀ i, i ∈ S.toList → i ∈ S := by
    intro i hi
    simpa using hi
  have hinv := esComp_iterNativeResidual p S S.toList f x hmem
  have hz : esComp p S (iterNativeResidual p S.toList f) x = 0 := by
    rw [hzero S hS]
    simp [esComp, condExp]
  rw [hz] at hinv
  exact hinv.symm

/-- **Exact finite composition against the indicator-degree input of
NF-PS-FINITE.** The finite source residual hypothesis (at every S
above order d) produces the required bounded interaction-degree
indicator expansion with the SAME degree d and no atom mass factor.
The historical RowBound namespace still needs its current-pin import. -/
theorem nativeResidualWords_imply_indicatorDegreeLE
    [Nonempty α] (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (d : ℕ)
    (hzero : ∀ S : Finset ι, d < S.card →
      iterNativeResidual p S.toList f = fun _ => 0) :
    HasIndicatorDegreeLE f d :=
  esDegreeLE_implies_indicatorDegreeLE p hp1 f d
    (nativeResidualWords_imply_ESDegreeLE p f d hzero)

#print axioms Nightfall.InfinitePiAllDegreeFiniteResidualBridge.nativeHeatBath_ignore
#print axioms Nightfall.InfinitePiAllDegreeFiniteResidualBridge.esComp_nativeResidual
#print axioms Nightfall.InfinitePiAllDegreeFiniteResidualBridge.esComp_iterNativeResidual
#print axioms Nightfall.InfinitePiAllDegreeFiniteResidualBridge.nativeResidualWords_imply_ESDegreeLE
#print axioms Nightfall.InfinitePiAllDegreeFiniteResidualBridge.nativeResidualWords_imply_indicatorDegreeLE

end Nightfall.InfinitePiAllDegreeFiniteResidualBridge
