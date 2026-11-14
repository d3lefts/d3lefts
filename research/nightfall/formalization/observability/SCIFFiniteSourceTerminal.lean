import SCIFActualRiskTerminal
import SCIFDegreeTransport
import SCIFClipped
import ActualProductSourcePairCentering

/-!
# SCIF finite-source structural/risk and owner recertification bundle

Formalizes source-derived degree, canonical graph, true influence, risk,
and a quantitative fixed-owner repair for the recentered original pair.
The step identifying this recentered pair with the NEW canonical pair
for an arbitrary f is separately open. No physical source trust claim.
-/
namespace Nightfall.Observability.SCIFFiniteSourceTerminal
open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.SCIFSourceGraph
open Nightfall.Observability.SCIFDegreeTransport
open Nightfall.Observability.SCIFActualRiskTerminal
open Nightfall.SCIF

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

theorem actual_source_structure_and_risk_recertification
    (p r : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hr0 : ∀ i a, 0 ≤ r i a)
    (hr1 : ∀ i, (∑ a : α, r i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i j : ι) (hij : i ≠ j) :
    ESDegreeLE r f 2 ∧
    (HasCanonicalPairRectangle p f i j ↔
      HasCanonicalPairRectangle r f i j) ∧
    (∀ k : ι, sourceInfluence r f k =
      sourceInfluence p f k + influenceShift p r f k) ∧
    sourceVariance r f ≤
      ∑ k : ι, (sourceInfluence p f k + influenceShift p r f k) := by
  refine ⟨degree_two_preserved_by_any_law p r hp1 f hdegree, ?_, ?_, ?_⟩
  · exact canonical_pair_graph_invariant_after_any_law_change
      p r hp1 hr1 f hdegree i j hij
  · intro k
    exact source_actual_influence_transport p r f k
  · exact source_variance_recertified_all_degree p r hr0 hr1 f

variable {E V : Type} [Fintype E] [Fintype V]

theorem source_owned_pair_cover_after_single_law_edit
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq0 : ∀ a, 0 ≤ q a)
    (hq1 : (∑ a : α, q a) = 1)
    (neighbor : E → ι)
    (owner : E → V)
    (c : V → ℝ)
    (hc : ∀ v, 0 ≤ c v)
    (hcover : ∀ e a b,
      |sourceDoubleCenteredPair p f k (neighbor e) a b| ≤ c (owner e)) :
    ∀ e a b,
      |pairRecenter q
        (sourceDoubleCenteredPair p f k (neighbor e)) a b| ≤
        (1 + min (∑ z : α, |q z - p k z|) 1) * c (owner e) := by
  let H : E → α → α → ℝ :=
    fun e a b => sourceDoubleCenteredPair p f k (neighbor e) a b
  have hz : ∀ e : E, ∀ b : α,
      (∑ a : α, p k a * H e a b) = 0 := by
    intro e b
    exact actual_source_derived_pair_first_centered
      p hp1 f k (neighbor e) b
  have hbound : ∀ e a b, |H e a b| ≤ c (owner e) := by
    intro e a b
    exact hcover e a b
  exact fixed_owner_recenter_cover_clipped (p k) q
    owner H c hc hq0 hq1 hz hbound

def editLaw (p : ι → α → ℝ) (k : ι) (q : α → ℝ) : ι → α → ℝ :=
  fun i a => if i = k then q a else p i a

theorem editLaw_normalized
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (k : ι) (q : α → ℝ)
    (hq1 : (∑ a : α, q a) = 1) :
    ∀ i, (∑ a : α, editLaw p k q i a) = 1 := by
  intro i
  by_cases hi : i = k
  · simpa [editLaw, hi] using hq1
  · simpa [editLaw, hi] using hp1 i

theorem editLaw_nonnegative
    (p : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a)
    (k : ι) (q : α → ℝ)
    (hq0 : ∀ a, 0 ≤ q a) :
    ∀ i a, 0 ≤ editLaw p k q i a := by
  intro i a
  by_cases hi : i = k
  · simpa [editLaw, hi] using hq0 a
  · simpa [editLaw, hi] using hp0 i a

theorem single_source_edit_structural_risk_terminal
    (p : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (k : ι) (q : α → ℝ)
    (hq0 : ∀ a, 0 ≤ q a)
    (hq1 : (∑ a : α, q a) = 1)
    (i j : ι) (hij : i ≠ j) :
    ESDegreeLE (editLaw p k q) f 2 ∧
    (HasCanonicalPairRectangle p f i j ↔
      HasCanonicalPairRectangle (editLaw p k q) f i j) ∧
    (∀ t : ι, sourceInfluence (editLaw p k q) f t =
      sourceInfluence p f t + influenceShift p (editLaw p k q) f t) ∧
    sourceVariance (editLaw p k q) f ≤
      ∑ t : ι,
        (sourceInfluence p f t + influenceShift p (editLaw p k q) f t) := by
  exact actual_source_structure_and_risk_recertification p
    (editLaw p k q) hp1
    (editLaw_nonnegative p hp0 k q hq0)
    (editLaw_normalized p hp1 k q hq1)
    f hdegree i j hij

theorem fixed_owner_source_edit_total
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq0 : ∀ a, 0 ≤ q a)
    (hq1 : (∑ a : α, q a) = 1)
    (neighbor : E → ι) (owner : E → V)
    (c : V → ℝ) (C : ℝ)
    (hc : ∀ v, 0 ≤ c v)
    (hcover : ∀ e a b,
      |sourceDoubleCenteredPair p f k (neighbor e) a b| ≤ c (owner e))
    (hcost : (∑ v : V, c v) ≤ C) :
    (∀ e a b,
      |pairRecenter q
        (sourceDoubleCenteredPair p f k (neighbor e)) a b| ≤
        (1 + min (∑ z : α, |q z - p k z|) 1) * c (owner e)) ∧
    (∑ v : V,
       (1 + min (∑ z : α, |q z - p k z|) 1) * c v) ≤
      (1 + min (∑ z : α, |q z - p k z|) 1) * C := by
  constructor
  · exact source_owned_pair_cover_after_single_law_edit
      p hp1 f k q hq0 hq1 neighbor owner c hc hcover
  · exact fixed_owner_clipped_total_cost (p k) q c C hcost

end Nightfall.Observability.SCIFFiniteSourceTerminal
