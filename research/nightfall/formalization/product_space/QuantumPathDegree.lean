import ProductSimulation
import EfronSteinDegree

/-!
# NIGHTFALL — finite quantum path amplitudes and indicator degree

A sum-of-paths normal form for complex quantum amplitudes, represented by real
and imaginary coefficients. A path records at most T queried (coordinate,symbol)
pairs. Each path contributes the product of its coordinate equality indicators.

The Born probability is the sum over output basis states of the squared real and
imaginary amplitudes. It has indicator interaction degree at most 2T; this
declaration *derives* the degree hypothesis of ProductSimulation.

IMPORTANT: this file certifies the path-sum model. It does not yet certify that
every arbitrary unitary query circuit can be converted to these coefficients.
That circuit-to-path extraction lemma is a separate formalization obligation.
-/

namespace Nightfall.ProductSpace.QuantumPath

open Finset
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.EfronStein

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- A junta of support size at most d has indicator degree at most d.
    The product law is used only to choose explicit interpolation coefficients. -/
private theorem degree_of_junta (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (S : Finset ι) (d : ℕ) (hc : S.card ≤ d)
    (g : (ι → α) → ℝ) (hg : DependsOn S g) :
    HasProdDegreeLE g d := by
  classical
  let a : Finset ι → (ι → α) → ℝ :=
    fun T τ => if T = S then g τ * ∏ i, (if i ∈ S then (1 : ℝ) else p i (τ i)) else 0
  refine ⟨a, ?_, ?_⟩
  · intro T ht τ
    by_cases hTS : T = S
    · subst T
      exact (False.elim ((Nat.not_lt_of_ge hc) ht))
    · simp [a, hTS]
  · intro x
    change g x = ∑ T : Finset ι, ∑ τ : ι → α, a T τ * indMono T τ x
    rw [Finset.sum_eq_single S]
    · simpa only [a, ite_true] using (junta_expand p hp1 S g hg x).symm
    · intro T _ hTS
      simp [a, hTS]
    · intro hS
      exact (hS (Finset.mem_univ S)).elim

/-- Finite sums preserve indicator degree. -/
private theorem degree_sum {β : Type} [Fintype β]
    (g : β → (ι → α) → ℝ) (d : ℕ)
    (hg : ∀ b, HasProdDegreeLE (g b) d) :
    HasProdDegreeLE (fun x => ∑ b, g b x) d := by
  classical
  choose a ha0 heq using hg
  refine ⟨fun T τ => ∑ b, a b T τ, ?_, ?_⟩
  · intro T hT τ
    exact Finset.sum_eq_zero fun b _ => ha0 b T hT τ
  · intro x
    calc
      (∑ b, g b x) =
          ∑ b, ∑ T : Finset ι, ∑ τ : ι → α, a b T τ * indMono T τ x :=
        Finset.sum_congr rfl fun b _ => heq b x
      _ = ∑ T : Finset ι, ∑ τ : ι → α,
          ∑ b, a b T τ * indMono T τ x := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro T _
          rw [Finset.sum_comm]
      _ = ∑ T : Finset ι, ∑ τ : ι → α,
          (∑ b, a b T τ) * indMono T τ x := by
          simp_rw [Finset.sum_mul]

/-- The branch schedule for T symbolic coordinate queries. -/
abbrev Trace (T : ℕ) (ι α : Type) := Fin T → ι × α

/-- Product of the queried symbol indicators along a path. -/
noncomputable def traceIndicator {T : ℕ} (σ : Trace T ι α)
    (x : ι → α) : ℝ :=
  ∏ k : Fin T, (if x (σ k).1 = (σ k).2 then 1 else 0)

/-- Coordinates mentioned by a path. -/
def traceSupport {T : ℕ} (σ : Trace T ι α) : Finset ι :=
  (Finset.univ : Finset (Fin T)).image (fun k => (σ k).1)

theorem traceSupport_card {T : ℕ} (σ : Trace T ι α) :
    (traceSupport σ).card ≤ T := by
  calc
    (traceSupport σ).card ≤ (Finset.univ : Finset (Fin T)).card := by
      unfold traceSupport
      exact Finset.card_image_le
    _ = T := by simp

theorem traceIndicator_dep {T : ℕ} (σ : Trace T ι α) :
    DependsOn (traceSupport σ) (traceIndicator σ) := by
  intro x y hxy
  unfold traceIndicator
  apply Finset.prod_congr rfl
  intro k _
  have hmem : (σ k).1 ∈ traceSupport σ := by
    unfold traceSupport
    exact Finset.mem_image.mpr ⟨k, Finset.mem_univ _, rfl⟩
  rw [hxy _ hmem]

/-- Joint support for the interference term of two paths. -/
def pairSupport {T : ℕ} (σ τ : Trace T ι α) : Finset ι :=
  traceSupport σ ∪ traceSupport τ

theorem pairSupport_card {T : ℕ} (σ τ : Trace T ι α) :
    (pairSupport σ τ).card ≤ 2 * T := by
  calc
    (pairSupport σ τ).card ≤ (traceSupport σ).card + (traceSupport τ).card := by
      unfold pairSupport
      exact Finset.card_union_le _ _
    _ ≤ T + T := Nat.add_le_add (traceSupport_card σ) (traceSupport_card τ)
    _ = 2 * T := by omega

theorem pairIndicator_dep {T : ℕ} (σ τ : Trace T ι α) (c : ℝ) :
    DependsOn (pairSupport σ τ)
      (fun x => c * traceIndicator σ x * traceIndicator τ x) := by
  intro x y hxy
  have hσ := traceIndicator_dep σ x y
    (fun i hi => hxy i (Finset.mem_union_left _ hi))
  have hτ := traceIndicator_dep τ x y
    (fun i hi => hxy i (Finset.mem_union_right _ hi))
  simp only [hσ, hτ]

variable {κ : Type} [Fintype κ]

/-- Real and imaginary path amplitudes, with arbitrary complex coefficients
    encoded as their two real components. -/
noncomputable def amplitudeRe (T : ℕ)
    (c : κ → Trace T ι α → ℝ) (x : ι → α) (k : κ) : ℝ :=
  ∑ σ, c k σ * traceIndicator σ x

/-- Born acceptance probability, written directly as the quadratic path expansion.
    The coefficient of each interference term is cReσ cReτ + cImσ cImτ. -/
noncomputable def pathBorn (T : ℕ)
    (cRe cIm : κ → Trace T ι α → ℝ) (x : ι → α) : ℝ :=
  ∑ k : κ, ∑ σ : Trace T ι α, ∑ τ : Trace T ι α,
    (cRe k σ * cRe k τ + cIm k σ * cIm k τ) *
      traceIndicator σ x * traceIndicator τ x

/-- The path Born probability is exactly the sum of squared real and
imaginary amplitude components. -/
theorem pathBorn_eq_squares (T : ℕ)
    (cRe cIm : κ → Trace T ι α → ℝ) (x : ι → α) :
    pathBorn T cRe cIm x =
    ∑ k : κ, ((amplitudeRe T cRe x k) ^ 2 + (amplitudeRe T cIm x k) ^ 2) := by
  unfold pathBorn amplitudeRe
  apply Finset.sum_congr rfl
  intro k _
  have hsq (c : Trace T ι α → ℝ) :
      (∑ σ, c σ * traceIndicator σ x) ^ 2 =
        ∑ σ, ∑ τ, (c σ * c τ) * traceIndicator σ x * traceIndicator τ x := by
    rw [pow_two, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro σ _
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro τ _
    ring
  rw [hsq (cRe k), hsq (cIm k), ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro σ _
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro τ _
  ring

/-- Fully explicit finite-query path representation yields degree at most 2T.
    No assumed low-degree hypothesis appears in this theorem. -/
theorem pathBorn_degree (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1) (T : ℕ)
    (cRe cIm : κ → Trace T ι α → ℝ) :
    HasProdDegreeLE (pathBorn T cRe cIm) (2 * T) := by
  unfold pathBorn
  apply degree_sum
  intro k
  apply degree_sum
  intro σ
  apply degree_sum
  intro τ
  exact degree_of_junta p hp1 (pairSupport σ τ) (2 * T)
    (pairSupport_card σ τ) _
    (pairIndicator_dep σ τ
      (cRe k σ * cRe k τ + cIm k σ * cIm k τ))

/-- Plug the newly proved degree theorem into the certified uniform
    product-law classical simulator. The independent bound [0,1] is required
    of the acceptance probability, as it is for any legitimate quantum POVM. -/
theorem pathBorn_simulation (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (T : ℕ) (hT : 1 ≤ T)
    (cRe cIm : κ → Trace T ι α → ℝ)
    (hBorn : ∀ x, 0 ≤ pathBorn T cRe cIm x ∧ pathBorn T cRe cIm x ≤ 1)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (n : ℕ)
    (hn : 384 * Real.sqrt 2 * Real.pi ^ 6 * (T : ℝ) ^ 6 ≤
      n * (ε ^ 3 * δ ^ 2 * Real.sqrt δ)) :
    ∃ t : Simulation.DTree ι α,
      (∀ x, t.queries x ≤ n) ∧
      ∑ x, Transfer.prodMass p x *
        (if ε < |pathBorn T cRe cIm x - t.eval x| then (1 : ℝ) else 0) ≤ δ := by
  have hd : 1 ≤ 2 * T := by omega
  have hdegree := pathBorn_degree p hp1 T cRe cIm
  have hn' : 6 * Real.sqrt 2 * Real.pi ^ 6 * ((2 * T : ℕ) : ℝ) ^ 6 ≤
      n * (ε ^ 3 * δ ^ 2 * Real.sqrt δ) := by
    convert hn using 1 <;> push_cast <;> ring
  exact Simulation.simulation_degree p hp hp1
    (pathBorn T cRe cIm) (2 * T) hd hBorn hdegree ε δ hε hδ n hn'

end Nightfall.ProductSpace.QuantumPath
