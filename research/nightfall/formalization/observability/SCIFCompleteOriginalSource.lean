import SCIFFullCanonicalOwner
import SCIFGraphLocality
import SCIFActualRiskTerminal
import SCIFDegreeTransport

/-!
# NIGHTFALL SCIF: integrated exact finite-source recertification theorem

One kernel declaration, original f and genuine original product source p.
A one-coordinate law edit at k preserves Efron-Stein degree and the
pointwise interaction graph; actual new-law canonical pair projectors
are repaired from the old source; true sourceInfluence updates are
exact signed old-law integrals and are zero off the old canonical
neighborhood; the all-degree changed-law variance certificate and
the fixed-owner *new canonical pair* amplitude/cost repair coexist.

The only external certificate inputs here are the original degree-two
hypothesis and the original source-derived pair amplitude owner bound.
No new-source degree/influence table, positive atom floor, or
unverified projection oracle is assumed.

Scope: finite products, common finite alphabet, exact product laws,
immutable pointwise f, one authenticated-in-the-model law edit.
Excluded: physical source attestation, optimal computation complexity,
alternative verification oracles and effect-time enforcement.
-/
namespace Nightfall.SCIFCompleteOriginalSource

open Finset
open Nightfall.SCIF
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.SCIFExactTableTransport
open Nightfall.SCIFFullCanonicalOwner
open Nightfall.SCIFLocalSourceInfluence
open Nightfall.SCIFGraphLocality
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.SCIFActualInfluence
open Nightfall.Observability.SCIFSourceGraph
open Nightfall.Observability.SCIFDegreeTransport
open Nightfall.Observability.SCIFActualRiskTerminal

variable {ι α E V : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]
  [Fintype E] [Fintype V]

/-- Integrated terminal for the genuine original f and product source.
The bounded owner component is on the actual new canonical pair, not
an auxiliary synthetic interaction table. -/
theorem scif_complete_finite_original_source_terminal
    (p : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (k : ι) (q : α → ℝ)
    (hq0 : ∀ a, 0 ≤ q a)
    (hq1 : (∑ a : α, q a) = 1)
    (neighbor : E → ι)
    (hkj : ∀ e : E, k ≠ neighbor e)
    (owner : E → V)
    (c : V → ℝ) (C : ℝ)
    (hc : ∀ v, 0 ≤ c v)
    (hcover : ∀ e a b,
      |sourceDoubleCenteredPair p f k (neighbor e) a b| ≤ c (owner e))
    (hcost : (∑ v : V, c v) ≤ C) :
    ESDegreeLE (editLaw p k q) f 2 ∧
    (∀ i j : ι, i ≠ j →
      (HasCanonicalPairRectangle p f i j ↔
       HasCanonicalPairRectangle (editLaw p k q) f i j)) ∧
    (∀ j : ι, k ≠ j → ∀ x : ι → α,
      esComp (editLaw p k q) ({k,j} : Finset ι) f x =
        esComp p ({k,j} : Finset ι) f x -
          ∑ a : α, q a *
            esComp p ({k,j} : Finset ι) f
              (Function.update x k a)) ∧
    (∀ j : ι, k ≠ j →
      sourceInfluence (editLaw p k q) f j -
        sourceInfluence p f j =
      ∑ x : ι → α, originalMass p x *
        (∑ a : α, (q a - p k a) *
          (residual p f j (Function.update x k a))^2)) ∧
    (∀ j : ι, k ≠ j →
      (∀ x : ι → α,
        esComp p ({k,j} : Finset ι) f x = 0) →
      sourceInfluence (editLaw p k q) f j =
        sourceInfluence p f j) ∧
    (∀ t : ι, sourceInfluence (editLaw p k q) f t =
      sourceInfluence p f t +
        influenceShift p (editLaw p k q) f t) ∧
    (sourceVariance (editLaw p k q) f ≤
      ∑ t : ι,
        (sourceInfluence p f t +
          influenceShift p (editLaw p k q) f t)) ∧
    ((∀ e a b,
      |sourceDoubleCenteredPair (editLaw p k q) f
        k (neighbor e) a b| ≤
        (1 + min (∑ u : α, |q u - p k u|) 1) * c (owner e)) ∧
     (∑ v : V,
      (1 + min (∑ u : α, |q u - p k u|) 1) * c v) ≤
        (1 + min (∑ u : α, |q u - p k u|) 1) * C) := by
  have hn : ∀ i, (∑ a : α, editLaw p k q i a) = 1 :=
    editLaw_normalized p hp1 k q hq1
  have h0 : ∀ i a, 0 ≤ editLaw p k q i a := by
    intro i a
    by_cases hi : i = k
    · simpa [editLaw, hi] using hq0 a
    · simpa [editLaw, hi] using hp0 i a
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact degree_two_preserved_by_any_law
      p (editLaw p k q) hp1 f hdegree
  · intro i j hij
    exact canonical_pair_graph_invariant_after_any_law_change
      p (editLaw p k q) hp1 hn f hdegree i j hij
  · intro j hj x
    exact source_canonical_pair_recenter_unconditional
      p hp1 f k j hj q hq1 x
  · intro j hj
    exact actual_influence_change_as_single_coordinate_integral
      p hp1 f k j hj q
  · intro j hj hzero
    exact actual_influence_unchanged_outside_canonical_neighborhood
      p hp1 f hdegree k j hj q hq1 hzero
  · intro t
    exact source_actual_influence_transport p (editLaw p k q) f t
  · exact source_variance_recertified_all_degree
      p (editLaw p k q) h0 hn f
  · exact canonical_owner_full_cost_repair
      p hp1 f k q hq0 hq1 neighbor hkj owner c C hc hcover hcost

end Nightfall.SCIFCompleteOriginalSource
