import GlobalQuadraticParity
import CenteredRectangles

/-!
# Actual arbitrary-law centered pair kernels -> global matching amplitude

For any finite collection of disjoint matched coordinate pairs with arbitrary
finite alphabets and coordinate-dependent normalized nonnegative laws, this
theorem derives the bounded-matching-amplitude inequality for ACTUAL
separately centered pair kernels, inside a bounded full quadratic function.
No parity-cancellation, rectangle-mean, or orientation hypothesis is supplied.

The full quadratic function may contain arbitrary singleton interactions and
arbitrarily dense cross-block pair interactions. An arbitrary coordinate in a
general product not covered by the chosen matching, finite ANOVA centering,
and the geometric transition from general finite graph to this block model
remain distinct source-level formalization tasks. No unrestricted quadratic
influence result is claimed by this module.
-/

namespace Nightfall.Observability.GlobalCenteredMatching

open Finset
open Nightfall.Observability.GlobalQuadraticParity
open Nightfall.Observability.CenteredRectangles

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [Nonempty α]
  [Fintype E]

/-- At every chosen point of every separately centered matched pair kernel,
the total absolute interaction amplitude is bounded by four times the
supremum norm of the whole quadratic function.

All pairwise offmatching interactions are PRESENT and may be dense;
the global parity cancellation and orientation are proved from the
actual functions, not carried as assumptions. -/
theorem centered_matching_amplitude_at_points
    (c : ℝ)
    (leftOne rightOne : ι → α → ℝ)
    (matched : ι → α → α → ℝ)
    (first second : E → ι)
    (sideFirst sideSecond : E → Bool)
    (hne : ∀ e, first e ≠ second e)
    (off : E → α → α → ℝ)
    (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hq : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hq1 : ∀ i, (∑ a : α, q i a) = 1)
    (hrow : ∀ i x, (∑ b : α, q i b * matched i x b) = 0)
    (hcol : ∀ i y, (∑ a : α, p i a * matched i a y) = 0)
    (B : ℝ)
    (hbounded : ∀ z : ι → Bool → α,
      |quadraticModel c leftOne rightOne matched
        first second sideFirst sideSecond off z| ≤ B)
    (x y : ι → α) :
    (∑ i : ι, |matched i (x i) (y i)|) ≤ 4 * B := by
  classical
  have hlocal (i : ι) :
      ∃ x0 x1 : α, ∃ y0 y1 : α,
        |matched i (x i) (y i)| ≤
        matched i x0 y0 - matched i x0 y1 -
        matched i x1 y0 + matched i x1 y1 := by
    exact exists_oriented_rectangle_dominating_abs
      (p i) (q i) (hp i) (hq i) (hp1 i) (hq1 i)
      (matched i) (hrow i) (hcol i) (x i) (y i)
  choose x0 x1 y0 y1 hrect using hlocal
  let left : ι → Bool → α :=
    fun i b => if b then x1 i else x0 i
  let right : ι → Bool → α :=
    fun i b => if b then y1 i else y0 i
  have hdom :
      (∑ i : ι, |matched i (x i) (y i)|) ≤
      (∑ i : ι, (matched i (left i false) (right i false) -
         matched i (left i false) (right i true) -
         matched i (left i true) (right i false) +
         matched i (left i true) (right i true))) := by
    apply Finset.sum_le_sum
    intro i _
    simpa [left, right] using hrect i
  exact hdom.trans
    (global_matching_delta_budget
      c leftOne rightOne matched
      first second sideFirst sideSecond hne off left right B hbounded)


/-- Finite coordinate alphabets admit simultaneous maximum-modulus
pair-kernel witnesses. Composed with the actual centered matching theorem,
their *total true sup-norm amplitude* is at most four times the full
quadratic bound. This is not a supplied matching-mass premise. -/
theorem centered_matching_maximal_amplitude
    (c : ℝ)
    (leftOne rightOne : ι → α → ℝ)
    (matched : ι → α → α → ℝ)
    (first second : E → ι)
    (sideFirst sideSecond : E → Bool)
    (hne : ∀ e, first e ≠ second e)
    (off : E → α → α → ℝ)
    (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hq : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (hq1 : ∀ i, (∑ a : α, q i a) = 1)
    (hrow : ∀ i x, (∑ b : α, q i b * matched i x b) = 0)
    (hcol : ∀ i y, (∑ a : α, p i a * matched i a y) = 0)
    (B : ℝ)
    (hbounded : ∀ z : ι → Bool → α,
      |quadraticModel c leftOne rightOne matched
        first second sideFirst sideSecond off z| ≤ B) :
    ∃ x y : ι → α,
      (∀ i a b, |matched i a b| ≤ |matched i (x i) (y i)|) ∧
      (∑ i : ι, |matched i (x i) (y i)|) ≤ 4 * B := by
  classical
  have hmaximal (i : ι) :
      ∃ x y : α, ∀ a b : α,
        |matched i a b| ≤ |matched i x y| := by
    have hne : (Finset.univ : Finset (α × α)).Nonempty :=
      ⟨(Classical.choice ‹Nonempty α›, Classical.choice ‹Nonempty α›),
        Finset.mem_univ _⟩
    obtain ⟨t, _, hmax⟩ :=
      Finset.exists_max_image (Finset.univ : Finset (α × α))
        (fun t : α × α => |matched i t.1 t.2|) hne
    refine ⟨t.1, t.2, ?_⟩
    intro a b
    exact hmax (a, b) (Finset.mem_univ _)
  choose x y hmax using hmaximal
  refine ⟨x, y, ?_, ?_⟩
  · intro i a b
    exact hmax i a b
  · exact centered_matching_amplitude_at_points
      c leftOne rightOne matched first second
      sideFirst sideSecond hne off p q hp hq hp1 hq1
      hrow hcol B hbounded x y

end Nightfall.Observability.GlobalCenteredMatching
