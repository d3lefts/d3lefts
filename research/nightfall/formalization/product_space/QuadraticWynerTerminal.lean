import QuadraticWynerGoodQuery
import QuadraticWynerParametric
import Route1WynerGeneral

/-!
# Quadratic Wyner Simulation Theorem — named source-quantified terminal attempt

A true end-to-end candidate: ORIGINAL mixture posterior crux from the actual
finite star κ (QuadraticWynerGoodQuery), certified Q2 on the *latent
averaged seed function*, actual component Jensen and Key Lemma, then
compiled original-coordinate Wyner tree and general finite-to-Borel
Wyner common information. NO unexplained GoodW premise in this terminal.

This source has NOT passed its exact-head Lean/leanchecker gate; treat as
a provisional proof attempt, not a completed certificate. Once compiled,
the real theorem statement, closure, axes, and source hash must be audited.
-/
namespace Nightfall.Route1Polylog

open Finset
open Nightfall.QuadraticWynerGoodQuery
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

/-- Degree-two seed row cost: K₂=π²·2²/2=2π². -/
noncomputable def quadraticSeedK : ℝ := Real.pi ^ 2 * (2 : ℝ) ^ 2 / 2

theorem quadraticSeedK_pos : 0 < quadraticSeedK := by
  unfold quadraticSeedK
  positivity

/-- Full concrete mixture simulator. No latent oracle query and no
externally supplied posterior GoodW assumption. -/
theorem quadratic_wyner_simulation
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ)
    (hw1 : ∑ θ, w θ = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1 / 4)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Ex P w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        (quadraticSeedK / quadGa τ +
            mutInfo P w / quadGb quadraticSeedK τ) / n +
          τ / ε ^ 2 := by
  have hK : 0 < quadraticSeedK := quadraticSeedK_pos
  have hga : 0 < quadGa τ := quadGa_pos τ hτ
  have hgb : 0 < quadGb quadraticSeedK τ :=
    quadGb_pos quadraticSeedK τ hK hτ
  have hgood : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ),
      StD f (Real.pi ^ 2 * (2 : ℝ) ^ 2 / 2) 2 A v g →
      τ * Vs v < mvar P v g →
      ∃ j, j ∉ A ∧ GoodW P (quadGa τ) (quadGb quadraticSeedK τ) A v g j := by
    intro A v g hS hvar
    exact good_exists_wyner_quadratic P hP0 hP1 f quadraticSeedK
      hK τ hτ hτmax A v g hS hvar
  have h := route1_wyner_from_verified_good
    P hP0 hP1 w hw0 hw1 f hf01 2 hdeg τ hτ ε hε n hn
    (quadGa τ) (quadGb quadraticSeedK τ) hga hgb hgood
  simpa only [quadraticSeedK] using h

/-- Source-quantified Wyner-CI variant with a finite product decomposition
chosen below any strict information charge s>C_W(ν). -/
theorem quadratic_wyner_CI
    (ν : (ι → α) → ℝ) (hne : (wynerSet ν).Nonempty)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1 / 4)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerCI ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x *
        (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (quadraticSeedK / quadGa τ + s / quadGb quadraticSeedK τ) / n +
        τ / ε ^ 2 := by
  obtain ⟨s0, ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩, hlt⟩ :=
    exists_lt_of_csInf_lt hne hs
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0
      simp at hw1
    · exact h
  haveI : Nonempty (Fin k) := ⟨⟨0, hk⟩⟩
  obtain ⟨t, htq, hb⟩ :=
    quadratic_wyner_simulation Q hQ0 hQ1 w hw0 hw1
      f hf01 hdeg τ hτ hτmax ε hε n hn
  refine ⟨t, htq, ?_⟩
  have hEx :
      Ex Q w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) =
        ∑ x, ν x *
          (if ε < |f x - t.eval x| then (1 : ℝ) else 0) := by
    unfold Ex pexp
    simp only [hν, Finset.mul_sum, Finset.sum_mul]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ =>
      Finset.sum_congr rfl fun θ _ => by ring
  rw [← hEx]
  refine hb.trans ?_
  have hgb : 0 < quadGb quadraticSeedK τ :=
    quadGb_pos quadraticSeedK τ quadraticSeedK_pos hτ
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  gcongr

/-- General-latent unconditional finite-alphabet QW+ statement, not yet
promoted: the kernel must validate every imported source before certification. -/
theorem quadratic_wyner_general
    (ν : (ι → α) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ ≤ 1 / 4)
    (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n)
    (s : ℝ) (hs : wynerGen ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x *
        (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (quadraticSeedK / quadGa τ + s / quadGb quadraticSeedK τ) / n +
        τ / ε ^ 2 := by
  rw [← wynerCI_eq_wynerGen] at hs
  exact quadratic_wyner_CI ν (wynerSet_nonempty ν hν0 hν1)
    f hf01 hdeg τ hτ hτmax ε hε n hn s hs

#print axioms Nightfall.Route1Polylog.quadratic_wyner_simulation
#print axioms Nightfall.Route1Polylog.quadratic_wyner_CI
#print axioms Nightfall.Route1Polylog.quadratic_wyner_general
end Nightfall.Route1Polylog
