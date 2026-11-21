import SubcubeAllLevels

set_option maxRecDepth 12000
set_option maxHeartbeats 3000000

namespace Nightfall.StructuralInformation.SubcubeSecantSlices

open Nightfall.StructuralInformation.SubcubeAllSpacesL3

variable {V : Type*} [AddCommGroup V] [Module K V] [DecidableEq V]

def pairSums (R : Finset V) : Finset V :=
  (R.product R).image (fun p => p.1 + p.2)

def mixedAC (R : Finset V) : Finset (V × V) :=
  (R.product R).image (fun p => (p.1 + p.2, p.2))

def mixedBC (R : Finset V) : Finset (V × V) :=
  (R.product R).image (fun p => (p.2, p.1 + p.2))

def sixSlices (R : Finset V) : Finset (V × V) :=
  rowsUp (pairSums R) ∪ ((R.product R) ∪ (mixedAC R ∪ mixedBC R))

private theorem row_cases (R : Finset V) {p : V × V} (hp : p ∈ rowsUp R) :
    (∃ r ∈ R, p = (r, 0)) ∨
    (∃ r ∈ R, p = (0, r)) ∨
    (∃ r ∈ R, p = (r, r)) := by
  change p ∈ (R.image inl ∪ R.image inr) ∪ R.image diag at hp
  rcases Finset.mem_union.mp hp with h | h
  · rcases Finset.mem_union.mp h with h | h
    · obtain ⟨r, hr, he⟩ := Finset.mem_image.mp h
      exact Or.inl ⟨r, hr, by simpa [inl] using he.symm⟩
    · obtain ⟨r, hr, he⟩ := Finset.mem_image.mp h
      exact Or.inr (Or.inl ⟨r, hr, by simpa [inr] using he.symm⟩)
  · obtain ⟨r, hr, he⟩ := Finset.mem_image.mp h
    exact Or.inr (Or.inr ⟨r, hr, by simpa [diag, inl, inr] using he.symm⟩)

private theorem pair_mem (R : Finset V) {r s : V} (hr : r ∈ R) (hs : s ∈ R) :
    r + s ∈ pairSums R := by
  apply Finset.mem_image.mpr
  exact ⟨(r, s), Finset.mem_product.mpr ⟨hr, hs⟩, rfl⟩

private theorem pureA (R : Finset V) {z : V} (hz : z ∈ pairSums R) :
    (z, 0) ∈ sixSlices R := by
  apply Finset.mem_union.mpr
  left
  change (z, 0) ∈ (pairSums R).image inl ∪ (pairSums R).image inr ∪
    (pairSums R).image diag
  apply Finset.mem_union.mpr
  left
  apply Finset.mem_union.mpr
  left
  exact Finset.mem_image.mpr ⟨z, hz, by simp [inl]⟩

private theorem pureB (R : Finset V) {z : V} (hz : z ∈ pairSums R) :
    (0, z) ∈ sixSlices R := by
  apply Finset.mem_union.mpr
  left
  change (0, z) ∈ (pairSums R).image inl ∪ (pairSums R).image inr ∪
    (pairSums R).image diag
  apply Finset.mem_union.mpr
  left
  apply Finset.mem_union.mpr
  right
  exact Finset.mem_image.mpr ⟨z, hz, by simp [inr]⟩

private theorem pureC (R : Finset V) {z : V} (hz : z ∈ pairSums R) :
    (z, z) ∈ sixSlices R := by
  apply Finset.mem_union.mpr
  left
  change (z, z) ∈ (pairSums R).image inl ∪ (pairSums R).image inr ∪
    (pairSums R).image diag
  apply Finset.mem_union.mpr
  right
  exact Finset.mem_image.mpr ⟨z, hz, by simp [diag, inl, inr]⟩

private theorem crossAB (R : Finset V) {r s : V} (hr : r ∈ R) (hs : s ∈ R) :
    (r, s) ∈ sixSlices R := by
  apply Finset.mem_union.mpr
  right
  apply Finset.mem_union.mpr
  left
  exact Finset.mem_product.mpr ⟨hr, hs⟩

private theorem crossAC (R : Finset V) {r s : V} (hr : r ∈ R) (hs : s ∈ R) :
    (r + s, s) ∈ sixSlices R := by
  apply Finset.mem_union.mpr
  right
  apply Finset.mem_union.mpr
  right
  apply Finset.mem_union.mpr
  left
  exact Finset.mem_image.mpr ⟨(r, s), Finset.mem_product.mpr ⟨hr, hs⟩, rfl⟩

private theorem crossBC (R : Finset V) {r s : V} (hr : r ∈ R) (hs : s ∈ R) :
    (s, r + s) ∈ sixSlices R := by
  apply Finset.mem_union.mpr
  right
  apply Finset.mem_union.mpr
  right
  apply Finset.mem_union.mpr
  right
  exact Finset.mem_image.mpr ⟨(r, s), Finset.mem_product.mpr ⟨hr, hs⟩, rfl⟩

/-- Six-family cover for every finite row set in an F₂ vector space. -/
theorem six_way_cover (R : Finset V) :
    pairSums (rowsUp R) ⊆ sixSlices R := by
  intro t ht
  obtain ⟨⟨x, y⟩, hxy, ht⟩ := Finset.mem_image.mp ht
  obtain ⟨hx, hy⟩ := Finset.mem_product.mp hxy
  rcases row_cases R hx with ⟨r, hr, rfl⟩ | ⟨r, hr, rfl⟩ | ⟨r, hr, rfl⟩ <;>
  rcases row_cases R hy with ⟨s, hs, rfl⟩ | ⟨s, hs, rfl⟩ | ⟨s, hs, rfl⟩
  · rw [← ht]
    simpa using (pureA R (pair_mem R hr hs))
  · rw [← ht]
    simpa using (crossAB R hr hs)
  · rw [← ht]
    simpa using (crossAC R hr hs)
  · rw [← ht]
    simpa [add_comm] using (crossAB R hs hr)
  · rw [← ht]
    simpa using (pureB R (pair_mem R hr hs))
  · rw [← ht]
    simpa using (crossBC R hr hs)
  · rw [← ht]
    simpa [add_comm] using (crossAC R hs hr)
  · rw [← ht]
    simpa [add_comm] using (crossBC R hs hr)
  · rw [← ht]
    simpa using (pureC R (pair_mem R hr hs))

#print axioms Nightfall.StructuralInformation.SubcubeSecantSlices.six_way_cover

end Nightfall.StructuralInformation.SubcubeSecantSlices
