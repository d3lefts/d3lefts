import Mathlib
import ProductSphereObstruction

/-!
# Product-sphere zero-padding transfer

Proves that the single maximal pure-character topology proposition
ProductSphereZero n (n-1) (n-1) implies all smaller pure-character versions.

This is a theorem BETWEEN PROPOSITIONS, not a proof of the maximal
topological statement. The external topology premise remains explicit.
The U and V coordinates are padded by literal zeros, preserving the
two separately antipodal sign characters and continuity-on-sphere.

Sources: #1010 topology interface, #1015 main-branch conditional causal
threshold, #1017 independent alternative, #1000 non-author proof audit.
-/

namespace Nightfall.ProductSpherePadding
open Nightfall.ProductSphereObstruction

theorem productSphereZero_of_max (n p q : ℕ)
    (hmax : ProductSphereZero n (n - 1) (n - 1))
    (hp : p ≤ n - 1) (hq : q ≤ n - 1) :
    ProductSphereZero n p q := by
  intro fU fV hcU hcV hUl hUr hVl hVr
  classical
  let FU : (Fin n → ℝ) → (Fin n → ℝ) → Fin (n - 1) → ℝ :=
    fun u v i => if hi : i.val < p then fU u v ⟨i.val, hi⟩ else 0
  let FV : (Fin n → ℝ) → (Fin n → ℝ) → Fin (n - 1) → ℝ :=
    fun u v i => if hi : i.val < q then fV u v ⟨i.val, hi⟩ else 0
  have hFUcont : ∀ i, ContinuousOn
      (fun z : (Fin n → ℝ) × (Fin n → ℝ) => FU z.1 z.2 i)
      (SpherePair n) := by
    intro i
    by_cases hi : i.val < p
    · simpa [FU, hi] using hcU ⟨i.val, hi⟩
    · simpa [FU, hi] using
        (continuous_const.continuousOn :
          ContinuousOn (fun _ : (Fin n → ℝ) × (Fin n → ℝ) => (0 : ℝ))
            (SpherePair n))
  have hFVcont : ∀ i, ContinuousOn
      (fun z : (Fin n → ℝ) × (Fin n → ℝ) => FV z.1 z.2 i)
      (SpherePair n) := by
    intro i
    by_cases hi : i.val < q
    · simpa [FV, hi] using hcV ⟨i.val, hi⟩
    · simpa [FV, hi] using
        (continuous_const.continuousOn :
          ContinuousOn (fun _ : (Fin n → ℝ) × (Fin n → ℝ) => (0 : ℝ))
            (SpherePair n))
  have hFUleft : ∀ u v i, UnitVec n u → UnitVec n v →
      FU (-u) v i = -FU u v i := by
    intro u v i hu hv
    by_cases hi : i.val < p
    · simpa [FU, hi] using hUl u v ⟨i.val, hi⟩ hu hv
    · simp [FU, hi]
  have hFUright : ∀ u v i, UnitVec n u → UnitVec n v →
      FU u (-v) i = FU u v i := by
    intro u v i hu hv
    by_cases hi : i.val < p
    · simpa [FU, hi] using hUr u v ⟨i.val, hi⟩ hu hv
    · simp [FU, hi]
  have hFVleft : ∀ u v i, UnitVec n u → UnitVec n v →
      FV (-u) v i = FV u v i := by
    intro u v i hu hv
    by_cases hi : i.val < q
    · simpa [FV, hi] using hVl u v ⟨i.val, hi⟩ hu hv
    · simp [FV, hi]
  have hFVright : ∀ u v i, UnitVec n u → UnitVec n v →
      FV u (-v) i = -FV u v i := by
    intro u v i hu hv
    by_cases hi : i.val < q
    · simpa [FV, hi] using hVr u v ⟨i.val, hi⟩ hu hv
    · simp [FV, hi]
  obtain ⟨u, v, hu, hv, hzU, hzV⟩ :=
    hmax FU FV hFUcont hFVcont hFUleft hFUright hFVleft hFVright
  refine ⟨u, v, hu, hv, ?_, ?_⟩
  · intro i
    have hi : (i.val : ℕ) < p := i.isLt
    have hbound : (i.val : ℕ) < n - 1 := lt_of_lt_of_le i.isLt hp
    simpa [FU, hi] using hzU ⟨i.val, hbound⟩
  · intro i
    have hi : (i.val : ℕ) < q := i.isLt
    have hbound : (i.val : ℕ) < n - 1 := lt_of_lt_of_le i.isLt hq
    simpa [FV, hi] using hzV ⟨i.val, hbound⟩

theorem productSphereZero_all_subcritical (n : ℕ)
    (hmax : ProductSphereZero n (n - 1) (n - 1)) :
    ∀ p q : ℕ, p < n → q < n → ProductSphereZero n p q := by
  intro p q hp hq
  exact productSphereZero_of_max n p q hmax (by omega) (by omega)

#print productSphereZero_of_max
#print axioms productSphereZero_of_max
#print productSphereZero_all_subcritical
#print axioms productSphereZero_all_subcritical

end Nightfall.ProductSpherePadding
