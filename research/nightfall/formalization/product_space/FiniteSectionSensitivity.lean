import Mathlib
import FiniteSwitchingCore

/-!
NIGHTFALL exact recovery: finite sectioning and strictly-positive atomic resampling.

These statements are purely finite. Sectioning an explicit low-coordinate-support
representation preserves that degree; if a finite positive-atom section is
nonconstant, then every base-point value differs on positive resampling mass.

NOT FORMALIZED HERE: conditional expectation, Hoeffding projections, maximal
nonzero interaction, L2 limits, Fubini, completed or infinite products.
-/

namespace Nightfall.Recovery

open Finset

variable {Coord Symbol Label : Type*}

/-- Fix coordinates A according to a; leave all other coordinates from x. -/
def overwrite [DecidableEq Coord] (A : Finset Coord)
    (a x : Coord → Symbol) : Coord → Symbol :=
  fun i => if i ∈ A then a i else x i

theorem overwrite_agree_on [DecidableEq Coord]
    (T A : Finset Coord) (a x y : Coord → Symbol)
    (hxy : ∀ i ∈ T \ A, x i = y i) :
    ∀ i ∈ T, overwrite A a x i = overwrite A a y i := by
  intro i hi
  by_cases hia : i ∈ A
  · simp [overwrite, hia]
  · have hit : i ∈ T \ A := Finset.mem_sdiff.mpr ⟨hi, hia⟩
    simp [overwrite, hia, hxy i hit]

/-- A cylinder term supported on T becomes supported on T minus fixed A. -/
theorem section_term_depends [DecidableEq Coord]
    (T A : Finset Coord) (g : (Coord → Symbol) → ℝ)
    (hg : DependsOn T g) (a : Coord → Symbol) :
    DependsOn (T \ A) (fun x => g (overwrite A a x)) := by
  intro x y hxy
  apply hg
  exact overwrite_agree_on T A a x y hxy

/-- Explicit finite degree ≤d representations survive arbitrary prefix sections. -/
theorem section_preserves_degree [Fintype Label] [DecidableEq Coord]
    (f : (Coord → Symbol) → ℝ) (d : ℕ)
    (hdeg : HasDegreeRepresentation (Label := Label) f d)
    (A : Finset Coord) (a : Coord → Symbol) :
    HasDegreeRepresentation (Label := Label)
      (fun x => f (overwrite A a x)) d := by
  rcases hdeg with ⟨support, piece, hp, hsum⟩
  refine ⟨(fun l => support l \ A),
    (fun l x => piece l (overwrite A a x)), ?_, ?_⟩
  · intro l
    obtain ⟨hcard, hdep⟩ := hp l
    constructor
    · exact (Finset.card_le_card (Finset.sdiff_subset)).trans hcard
    · exact section_term_depends (support l) A (piece l) hdep a
  · intro x
    exact hsum (overwrite A a x)

/-- Strictly positive joint product mass of an individual finite atom. -/
def atomMass [Fintype Coord] (p : Coord → Symbol → ℝ)
    (u : Coord → Symbol) : ℝ :=
  ∏ i, p i (u i)

theorem atomMass_pos [Fintype Coord]
    (p : Coord → Symbol → ℝ)
    (hp : ∀ i t, 0 < p i t) (u : Coord → Symbol) :
    0 < atomMass p u := by
  unfold atomMass
  exact Finset.prod_pos (fun i _ => hp i (u i))

/-- Nonconstant finite section has a positive-probability witness of change. 
The full-product atom sum is sufficient; the normalized block-resampling
probability follows by independent product masses. -/
theorem positive_resampling_of_nonconstant
    [Fintype Coord] [Fintype Symbol] [DecidableEq Coord]
    (p : Coord → Symbol → ℝ) (hp : ∀ i t, 0 < p i t)
    (f : (Coord → Symbol) → ℝ) (S : Finset Coord)
    (x : Coord → Symbol)
    (hnonconst : ∃ u v : Coord → Symbol,
      f (overwrite S u x) ≠ f (overwrite S v x)) :
    0 < ∑ u : Coord → Symbol,
      if f (overwrite S u x) ≠ f x then atomMass p u else 0 := by
  classical
  obtain ⟨u, v, huv⟩ := hnonconst
  have hd : f (overwrite S u x) ≠ f x ∨
      f (overwrite S v x) ≠ f x := by
    by_contra h
    push_neg at h
    exact huv (h.1.trans h.2.symm)
  have hnonneg : ∀ t : Coord → Symbol,
      0 ≤ (if f (overwrite S t x) ≠ f x then atomMass p t else 0) := by
    intro t
    split_ifs
    · exact (atomMass_pos p hp t).le
    · exact le_refl _
  rcases hd with hu | hv
  · apply Finset.sum_pos' (fun t _ => hnonneg t)
    exact ⟨u, Finset.mem_univ _, by simp [hu, atomMass_pos p hp u]⟩
  · apply Finset.sum_pos' (fun t _ => hnonneg t)
    exact ⟨v, Finset.mem_univ _, by simp [hv, atomMass_pos p hp v]⟩

end Nightfall.Recovery
