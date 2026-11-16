import Mathlib
import PhysicalPOVMCompression
import BayesPOVMCorner

/-!
NIGHTFALL: physical arbitrary-dimensional POVM Bayes-gain bound.

This module derives the coherent-matrix-element constraint and the diagonal
normalization from actual complex Hermitian positive semidefinite effects
summing to identity, for ALL finite POVM outcome spaces.

The remaining hypothesis `hBorn` is precisely the lower bound of the actual
Born probability by the contributions of the two GHZ rays. It follows from
a positive diagonal source average with those weights; formalizing that
source-average identification in the same kernel dependency graph is a
separate obligation.
-/

namespace Nightfall.Quantum.ComplexPOVM

open scoped BigOperators ComplexOrder
open Matrix
open Nightfall.Quantum.PhysicalPOVM
open Nightfall.Quantum.BayesCorner

theorem effects_diagonal_normalized
    {ι Out : Type*} [Fintype ι] [DecidableEq ι] [Fintype Out]
    (E : Out → Matrix ι ι ℂ)
    (hcomplete : (∑ z, E z) = 1)
    (a : ι) :
    (∑ z, (E z a a).re) = 1 := by
  classical
  have hentry : (∑ z, E z a a) = 1 := by
    have h := congrArg (fun M : Matrix ι ι ℂ => M a a) hcomplete
    simpa [Matrix.sum_apply] using h
  have hmap (s : Finset Out) :
      Complex.re (s.sum (fun z => E z a a)) =
        s.sum (fun z => Complex.re (E z a a)) := by
    induction s using Finset.induction_on with
    | empty => simp
    | @insert z s hz ih => simp [Finset.sum_insert hz, Complex.add_re, ih]
  have hre := congrArg Complex.re hentry
  simpa only [hmap Finset.univ, Complex.one_re] using hre

theorem complex_povm_energy_optimal
    {ι Out : Type*} [Fintype ι] [DecidableEq ι] [Fintype Out]
    (E : Out → Matrix ι ι ℂ)
    (hpositive : ∀ z, (E z).PosSemidef)
    (hcomplete : (∑ z, E z) = 1)
    (a b : ι) (w : Out → ℝ) (u v t : ℝ)
    (hu : 0 < u) (hv : 0 < v)
    (hBorn : ∀ z,
      u * (E z a a).re + v * (E z b b).re ≤ w z) :
    (∑ z, (2 * t * (E z a b).re) ^ 2 / w z) ≤
      4 * t ^ 2 / (u + v) := by
  classical
  apply physical_bayes_gain_upper u v t hu hv
    (fun z => (E z a a).re)
    (fun z => (E z b b).re)
    (fun z => (E z a b).re)
    w
  · intro z
    exact (RCLike.nonneg_iff.mp ((hpositive z).diag_nonneg (i := a))).1
  · intro z
    exact (RCLike.nonneg_iff.mp ((hpositive z).diag_nonneg (i := b))).1
  · intro z
    exact complex_psd_compressed_gram (E z) (hpositive z) a b
  · exact hBorn
  · exact effects_diagonal_normalized E hcomplete a
  · exact effects_diagonal_normalized E hcomplete b

#print axioms Nightfall.Quantum.ComplexPOVM.effects_diagonal_normalized
#print axioms Nightfall.Quantum.ComplexPOVM.complex_povm_energy_optimal

end Nightfall.Quantum.ComplexPOVM
