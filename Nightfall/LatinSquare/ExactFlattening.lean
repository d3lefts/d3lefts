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

#print axioms Nightfall.LatinSquare.weighted_ratio_balance
#print axioms Nightfall.LatinSquare.soft_forward_atom
#print axioms Nightfall.LatinSquare.soft_forward_sum
#print axioms Nightfall.LatinSquare.stage_gate_identity
#print axioms Nightfall.LatinSquare.flattenMass_eq
#print axioms Nightfall.LatinSquare.normalized_flatten_mass
#print axioms Nightfall.LatinSquare.normalize_weighted_mass
#print axioms Nightfall.LatinSquare.weighted_flatten_normalizes

end Nightfall.LatinSquare
