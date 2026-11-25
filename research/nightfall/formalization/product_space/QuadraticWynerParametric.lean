import Route1WynerSimulation

/-!
# Route 1/Wyner: parametric certified original-coordinate simulator

This proof extracts the shared tree/remaining-information-potential machinery
from the already verified Route 1 terminal. It assumes an *explicit* source
good-query certificate hgood; it does NOT prove the quadratic source crux.
Any all-dimensional QW terminal must supply hgood from the actual Q2 theorem,
seed coupling, variance comparison and original-coordinate transfer.

The same parameterization also supports a same-model assessment of the #939
mean-increment alternative without conflating log M and Wyner information.
No source-specific improvement is claimed by this wrapper alone.
-/
namespace Nightfall.Route1Polylog
open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
variable (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

-- These source-law hypotheses occur in the proof, not the goal's syntax.
include hP0 hP1

/-- Source-parameterized Wyner tree. The improved QW bound is NOT proved
until hgood is instantiated by a genuine original-source quadratic crux. -/
theorem route1_wyner_from_verified_good
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (ga gb : ℝ) (hga : 0 < ga) (hgb : 0 < gb)
    (hgood : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ),
      StD f (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d A v g →
      τ * Vs v < mvar P v g →
      ∃ j, j ∉ A ∧ GoodW P ga gb A v g j) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Ex P w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / ga +
          mutInfo P w / gb) / n + τ / ε ^ 2 := by
  set K : ℝ := Real.pi ^ 2 * (d : ℝ) ^ 2 / 2 with hKdef
  set t := wbuild P τ ga gb n ∅ w f with htdef
  refine ⟨t, wqueries_le P τ ga gb n ∅ w f, ?_⟩
  have hS0 : StD f K d ∅ w f :=
    ⟨⟨hw0, fun i hi => absurd hi (Finset.notMem_empty i), hasRows_of_degree f d hf01 hdeg,
      rep_empty f, hf01⟩, hdeg⟩
  have hbq := wbad_queries P τ ga gb (StD f K d)
    (fun A v g j b hS hj => StD_pres P hP0 f K d A v g j b hS hj)
    (fun A v g hS hvar => hgood A v g hS hvar)
    n ∅ w f hS0
  have hq := wexpected P hP0 hP1 τ ga gb hga hgb n ∅ w f hw0
  have herr := wleaf_error P hP0 hP1 τ ga gb hτ.le n ∅ w f hw0
  have hVw : Vs w = 1 := hw1
  rw [hVw, mul_one] at herr
  have hε2 : 0 < ε ^ 2 := by positivity
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hpt : ∀ x, (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (t.queries x : ℝ) / n + (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    intro x
    by_cases hb : t.bad x = true
    · have hqn : (t.queries x : ℝ) = n := by exact_mod_cast hbq x hb
      rw [hqn, div_self hn'.ne']
      simp only [hb, ite_true, zero_div, add_zero]
      split_ifs <;> norm_num
    · simp only [hb, Bool.false_eq_true, ite_false]
      have hq0 : 0 ≤ (t.queries x : ℝ) / n := by positivity
      split_ifs with hlt
      · have h1 : ε ^ 2 < (f x - t.eval x) ^ 2 := by
          have := pow_lt_pow_left₀ hlt hε.le two_ne_zero; rwa [sq_abs] at this
        have : 1 ≤ (f x - t.eval x) ^ 2 / ε ^ 2 := by rw [le_div_iff₀ hε2, one_mul]; exact h1.le
        linarith
      · have : 0 ≤ (f x - t.eval x) ^ 2 / ε ^ 2 := by positivity
        linarith
  have hmono := Ex_mono P w hw0 hP0 _ _ hpt
  have hsplit : Ex P w (fun x => (t.queries x : ℝ) / n +
      (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2) =
      Ex P w (fun x => (t.queries x : ℝ)) / n +
        Ex P w (fun x => if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    rw [Ex_add]
    unfold Ex pexp
    congr 1
    · rw [Finset.sum_div]
      refine Finset.sum_congr rfl fun θ _ => ?_
      rw [mul_div_assoc, Finset.sum_div]
      congr 1
      exact Finset.sum_congr rfl fun x _ => by ring
    · rw [Finset.sum_div]
      refine Finset.sum_congr rfl fun θ _ => ?_
      rw [mul_div_assoc, Finset.sum_div]
      congr 1
      exact Finset.sum_congr rfl fun x _ => by ring
  rw [hsplit] at hmono
  have hPot : PotW P ga gb ∅ w f ≤ K / ga + mutInfo P w / gb := by
    unfold PotW
    have hPhi : Phi P w f ≤ K := by
      unfold Phi
      obtain ⟨a, hr, hKa⟩ := hasRows_of_degree f d hf01 hdeg
      calc ∑ θ, w θ * Ltot (P θ) f ≤ ∑ θ, w θ * K :=
            Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left
              (sum_pincr_le (P θ) (hP0 θ) (hP1 θ) f a hr K hKa) (hw0 θ)
        _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
    have h1 : Phi P w f / ga ≤ K / ga := div_le_div_of_nonneg_right hPhi hga.le
    have h2 : Info P ∅ w / gb ≤ mutInfo P w / gb := by rw [info_empty]
    linarith
  have hfinal : Ex P w (fun x => (t.queries x : ℝ)) / n ≤
      (K / ga + mutInfo P w / gb) / n :=
    div_le_div_of_nonneg_right (hq.trans hPot) hn'.le
  have herr' : Ex P w (fun x => if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 ≤ τ / ε ^ 2 :=
    div_le_div_of_nonneg_right herr hε2.le
  have hresult : Ex P w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (K / ga + mutInfo P w / gb) / n + τ / ε ^ 2 := by
    linarith
  simpa only [hKdef] using hresult

#print axioms Nightfall.Route1Polylog.route1_wyner_from_verified_good
end Nightfall.Route1Polylog
