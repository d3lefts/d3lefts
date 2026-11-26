import Mathlib

/-! Paper II, Corollary 1.3: the exact inverse-energy drift lemma.
The source-specific energy identity and greedy tree construction must
still be attached to the existing C2 theorem. -/
namespace Nightfall.PaperIIAdaptiveDrift

theorem reciprocal_increment (C x y : ℝ)
    (hC : 0 < C) (hx : 0 < x) (hy : 0 < y)
    (h : y ≤ x - x^2/C) :
    1/x + 1/C ≤ 1/y := by
  have hxy : y ≤ x := by
    have hp : 0 ≤ x^2/C := by positivity
    linarith
  have hdiff : x^2 ≤ C*(x-y) := by
    have he : x^2/C ≤ x-y := by linarith
    rw [div_le_iff₀ hC] at he
    simpa [mul_comm] using he
  have hprod : x*y ≤ x^2 := by nlinarith only [mul_le_mul_of_nonneg_left hxy hx.le]
  have hmain : (x+C)*y ≤ C*x := by nlinarith only [hdiff,hprod]
  have he : 1/x+1/C = (x+C)/(C*x) := by field_simp [hx.ne',hC.ne'] <;> ring
  rw [he,div_le_div_iff₀ (mul_pos hC hx) hy]
  simpa using hmain

theorem inverse_energy_bound (P : ℕ → ℝ) (C : ℝ) (hC : 0 < C)
    (hP : ∀ n, 0 ≤ P n)
    (hstep : ∀ n, P (n+1) ≤ P n - (P n)^2/C) :
    ∀ n, 0 < n → P n ≤ C/(n : ℝ) := by
  have hmono : ∀ n, P (n+1) ≤ P n := by
    intro n
    have h := hstep n
    have hz : 0 ≤ (P n)^2/C := by positivity
    linarith
  have hrec : ∀ n, 0 < P n → (n : ℝ)/C ≤ 1/P n := by
    intro n
    induction n with
    | zero =>
      intro hp
      simp only [Nat.cast_zero,zero_div]
      positivity
    | succ n ih =>
      intro hp
      have hp0 : 0 < P n := hp.trans_le (hmono n)
      have h := reciprocal_increment C (P n) (P (n+1)) hC hp0 hp (hstep n)
      have h' := ih hp0
      push_cast
      rw [add_div]
      linarith
  intro n hn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  rcases (hP n).eq_or_lt with hz | hp
  · rw [← hz]
    positivity
  · have h := hrec n hp
    rw [div_le_div_iff₀ hC hp] at h
    apply (le_div_iff₀ hnR).mpr
    simpa [mul_comm] using h

#print axioms reciprocal_increment
#print axioms inverse_energy_bound
end Nightfall.PaperIIAdaptiveDrift
