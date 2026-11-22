import Route1LatentDegree

/-!
# Coordinate grouping preserves finite indicator interaction degree

Given a finite function f on original coordinates I and a map parent:I→B,
each original coordinate i is a deterministic function φᵢ of just the
underlying block x(parent i). If f has interaction degree≤d on I, its
pullback to B has interaction degree≤d. The supports S of f's exact
junta expansion become S.image parent, which cannot increase cardinality.

This is a general source-to-representation transfer, not a phase-specific
constant. It is the missing connection between the existing
QuantumCircuitSimulation.acceptance_degree on raw original sensor addresses
and the hidden-block Route1 degree.
-/

namespace Nightfall.PhaseBlockGrouping

open Finset
open Nightfall.Route1LatentDegree

variable {I B A C : Type*}
  [Fintype I] [DecidableEq I]
  [Fintype B] [DecidableEq B]
  [Fintype A] [DecidableEq A] [Nonempty A]
  [Fintype C] [DecidableEq C] [Nonempty C]

def groupedInput (parent : I → B) (φ : I → A → C)
    (x : B → A) : I → C :=
  fun i => φ i (x (parent i))

/-- An observable depending on S original coordinates becomes an
observable depending on at most |S| parent blocks. -/
theorem grouped_supported (parent : I → B) (φ : I → A → C)
    (S : Finset I) (g : (I → C) → ℝ)
    (hg : SupportedOn S g) :
    SupportedOn (S.image parent)
      (fun x : B → A => g (groupedInput parent φ x)) := by
  intro x y hxy
  apply hg
  intro i hi
  change φ i (x (parent i)) = φ i (y (parent i))
  rw [hxy (parent i) (Finset.mem_image.mpr ⟨i, hi, rfl⟩)]

/-- **Source-preserving degree pullback.** The output degree is measured in
actual hidden block variables, not in the original 4B sensor coordinates.
The source's finite indicator-degree witness is fully reconstructed; no
degree assumption on the grouped function is smuggled in. -/
theorem grouped_degree
    (f : (I → C) → ℝ) (d : ℕ)
    (hf : DegreeLE f d)
    (parent : I → B) (φ : I → A → C) :
    DegreeLE (fun x : B → A => f (groupedInput parent φ x)) d := by
  classical
  obtain ⟨a,ha0,ha⟩ := hf
  have hexp :
      (fun x : B → A => f (groupedInput parent φ x)) =
      (fun x : B → A =>
        ∑ S : Finset I, ∑ τ : I → C,
          a S τ * indMono S τ (groupedInput parent φ x)) := by
    funext x
    exact ha _
  rw [hexp]
  apply degree_sum
    (g := fun S : Finset I =>
      fun x : B → A => ∑ τ : I → C,
        a S τ * indMono S τ (groupedInput parent φ x))
    (d := d)
  intro S
  apply degree_sum
    (g := fun τ : I → C =>
      fun x : B → A =>
        a S τ * indMono S τ (groupedInput parent φ x))
    (d := d)
  intro τ
  by_cases hs : S.card ≤ d
  · have hlocal : SupportedOn S (fun z : I → C => a S τ * indMono S τ z) := by
      intro x y hxy
      change a S τ * indMono S τ x = a S τ * indMono S τ y
      have hmono : indMono S τ x = indMono S τ y := by
        unfold indMono
        apply Finset.prod_congr rfl
        intro i hi
        rw [hxy i hi]
      rw [hmono]
    apply degree_of_supported
      (S.image parent)
      (fun x : B → A => a S τ * indMono S τ (groupedInput parent φ x))
      (grouped_supported parent φ S _ hlocal) d
      ((Finset.card_image_le).trans hs)
  · have haZ : a S τ = 0 := ha0 S (by omega) τ
    simpa [haZ] using
      (degree_zero (ι := B) (α := A) d)

#print axioms Nightfall.PhaseBlockGrouping.grouped_supported
#print axioms Nightfall.PhaseBlockGrouping.grouped_degree
#print Nightfall.PhaseBlockGrouping.grouped_degree

end Nightfall.PhaseBlockGrouping
