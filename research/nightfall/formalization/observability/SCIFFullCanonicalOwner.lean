import SCIFExactTableTransport
import SCIFClipped

/-!
# SCIF full canonical source-owned pair repair

The new-law genuine canonical pair projector equals the old-law pair
recentered in the edited coordinate, directly from arbitrary original
f and literal original product mass. Unlike the preliminary SCIF
table-layer certificate, the resulting bounded owner cover is for
the ACTUAL new-law canonical pair of f.

No degree assumption, mass positivity floor, or external table
transport hypothesis. Each source edge is a distinct ordered pair
(k,neighbor e), and the unchanged owner assignment is supplied as
a finite certificate with an old-law amplitude envelope.
-/

namespace Nightfall.SCIFFullCanonicalOwner
open Finset
open Nightfall.SCIF
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.SCIFExactTableTransport
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceANOVA

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Actual full-source two-site kernel after k law change is exactly
its original-source q-centered repair. All symbols, including original
or new zero-probability atoms, are covered pointwise. -/
theorem source_canonical_derived_pair_recenter_exact
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (a b : α) :
    sourceDoubleCenteredPair (editLaw p k q) f k j a b =
      pairRecenter q (sourceDoubleCenteredPair p f k j) a b := by
  classical
  have ht :
      sourceTwoSiteTable (editLaw p k q) f k j =
        sourceTwoSiteTable p f k j := by
    funext u v
    exact source_two_site_table_invariant_under_first_law_edit
      p hp1 f k j hkj q hq1 u v
  have hk : (editLaw p k q) k = q := by
    funext u
    simp [editLaw]
  have hj : (editLaw p k q) j = p j := by
    funext u
    simp [editLaw, Ne.symm hkj]
  unfold sourceDoubleCenteredPair
  rw [ht, hk, hj]
  exact doubleCenter_retarget_first
    (p k) q (p j) hq1 (sourceTwoSiteTable p f k j) a b

variable {E V : Type} [Fintype E] [Fintype V]

/-- Real canonical new-law pair amplitude certificate with the same
old owner assignment and sharp clipped L1 multiplier. No new pair
energies are assumed. -/
theorem actual_new_source_pair_fixed_owner_cover
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq0 : ∀ a, 0 ≤ q a)
    (hq1 : (∑ a : α, q a) = 1)
    (neighbor : E → ι)
    (hkj : ∀ e : E, k ≠ neighbor e)
    (owner : E → V)
    (c : V → ℝ)
    (hc : ∀ v, 0 ≤ c v)
    (hcover : ∀ e a b,
      |sourceDoubleCenteredPair p f k (neighbor e) a b| ≤ c (owner e)) :
    ∀ e a b,
      |sourceDoubleCenteredPair (editLaw p k q) f
        k (neighbor e) a b| ≤
        (1 + min (∑ u : α, |q u - p k u|) 1) * c (owner e) := by
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
  have ht := fixed_owner_recenter_cover_clipped
    (p k) q owner H c hc hq0 hq1 hz hbound
  intro e a b
  rw [source_canonical_derived_pair_recenter_exact
    p hp1 f k (neighbor e) (hkj e) q hq1 a b]
  exact ht e a b

/-- The unchanged owner assignment gives a globally bounded new-law
canonical pair amplitude certificate, with exact rather than guessed
recalibration cost. -/
theorem canonical_owner_full_cost_repair
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
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
    (∀ e a b,
      |sourceDoubleCenteredPair (editLaw p k q) f
        k (neighbor e) a b| ≤
        (1 + min (∑ u : α, |q u - p k u|) 1) * c (owner e)) ∧
    (∑ v : V,
      (1 + min (∑ u : α, |q u - p k u|) 1) * c v) ≤
        (1 + min (∑ u : α, |q u - p k u|) 1) * C := by
  constructor
  · exact actual_new_source_pair_fixed_owner_cover
      p hp1 f k q hq0 hq1 neighbor hkj owner c hc hcover
  · exact fixed_owner_clipped_total_cost (p k) q c C hcost

end Nightfall.SCIFFullCanonicalOwner
