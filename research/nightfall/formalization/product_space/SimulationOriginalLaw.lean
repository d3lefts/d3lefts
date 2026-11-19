import ActualProductMergeTower

/-!
# Exact finite-product query restriction identities

Finite, possibly heterogeneous marginal *weights* on a common alphabet.
All expectations are original-product sums, so arbitrarily small and zero
atom masses are permitted. The refresh energy is twice the usual
conditional-resampling influence.
This is a semantic bridge, not an assumed stochastic independence axiom.
-/

namespace Nightfall.QuerySimulation.OriginalLaw

open Finset Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type*} [Fintype ι] [DecidableEq ι] [Fintype α]

noncomputable def pin (f : (ι → α) → ℝ) (j : ι) (a : α) :
    (ι → α) → ℝ :=
  fun x => f (Function.update x j a)

noncomputable def refreshEnergy (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (i : ι) (x : ι → α) : ℝ :=
  ∑ z : ι → α, originalMass p z *
    (f x - f (Function.update x i (z i))) ^ 2

noncomputable def doubleInfluence (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  ∑ x : ι → α, originalMass p x * refreshEnergy p f i x

/-- The literal original-source merge with only coordinate j refreshed
is exactly one coordinate update, for any finite product alphabet. -/
theorem keep_erase_eq_update (j : ι) (x y : ι → α) :
    keepSource (Finset.univ.erase j) x y =
      Function.update x j (y j) := by
  funext i
  by_cases hi : i = j
  · subst i
    simp [keepSource]
  · simp [keepSource, hi]

/-- Exact finite-product tower for a random query value. No assumption
that atoms are bounded away from zero; only normalization is used. -/
theorem source_pin_tower (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ι) (F : (ι → α) → ℝ) :
    (∑ x : ι → α, originalMass p x *
      (∑ y : ι → α, originalMass p y *
        F (Function.update x j (y j)))) =
      ∑ x : ι → α, originalMass p x * F x := by
  simpa only [keep_erase_eq_update] using
    (actual_product_merge_tower p hp1 (Finset.univ.erase j) F)

/-- Independent sample ordering can be exchanged for the pinned source. -/
theorem pin_swap_sums (p : ι → α → ℝ)
    (j : ι) (F : (ι → α) → ℝ) :
    (∑ y : ι → α, originalMass p y *
      (∑ x : ι → α, originalMass p x *
        F (Function.update x j (y j)))) =
    (∑ x : ι → α, originalMass p x *
      (∑ y : ι → α, originalMass p y *
        F (Function.update x j (y j)))) := by
  calc
    _ = ∑ y : ι → α, ∑ x : ι → α,
        originalMass p y * (originalMass p x *
          F (Function.update x j (y j))) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
    _ = ∑ x : ι → α, ∑ y : ι → α,
        originalMass p y * (originalMass p x *
          F (Function.update x j (y j))) := Finset.sum_comm
    _ = ∑ x : ι → α, ∑ y : ι → α,
        originalMass p x * (originalMass p y *
          F (Function.update x j (y j))) := by
          apply Finset.sum_congr rfl
          intro x _
          apply Finset.sum_congr rfl
          intro y _
          ring
    _ = _ := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]

theorem update_update_comm (i j : ι) (hij : i ≠ j)
    (x : ι → α) (a b : α) :
    Function.update (Function.update x i a) j b =
    Function.update (Function.update x j b) i a := by
  funext k
  by_cases hki : k = i
  · subst k
    simp [Function.update_apply, hij, Ne.symm hij]
  · by_cases hkj : k = j
    · subst k
      simp [Function.update_apply, hij, Ne.symm hij]
    · simp [Function.update_apply, hki, hkj]

/-- A query at j commutes with an independent heat-bath refresh at i. -/
theorem refreshEnergy_pin_other (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (i j : ι) (hij : i ≠ j)
    (a : α) (x : ι → α) :
    refreshEnergy p (pin f j a) i x =
      refreshEnergy p f i (Function.update x j a) := by
  unfold refreshEnergy pin
  apply Finset.sum_congr rfl
  intro z _
  rw [update_update_comm i j hij x (z i) a]

/-- Fixing j annihilates exactly its own conditional resampling energy. -/
theorem doubleInfluence_pin_self (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (j : ι) (a : α) :
    doubleInfluence p (pin f j a) j = 0 := by
  unfold doubleInfluence refreshEnergy pin
  simp

/-- Exact expected survival of every *other* original-source influence
after querying j. This is the load-bearing nonuniform-query lemma. -/
theorem doubleInfluence_pin_other_expectation
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (i j : ι) (hij : i ≠ j) :
    (∑ y : ι → α, originalMass p y *
      doubleInfluence p (pin f j (y j)) i) =
      doubleInfluence p f i := by
  unfold doubleInfluence
  calc
    _ = ∑ y : ι → α, originalMass p y *
          (∑ x : ι → α, originalMass p x *
            refreshEnergy p f i (Function.update x j (y j))) := by
          apply Finset.sum_congr rfl
          intro y _
          congr 1
          apply Finset.sum_congr rfl
          intro x _
          rw [refreshEnergy_pin_other p f i j hij (y j) x]
    _ = ∑ x : ι → α, originalMass p x *
          (∑ y : ι → α, originalMass p y *
            refreshEnergy p f i (Function.update x j (y j))) :=
          pin_swap_sums p j (refreshEnergy p f i)
    _ = ∑ x : ι → α, originalMass p x * refreshEnergy p f i x :=
          source_pin_tower p hp1 j (refreshEnergy p f i)


/-- The total original-law double influence (twice J). -/
noncomputable def totalDoubleInfluence (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) : ℝ :=
  ∑ i : ι, doubleInfluence p f i

/-- Exact expected total-potential decrement for any queried site.
No lower probability bound and no uniformity of coordinate weights.
This is an equality of genuine original-law expectations. -/
theorem totalDoubleInfluence_pin_expectation
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (j : ι) :
    (∑ y : ι → α, originalMass p y *
      totalDoubleInfluence p (pin f j (y j))) =
    totalDoubleInfluence p f - doubleInfluence p f j := by
  have hsplit (u : ι → ℝ) :
      (∑ i : ι, if i = j then (0 : ℝ) else u i) =
        (∑ i : ι, u i) - u j := by
    have hsum :
        (∑ i : ι, ((if i = j then (0 : ℝ) else u i) +
          (if i = j then u j else 0))) = ∑ i : ι, u i := by
      apply Finset.sum_congr rfl
      intro i _
      by_cases hi : i = j <;> simp [hi]
    rw [Finset.sum_add_distrib] at hsum
    have hsingle : (∑ i : ι, if i = j then u j else 0) = u j := by
      simp
    rw [hsingle] at hsum
    linarith
  calc
    (∑ y : ι → α, originalMass p y *
        totalDoubleInfluence p (pin f j (y j))) =
      ∑ y : ι → α, ∑ i : ι,
        originalMass p y * doubleInfluence p (pin f j (y j)) i := by
          unfold totalDoubleInfluence
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
    _ = ∑ i : ι, ∑ y : ι → α,
        originalMass p y * doubleInfluence p (pin f j (y j)) i := Finset.sum_comm
    _ = ∑ i : ι, if i = j then 0 else doubleInfluence p f i := by
          apply Finset.sum_congr rfl
          intro i _
          by_cases hi : i = j
          · subst i
            simp [doubleInfluence_pin_self]
          · rw [if_neg hi]
            exact doubleInfluence_pin_other_expectation p hp1 f i j hi
    _ = totalDoubleInfluence p f - doubleInfluence p f j := by
          simpa only [totalDoubleInfluence] using hsplit (fun i => doubleInfluence p f i)

end Nightfall.QuerySimulation.OriginalLaw
