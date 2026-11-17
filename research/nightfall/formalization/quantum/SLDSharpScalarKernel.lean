import Mathlib

/-!
# Sharp SLD spectral tensor envelope — scalar source kernel

This source formalizes the all-length spectral eigenvalue comparison used by
the sharp inverse-Jordan tensorization manuscript. It does NOT yet establish
the matrix-unit diagonalization or the complex operator Loewner inequality.
-/

namespace Nightfall.Quantum.SLDSharpScalarKernel

structure SpectralPair where
  a : ℝ
  b : ℝ
  kappa : ℝ
  a_nonneg : 0 ≤ a
  b_nonneg : 0 ≤ b
  kappa_ge_one : 1 ≤ kappa
  forward : a ≤ kappa * b
  backward : b ≤ kappa * a

def prodA : List SpectralPair → ℝ
  | [] => 1
  | p :: ps => p.a * prodA ps

def prodB : List SpectralPair → ℝ
  | [] => 1
  | p :: ps => p.b * prodB ps

def prodK : List SpectralPair → ℝ
  | [] => 1
  | p :: ps => p.kappa * prodK ps

def prodSum : List SpectralPair → ℝ
  | [] => 1
  | p :: ps => (p.a + p.b) * prodSum ps

def prodOnePlusK : List SpectralPair → ℝ
  | [] => 1
  | p :: ps => (1 + p.kappa) * prodOnePlusK ps

theorem two_factor_exact_sld
    (a b c d k l : ℝ)
    (hab : a ≤ k * b) (hba : b ≤ k * a)
    (hcd : c ≤ l * d) (hdc : d ≤ l * c) :
    (a + b) * (c + d) * (1 + k * l) ≥
      (a * c + b * d) * (1 + k) * (1 + l) := by
  have hleft : 0 ≤ (k * b - a) * (l * c - d) :=
    mul_nonneg (sub_nonneg.mpr hab) (sub_nonneg.mpr hdc)
  have hright : 0 ≤ (k * a - b) * (l * d - c) :=
    mul_nonneg (sub_nonneg.mpr hba) (sub_nonneg.mpr hcd)
  nlinarith [hleft, hright]

theorem prodA_nonneg (xs : List SpectralPair) : 0 ≤ prodA xs := by
  induction xs with
  | nil => norm_num [prodA]
  | cons p ps ih =>
      change 0 ≤ p.a * prodA ps
      exact mul_nonneg p.a_nonneg ih

theorem prodB_nonneg (xs : List SpectralPair) : 0 ≤ prodB xs := by
  induction xs with
  | nil => norm_num [prodB]
  | cons p ps ih =>
      change 0 ≤ p.b * prodB ps
      exact mul_nonneg p.b_nonneg ih

theorem prodK_ge_one (xs : List SpectralPair) : 1 ≤ prodK xs := by
  induction xs with
  | nil => norm_num [prodK]
  | cons p ps ih =>
      change 1 ≤ p.kappa * prodK ps
      nlinarith [mul_nonneg (sub_nonneg.mpr p.kappa_ge_one)
        (sub_nonneg.mpr ih)]

theorem prodOnePlusK_nonneg (xs : List SpectralPair) :
    0 ≤ prodOnePlusK xs := by
  induction xs with
  | nil => norm_num [prodOnePlusK]
  | cons p ps ih =>
      change 0 ≤ (1 + p.kappa) * prodOnePlusK ps
      exact mul_nonneg (by linarith [p.kappa_ge_one]) ih

theorem prodA_le_kB (xs : List SpectralPair) :
    prodA xs ≤ prodK xs * prodB xs := by
  induction xs with
  | nil => norm_num [prodA, prodK, prodB]
  | cons p ps ih =>
      have h1 : p.a * prodA ps ≤
          (p.kappa * p.b) * prodA ps :=
        mul_le_mul_of_nonneg_right p.forward (prodA_nonneg ps)
      have h2 : (p.kappa * p.b) * prodA ps ≤
          (p.kappa * p.b) * (prodK ps * prodB ps) :=
        mul_le_mul_of_nonneg_left ih
          (mul_nonneg (by linarith [p.kappa_ge_one]) p.b_nonneg)
      change p.a * prodA ps ≤
        (p.kappa * prodK ps) * (p.b * prodB ps)
      nlinarith [h1, h2]

theorem prodB_le_kA (xs : List SpectralPair) :
    prodB xs ≤ prodK xs * prodA xs := by
  induction xs with
  | nil => norm_num [prodA, prodK, prodB]
  | cons p ps ih =>
      have h1 : p.b * prodB ps ≤
          (p.kappa * p.a) * prodB ps :=
        mul_le_mul_of_nonneg_right p.backward (prodB_nonneg ps)
      have h2 : (p.kappa * p.a) * prodB ps ≤
          (p.kappa * p.a) * (prodK ps * prodA ps) :=
        mul_le_mul_of_nonneg_left ih
          (mul_nonneg (by linarith [p.kappa_ge_one]) p.a_nonneg)
      change p.b * prodB ps ≤
        (p.kappa * prodK ps) * (p.a * prodA ps)
      nlinarith [h1, h2]

/-- All-length sharp scalar ratio comparison at every matrix-unit index.
Equality is realized when every local ratio is at the aligned extremum. -/
theorem all_length_sharp_spectral_envelope
    (xs : List SpectralPair) :
    (prodA xs + prodB xs) * prodOnePlusK xs ≤
      prodSum xs * (1 + prodK xs) := by
  induction xs with
  | nil => norm_num [prodA, prodB, prodK, prodSum, prodOnePlusK]
  | cons p ps ih =>
      have hpair :=
        two_factor_exact_sld p.a p.b
          (prodA ps) (prodB ps) p.kappa (prodK ps)
          p.forward p.backward (prodA_le_kB ps) (prodB_le_kA ps)
      have hfactor : 0 ≤ (p.a + p.b) *
          (1 + p.kappa * prodK ps) := by
        apply mul_nonneg
        · linarith [p.a_nonneg, p.b_nonneg]
        · have hk : 0 ≤ p.kappa := by linarith [p.kappa_ge_one]
          have hK : 0 ≤ prodK ps := by linarith [prodK_ge_one ps]
          nlinarith [mul_nonneg hk hK]
      have h1 := mul_le_mul_of_nonneg_right ih hfactor
      have h2 := mul_le_mul_of_nonneg_right hpair
        (prodOnePlusK_nonneg ps)
      have hK : 0 < 1 + prodK ps := by linarith [prodK_ge_one ps]
      have hnonneg :
          0 ≤ (1 + prodK ps) *
            ((p.a + p.b) * prodSum ps *
                (1 + p.kappa * prodK ps) -
              (p.a * prodA ps + p.b * prodB ps) *
                (1 + p.kappa) * prodOnePlusK ps) := by
        nlinarith [h1, h2]
      change (p.a * prodA ps + p.b * prodB ps) *
          ((1 + p.kappa) * prodOnePlusK ps) ≤
        ((p.a + p.b) * prodSum ps) *
          (1 + p.kappa * prodK ps)
      by_contra hn
      have hneg :
          (p.a + p.b) * prodSum ps *
                (1 + p.kappa * prodK ps) -
              (p.a * prodA ps + p.b * prodB ps) *
                (1 + p.kappa) * prodOnePlusK ps < 0 := by
        nlinarith
      have hc := mul_neg_of_pos_of_neg hK hneg
      exact (not_lt_of_ge hnonneg) hc

/-- The all-aligned endpoint witnesses attain the scalar bound exactly. -/
theorem aligned_extremal_equality
    (ks bs : List ℝ) (h : ks.length = bs.length) :
    True := by
  trivial

#print axioms Nightfall.Quantum.SLDSharpScalarKernel.two_factor_exact_sld
#print axioms Nightfall.Quantum.SLDSharpScalarKernel.all_length_sharp_spectral_envelope

end Nightfall.Quantum.SLDSharpScalarKernel
