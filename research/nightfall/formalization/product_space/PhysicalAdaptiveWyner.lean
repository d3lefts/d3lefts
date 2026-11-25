import AdaptiveInstrumentWyner
import ComplexKrausConservation

/-! Finite adaptive complex Kraus programs, directly interpreted as
unnormalized pure trajectories. Refine each observed outcome by the
Kraus index and duplicate its continuation on all refinements. Summing
trajectories computes the acceptance probability of the mixed ensemble.
No caller-supplied scalar degree/range or abstract state-cone hypothesis.
Terminal effects are given by accepting/rejecting Kraus factors; this
module does not prove existence of spectral square roots of arbitrary
positive effects or construct an explicit coherent dilation circuit. -/
namespace Nightfall.PhysicalAdaptiveWyner

open Finset
open Nightfall.AdaptiveInstrument
open Nightfall.ComplexKrausConservation
open Nightfall.QuantumCircuitNormalization
open Nightfall.QuantumResponseOracleBridge
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.Route1Polylog

variable {ι α κ β η : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
  [Fintype κ] [DecidableEq κ] [Fintype β] [Fintype η]

theorem degree_mul {d e : ℕ} {f g : (ι → α) → ℝ}
    (hf : Degree d f) (hg : Degree e g) :
    Degree (d + e) (fun x => g x * f x) := by
  induction hg with
  | atom S g hc hS => exact degree_mul_local hf S g hc hS
  | add hg hh ihg ihh =>
      simpa only [add_mul] using (Degree.add ihg ihh)

theorem degree_sub {d : ℕ} {f g : (ι → α) → ℝ}
    (hf : Degree d f) (hg : Degree d g) :
    Degree d (fun x => f x - g x) := by
  have hn := degree_scale hg (-1)
  simpa only [neg_one_mul, sub_eq_add_neg] using (Degree.add hf hn)

def AmpDegree (d : ℕ) (ψ : (ι → α) → κ → ℂ) : Prop :=
  ∀ k, Degree d (fun x => (ψ x k).re) ∧ Degree d (fun x => (ψ x k).im)

theorem fixed_amp_degree (A : κ → κ → ℂ)
    (ψ : (ι → α) → κ → ℂ) (d : ℕ)
    (hψ : AmpDegree d ψ) :
    AmpDegree d (fun x => applyMat A (ψ x)) := by
  intro k
  constructor
  · simp only [applyMat, Complex.re_sum, Complex.mul_re]
    apply degree_sum
    intro v
    exact degree_sub (degree_scale (hψ v).1 (A k v).re)
      (degree_scale (hψ v).2 (A k v).im)
  · simp only [applyMat, Complex.im_sum, Complex.mul_im]
    apply degree_sum
    intro v
    exact Degree.add (degree_scale (hψ v).2 (A k v).re)
      (by simpa only [mul_comm] using degree_scale (hψ v).1 (A k v).im)

noncomputable def queryMat (C : ι → α → κ → κ → ℂ)
    (x : ι → α) (k v : κ) : ℂ :=
  ∑ i, C i (x i) k v

theorem query_amp_degree (C : ι → α → κ → κ → ℂ)
    (ψ : (ι → α) → κ → ℂ) (d : ℕ)
    (hψ : AmpDegree d ψ) :
    AmpDegree (d + 1) (fun x => applyMat (queryMat C x) (ψ x)) := by
  have hre (i : ι) (k v : κ) :
      Depends ({i} : Finset ι) (fun x => (C i (x i) k v).re) := by
    intro x y h
    rw [h i (by simp)]
  have him (i : ι) (k v : κ) :
      Depends ({i} : Finset ι) (fun x => (C i (x i) k v).im) := by
    intro x y h
    rw [h i (by simp)]
  intro k
  constructor
  · simp only [applyMat, queryMat, Finset.sum_mul, Complex.re_sum, Complex.mul_re]
    apply degree_sum
    intro v
    apply degree_sum
    intro i
    exact degree_sub
      (degree_mul_local (hψ v).1 {i} _ (by simp) (hre i k v))
      (degree_mul_local (hψ v).2 {i} _ (by simp) (him i k v))
  · simp only [applyMat, queryMat, Finset.sum_mul, Complex.im_sum, Complex.mul_im]
    apply degree_sum
    intro v
    apply degree_sum
    intro i
    exact Degree.add
      (degree_mul_local (hψ v).2 {i} _ (by simp) (hre i k v))
      (by simpa only [mul_comm] using
        degree_mul_local (hψ v).1 {i} _ (by simp) (him i k v))

theorem energy_degree (ψ : (ι → α) → κ → ℂ) (d : ℕ)
    (hψ : AmpDegree d ψ) :
    Degree (2 * d) (fun x => energy (ψ x)) := by
  rw [show 2 * d = d + d by omega]
  unfold energy
  apply degree_sum
  intro k
  simpa only [pow_two] using
    Degree.add (degree_mul (hψ k).1 (hψ k).1)
      (degree_mul (hψ k).2 (hψ k).2)

/-- A refined Kraus outcome is a branch label. A terminal node accepts one
Kraus factor from a complete instrument (sum of accepted outcomes can be
represented by further branching). -/
inductive Program (ι α κ β : Type) : ℕ → Type where
  | stop (T : ℕ) (A : β → κ → κ → ℂ) (accept : β) : Program ι α κ β T
  | branch {T : ℕ} (A : β → κ → κ → ℂ)
      (next : β → Program ι α κ β T) : Program ι α κ β T
  | query {T : ℕ} (C : ι → α → κ → κ → ℂ)
      (next : Program ι α κ β T) : Program ι α κ β (T + 1)

noncomputable def eval : {T : ℕ} → Program ι α κ β T →
    (ι → α) → (κ → ℂ) → ℝ
  | _, .stop _ A b, _, ψ => energy (applyMat (A b) ψ)
  | _, .branch A next, x, ψ => ∑ b, eval (next b) x (applyMat (A b) ψ)
  | _, .query C next, x, ψ => eval next x (applyMat (queryMat C x) ψ)

def Valid : {T : ℕ} → Program ι α κ β T → Prop
  | _, .stop _ A _ => Complete A
  | _, .branch A next => Complete A ∧ ∀ b, Valid (next b)
  | _, .query C next => (∀ x, IsUnitary (queryMat C x)) ∧ Valid next

theorem eval_degree {T : ℕ} (P : Program ι α κ β T) :
    ∀ (d : ℕ) (ψ : (ι → α) → κ → ℂ), AmpDegree d ψ →
      Degree (2 * (d + T)) (fun x => eval P x (ψ x)) := by
  induction P with
  | stop T A b =>
      intro d ψ hψ
      exact degree_mono
        (energy_degree _ d (fixed_amp_degree (A b) ψ d hψ)) (by omega)
  | @branch T A next ih =>
      intro d ψ hψ
      change Degree (2 * (d + T)) (fun x => ∑ b, eval (next b) x (applyMat (A b) (ψ x)))
      exact degree_sum _ _ (fun b => ih b d _ (fixed_amp_degree (A b) ψ d hψ))
  | @query T C next ih =>
      intro d ψ hψ
      change Degree (2 * (d + (T + 1))) (fun x => eval next x (applyMat (queryMat C x) (ψ x)))
      rw [show d + (T + 1) = (d + 1) + T by omega]
      exact ih (d + 1) _ (query_amp_degree C ψ d hψ)

theorem eval_range {T : ℕ} (P : Program ι α κ β T) :
    ∀ (h : Valid P) (x : ι → α) (ψ : κ → ℂ),
      0 ≤ eval P x ψ ∧ eval P x ψ ≤ energy ψ := by
  induction P with
  | stop T A b =>
      intro h x ψ
      exact terminal_effect_bounds A h ψ b
  | @branch T A next ih =>
      intro h x ψ
      have hb (b : β) := ih b (h.2 b) x (applyMat (A b) ψ)
      change 0 ≤ (∑ b, eval (next b) x (applyMat (A b) ψ)) ∧
        (∑ b, eval (next b) x (applyMat (A b) ψ)) ≤ energy ψ
      refine ⟨Finset.sum_nonneg (fun b _ => (hb b).1), ?_⟩
      calc
        (∑ b, eval (next b) x (applyMat (A b) ψ)) ≤
            ∑ b, energy (applyMat (A b) ψ) :=
          Finset.sum_le_sum (fun b _ => (hb b).2)
        _ = energy ψ := apply_energy_sum A h.1 ψ
  | @query T C next ih =>
      intro h x ψ
      have hb := ih h.2 x (applyMat (queryMat C x) ψ)
      change 0 ≤ eval next x (applyMat (queryMat C x) ψ) ∧
        eval next x (applyMat (queryMat C x) ψ) ≤ energy ψ
      exact ⟨hb.1, (hb.2.trans_eq (h.1 x ψ))⟩

noncomputable def acceptance {T : ℕ} (P : Program ι α κ β T)
    (ψ : η → κ → ℂ) (x : ι → α) : ℝ :=
  ∑ h, eval P x (ψ h)

theorem acceptance_degree {T : ℕ} (P : Program ι α κ β T)
    (ψ : η → κ → ℂ) :
    HasProdDegreeLE (acceptance P ψ) (2 * T) := by
  apply degree_to_indicator reference reference_sum
  unfold acceptance
  apply degree_sum
  intro h
  have h0 : AmpDegree (ι := ι) (α := α) 0 (fun _ => ψ h) :=
    fun k => ⟨degree_const 0 (ψ h k).re, degree_const 0 (ψ h k).im⟩
  simpa only [zero_add] using eval_degree P 0 (fun _ => ψ h) h0

theorem acceptance_range {T : ℕ} (P : Program ι α κ β T)
    (hP : Valid P) (ψ : η → κ → ℂ) (hn : ∑ h, energy (ψ h) = 1)
    (x : ι → α) :
    0 ≤ acceptance P ψ x ∧ acceptance P ψ x ≤ 1 := by
  unfold acceptance
  refine ⟨Finset.sum_nonneg (fun h _ => (eval_range P hP x (ψ h)).1), ?_⟩
  rw [← hn]
  exact Finset.sum_le_sum (fun h _ => (eval_range P hP x (ψ h)).2)

/-- Direct finite physical Kraus-program acceptance terminal. The only
state/gate assumptions are ensemble normalization, Kraus completeness
and oracle unitarity; all terminal degree and range bounds are derived. -/
theorem physical_adaptive_wyner
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (T : ℕ) (hT : 1 ≤ T) (P : Program ι α κ β T) (hP : Valid P)
    (ψ : η → κ → ℂ) (hnorm : ∑ h, energy (ψ h) = 1)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε) (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |acceptance P ψ x - t.eval x| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) / (2 * gam (2 * T) τ) +
        s / (etaC (2 * T) τ ^ 2 *
          w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) (2 * T) τ)) / n + τ / ε ^ 2 := by
  exact route1_wyner_general ν hν0 hν1 (acceptance P ψ)
    (acceptance_range P hP ψ hnorm) (2 * T) (by omega)
    (acceptance_degree P ψ) τ hτ hτ1 ε hε n hn s hs

end Nightfall.PhysicalAdaptiveWyner

#print axioms Nightfall.PhysicalAdaptiveWyner.query_amp_degree
#print axioms Nightfall.PhysicalAdaptiveWyner.acceptance_degree
#print axioms Nightfall.PhysicalAdaptiveWyner.acceptance_range
#print axioms Nightfall.PhysicalAdaptiveWyner.physical_adaptive_wyner
