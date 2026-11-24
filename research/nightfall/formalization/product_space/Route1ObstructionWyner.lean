import Route1WynerGeneral
import Route1StaticObstruction
import Route1RecoveryEntropy
import Route1OrthogonalCorrelation

/-! Source-exact terminal composition with #970's general-latent Wyner
information. No alternate definition of information, finite mixture rank,
or custom axiom is introduced. -/
namespace Nightfall.Route1Polylog

open Finset Real
open Nightfall.ProductSpace.Mixture
open Nightfall.Route1StaticObstruction
open Nightfall.Route1RecoveryEntropy

variable {J A : Type} [Fintype J] [DecidableEq J]
  [Fintype A] [DecidableEq A] [Nonempty A]

/-- A uniform componentwise entropy upper bound gives a lower bound for
the actual general-latent common information. This uses #970's proven
finite/general equivalence, not an assumption on the size of the latent. -/
theorem wynerGen_lower_of_component_entropy
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (K : ℝ)
    (hK : ∀ p : J → A → ℝ, (∀ j a, 0 ≤ p j a) →
      (∀ j, ∑ a, p j a = 1) →
      (∀ z, 0 < prodMass p z → 0 < ν z) →
      Hent (prodMass p) ≤ K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
  rw [mutInfo_eq Q hQ1 w hw1]
  have hm : (fun z => ∑ θ, w θ * prodMass (Q θ) z) = ν :=
    funext (fun z => (hν z).symm)
  rw [hm]
  have he : ∑ θ, w θ * Hent (prodMass (Q θ)) ≤ K := by
    calc
      _ ≤ ∑ θ, w θ * K := by
        apply Finset.sum_le_sum
        intro θ _
        rcases (hw0 θ).eq_or_lt with h | h
        · simp [← h]
        · apply mul_le_mul_of_nonneg_left _ (hw0 θ)
          apply hK (Q θ) (hQ0 θ) (hQ1 θ)
          intro z hz
          have hle : w θ * prodMass (Q θ) z ≤ ν z := by
            rw [hν]
            exact Finset.single_le_sum
              (fun t _ => mul_nonneg (hw0 t)
                (Finset.prod_nonneg (fun j _ => hQ0 t j (z j)))) (mem_univ θ)
          exact lt_of_lt_of_le (mul_pos h hz) hle
      _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
  linarith

/-- More general entropy-budget version, needed for the TV-robust code
argument and orthogonal correlation, where the bound is on the average
rather than on each component separately. -/
theorem wynerGen_lower_of_average_entropy
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (K : ℝ)
    (hK : ∀ (k : ℕ) (w : Fin k → ℝ) (Q : Fin k → J → A → ℝ),
      (∀ θ, 0 ≤ w θ) → (∑ θ, w θ = 1) →
      (∀ θ j a, 0 ≤ Q θ j a) → (∀ θ j, ∑ a, Q θ j a = 1) →
      (∀ z, ν z = ∑ θ, w θ * prodMass (Q θ) z) →
      ∑ θ, w θ * Hent (prodMass (Q θ)) ≤ K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
  rw [mutInfo_eq Q hQ1 w hw1]
  have hm : (fun z => ∑ θ, w θ * prodMass (Q θ) z) = ν :=
    funext (fun z => (hν z).symm)
  rw [hm]
  have he := hK k w Q hw0 hw1 hQ0 hQ1 hν
  linarith

/-- Actual product mass positivity is equivalent to membership in the
coordinate-support rectangle, including zero atoms. -/
theorem prodMass_pos_iff_box (p : J → A → ℝ)
    (hp0 : ∀ j a, 0 ≤ p j a) (z : J → A) :
    0 < prodMass p z ↔ z ∈ box (fun j => univ.filter (fun a => 0 < p j a)) := by
  classical
  constructor
  · intro hz j
    apply mem_filter.mpr
    refine ⟨mem_univ _, ?_⟩
    by_contra! h
    have he : p j (z j) = 0 := le_antisymm h (hp0 j (z j))
    have hzero : prodMass p z = 0 := by
      unfold prodMass
      exact Finset.prod_eq_zero (mem_univ j) he
    linarith
  · intro hz
    unfold prodMass
    exact Finset.prod_pos (fun j _ => (mem_filter.mp (hz j)).2)

/-- The exact entropy bound on a genuine product mass supported by a
finite rectangle. This theorem counts the rectangle directly. -/
theorem product_entropy_le_log_support (p : J → A → ℝ)
    (hp0 : ∀ j a, 0 ≤ p j a) (hp1 : ∀ j, ∑ a, p j a = 1)
    (L : ℕ) (hL : (univ.filter (fun z => 0 < prodMass p z)).card ≤ L) :
    Hent (prodMass p) ≤ Real.log (L : ℝ) := by
  classical
  let S : Finset (J → A) := univ.filter (fun z => 0 < prodMass p z)
  have hnonneg : ∀ z, 0 ≤ prodMass p z :=
    fun z => Finset.prod_nonneg (fun j _ => hp0 j (z j))
  have hzero : ∀ z ∉ S, prodMass p z = 0 := by
    intro z hz
    have hn : ¬ 0 < prodMass p z := by simpa [S] using hz
    exact le_antisymm (le_of_not_gt hn) (hnonneg z)
  have hm : ∑ z ∈ S, prodMass p z = 1 := by
    rw [← prodMass_total p hp1]
    exact Finset.sum_subset (subset_univ _) (fun z _ hz => hzero z hz) |>.symm
  have hs : S.Nonempty := by
    by_contra hn
    have he : S = ∅ := Finset.not_nonempty_iff_eq_empty.mp hn
    simp [he] at hm
  have he : Hent (prodMass p) = ∑ z ∈ S, negMulLog (prodMass p z) := by
    unfold Hent
    symm
    exact Finset.sum_subset (subset_univ _) (fun z _ hz => by simp [hzero z hz])
  rw [he]
  have hpos : (0 : ℝ) < S.card := Nat.cast_pos.mpr (Finset.card_pos.mpr hs)
  exact (support_entropy_le S hs _ (fun z _ => hnonneg z) hm).trans
    (Real.log_le_log hpos (by exact_mod_cast hL))

/-- A literal general-latent static obstruction from a proved
component support cardinality bound. The geometry-to-cardinality step
is separate, so this statement does not assume a mutual information
or Wyner inequality. -/
theorem static_wyner_cardinality_terminal
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (L : ℕ)
    (hL : ∀ p : J → A → ℝ, (∀ j a, 0 ≤ p j a) →
      (∀ j, ∑ a, p j a = 1) →
      (∀ z, 0 < prodMass p z → 0 < ν z) →
      (univ.filter (fun z => 0 < prodMass p z)).card ≤ L) :
    Hent ν - Real.log (L : ℝ) ≤ wynerGen ν := by
  apply wynerGen_lower_of_component_entropy ν hν0 hν1
  intro p hp0 hp1 hs
  exact product_entropy_le_log_support p hp0 hp1 L (hL p hp0 hp1 hs)

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.wynerGen_lower_of_component_entropy
#print axioms Nightfall.Route1Polylog.wynerGen_lower_of_average_entropy
#print axioms Nightfall.Route1Polylog.prodMass_pos_iff_box
#print axioms Nightfall.Route1Polylog.product_entropy_le_log_support
#print axioms Nightfall.Route1Polylog.static_wyner_cardinality_terminal
