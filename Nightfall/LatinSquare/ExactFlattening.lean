import Mathlib

/-!
# Exact soft gate and multiscale algebra for Latin-square sampling

Scope: algebraic sublemmas extracted from Mira Cult's pinned
"Exact uniform generation of labeled Latin squares", commit
30ddaaad27b48df2002225c3e3f40cffd02c5253.

The lemmas below do NOT certify the paper's all-target mean-log coverage,
the regular-board counting theorem, the Bernoulli factory or its cost,
the exact perfect-matching backend, or the n^25 expected-bit-work result.

Source: https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling
-/

namespace Nightfall.LatinSquare

/-- The rational likelihood ratio balances the forward and reverse atoms.
Here `q` is the forward probability, `r` the reverse probability,
and `w` the desired unnormalized target weight. -/
theorem weighted_ratio_balance (q r w : ℚ) (hq : q ≠ 0) :
    q * (w * r / q) = w * r := by
  field_simp [hq]

/-- The soft forward gate has the weighted reverse-history mass.
No numerical approximation or probability assumption is used here. -/
theorem soft_forward_atom (q r w t h : ℚ)
    (balance : q * t = w * r) :
    q * (t / (t + h)) = (w * r) / (t + h) := by
  calc
    q * (t / (t + h)) = (q * t) / (t + h) := by ring
    _ = (w * r) / (t + h) := by rw [balance]

/-- The soft-gate identity summed over an arbitrary finite history set. -/
theorem soft_forward_sum
    (α : Type*) [Fintype α]
    (q r w t : α → ℚ) (h : ℚ)
    (balance : ∀ z, q z * t z = w z * r z) :
    (∑ z, q z * (t z / (t z + h))) =
      ∑ z, (w z * r z) / (t z + h) := by
  apply Finset.sum_congr rfl
  intro z hz
  exact soft_forward_atom (q z) (r z) (w z) (t z) h (balance z)

/-- This rational identity is the per-level cancellation required by
the multiscale telescoping proof. -/
theorem stage_gate_identity (u f : ℚ) (h : u + f ≠ 0) :
    f * (u / (u + f)) = u * (1 - u / (u + f)) := by
  field_simp [h]
  ring

/-- The abstract telescoping recurrence for an arbitrary sequence of exact
per-level gates. The scalar `a` is the (possibly nonuniform) target weight.
A finite terminal stage contributes `a*u`. -/
def flattenMass (a u : ℚ) : List ℚ → ℚ
  | [] => a * u
  | r :: rs => a * u * (1 - r) + r * flattenMass a u rs

/-- The total corrected mass is exactly proportional to the target weight,
independent of every intermediate gate probability. -/
theorem flattenMass_eq (a u : ℚ) (rs : List ℚ) :
    flattenMass a u rs = a * u := by
  induction rs with
  | nil =>
      rfl
  | cons r rs ih =>
      simp only [flattenMass]
      rw [ih]
      ring

/-- The same telescoping identity after introducing an arbitrary common
nonzero scale. This is algebra, not a runtime certificate. -/
theorem normalized_flatten_mass
    (a u scale : ℚ) (rs : List ℚ) :
    flattenMass a u rs / scale = (a * u) / scale := by
  rw [flattenMass_eq]

/-- A finite output law with target masses c * weight has normalized
distribution exactly proportional to the target weight. This is the
conditioning-on-acceptance step, not a theorem that the concrete Mira
sampler satisfies its hypotheses. -/
theorem normalize_weighted_mass
    (α : Type*) [Fintype α]
    (mass weight : α → ℚ) (c : ℚ)
    (hc : c ≠ 0)
    (hweight : (∑ z, weight z) ≠ 0)
    (hmass : ∀ z, mass z = c * weight z)
    (s : α) :
    mass s / (∑ z, mass z) = weight s / (∑ z, weight z) := by
  have htotal : (∑ z, mass z) = c * (∑ z, weight z) := by
    simp_rw [hmass]
    rw [Finset.mul_sum]
  rw [hmass, htotal]
  field_simp [hc, hweight] <;> ring

/-- The weighted telescoping expression, normalized after a successful
non-null trial, has exactly the desired finite target distribution. -/
theorem weighted_flatten_normalizes
    (α : Type*) [Fintype α]
    (weight : α → ℚ) (u : ℚ) (hu : u ≠ 0)
    (hweight : (∑ z, weight z) ≠ 0)
    (gates : α → List ℚ) (s : α) :
    flattenMass (weight s) u (gates s) /
      (∑ z, flattenMass (weight z) u (gates z)) =
        weight s / (∑ z, weight z) := by
  apply normalize_weighted_mass α (fun z => flattenMass (weight z) u (gates z)) weight u
    hu hweight
  · intro z
    rw [flattenMass_eq]
    ring

/-!
## Finite kernel bridge

These definitions describe exact finite subprobability *masses*.
There is no random executable, measure-space cost bound, or positivity
certificate in this module. The identities make explicit which atoms
the weighted multiscale correction must preserve.
-/

/-- Total forward mass after a scale-a soft gate on a finite history set. -/
def softForwardKernelMass (η : Type*) [Fintype η]
    (q t : η → ℚ) (a : ℚ) : ℚ :=
  ∑ z, q z * (t z / (t z + a))

/-- Total reverse soft-coin mass at scale a. -/
def softReverseKernelMass (η : Type*) [Fintype η]
    (r t : η → ℚ) (a : ℚ) : ℚ :=
  ∑ z, r z * (a / (t z + a))

/-- The actual finite-history forward and reverse soft gates agree by
the weighted likelihood-ratio balance q(z)*t(z)=w*r(z).
This assumes only exact finite rational atoms, a nonzero scale,
and nonzero local denominators; it does not assert a sampler exists. -/
theorem softKernelMass_balance
    (η : Type*) [Fintype η]
    (q r t : η → ℚ) (w a : ℚ)
    (ha : a ≠ 0)
    (hden : ∀ z, t z + a ≠ 0)
    (hbalance : ∀ z, q z * t z = w * r z) :
    softForwardKernelMass η q t a =
      (w / a) * softReverseKernelMass η r t a := by
  unfold softForwardKernelMass softReverseKernelMass
  calc
    (∑ z, q z * (t z / (t z + a))) =
        ∑ z, (w * r z) / (t z + a) := by
          apply Finset.sum_congr rfl
          intro z hz
          exact soft_forward_atom (q z) (r z) w (t z) a (hbalance z)
    _ = ∑ z, (w / a) * (r z * (a / (t z + a))) := by
          apply Finset.sum_congr rfl
          intro z hz
          field_simp [ha, hden z]
          ring
    _ = (w / a) * ∑ z, r z * (a / (t z + a)) := by
          rw [Finset.mul_sum]

/-- The observable reverse coin times its integer scale is the
calibration f_m used in the multiscale proof. -/
def scaledReverseKernelMass (η : Type*) [Fintype η]
    (r t : η → ℚ) (H m : ℚ) : ℚ :=
  m * softReverseKernelMass η r t (H / m)

/-- The scale-H/m forward proposal mass for a prescribed target is
w*f_m/H, where f_m is computed solely from the reverse kernel. -/
theorem scaledKernelMass_balance
    (η : Type*) [Fintype η]
    (q r t : η → ℚ) (w H m : ℚ)
    (hH : H ≠ 0) (hm : m ≠ 0)
    (hden : ∀ z, t z + H / m ≠ 0)
    (hbalance : ∀ z, q z * t z = w * r z) :
    softForwardKernelMass η q t (H / m) =
      (w / H) * scaledReverseKernelMass η r t H m := by
  have ha : H / m ≠ 0 := div_ne_zero hH hm
  rw [softKernelMass_balance η q r t w (H / m) ha hden hbalance]
  unfold scaledReverseKernelMass
  have hcoeff : w / (H / m) = (w / H) * m := by
    field_simp [hH, hm]
    ring
  rw [hcoeff]
  ring

/-- A finite-level correction in operational form: the actual soft
forward mass w*f/H is multiplied by the race bias u/(u+f).
If that attempt fails at the race, the next scale is considered.
The empty list is the final exact inverse u/f gate's mass. -/
def correctedLevelMass (w H u : ℚ) : List ℚ → ℚ
  | [] => w * u / H
  | f :: fs =>
      (w * f / H) * (u / (u + f)) +
        (u / (u + f)) * correctedLevelMass w H u fs

/-- The concrete finite-level correction telescopes without assuming
the f values are constant across targets or scales. -/
theorem correctedLevelMass_eq
    (w H u : ℚ) (hH : H ≠ 0) (fs : List ℚ) :
    (∀ f ∈ fs, u + f ≠ 0) →
    correctedLevelMass w H u fs = w * u / H := by
  induction fs with
  | nil =>
      intro _
      rfl
  | cons f fs ih =>
      intro hden
      have hf : u + f ≠ 0 := hden f (by simp)
      have ht : ∀ g ∈ fs, u + g ≠ 0 := by
        intro g hg
        exact hden g (by simp [hg])
      simp only [correctedLevelMass]
      rw [ih ht]
      field_simp [hH, hf]
      ring

/-- A finite exact non-null output law for target-dependent lists of
kernel calibration values is the prescribed target-weight distribution.
This assumes the denominator hypotheses and does not infer them. -/
theorem correctedKernelMass_normalizes
    (α : Type*) [Fintype α]
    (weight : α → ℚ) (H u : ℚ)
    (hH : H ≠ 0) (hu : u ≠ 0)
    (hweight : (∑ z, weight z) ≠ 0)
    (calibrations : α → List ℚ)
    (hden : ∀ s f, f ∈ calibrations s → u + f ≠ 0)
    (s : α) :
    correctedLevelMass (weight s) H u (calibrations s) /
      (∑ z, correctedLevelMass (weight z) H u (calibrations z)) =
        weight s / (∑ z, weight z) := by
  apply normalize_weighted_mass α
    (fun z => correctedLevelMass (weight z) H u (calibrations z))
    weight (u / H) (div_ne_zero hu hH) hweight
  · intro z
    rw [correctedLevelMass_eq (weight z) H u hH (calibrations z)]
    · ring
    · intro f hf
      exact hden z f hf

#print axioms Nightfall.LatinSquare.weighted_ratio_balance
#print axioms Nightfall.LatinSquare.soft_forward_atom
#print axioms Nightfall.LatinSquare.soft_forward_sum
#print axioms Nightfall.LatinSquare.stage_gate_identity
#print axioms Nightfall.LatinSquare.flattenMass_eq
#print axioms Nightfall.LatinSquare.normalized_flatten_mass
#print axioms Nightfall.LatinSquare.normalize_weighted_mass
#print axioms Nightfall.LatinSquare.weighted_flatten_normalizes
#print axioms Nightfall.LatinSquare.softKernelMass_balance
#print axioms Nightfall.LatinSquare.scaledKernelMass_balance
#print axioms Nightfall.LatinSquare.correctedLevelMass_eq
#print axioms Nightfall.LatinSquare.correctedKernelMass_normalizes

end Nightfall.LatinSquare
