import SCIFRecenter
import ActualSourceCanonicalIdentification
import ActualSourceInfluenceEnergy
import ActualProductPairSector

/-!
# SCIF canonical source bridge (genuine finite product law)

Connects SCIF's weighted pair recentering to the repository's *actual*
Efron–Stein pair projector of f, and to actual sourceInfluence.

No source atom lower bound is used. The general-table source theorem
requires explicit sourceTwoSiteTable transport; it is discharged below
for genuine two-coordinate observables, but not yet for arbitrary
degree-two f with all its other interactions.
-/

namespace Nightfall.SCIFCanonicalSourceBridge

open Finset
open Nightfall.SCIF
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceCanonicalIdentification
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualProductPairSector

variable {α : Type} [Fintype α] [DecidableEq α]

/-- The actual bivariate double-centering is a first-site recentering
of the second-site centered table. All sums are over actual finite
symbol alphabets, with no positivity or probability assumptions. -/
theorem doubleCenter_as_first_recenter
    (q r : α → ℝ) (F : α → α → ℝ) (a b : α) :
    doubleCenter q r F a b =
      pairRecenter q
        (fun u v => F u v - ∑ z : α, r z * F u z) a b := by
  classical
  unfold doubleCenter pairRecenter firstMean
  simp only [mul_sub, Finset.sum_sub_distrib]
  ring

/-- Two successive first-coordinate recenterings collapse to the last
normalized source law, irrespective of the previous law. -/
theorem pairRecenter_retarget
    (p q : α → ℝ) (hq : (∑ a : α, q a) = 1)
    (H : α → α → ℝ) (a b : α) :
    pairRecenter q (pairRecenter p H) a b =
      pairRecenter q H a b := by
  classical
  have hm :
      firstMean q (pairRecenter p H) b =
      firstMean q H b - firstMean p H b := by
    unfold firstMean pairRecenter
    simp only [mul_sub, Finset.sum_sub_distrib]
    rw [← Finset.sum_mul, hq]
    simp only [firstMean]
    ring
  change H a b - firstMean p H b -
      firstMean q (pairRecenter p H) b =
    H a b - firstMean q H b
  rw [hm]
  ring

/-- Exact source-law transport of a centered pair table, with no
restriction on the old probability weights or original symbols. -/
theorem doubleCenter_retarget_first
    (p q r : α → ℝ) (hq : (∑ a : α, q a) = 1)
    (F : α → α → ℝ) (a b : α) :
    doubleCenter q r F a b =
      pairRecenter q (doubleCenter p r F) a b := by
  rw [doubleCenter_as_first_recenter,
      show doubleCenter p r F =
        pairRecenter p
          (fun u v => F u v - ∑ z : α, r z * F u z) from
        funext (fun u => funext (fun v =>
          doubleCenter_as_first_recenter p r F u v))]
  exact (pairRecenter_retarget p q hq
    (fun u v => F u v - ∑ z : α, r z * F u z) a b).symm

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- Editing only one coordinate of the original product source. -/
def editLaw (p : ι → α → ℝ) (k : ι) (q : α → ℝ) : ι → α → ℝ :=
  fun i a => if i = k then q a else p i a

theorem editLaw_normalized
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (k : ι) (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1) :
    ∀ i, (∑ a : α, editLaw p k q i a) = 1 := by
  intro i
  by_cases hi : i = k
  · simpa [editLaw, hi] using hq1
  · simpa [editLaw, hi] using hp1 i

/-- An actual two-coordinate observable has an exact source-extracted
pair table equal to its literal pointwise table, regardless of
nonuniform and zero-probability original source atoms. -/
theorem actual_pair_table_of_pair_observable
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (k j : ι) (hkj : k ≠ j)
    (F : α → α → ℝ) (a b : α) :
    sourceTwoSiteTable p
       (fun z : ι → α => F (z k) (z j)) k j a b =
      F a b := by
  classical
  have hpoint (y : ι → α) :
      F ((Function.update (Function.update y k a) j b) k)
        ((Function.update (Function.update y k a) j b) j) = F a b := by
    simp [hkj]
  unfold sourceTwoSiteTable
  simp_rw [hpoint]
  rw [← Finset.sum_mul, originalMass_total_one p hp1, one_mul]

/-- General exact canonical pair transport assuming equality of the
genuine source-derived 2-site conditional tables before/after edit.
The conclusion refers to actual esComp, not a free synthetic kernel.
The table-transport condition is discharged for pair-observables below.
-/
theorem canonical_pair_recenter_of_table_transport
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (hTable : ∀ a b : α,
       sourceTwoSiteTable (editLaw p k q) f k j a b =
       sourceTwoSiteTable p f k j a b)
    (x : ι → α) :
    esComp (editLaw p k q) ({k,j} : Finset ι) f x =
      esComp p ({k,j} : Finset ι) f x -
        ∑ a : α, q a *
          esComp p ({k,j} : Finset ι) f
            (Function.update x k a) := by
  classical
  let p' := editLaw p k q
  have hp'1 := editLaw_normalized p hp1 k q hq1
  have hqp : p' k = q := by
    funext a
    simp [p', editLaw]
  have hrp : p' j = p j := by
    funext a
    simp [p', editLaw, Ne.symm hkj]
  let F := sourceTwoSiteTable p f k j
  have hFt : sourceTwoSiteTable p' f k j = F := by
    funext a b
    exact hTable a b
  have htransport (a b : α) :
      sourceDoubleCenteredPair p' f k j a b =
        pairRecenter q (sourceDoubleCenteredPair p f k j) a b := by
    dsimp [sourceDoubleCenteredPair]
    rw [hFt, hqp, hrp]
    exact doubleCenter_retarget_first (p k) q (p j) hq1 F a b
  rw [actual_source_esComp_pair_eq_derived p' hp'1 f k j hkj x,
      actual_source_esComp_pair_eq_derived p hp1 f k j hkj x,
      htransport]
  unfold pairRecenter firstMean
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  rw [actual_source_esComp_pair_eq_derived p hp1 f k j hkj
      (Function.update x k a)]
  rw [Function.update_same]
  rw [Function.update_of_ne (Ne.symm hkj) a x]

/-- Fully source-derived canonical pair repair for an actual bounded
or unbounded two-coordinate observable; no independent hTable oracle.
A general degree-two f needs a further all-interaction source-table
transport lemma and is NOT asserted by this declaration. -/
theorem canonical_pair_recenter_actual_pair
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (F : α → α → ℝ) (x : ι → α) :
    esComp (editLaw p k q) ({k,j} : Finset ι)
        (fun z : ι → α => F (z k) (z j)) x =
      esComp p ({k,j} : Finset ι)
        (fun z : ι → α => F (z k) (z j)) x -
        ∑ a : α, q a *
          esComp p ({k,j} : Finset ι)
            (fun z : ι → α => F (z k) (z j))
            (Function.update x k a) := by
  apply canonical_pair_recenter_of_table_transport
    p hp1 _ k j hkj q hq1 _ x
  intro a b
  rw [actual_pair_table_of_pair_observable
    (editLaw p k q) (editLaw_normalized p hp1 k q hq1)
    k j hkj F a b]
  rw [actual_pair_table_of_pair_observable p hp1 k j hkj F a b]

/-- The true sourceInfluence of a two-coordinate function is the
literal, source-weighted conditional variance of its pair table.
This uses actual originalMass, not a supplied energy oracle. -/
theorem actual_sourceInfluence_pair_eq_table
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (k j : ι) (hkj : k ≠ j)
    (F : α → α → ℝ) :
    sourceInfluence p (fun z : ι → α => F (z k) (z j)) j =
      ∑ a : α, ∑ b : α,
         p k a * p j b *
          (F a b - ∑ c : α, p j c * F a c)^2 := by
  classical
  unfold sourceInfluence
  have heq (x : ι → α) :
      (F (x k) (x j) -
        ∑ c : α, p j c *
          F ((Function.update x j c) k)
            ((Function.update x j c) j))^2 =
      (F (x k) (x j) -
        ∑ c : α, p j c * F (x k) c)^2 := by
    simp [hkj]
  calc
    (∑ x : ι → α, originalMass p x *
      (F (x k) (x j) -
        ∑ c : α, p j c *
          F ((Function.update x j c) k)
            ((Function.update x j c) j))^2) =
      ∑ x : ι → α, originalMass p x *
        (F (x k) (x j) -
          ∑ c : α, p j c * F (x k) c)^2 := by
            apply Finset.sum_congr rfl
            intro x _
            rw [heq x]
    _ = _ := actual_product_two_site_marginal p hp1 k j hkj
       (fun a b => (F a b - ∑ c : α, p j c * F a c)^2)

/-- Exact same-source influence change in an untouched neighbor j
after law k is edited. The right side is an entirely local
weighted-table identity: no asymptotic approximation or atom floor. -/
theorem actual_sourceInfluence_neighbor_update_pair
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (F : α → α → ℝ) :
    sourceInfluence (editLaw p k q)
       (fun z : ι → α => F (z k) (z j)) j -
    sourceInfluence p
       (fun z : ι → α => F (z k) (z j)) j =
      ∑ a : α, (q a - p k a) *
        (∑ b : α, p j b *
          (F a b - ∑ c : α, p j c * F a c)^2) := by
  classical
  let p' := editLaw p k q
  have hp'1 := editLaw_normalized p hp1 k q hq1
  rw [actual_sourceInfluence_pair_eq_table p' hp'1 k j hkj F,
      actual_sourceInfluence_pair_eq_table p hp1 k j hkj F]
  have hk : p' k = q := by
    funext a; simp [p', editLaw]
  have hj : p' j = p j := by
    funext a; simp [p', editLaw, Ne.symm hkj]
  rw [hk, hj]
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro a _
  calc
    (∑ b : α, q a * p j b *
        (F a b - ∑ c : α, p j c * F a c)^2) -
      (∑ b : α, p k a * p j b *
        (F a b - ∑ c : α, p j c * F a c)^2) =
      ∑ b : α, (q a - p k a) *
        (p j b * (F a b - ∑ c : α, p j c * F a c)^2) := by
        rw [← Finset.sum_sub_distrib]
        apply Finset.sum_congr rfl
        intro b _
        ring
    _ = (q a - p k a) *
        (∑ b : α, p j b *
          (F a b - ∑ c : α, p j c * F a c)^2) := by
        rw [Finset.mul_sum]

end Nightfall.SCIFCanonicalSourceBridge
