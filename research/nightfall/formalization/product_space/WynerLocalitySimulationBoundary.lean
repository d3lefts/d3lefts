import WynerLocalityInformation

/-!
# Locality obstruction: explicit product mixtures versus query simulation

The first group transfers a certified Wyner lower bound to a lower bound on
the number of states in any exact finite product-mixture representation.
The second group transfers a product-law query simulation through pointwise
density domination. Neither assertion is a lower bound on arbitrary
decision trees or on implicit sampling circuits.
-/

namespace Nightfall.WynerLocality

open Finset Real
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

section MixtureSize
variable {κ α : Type} [Fintype κ] [DecidableEq κ]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem mixture_information_le_log_card
    {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
    (P : Θ → κ → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1) :
    mutInfo P w ≤ Real.log (Fintype.card Θ : ℝ) := by
  unfold mutInfo
  have hcond : 0 ≤ ∑ x : κ → α, Ent (fun θ => w θ * prodMass (P θ) x) := by
    apply Finset.sum_nonneg
    intro x _
    exact ent_nonneg _ (fun θ => mul_nonneg (hw0 θ)
      (product_mass_nonneg (P θ) (hP0 θ) x))
  exact (sub_le_self _ hcond).trans (ent_le_log_card w hw0 hw1)

theorem wynerSet_bddBelow_local (ν : (κ → α) → ℝ) :
    BddBelow (wynerSet ν) := by
  classical
  refine ⟨0, ?_⟩
  rintro s ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst k; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0, hk⟩⟩
  have h := info_nonneg Q hQ0 hQ1 _ (∅ : Finset κ) w rfl hw0
  simpa only [info_empty] using h

theorem wynerGen_le_log_mixture_card
    (ν : (κ → α) → ℝ) (k : ℕ) (w : Fin k → ℝ)
    (Q : Fin k → κ → α → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (hQ0 : ∀ θ i a, 0 ≤ Q θ i a)
    (hQ1 : ∀ θ i, ∑ a, Q θ i a = 1)
    (hν : ∀ z, ν z = ∑ θ, w θ * prodMass (Q θ) z) :
    wynerGen ν ≤ Real.log (k : ℝ) := by
  classical
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst k; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0, hk⟩⟩
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  have hm : mutInfo Q w ∈ wynerSet ν :=
    ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩
  have hu := mixture_information_le_log_card Q hQ0 w hw0 hw1
  simpa only [Fintype.card_fin] using
    (csInf_le (wynerSet_bddBelow_local ν) hm).trans hu

theorem mixture_card_lower_of_wyner_bound
    (ν : (κ → α) → ℝ) (L : ℝ) (hL : L ≤ wynerGen ν)
    (k : ℕ) (w : Fin k → ℝ) (Q : Fin k → κ → α → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (hQ0 : ∀ θ i a, 0 ≤ Q θ i a)
    (hQ1 : ∀ θ i, ∑ a, Q θ i a = 1)
    (hν : ∀ z, ν z = ∑ θ, w θ * prodMass (Q θ) z) :
    Real.exp L ≤ (k : ℝ) := by
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst k; simp at hw1
    · exact h
  have hkR : (0 : ℝ) < k := Nat.cast_pos.mpr hk
  calc
    Real.exp L ≤ Real.exp (Real.log (k : ℝ)) :=
      Real.exp_le_exp.mpr (hL.trans (wynerGen_le_log_mixture_card ν k w Q hw0 hw1 hQ0 hQ1 hν))
    _ = (k : ℝ) := Real.exp_log hkR

theorem locality_mixture_card_lower
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (S : Set (ι → Bool)) (t b r : ℕ) (hr : 0 < r)
    (E : (κ → α) → (ι → Bool)) (D : κ → Tree ι α) (L : ι → Finset κ)
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (hE : Local E L) (hL : ∀ j, (L j).card ≤ b) (hD : ∀ l, (D l).depth ≤ r)
    (hS : FullProjection S t) (hsmall : b*r+1 ≤ t)
    (hfix : ∀ x ∈ S, E (decode D x) = x)
    (hsource : ∀ z, 0 < ν z → E z ∈ S)
    (hinv : ∀ z, 0 < ν z → decode D (E z) = z)
    (hisol : Isolated S)
    (k : ℕ) (w : Fin k → ℝ) (Q : Fin k → κ → α → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (hQ0 : ∀ θ i a, 0 ≤ Q θ i a)
    (hQ1 : ∀ θ i, ∑ a, Q θ i a = 1)
    (hν : ∀ z, ν z = ∑ θ, w θ * prodMass (Q θ) z) :
    Real.exp (Hent ν - (((Fintype.card ι : ℝ) -
      (Fintype.card ι : ℝ)/r) * Real.log 2)) ≤ (k : ℝ) := by
  exact mixture_card_lower_of_wyner_bound ν _
    (wyner_locality_general S t b r hr E D L ν hν0 hν1 hE hL hD hS hsmall
      hfix hsource hinv hisol) k w Q hw0 hw1 hQ0 hQ1 hν

end MixtureSize

section Domination
variable {κ α : Type} [Fintype κ] [DecidableEq κ]
  [Fintype α] [DecidableEq α]

/-- A pointwise dominating reference law transfers every bounded nonnegative loss. -/
theorem dominated_loss (ν μ : (κ → α) → ℝ) (M : ℝ)
    (hdom : ∀ z, ν z ≤ M * μ z) (g : (κ → α) → ℝ)
    (hg : ∀ z, 0 ≤ g z) :
    (∑ z, ν z * g z) ≤ M * ∑ z, μ z * g z := by
  calc
    (∑ z, ν z * g z) ≤ ∑ z, (M * μ z) * g z :=
      Finset.sum_le_sum (fun z _ => mul_le_mul_of_nonneg_right (hdom z) (hg z))
    _ = M * ∑ z, μ z * g z := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro z _
      ring

/-- Product-law simulation works even for correlated inputs dominated by that
product law, at error parameter δ/M. This is an upper bound, not a converse
to the Wyner-based simulation theorem. -/
theorem dominated_product_simulation
    (ν : (κ → α) → ℝ) (p : κ → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (M : ℝ) (hM : 0 < M) (hdom : ∀ z, ν z ≤ M * prodMass p z)
    (f : (κ → α) → ℝ) (d : ℕ) (hd : 1 ≤ d)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (hdeg : HasProdDegreeLE f d)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (n : ℕ)
    (hn : 6 * Real.sqrt 2 * Real.pi ^ 6 * (d : ℝ) ^ 6 ≤
      n * (ε ^ 3 * (δ/M) ^ 2 * Real.sqrt (δ/M))) :
    ∃ t : DTree κ α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤ δ := by
  obtain ⟨t, ht, herr⟩ := simulation_degree p hp hp1 f d hd hf hdeg
    ε (δ/M) hε (div_pos hδ hM) n hn
  refine ⟨t, ht, ?_⟩
  calc
    _ ≤ M * ∑ x, prodMass p x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) :=
      dominated_loss ν (prodMass p) M hdom _ (fun x => by split_ifs <;> norm_num)
    _ ≤ M * (δ/M) := mul_le_mul_of_nonneg_left herr hM.le
    _ = δ := by field_simp [ne_of_gt hM]

end Domination
end Nightfall.WynerLocality

#print axioms Nightfall.WynerLocality.locality_mixture_card_lower
#print axioms Nightfall.WynerLocality.dominated_product_simulation
