import ParityBlockCancellation

/-!
# Global degree-two matching parity comparison, actual function model

This module builds *one actual bounded quadratic function* on two coordinates
per matching block.  Its matched edges are within blocks; the other arbitrary
pairwise terms join distinct matching blocks and may form a dense graph.

The even and odd full-selector experiments are *defined* as concrete
configurations, with each selector uniform across all blocks.  The exact
expectation identity follows from the full off-matching parity cancellation
already formalized in ParityBlockCancellation, plus the matched four-corner
identity.  Neither identity is supplied as a free premise here.

This is a genuine global function-level cancellation in the "all coordinates
matched" finite two-slot model. Remaining for the complete quadratic theorem:
the equivalence with a general product's degree-two Hoeffding decomposition,
choosing extremal rectangles with canonical degeneracy, greedy weighted
matching extraction, switching/section budgets, and end-to-end composition.
-/

namespace Nightfall.Observability.GlobalQuadraticParity

open Finset Nightfall.Observability.ParityBlocks
variable {ι α E : Type*} [Fintype ι] [DecidableEq ι] [Fintype E]

def evenConfig (left right : ι → Bool → α)
    (σ : ι → Bool) : ι → Bool → α :=
  fun i side => if side then right i (σ i) else left i (σ i)

def oddConfig (left right : ι → Bool → α)
    (σ : ι → Bool) : ι → Bool → α :=
  fun i side => if side then right i (!(σ i)) else left i (σ i)

/-- General real quadratic expression on exactly two coordinates per block.
All offmatching interactions connect different blocks; no restriction on
the graph's density or intersection pattern. -/
noncomputable def quadraticModel
    (c : ℝ) (leftOne rightOne : ι → α → ℝ)
    (matched : ι → α → α → ℝ)
    (first second : E → ι) (sideFirst sideSecond : E → Bool)
    (off : E → α → α → ℝ)
    (x : ι → Bool → α) : ℝ :=
  c +
  (∑ i : ι, leftOne i (x i false)) +
  (∑ i : ι, rightOne i (x i true)) +
  (∑ i : ι, matched i (x i false) (x i true)) +
  (∑ e : E, off e (x (first e) (sideFirst e))
                     (x (second e) (sideSecond e)))

/-- Every offmatching degree-two interaction cancels *simultaneously*,
the singleton terms cancel, and every selected matched edge contributes
exactly its rectangular mixed difference, at its correct weight. -/
theorem global_matching_quadratic_parity_identity
    (c : ℝ) (leftOne rightOne : ι → α → ℝ)
    (matched : ι → α → α → ℝ)
    (first second : E → ι) (sideFirst sideSecond : E → Bool)
    (hne : ∀ e, first e ≠ second e)
    (off : E → α → α → ℝ)
    (left right : ι → Bool → α) :
    2 * (∑ σ : ι → Bool,
        (quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (evenConfig left right σ) -
         quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (oddConfig left right σ))) =
    (Fintype.card (ι → Bool) : ℝ) *
      (∑ i : ι, (matched i (left i false) (right i false) -
        matched i (left i false) (right i true) -
        matched i (left i true) (right i false) +
        matched i (left i true) (right i true))) := by
  let a : (ι → Bool) → ℝ :=
    fun σ => c + (∑ i : ι, leftOne i (left i (σ i)))
  let b : (ι → Bool) → ℝ :=
    fun σ => ∑ i : ι, rightOne i (right i (σ i))
  let b' : (ι → Bool) → ℝ :=
    fun σ => ∑ i : ι, rightOne i (right i (!(σ i)))
  let m : (ι → Bool) → ℝ :=
    fun σ => ∑ i : ι, matched i (left i (σ i)) (right i (σ i))
  let m' : (ι → Bool) → ℝ :=
    fun σ => ∑ i : ι, matched i (left i (σ i)) (right i (!(σ i)))
  let k : (ι → Bool) → ℝ :=
    fun σ => ∑ e : E,
      off e
        (if sideFirst e then right (first e) (σ (first e))
          else left (first e) (σ (first e)))
        (if sideSecond e then right (second e) (σ (second e))
          else left (second e) (σ (second e)))
  let k' : (ι → Bool) → ℝ :=
    fun σ => ∑ e : E,
      off e
        (if sideFirst e then right (first e) (!(σ (first e)))
          else left (first e) (σ (first e)))
        (if sideSecond e then right (second e) (!(σ (second e)))
          else left (second e) (σ (second e)))
  have heven (σ : ι → Bool) :
      quadraticModel c leftOne rightOne matched
          first second sideFirst sideSecond off
          (evenConfig left right σ) = a σ + b σ + m σ + k σ := by
    dsimp [quadraticModel, evenConfig, a, b, m, k] <;> ring
  have hodd (σ : ι → Bool) :
      quadraticModel c leftOne rightOne matched
          first second sideFirst sideSecond off
          (oddConfig left right σ) = a σ + b' σ + m' σ + k' σ := by
    dsimp [quadraticModel, oddConfig, a, b', m', k'] <;> ring
  have hb : (∑ σ : ι → Bool, b σ) =
      ∑ σ : ι → Bool, b' σ := by
    dsimp [b, b']
    calc
      (∑ σ : ι → Bool, ∑ i : ι, rightOne i (right i (σ i))) =
          ∑ i : ι, ∑ σ : ι → Bool, rightOne i (right i (σ i)) :=
            Finset.sum_comm
      _ = ∑ i : ι, ∑ σ : ι → Bool,
            rightOne i (right i (!(σ i))) := by
              apply Finset.sum_congr rfl
              intro i _
              exact right_marginal right (rightOne i) i
      _ = ∑ σ : ι → Bool, ∑ i : ι,
            rightOne i (right i (!(σ i))) := Finset.sum_comm
  have hk : (∑ σ : ι → Bool, k σ) =
      ∑ σ : ι → Bool, k' σ := by
    exact off_matching_pair_family_cancel first second hne
      sideFirst sideSecond left right left right off
  have hm :
      2 * (∑ σ : ι → Bool, (m σ - m' σ)) =
      (Fintype.card (ι → Bool) : ℝ) *
        (∑ i : ι, (matched i (left i false) (right i false) -
          matched i (left i false) (right i true) -
          matched i (left i true) (right i false) +
          matched i (left i true) (right i true))) := by
    have hs (σ : ι → Bool) :
        m σ - m' σ =
        ∑ i : ι, (matched i (left i (σ i)) (right i (σ i)) -
          matched i (left i (σ i)) (right i (!(σ i)))) := by
      dsimp [m, m']
      rw [Finset.sum_sub_distrib]
    have hsum :
        (∑ σ : ι → Bool, (m σ - m' σ)) =
        ∑ σ : ι → Bool, ∑ i : ι,
          (matched i (left i (σ i)) (right i (σ i)) -
          matched i (left i (σ i)) (right i (!(σ i)))) :=
      Finset.sum_congr rfl (fun σ _ => hs σ)
    rw [hsum]
    exact matched_family_delta_identity
      (fun i v w => matched i (left i v) (right i w))
  have hcancel :
      (∑ σ : ι → Bool,
        (quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (evenConfig left right σ) -
         quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (oddConfig left right σ))) =
      ∑ σ : ι → Bool, (m σ - m' σ) := by
    calc
      _ = ∑ σ : ι → Bool,
           ((a σ + b σ + m σ + k σ) -
             (a σ + b' σ + m' σ + k' σ)) := by
        apply Finset.sum_congr rfl
        intro σ _
        rw [heven, hodd]
      _ = (∑ σ : ι → Bool, b σ) -
          (∑ σ : ι → Bool, b' σ) +
          ((∑ σ : ι → Bool, m σ) -
          (∑ σ : ι → Bool, m' σ)) +
          ((∑ σ : ι → Bool, k σ) -
          (∑ σ : ι → Bool, k' σ)) := by
        simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib]
        ring
      _ = ∑ σ : ι → Bool, (m σ - m' σ) := by
        rw [hb, hk, sub_self, zero_add, sub_self, add_zero,
          Finset.sum_sub_distrib]
  rw [hcancel]
  exact hm

/-- All matched four-corner differences are jointly controlled by the
supremum of the *whole* quadratic expression.  These are actual finite
function-level corner configurations; this is not a graph coloring bound. -/
theorem global_matching_delta_budget
    (c : ℝ) (leftOne rightOne : ι → α → ℝ)
    (matched : ι → α → α → ℝ)
    (first second : E → ι) (sideFirst sideSecond : E → Bool)
    (hne : ∀ e, first e ≠ second e)
    (off : E → α → α → ℝ)
    (left right : ι → Bool → α)
    (B : ℝ)
    (hbounded : ∀ x : ι → Bool → α,
      |quadraticModel c leftOne rightOne matched
          first second sideFirst sideSecond off x| ≤ B) :
    (∑ i : ι, (matched i (left i false) (right i false) -
        matched i (left i false) (right i true) -
        matched i (left i true) (right i false) +
        matched i (left i true) (right i true))) ≤ 4 * B := by
  let n : ℝ := Fintype.card (ι → Bool)
  have hn : 0 < n := by
    dsimp [n]
    exact_mod_cast Fintype.card_pos_iff.mpr ⟨fun _ => false⟩
  let D : ℝ := ∑ i : ι, (matched i (left i false) (right i false) -
        matched i (left i false) (right i true) -
        matched i (left i true) (right i false) +
        matched i (left i true) (right i true))
  let Q : ℝ := ∑ σ : ι → Bool,
        (quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (evenConfig left right σ) -
         quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (oddConfig left right σ))
  have hidentity : 2 * Q = n * D :=
    global_matching_quadratic_parity_identity
      c leftOne rightOne matched first second sideFirst sideSecond
      hne off left right
  have hstep (σ : ι → Bool) :
      (quadraticModel c leftOne rightOne matched
          first second sideFirst sideSecond off
          (evenConfig left right σ) -
       quadraticModel c leftOne rightOne matched
          first second sideFirst sideSecond off
          (oddConfig left right σ)) ≤ 2 * B := by
    have he := (abs_le.mp (hbounded (evenConfig left right σ))).2
    have ho := (abs_le.mp (hbounded (oddConfig left right σ))).1
    linarith
  have hq : Q ≤ n * (2 * B) := by
    dsimp [Q, n]
    calc
      (∑ σ : ι → Bool,
        (quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (evenConfig left right σ) -
         quadraticModel c leftOne rightOne matched
            first second sideFirst sideSecond off
            (oddConfig left right σ))) ≤
        ∑ _σ : ι → Bool, (2 * B) :=
          Finset.sum_le_sum (fun σ _ => hstep σ)
      _ = (Fintype.card (ι → Bool) : ℝ) * (2 * B) := by simp
  have hmul : n * D ≤ n * (4 * B) := by
    nlinarith [hq, hidentity]
  change D ≤ 4 * B
  by_contra h
  have hd : 0 < D - 4 * B := sub_pos.mpr (lt_of_not_ge h)
  have hpositive : 0 < n * (D - 4 * B) := mul_pos hn hd
  nlinarith [hmul, hpositive]

end Nightfall.Observability.GlobalQuadraticParity
