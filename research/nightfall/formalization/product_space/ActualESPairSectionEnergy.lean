import ActualESPairEnergyFubini

/-!
# Exact conditional-section energy of every original source pair

For a genuine two-coordinate Efron–Stein component h_{ij}, its
source pair energy is simultaneously:

(1) the L2 norm under the actual joint product law,
(2) the p_i × p_j energy of its canonical pair table,
(3) E_{X_{-i}} [ sum_a p_i(a) h_{ij}(a,X_j)^2 ].

The third expression is the original conditional-section energy.
Its expectation uses the complete original product law for X and
the exact source marginal p_i. No artificial neighbor product,
supplied energy bound or conditional independence assertion.

This is a source-level identity for every interaction; later
orthogonality allows these identities to add within an owner.
-/

namespace Nightfall.Observability.ActualESPairSectionEnergy

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESOwnedEnergy

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Actual conditional squared L2 section energy of one canonical
source pair (i,j), computed against the original product law. -/
noncomputable def actualPairSectionEnergy
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) : ℝ :=
  ∑ x : ι → α, prodMass p x *
    (∑ a : α, p i a *
      (esComp p ({i,j} : Finset ι) f
        (Function.update x i a))^2)

/-- The genuine source pair component's coordinate section is
literally its canonical pair table with the other coordinate from
the same input x. -/
theorem actual_pair_source_section_eq_kernel
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ)
    (base x : ι → α)
    (i j : ι) (hij : i ≠ j) (a : α) :
    esComp p ({i,j} : Finset ι) f
      (Function.update x i a) =
      actualPairKernel p f base i j a (x j) := by
  have h := actual_pair_component_is_kernel
    p f base (Function.update x i a) i j hij
  simpa [hij] using h

/-- Exact identity: the original product-law conditional-section energy
of the genuine Efron–Stein interaction equals its literal p_i p_j
pair-kernel energy. No lower bound on masses is needed. -/
theorem actual_pair_section_energy_eq_source_pair_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (i j : ι) (hij : i ≠ j) :
    actualPairSectionEnergy p f i j =
      sourcePairEnergy p f base i j := by
  classical
  unfold actualPairSectionEnergy sourcePairEnergy
  calc
    (∑ x : ι → α, prodMass p x *
      (∑ a : α, p i a *
        (esComp p ({i,j} : Finset ι) f
          (Function.update x i a))^2)) =
      ∑ x : ι → α, prodMass p x *
        (∑ a : α, p i a *
          (actualPairKernel p f base i j a (x j))^2) := by
            apply Finset.sum_congr rfl
            intro x _
            congr 1
            apply Finset.sum_congr rfl
            intro a _
            rw [actual_pair_source_section_eq_kernel p f base x i j hij a]
    _ = ∑ b : α, p j b *
        (∑ a : α, p i a *
          (actualPairKernel p f base i j a b)^2) := by
            exact sum_prodMass_coord p hp1 j
              (fun b => ∑ a : α, p i a *
                (actualPairKernel p f base i j a b)^2)
    _ = ∑ a : α, ∑ b : α,
        p i a * p j b *
          (actualPairKernel p f base i j a b)^2 := by
            rw [Finset.sum_comm]
            apply Finset.sum_congr rfl
            intro a _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro b _
            ring

end Nightfall.Observability.ActualESPairSectionEnergy
