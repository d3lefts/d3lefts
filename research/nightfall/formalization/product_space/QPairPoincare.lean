import Mathlib

/-!
# Exact sharp Poincare constant of a correlated fair bit pair (q=1/4)

Joint probabilities:
  ν(00)=3/8, ν(01)=1/8, ν(10)=1/8, ν(11)=3/8.
The global joint density floor of k independent copies relative to
2k independent fair bit marginals is 2^(-k), while each 2-site
block has an exactly sharp heat-bath Poincare constant C=2.

The substantive new proof object is a sum-of-squares identity.
-/
namespace Nightfall.CorrelatedPairs

/-- Exact mean under the correlated pair law. -/
def pairMean (a b c d : ℝ) : ℝ := (3*a+b+c+3*d)/8

/-- Variance under joint probabilities (3,1,1,3)/8. -/
def pairVariance (a b c d : ℝ) : ℝ :=
  (3*(a-pairMean a b c d)^2 +
      (b-pairMean a b c d)^2 +
      (c-pairMean a b c d)^2 +
    3*(d-pairMean a b c d)^2)/8

/-- The true single-site conditional-resampling influence of the first bit. -/
def pairInfluence1 (a b c d : ℝ) : ℝ :=
  3/32*((a-c)^2+(b-d)^2)

/-- The true single-site conditional-resampling influence of the second bit. -/
def pairInfluence2 (a b c d : ℝ) : ℝ :=
  3/32*((a-b)^2+(c-d)^2)

/-- Sharp SOS certificate for the two-site heat-bath spectral gap. -/
theorem correlated_pair_gap_sos (a b c d : ℝ) :
    2*(pairInfluence1 a b c d+pairInfluence2 a b c d)
       -pairVariance a b c d =
    9/64*(a+d-b-c)^2 + 1/8*(b-c)^2 := by
  unfold pairInfluence1 pairInfluence2 pairVariance pairMean
  ring

/-- Universal correlated pair Poincare inequality, exact C=2. -/
theorem correlated_pair_poincare (a b c d : ℝ) :
    pairVariance a b c d ≤
      2*(pairInfluence1 a b c d+pairInfluence2 a b c d) := by
  have hs := correlated_pair_gap_sos a b c d
  nlinarith [sq_nonneg (a+d-b-c), sq_nonneg (b-c)]

/-- Equality occurs on the correlated plus mode, so C cannot be lowered. -/
theorem correlated_pair_gap_sharp :
    pairVariance (-2) 0 0 2 =
      2*(pairInfluence1 (-2) 0 0 2+pairInfluence2 (-2) 0 0 2) := by
  norm_num [pairVariance,pairMean,pairInfluence1,pairInfluence2]

end Nightfall.CorrelatedPairs
