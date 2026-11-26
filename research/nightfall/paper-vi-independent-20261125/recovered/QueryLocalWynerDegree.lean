import Route1LatentDegree
import ProductRowBound

/-!
# NIGHTFALL — degree preservation under finite query-local encoding

A b-local deterministic map Phi sends every observed degree-d function to a
latent degree-(b*d) function, using the EXACT source predicate
RowBound.HasProdDegreeLE. No probability assumptions and no oracle shortcuts.
The proof expands each indicator monomial into a supported function on
the union of its coordinate neighborhoods. The union cardinality is bounded
before the source-degree reconstruction.
-/

namespace Nightfall.QueryLocalWyner

open Finset
open Nightfall.Route1LatentDegree
open Nightfall.ProductSpace.RowBound

variable {I J A : Type}
  [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype A] [DecidableEq A] [Nonempty A]

def LocallyEncoded (Φ : (J → A) → (I → A))
    (S : I → Finset J) : Prop :=
  ∀ i z w, (∀ j ∈ S i, z j = w j) → Φ z i = Φ w i

theorem locality_card_le (S : I → Finset J) (b : ℕ)
    (hb : ∀ i, (S i).card ≤ b) (T : Finset I) :
    (T.biUnion S).card ≤ b * T.card := by
  calc
    (T.biUnion S).card ≤ ∑ i ∈ T, (S i).card :=
      Finset.card_biUnion_le
    _ ≤ ∑ _i ∈ T, b :=
      Finset.sum_le_sum (fun i _ => hb i)
    _ = b * T.card := by simp [mul_comm]

theorem pulled_indicator_supported
    (Φ : (J → A) → (I → A))
    (S : I → Finset J)
    (hlocal : LocallyEncoded Φ S)
    (T : Finset I) (τ : I → A) (c : ℝ) :
    SupportedOn (T.biUnion S)
      (fun z : J → A => c * Nightfall.Route1LatentDegree.indMono T τ (Φ z)) := by
  intro z w hzw
  apply congrArg (fun y : ℝ => c * y)
  unfold Nightfall.Route1LatentDegree.indMono
  apply Finset.prod_congr rfl
  intro i hi
  have hcoord : Φ z i = Φ w i := hlocal i z w (by
    intro j hj
    exact hzw j (Finset.mem_biUnion.mpr ⟨i, hi, hj⟩))
  rw [hcoord]

/-- Full finite b-local interaction-degree pullback, not a hypothesis.
The same algebraic predicate HasProdDegreeLE as original Route1 is used. -/
theorem degree_local_pullback
    (Φ : (J → A) → (I → A))
    (S : I → Finset J) (b d : ℕ)
    (hb : ∀ i, (S i).card ≤ b)
    (hlocal : LocallyEncoded Φ S)
    (f : (I → A) → ℝ)
    (hf : HasProdDegreeLE f d) :
    HasProdDegreeLE (fun z => f (Φ z)) (b * d) := by
  classical
  have hfd : DegreeLE f d := hf
  obtain ⟨a, ha0, ha⟩ := hfd
  have hterm : ∀ T : Finset I, ∀ τ : I → A,
      DegreeLE (fun z : J → A =>
        a T τ * Nightfall.Route1LatentDegree.indMono T τ (Φ z)) (b*d) := by
    intro T τ
    by_cases hT : T.card ≤ d
    · exact degree_of_supported (T.biUnion S) _
        (pulled_indicator_supported Φ S hlocal T τ (a T τ))
        (b*d) (by
          calc
            (T.biUnion S).card ≤ b*T.card := locality_card_le S b hb T
            _ ≤ b*d := Nat.mul_le_mul_left b hT)
    · have hzero : a T τ = 0 := ha0 T (by omega) τ
      simpa [hzero] using
        (degree_zero (ι := J) (α := A) (b*d))
  have hinner : ∀ T : Finset I,
      DegreeLE (fun z : J → A =>
        ∑ τ : I → A, a T τ *
          Nightfall.Route1LatentDegree.indMono T τ (Φ z)) (b*d) := by
    intro T
    exact degree_sum _ (b*d) (hterm T)
  have houter : DegreeLE (fun z : J → A =>
      ∑ T : Finset I, ∑ τ : I → A,
        a T τ * Nightfall.Route1LatentDegree.indMono T τ (Φ z)) (b*d) := by
    exact degree_sum _ (b*d) hinner
  change DegreeLE (fun z => f (Φ z)) (b*d)
  obtain ⟨coeff, hcoeff0, hcoeff⟩ := houter
  refine ⟨coeff, hcoeff0, ?_⟩
  intro z
  calc
    f (Φ z) = ∑ T : Finset I, ∑ τ : I → A,
      a T τ * Nightfall.Route1LatentDegree.indMono T τ (Φ z) := ha (Φ z)
    _ = ∑ T : Finset J, ∑ τ : J → A,
      coeff T τ * Nightfall.Route1LatentDegree.indMono T τ z := hcoeff z

end Nightfall.QueryLocalWyner

#print axioms Nightfall.QueryLocalWyner.locality_card_le
#print axioms Nightfall.QueryLocalWyner.pulled_indicator_supported
#print axioms Nightfall.QueryLocalWyner.degree_local_pullback
