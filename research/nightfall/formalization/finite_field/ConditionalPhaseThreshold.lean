import Mathlib
import ProductSphereCausalComposition

/-!
# NIGHTFALL conditional all-dimensional measurement-count lower bound

This is the source-faithful causal consequence of the classical
product-sphere topology proposition, and has no other mathematical
existence assumptions. It does NOT prove ProductSphereZero.

Here "exact recovery up to global sign" means that equal actual
squared-linear transcripts imply x=y or x=-y. Arbitrary row choices are
allowed off reachable histories; continuity is required only on the
actual reachable-prefix images.

The topology quantifier is universal over all pure-character rank
budgets r,s<n. This is a single classical topology-family assumption,
not a hidden per-protocol collision oracle or an admitted theorem.
-/

namespace Nightfall.ProductSphereCausal

open Nightfall.ProductSphereObstruction
open Nightfall.GenuinePrefixPhase

def ExactRecovery {n : ℕ} (a : CausalRows n) (m : ℕ) : Prop :=
  ∀ x y : Signal n,
    GenuinePrefixPhase.transcript (amp a) m x =
      GenuinePrefixPhase.transcript (amp a) m y →
      x = y ∨ x = -y

/-- Sharp *conditional* obstruction:
no real continuously selected causal squared-linear measurement policy
with m ≤ 2n-2 exact readings recovers every sign class in dimension n≥2.
The sole unproved external mathematical premise is the explicitly
quantified classical product-sphere topology theorem. -/
theorem no_continuous_causal_exact_recovery_below
    (n m : ℕ) (hn : 2 ≤ n) (hm : m ≤ 2 * n - 2)
    (hBU : ∀ r s : ℕ, r < n → s < n → ProductSphereZero n r s)
    (a : CausalRows n) (ha : ReachableContinuous a) :
    ¬ ExactRecovery a m := by
  intro hrecover
  let r : ℕ := min m (n - 1)
  let s : ℕ := m - r
  have hr : r < n := by
    dsimp [r]
    omega
  have hs : s < n := by
    dsimp [s, r]
    omega
  have hsum : r + s = m := by
    dsimp [s, r]
    omega
  obtain ⟨u, v, hu, hv, htrans, hneq, hneq'⟩ :=
    collision_of_product_sphere_zero_reachable n r s
      (hBU r s hr hs) a ha
  have heq : GenuinePrefixPhase.transcript (amp a) m (u + v) =
      GenuinePrefixPhase.transcript (amp a) m (u - v) := by
    simpa only [hsum] using htrans
  rcases hrecover (u + v) (u - v) heq with he | he
  · exact hneq he
  · exact hneq' he

#print no_continuous_causal_exact_recovery_below
#print axioms no_continuous_causal_exact_recovery_below

end Nightfall.ProductSphereCausal
