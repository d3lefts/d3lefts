import AdaptiveInstrumentDegree
import EfronSteinDegree
import Route1WynerGeneral

/-! Link the actual adaptive linear program semantics to the repository's
general-latent Wyner theorem. The local state-cone contract remains explicit. -/

namespace Nightfall.AdaptiveInstrument

open Finset
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Simulation
open Nightfall.Route1Polylog

variable {ι α κ β : Type}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
  [Fintype κ] [Fintype β]

/-- Indicator expansion of a supported atom. This proof follows the existing
QuantumPathDegree.degree_of_junta construction and junta_expand. -/
private theorem atom_indicator (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (S : Finset ι) (d : ℕ) (hc : S.card ≤ d)
    (g : (ι → α) → ℝ) (hg : Depends S g) :
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

theorem degree_to_indicator (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    {d : ℕ} {f : (ι → α) → ℝ} (hf : Degree d f) :
    HasProdDegreeLE f d := by
  classical
  induction hf with
  | atom S g hc hg => exact atom_indicator p hp1 S d hc g hg
  | @add f g hf hg ihf ihg =>
      obtain ⟨a, ha0, ha⟩ := ihf
      obtain ⟨b, hb0, hb⟩ := ihg
      refine ⟨fun T τ => a T τ + b T τ, ?_, ?_⟩
      · intro T hT τ
        simp [ha0 T hT τ, hb0 T hT τ]
      · intro x
        change f x + g x =
          ∑ T : Finset ι, ∑ τ : ι → α, (a T τ + b T τ) * indMono T τ x
        simp only [add_mul, Finset.sum_add_distrib]
        rw [← ha x, ← hb x]

noncomputable def reference (_i : ι) (a : α) : ℝ :=
  if a = Classical.arbitrary α then 1 else 0

theorem reference_sum (i : ι) : ∑ a : α, reference i a = 1 := by
  classical
  simp [reference]

theorem adaptive_indicator_degree {T : ℕ} (P : Program ι α κ β T) (r : κ → ℝ) :
    HasProdDegreeLE (fun x => eval P x r) (2 * T) := by
  exact degree_to_indicator reference reference_sum (adaptive_degree P r)

/-- General-latent Route 1 on the evaluated adaptive program. All terminal
degree and range obligations are derived from syntax and local conservation. -/
theorem adaptive_route1_wyner
    (ν : (ι → α) → ℝ) (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (T : ℕ) (hT : 1 ≤ T) (P : Program ι α κ β T)
    (G : (κ → ℝ) → Prop) (mass : (κ → ℝ) → ℝ)
    (hvalid : Valid G mass P) (r : κ → ℝ) (hr : G r) (hnorm : mass r = 1)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε) (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |eval P x r - t.eval x| then (1 : ℝ) else 0) ≤
      ((Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) / (2 * gam (2 * T) τ) +
        s / (etaC (2 * T) τ ^ 2 *
          w0C (Real.pi ^ 2 * ((2 * T : ℕ) : ℝ) ^ 2 / 2) (2 * T) τ)) / n + τ / ε ^ 2 := by
  exact route1_wyner_general ν hν0 hν1 (fun x => eval P x r)
    (adaptive_range G mass P hvalid r hr hnorm) (2 * T) (by omega)
    (adaptive_indicator_degree P r) τ hτ hτ1 ε hε n hn s hs

end Nightfall.AdaptiveInstrument

#print axioms Nightfall.AdaptiveInstrument.degree_to_indicator
#print axioms Nightfall.AdaptiveInstrument.adaptive_indicator_degree
#print axioms Nightfall.AdaptiveInstrument.adaptive_route1_wyner
