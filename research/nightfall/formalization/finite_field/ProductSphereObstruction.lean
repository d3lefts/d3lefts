import Mathlib

/-!
# Product-sphere obstruction: exact algebra and the honest topology interface

The causal collision theorem is already proved separately in PR #1008, conditional
on a simultaneous zero. This file does NOT assert that the simultaneous zero
exists. `ProductSphereZero` is a *Prop-valued statement*, not a theorem or axiom.

The finite coefficient model is the additive basis of
  F₂[α, β] / (αⁿ, βⁿ).
Its two checked nonvanishing assertions correspond to:
* unknown norm: αʳ βˢ with r,s < n;
* known norm: αⁿ⁻¹ βⁿ⁻² (α + β).

Only the coefficient arithmetic below is kernel-checked. The step identifying
these polynomials with top Stiefel–Whitney classes, and proving that a nonzero
class forces a zero for every continuous equivariant map, is NOT formalized here.

Reference: Chan–Chen–Frick–Hull (2019), Theorem 2.5 / Remark 2.7.
-/

namespace Nightfall.ProductSphereObstruction

/-- The finite coefficient array of the truncated two-generator mod-2 ring. -/
abbrev CoeffGrid (n : ℕ) := Fin n → Fin n → ZMod 2

/-- A single monomial α^r β^s, truncated by α^n = β^n = 0. -/
def monomial (n r s : ℕ) : CoeffGrid n :=
  fun i j => if i.val = r ∧ j.val = s then 1 else 0

theorem monomial_nonzero (n r s : ℕ) (hr : r < n) (hs : s < n) :
    monomial n r s ≠ 0 := by
  intro h
  have hval := congrArg
    (fun f : CoeffGrid n => f ⟨r, hr⟩ ⟨s, hs⟩) h
  simp [monomial] at hval

/-- Multiplication of a monomial by the mixed character (α + β). -/
def mixedProduct (n r s : ℕ) : CoeffGrid n :=
  monomial n (r + 1) s + monomial n r (s + 1)

/-- The top coefficient of α^(n-1) β^(n-2) (α + β) is 1. -/
theorem mixed_top_coefficient (n : ℕ) (hn : 2 ≤ n) :
    mixedProduct n (n - 1) (n - 2)
      ⟨n - 1, by omega⟩ ⟨n - 1, by omega⟩ = 1 := by
  have ha : (n - 1) + 1 = n := by omega
  have hb : (n - 2) + 1 = n - 1 := by omega
  have hc : n - 1 ≠ n := by omega
  simp [mixedProduct, monomial, ha, hb, hc]

theorem mixedProduct_nonzero (n : ℕ) (hn : 2 ≤ n) :
    mixedProduct n (n - 1) (n - 2) ≠ 0 := by
  intro h
  have hval := congrArg
    (fun f : CoeffGrid n => f ⟨n - 1, by omega⟩ ⟨n - 1, by omega⟩) h
  rw [mixed_top_coefficient n hn] at hval
  simp at hval

/-- The mixed character is represented geometrically by the ordinary dot product. -/
def mixedDot (n : ℕ) (u v : Fin n → ℝ) : ℝ :=
  ∑ i, u i * v i

/-- The mixed coordinate changes sign under the first antipode. -/
theorem mixedDot_flip_left (n : ℕ) (u v : Fin n → ℝ) :
    mixedDot n (-u) v = -mixedDot n u v := by
  simp [mixedDot, Finset.sum_neg_distrib]

/-- The mixed coordinate also changes sign under the second antipode. -/
theorem mixedDot_flip_right (n : ℕ) (u v : Fin n → ℝ) :
    mixedDot n u (-v) = -mixedDot n u v := by
  simp [mixedDot, Finset.sum_neg_distrib]

/-- The geometric mixed-character coordinate is continuous. -/
theorem continuous_mixedDot (n : ℕ) :
    Continuous (fun p : (Fin n → ℝ) × (Fin n → ℝ) =>
      mixedDot n p.1 p.2) := by
  unfold mixedDot
  fun_prop

/-- Unit vectors, represented by sum-of-squares to make the interface
independent of coordinate norm conventions. -/
def UnitVec (n : ℕ) (u : Fin n → ℝ) : Prop :=
  (∑ i, u i ^ 2) = 1

/-- The product of the two unit spheres, with their subspace topology. -/
def SpherePair (n : ℕ) : Set ((Fin n → ℝ) × (Fin n → ℝ)) :=
  { p | UnitVec n p.1 ∧ UnitVec n p.2 }

/--
The EXACT external topology obligation in the unknown-norm causal proof.
The two blocks transform by the two *separate* antipodal characters.
Continuity and sign rules are required only on the sphere product.

This is only a proposition. In particular, NO theorem of this name and
NO axiom proving it is provided in this module.
-/
def ProductSphereZero (n r s : ℕ) : Prop :=
  ∀ (fU : (Fin n → ℝ) → (Fin n → ℝ) → Fin r → ℝ)
    (fV : (Fin n → ℝ) → (Fin n → ℝ) → Fin s → ℝ),
    (∀ i, ContinuousOn
      (fun p : (Fin n → ℝ) × (Fin n → ℝ) => fU p.1 p.2 i)
      (SpherePair n)) →
    (∀ i, ContinuousOn
      (fun p : (Fin n → ℝ) × (Fin n → ℝ) => fV p.1 p.2 i)
      (SpherePair n)) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fU (-u) v i = -fU u v i) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fU u (-v) i = fU u v i) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fV (-u) v i = fV u v i) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fV u (-v) i = -fV u v i) →
    ∃ u v, UnitVec n u ∧ UnitVec n v ∧
      (∀ i, fU u v i = 0) ∧ (∀ i, fV u v i = 0)


/-- Squared Euclidean norm in coordinates, without choosing a square root. -/
def sqNorm (n : ℕ) (u : Fin n → ℝ) : ℝ :=
  ∑ i, (u i) ^ 2

/-- Exact polarization identity for the two candidate phase-retrieval signals. -/
theorem sqNorm_plus_minus_difference (n : ℕ) (u v : Fin n → ℝ) :
    sqNorm n (u + v) - sqNorm n (u - v) = 4 * mixedDot n u v := by
  unfold sqNorm mixedDot
  simp only [Pi.add_apply, Pi.sub_apply]
  rw [← Finset.sum_sub_distrib]
  calc
    (∑ i, ((u i + v i) ^ 2 - (u i - v i) ^ 2)) =
      ∑ i, 4 * (u i * v i) := by
        apply Finset.sum_congr rfl
        intro i hi
        ring
    _ = 4 * ∑ i, u i * v i := by rw [Finset.mul_sum]

/-- A zero of the mixed character forces equal squared norms. -/
theorem sqNorm_eq_of_mixedDot_zero (n : ℕ) (u v : Fin n → ℝ)
    (hz : mixedDot n u v = 0) :
    sqNorm n (u + v) = sqNorm n (u - v) := by
  have h := sqNorm_plus_minus_difference n u v
  rw [hz] at h
  linarith

/-- Unit vectors cannot be the zero vector. -/
theorem unitVec_ne_zero (n : ℕ) (u : Fin n → ℝ)
    (hu : UnitVec n u) : u ≠ 0 := by
  intro hz
  unfold UnitVec at hu
  simp [hz] at hu

/-- The candidate pair is distinct modulo the global sign action. -/
theorem plus_minus_sign_distinct (n : ℕ) (u v : Fin n → ℝ)
    (hu : UnitVec n u) (hv : UnitVec n v) :
    (u + v ≠ u - v) ∧ (u + v ≠ -(u - v)) := by
  have hu0 := unitVec_ne_zero n u hu
  have hv0 := unitVec_ne_zero n v hv
  constructor
  · intro h
    have hzero : v = 0 := by
      ext i
      have hi := congrArg (fun w : Fin n → ℝ => w i) h
      simp only [Pi.add_apply, Pi.sub_apply] at hi
      change v i = (0 : ℝ)
      linarith
    exact hv0 hzero
  · intro h
    have hzero : u = 0 := by
      ext i
      have hi := congrArg (fun w : Fin n → ℝ => w i) h
      simp only [Pi.add_apply, Pi.sub_apply, Pi.neg_apply] at hi
      change u i = (0 : ℝ)
      linarith
    exact hu0 hzero

/-- Geometric conclusion used by the known-norm phase-retrieval argument.
This is conditional only on orthogonality, not on any topological theorem. -/
theorem known_sphere_geometry (n : ℕ) (u v : Fin n → ℝ)
    (hu : UnitVec n u) (hv : UnitVec n v)
    (hzero : mixedDot n u v = 0) :
    sqNorm n (u + v) = sqNorm n (u - v) ∧
    (u + v ≠ u - v) ∧ (u + v ≠ -(u - v)) := by
  exact ⟨sqNorm_eq_of_mixedDot_zero n u v hzero,
    plus_minus_sign_distinct n u v hu hv⟩

/--
Separate topology obligation for a mixed-character extra coordinate.
The third coordinate changes sign under both independent antipodes.
This is NOT a theorem and is NOT implied by the pure-character predicate
without an additional topological argument.
-/
def ProductSphereMixedZero (n r s : ℕ) : Prop :=
  ∀ (fU : (Fin n → ℝ) → (Fin n → ℝ) → Fin r → ℝ)
    (fV : (Fin n → ℝ) → (Fin n → ℝ) → Fin s → ℝ)
    (fM : (Fin n → ℝ) → (Fin n → ℝ) → ℝ),
    (∀ i, ContinuousOn
      (fun p : (Fin n → ℝ) × (Fin n → ℝ) => fU p.1 p.2 i)
      (SpherePair n)) →
    (∀ i, ContinuousOn
      (fun p : (Fin n → ℝ) × (Fin n → ℝ) => fV p.1 p.2 i)
      (SpherePair n)) →
    ContinuousOn (fun p : (Fin n → ℝ) × (Fin n → ℝ) => fM p.1 p.2)
      (SpherePair n) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fU (-u) v i = -fU u v i) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fU u (-v) i = fU u v i) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fV (-u) v i = fV u v i) →
    (∀ u v i, UnitVec n u → UnitVec n v →
      fV u (-v) i = -fV u v i) →
    (∀ u v, UnitVec n u → UnitVec n v →
      fM (-u) v = -fM u v) →
    (∀ u v, UnitVec n u → UnitVec n v →
      fM u (-v) = -fM u v) →
    ∃ u v, UnitVec n u ∧ UnitVec n v ∧
      (∀ i, fU u v i = 0) ∧ (∀ i, fV u v i = 0) ∧
      fM u v = 0


#print axioms sqNorm_plus_minus_difference
#print axioms sqNorm_eq_of_mixedDot_zero
#print axioms unitVec_ne_zero
#print axioms plus_minus_sign_distinct
#print axioms known_sphere_geometry
#check ProductSphereMixedZero

#print axioms monomial_nonzero
#print axioms mixed_top_coefficient
#print axioms mixedProduct_nonzero
#print axioms mixedDot_flip_left
#print axioms mixedDot_flip_right
#print axioms continuous_mixedDot
#check ProductSphereZero

end Nightfall.ProductSphereObstruction
