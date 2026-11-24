import T2SecondStageLight
import T2EffectOrder

/-!
# NIGHTFALL T2 — both rank-free zero-triple survivor contractions

The two nontrivial Group C complex-Hilbert cancellations in the
paper's unrestricted two-query simulation argument admit independent
operator-factorization proofs. This source derives both, with arbitrary
possibly infinite-dimensional common sector Hilbert fiber E and
arbitrary noncommuting positive terminal effect P.

First-light survivor a'=d:
  Z := Σ_{c∈D} Π_c P B_c,
  Σ_{d∈L} |<v_d,Z>|² ≤ eta*Σ_c ||B_c||².
Here v_d is a real physical first-stage path vector satisfying the
proven p-light frame. No bound on number of paths per c is assumed.

Second-light survivor b'=d:
  K_d := Σ_{c∈C} <t_{d,c}, (P B_c)_d>,
  Σ_{d∈L} |K_d|² ≤ eta*Σ_c ||B_c||²
if q_d=Σ_c ||t_{d,c}||²≤eta. This derivation explicitly
pinches AFTER P; it never falsely commutes P with Π_d.
No orthogonality among t_{d,c} for fixed d is used.

To reach the paper's sqrt(M₂*eta) per survivor event, B_c is the
original additive-pair fiber sum \hat T_c, with total energy ≤M₂.
That source-to-frame coefficient connection and four slot Fourier
index regrouping are separate formalization obligations.
-/

namespace Nightfall.StructuralInformation.T2SurvivorFrames

open Finset
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2EffectOrder

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {C : Type*} [Fintype C]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The exact complex Hilbert inner-product Cauchy--Schwarz
inequality for an arbitrary finite index set, including all
nonorthogonal pairs. -/
theorem finite_complex_inner_cauchy
    (u v : C → E) :
    ‖∑ c : C, inner ℂ (u c) (v c)‖ ^ 2 ≤
      (∑ c : C, ‖u c‖ ^ 2) *
      (∑ c : C, ‖v c‖ ^ 2) := by
  have hnorm : ‖∑ c : C, inner ℂ (u c) (v c)‖ ≤
      ∑ c : C, ‖inner ℂ (u c) (v c)‖ :=
    norm_sum_le _ _
  have hterm : (∑ c : C, ‖inner ℂ (u c) (v c)‖) ≤
      ∑ c : C, ‖u c‖ * ‖v c‖ := by
    apply Finset.sum_le_sum
    intro c _
    exact norm_inner_le_norm (𝕜 := ℂ) (u c) (v c)
  have hpos : 0 ≤ ∑ c : C, ‖u c‖ * ‖v c‖ := by
    apply Finset.sum_nonneg
    intro c _
    exact mul_nonneg (norm_nonneg _) (norm_nonneg _)
  have hsq : ‖∑ c : C, inner ℂ (u c) (v c)‖ ^ 2 ≤
      (∑ c : C, ‖u c‖ * ‖v c‖) ^ 2 :=
    (sq_le_sq₀ (norm_nonneg _) hpos).mpr (hnorm.trans hterm)
  exact hsq.trans (Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset C)
    (fun c => ‖u c‖) (fun c => ‖v c‖))

/-- The actual c-th pair-completed vector after the positive effect
is selected on its *output* d-sector. -/
noncomputable def survivorOutputCoeff
    (t : D → C → E) (B : C → H D E)
    (P : H D E →L[ℂ] H D E) (d : D) : ℂ :=
  ∑ c : C, inner ℂ (t d c) ((P (B c)) d)

/-- Group C second-light contraction in genuine complex Hilbert
sectors. Arbitrary noncommuting physical effects are permitted; no
finite-rank, path-orthogonality or source-space dimension assumptions.
The original pair-completion energy enters visibly as hmass. -/
theorem survivor_output_group_energy
    (L : Finset D) (eta M : ℝ) (heta : 0 ≤ eta)
    (t : D → C → E) (B : C → H D E)
    (P : H D E →L[ℂ] H D E)
    (hP : ‖P‖ ≤ 1)
    (hlight : ∀ d ∈ L, (∑ c : C, ‖t d c‖ ^ 2) ≤ eta)
    (hmass : (∑ c : C, ‖B c‖ ^ 2) ≤ M) :
    (∑ d ∈ L, ‖survivorOutputCoeff t B P d‖ ^ 2) ≤ eta * M := by
  have hcontract (x : H D E) : ‖P x‖ ^ 2 ≤ ‖x‖ ^ 2 := by
    apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr
    calc
      ‖P x‖ ≤ ‖P‖ * ‖x‖ := P.le_opNorm x
      _ ≤ 1 * ‖x‖ := mul_le_mul_of_nonneg_right hP (norm_nonneg x)
      _ = ‖x‖ := one_mul _
  have hrow (d : D) (hd : d ∈ L) :
      ‖survivorOutputCoeff t B P d‖ ^ 2 ≤
        eta * (∑ c : C, ‖(P (B c)) d‖ ^ 2) := by
    calc
      _ ≤ (∑ c : C, ‖t d c‖ ^ 2) *
          (∑ c : C, ‖(P (B c)) d‖ ^ 2) :=
        finite_complex_inner_cauchy (t d) (fun c => (P (B c)) d)
      _ ≤ eta * (∑ c : C, ‖(P (B c)) d‖ ^ 2) :=
        mul_le_mul_of_nonneg_right (hlight d hd)
          (Finset.sum_nonneg (fun c _ => sq_nonneg _))
  have hglobal :
      (∑ d ∈ L, ∑ c : C, ‖(P (B c)) d‖ ^ 2) ≤
        ∑ c : C, ‖B c‖ ^ 2 := by
    calc
      _ = ∑ c : C, ∑ d ∈ L, ‖(P (B c)) d‖ ^ 2 :=
        Finset.sum_comm
      _ ≤ ∑ c : C, ‖P (B c)‖ ^ 2 := by
        apply Finset.sum_le_sum
        intro c _
        rw [PiLp.norm_sq_eq_of_L2]
        exact Finset.sum_le_sum_of_subset_of_nonneg
          (Finset.subset_univ L)
          (fun d hd hn => sq_nonneg (‖(P (B c)) d‖))
      _ ≤ ∑ c : C, ‖B c‖ ^ 2 := by
        apply Finset.sum_le_sum
        intro c _
        exact hcontract (B c)
  calc
    _ ≤ ∑ d ∈ L, eta * (∑ c : C, ‖(P (B c)) d‖ ^ 2) := by
      apply Finset.sum_le_sum
      intro d hd
      exact hrow d hd
    _ = eta * (∑ d ∈ L, ∑ c : C, ‖(P (B c)) d‖ ^ 2) := by
      rw [Finset.mul_sum]
    _ ≤ eta * (∑ c : C, ‖B c‖ ^ 2) :=
      mul_le_mul_of_nonneg_left hglobal heta
    _ ≤ eta * M := mul_le_mul_of_nonneg_left hmass heta

/-- The result specialized to actual physical positive effects, with
0≤P≤I and no assumption that P commutes with the oracle sectors. -/
theorem survivor_output_of_positive_effect
    (L : Finset D) (eta M : ℝ) (heta : 0 ≤ eta)
    (t : D → C → E) (B : C → H D E)
    (P : H D E →L[ℂ] H D E)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (hlight : ∀ d ∈ L, (∑ c : C, ‖t d c‖ ^ 2) ≤ eta)
    (hmass : (∑ c : C, ‖B c‖ ^ 2) ≤ M) :
    (∑ d ∈ L, ‖survivorOutputCoeff t B P d‖ ^ 2) ≤ eta * M :=
  survivor_output_group_energy L eta M heta t B P
    (effect_norm_le_one P hP0 hP1) hlight hmass

/-- First-light survivor completion: take only the output coordinate
d AFTER applying P to each pair-completed input B_d. -/
noncomputable def pinchedSynthesis
    (B : D → H D E) (P : H D E →L[ℂ] H D E) : H D E :=
  WithLp.toLp 2 (fun d : D => (P (B d)) d)

/-- The rank-free pinched synthesis contraction:
||Σ_d Π_d P B_d||²≤Σ_d||B_d||², even when P does not commute with Π_d.
This is an actual Hilbert operator inequality. -/
theorem pinched_synthesis_energy_le
    (B : D → H D E) (P : H D E →L[ℂ] H D E)
    (hP : ‖P‖ ≤ 1) :
    ‖pinchedSynthesis B P‖ ^ 2 ≤ ∑ d : D, ‖B d‖ ^ 2 := by
  rw [PiLp.norm_sq_eq_of_L2]
  change (∑ d : D, ‖(P (B d)) d‖ ^ 2) ≤ _
  calc
    _ ≤ ∑ d : D, ‖P (B d)‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro d _
      rw [PiLp.norm_sq_eq_of_L2]
      exact Finset.single_le_sum
        (fun j _ => sq_nonneg (‖(P (B d)) j‖)) (Finset.mem_univ d)
    _ ≤ ∑ d : D, ‖B d‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro d _
      apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr
      calc
        ‖P (B d)‖ ≤ ‖P‖ * ‖B d‖ := P.le_opNorm _
        _ ≤ 1 * ‖B d‖ := mul_le_mul_of_nonneg_right hP (norm_nonneg _)
        _ = ‖B d‖ := one_mul _

/-- Group C first-light survivor contraction, using the *already
derived* light input frame and the exact noncommuting pinched synthesis.
The hframe condition is the physical p-light estimate, not the desired
bound as an assumed axiom. -/
theorem survivor_input_group_energy
    (L : Finset D) (eta M : ℝ) (heta : 0 ≤ eta)
    (v : D → H D E) (B : D → H D E)
    (P : H D E →L[ℂ] H D E)
    (hP : ‖P‖ ≤ 1)
    (hframe : ∀ x : H D E,
      (∑ d ∈ L, ‖inner ℂ (v d) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2)
    (hmass : (∑ d : D, ‖B d‖ ^ 2) ≤ M) :
    (∑ d ∈ L,
        ‖inner ℂ (v d) (pinchedSynthesis B P)‖ ^ 2) ≤ eta * M := by
  calc
    _ ≤ eta * ‖pinchedSynthesis B P‖ ^ 2 :=
      hframe (pinchedSynthesis B P)
    _ ≤ eta * (∑ d : D, ‖B d‖ ^ 2) :=
      mul_le_mul_of_nonneg_left (pinched_synthesis_energy_le B P hP) heta
    _ ≤ eta * M := mul_le_mul_of_nonneg_left hmass heta

/-- Physical positive terminal effect version of the first-light
survivor estimate, with the projector order unchanged. -/
theorem survivor_input_of_positive_effect
    (L : Finset D) (eta M : ℝ) (heta : 0 ≤ eta)
    (v : D → H D E) (B : D → H D E)
    (P : H D E →L[ℂ] H D E)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (hframe : ∀ x : H D E,
      (∑ d ∈ L, ‖inner ℂ (v d) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2)
    (hmass : (∑ d : D, ‖B d‖ ^ 2) ≤ M) :
    (∑ d ∈ L,
        ‖inner ℂ (v d) (pinchedSynthesis B P)‖ ^ 2) ≤ eta * M :=
  survivor_input_group_energy L eta M heta v B P
    (effect_norm_le_one P hP0 hP1) hframe hmass

#print axioms Nightfall.StructuralInformation.T2SurvivorFrames.finite_complex_inner_cauchy
#print axioms Nightfall.StructuralInformation.T2SurvivorFrames.survivor_output_group_energy
#print axioms Nightfall.StructuralInformation.T2SurvivorFrames.survivor_output_of_positive_effect
#print axioms Nightfall.StructuralInformation.T2SurvivorFrames.pinched_synthesis_energy_le
#print axioms Nightfall.StructuralInformation.T2SurvivorFrames.survivor_input_group_energy
#print axioms Nightfall.StructuralInformation.T2SurvivorFrames.survivor_input_of_positive_effect

end Nightfall.StructuralInformation.T2SurvivorFrames
