import Mathlib
import ProductBUSphereCompact

/-!
# Product-sphere augmented zero-fiber: exact compactness and endpoint exclusion

One prerequisite for completing the regular one-manifold-with-boundary
construction in the maximal pure-character product Borsuk-Ulam theorem.

Given ANY continuous Euclidean-valued augmented homotopy F, its zeros
on the exact product sphere and the closed time slab [0,1] form a
compact set. If the t=1 slice is zero-free, that compact zero set has
no t=1 endpoint. No manifold structure, transversality, parity, or
topological zero theorem is assumed or proved here.

This module deliberately imports the exact source of the parallel
#1055/#1063 sphere compactness theorem rather than copying it.
-/

namespace Nightfall.ProductBUCompactFiber

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSphereCompact

abbrev PairSpace (n : ℕ) := (Fin n → ℝ) × (Fin n → ℝ)
abbrev SpaceTime (n : ℕ) := PairSpace n × ℝ
abbrev Values (m : ℕ) := Fin m → ℝ

/-- Exact product-sphere domain, restricted to the closed homotopy time slab. -/
def domain (n : ℕ) : Set (SpaceTime n) :=
  SpherePair n ×ˢ Set.Icc (0 : ℝ) 1

/-- Actual regular-fiber candidate as a SET, without assuming regularity. -/
def zeroFiber (n m : ℕ) (F : SpaceTime n → Values m) : Set (SpaceTime n) :=
  domain n ∩ F ⁻¹' {0}

/-- Every continuous augmented response has a compact zero fiber on the
closed product-sphere time slab, whether or not the value zero is regular. -/
theorem zeroFiber_isCompact (n m : ℕ)
    (F : SpaceTime n → Values m) (hF : Continuous F) :
    IsCompact (zeroFiber n m F) := by
  have hd : IsCompact (domain n) := by
    exact (spherePair_isCompact n).prod isCompact_Icc
  have hzero : IsClosed (F ⁻¹' {(0 : Values m)}) :=
    isClosed_singleton.preimage hF
  exact hd.inter_right hzero

/-- Any point in the zero fiber has a genuine sphere pair and a legal
time coordinate, not a phantom ambient-space zero. -/
theorem zeroFiber_mem (n m : ℕ) (F : SpaceTime n → Values m)
    {p : SpaceTime n} (hp : p ∈ zeroFiber n m F) :
    p.1 ∈ SpherePair n ∧ p.2 ∈ Set.Icc (0 : ℝ) 1 ∧ F p = 0 := by
  exact ⟨hp.1.1, hp.1.2, hp.2⟩

/-- If the t=1 section is nowhere zero on the original product sphere,
there are no zero-fiber points on that endpoint. -/
theorem zeroFiber_no_one_face (n m : ℕ)
    (F : SpaceTime n → Values m)
    (hface : ∀ z ∈ SpherePair n, F (z, (1 : ℝ)) ≠ 0)
    {p : SpaceTime n} (hp : p ∈ zeroFiber n m F) :
    p.2 ≠ 1 := by
  intro h
  have hz := zeroFiber_mem n m F hp
  rcases p with ⟨z, t⟩
  change t = 1 at h
  subst t
  exact (hface z hz.1) hz.2.2

#print zeroFiber_isCompact
#print axioms zeroFiber_isCompact
#print zeroFiber_mem
#print axioms zeroFiber_mem
#print zeroFiber_no_one_face
#print axioms zeroFiber_no_one_face

end Nightfall.ProductBUCompactFiber
