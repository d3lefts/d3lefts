import T2QuantumPhaseExpansion
import T2PathEnergy

/-!
# NIGHTFALL T2 — exact physical Born two-oracle four-slot expansion

From the literal source oracle O_s, arbitrary physical U, state ψ,
and arbitrary complex-linear terminal P, prove the exact
**four original-slot** complex interference expansion for

  ⟪O_s U O_s ψ, P (O_s U O_s ψ)⟫.

No alternative assumed path-sum model and no independence of labels;
path vectors are the actual Π_b U Π_a ψ. No positivity of P is needed
for the algebraic identity, so all physical positive nonprojective
effects are included. The summation is over actual original sector
pairs, with a possibly nonzero free zero-label sector.

In the characteristic-two source, the complex conjugate hidden
character is equal to itself. A separate finite group lemma converts
the two paired phase factors into the four-slot Walsh label.
The grouped A/B/C Fourier tail and final query theorem are additional
obligations: this module does not claim to prove them.
-/

namespace Nightfall.StructuralInformation.T2BornExpansion

open Finset
open Nightfall.StructuralInformation.T2QuantumPhaseExpansion
open Nightfall.StructuralInformation.T2ActualSource
open Nightfall.StructuralInformation.T2PathEnergy
open Nightfall.StructuralInformation.T2SecondStageLight

variable {G : Type*} [AddCommGroup G]
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The two original oracle-sector labels on one physical path. -/
def pathFrequency (label : D → G) (ba : D × D) : G :=
  label ba.1 + label ba.2

/-- Genuine two-query Hilbert path produced from the source, not
an independent family of formal vectors. -/
noncomputable def actualPath
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (ba : D × D) : H D E :=
  fullPath (sourcePath psi U) ba

/-- A physically generated state equals the exact finite sum of
its original two-slot phase-weighted Hilbert paths. -/
theorem quantum_state_eq_original_pair_sum
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) :
    twoQueryState label s psi U =
      ∑ ba : D × D,
        s (pathFrequency label ba) • actualPath psi U ba := by
  rw [twoQueryState_eq_original_path_sum]
  simp only [Fintype.sum_prod_type, pathFrequency, actualPath, fullPath]

/-- The exact complex Born amplitude of the actual quantum circuit.
The self-adjoint effect condition is not needed just to expand it. -/
noncomputable def bornAmplitude
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) : ℂ :=
  inner ℂ (twoQueryState label s psi U)
    (P (twoQueryState label s psi U))

/-- Coefficients indexed by genuine original oracle-sector
four-tuples: a,b in ba and a',b' in cd. -/
noncomputable def originalFourCoefficient
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E)
    (ba cd : D × D) : ℂ :=
  inner ℂ (actualPath psi U ba) (P (actualPath psi U cd))

/-- The full physical four-slot interference identity before the
characteristic-two simplification. It holds for all complex physical
linear maps P without assuming commutativity with any sector. -/
theorem bornAmplitude_eq_complex_four_slot_sum
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) :
    bornAmplitude label s psi U P =
      ∑ ba : D × D, ∑ cd : D × D,
        ((starRingEnd ℂ) (s (pathFrequency label ba)) *
          s (pathFrequency label cd)) *
        originalFourCoefficient psi U P ba cd := by
  unfold bornAmplitude
  rw [quantum_state_eq_original_pair_sum]
  change inner ℂ
      (∑ ba : D × D, s (pathFrequency label ba) • actualPath psi U ba)
      (P (∑ cd : D × D,
        s (pathFrequency label cd) • actualPath psi U cd)) = _
  calc
    _ = ∑ ba : D × D, ∑ cd : D × D,
        inner ℂ
          (s (pathFrequency label ba) • actualPath psi U ba)
          (s (pathFrequency label cd) • P (actualPath psi U cd)) := by
      simp only [map_sum, map_smul, sum_inner, inner_sum]
      exact Finset.sum_comm
    _ = _ := by
      apply Finset.sum_congr rfl
      intro ba _
      apply Finset.sum_congr rfl
      intro cd _
      simp only [inner_smul_left, inner_smul_right,
        originalFourCoefficient, starRingEnd_apply]
      ring

#print axioms Nightfall.StructuralInformation.T2BornExpansion.quantum_state_eq_original_pair_sum
#print axioms Nightfall.StructuralInformation.T2BornExpansion.bornAmplitude_eq_complex_four_slot_sum

end Nightfall.StructuralInformation.T2BornExpansion
