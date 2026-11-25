import AllOrderTruncation
import T2ClippedEstimator
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FieldSimp

namespace Nightfall.AllOrder
open Finset
open Nightfall.StructuralInformation.T2UniformParseval
open Nightfall.StructuralInformation.T2ClippedEstimator
variable {I A P G : Type*} [Fintype I] [DecidableEq I] [Fintype A] [DecidableEq A]
  [Fintype P] [DecidableEq P] [AddCommGroup G] [Fintype G] [DecidableEq G]

noncomputable def phaseEval (label : A → G) (S : Finset (I → A)) (c : (I → A) → ℝ)
    (s : AddChar G ℂ) : ℝ :=
  ∑ b ∈ S, c b * sign s (∑ i, label (b i))

noncomputable def querySet (c : P → (I → A) → ℝ) (t : ℝ) : Finset A :=
  univ.biUnion (fun p => selectedLabels (c p) t)

noncomputable def keptPaths (c : (I → A) → ℝ) (S : Finset (I → A)) (t : ℝ) : Finset (I → A) :=
  S \ residualPaths c t

noncomputable def omittedPaths (c : (I → A) → ℝ) (S : Finset (I → A)) (t : ℝ) : Finset (I → A) :=
  S ∩ residualPaths c t

/-- Actual total charge of original query labels across all patterns. -/
theorem all_pattern_query_card (c : P → (I → A) → ℝ) (t : ℝ) (m : ℕ) (ht : 0 < t)
    (hr : ∀ p i, (∑ a, rowNorm (c p) i a) ≤ (m : ℝ)*t) :
    (querySet c t).card ≤ Fintype.card P * Fintype.card I * m := by
  classical
  unfold querySet
  calc
    _ ≤ ∑ p : P, (selectedLabels (c p) t).card := Finset.card_biUnion_le
    _ ≤ ∑ _ : P, Fintype.card I * m := Finset.sum_le_sum fun p _ => selected_card (c p) t m ht (hr p)
    _ = _ := by simp [Nat.mul_assoc]

/-- Exact decomposition into kept and discarded signed path sums. -/
theorem phase_eval_split (label : A → G) (c : (I → A) → ℝ) (S : Finset (I → A)) (t : ℝ)
    (s : AddChar G ℂ) : phaseEval label S c s - phaseEval label (keptPaths c S t) c s =
    phaseEval label (omittedPaths c S t) c s := by
  classical
  unfold phaseEval keptPaths omittedPaths
  have hs : S ∩ residualPaths c t ⊆ S := Finset.inter_subset_left
  have hd : S \ (S ∩ residualPaths c t) = S \ residualPaths c t := by ext b; simp
  have h := Finset.sum_sdiff (f := fun b : I → A => c b * sign s (∑ i, label (b i))) hs
  rw [hd] at h
  linarith

/-- Single pattern uniform character risk from the actual support fiber and row mixed-norm caps. -/
theorem pattern_omitted_risk (label : A → G) (h₂ : ∀ z : G, z+z=0)
    (c : (I → A) → ℝ) (S : Finset (I → A)) (t M : ℝ) (B : ℕ) (ht : 0 ≤ t)
    (hr : ∀ i, (∑ a, rowNorm c i a) ≤ M)
    (hB : ∀ z : G, (S.filter (fun b => (∑ i, label (b i)) = z)).card ≤ B) :
    (∑ s : AddChar G ℂ, (phaseEval label (omittedPaths c S t) c s)^2) ≤
      (Fintype.card G : ℝ) * (B : ℝ) * (Fintype.card I : ℝ) * (t*M) := by
  classical
  have hB' : ∀ z : G, ((omittedPaths c S t).filter (fun b => (∑ i, label (b i)) = z)).card ≤ B := by
    intro z
    apply le_trans (Finset.card_le_card _) (hB z)
    intro b hb
    obtain ⟨h1,h2⟩ := Finset.mem_filter.mp hb
    exact Finset.mem_filter.mpr ⟨(Finset.mem_inter.mp h1).1,h2⟩
  have h := active_fiber_risk h₂ (omittedPaths c S t) (fun b => ∑ i, label (b i)) c B hB'
  have hsub : (∑ b ∈ omittedPaths c S t, (c b)^2) ≤ ∑ b ∈ residualPaths c t, (c b)^2 :=
    Finset.sum_le_sum_of_subset_of_nonneg Finset.inter_subset_right (fun _ _ _ => sq_nonneg _)
  have htail := hsub.trans (residual_energy c t M ht hr)
  unfold phaseEval
  calc
    _ ≤ (Fintype.card G : ℝ) * ((B : ℝ) * ∑ b ∈ omittedPaths c S t, (c b)^2) := h
    _ ≤ (Fintype.card G : ℝ) * ((B : ℝ) * ((Fintype.card I : ℝ) * (t*M))) := by
      exact mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left htail (by positivity)) (by positivity)
    _ = _ := by ring

/-- The kept contribution depends only on the *original* queried labels. -/
theorem kept_depends (label : A → G) (h₂ : ∀ z : G, z+z=0)
    (c : P → (I → A) → ℝ) (S : P → Finset (I → A)) (t : ℝ)
    (s s' : AddChar G ℂ)
    (hag : ∀ a ∈ querySet c t, s (label a) = s' (label a)) :
    (∑ p, phaseEval label (keptPaths (c p) (S p) t) (c p) s) =
      ∑ p, phaseEval label (keptPaths (c p) (S p) t) (c p) s' := by
  classical
  apply Finset.sum_congr rfl
  intro p _
  unfold phaseEval
  apply Finset.sum_congr rfl
  intro b hb
  have hret := (Finset.mem_sdiff.mp hb).2
  congr 1
  rw [sign_sum h₂, sign_sum h₂]
  apply Finset.prod_congr rfl
  intro i _
  have hsel := retained_uses_selected (c p) t b hret i
  have hq : b i ∈ querySet c t := Finset.mem_biUnion.mpr ⟨p,Finset.mem_univ p,hsel⟩
  exact congrArg Complex.re (hag (b i) hq)

/-- All-pattern source-matched uniform risk. The external tensor bound and
    mixed-norm theorem are explicit quantitative inputs; the Fourier and
    truncation algebra is not assumed. -/
theorem all_pattern_risk (label : A → G) (h₂ : ∀ z : G, z+z=0)
    (c : P → (I → A) → ℝ) (S : P → Finset (I → A)) (t M : ℝ) (B : ℕ) (ht : 0 ≤ t)
    (hr : ∀ p i, (∑ a, rowNorm (c p) i a) ≤ M)
    (hB : ∀ p z, ((S p).filter (fun b => (∑ i, label (b i)) = z)).card ≤ B) :
    (∑ s : AddChar G ℂ,
      ((∑ p, phaseEval label (S p) (c p) s) -
        (∑ p, phaseEval label (keptPaths (c p) (S p) t) (c p) s))^2) ≤
      (Fintype.card G : ℝ) * ((Fintype.card P : ℝ)^2 * (B : ℝ) * (Fintype.card I : ℝ) * (t*M)) := by
  classical
  simp_rw [← Finset.sum_sub_distrib, phase_eval_split]
  calc
    _ ≤ ∑ s : AddChar G ℂ, (Fintype.card P : ℝ) *
          ∑ p, (phaseEval label (omittedPaths (c p) (S p) t) (c p) s)^2 := by
      apply Finset.sum_le_sum
      intro s _
      have h := Finset.sum_mul_sq_le_sq_mul_sq (univ : Finset P) (fun _ => (1 : ℝ))
        (fun p => phaseEval label (omittedPaths (c p) (S p) t) (c p) s)
      simpa only [one_mul, one_pow, Finset.sum_const, nsmul_eq_mul, mul_one, Finset.card_univ] using h
    _ = (Fintype.card P : ℝ) * ∑ p, ∑ s : AddChar G ℂ,
          (phaseEval label (omittedPaths (c p) (S p) t) (c p) s)^2 := by
      rw [← Finset.mul_sum, Finset.sum_comm]
    _ ≤ (Fintype.card P : ℝ) * ∑ _ : P,
        (Fintype.card G : ℝ) * (B : ℝ) * (Fintype.card I : ℝ) * (t*M) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact Finset.sum_le_sum fun p _ => pattern_omitted_risk label h₂ (c p) (S p) t M B ht (hr p) (hB p)
    _ = _ := by simp; ring

/-- All-order, original-coordinate deterministic nonadaptive simulation,
    conditional on the exact contracted-pattern representation and its
    row-norm/fiber caps. This is not an unconditional tensor theorem. -/
theorem all_pattern_simulation (label : A → G) (h₂ : ∀ z : G, z+z=0)
    (c : P → (I → A) → ℝ) (S : P → Finset (I → A)) (t M eps delta : ℝ) (B m : ℕ)
    (ht : 0 < t) (heps : 0 < eps)
    (hMt : M ≤ (m : ℝ)*t)
    (hr : ∀ p i, (∑ a, rowNorm (c p) i a) ≤ M)
    (hB : ∀ p z, ((S p).filter (fun b => (∑ i, label (b i)) = z)).card ≤ B)
    (hf : ∀ s : AddChar G ℂ, 0 ≤ (∑ p, phaseEval label (S p) (c p) s) ∧
        (∑ p, phaseEval label (S p) (c p) s) ≤ 1)
    (hbudget : (Fintype.card P : ℝ)^2 * (B : ℝ) * (Fintype.card I : ℝ) * (t*M) ≤ eps^2*delta) :
    ∃ Q : Finset A, Q.card ≤ Fintype.card P * Fintype.card I * m ∧
      ∃ g : (↑Q → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar G ℂ =>
        eps < |(∑ p, phaseEval label (S p) (c p) s) - g (fun a => s (label a.1))|)).card : ℝ) ≤
        (Fintype.card (AddChar G ℂ) : ℝ)*delta := by
  classical
  let Q := querySet c t
  let τ : AddChar G ℂ → (↑Q → ℂ) := fun s a => s (label a.1)
  let f : AddChar G ℂ → ℝ := fun s => ∑ p, phaseEval label (S p) (c p) s
  let k : AddChar G ℂ → ℝ := fun s => ∑ p, phaseEval label (keptPaths (c p) (S p) t) (c p) s
  have hdep : ∀ s s', τ s = τ s' → k s = k s' := by
    intro s s' heq
    apply kept_depends label h₂ c S t s s'
    intro a ha
    exact congrFun heq ⟨a,ha⟩
  have henergy : (∑ s : AddChar G ℂ, (f s - k s)^2) ≤ (Fintype.card (AddChar G ℂ) : ℝ) * eps^2 * delta := by
    rw [AddChar.card_eq]
    calc
      _ ≤ (Fintype.card G : ℝ) * ((Fintype.card P : ℝ)^2 * (B : ℝ) * (Fintype.card I : ℝ) * (t*M)) :=
        all_pattern_risk label h₂ c S t M B ht.le hr hB
      _ ≤ (Fintype.card G : ℝ) * (eps^2 * delta) := mul_le_mul_of_nonneg_left hbudget (by positivity)
      _ = _ := by ring
  refine ⟨Q,all_pattern_query_card c t m ht (fun p i => (hr p i).trans hMt),
    clippedTranscriptEstimator τ k, clippedTranscriptEstimator_range τ k, ?_⟩
  exact clipped_estimator_uniform_success τ f k hf hdep eps delta heps henergy

#print axioms all_pattern_query_card
#print axioms phase_eval_split
#print axioms pattern_omitted_risk
#print axioms kept_depends
#print axioms all_pattern_risk
#print axioms all_pattern_simulation
end Nightfall.AllOrder
