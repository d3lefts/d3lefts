import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Fintype.Pi
import Mathlib.Tactic

namespace Nightfall.AllOrder.Quantum
open Finset
variable {A E : Type*} [Fintype A] [DecidableEq A] [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Real-weighted phase oracle, including the independent real cube extension. -/
noncomputable def oracle (P : A → E →ₗ[ℂ] E) (u : A → ℝ) (x : E) : E :=
  ∑ a, (u a : ℂ) • P a x

theorem orthogonal_sum_energy (v : A → E) (h : ∀ a b, a ≠ b → inner ℂ (v a) (v b) = 0) :
    ‖∑ a, v a‖^2 = ∑ a, ‖v a‖^2 := by
  classical
  have he : inner ℂ (∑ a, v a) (∑ a, v a) = ∑ a, inner ℂ (v a) (v a) := by
    rw [sum_inner]
    apply Finset.sum_congr rfl
    intro a _
    rw [inner_sum,Finset.sum_eq_single a]
    · intro b _ hb; exact h a b hb.symm
    · simp
  simp_rw [inner_self_eq_norm_sq_to_K] at he
  have hr := congrArg Complex.re he
  simpa [Complex.re_sum,← Complex.ofReal_pow] using hr

theorem oracle_contract (P : A → E →ₗ[ℂ] E)
    (hP : ∀ x a b, a ≠ b → inner ℂ (P a x) (P b x) = 0)
    (hsum : ∀ x, ∑ a, P a x = x) (u : A → ℝ) (hu : ∀ a, |u a| ≤ 1) (x : E) :
    ‖oracle P u x‖ ≤ ‖x‖ := by
  classical
  have h1 := orthogonal_sum_energy (fun a => P a x) (hP x)
  rw [hsum] at h1
  have h2 := orthogonal_sum_energy (fun a => (u a:ℂ) • P a x) (by
    intro a b hab; rw [inner_smul_left,inner_smul_right,hP x a b hab]; simp)
  have h3 : ‖oracle P u x‖^2 ≤ ‖x‖^2 := by
    unfold oracle
    rw [h2,h1]
    apply Finset.sum_le_sum
    intro a _
    rw [norm_smul,Complex.norm_real,Real.norm_eq_abs]
    exact pow_le_pow_left₀ (by positivity) (by nlinarith [hu a,norm_nonneg (P a x)]) 2
  nlinarith [norm_nonneg (oracle P u x),norm_nonneg x]

/-- The gate indexed by n is applied after the last (first stored) query. -/
noncomputable def run (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E) :
    (n : ℕ) → (Fin n → A → ℝ) → E
  | 0, _ => ψ
  | n+1, u => U n (oracle P (u 0) (run P U ψ n (fun i => u i.succ)))

noncomputable def path (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E) :
    (n : ℕ) → (Fin n → A) → E
  | 0, _ => ψ
  | n+1, b => U n (P (b 0) (path P U ψ n (fun i => b i.succ)))

theorem run_contract (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (hP : ∀ x a b, a ≠ b → inner ℂ (P a x) (P b x) = 0)
    (hsum : ∀ x, ∑ a, P a x = x) (hU : ∀ k x, ‖U k x‖ ≤ ‖x‖)
    (n : ℕ) (u : Fin n → A → ℝ) (hu : ∀ i a, |u i a| ≤ 1) : ‖run P U ψ n u‖ ≤ ‖ψ‖ := by
  induction n with
  | zero => exact le_rfl
  | succ n ih =>
    rw [run]
    exact (hU n _).trans ((oracle_contract P hP hsum (u 0) (hu 0) _).trans (ih _ (fun i => hu i.succ)))

theorem sum_cons_E (n : ℕ) (f : (Fin (n+1) → A) → E) :
    (∑ b, f b) = ∑ a : A, ∑ b : Fin n → A, f (Fin.cons a b) := by
  let e := Fin.consEquiv (fun _ : Fin (n+1) => A)
  rw [← e.sum_comp f, Fintype.sum_prod_type]
  rfl

/-- Exact amplitude expansion on independent real input blocks. -/
theorem run_path_expansion (P : A → E →ₗ[ℂ] E) (U : ℕ → E →ₗ[ℂ] E) (ψ : E)
    (n : ℕ) (u : Fin n → A → ℝ) :
    run P U ψ n u = ∑ b : Fin n → A, ((∏ i, u i (b i) : ℝ):ℂ) • path P U ψ n b := by
  classical
  induction n with
  | zero => simp [run,path]
  | succ n ih =>
    rw [run,oracle,ih,sum_cons_E]
    simp only [map_sum,map_smul,Fin.prod_univ_succ,Fin.cons_zero,Fin.cons_succ,path,Complex.ofReal_mul,mul_smul,Finset.smul_sum]

#print axioms oracle_contract
#print axioms run_contract
#print axioms run_path_expansion
end Nightfall.AllOrder.Quantum
