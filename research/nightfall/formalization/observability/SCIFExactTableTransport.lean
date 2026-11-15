import SCIFCanonicalSourceBridge

/-!
# SCIF fully source-derived two-site table transport after a law edit

Exact finite product measure change via a reversible coordinate swap
between original-world and fresh-symbol pairs. Proves that a two-site
conditional table *fixing* k,j is independent of the marginal p_k;
hence the genuine canonical order-two Mobius projector of arbitrary f
is given by the exact SCIF recentering formula.

No degree-two premise and no positivity/atom-floor premise is needed
for these algebraic transport identities.
-/

namespace Nightfall.SCIFExactTableTransport

open Finset
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourceANOVA

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exchange the actual symbol at coordinate k with a fresh symbol. -/
def swapCoordinate (k : ι) :
    ((ι → α) × α) ≃ ((ι → α) × α) where
  toFun z := (Function.update z.1 k z.2, z.1 k)
  invFun z := (Function.update z.1 k z.2, z.1 k)
  left_inv := by
    rintro ⟨x, a⟩
    apply Prod.ext
    · funext i
      by_cases hi : i = k
      · subst i
        simp
      · simp [Function.update_of_ne hi]
    · simp
  right_inv := by
    rintro ⟨x, a⟩
    apply Prod.ext
    · funext i
      by_cases hi : i = k
      · subst i
        simp
      · simp [Function.update_of_ne hi]
    · simp

/-- Swapping k and the fresh symbol transfers exactly the product
weight from edited source to original source, without division by p_k. -/
theorem swap_source_weight
    (p : ι → α → ℝ) (k : ι) (q : α → ℝ)
    (x : ι → α) (a : α) :
    originalMass (editLaw p k q) x * p k a =
      originalMass p (Function.update x k a) * q (x k) := by
  classical
  unfold originalMass
  calc
    (∏ i : ι, editLaw p k q i (x i)) * p k a =
        ∏ i : ι, (editLaw p k q i (x i)) *
          (if i = k then p k a else (1 : ℝ)) := by
            rw [Finset.prod_mul_distrib]
            simp
    _ = ∏ i : ι, p i ((Function.update x k a) i) *
          (if i = k then q (x k) else (1 : ℝ)) := by
            apply Finset.prod_congr rfl
            intro i _
            by_cases hi : i = k
            · subst i
              simp [editLaw, mul_comm]
            · have hu : (Function.update x k a) i = x i :=
                Function.update_of_ne hi a x
              simp [editLaw, hi, hu]
    _ = (∏ i : ι, p i ((Function.update x k a) i)) *
          q (x k) := by
            rw [Finset.prod_mul_distrib]
            simp

/-- An exact finite law-swap identity: resampling the edited
coordinate under the old source makes the edited full expectation
equal to the original full source expectation. -/
theorem source_law_swap_integral
    (p : ι → α → ℝ)
    (k : ι) (q : α → ℝ)
    (hq : (∑ a : α, q a) = 1)
    (F : (ι → α) → ℝ) :
    (∑ x : ι → α,
      originalMass (editLaw p k q) x *
        (∑ a : α, p k a * F (Function.update x k a))) =
    ∑ x : ι → α, originalMass p x * F x := by
  classical
  have hswap := Fintype.sum_equiv (swapCoordinate k)
    (fun z : (ι → α) × α =>
      originalMass (editLaw p k q) z.1 * p k z.2 *
        F (Function.update z.1 k z.2))
    (fun z : (ι → α) × α =>
      originalMass p z.1 * q z.2 * F z.1)
    (by
      rintro ⟨x, a⟩
      change originalMass (editLaw p k q) x * p k a *
        F (Function.update x k a) =
        originalMass p (Function.update x k a) * q (x k) *
          F (Function.update x k a)
      rw [swap_source_weight p k q x a])
  rw [Fintype.sum_prod_type, Fintype.sum_prod_type] at hswap
  calc
    (∑ x : ι → α,
      originalMass (editLaw p k q) x *
        (∑ a : α, p k a * F (Function.update x k a))) =
      ∑ x : ι → α, ∑ a : α,
        originalMass (editLaw p k q) x * p k a *
          F (Function.update x k a) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            ring
    _ = ∑ x : ι → α, ∑ a : α,
          originalMass p x * q a * F x := hswap
    _ = ∑ x : ι → α, originalMass p x * F x := by
          apply Finset.sum_congr rfl
          intro x _
          calc
            (∑ a : α, originalMass p x * q a * F x) =
              (∑ a : α, q a) * (originalMass p x * F x) := by
                rw [Finset.sum_mul]
                apply Finset.sum_congr rfl
                intro a _
                ring
            _ = originalMass p x * F x := by rw [hq]; ring

/-- Any table not depending on the old/new coordinate k has
identical source averages under the old and edited product laws. -/
theorem source_integral_invariant_if_ignores_k
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (k : ι) (q : α → ℝ)
    (hq1 : (∑ a : α, q a) = 1)
    (F : (ι → α) → ℝ)
    (hignore : ∀ x : ι → α, ∀ a : α,
      F (Function.update x k a) = F x) :
    (∑ x : ι → α,
      originalMass (editLaw p k q) x * F x) =
    ∑ x : ι → α, originalMass p x * F x := by
  classical
  calc
    (∑ x : ι → α,
      originalMass (editLaw p k q) x * F x) =
      ∑ x : ι → α, originalMass (editLaw p k q) x *
        (∑ a : α, p k a * F (Function.update x k a)) := by
          apply Finset.sum_congr rfl
          intro x _
          simp_rw [hignore x]
          rw [← Finset.sum_mul, hp1 k, one_mul]
    _ = ∑ x : ι → α, originalMass p x * F x :=
        source_law_swap_integral p k q hq1 F

/-- The actual two-site table of any observable is unaffected by
changing the marginal of either *fixed* coordinate. This theorem
discharges the table-transport premise for arbitrary f. -/
theorem source_two_site_table_invariant_under_first_law_edit
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (a b : α) :
    sourceTwoSiteTable (editLaw p k q) f k j a b =
      sourceTwoSiteTable p f k j a b := by
  classical
  unfold sourceTwoSiteTable
  apply source_integral_invariant_if_ignores_k p hp1 k q hq1
  intro y v
  congr 1
  funext i
  by_cases hi : i = k
  · subst i
    simp [hkj]
  · simp [Function.update_of_ne hi]

/-- Unrestricted actual source canonical pair recentering.
The displayed original observable f is arbitrary; its low degree
or source pair representation is not assumed. -/
theorem source_canonical_pair_recenter_unconditional
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k j : ι) (hkj : k ≠ j)
    (q : α → ℝ) (hq1 : (∑ a : α, q a) = 1)
    (x : ι → α) :
    esComp (editLaw p k q) ({k,j} : Finset ι) f x =
      esComp p ({k,j} : Finset ι) f x -
        ∑ a : α, q a *
          esComp p ({k,j} : Finset ι) f
            (Function.update x k a) := by
  apply canonical_pair_recenter_of_table_transport
    p hp1 f k j hkj q hq1 ?_ x
  intro a b
  exact source_two_site_table_invariant_under_first_law_edit
    p hp1 f k j hkj q hq1 a b

end Nightfall.SCIFExactTableTransport
