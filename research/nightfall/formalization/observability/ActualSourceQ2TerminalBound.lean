import ActualSourceSingletonEnergyBridge
import ActualSourceOwnedFourthClosure
import ActualProductQ2ScalarClosure

/-!
# Q2 terminal finite-product source-bound attempt, Lean 4.36.0-rc2

The only mathematical input to the terminal theorem is one genuine
nonnegative normalized finite product p, the actual degree <= 2 source f,
a pointwise bound |f| <= B, and an upper bound M on the *actual* source
coordinate influences. Every matching cost, owner, Hilbert moment, Jensen
budget and variance energy is derived from that same p and f.

Certification status is determined ONLY by strict current-head CI.
No theorem claim may be promoted from the presence of this file.
-/

namespace Nightfall.Observability.ActualSourceQ2TerminalBound

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceOwnedGraph
open Nightfall.Observability.ActualSourceFinitePairMoment
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceOwnedFourthClosure
open Nightfall.Observability.ActualProductQ2ScalarClosure
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- A normalized actual finite product law gives L1 <= sqrt(L2)
for a concrete recursively sampled finite-dimensional Hilbert vector.
No minimum positive mass is needed. -/
theorem original_independent_first_norm_le_sqrt_moment2
    (q : ℕ → α → ℝ)
    (Y : ℕ → α → α → ℝ)
    (n : ℕ)
    (hq : ∀ k b, 0 ≤ q k b)
    (hq1 : ∀ k, (∑ b : α, q k b) = 1)
    (M : ℝ) (hM0 : 0 ≤ M)
    (hM : moment2 q Y n ≤ M) :
    (∑ w : Samples α n, mass q n w *
      Real.sqrt (vecNormSq (sumVector Y n w))) ≤ Real.sqrt M := by
  classical
  let μ : Samples α n → ℝ := mass q n
  let v : Samples α n → ℝ := fun w =>
    Real.sqrt (vecNormSq (sumVector Y n w))
  have hμ : ∀ w : Samples α n, 0 ≤ μ w := by
    intro w
    exact mass_nonneg q hq n w
  have hsum : (∑ w : Samples α n, μ w * v w)^2 ≤
      (∑ w : Samples α n, μ w) *
        (∑ w : Samples α n, μ w * (v w)^2) := by
    exact Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
      (s := (Finset.univ : Finset (Samples α n)))
      (r := fun w => μ w * v w)
      (f := fun w => μ w)
      (g := fun w => μ w * (v w)^2)
      (fun w _ => hμ w)
      (fun w _ => mul_nonneg (hμ w) (sq_nonneg _))
      (fun w _ => by ring)
  have hmass : (∑ w : Samples α n, μ w) = 1 :=
    mass_one q hq1 n
  have henergy :
      (∑ w : Samples α n, μ w * (v w)^2) =
        moment2 q Y n := by
    unfold moment2
    apply Finset.sum_congr rfl
    intro w _
    dsimp [μ, v]
    rw [Real.sq_sqrt (vecNormSq_nonneg _)]
  have hz0 : 0 ≤ ∑ w : Samples α n, μ w * v w := by
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (hμ w) (Real.sqrt_nonneg _)
  have hzs : (∑ w : Samples α n, μ w * v w)^2 ≤ M := by
    calc
      (∑ w : Samples α n, μ w * v w)^2 ≤
        (∑ w : Samples α n, μ w) *
          (∑ w : Samples α n, μ w * (v w)^2) := hsum
      _ = moment2 q Y n := by rw [hmass, one_mul, henergy]
      _ ≤ M := hM
  have hroot := Real.sq_sqrt hM0
  have hroot0 := Real.sqrt_nonneg M
  change (∑ w : Samples α n, μ w * v w) ≤ Real.sqrt M
  nlinarith

/-- Terminal Q2 proof target from ONE actual original finite product.
The influence cap is on the true source quantity, not on synthetic
pair energy or any auxiliary moment. -/
theorem original_source_degree_two_variance_sq_le_influence
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B)
    (M : ℝ) (hM0 : 0 ≤ M)
    (hM : ∀ i, sourceInfluence p f i ≤ M) :
    (sourceVariance p f)^2 ≤
      (16 * (1 + Real.sqrt 3))^2 * B^2 * M := by
  classical
  obtain ⟨c, hc, hcost, howned, hztotal⟩ :=
    original_source_generated_fourth_and_jensen_package
      p hp hp1 f hdegree B hB hf M hM
  let a : ι → ℝ := originalSingletonNorm p f
  let s : ι → ℝ := fun i =>
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    moment2 (fun k => p (j k))
      (finitePairIncrement p f i j J.card) J.card
  let z : ι → ℝ := fun i =>
    let J := ownedNeighbors c i
    let j := neighborIndex i J
    let Y := finitePairIncrement p f i j J.card
    ∑ w : Samples α J.card, mass (fun k => p (j k)) J.card w *
      Real.sqrt (vecNormSq (sumVector Y J.card w))
  have ha0 : ∀ i, 0 ≤ a i := by
    intro i
    exact Real.sqrt_nonneg _
  have hz0 : ∀ i, 0 ≤ z i := by
    intro i
    dsimp [z]
    apply Finset.sum_nonneg
    intro w _
    apply mul_nonneg
    · exact mass_nonneg
        (fun k => p (neighborIndex i (ownedNeighbors c i) k))
        (fun k b => hp _ b) _ w
    · exact Real.sqrt_nonneg _
  have haT : ∀ i, a i ≤ Real.sqrt M := by
    intro i
    exact original_singleton_norm_le_sqrt_influence_cap
      p hp hp1 f hdegree i M hM0 (hM i)
  have hzT : ∀ i, z i ≤ Real.sqrt M := by
    intro i
    have henergy := (howned i).1
    exact original_independent_first_norm_le_sqrt_moment2
      (fun k => p (neighborIndex i (ownedNeighbors c i) k))
      (finitePairIncrement p f i
        (neighborIndex i (ownedNeighbors c i))
        (ownedNeighbors c i).card)
      (ownedNeighbors c i).card
      (fun k b => hp _ b)
      (fun k => hp1 _)
      M hM0 (henergy.trans (hM i))
  have hstep : ∀ i, s i ≤
      z i * (c i + Real.sqrt 3 * Real.sqrt M) := by
    intro i
    have h := (howned i).2.1
    have hsqrt : Real.sqrt (3 * M) = Real.sqrt 3 * Real.sqrt M :=
      Real.sqrt_mul (by norm_num : (0 : ℝ) ≤ 3) M
    dsimp [s, z] at ⊢
    rw [← hsqrt]
    exact h
  have habudget : (∑ i : ι, a i) ≤ 8 * B :=
    original_singleton_norm_sum_le_eight
      p hp hp1 f hdegree B hB hf
  have hzbudget : (∑ i : ι, z i) ≤ 16 * B := by
    exact hztotal
  have hvariance : sourceVariance p f =
      (∑ i : ι, (a i)^2) + ∑ i : ι, s i :=
    original_source_variance_eq_singleton_plus_owned_moment2
      p hp hp1 f hdegree c
  have hV : 0 ≤ sourceVariance p f := by
    unfold sourceVariance
    apply Finset.sum_nonneg
    intro x _
    apply mul_nonneg
    · unfold originalMass
      exact Finset.prod_nonneg (fun i _ => hp i (x i))
    · exact sq_nonneg _
  have hsq : (Real.sqrt M)^2 = M := Real.sq_sqrt hM0
  have hnum := q2_scalar_endpoint_squared
    a c z s B (Real.sqrt M) M 8 (Real.sqrt 3) (sourceVariance p f)
    hB (Real.sqrt_nonneg _) hV
    (by norm_num) (Real.sqrt_nonneg _)
    ha0 hc hz0 haT hzT hstep
    habudget hcost (by
      convert hzbudget using 1 <;> norm_num)
    hvariance hsq
  have hcoef : (8 + (8 : ℝ)) * (1 + Real.sqrt 3) =
      16 * (1 + Real.sqrt 3) := by ring
  rw [hcoef] at hnum
  exact hnum

end Nightfall.Observability.ActualSourceQ2TerminalBound
