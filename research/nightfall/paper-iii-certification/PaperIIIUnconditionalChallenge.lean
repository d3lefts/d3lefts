import ConditionalPhaseThreshold
open Nightfall.ProductSphereObstruction
open Nightfall.ProductSphereCausal

-- A genuine terminal must inhabit these exact unconditional types.
-- This is a challenge file, not a claimed proof. Unknown declarations
-- cause this gate to fail until proved in the imported closure.
example (n r s : ℕ) (hn : 1 ≤ n) (hr : r < n) (hs : s < n) :
    ProductSphereZero n r s :=
  Nightfall.PaperIII.productSphereZero n r s hn hr hs

example (n : ℕ) (hn : 2 ≤ n) :
    ProductSphereMixedZero n (n-1) (n-2) :=
  Nightfall.PaperIII.productSphereMixedZero n hn

example (n m : ℕ) (hn : 2 ≤ n) (hm : m ≤ 2*n-2)
    (a : CausalRows n) (ha : ReachableContinuous a) :
    ¬ ExactRecovery a m :=
  Nightfall.PaperIII.no_continuous_causal_exact_recovery_below n m hn hm a ha
