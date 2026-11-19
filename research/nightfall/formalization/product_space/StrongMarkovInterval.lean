import StrongMarkovInterior

/-!
# Genuine interval Markov bound from the proved Chebyshev inequality

No derivative estimates assumed. For any real polynomial P of natDegree ≤d
bounded between 0 and 1 throughout [0,L], its derivative is bounded by
2d²/L for every point of the same interval (L>0). This slightly loses a
factor of two relative to the sharp Markov constant but is sufficient for
bias-floor-free product expectation stability after the common-part path
bridge is proved.
-/
namespace Nightfall.BiasFreeMarkov

open Polynomial

theorem markov_derivative_interval
    (P : Polynomial ℝ) (d : ℕ) (L x : ℝ)
    (hL : 0 < L) (hx0 : 0 ≤ x) (hxL : x ≤ L)
    (hdeg : P.natDegree ≤ d)
    (hrange : ∀ y ∈ Set.Icc (0 : ℝ) L, 0 ≤ P.eval y ∧ P.eval y ≤ 1) :
    (L / 2) * |(derivative P).eval x| ≤ (d : ℝ) ^ 2 := by
  have hpath : ∀ b : ℝ, 0 ≤ b → b ≤ L →
      |x - b| * |(derivative P).eval x| ≤ (d : ℝ) ^ 2 := by
    intro b hb0 hbL
    apply markov_endpoint_affine P d x b hdeg
    intro t ht
    have htlo := (Set.mem_Icc.mp ht).1
    have hthi := (Set.mem_Icc.mp ht).2
    let r : ℝ := (1 + t) / 2
    let s : ℝ := (1 - t) / 2
    have hr : 0 ≤ r := by dsimp [r]; linarith
    have hs : 0 ≤ s := by dsimp [s]; linarith
    have hweights : r + s = 1 := by dsimp [r, s]; ring
    have hru : 0 ≤ r * x := mul_nonneg hr hx0
    have hsb : 0 ≤ s * b := mul_nonneg hs hb0
    have hru' : 0 ≤ r * (L - x) :=
      mul_nonneg hr (sub_nonneg.mpr hxL)
    have hsb' : 0 ≤ s * (L - b) :=
      mul_nonneg hs (sub_nonneg.mpr hbL)
    have hiden : (x + b) / 2 + (x - b) / 2 * t = r * x + s * b := by
      dsimp [r, s]
      ring
    apply hrange
    rw [hiden]
    exact Set.mem_Icc.mpr ⟨by linarith [hru, hsb], by
      nlinarith [hru', hsb', hweights]⟩
  have hn : 0 ≤ |(derivative P).eval x| := abs_nonneg _
  by_cases hhalf : L / 2 ≤ x
  · have hm := hpath 0 le_rfl hL.le
    have hs : |x - 0| = x := by simp [abs_of_nonneg hx0]
    rw [hs] at hm
    have hmul := mul_le_mul_of_nonneg_right hhalf hn
    nlinarith
  · have hm := hpath L hL.le le_rfl
    have hs : |x - L| = L - x := by
      rw [abs_sub_comm]
      simpa [abs_of_nonneg (sub_nonneg.mpr hxL)]
    rw [hs] at hm
    have hgap : L / 2 ≤ L - x := by linarith
    have hmul := mul_le_mul_of_nonneg_right hgap hn
    nlinarith

end Nightfall.BiasFreeMarkov
