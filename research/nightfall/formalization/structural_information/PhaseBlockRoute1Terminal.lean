import Route1PolylogSimulation
import PhaseBlockQuantumDegree
import PhaseBlockTreeCompiler

/-!
# Full source-connected phase-block / Route1 terminal for scalar acceptance

This invokes the existing kernel-checked NIGHTFALL Route1 polylog theorem on
ONE product component, with a genuine complex path-sum acceptance function.
The degree bound is derived by the independent source-exact path expansion
proof and converted definitionally to the existing product-space degree
predicate. The selected actual DTree is compiled to exactly three original
intensity queries per queried block.

Hypotheses:
* each oracle path transition reads precisely one sign-invariant block
* the scalar terminal f is in [0,1] for every input (physical quantum
  well-formedness of E and normalized circuit remains an open interface)
* input blocks are independent with finite product masses p
This theorem does NOT claim that arbitrary quantum circuits, arbitrary
sign-sensitive or global matrix queries satisfy these hypotheses.
-/

namespace Nightfall.PhaseBlockRoute1Terminal

open Finset
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.Route1Polylog
open Nightfall.PhaseBlockQuantumDegree
open Nightfall.PhaseBlockTreeCompiler

variable {B Path : Type*} [Fintype B] [DecidableEq B]
variable [Fintype Path] [DecidableEq Path]

/-- The supplied independent-block distribution. No latent mixing cost:
    the latent consists of a single unit label. -/
def singleProduct (p : B → Fin 8 → ℝ) : Unit → B → Fin 8 → ℝ :=
  fun _ => p

def singleWeight : Unit → ℝ := fun _ => 1

theorem singleWeight_nonneg : ∀ θ : Unit, 0 ≤ singleWeight θ := by
  intro θ
  norm_num [singleWeight]

theorem singleWeight_sum : ∑ θ : Unit, singleWeight θ = 1 := by
  simp [singleWeight]

/-- **NIGHTFALL combined terminal, exact source theorem and raw sensor cost.**
A finite complex path-sum whose oracle factors each depend on one hidden
sign-orbit block can be approximated under ANY independent product law of
these eight hidden block symbols. The returned original-sensor decision tree
has no B-factor; physical access count is bounded by 3*n *pointwise*.

Source actual theorem: Route1Polylog.route1_polylog_simulation, M=1.
This is a CONDITIONAL quantum model theorem. It is not a generic
arbitrary-oracle quantum simulator or source-specific circuit parser. -/
theorem phase_block_route1_simulation
    (T : ℕ) (hT : 0 < T)
    (site : Path → Fin T → B)
    (coeff : Path → ℂ)
    (kernel : Path → Fin T → Fin 8 → ℂ)
    (E : Path → Path → ℂ)
    (p : B → Fin 8 → ℝ)
    (hp0 : ∀ b a, 0 ≤ p b a)
    (hp1 : ∀ b, ∑ a, p b a = 1)
    (hbounded : ∀ x, 0 ≤ effectValue T site coeff kernel E x ∧
                        effectValue T site coeff kernel E x ≤ 1)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ rawtree : DTree (B × Fin 4) (Fin 26),
      (∀ x : B → Fin 8, rawtree.queries (rawTable x) ≤ 3 * n) ∧
      Ex (singleProduct p) singleWeight
          (fun x => if ε < |effectValue T site coeff kernel E x -
                  rawtree.eval (rawTable x)| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) /
        (2 * gam (2 * T) τ) +
        Real.log (Fintype.card Unit) /
          (etaC (2 * T) τ ^ 2 *
            w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2)
              (2 * T) τ)) / n + τ / ε ^ 2 := by
  classical
  let f : (B → Fin 8) → ℝ := effectValue T site coeff kernel E
  have hd : 1 ≤ 2 * T := by omega
  have hdeg : HasProdDegreeLE f (2 * T) := by
    exact effectValue_degree T site coeff kernel E
  have hbp : ∀ x, 0 ≤ f x ∧ f x ≤ 1 := hbounded
  have hP0 : ∀ θ b a, 0 ≤ singleProduct p θ b a := by
    intro θ b a
    exact hp0 b a
  have hP1 : ∀ θ b, ∑ a, singleProduct p θ b a = 1 := by
    intro θ b
    exact hp1 b
  obtain ⟨t, hq, he⟩ :=
    route1_polylog_simulation
      (singleProduct p) hP0 hP1
      singleWeight singleWeight_nonneg singleWeight_sum
      f hbp (2 * T) hd hdeg τ hτ hτ1 ε hε n hn
  refine ⟨compileTree t, ?_, ?_⟩
  · intro x
    rw [compileTree_queries]
    exact Nat.mul_le_mul_left 3 (hq x)
  · simpa only [f, compileTree_eval] using he

#print axioms Nightfall.PhaseBlockRoute1Terminal.phase_block_route1_simulation
#print Nightfall.PhaseBlockRoute1Terminal.phase_block_route1_simulation

end Nightfall.PhaseBlockRoute1Terminal
