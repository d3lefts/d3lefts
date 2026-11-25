import AdaptiveInstrumentDegree
import QuantumCircuitNormalization

/-! Direct complex Kraus refinement. Each instrument outcome is refined into
its finite Kraus labels; duplicate continuations for hidden labels. The
amplitude history is unnormalized. Completeness is expressed operationally
as conservation of the sum of squared norms, and effects as two Kraus
operators for acceptance/rejection. No dilation or hardware claim. -/

namespace Nightfall.KrausAdaptive

open Finset
open Nightfall.AdaptiveInstrument
open Nightfall.QuantumCircuitNormalization

variable {ι α κ β : Type}
  [DecidableEq ι] [DecidableEq α] [Fintype ι] [Fintype α]
  [Fintype κ] [Fintype β]

theorem degree_product {d e : ℕ} {f g : (ι → α) → ℝ}
    (hf : Degree d f) (hg : Degree e g) :
    Degree (d + e) (fun x => f x * g x) := by
  induction hg with
  | atom S g hs hdep =>
      simpa only [mul_comm] using degree_mul_local hf S g hs hdep
  | add ha hb iha ihb =>
      simpa only [mul_add] using Degree.add iha ihb

def AmpDegree (d : ℕ) (v : (ι → α) → κ → ℂ) : Prop :=
  ∀ k, Degree d (fun x => (v x k).re) ∧ Degree d (fun x => (v x k).im)

theorem amp_const (v : κ → ℂ) : AmpDegree (ι := ι) (α := α) 0 (fun _ => v) := by
  intro k
  exact ⟨degree_const 0 (v k).re, degree_const 0 (v k).im⟩

theorem fixed_amp_degree (M : κ → κ → ℂ) {d : ℕ}
    (v : (ι → α) → κ → ℂ) (hv : AmpDegree d v) :
    AmpDegree d (fun x => applyMat M (v x)) := by
  intro k
  constructor
  · simp only [applyMat, Complex.re_sum, Complex.mul_re, sub_eq_add_neg, neg_mul]
    apply degree_sum
    intro j
    simpa only [neg_mul] using Degree.add (degree_scale (hv j).1 (M k j).re)
      (degree_scale (hv j).2 (-(M k j).im))
  · simp only [applyMat, Complex.im_sum, Complex.mul_im]
    apply degree_sum
    intro j
    -- Both terms are constant multiples, regardless of multiplication order.
    first
    | exact Degree.add (degree_scale (hv j).2 (M k j).re)
        (degree_scale (hv j).1 (M k j).im)
    | simpa only [mul_comm, add_comm] using
        (Degree.add (degree_scale (hv j).2 (M k j).re)
          (degree_scale (hv j).1 (M k j).im))

/-- The actual oracle is a sum of single-symbol matrix coefficients. -/
noncomputable def queryAmp (A : ι → α → κ → κ → ℂ)
    (x : ι → α) (v : κ → ℂ) : κ → ℂ :=
  fun k => ∑ i, ∑ j, A i (x i) k j * v j

theorem query_amp_degree (A : ι → α → κ → κ → ℂ) {d : ℕ}
    (v : (ι → α) → κ → ℂ) (hv : AmpDegree d v) :
    AmpDegree (d + 1) (fun x => queryAmp A x (v x)) := by
  intro k
  have hlocal (i : ι) (g : α → ℝ) : Depends ({i} : Finset ι) (fun x => g (x i)) := by
    intro x y h
    rw [h i (by simp)]
  constructor
  · simp only [queryAmp, Complex.re_sum, Complex.mul_re, sub_eq_add_neg, neg_mul]
    apply degree_sum
    intro i
    apply degree_sum
    intro j
    simpa only [neg_mul] using Degree.add
      (degree_mul_local (hv j).1 {i} _ (by simp) (hlocal i (fun a => (A i a k j).re)))
      (degree_mul_local (hv j).2 {i} _ (by simp) (hlocal i (fun a => -(A i a k j).im)))
  · simp only [queryAmp, Complex.im_sum, Complex.mul_im]
    apply degree_sum
    intro i
    apply degree_sum
    intro j
    have h1 := degree_mul_local (hv j).2 ({i} : Finset ι)
      (fun x => (A i (x i) k j).re) (k := 1) (by simp)
      (hlocal i (fun a => (A i a k j).re))
    have h2 := degree_mul_local (hv j).1 ({i} : Finset ι)
      (fun x => (A i (x i) k j).im) (k := 1) (by simp)
      (hlocal i (fun a => (A i a k j).im))
    first
    | exact Degree.add h1 h2
    | simpa only [mul_comm, add_comm] using Degree.add h1 h2

theorem energy_degree {d : ℕ} (v : (ι → α) → κ → ℂ)
    (hv : AmpDegree d v) : Degree (d + d) (fun x => energy (v x)) := by
  unfold energy
  apply degree_sum
  intro k
  simpa only [pow_two] using Degree.add
    (degree_product (hv k).1 (hv k).1) (degree_product (hv k).2 (hv k).2)

inductive Tree (ι α κ β : Type) : ℕ → Type where
  | stop (T : ℕ) (accept reject : κ → κ → ℂ) : Tree ι α κ β T
  | branch {T : ℕ} (K : β → κ → κ → ℂ)
      (next : β → Tree ι α κ β T) : Tree ι α κ β T
  | query {T : ℕ} (A : ι → α → κ → κ → ℂ)
      (next : Tree ι α κ β T) : Tree ι α κ β (T + 1)

noncomputable def evaluate : {T : ℕ} → Tree ι α κ β T →
    (ι → α) → (κ → ℂ) → ℝ
  | _, .stop _ E _, _, v => energy (applyMat E v)
  | _, .branch K next, x, v => ∑ b, evaluate (next b) x (applyMat (K b) v)
  | _, .query A next, x, v => evaluate next x (queryAmp A x v)

def Complete (K : β → κ → κ → ℂ) : Prop :=
  ∀ v : κ → ℂ, (∑ b, energy (applyMat (K b) v)) = energy v

def Valid : {T : ℕ} → Tree ι α κ β T → Prop
  | _, .stop _ E R =>
      ∀ v, energy (applyMat E v) + energy (applyMat R v) = energy v
  | _, .branch K next => Complete K ∧ ∀ b, Valid (next b)
  | _, .query A next =>
      (∀ x v, energy (queryAmp A x v) = energy v) ∧ Valid next

theorem evaluate_degree {T : ℕ} (P : Tree ι α κ β T) :
    ∀ d (v : (ι → α) → κ → ℂ), AmpDegree d v →
      Degree (2 * (d + T)) (fun x => evaluate P x (v x)) := by
  induction P with
  | stop T E R =>
      intro d v hv
      change Degree (2 * (d + T)) (fun x => energy (applyMat E (v x)))
      exact degree_mono (energy_degree _ (fixed_amp_degree E v hv)) (by omega)
  | @branch T K next ih =>
      intro d v hv
      change Degree (2 * (d + T))
        (fun x => ∑ b, evaluate (next b) x (applyMat (K b) (v x)))
      exact degree_sum _ _ (fun b => ih b d _ (fixed_amp_degree (K b) v hv))
  | @query T A next ih =>
      intro d v hv
      change Degree (2 * (d + (T + 1))) (fun x => evaluate next x (queryAmp A x (v x)))
      rw [show 2 * (d + (T + 1)) = 2 * ((d + 1) + T) by omega]
      exact ih (d + 1) _ (query_amp_degree A v hv)

theorem energy_nonneg (v : κ → ℂ) : 0 ≤ energy v := by
  unfold energy
  positivity

theorem evaluate_bounds {T : ℕ} (P : Tree ι α κ β T) :
    ∀ (h : Valid P) x v, 0 ≤ evaluate P x v ∧ evaluate P x v ≤ energy v := by
  induction P with
  | stop T E R =>
      intro h x v
      change 0 ≤ energy (applyMat E v) ∧ energy (applyMat E v) ≤ energy v
      have hc := h v
      exact ⟨energy_nonneg _, by linarith [energy_nonneg (applyMat R v)]⟩
  | @branch T K next ih =>
      intro h x v
      have hb (b : β) := ih b (h.2 b) x (applyMat (K b) v)
      change 0 ≤ (∑ b, evaluate (next b) x (applyMat (K b) v)) ∧
        (∑ b, evaluate (next b) x (applyMat (K b) v)) ≤ energy v
      refine ⟨Finset.sum_nonneg (fun b _ => (hb b).1), ?_⟩
      calc
        _ ≤ ∑ b, energy (applyMat (K b) v) := Finset.sum_le_sum (fun b _ => (hb b).2)
        _ = energy v := h.1 v
  | @query T A next ih =>
      intro h x v
      have hb := ih h.2 x (queryAmp A x v)
      exact ⟨hb.1, by simpa only [h.1 x v] using hb.2⟩

/-- Arbitrary finite pure-state ensemble (including mixed initial states).
Weights are absorbed into the unnormalized input amplitudes. -/
noncomputable def ensembleAccept {γ : Type} [Fintype γ] {T : ℕ}
    (P : Tree ι α κ β T) (v : γ → κ → ℂ) (x : ι → α) : ℝ :=
  ∑ c, evaluate P x (v c)

theorem ensemble_degree {γ : Type} [Fintype γ] {T : ℕ}
    (P : Tree ι α κ β T) (v : γ → κ → ℂ) :
    Degree (2 * T) (ensembleAccept P v) := by
  unfold ensembleAccept
  apply degree_sum
  intro c
  simpa only [zero_add] using evaluate_degree P 0 (fun _ => v c) (amp_const (v c))

theorem ensemble_range {γ : Type} [Fintype γ] {T : ℕ}
    (P : Tree ι α κ β T) (h : Valid P) (v : γ → κ → ℂ)
    (hn : ∑ c, energy (v c) = 1) (x : ι → α) :
    0 ≤ ensembleAccept P v x ∧ ensembleAccept P v x ≤ 1 := by
  unfold ensembleAccept
  have hb (c : γ) := evaluate_bounds P h x (v c)
  refine ⟨Finset.sum_nonneg (fun c _ => (hb c).1), ?_⟩
  calc
    (∑ c, evaluate P x (v c)) ≤ ∑ c, energy (v c) :=
      Finset.sum_le_sum (fun c _ => (hb c).2)
    _ = 1 := hn


/-- The stacked Kraus map is an isometry precisely under the operational
completeness contract. This checks the dilation's isometry step, not
extension to a square unitary or a controlled padding compiler. -/
noncomputable def stacked (K : β → κ → κ → ℂ) (v : κ → ℂ) :
    β × κ → ℂ := fun b => applyMat (K b.1) v b.2

theorem stacked_energy (K : β → κ → κ → ℂ) (v : κ → ℂ) :
    energy (stacked K v) = ∑ b, energy (applyMat (K b) v) := by
  simp only [energy, stacked, Fintype.sum_prod_type]

theorem stacked_isometry (K : β → κ → κ → ℂ) (h : Complete K) (v : κ → ℂ) :
    energy (stacked K v) = energy v := by
  rw [stacked_energy, h v]

/-- Refining Kraus labels is consistent with retaining their outcome
probabilities: summation over finite product indices equals iterated sums. -/
theorem kraus_outcome_refinement {γ : Type} [Fintype γ]
    (K : β → γ → κ → κ → ℂ) (v : κ → ℂ) :
    (∑ b : β × γ, energy (applyMat (K b.1 b.2) v)) =
      ∑ b : β, ∑ c : γ, energy (applyMat (K b c) v) := by
  rw [Fintype.sum_prod_type]

end Nightfall.KrausAdaptive

#print axioms Nightfall.KrausAdaptive.query_amp_degree
#print axioms Nightfall.KrausAdaptive.evaluate_degree
#print axioms Nightfall.KrausAdaptive.evaluate_bounds
#print axioms Nightfall.KrausAdaptive.ensemble_degree
#print axioms Nightfall.KrausAdaptive.ensemble_range

#print axioms Nightfall.KrausAdaptive.stacked_isometry
#print axioms Nightfall.KrausAdaptive.kraus_outcome_refinement
