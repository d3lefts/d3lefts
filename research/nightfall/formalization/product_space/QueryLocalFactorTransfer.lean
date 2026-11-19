import QueryLocalDegree
import QueryDecoderLift
import MixtureSimulation

/-!
# NIGHTFALL — source-aware query-local factor theorem (Theorem 2)

An observed source X = Phi(Z), with latent Z drawn from a finite mixture of
M independent product distributions, admits a distribution-uniform whole-symbol
classical simulator when:

- Phi_i depends on at most b latent symbols (a semantic LocalEncoding proof);
- each latent symbol Z_j has an observed decoder of depth at most r;
- the original observed function f is [0,1] bounded, indicator degree ≤ d.

No source-atom positivity lower bound, injectivity, or oracle-time claim.
The non-degenerate Jensen degree used by the simulator is max 1 (b*d).
This is the exact-source structural transfer. A bounded-support variant and
TV robustness are separate gates.
-/

namespace Nightfall.ProductSpace.QueryLocalFactor

open Finset
open Nightfall.ProductSpace
open Nightfall.ProductSpace.QueryLocalDegree
open Nightfall.ProductSpace.QueryDecoderLift

variable {I J α β Θ : Type}
  [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [Fintype α] [DecidableEq α]
  [Fintype β] [DecidableEq β] [Nonempty β]
  [Fintype Θ] [Nonempty Θ]

/-- Indicator degree is monotone in the permitted support order. -/
private theorem degree_mono (g : (J → β) → ℝ)
    (d d' : ℕ) (hdd : d ≤ d')
    (hd : RowBound.HasProdDegreeLE g d) :
    RowBound.HasProdDegreeLE g d' := by
  obtain ⟨a, ha, hrep⟩ := hd
  refine ⟨a, ?_, hrep⟩
  intro S hS τ
  exact ha S (lt_of_le_of_lt hdd hS) τ

/-- The certified Jensen mixture error budget after pulling d back to D. -/
noncomputable def jensenError (D M n : ℕ) (τ ε : ℝ) : ℝ :=
  (3 * Real.sqrt 2 * Real.pi ^ 6 * (D : ℝ) ^ 6 * M /
      (τ * Real.sqrt τ) +
    512 * (D : ℝ) ^ 4 * (M : ℝ) ^ 4 / τ ^ 3) / n +
  τ / ε ^ 2

/-- A single observed decision tree simulates f across all M components.
Every observed input has query depth ≤r*n. On each encoded latent input the
output matches the latent Jensen simulator exactly. -/
theorem factor_mixture_simulation_jensen
    (P : Θ → J → β → ℝ)
    (hP0 : ∀ θ j v, 0 ≤ P θ j v)
    (hP1 : ∀ θ j, ∑ v, P θ j v = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ)
    (hPhi : LocalEncoding Phi deps b)
    (dec : J → DecoderTree I α β)
    (r : ℕ)
    (hdec : ∀ j z, (dec j).eval (Phi z) = z j)
    (hcost : ∀ j x, (dec j).queries x ≤ r)
    (f : (I → α) → ℝ)
    (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : RowBound.HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree I α,
      (∀ x, t.queries x ≤ r * n) ∧
      Mixture.Ex P w
        (fun z => if ε < |f (Phi z) - t.eval (Phi z)|
                  then (1 : ℝ) else 0) ≤
        jensenError (max 1 (b * d)) (Fintype.card Θ) n τ ε := by
  classical
  let g : (J → β) → ℝ := fun z => f (Phi z)
  let D := max 1 (b * d)
  have hD : 1 ≤ D := Nat.le_max_left 1 (b * d)
  let θ₀ : Θ := Classical.choice inferInstance
  have h0 : RowBound.HasProdDegreeLE g (b * d) :=
    degree_pullback (P θ₀) (hP1 θ₀) Phi deps b hPhi f d hd
  have hdegree : RowBound.HasProdDegreeLE g D :=
    degree_mono g (b * d) D (Nat.le_max_right 1 (b * d)) h0
  have hg01 : ∀ z, 0 ≤ g z ∧ g z ≤ 1 := fun z => hf01 (Phi z)
  obtain ⟨u, hu, herr⟩ :=
    Mixture.mixture_simulation_jensen P hP0 hP1
      w hw0 hw1 g hg01 D hD hdegree τ hτ hτ2 ε hε n hn
  let t := substitute dec r n u
  refine ⟨t, fun x => substitute_queries dec r n u x, ?_⟩
  have heq : (fun z : J → β =>
          if ε < |f (Phi z) - t.eval (Phi z)| then (1 : ℝ) else 0) =
      (fun z : J → β =>
          if ε < |g z - u.eval z| then (1 : ℝ) else 0) := by
    funext z
    change (if ε < |f (Phi z) - (substitute dec r n u).eval (Phi z)|
             then (1 : ℝ) else 0) =
      (if ε < |f (Phi z) - u.eval z| then (1 : ℝ) else 0)
    rw [substitute_eval dec Phi hdec r hcost n u hu z]
  change Mixture.Ex P w
    (fun z => if ε < |f (Phi z) - t.eval (Phi z)| then (1 : ℝ) else 0) ≤
    (3 * Real.sqrt 2 * Real.pi ^ 6 * (D : ℝ) ^ 6 * Fintype.card Θ /
       (τ * Real.sqrt τ) +
     512 * (D : ℝ) ^ 4 * (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) / n +
     τ / ε ^ 2
  rw [heq]
  exact herr

/-- If n meets the exact Jensen error budget, the observed factor tree
achieves failure probability ≤delta under the pushforward source. -/
theorem factor_mixture_simulation_delta
    (P : Θ → J → β → ℝ)
    (hP0 : ∀ θ j v, 0 ≤ P θ j v)
    (hP1 : ∀ θ j, ∑ v, P θ j v = 1)
    (w : Θ → ℝ)
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (Phi : (J → β) → (I → α))
    (deps : I → Finset J) (b : ℕ)
    (hPhi : LocalEncoding Phi deps b)
    (dec : J → DecoderTree I α β)
    (r : ℕ)
    (hdec : ∀ j z, (dec j).eval (Phi z) = z j)
    (hcost : ∀ j x, (dec j).queries x ≤ r)
    (f : (I → α) → ℝ)
    (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : RowBound.HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (δ : ℝ) (n : ℕ) (hn : 0 < n)
    (hbudget : jensenError (max 1 (b * d)) (Fintype.card Θ) n τ ε ≤ δ) :
    ∃ t : Simulation.DTree I α,
      (∀ x, t.queries x ≤ r * n) ∧
      Mixture.Ex P w
        (fun z => if ε < |f (Phi z) - t.eval (Phi z)|
                  then (1 : ℝ) else 0) ≤ δ := by
  obtain ⟨t, ht, herr⟩ :=
    factor_mixture_simulation_jensen P hP0 hP1 w hw0 hw1
      Phi deps b hPhi dec r hdec hcost f hf01 d hd
      τ hτ hτ2 ε hε n hn
  exact ⟨t, ht, le_trans herr hbudget⟩

end Nightfall.ProductSpace.QueryLocalFactor
