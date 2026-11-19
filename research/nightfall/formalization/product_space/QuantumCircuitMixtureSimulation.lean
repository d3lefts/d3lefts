import QuantumCircuitSimulation
import MixtureSimulation

/-!
# Normalized quantum circuits on finite product mixtures

Composes the exact complex-circuit acceptance-degree theorem with the
Jensen product-mixture classical decision-tree simulator. There are no
postulated low-degree or probability-bound hypotheses: degree is derived from
query-path semantics and the [0,1] bound from `WellFormed` normalized
norm-preserving matrix gates.

`circuit_mixture_simulation_jensen` applies to the *exact mixture*.
`circuit_tv_approx_mixture_jensen` transfers the same tree to any probability
law within TV distance eta, paying *additively eta* in failure probability.

This is a theorem about whole-symbol query complexity on finite alphabets.
It does not bound classical runtime, characterize all quantum query oracles
independently of the matrix-model semantics, or prove novelty.
-/

namespace Nightfall.ProductSpace.QuantumCircuitMixture

open Finset
open Nightfall.ProductSpace

variable {ι α κ Θ : Type}
    [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]
    [Fintype κ] [Fintype Θ]

/-- The full input law induced by finite latent mixture weights and
independent coordinate marginals conditioned on the latent state. -/
noncomputable def mixtureMass (P : Θ → ι → α → ℝ) (w : Θ → ℝ)
    (x : ι → α) : ℝ :=
  ∑ θ, w θ * Transfer.prodMass (P θ) x

/-- A mixture with normalized component laws and weights is itself
normalized. Zero component weights and zero symbol masses are allowed. -/
theorem mixtureMass_sum_one (P : Θ → ι → α → ℝ)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw1 : ∑ θ, w θ = 1) :
    ∑ x : ι → α, mixtureMass P w x = 1 := by
  classical
  calc
    ∑ x : ι → α, mixtureMass P w x
        = ∑ θ, w θ * ∑ x : ι → α, Transfer.prodMass (P θ) x := by
            unfold mixtureMass
            rw [Finset.sum_comm]
            apply Finset.sum_congr rfl
            intro θ _
            rw [Finset.mul_sum]
    _ = ∑ θ, w θ := by
          apply Finset.sum_congr rfl
          intro θ _
          rw [Influence.sum_prodMass (P θ) (hP1 θ), mul_one]
    _ = 1 := hw1

/-- Reindex the mixture weighted expectation in terms of its genuine joint
input probability mass. -/
theorem mixtureEx_eq_mass (P : Θ → ι → α → ℝ)
    (w : Θ → ℝ) (f : (ι → α) → ℝ) :
    Mixture.Ex P w f = ∑ x : ι → α, mixtureMass P w x * f x := by
  classical
  unfold Mixture.Ex Influence.pexp mixtureMass
  calc
    ∑ θ, w θ * ∑ x : ι → α, Transfer.prodMass (P θ) x * f x
        = ∑ θ, ∑ x : ι → α,
            (w θ * Transfer.prodMass (P θ) x) * f x := by
              apply Finset.sum_congr rfl
              intro θ _
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro x _
              ring
    _ = ∑ x : ι → α, ∑ θ,
            (w θ * Transfer.prodMass (P θ) x) * f x :=
          Finset.sum_comm
    _ = ∑ x : ι → α, (∑ θ,
            w θ * Transfer.prodMass (P θ) x) * f x := by
              apply Finset.sum_congr rfl
              intro x _
              rw [Finset.sum_mul]

/-- Total variation on a finite space, equal to one-half of L1 distance
for two probability measures. -/
noncomputable def finiteTV (u v : (ι → α) → ℝ) : ℝ :=
  (∑ x : ι → α, |u x - v x|) / 2

/-- Exact event/soft-event transfer under total variation.
It is sufficient that both masses have total weight one and the test is
[0,1]-valued; all masses may be signed at this algebraic stage. -/
theorem finiteTV_bounded_transfer
    (u v : (ι → α) → ℝ)
    (hu : ∑ x : ι → α, u x = 1)
    (hv : ∑ x : ι → α, v x = 1)
    (g : (ι → α) → ℝ) (hg : ∀ x, 0 ≤ g x ∧ g x ≤ 1) :
    ∑ x : ι → α, u x * g x ≤
      (∑ x : ι → α, v x * g x) + finiteTV u v := by
  classical
  have hpoint : ∀ x : ι → α,
      (u x - v x) * g x ≤ ((u x - v x) + |u x - v x|) / 2 := by
    intro x
    rcases le_total 0 (u x - v x) with hpos | hneg
    · have hmul := mul_le_mul_of_nonneg_left (hg x).2 hpos
      rw [abs_of_nonneg hpos]
      nlinarith
    · have hmul := mul_nonpos_of_nonpos_of_nonneg hneg (hg x).1
      rw [abs_of_nonpos hneg]
      nlinarith
  have hsum : (∑ x : ι → α, (u x - v x) * g x) ≤
      (∑ x : ι → α, ((u x - v x) + |u x - v x|) / 2) :=
    Finset.sum_le_sum (fun x _ => hpoint x)
  have hnormal : (∑ x : ι → α, (u x - v x)) = 0 := by
    rw [Finset.sum_sub_distrib, hu, hv]
    ring
  have hleft : (∑ x : ι → α, (u x - v x) * g x) =
      (∑ x : ι → α, u x * g x) - (∑ x : ι → α, v x * g x) := by
    simp only [sub_mul, Finset.sum_sub_distrib]
  have hright : (∑ x : ι → α, ((u x - v x) + |u x - v x|) / 2) =
      finiteTV u v := by
    rw [Finset.sum_div, Finset.sum_add_distrib, hnormal]
    simp only [zero_add]
    rfl
  rw [hleft, hright] at hsum
  linarith

/-- Explicit quantum-circuit-to-mixture simulation.
The proof obtains Born boundedness from unitary normalization, obtains
interaction degree at most 2T from complex-query path semantics, and invokes
the existing Lean-certified Jensen theorem. -/
theorem circuit_mixture_simulation_jensen
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α,
      (∀ x, t.queries x ≤ n) ∧
      Mixture.Ex P w
        (fun x => if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x -
          t.eval x| then (1 : ℝ) else 0) ≤
        (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
          Fintype.card Θ / (τ * Real.sqrt τ) +
         512 * ((2 * T : ℕ) : ℝ) ^ 4 * (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) /
          n + τ / ε ^ 2 := by
  classical
  have hM : 0 < Fintype.card Θ := by
    rcases Nat.eq_zero_or_pos (Fintype.card Θ) with hzero | hpos
    · exfalso
      have : IsEmpty Θ := Fintype.card_eq_zero_iff.mp hzero
      simp at hw1
    · exact hpos
  let θ₀ : Θ := Classical.choice (Fintype.card_pos_iff.mp hM)
  have hBorn : ∀ x, 0 ≤ QuantumCircuitSimulation.acceptanceProbability c accept x ∧
      QuantumCircuitSimulation.acceptanceProbability c accept x ≤ 1 := by
    intro x
    simpa only [Nightfall.QuantumCircuitNormalization.probability,
      QuantumCircuitSimulation.acceptanceProbability] using
        Nightfall.QuantumCircuitNormalization.probability_in_unit_interval hc accept x
  have hdegree :
      RowBound.HasProdDegreeLE
        (QuantumCircuitSimulation.acceptanceProbability c accept) (2 * T) :=
    QuantumCircuitSimulation.acceptance_degree (P θ₀) (hP1 θ₀) T c accept
  have hd : 1 ≤ 2 * T := by omega
  exact Mixture.mixture_simulation_jensen P hP0 hP1 w hw0 hw1
    (QuantumCircuitSimulation.acceptanceProbability c accept)
    hBorn (2 * T) hd hdegree τ hτ hτ2 ε hε n hn

/-- A TV-eta perturbation of an M-component product mixture needs no new
oracle queries: the original simulated decision tree incurs at most eta
additional failure probability under the perturbed input law. -/
theorem circuit_tv_approx_mixture_jensen
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (nu : (ι → α) → ℝ)
    (hnu0 : ∀ x, 0 ≤ nu x)
    (hnu1 : ∑ x : ι → α, nu x = 1)
    (eta : ℝ) (heta : 0 ≤ eta)
    (htv : finiteTV nu (mixtureMass P w) ≤ eta)
    (T : ℕ) (hT : 1 ≤ T)
    (c : Nightfall.QuantumCircuitPaths.Circuit ι α κ T)
    (hc : Nightfall.QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (τ : ℝ) (hτ : 0 < τ) (hτ2 : τ ≤ 1 / 2)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : Simulation.DTree ι α,
      (∀ x, t.queries x ≤ n) ∧
      (∑ x : ι → α, nu x *
        (if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x -
           t.eval x| then (1 : ℝ) else 0)) ≤
        (3 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 *
          Fintype.card Θ / (τ * Real.sqrt τ) +
         512 * ((2 * T : ℕ) : ℝ) ^ 4 * (Fintype.card Θ : ℝ) ^ 4 / τ ^ 3) /
          n + τ / ε ^ 2 + eta := by
  classical
  obtain ⟨t, ht, herr⟩ :=
    circuit_mixture_simulation_jensen P hP0 hP1 w hw0 hw1 T hT c hc
      accept τ hτ hτ2 ε hε n hn
  refine ⟨t, ht, ?_⟩
  have htrans := finiteTV_bounded_transfer nu (mixtureMass P w) hnu1
    (mixtureMass_sum_one P hP1 w hw1)
    (fun x => if ε < |QuantumCircuitSimulation.acceptanceProbability c accept x -
      t.eval x| then (1 : ℝ) else 0)
    (fun x => by split_ifs <;> constructor <;> norm_num)
  rw [← mixtureEx_eq_mass P w] at htrans
  linarith

end Nightfall.ProductSpace.QuantumCircuitMixture

#print axioms Nightfall.ProductSpace.QuantumCircuitMixture.circuit_mixture_simulation_jensen
#print axioms Nightfall.ProductSpace.QuantumCircuitMixture.circuit_tv_approx_mixture_jensen
