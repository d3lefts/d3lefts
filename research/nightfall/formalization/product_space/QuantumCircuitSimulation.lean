import QuantumCircuitPaths
import QuantumPathDegree
import QuantumCircuitNormalization

/-!
# NIGHTFALL — uniform classical simulation of finite quantum query circuits

Unconditionally derives the interaction degree bound for the acceptance
probability of finite complex matrix-oracle query circuits from their
semantics, then invokes the pinned product-law simulator.

The matrix-oracle class includes conventional finite-dimensional quantum
query algorithms whose x-dependent oracle has entries affine-linear in
one-coordinate symbol indicators. Fixed (input-independent) unitaries are
a special case of the unconstrained matrices in Circuit.step.

Probability [0,1] is required of the circuit acceptance value. A normalized
unitary circuit supplies this condition, but the theorem does not assert
unitarity of arbitrary matrices.
-/

namespace Nightfall.ProductSpace.QuantumCircuitSimulation

open Finset
open Nightfall.ProductSpace

variable {ι α κ : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
  [Fintype κ]

/-- The real indicator product is the complex query-path weight. -/
private theorem traceWeight_eq_ofReal {T : ℕ}
    (σ : QuantumCircuitPaths.Trace T ι α) (x : ι → α) :
    QuantumCircuitPaths.traceWeight σ x =
      (QuantumPath.traceIndicator σ x : ℂ) := by
  classical
  unfold QuantumCircuitPaths.traceWeight QuantumPath.traceIndicator
  rw [Complex.ofReal_prod]
  apply Finset.prod_congr rfl
  intro j _
  by_cases h : x (σ j).1 = (σ j).2
  · simp [QuantumCircuitPaths.symbol, h]
  · simp [QuantumCircuitPaths.symbol, h]

/-- Actual circuit amplitudes have the real-component path expansion. -/
theorem execute_re_eq_path_amplitude {T : ℕ}
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (x : ι → α) (k : κ) :
    (QuantumCircuitPaths.execute c x k).re =
      QuantumPath.amplitudeRe T
        (fun k σ => (QuantumCircuitPaths.pathCoeff c σ k).re) x k := by
  rw [QuantumCircuitPaths.execute_eq_path_sum]
  rw [Complex.re_sum]
  unfold QuantumPath.amplitudeRe
  apply Finset.sum_congr rfl
  intro σ _
  rw [traceWeight_eq_ofReal]
  simp [Complex.mul_re]

/-- Actual circuit amplitudes have the imaginary-component path expansion. -/
theorem execute_im_eq_path_amplitude {T : ℕ}
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (x : ι → α) (k : κ) :
    (QuantumCircuitPaths.execute c x k).im =
      QuantumPath.amplitudeRe T
        (fun k σ => (QuantumCircuitPaths.pathCoeff c σ k).im) x k := by
  rw [QuantumCircuitPaths.execute_eq_path_sum]
  rw [Complex.im_sum]
  unfold QuantumPath.amplitudeRe
  apply Finset.sum_congr rfl
  intro σ _
  rw [traceWeight_eq_ofReal]
  simp [Complex.mul_im]

/-- The acceptance probability computed from the actual complex gate
    semantics and a Boolean accepted-output-basis predicate. -/
noncomputable def acceptanceProbability {T : ℕ}
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool) (x : ι → α) : ℝ :=
  ∑ k : κ, if accept k then
    ((QuantumCircuitPaths.execute c x k).re ^ 2 +
     (QuantumCircuitPaths.execute c x k).im ^ 2)
    else 0

/-- Convert accepted complex path amplitudes to real coefficients. -/
noncomputable def acceptedRe {T : ℕ}
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool)
    (k : κ) (σ : QuantumPath.Trace T ι α) : ℝ :=
  if accept k then (QuantumCircuitPaths.pathCoeff c σ k).re else 0

/-- Convert accepted complex path amplitudes to imaginary coefficients. -/
noncomputable def acceptedIm {T : ℕ}
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool)
    (k : κ) (σ : QuantumPath.Trace T ι α) : ℝ :=
  if accept k then (QuantumCircuitPaths.pathCoeff c σ k).im else 0

/-- The circuit's physical Born acceptance probability equals the path
    quadratic formula, not merely a degree-bounded surrogate. -/
theorem acceptance_eq_pathBorn {T : ℕ}
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool) (x : ι → α) :
    acceptanceProbability c accept x =
      QuantumPath.pathBorn T (acceptedRe c accept) (acceptedIm c accept) x := by
  rw [QuantumPath.pathBorn_eq_squares]
  unfold acceptanceProbability
  apply Finset.sum_congr rfl
  intro k _
  by_cases hk : accept k = true
  · simp only [hk, ite_true]
    simp only [QuantumPath.amplitudeRe, acceptedRe, acceptedIm, hk, ite_true]
    have hre := execute_re_eq_path_amplitude c x k
    have him := execute_im_eq_path_amplitude c x k
    simp only [QuantumPath.amplitudeRe] at hre him
    rw [hre, him]
  · have hf : accept k = false := Bool.eq_false_of_ne_true hk
    simp [QuantumPath.amplitudeRe, acceptedRe, acceptedIm, hf]

/-- The key missing quantum-to-polynomial theorem, stated on the circuit's
    actual complex matrix-entry execution semantics; no degree hypothesis. -/
theorem acceptance_degree (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1) (T : ℕ)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool) :
    RowBound.HasProdDegreeLE (acceptanceProbability c accept) (2 * T) := by
  have heq : acceptanceProbability c accept =
      QuantumPath.pathBorn T (acceptedRe c accept) (acceptedIm c accept) :=
    funext (acceptance_eq_pathBorn c accept)
  rw [heq]
  exact QuantumPath.pathBorn_degree p hp1 T
    (acceptedRe c accept) (acceptedIm c accept)

/-- Direct uniform classical simulation for finite matrix-oracle circuits.
    T counts oracle calls; the circuit acceptance probability is calculated
    from its complex execution semantics, not postulated to have degree ≤2T.

    For a normalized unitary quantum circuit, the [0,1] bound hBorn holds.
    The result needs no lower bound on any symbol probability. -/
theorem circuit_uniform_simulation (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (accept : κ → Bool)
    (hBorn : ∀ x, 0 ≤ acceptanceProbability c accept x ∧
      acceptanceProbability c accept x ≤ 1)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (n : ℕ)
    (hn : 384 * Real.sqrt 2 * Real.pi ^ 6 * (T : ℝ) ^ 6 ≤
      n * (ε ^ 3 * δ ^ 2 * Real.sqrt δ)) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, Transfer.prodMass p x *
        (if ε < |acceptanceProbability c accept x - t.eval x| then (1 : ℝ) else 0) ≤ δ := by
  have hP : ∀ x, 0 ≤ QuantumPath.pathBorn T (acceptedRe c accept)
      (acceptedIm c accept) x ∧
      QuantumPath.pathBorn T (acceptedRe c accept) (acceptedIm c accept) x ≤ 1 := by
    intro x
    rw [← acceptance_eq_pathBorn c accept x]
    exact hBorn x
  obtain ⟨t, ht, herr⟩ := QuantumPath.pathBorn_simulation
    p hp hp1 T hT (acceptedRe c accept) (acceptedIm c accept)
    hP ε δ hε hδ n hn
  refine ⟨t, ht, ?_⟩
  simpa only [← acceptance_eq_pathBorn] using herr


/-- **Physical quantum circuit terminal.** A norm-one initial state and
norm-preserving fixed/oracle matrices imply that the computed Born acceptance
probability lies in [0,1]. Therefore the law-uniform simulation theorem needs
no independent acceptance-probability boundedness premise.

The matrix-oracle formalism encompasses standard finite-dimensional
whole-symbol quantum query algorithms. -/
theorem unitary_circuit_uniform_simulation (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (c : QuantumCircuitPaths.Circuit ι α κ T)
    (hc : QuantumCircuitNormalization.WellFormed c)
    (accept : κ → Bool)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ)
    (n : ℕ)
    (hn : 384 * Real.sqrt 2 * Real.pi ^ 6 * (T : ℝ) ^ 6 ≤
      n * (ε ^ 3 * δ ^ 2 * Real.sqrt δ)) :
    ∃ t : Simulation.DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, Transfer.prodMass p x *
        (if ε < |acceptanceProbability c accept x - t.eval x| then (1 : ℝ) else 0) ≤ δ := by
  have hb : ∀ x, 0 ≤ acceptanceProbability c accept x ∧
      acceptanceProbability c accept x ≤ 1 := by
    intro x
    simpa only [QuantumCircuitNormalization.probability, acceptanceProbability] using
      QuantumCircuitNormalization.probability_in_unit_interval hc accept x
  exact circuit_uniform_simulation p hp hp1 T hT c accept hb ε δ hε hδ n hn

end Nightfall.ProductSpace.QuantumCircuitSimulation
