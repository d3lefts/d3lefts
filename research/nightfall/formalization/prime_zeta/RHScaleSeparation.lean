import Mathlib

/-!
# Critical-line dilation separation and finite source-fiber collapse

This file proves an **RH-conditional** algebraic consequence, not RH itself.
It uses Mathlib's `riemannZeta` only to define the actual zero predicate.
No proof of the prime-zeta analytic-continuation/local-residue theorem is claimed.

If two *positive-integer dilations of the same point* are nontrivial zeta zeros,
the critical-line hypothesis forces the indices to agree. Consequently a finite
weighted sum supported on such dilations is either empty or a singleton.

The imported RH assertion is an explicit argument `hRH`; the Lean compiler
does not thereby import or certify Alpöge's separate RH proof.
-/

namespace Nightfall.PrimeZeta

/-- Real part 1/2; a geometric property, not a proof of RH. -/
def OnCriticalLine (z : ℂ) : Prop := z.re = (1 / 2 : ℝ)

/-- The actual nontrivial zero predicate for Mathlib's Riemann zeta. -/
def NontrivialZetaZero (z : ℂ) : Prop :=
  riemannZeta z = 0 ∧ 0 < z.re ∧ z.re < 1

/-- Elementary real-factor cancellation, with a nonzero factor deduced
from the common critical-line value. -/
theorem real_dilation_unique (a : ℝ) (n m : ℕ)
    (hn : (n : ℝ) * a = (1 / 2 : ℝ))
    (hm : (m : ℝ) * a = (1 / 2 : ℝ)) : n = m := by
  have ha : a ≠ 0 := by
    intro hz
    norm_num [hz] at hn
  have heq : (n : ℝ) * a = (m : ℝ) * a := hn.trans hm.symm
  have hdifference : ((n : ℝ) - (m : ℝ)) * a = 0 := by
    rw [sub_mul, heq, sub_self]
  rcases mul_eq_zero.mp hdifference with hdiff | hzero
  · have hcast : (n : ℝ) = (m : ℝ) := sub_eq_zero.mp hdiff
    exact_mod_cast hcast
  · exact (ha hzero).elim

/-- The real part of an integer dilation of a complex point. -/
theorem re_nat_dilation (z : ℂ) (n : ℕ) :
    ((n : ℂ) * z).re = (n : ℝ) * z.re := by
  simp [Complex.mul_re]

/-- Two critical-line integer dilations of one point have the same index. -/
theorem scale_index_unique (z : ℂ) (n m : ℕ)
    (hn : OnCriticalLine ((n : ℂ) * z))
    (hm : OnCriticalLine ((m : ℂ) * z)) : n = m := by
  apply real_dilation_unique z.re n m
  · simpa [OnCriticalLine, re_nat_dilation] using hn
  · simpa [OnCriticalLine, re_nat_dilation] using hm

/-- RH is explicitly *assumed*. This theorem is safe under any future
change of how the separate RH evidence is imported. -/
theorem rh_conditional_zeta_scale_unique
    (hRH : ∀ z : ℂ, NontrivialZetaZero z → OnCriticalLine z)
    (z : ℂ) (n m : ℕ)
    (hn : NontrivialZetaZero ((n : ℂ) * z))
    (hm : NontrivialZetaZero ((m : ℂ) * z)) : n = m :=
  scale_index_unique z n m (hRH _ hn) (hRH _ hm)

/-- An arbitrary finite fiber of critical-line dilation indices collapses
to at most one element. This is independent of coefficient signs. -/
theorem finite_fiber_sum (z : ℂ) (n : ℕ) (S : Finset ℕ)
    (hn : OnCriticalLine ((n : ℂ) * z))
    (hS : ∀ m ∈ S, OnCriticalLine ((m : ℂ) * z))
    (weight : ℕ → ℚ) :
    (∑ m ∈ S, weight m) = if n ∈ S then weight n else 0 := by
  classical
  have hunique : ∀ m ∈ S, m = n := by
    intro m hm
    exact scale_index_unique z m n (hS m hm) hn
  by_cases hmem : n ∈ S
  · have hsingleton : S = {n} := by
      ext m
      constructor
      · intro hm
        simpa only [Finset.mem_singleton] using hunique m hm
      · intro hm
        have hmn : m = n := by simpa only [Finset.mem_singleton] using hm
        simpa [hmn] using hmem
    simp [hsingleton]
  · have hempty : S = ∅ := by
      ext m
      constructor
      · intro hm
        have hmn : m = n := hunique m hm
        exact False.elim (hmem (by simpa [hmn] using hm))
      · simp
    simp [hempty, hmem]

/-- When the distinguished index is present, vanishing of the entire finite
weighted fiber is equivalent to vanishing of its single coefficient. -/
theorem finite_fiber_zero_iff (z : ℂ) (n : ℕ) (S : Finset ℕ)
    (hn : OnCriticalLine ((n : ℂ) * z))
    (hS : ∀ m ∈ S, OnCriticalLine ((m : ℂ) * z))
    (hmem : n ∈ S) (weight : ℕ → ℚ) :
    ((∑ m ∈ S, weight m) = 0) ↔ weight n = 0 := by
  rw [finite_fiber_sum z n S hn hS weight]
  simp [hmem]

end Nightfall.PrimeZeta
