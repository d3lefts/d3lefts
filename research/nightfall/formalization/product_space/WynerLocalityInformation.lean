import Route1WynerGeneral
import WynerLocalityPPZ

/-!
The general-latent entropy bridge uses the actual Route1WynerGeneral
definition, not a redefined common information. The terminal theorem
uses the separately proved PPZ counting lemma without a counting premise.
-/

namespace Nightfall.WynerLocality

open Finset Real
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.Transfer (prodMass)

section Entropy
variable {X : Type} [Fintype X] [DecidableEq X]

noncomputable def positiveSupport (p : X → ℝ) : Finset X :=
  univ.filter fun x => 0 < p x

theorem entropy_le_log_support (p : X → ℝ)
    (hp0 : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1) :
    (∑ x, negMulLog (p x)) ≤ Real.log ((positiveSupport p).card : ℝ) := by
  classical
  let A := positiveSupport p
  have hzero : ∀ x, x ∉ A → p x = 0 := by
    intro x hx
    have hn : ¬ 0 < p x := by simpa [A, positiveSupport] using hx
    exact le_antisymm (le_of_not_gt hn) (hp0 x)
  have hs : (∑ x ∈ A, p x) = 1 := by
    calc
      _ = ∑ x, p x := Finset.sum_subset (Finset.subset_univ A) (fun x _ hx => hzero x hx)
      _ = 1 := hp1
  have hH : (∑ x ∈ A, negMulLog (p x)) = ∑ x, negMulLog (p x) := by
    apply Finset.sum_subset (Finset.subset_univ A)
    intro x _ hx
    rw [hzero x hx, Real.negMulLog_zero]
  have hA : 0 < A.card := by
    by_contra hn
    have he : A = ∅ := Finset.card_eq_zero.mp (by omega)
    simp [he] at hs
  have hM : (0 : ℝ) < A.card := Nat.cast_pos.mpr hA
  have hw : (∑ _x ∈ A, (1 : ℝ) / A.card) = 1 := by
    rw [Finset.sum_const, nsmul_eq_mul]
    field_simp
  have hcon := ConcaveOn.le_map_sum Real.concaveOn_negMulLog (t := A)
    (w := fun _ => 1 / (A.card : ℝ)) (p := p)
    (fun _ _ => by positivity) hw
    (fun x _ => Set.mem_Ici.mpr (hp0 x))
  simp only [smul_eq_mul] at hcon
  have hleft : (∑ x ∈ A, (1 / (A.card : ℝ)) * negMulLog (p x)) =
      (∑ x, negMulLog (p x)) / A.card := by
    rw [← Finset.mul_sum, hH]
    ring
  have hright : (∑ x ∈ A, (1 / (A.card : ℝ)) * p x) = 1 / (A.card : ℝ) := by
    rw [← Finset.mul_sum, hs, mul_one]
  have hv : negMulLog (1 / (A.card : ℝ)) = Real.log (A.card : ℝ) / A.card := by
    unfold negMulLog
    rw [one_div, Real.log_inv]
    ring
  rw [hleft, hright, hv] at hcon
  exact (div_le_div_iff_of_pos_right hM).mp hcon

end Entropy

section Wyner
variable {κ α : Type} [Fintype κ] [DecidableEq κ]
    [Fintype α] [DecidableEq α] [Nonempty α]

theorem product_mass_nonneg (p : κ → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (z : κ → α) : 0 ≤ prodMass p z := by
  unfold prodMass
  exact Finset.prod_nonneg fun i _ => hp i (z i)

theorem product_mass_pos_iff (p : κ → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (z : κ → α) : 0 < prodMass p z ↔ ∀ i, 0 < p i (z i) := by
  unfold prodMass
  constructor
  · intro h i
    by_contra hn
    have hz : p i (z i) = 0 := le_antisymm (le_of_not_gt hn) (hp i (z i))
    rw [Finset.prod_eq_zero (Finset.mem_univ i) hz] at h
    exact (lt_irrefl 0) h
  · intro h
    exact Finset.prod_pos fun i _ => h i

/-- Lower bound on the existing general-latent Wyner infimum from a bound on
all normalized product components supported in the original positive support. -/
theorem wyner_general_lower_of_component_entropy
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (K : ℝ)
    (hcap : ∀ p : κ → α → ℝ, (∀ i a, 0 ≤ p i a) →
      (∀ i, ∑ a, p i a = 1) →
      (∀ z, 0 < prodMass p z → 0 < ν z) → Hent (prodMass p) ≤ K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩
  have hmix : Hent ν = Hent (fun z => ∑ θ, w θ * prodMass (Q θ) z) := by
    congr 1
    funext z
    exact hν z
  rw [mutInfo_eq Q hQ1 w hw1, ← hmix]
  have hsum : (∑ θ, w θ * Hent (prodMass (Q θ))) ≤ K := by
    calc
      _ ≤ ∑ θ, w θ * K := by
        apply Finset.sum_le_sum
        intro θ _
        by_cases hz : w θ = 0
        · simp [hz]
        · have hw : 0 < w θ := lt_of_le_of_ne (hw0 θ) (Ne.symm hz)
          apply mul_le_mul_of_nonneg_left _ (hw0 θ)
          apply hcap (Q θ) (hQ0 θ) (hQ1 θ)
          intro z hpos
          rw [hν z]
          exact (mul_pos hw hpos).trans_le
            (Finset.single_le_sum
              (fun i _ => mul_nonneg (hw0 i) (product_mass_nonneg (Q i) (hQ0 i) z))
              (Finset.mem_univ θ))
      _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
  linarith

end Wyner

section Locality
variable {ι κ α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype κ] [DecidableEq κ] [Fintype α] [DecidableEq α] [Nonempty α]

/-- The actual general-latent bound, conditional only on the explicitly
stated isolated-assignment counting lemma and the paper's source model. -/
theorem wyner_locality_of_ppz
    (S : Set (ι → Bool)) (t b r : ℕ)
    (E : (κ → α) → (ι → Bool)) (D : κ → Tree ι α) (L : ι → Finset κ)
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (hE : Local E L) (hL : ∀ j, (L j).card ≤ b) (hD : ∀ l, (D l).depth ≤ r)
    (hS : FullProjection S t) (hsmall : b*r+1 ≤ t)
    (hfix : ∀ x ∈ S, E (decode D x) = x)
    (hsource : ∀ z, 0 < ν z → E z ∈ S)
    (hinv : ∀ z, 0 < ν z → decode D (E z) = z)
    (hisol : Isolated S) (K : ℝ) (hPPZ : PPZCap (ι := ι) r K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  have hid := shallow_retraction_identity S t b r E D L hE hL hD hS hsmall hfix
  apply wyner_general_lower_of_component_entropy ν hν0 hν1 K
  intro p hp0 hp1 hsupport
  let T := positiveSupport (prodMass p)
  let A := T.image E
  have hT : ∀ z, z ∈ T ↔ 0 < prodMass p z := by
    intro z
    simp [T, positiveSupport]
  have hA : ∀ x, x ∈ A ↔ ∀ l, 0 < p l (decode D x l) := by
    intro x
    constructor
    · intro hx
      obtain ⟨z, hz, he⟩ := Finset.mem_image.mp hx
      have hz' := (hT z).mp hz
      have hd := hinv z (hsupport z hz')
      rw [← he, hd]
      exact (product_mass_pos_iff p hp0 z).mp hz'
    · intro hx
      exact Finset.mem_image.mpr ⟨decode D x,
        (hT _).mpr ((product_mass_pos_iff p hp0 _).mpr hx), hid x⟩
  have hcard : A.card = T.card := by
    apply Finset.card_image_iff.mpr
    intro x hx y hy hxy
    have hx' := hinv x (hsupport x ((hT x).mp hx))
    have hy' := hinv y (hsupport y ((hT y).mp hy))
    rw [hxy, hy'] at hx'
    exact hx'.symm
  have hnon : A.Nonempty := by
    have hTnon : T.Nonempty := by
      by_contra hn
      have he : T = ∅ := Finset.not_nonempty_iff_eq_empty.mp hn
      have hz : ∀ z, prodMass p z = 0 := by
        intro z
        have hn' : ¬ 0 < prodMass p z := by
          rw [← hT z, he]
          simp
        exact le_antisymm (le_of_not_gt hn') (product_mass_nonneg p hp0 z)
      have hs := prodMass_total p hp1
      simp [hz] at hs
    exact hTnon.image E
  have hsubset : ∀ x ∈ A, x ∈ S := by
    intro x hx
    obtain ⟨z, hz, rfl⟩ := Finset.mem_image.mp hx
    exact hsource z (hsupport z ((hT z).mp hz))
  have hloc : LocalExclusion (↑A : Set (ι → Bool)) r := by
    intro y hy
    have hbad : ¬ ∀ l, decode D y l ∈ {a | 0 < p l a} := by
      intro hh
      exact hy ((hA y).mpr hh)
    obtain ⟨J, hJ, hJx⟩ := rectangle_preimage_local_exclusion D r
      (fun l => {a | 0 < p l a}) hD y hbad
    refine ⟨J, hJ, ?_⟩
    intro x hx hxA
    exact hJx x hx ((hA x).mp hxA)
  have hIso : Isolated (↑A : Set (ι → Bool)) := by
    intro x hx j hj
    exact hisol x (hsubset x hx) j (hsubset _ hj)
  have hK := hPPZ A hnon hloc hIso
  rw [hcard] at hK
  exact (entropy_le_log_support (prodMass p) (product_mass_nonneg p hp0)
    (prodMass_total p hp1)).trans hK

end Locality

section Terminal
variable {ι : Type} [Fintype ι] [DecidableEq ι]
/-- The general locality theorem with the PPZ premise discharged. Entropies
are nats, as in #970. No finite enumeration or conditional support cap
assumption appears in this statement. -/
theorem wyner_locality_general
    {κ α : Type} [Fintype κ] [DecidableEq κ]
    [Fintype α] [DecidableEq α] [Nonempty α]
    (S : Set (ι → Bool)) (t b r : ℕ) (hr : 0 < r)
    (E : (κ → α) → (ι → Bool)) (D : κ → Tree ι α) (L : ι → Finset κ)
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (hE : Local E L) (hL : ∀ j, (L j).card ≤ b) (hD : ∀ l, (D l).depth ≤ r)
    (hS : FullProjection S t) (hsmall : b*r+1 ≤ t)
    (hfix : ∀ x ∈ S, E (decode D x) = x)
    (hsource : ∀ z, 0 < ν z → E z ∈ S)
    (hinv : ∀ z, 0 < ν z → decode D (E z) = z)
    (hisol : Isolated S) :
    Nightfall.Route1Polylog.Hent ν -
      (((Fintype.card ι : ℝ) - (Fintype.card ι : ℝ)/r) * Real.log 2) ≤
      Nightfall.Route1Polylog.wynerGen ν := by
  exact wyner_locality_of_ppz S t b r E D L ν hν0 hν1 hE hL hD hS hsmall hfix hsource hinv hisol
    _ (ppz_cap r hr)

end Terminal
end Nightfall.WynerLocality

#print axioms Nightfall.WynerLocality.entropy_le_log_support
#print axioms Nightfall.WynerLocality.wyner_general_lower_of_component_entropy
#print axioms Nightfall.WynerLocality.wyner_locality_of_ppz

#print axioms Nightfall.WynerLocality.wyner_locality_general
