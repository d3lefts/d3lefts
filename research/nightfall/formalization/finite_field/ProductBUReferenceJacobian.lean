import Mathlib
import ProductBUOrbitCertificate
import ProductBUPerturbation

/-!
# Augmented reference map: exact endpoint Jacobian surjectivity

At time t=0 the parametrized product-sphere homotopy equals
F₀(u,v)=(tail u,tail v). Appending two sphere equations gives
Ψ₀(u,v)=(tail u,tail v,∑uᵢ²−1,∑vᵢ²−1).
At a zero, u,v are ± the first-coordinate axis. The spatial
derivative of Ψ₀ is
  (du,dv) ↦ (tail du,tail dv,2⟨u,du⟩,2⟨v,dv⟩).

This module certifies the linear SURJECTIVITY of that Jacobian at
all four reference zeros with a concrete right inverse. It does NOT
formalize the derivative identity itself, generic transversality,
regular-zero-set manifold structure, or ProductSphereZero.
-/

namespace Nightfall.ProductBUReferenceJacobian

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUOrbit
open Nightfall.ProductBUParity
open Nightfall.ProductBUPerturbation

/-- Right-inverse direction: first coordinate covers the radial
constraint; the tail covers the tangent output coordinates. -/
noncomputable def referenceDirection (k : ℕ)
    (u : Fin (k + 1) → ℝ) (rad : ℝ) (y : Fin k → ℝ) :
    Fin (k + 1) → ℝ :=
  Fin.cons ((rad / 2) * u 0) y

theorem referenceDirection_tail (k : ℕ)
    (u : Fin (k + 1) → ℝ) (rad : ℝ) (y : Fin k → ℝ)
    (i : Fin k) :
    referenceDirection k u rad y i.succ = y i := by
  simp [referenceDirection]

theorem referenceDirection_radial (k : ℕ)
    (u : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u)
    (htail : ∀ i : Fin k, u i.succ = 0)
    (rad : ℝ) (y : Fin k → ℝ) :
    2 * mixedDot (k + 1) u (referenceDirection k u rad y) = rad := by
  have hfirst : (u 0) ^ 2 = 1 := by
    rcases unit_tail_zero_first_sign k u hu htail with h | h
    · rw [h]
      norm_num
    · rw [h]
      norm_num
  have hsum : (∑ i : Fin k, u i.succ * y i) = 0 := by
    simp [htail]
  unfold mixedDot referenceDirection
  rw [Fin.sum_univ_succ]
  simp only [Fin.cons_zero, Fin.cons_succ, hsum, add_zero]
  calc
    2 * (u 0 * (rad / 2 * u 0)) = rad * (u 0) ^ 2 := by ring
    _ = rad := by rw [hfirst]; ring

/-- The exact full spatial Jacobian of the *augmented reference map*
is surjective at every reference zero, in ALL dimensions. -/
theorem reference_augmented_jacobian_surjective (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (htU : ∀ i : Fin k, refU k u v i = 0)
    (htV : ∀ i : Fin k, refV k u v i = 0)
    (radU radV : ℝ) (targetU targetV : Fin k → ℝ) :
    ∃ du dv : Fin (k + 1) → ℝ,
      (∀ i : Fin k, du i.succ = targetU i) ∧
      (∀ i : Fin k, dv i.succ = targetV i) ∧
      2 * mixedDot (k + 1) u du = radU ∧
      2 * mixedDot (k + 1) v dv = radV := by
  let du := referenceDirection k u radU targetU
  let dv := referenceDirection k v radV targetV
  refine ⟨du, dv, ?_, ?_, ?_, ?_⟩
  · intro i
    exact referenceDirection_tail k u radU targetU i
  · intro i
    exact referenceDirection_tail k v radV targetV i
  · exact referenceDirection_radial k u hu (fun i => htU i)
      radU targetU
  · exact referenceDirection_radial k v hv (fun i => htV i)
      radV targetV

#print axioms referenceDirection_tail
#print axioms referenceDirection_radial
#print axioms reference_augmented_jacobian_surjective

end Nightfall.ProductBUReferenceJacobian
