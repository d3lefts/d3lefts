import Mathlib
import ProductSphereObstruction
import ProductBUSphereExtension
import ProductBUOrbitCertificate

/-!
# Compactness of the *exact* product-sphere topology domain

Certified geometric prerequisite for obtaining a positive uniform lower
bound from a continuous nowhere-zero separately equivariant block map.

This module does not assert any zero of a continuous equivariant map and
does not import a topological ProductSphereZero proof.
-/

namespace Nightfall.ProductBUSphereCompact

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSphereExtension
open Nightfall.ProductBUOrbit

abbrev V (n : ℕ) := Fin n → ℝ

theorem unitVec_coordinate_abs_le_one (n : ℕ)
    (u : V n) (hu : UnitVec n u) (i : Fin n) :
    |u i| ≤ 1 := by
  have hs : (u i)^2 ≤ ∑ j : Fin n, (u j)^2 := by
    exact Finset.single_le_sum (fun j _ => sq_nonneg (u j)) (Finset.mem_univ i)
  have hunit : (∑ j : Fin n, (u j)^2) = 1 := hu
  have : (u i)^2 ≤ 1 := hs.trans_eq hunit
  exact (sq_le_one_iff_abs_le_one (u i)).mp this

theorem unitVec_coordinate_mem_Icc (n : ℕ)
    (u : V n) (hu : UnitVec n u) (i : Fin n) :
    u i ∈ Set.Icc (-1 : ℝ) 1 := by
  exact abs_le.mp (unitVec_coordinate_abs_le_one n u hu i)

/-- A fixed compact cube contains every exact unit sphere. -/
theorem unitSphere_isCompact (n : ℕ) :
    IsCompact {u : V n | UnitVec n u} := by
  let C : Set (V n) :=
    {u | ∀ i : Fin n, u i ∈ Set.Icc (-1 : ℝ) 1}
  have hC : IsCompact C := by
    simpa [C] using
      (isCompact_pi_infinite
        (s := fun _ : Fin n => Set.Icc (-1 : ℝ) 1)
        (fun _ => isCompact_Icc))
  have hclosed : IsClosed {u : V n | UnitVec n u} := by
    have hsum : Continuous (fun u : V n => ∑ i : Fin n, u i ^ 2) := by
      fun_prop
    simpa [UnitVec] using
      (isClosed_eq hsum
        (continuous_const : Continuous (fun _ : V n => (1 : ℝ))))
  apply IsCompact.of_isClosed_subset hC hclosed
  intro u hu
  change ∀ i : Fin n, u i ∈ Set.Icc (-1 : ℝ) 1
  exact fun i => unitVec_coordinate_mem_Icc n u hu i

/-- Compactness of the precise SpherePair domain in ProductSphereZero. -/
theorem spherePair_isCompact (n : ℕ) :
    IsCompact (SpherePair n) := by
  have h : IsCompact
      ({u : V n | UnitVec n u} ×ˢ {v : V n | UnitVec n v}) :=
    (unitSphere_isCompact n).prod (unitSphere_isCompact n)
  have heq :
      (({u : V n | UnitVec n u} ×ˢ {v : V n | UnitVec n v}) :
        Set (V n × V n)) = SpherePair n := by
    ext p
    simp only [Set.mem_prod, Set.mem_setOf_eq, SpherePair]
  rw [heq] at h
  exact h

/-- For n=k+1 the product sphere is genuinely nonempty. -/
theorem spherePair_nonempty (k : ℕ) :
    (SpherePair (k + 1)).Nonempty := by
  refine ⟨(axis k, axis k), ?_⟩
  exact ⟨axis_unit k, axis_unit k⟩


/-- Any continuous scalar function that is pointwise strictly positive
on a nonempty compact product sphere admits a *uniform* positive gap.
This theorem is independent of the definition of the response blocks. -/
theorem positive_uniform_gap (k : ℕ)
    (f : (V (k + 1) × V (k + 1)) → ℝ)
    (hf : ContinuousOn f (SpherePair (k + 1)))
    (hpos : ∀ p ∈ SpherePair (k + 1), 0 < f p) :
    ∃ δ : ℝ, 0 < δ ∧
      ∀ p ∈ SpherePair (k + 1), δ ≤ f p := by
  obtain ⟨p,hp,hmin⟩ :=
    (spherePair_isCompact (k + 1)).exists_isMinOn
      (spherePair_nonempty k) hf
  exact ⟨f p, hpos p hp, fun q hq => hmin hq⟩

/-- Energy of both finite pure-character blocks, without taking
square roots or imposing any extended-domain continuity. -/
def pureEnergy (n k : ℕ)
    (fU fV : V n → V n → Fin k → ℝ)
    (p : V n × V n) : ℝ :=
  (∑ i : Fin k, (fU p.1 p.2 i)^2) +
  (∑ i : Fin k, (fV p.1 p.2 i)^2)

theorem pureEnergy_nonneg (n k : ℕ)
    (fU fV : V n → V n → Fin k → ℝ)
    (p : V n × V n) :
    0 ≤ pureEnergy n k fU fV p := by
  unfold pureEnergy
  exact add_nonneg
    (Finset.sum_nonneg fun i _ => sq_nonneg _)
    (Finset.sum_nonneg fun i _ => sq_nonneg _)

/-- The energy vanishes exactly when every output of both blocks
vanishes, including degenerate rank k=0. -/
theorem pureEnergy_eq_zero_iff (n k : ℕ)
    (fU fV : V n → V n → Fin k → ℝ)
    (p : V n × V n) :
    pureEnergy n k fU fV p = 0 ↔
      (∀ i : Fin k, fU p.1 p.2 i = 0) ∧
      (∀ i : Fin k, fV p.1 p.2 i = 0) := by
  constructor
  · intro h
    have hU0 : (∑ i : Fin k, (fU p.1 p.2 i)^2) = 0 := by
      unfold pureEnergy at h
      have ha : 0 ≤ ∑ i : Fin k, (fU p.1 p.2 i)^2 :=
        Finset.sum_nonneg (fun i _ => sq_nonneg _)
      have hb : 0 ≤ ∑ i : Fin k, (fV p.1 p.2 i)^2 :=
        Finset.sum_nonneg (fun i _ => sq_nonneg _)
      linarith
    have hV0 : (∑ i : Fin k, (fV p.1 p.2 i)^2) = 0 := by
      unfold pureEnergy at h
      have ha : 0 ≤ ∑ i : Fin k, (fU p.1 p.2 i)^2 :=
        Finset.sum_nonneg (fun i _ => sq_nonneg _)
      have hb : 0 ≤ ∑ i : Fin k, (fV p.1 p.2 i)^2 :=
        Finset.sum_nonneg (fun i _ => sq_nonneg _)
      linarith
    constructor
    · intro i
      have hi : (fU p.1 p.2 i)^2 ≤
          ∑ j : Fin k, (fU p.1 p.2 j)^2 :=
        Finset.single_le_sum (fun j _ => sq_nonneg _) (Finset.mem_univ i)
      rw [hU0] at hi
      nlinarith [sq_nonneg (fU p.1 p.2 i)]
    · intro i
      have hi : (fV p.1 p.2 i)^2 ≤
          ∑ j : Fin k, (fV p.1 p.2 j)^2 :=
        Finset.single_le_sum (fun j _ => sq_nonneg _) (Finset.mem_univ i)
      rw [hV0] at hi
      nlinarith [sq_nonneg (fV p.1 p.2 i)]
  · rintro ⟨hU,hV⟩
    simp [pureEnergy, hU, hV]

/-- Continuity of finite squared energies assuming only continuity
on the *actual product-sphere domain*. -/
theorem continuousOn_pureEnergy (n k : ℕ)
    (fU fV : V n → V n → Fin k → ℝ)
    (hcU : ∀ i : Fin k, ContinuousOn
      (fun p : V n × V n => fU p.1 p.2 i) (SpherePair n))
    (hcV : ∀ i : Fin k, ContinuousOn
      (fun p : V n × V n => fV p.1 p.2 i) (SpherePair n)) :
    ContinuousOn (pureEnergy n k fU fV) (SpherePair n) := by
  classical
  have hU (s : Finset (Fin k)) :
      ContinuousOn (fun p : V n × V n =>
        ∑ i ∈ s, (fU p.1 p.2 i)^2) (SpherePair n) := by
    induction s using Finset.induction_on with
    | empty =>
      simpa using
        (continuousOn_const : ContinuousOn
          (fun _ : V n × V n => (0 : ℝ)) (SpherePair n))
    | @insert i s hi ih =>
      have h := (hcU i).pow 2 |>.add ih
      simpa only [Finset.sum_insert hi, Pi.add_apply, Pi.pow_apply] using h
  have hV (s : Finset (Fin k)) :
      ContinuousOn (fun p : V n × V n =>
        ∑ i ∈ s, (fV p.1 p.2 i)^2) (SpherePair n) := by
    induction s using Finset.induction_on with
    | empty =>
      simpa using
        (continuousOn_const : ContinuousOn
          (fun _ : V n × V n => (0 : ℝ)) (SpherePair n))
    | @insert i s hi ih =>
      have h := (hcV i).pow 2 |>.add ih
      simpa only [Finset.sum_insert hi, Pi.add_apply, Pi.pow_apply] using h
  exact (hU Finset.univ).add (hV Finset.univ)

/-- Under a hypothetical absence of common zeros, finite energy
has a uniform positive lower bound on the ORIGINAL compact domain.
No topology theorem is assumed; this is a conditional contradiction
ingredient for the smooth-approximation route. -/
theorem exists_positive_energy_gap (n k : ℕ) (hn : 1 ≤ n)
    (fU fV : V n → V n → Fin k → ℝ)
    (hcU : ∀ i : Fin k, ContinuousOn
      (fun p : V n × V n => fU p.1 p.2 i) (SpherePair n))
    (hcV : ∀ i : Fin k, ContinuousOn
      (fun p : V n × V n => fV p.1 p.2 i) (SpherePair n))
    (hnozero : ∀ p ∈ SpherePair n,
      ¬ ((∀ i : Fin k, fU p.1 p.2 i = 0) ∧
         (∀ i : Fin k, fV p.1 p.2 i = 0))) :
    ∃ δ : ℝ, 0 < δ ∧
      ∀ p ∈ SpherePair n, δ ≤ pureEnergy n k fU fV p := by
  have hcont := continuousOn_pureEnergy n k fU fV hcU hcV
  have hpos : ∀ p ∈ SpherePair n, 0 < pureEnergy n k fU fV p := by
    intro p hp
    have hz := pureEnergy_nonneg n k fU fV p
    rcases hz.eq_or_lt with h | h
    · exact False.elim ((hnozero p hp) ((pureEnergy_eq_zero_iff n k fU fV p).mp h.symm))
    · exact h
  obtain ⟨m,hm⟩ : ∃ m : ℕ, n = m + 1 := ⟨n - 1, by omega⟩
  subst n
  exact positive_uniform_gap m (pureEnergy (m + 1) k fU fV) hcont hpos

#print axioms positive_uniform_gap
#print axioms pureEnergy_nonneg
#print axioms pureEnergy_eq_zero_iff
#print axioms continuousOn_pureEnergy
#print axioms exists_positive_energy_gap
#print axioms unitVec_coordinate_abs_le_one
#print axioms unitVec_coordinate_mem_Icc
#print axioms unitSphere_isCompact
#print axioms spherePair_isCompact
#print axioms spherePair_nonempty

end Nightfall.ProductBUSphereCompact
