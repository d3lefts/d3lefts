import Mathlib

/-!
# NIGHTFALL T2 — physical Hilbert pair-completion energy at actual frequencies

The unrestricted two-query paper introduces the pair-completed
physical path vectors \hat T_e = Σ_{a,b: a+b=e} Π_b U Π_a ψ.
The key \hat T-energy input to both zero-triple survivor bounds is

  Σ_{e∈F} ‖\hat T_e‖² ≤ M Σ_{b,a} ‖Π_b U Π_a ψ‖²,

where M bounds the *actual* ordered pair frequency fiber over F.
If ψ is normalized and U unitary, RHS ≤ M. This does NOT require
different paths in a fiber to be orthogonal, finite sector rank,
or any spectral assumption about P.

This source proves the universal Hilbert-vector frequency-fiber
operator via real Cauchy, norm triangle, and exact disjointness of
original index fibers. It applies to arbitrary possibly infinite-
dimensional complex Hilbert sector sums.

The C-survivor index family uses F=nonzero original legal labels;
the large e=0 pair fiber is not charged to the source M₂ bound.
That restriction and identification with actual Π_b U Π_a ψ are
separate final composition steps.
-/

namespace Nightfall.StructuralInformation.T2HatEnergy

open Finset

variable {I Z : Type*} [DecidableEq I] [DecidableEq Z]
variable {V : Type*} [NormedAddCommGroup V]

noncomputable def vectorFiber
    (S : Finset I) (freq : I → Z) (z : Z) : Finset I :=
  S.filter (fun i => freq i = z)

/-- Hilbert-vector Cauchy for the actual *norm of a sum* rather than
an imagined orthogonality of the summands. No dimension bound. -/
theorem norm_vector_sum_sq_le_card
    (S : Finset I) (v : I → V) :
    ‖∑ i ∈ S, v i‖ ^ 2 ≤
      (S.card : ℝ) * (∑ i ∈ S, ‖v i‖ ^ 2) := by
  have htriangle : ‖∑ i ∈ S, v i‖ ≤ ∑ i ∈ S, ‖v i‖ :=
    norm_sum_le _ _
  have hnonneg : 0 ≤ ∑ i ∈ S, ‖v i‖ :=
    Finset.sum_nonneg (fun i hi => norm_nonneg _)
  have hsq : ‖∑ i ∈ S, v i‖ ^ 2 ≤
      (∑ i ∈ S, ‖v i‖) ^ 2 :=
    (sq_le_sq₀ (norm_nonneg _) hnonneg).mpr htriangle
  have hcauchy :
      (∑ i ∈ S, ‖v i‖) ^ 2 ≤
      (S.card : ℝ) * (∑ i ∈ S, ‖v i‖ ^ 2) := by
    simpa using (Finset.sum_mul_sq_le_sq_mul_sq (R := ℝ) S
      (fun _ => 1) (fun i => ‖v i‖))
  exact hsq.trans hcauchy

/-- All frequency fibers are disjoint because they come from a
function of the *actual* original ordered index tuple. -/
theorem vector_fiber_disjoint_energy
    (S : Finset I) (F : Finset Z)
    (freq : I → Z) (f : I → ℝ)
    (hf : ∀ i, 0 ≤ f i) :
    (∑ z ∈ F, ∑ i ∈ vectorFiber S freq z, f i) ≤
      ∑ i ∈ S, f i := by
  have hsum :
      (∑ z ∈ F, ∑ i ∈ vectorFiber S freq z, f i) =
        ∑ i ∈ S, if freq i ∈ F then f i else 0 := by
    simp [vectorFiber, Finset.sum_filter, Finset.sum_comm]
  rw [hsum]
  apply Finset.sum_le_sum
  intro i _
  split_ifs
  · exact le_refl _
  · exact hf i

/-- Universal rank-free grouped Hilbert-energy bound for
*actual* finite source tuples, no assumed phase independence or
path orthogonality. -/
theorem pair_completed_energy_le_multiplicity
    (S : Finset I) (F : Finset Z)
    (freq : I → Z) (v : I → V)
    (M : ℕ)
    (hM : ∀ z ∈ F, (vectorFiber S freq z).card ≤ M) :
    (∑ z ∈ F, ‖∑ i ∈ vectorFiber S freq z, v i‖ ^ 2) ≤
      (M : ℝ) * (∑ i ∈ S, ‖v i‖ ^ 2) := by
  have hrow : ∀ z ∈ F,
      ‖∑ i ∈ vectorFiber S freq z, v i‖ ^ 2 ≤
        (M : ℝ) * (∑ i ∈ vectorFiber S freq z, ‖v i‖ ^ 2) := by
    intro z hz
    have hcard : ((vectorFiber S freq z).card : ℝ) ≤ M := by
      exact_mod_cast hM z hz
    calc
      _ ≤ ((vectorFiber S freq z).card : ℝ) *
          (∑ i ∈ vectorFiber S freq z, ‖v i‖ ^ 2) :=
          norm_vector_sum_sq_le_card _ v
      _ ≤ (M : ℝ) * (∑ i ∈ vectorFiber S freq z, ‖v i‖ ^ 2) :=
          mul_le_mul_of_nonneg_right hcard
            (Finset.sum_nonneg (fun i hi => sq_nonneg _))
  calc
    (∑ z ∈ F, ‖∑ i ∈ vectorFiber S freq z, v i‖ ^ 2) ≤
        ∑ z ∈ F, (M : ℝ) *
          (∑ i ∈ vectorFiber S freq z, ‖v i‖ ^ 2) := by
      apply Finset.sum_le_sum
      intro z hz
      exact hrow z hz
    _ = (M : ℝ) * (∑ z ∈ F,
          ∑ i ∈ vectorFiber S freq z, ‖v i‖ ^ 2) := by
      rw [Finset.mul_sum]
    _ ≤ (M : ℝ) * (∑ i ∈ S, ‖v i‖ ^ 2) := by
      apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg M)
      exact vector_fiber_disjoint_energy S F freq
        (fun i => ‖v i‖ ^ 2) (fun i => sq_nonneg _)

/-- Unit-mass corollary. In T2 the source mass is exactly ‖ψ‖²=1,
so the hat family over any legal nonzero frequency subset costs at
most M independent of output Hilbert rank. -/
theorem pair_completed_energy_le_M
    (S : Finset I) (F : Finset Z)
    (freq : I → Z) (v : I → V)
    (M : ℕ)
    (hM : ∀ z ∈ F, (vectorFiber S freq z).card ≤ M)
    (hunit : (∑ i ∈ S, ‖v i‖ ^ 2) ≤ 1) :
    (∑ z ∈ F, ‖∑ i ∈ vectorFiber S freq z, v i‖ ^ 2) ≤ M := by
  calc
    _ ≤ (M : ℝ) * (∑ i ∈ S, ‖v i‖ ^ 2) :=
      pair_completed_energy_le_multiplicity S F freq v M hM
    _ ≤ (M : ℝ) * 1 :=
      mul_le_mul_of_nonneg_left hunit (Nat.cast_nonneg M)
    _ = M := by ring

#print axioms Nightfall.StructuralInformation.T2HatEnergy.norm_vector_sum_sq_le_card
#print axioms Nightfall.StructuralInformation.T2HatEnergy.vector_fiber_disjoint_energy
#print axioms Nightfall.StructuralInformation.T2HatEnergy.pair_completed_energy_le_multiplicity
#print axioms Nightfall.StructuralInformation.T2HatEnergy.pair_completed_energy_le_M

end Nightfall.StructuralInformation.T2HatEnergy
