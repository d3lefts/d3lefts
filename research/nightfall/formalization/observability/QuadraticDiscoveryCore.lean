import Mathlib

/-!
# NIGHTFALL quadratic discovery: strict Lean boundary

The following declarations kernel-check three *exactly scoped* parts of
Wright, "Adaptive Compression and Quadratic Observability", v4 (2026-11-11).

1. The sharp 7B three-point quadratic projection estimate (the v3 improvement).
2. The parity mixed-difference arithmetic used in matching comparisons.
3. Composition of an explicitly supplied matching/fourth-moment certificate
   into the proposed 15(1+sqrt(3)) variance bound.

The full degree-two arbitrary-law theorem is NOT certified here: it still
requires a Lean proof connecting an actual bounded Hoeffding-degree-two
product observable to the certificate hypotheses below, notably the
multi-edge parity coupling, quadratic switching, and Hilbert-valued
independent-increment fourth-moment estimates. The rank-r adaptive
prediction, arbitrary-measurable-product lift, and priority review are also
NOT certified here. No "sorry", custom axioms, or opaque premises are used.
-/

namespace Nightfall.Observability.QuadraticV3

open Finset

/-- Exact degree-two interpolation: the additive projection is the
three-point extrapolant `-2 q(0) + 4 q(1/2) - q(1)`. -/
theorem additive_projection_identity (a b c : ℝ) :
    c + b = -2 * c + 4 * (a / 4 + b / 2 + c) - (a + b + c) := by
  ring

/-- Sharp 7B bound for the additive projection from bounded quadratic
switching at the three points 0, 1/2, and 1. No law or atom lower bound. -/
theorem additive_projection_seven
    (a b c B : ℝ)
    (h0 : |c| ≤ B)
    (hh : |a / 4 + b / 2 + c| ≤ B)
    (h1 : |a + b + c| ≤ B) :
    |c + b| ≤ 7 * B := by
  obtain ⟨h0l, h0u⟩ := abs_le.mp h0
  obtain ⟨hhl, hhu⟩ := abs_le.mp hh
  obtain ⟨h1l, h1u⟩ := abs_le.mp h1
  rw [additive_projection_identity]
  apply abs_le.mpr
  constructor <;> linarith

/-- The coefficient 7 is attained by the quadratic
q(t)=8t²-8t+1: q(0)=q(1)=1, q(1/2)=-1, q(0)+q'(0)=-7. -/
theorem additive_projection_seven_sharp :
    ∃ (a b c B : ℝ),
      |c| ≤ B ∧
      |a / 4 + b / 2 + c| ≤ B ∧
      |a + b + c| ≤ B ∧
      |c + b| = 7 * B := by
  refine ⟨8, -8, 1, 1, ?_⟩
  norm_num

/-- Same-marginal even/odd two-point couplings isolate one mixed
difference. A local algebraic lemma, NOT yet the multi-edge coupling. -/
theorem parity_coupling_difference (a b c d : ℝ) :
    (a + d) / 2 - (b + c) / 2 =
    (a - b - c + d) / 2 := by
  ring

/-- If the two coupling expectations are individually bounded by B,
the associated mixed difference is at most 4B in absolute value. -/
theorem mixed_difference_four
    (a b c d B : ℝ)
    (heven : |(a + d) / 2| ≤ B)
    (hodd : |(b + c) / 2| ≤ B) :
    |a - b - c + d| ≤ 4 * B := by
  obtain ⟨hel, heu⟩ := abs_le.mp heven
  obtain ⟨hol, hou⟩ := abs_le.mp hodd
  have hid : a - b - c + d =
      2 * ((a + d) / 2 - (b + c) / 2) := by ring
  rw [hid]
  apply abs_le.mpr
  constructor <;> linarith

/-- Exact matching-coupling conclusion, *conditional on* the global
coupling-cancellation equality. This does not prove that equality for
an arbitrary quadratic product function. -/
theorem matching_amplitude_from_coupled_expectations
    {I : Type*} [Fintype I]
    (D : I → ℝ) (evenMean oddMean B : ℝ)
    (hconservation : (∑ i : I, |D i|) = 2 * (evenMean - oddMean))
    (heven : |evenMean| ≤ B) (hodd : |oddMean| ≤ B) :
    (∑ i : I, |D i|) ≤ 4 * B := by
  obtain ⟨hel, heu⟩ := abs_le.mp heven
  obtain ⟨hol, hou⟩ := abs_le.mp hodd
  rw [hconservation]
  linarith

/-- Exact composition of the proposed scalar quadratic certificate.

Each hypothesis below is a separate mathematical proof obligation:
hadd is the projected additive norm budget, hsections the switching
budget, hcost the matching amplitude budget, hzbudget the conditional
expectation reduction, hquadEnergy the fourth-moment interpolation,
and hV the ANOVA orthogonal energy decomposition.

Crucially these hypotheses are NOT all derived here from an actual f;
therefore this theorem is a certificate-composition theorem, not the
unrestricted arbitrary-product influence theorem. -/
theorem quadratic_certificate_closure
    {I : Type*} [Fintype I]
    (B R V : ℝ)
    (c u h z a s : I → ℝ)
    (hR : 0 ≤ R)
    (hB : 0 ≤ B)
    (hcpos : ∀ i, 0 ≤ c i)
    (hV : V ≤ (∑ i : I, a i) + (∑ i : I, s i))
    (hadd : (∑ i : I, h i) ≤ 7 * B)
    (hsections : (∑ i : I, u i) ≤ 8 * B)
    (hcost : (∑ i : I, c i) ≤ 8 * B)
    (hzbudget : ∀ i, z i ≤ u i + h i)
    (hzmax : ∀ i, z i ≤ R)
    (haddEnergy : ∀ i, a i ≤ R * h i)
    (hquadEnergy : ∀ i, s i ≤ c i * z i + (Real.sqrt 3 * R) * z i) :
    V ≤ (15 * (1 + Real.sqrt 3)) * B * R := by
  classical
  have hzs : (∑ i : I, z i) ≤ 15 * B := by
    calc
      (∑ i : I, z i) ≤ ∑ i : I, (u i + h i) :=
        Finset.sum_le_sum (fun i _ => hzbudget i)
      _ = (∑ i : I, u i) + (∑ i : I, h i) :=
        Finset.sum_add_distrib
      _ ≤ 15 * B := by linarith
  have hce : (∑ i : I, c i * z i) ≤ 8 * B * R := by
    calc
      (∑ i : I, c i * z i) ≤ ∑ i : I, c i * R := by
        apply Finset.sum_le_sum
        intro i _
        exact mul_le_mul_of_nonneg_left (hzmax i) (hcpos i)
      _ = (∑ i : I, c i) * R := by rw [Finset.sum_mul]
      _ ≤ 8 * B * R := mul_le_mul_of_nonneg_right hcost hR
  have hze : (∑ i : I, (Real.sqrt 3 * R) * z i) ≤
      (Real.sqrt 3 * R) * (15 * B) := by
    calc
      (∑ i : I, (Real.sqrt 3 * R) * z i) =
          (Real.sqrt 3 * R) * (∑ i : I, z i) := by rw [Finset.mul_sum]
      _ ≤ (Real.sqrt 3 * R) * (15 * B) :=
        mul_le_mul_of_nonneg_left hzs
          (mul_nonneg (Real.sqrt_nonneg 3) hR)
  have hae : (∑ i : I, a i) ≤ R * (7 * B) := by
    calc
      (∑ i : I, a i) ≤ ∑ i : I, R * h i :=
        Finset.sum_le_sum (fun i _ => haddEnergy i)
      _ = R * (∑ i : I, h i) := by rw [Finset.mul_sum]
      _ ≤ R * (7 * B) := mul_le_mul_of_nonneg_left hadd hR
  have hse : (∑ i : I, s i) ≤
      (8 * B * R) + ((Real.sqrt 3 * R) * (15 * B)) := by
    calc
      (∑ i : I, s i) ≤
          ∑ i : I, (c i * z i + (Real.sqrt 3 * R) * z i) :=
            Finset.sum_le_sum (fun i _ => hquadEnergy i)
      _ = (∑ i : I, c i * z i) +
          (∑ i : I, (Real.sqrt 3 * R) * z i) :=
            Finset.sum_add_distrib
      _ ≤ (8 * B * R) + ((Real.sqrt 3 * R) * (15 * B)) :=
        add_le_add hce hze
  calc
    V ≤ R * (7 * B) +
        ((8 * B * R) + ((Real.sqrt 3 * R) * (15 * B))) := by linarith
    _ = (15 * (1 + Real.sqrt 3)) * B * R := by ring

/-- Turning a variance-versus-sqrt-influence certificate into the
squared-variance influence inequality. This is the precise scale claimed
in v3; obtaining its premise from a real f is an independent obligation. -/
theorem squared_influence_of_quadratic_bound
    (V B M C : ℝ)
    (hV : 0 ≤ V) (hB : 0 ≤ B) (hM : 0 ≤ M) (hC : 0 ≤ C)
    (hbound : V ≤ C * B * Real.sqrt M) :
    V ^ 2 ≤ C ^ 2 * B ^ 2 * M := by
  have hq : 0 ≤ C * B * Real.sqrt M :=
    mul_nonneg (mul_nonneg hC hB) (Real.sqrt_nonneg M)
  have hp := mul_nonneg (sub_nonneg.mpr hbound) (add_nonneg hq hV)
  have hs : (Real.sqrt M) ^ 2 = M := Real.sq_sqrt hM
  nlinarith [hp]

end Nightfall.Observability.QuadraticV3
