import Route1PolylogTools

/-!
# Block-local quantum path sums have Route1 interaction degree at most 2T

A finite T-query matrix circuit expands into a finite sum over computational
paths. Each oracle transition on a path touches exactly one hidden block.
This file kernel-proves, from the explicit path coefficients, that the
quadratic complex acceptance functional has interaction degree ≤2T in the
EXISTING NIGHTFALL Route1 `HasProdDegreeLE` definition.

The separate theorem that any specified block-local oracle circuit gives
these path coefficients, and the norm/effect assumption 0≤f≤1, are not
proved in this file. No quantum conclusion is inferred from arbitrary
nonlocal oracle matrices.
-/

namespace Nightfall.PhaseBlockQuantumDegree

open Finset
open Nightfall.Route1Polylog
open Nightfall.Route1LatentDegree

variable {B P : Type*} [Fintype B] [DecidableEq B]
variable [Fintype P] [DecidableEq P]

/-- Hidden-block addresses touched along one computational path. -/
def touched (T : ℕ) (site : P → Fin T → B) (p : P) : Finset B :=
  Finset.univ.image (site p)

theorem touched_card_le (T : ℕ) (site : P → Fin T → B) (p : P) :
    (touched T site p).card ≤ T := by
  unfold touched
  calc
    (Finset.univ.image (site p)).card ≤ (Finset.univ : Finset (Fin T)).card :=
      Finset.card_image_le
    _ = T := by simp

/-- Arbitrary (possibly complex) path amplitude: a fixed scalar times T
one-block input-dependent transition factors. -/
def pathAmp (T : ℕ) (site : P → Fin T → B)
    (coeff : P → ℂ) (kernel : P → Fin T → Fin 8 → ℂ)
    (p : P) (x : B → Fin 8) : ℂ :=
  coeff p * ∏ j : Fin T, kernel p j (x (site p j))

theorem pathAmp_local (T : ℕ) (site : P → Fin T → B)
    (coeff : P → ℂ) (kernel : P → Fin T → Fin 8 → ℂ)
    (p : P) (x y : B → Fin 8)
    (hxy : ∀ b ∈ touched T site p, x b = y b) :
    pathAmp T site coeff kernel p x = pathAmp T site coeff kernel p y := by
  have hp :
      (∏ j : Fin T, kernel p j (x (site p j))) =
        ∏ j : Fin T, kernel p j (y (site p j)) := by
    apply Finset.prod_congr rfl
    intro j _
    have hj : x (site p j) = y (site p j) :=
      hxy (site p j) (by simp [touched])
    rw [hj]
  unfold pathAmp
  rw [hp]

/-- One quadratic contribution to a fixed input-independent terminal
Hermitian-effect expectation. Complex conjugation is degree-preserving. -/
def effectTerm (T : ℕ) (site : P → Fin T → B)
    (coeff : P → ℂ) (kernel : P → Fin T → Fin 8 → ℂ)
    (E : P → P → ℂ) (p q : P) (x : B → Fin 8) : ℝ :=
  Complex.re
    (star (pathAmp T site coeff kernel p x) *
      E p q * pathAmp T site coeff kernel q x)

/-- Full scalar acceptance path sum. Physical positivity and ≤1 are
SEPARATE hypotheses supplied by the genuine quantum circuit. -/
def effectValue (T : ℕ) (site : P → Fin T → B)
    (coeff : P → ℂ) (kernel : P → Fin T → Fin 8 → ℂ)
    (E : P → P → ℂ) (x : B → Fin 8) : ℝ :=
  ∑ pq : P × P, effectTerm T site coeff kernel E pq.1 pq.2 x

theorem effectTerm_supported (T : ℕ) (site : P → Fin T → B)
    (coeff : P → ℂ) (kernel : P → Fin T → Fin 8 → ℂ)
    (E : P → P → ℂ) (p q : P) :
    SupportedOn (touched T site p ∪ touched T site q)
      (effectTerm T site coeff kernel E p q) := by
  intro x y hxy
  have hp := pathAmp_local T site coeff kernel p x y
    (fun b hb => hxy b (Finset.mem_union.mpr (Or.inl hb)))
  have hq := pathAmp_local T site coeff kernel q x y
    (fun b hb => hxy b (Finset.mem_union.mpr (Or.inr hb)))
  unfold effectTerm
  rw [hp, hq]

/-- **Quantum-polynomial-to-Route1 bridge.**
Every finite T-query block-local path expansion has scalar acceptance
interaction degree ≤2T, even with coherent interference across different
paths and a completely general fixed complex terminal effect.

This is not predicated on a fake `HasProdDegreeLE` hypothesis; it is derived
from exact single-block factors in the path expansion. -/
theorem effectValue_degree (T : ℕ) (site : P → Fin T → B)
    (coeff : P → ℂ) (kernel : P → Fin T → Fin 8 → ℂ)
    (E : P → P → ℂ) :
    HasProdDegreeLE (effectValue T site coeff kernel E) (2 * T) := by
  classical
  unfold effectValue
  apply deg_of_terms
    (γ := P × P)
    (F := fun pq x => effectTerm T site coeff kernel E pq.1 pq.2 x)
    (S := fun pq => touched T site pq.1 ∪ touched T site pq.2)
    (d := 2 * T)
  · intro pq
    left
    calc
      (touched T site pq.1 ∪ touched T site pq.2).card ≤
        (touched T site pq.1).card +
          (touched T site pq.2).card := Finset.card_union_le _ _
      _ ≤ T + T := Nat.add_le_add
        (touched_card_le T site pq.1) (touched_card_le T site pq.2)
      _ = 2 * T := by omega
  · intro pq
    exact effectTerm_supported T site coeff kernel E pq.1 pq.2

#print axioms Nightfall.PhaseBlockQuantumDegree.touched_card_le
#print axioms Nightfall.PhaseBlockQuantumDegree.pathAmp_local
#print axioms Nightfall.PhaseBlockQuantumDegree.effectTerm_supported
#print axioms Nightfall.PhaseBlockQuantumDegree.effectValue_degree
#print Nightfall.PhaseBlockQuantumDegree.effectValue_degree

end Nightfall.PhaseBlockQuantumDegree
