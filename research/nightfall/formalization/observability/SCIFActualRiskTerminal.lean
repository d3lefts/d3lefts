import SCIFActualInfluence
import ActualSourceEfronStein

/-!
# Actual-source finite law-change Efron–Stein risk terminal (ALL degrees)

This statement composes the *actual full-product* resampling influence change
from #500 with the all-degree original-source Efron–Stein inequality from #506.
There is no old-law positivity or normalization assumption in the exact
transport identity. The new law q is nonnegative/normalized in the variance
inequality. Zero atoms are allowed. No interaction degree is bounded.

IMPORTANT: This is finite-source, finite-common-alphabet variance
recertification, not the generated-SCOF ownership terminal, minimum-cost
recertification, or arbitrary-index all-L² Measure.infinitePi theorem.
-/

namespace Nightfall.Observability.SCIFActualRiskTerminal
open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.SCIFActualInfluence
open Nightfall.Observability.ActualSourceEfronStein

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact signed change in source resampling influence when the product law
changes from p to q, retaining the same actual f. This is not an assumed
influence-change budget or a supplied oracle result. -/
noncomputable def influenceShift
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) : ℝ :=
  (∑ x : ι → α,
      (originalMass q x - originalMass p x) * (residual p f i x)^2) -
  2 * (∑ x : ι → α,
      originalMass q x * residual p f i x * lawDelta p q f i x) +
  (∑ x : ι → α,
      originalMass q x * (lawDelta p q f i x)^2)

/-- Pointwise exact actual original-source influence recertification. -/
theorem source_actual_influence_transport
    (p q : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) :
    sourceInfluence q f i =
      sourceInfluence p f i + influenceShift p q f i := by
  have h := source_influence_edited_difference p q f i
  unfold influenceShift
  linarith

/-- A zero law change yields exactly zero correction, including on zero atoms. -/
theorem source_influence_shift_zero_at_same_law
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) (i : ι) :
    influenceShift p p f i = 0 := by
  have h := source_actual_influence_transport p p f i
  linarith

/-- Actual changed-law finite-source Efron–Stein terminal; ALL interaction
orders. The right side uses genuine original-law influences plus the exact
signed source changes, while the left side is the true new-law variance.
Only the new law needs to be probabilistically normalized. -/
theorem source_variance_recertified_all_degree
    (p q : ι → α → ℝ)
    (hq : ∀ i a, 0 ≤ q i a)
    (hq1 : ∀ i, (∑ a : α, q i a) = 1)
    (f : (ι → α) → ℝ) :
    sourceVariance q f ≤
      ∑ i : ι, (sourceInfluence p f i + influenceShift p q f i) := by
  calc
    sourceVariance q f ≤ ∑ i : ι, sourceInfluence q f i :=
      original_source_all_degree_efron_stein q hq hq1 f
    _ = ∑ i : ι, (sourceInfluence p f i + influenceShift p q f i) := by
      apply Finset.sum_congr rfl
      intro i _
      exact source_actual_influence_transport p q f i

end Nightfall.Observability.SCIFActualRiskTerminal
