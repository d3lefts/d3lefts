import ActualESGeneralMatching
import WeightedGreedyMatching

/-!
# Source-certified matching mass for genuine finite graph matchings

For an arbitrary finite Efron–Stein degree-two input function, any
finite subset of pair edges that is a genuine vertex-disjoint matching
has total source-derived pair amplitude <= 4 B. This module transfers
the matching from an arbitrary edge index into the injective
coordinate-pair interface of ActualESGeneralMatching. Its hypotheses
do not supply a 4 B inequality or an abstract block polynomial.

The weights are required to be attained supported absolute pair-kernel
amplitudes. This is a definition of the pair-amplitude statistic, not
an independent influence estimate; on a finite nonempty full-support
alphabet it can be supplied by a maximum witness.
-/

namespace Nightfall.Observability.ActualESMatchingMass

open Finset
open Nightfall.Observability.WeightedGreedy
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESGeneralMatching

variable {E ι α : Type}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The two endpoints of every edge and every distinct matching edge
have different original coordinate labels. This is exactly the
injectivity of the packed matching-coordinate embedding. -/
theorem matchingCoord_injective_of_disjoint
    (u v : E → ι)
    (hends : ∀ e, u e ≠ v e)
    (hdisj : ∀ e f, e ≠ f → separated u v e f) :
    Function.Injective (matchingCoord u v) := by
  intro a b hab
  rcases a with ⟨e, sa⟩
  rcases b with ⟨f, sb⟩
  by_cases hef : e = f
  · subst f
    have hside : sa = sb := by
      cases sa <;> cases sb
      · rfl
      · exact False.elim ((hends e) (by simpa [matchingCoord] using hab))
      · exact False.elim ((hends e) (by simpa [matchingCoord] using hab.symm))
      · rfl
    exact Prod.ext rfl hside
  · obtain ⟨haa, hab', hba, hbb⟩ := hdisj e f hef
    cases sa <;> cases sb
    · exact False.elim (haa (by simpa [matchingCoord] using hab))
    · exact False.elim (hab' (by simpa [matchingCoord] using hab))
    · exact False.elim (hba (by simpa [matchingCoord] using hab))
    · exact False.elim (hbb (by simpa [matchingCoord] using hab))

/-- The subtype of selected graph edges inherits the disjoint endpoint
property from an ordinary IsMatching witness. -/
theorem matchingCoord_injective_on_selected
    (u v : E → ι) (S : Finset E)
    (hmatch : IsMatching u v S)
    (hends : ∀ e ∈ S, u e ≠ v e) :
    Function.Injective
      (matchingCoord (fun e : {e // e ∈ S} => u e.1)
        (fun e : {e // e ∈ S} => v e.1)) := by
  let ue : {e // e ∈ S} → ι := fun e => u e.1
  let ve : {e // e ∈ S} → ι := fun e => v e.1
  apply matchingCoord_injective_of_disjoint ue ve
  · intro e
    exact hends e.1 e.2
  · intro e f hef
    have hne : e.1 ≠ f.1 := by
      intro h
      apply hef
      exact Subtype.ext h
    exact hmatch e.1 e.2 f.1 f.2 hne

/-- True source pair amplitudes on any finite matching of graph edges
have total mass at most 4 B, including in a larger product with
unmatched coordinates. No matching mass estimate is assumed. -/
theorem source_matching_mass_le_four
    [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : Nightfall.ProductSpace.EfronStein.ESDegreeLE p f 2)
    (base : ι → α)
    (u v : E → ι) (S : Finset E)
    (hmatch : IsMatching u v S)
    (hends : ∀ e ∈ S, u e ≠ v e)
    (w : E → ℝ)
    (hwitness : ∀ e ∈ S, ∃ s t : α,
      w e = |actualPairKernel p f base (u e) (v e) s t|)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    (∑ e ∈ S, w e) ≤ 4 * B := by
  classical
  let ue : {e // e ∈ S} → ι := fun e => u e.1
  let ve : {e // e ∈ S} → ι := fun e => v e.1
  have hinj : Function.Injective (matchingCoord ue ve) :=
    matchingCoord_injective_on_selected u v S hmatch hends
  obtain ⟨a0, a1, b0, b1, hdom, hbudget⟩ :=
    actual_source_general_matching_amplitude_witness
      p hp hp1 f hdegree base ue ve hinj B hf
  have hsum :
      (∑ e : {e // e ∈ S}, w e.1) ≤
      (∑ e : {e // e ∈ S},
        Nightfall.Observability.ActualESQuadraticRectangles.sourceRectangle
          f base (u e.1) (v e.1)
          (a0 e) (a1 e) (b0 e) (b1 e)) := by
    apply Finset.sum_le_sum
    intro e _
    obtain ⟨s, t, hw⟩ := hwitness e.1 e.2
    rw [hw]
    exact hdom e s t
  have hsubtype : (∑ e ∈ S, w e) =
      (∑ e : {e // e ∈ S}, w e.1) := by
    simp
  rw [hsubtype]
  exact hsum.trans hbudget

end Nightfall.Observability.ActualESMatchingMass
