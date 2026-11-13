import ActualESGlobalVariance
import ActualESGreedyOwnership

/-!
# True source-owned Hilbert second moments and greedy energy partition

Each owner i receives a finite set of actual source pair components,
and every source coordinate resampling is performed under the original
p product measure. This avoids identifying fake independent copies
with true repeated-coordinate source distributions.

The exact second-moment identity follows from the source resample_sum
operator and original-source Efron–Stein orthogonality. The ownership
partition then gives the sum over all graph edges, each exactly once.
-/

namespace Nightfall.Observability.ActualESOwnedSecondMoment

open Finset
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.ActualESGreedyOwnership
open Nightfall.Observability.ActualESOrthogonality
open Nightfall.Observability.ActualESGlobalVariance

variable {E ι α : Type*}
  [Fintype E] [DecidableEq E]
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact owned sum of canonical source interactions. Every graph edge
indexes exactly one 2-coordinate component, and owner i is its endpoint. -/
noncomputable def ownedComponentSum
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E) (i : ι) (x : ι → α) : ℝ :=
  (ownedEdges u v c T i).sum
    (fun e => esComp p ({u e, v e} : Finset ι) f x)

/-- Original-source Hilbert second moment of the owned section,
resampling the i-coordinate directly from the genuine source law. -/
noncomputable def ownedSourceMoment2
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E) (i : ι) : ℝ :=
  ∑ x : ι → α, prodMass p x *
    (∑ a : α, p i a *
      (ownedComponentSum p f u v c T i
        (Function.update x i a))^2)

/-- Every distinct edge is genuinely a different unordered coordinate
pair. Under this simple-graph hypothesis the owned source components are
orthogonal under the actual product law. The hypothesis is structural,
not an energy or amplitude estimate. -/
theorem ownedSourceMoment2_eq_pair_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E)
    (hSimple : ∀ e f : E,
      ({u e, v e} : Finset ι) = {u f, v f} → e = f)
    (i : ι) :
    ownedSourceMoment2 p f u v c T i =
      (ownedEdges u v c T i).sum
        (fun e => ∑ x : ι → α, prodMass p x *
          (esComp p ({u e, v e} : Finset ι) f x)^2) := by
  classical
  let g : E → (ι → α) → ℝ :=
    fun e x => esComp p ({u e, v e} : Finset ι) f x
  let G : (ι → α) → ℝ :=
    fun x => ((ownedEdges u v c T i).sum (fun e => g e x))^2
  have horth : ∀ e d : E, e ≠ d →
      (∑ x : ι → α, prodMass p x * g e x * g d x) = 0 := by
    intro e d hed
    exact actual_esComp_orthogonal p hp1 f
      ({u e, v e} : Finset ι)
      ({u d, v d} : Finset ι)
      (by
        intro heq
        exact hed (hSimple e d heq))
  have hresample :
      ownedSourceMoment2 p f u v c T i =
        ∑ x : ι → α, prodMass p x * G x := by
    calc
      ownedSourceMoment2 p f u v c T i =
        ∑ x : ι → α, ∑ a : α,
          prodMass p x * p i a * G (Function.update x i a) := by
            unfold ownedSourceMoment2
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            dsimp [G, ownedComponentSum, g]
            ring
      _ = ∑ x : ι → α, prodMass p x * G x :=
          resample_sum p hp1 i G
  calc
    ownedSourceMoment2 p f u v c T i =
      ∑ x : ι → α, prodMass p x * G x := hresample
    _ = (ownedEdges u v c T i).sum
        (fun e => ∑ x : ι → α, prodMass p x *
          (g e x)^2) :=
          weighted_square_of_orthogonal_sum
            (prodMass p) g horth (ownedEdges u v c T i)
    _ = (ownedEdges u v c T i).sum
        (fun e => ∑ x : ι → α, prodMass p x *
          (esComp p ({u e, v e} : Finset ι) f x)^2) := rfl

/-- The total source-owned Hilbert second moment is exactly the sum of
the original pair energies, each edge occurring once. No supplied
moment2, influence cap, or matching mass is assumed. -/
theorem total_ownedSourceMoment2_eq_all_pair_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (u v : E → ι) (c : ι → ℝ)
    (T : Finset E)
    (hSimple : ∀ e f : E,
      ({u e, v e} : Finset ι) = {u f, v f} → e = f) :
    (∑ i : ι, ownedSourceMoment2 p f u v c T i) =
      T.sum (fun e => ∑ x : ι → α, prodMass p x *
        (esComp p ({u e, v e} : Finset ι) f x)^2) := by
  classical
  calc
    (∑ i : ι, ownedSourceMoment2 p f u v c T i) =
      ∑ i : ι, (ownedEdges u v c T i).sum
        (fun e => ∑ x : ι → α, prodMass p x *
          (esComp p ({u e, v e} : Finset ι) f x)^2) := by
            apply Finset.sum_congr rfl
            intro i _
            exact ownedSourceMoment2_eq_pair_energy
              p hp1 f u v c T hSimple i
    _ = T.sum (fun e => ∑ x : ι → α, prodMass p x *
        (esComp p ({u e, v e} : Finset ι) f x)^2) :=
          owned_energy_partition u v c T _

end Nightfall.Observability.ActualESOwnedSecondMoment
