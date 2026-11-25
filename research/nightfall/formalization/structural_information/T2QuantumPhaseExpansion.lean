import T2ActualSource

/-!
# NIGHTFALL T2 — exact physical two-oracle phase/path expansion

Let G be the additive label group, D the finite set of physical
orthogonal sectors (each with a label in G), H=PiLp 2 (D -> E)
an arbitrary possibly infinite-dimensional complex Hilbert direct sum,
ψ any initial state, U any fixed complex linear unitary, and
s:AddChar G ℂ the actual hidden phase character.

The original oracle is the physical block-diagonal multiplication:
  (O_s x)_b = s(label b) • x_b.
This module derives
  (O_s U O_s ψ)_b =
    Σ_{a∈D} s(label b + label a) •
      (U (Π_a ψ))_b
for every physical sector b.

No phase independence, fabricated XOR-query access, finite-dimensional
workspace, special projection rank, or low-degree hypothesis. All zero
sector amplitudes are retained. This is the physical amplitude-to-
Fourier path identity in paper equation (6), before squaring against
the actual positive effect. The Born four-slot coefficient identity,
uniform Parseval and grouped heavy-tail 31 bound remain separate.
-/

namespace Nightfall.StructuralInformation.T2QuantumPhaseExpansion

open Finset
open Nightfall.StructuralInformation.T2ActualSource
open Nightfall.StructuralInformation.T2SecondStageLight

variable {G : Type*} [AddCommGroup G]
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The genuine block-diagonal phase oracle, using the actual secret
character and the physical label of each orthogonal sector. -/
noncomputable def phaseOracle
    (label : D → G) (s : AddChar G ℂ) (x : H D E) : H D E :=
  WithLp.toLp 2 (fun b : D => s (label b) • x b)

/-- Phase oracle acts on the requested physical output coordinate. -/
theorem phaseOracle_apply
    (label : D → G) (s : AddChar G ℂ) (x : H D E) (b : D) :
    phaseOracle label s x b = s (label b) • x b := by
  rfl

/-- Coordinate evaluation commutes with sums by linearity of the actual projection. -/
private theorem coordinate_sum {J : Type*} [Fintype J]
    (f : J → H D E) (b : D) :
    (∑ j, f j) b = ∑ j, f j b := by
  let L : H D E →ₗ[ℂ] E := PiLp.projₗ 2 (fun _ : D => E) b
  change L (∑ j, f j) = ∑ j, L (f j)
  exact map_sum L f Finset.univ

private theorem coordinate_smul (c : ℂ) (x : H D E) (b : D) :
    (c • x) b = c • x b := by
  rfl

/-- Physical sector projections resolve every vector, including
possibly zero output blocks, without choosing a basis for E. -/
theorem psi_eq_sum_sectors (psi : H D E) :
    psi = ∑ a : D, psiSector psi a := by
  ext b
  rw [coordinate_sum]
  change psi b = ∑ a : D, (if b = a then psi a else 0)
  simp

/-- The first quantum oracle acts by an actual complex-weighted
sum over the original physical sectors. -/
theorem phaseOracle_eq_sum_original_sector_paths
    (label : D → G) (s : AddChar G ℂ) (psi : H D E) :
    phaseOracle label s psi =
      ∑ a : D, s (label a) • psiSector psi a := by
  ext b
  rw [coordinate_sum]
  simp only [coordinate_smul]
  change s (label b) • psi b =
      ∑ a : D, s (label a) • (if b = a then psi a else 0)
  simp [smul_ite]

/-- Exact source-unitary first-oracle state identity, by the
complex linearity of U and without any spectral assumption. -/
theorem unitary_after_first_oracle
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) :
    U (phaseOracle label s psi) =
      ∑ a : D, s (label a) • U (psiSector psi a) := by
  rw [phaseOracle_eq_sum_original_sector_paths]
  simp only [map_sum, map_smul]

/-- The exact two-query physical state, not a surrogate polynomial. -/
noncomputable def twoQueryState
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) : H D E :=
  phaseOracle label s (U (phaseOracle label s psi))

/-- Paper's two-query amplitude formula, stated at each actual output
sector b. The frequency is the honest original-label sum (b+a). -/
theorem twoQueryState_coordinate_eq_path_sum
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (b : D) :
    twoQueryState label s psi U b =
      ∑ a : D, s (label b + label a) • sourcePath psi U b a := by
  rw [twoQueryState, phaseOracle_apply, unitary_after_first_oracle]
  simp only [coordinate_sum, coordinate_smul]
  change s (label b) •
      (∑ a : D, s (label a) • sourcePath psi U b a) = _
  rw [smul_sum]
  apply Finset.sum_congr rfl
  intro a _
  rw [smul_smul, ← AddChar.map_add_eq_mul]

/-- Exact two-query state as a literal sum of original two-stage
path vectors. This is not an assumption of a convenient path model:
the vectors are derived from the genuine oracle and U. -/
theorem twoQueryState_eq_original_path_sum
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) :
    twoQueryState label s psi U =
      ∑ b : D, ∑ a : D,
        s (label b + label a) •
          T2SecondStageLight.path (sourcePath psi U) b a := by
  ext d
  rw [twoQueryState_coordinate_eq_path_sum]
  simp only [coordinate_sum, coordinate_smul]
  change (∑ a : D, s (label d + label a) • sourcePath psi U d a) =
    ∑ b : D, ∑ a : D,
      s (label b + label a) • (if d = b then sourcePath psi U b a else 0)
  symm
  calc
    _ = ∑ b : D, if d = b then
          ∑ a : D, s (label b + label a) • sourcePath psi U b a else 0 := by
      apply Finset.sum_congr rfl
      intro b _
      by_cases h : d = b
      · simp [h]
      · simp [h]
    _ = _ := by simp

/-- Additive character multiplicativity proves the literal four-slot
Walsh frequency, without treating labels as independent bits. -/
theorem four_phases_eq_one_walsh_frequency
    (s : AddChar G ℂ) (a b c d : G) :
    s a * s b * s c * s d = s (a + b + c + d) := by
  simp [AddChar.map_add_eq_mul, mul_assoc]

#print axioms Nightfall.StructuralInformation.T2QuantumPhaseExpansion.psi_eq_sum_sectors
#print axioms Nightfall.StructuralInformation.T2QuantumPhaseExpansion.phaseOracle_eq_sum_original_sector_paths
#print axioms Nightfall.StructuralInformation.T2QuantumPhaseExpansion.unitary_after_first_oracle
#print axioms Nightfall.StructuralInformation.T2QuantumPhaseExpansion.twoQueryState_coordinate_eq_path_sum
#print axioms Nightfall.StructuralInformation.T2QuantumPhaseExpansion.twoQueryState_eq_original_path_sum
#print axioms Nightfall.StructuralInformation.T2QuantumPhaseExpansion.four_phases_eq_one_walsh_frequency

end Nightfall.StructuralInformation.T2QuantumPhaseExpansion
