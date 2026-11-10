import ProductSpaceTwoSidedBridge

/-!
# NIGHTFALL finite ANOVA interaction-energy descent

This proves the *exact finite combinatorial identity* that removing a
revealed coordinate from every Hoeffding support reduces the expected
ANOVA total-influence potential by that coordinate's energy-weighted
influence. The assertion that conditional expectation on an actual
product probability space transforms the ANOVA coefficients this way is
a separate analytic theorem, NOT silently assumed or proved here.

The final theorem composes this bookkeeping with PR #300's existing
weighted_potential_descent to produce the explicit algebraic descent.
-/

namespace Nightfall.ProductSpace.Observation
open Finset Nightfall.ProductSpace.Discovery

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- Total interaction energy counted once per active coordinate. -/
def anovaTotalPotential (E : Finset ι → ℝ) : ℝ :=
  ∑ S : Finset ι, ∑ j ∈ S, E S

/-- The interaction energy involving a fixed coordinate. -/
def anovaCoordinateInfluence (E : Finset ι → ℝ) (i : ι) : ℝ :=
  ∑ S : Finset ι, if i ∈ S then E S else 0

/-- Potential after deleting one coordinate from every support, averaged
over the observed value at the level of squared ANOVA component energies. -/
def anovaRemainingPotential (E : Finset ι → ℝ) (i : ι) : ℝ :=
  ∑ S : Finset ι, ∑ j ∈ S.erase i, E S

/-- Exactly one copy of E(S) disappears when i belongs to support S. -/
theorem anova_component_erase (E : Finset ι → ℝ)
    (S : Finset ι) (i : ι) :
    (∑ j ∈ S.erase i, E S) +
      (if i ∈ S then E S else 0) =
    ∑ j ∈ S, E S := by
  by_cases hi : i ∈ S
  · simp only [if_pos hi]
    exact Finset.sum_erase_add S (fun _ : ι => E S) hi
  · simp [hi, Finset.erase_eq_of_notMem hi]

/-- **ANOVA support identity.** The exact expected influence removed by
conditioning on i is the weight of components whose support contains i.
This is a finite combinatorial theorem, not yet a theorem about the
probability-theoretic conditional expectation operator. -/
theorem anova_posterior_potential_identity
    (E : Finset ι → ℝ) (i : ι) :
    anovaRemainingPotential E i =
      anovaTotalPotential E - anovaCoordinateInfluence E i := by
  have hsum :
      anovaRemainingPotential E i +
      anovaCoordinateInfluence E i = anovaTotalPotential E := by
    unfold anovaRemainingPotential anovaCoordinateInfluence anovaTotalPotential
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro S _
    exact anova_component_erase E S i
  linarith

/-- Compose the ANOVA support identity with the already-certified
certificate-sampling potential-descent algebra. The sampling-law
normalization and influence-gain premise remain explicit, rather than
replacing an unproved posterior conditional-expectation theorem. -/
theorem anova_weighted_observation_descent
    (E : Finset ι → ℝ) (π : ι → ℝ) (gain : ℝ)
    (hπ : ∑ j, π j = 1)
    (hgain : gain ≤ ∑ j, π j * anovaCoordinateInfluence E j) :
    (∑ j, π j * anovaRemainingPotential E j) ≤
      anovaTotalPotential E - gain := by
  exact weighted_potential_descent π (anovaCoordinateInfluence E)
    (anovaRemainingPotential E) (anovaTotalPotential E) gain hπ hgain
    (anova_posterior_potential_identity E)

end Nightfall.ProductSpace.Observation
