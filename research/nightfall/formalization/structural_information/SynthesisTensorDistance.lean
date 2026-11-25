import SubcubeSharpness

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SynthesisTensorDistance

open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeSharpness

variable {V : Type*} [AddCommGroup V] [Module K V] [DecidableEq V]

/-- Number of original tensor rows with nonzero character bit. -/
noncomputable def weight (A : Finset V) (s : V →ₗ[K] K) : Nat := by
  classical
  exact (A.filter fun a => s a ≠ 0).card

theorem weight_zero (A : Finset V) : weight A (0 : V →ₗ[K] K) = 0 := by
  classical
  simp [weight]

/-- Exact three-slice Hamming weight, on the actual rowsUp source. -/
theorem weight_step (A : Finset V) (h0 : (0 : V) ∉ A)
    (s : (V × V) →ₗ[K] K) :
    weight (rowsUp A) s =
      weight A (s.comp inl) + weight A (s.comp inr) + weight A (s.comp diag) := by
  classical
  let B := (A.image inl).filter (fun a => s a ≠ 0)
  let C := (A.image inr).filter (fun a => s a ≠ 0)
  let D := (A.image diag).filter (fun a => s a ≠ 0)
  have hBC : Disjoint B C := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    obtain ⟨a, ha, hax⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hx).1
    obtain ⟨b, hb, hbx⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hy).1
    have h : inl a = inr b := hax.trans hbx.symm
    have ha0 : a = 0 := by simpa [inl, inr] using congrArg Prod.fst h
    exact h0 (ha0 ▸ ha)
  have hBD : Disjoint B D := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    obtain ⟨a, ha, hax⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hx).1
    obtain ⟨b, hb, hbx⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hy).1
    have h : inl a = diag b := hax.trans hbx.symm
    have hb0 : b = 0 := by simpa [inl, inr, diag] using (congrArg Prod.snd h).symm
    exact h0 (hb0 ▸ hb)
  have hCD : Disjoint C D := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    obtain ⟨a, ha, hax⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hx).1
    obtain ⟨b, hb, hbx⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hy).1
    have h : inr a = diag b := hax.trans hbx.symm
    have hb0 : b = 0 := by simpa [inl, inr, diag] using (congrArg Prod.fst h).symm
    exact h0 (hb0 ▸ hb)
  have hBCD : Disjoint (B ∪ C) D := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    rcases Finset.mem_union.mp hx with hx | hx
    · exact (Finset.disjoint_left.mp hBD) hx hy
    · exact (Finset.disjoint_left.mp hCD) hx hy
  have hB : B.card = weight A (s.comp inl) := by
    dsimp [B, weight]
    rw [Finset.filter_image]
    apply Finset.card_image_of_injective
    intro a b h
    simpa [inl] using congrArg Prod.fst h
  have hC : C.card = weight A (s.comp inr) := by
    dsimp [C, weight]
    rw [Finset.filter_image]
    apply Finset.card_image_of_injective
    intro a b h
    simpa [inr] using congrArg Prod.snd h
  have hD : D.card = weight A (s.comp diag) := by
    dsimp [D, weight]
    rw [Finset.filter_image]
    apply Finset.card_image_of_injective
    intro a b h
    simpa [diag, inl, inr] using congrArg Prod.fst h
  calc
    weight (rowsUp A) s = ((B ∪ C) ∪ D).card := by
      unfold weight rowsUp
      rw [Finset.filter_union, Finset.filter_union]
      rfl
    _ = B.card + C.card + D.card := by
      rw [Finset.card_union_of_disjoint hBCD, Finset.card_union_of_disjoint hBC]
    _ = _ := by rw [hB, hC, hD]

private theorem two_slices_zero (s : (V × V) →ₗ[K] K)
    (h0 : s.comp inl = 0) (h1 : s.comp inr = 0) : s = 0 := by
  ext x
  have h : inl x.1 + inr x.2 = x := by simp [inl, inr]
  have h0' : s (inl x.1) = 0 := by
    simpa using LinearMap.congr_fun h0 x.1
  have h1' : s (inr x.2) = 0 := by
    simpa using LinearMap.congr_fun h1 x.2
  rw [← h, map_add, h0', h1']
  simp

private theorem diagonal_slice (s : (V × V) →ₗ[K] K) :
    s.comp diag = s.comp inl + s.comp inr := by
  ext x
  simp [diag, map_add]

/-- Every nonzero linear functional on the actual all-level tensor source
    has at least 2^n nonzero evaluations. No finite-depth restriction. -/
theorem distance_lower : ∀ n (s : E n →ₗ[K] K), s ≠ 0 →
    2^n ≤ weight (R n) s := by
  intro n
  induction n with
  | zero =>
    intro s hs
    have h : s (1 : K) ≠ 0 := by
      intro h1
      apply hs
      ext x
      have hx := s.map_smul x (1 : K)
      simpa [h1] using hx
    change 2^0 ≤ weight R0 s
    simp [weight, R0, h]
  | succ n ih =>
    intro s hs
    change 2^(n+1) ≤ weight (rowsUp (R n)) s
    rw [weight_step (R n) (rows_nonzero n), pow_succ]
    have hdiag := diagonal_slice s
    by_cases h0 : s.comp inl = 0
    · have h1 : s.comp inr ≠ 0 := fun h => hs (two_slices_zero s h0 h)
      have h2 : s.comp diag ≠ 0 := by
        rw [hdiag, h0, zero_add]
        exact h1
      have u := ih (s.comp inr) h1
      have v := ih (s.comp diag) h2
      omega
    · by_cases h1 : s.comp inr = 0
      · have h2 : s.comp diag ≠ 0 := by
          rw [hdiag, h1, add_zero]
          exact h0
        have u := ih (s.comp inl) h0
        have v := ih (s.comp diag) h2
        omega
      · have u := ih (s.comp inl) h0
        have v := ih (s.comp inr) h1
        omega

/-- The rank-one dual witness, iteratively taking the first factor. -/
noncomputable def witness : (n : Nat) → E n →ₗ[K] K
  | 0 => LinearMap.id
  | n+1 => (witness n).comp (LinearMap.fst K (E n) (E n))

theorem distance_witness : ∀ n, weight (R n) (witness n) = 2^n := by
  intro n
  induction n with
  | zero => simp [R, R0, weight, witness]
  | succ n ih =>
    change weight (rowsUp (R n)) (witness (n+1)) = 2^(n+1)
    rw [weight_step (R n) (rows_nonzero n)]
    have h0 : (witness (n+1)).comp inl = witness n := by
      ext x
      simp [witness, inl]
    have h1 : (witness (n+1)).comp inr = 0 := by
      ext x
      simp [witness, inr]
    have h2 : (witness (n+1)).comp diag = witness n := by
      rw [diagonal_slice, h0, h1, add_zero]
    rw [h0, h1, h2, weight_zero, ih, pow_succ]
    omega

/-- Exact minimum, including the nonzero witness, and actual source length
    and ambient rank. The observed code is the linear evaluation image. -/
theorem exact_distance (n : Nat) :
    (R n).card = 3^n ∧ Module.finrank K (E n) = 2^n ∧
    (∀ s : E n →ₗ[K] K, s ≠ 0 → 2^n ≤ weight (R n) s) ∧
    (∃ s : E n →ₗ[K] K, s ≠ 0 ∧ weight (R n) s = 2^n) := by
  refine ⟨all_levels_cardinality n, finrank_E n, distance_lower n, witness n, ?_, distance_witness n⟩
  intro h
  have hw := distance_witness n
  rw [h, weight_zero] at hw
  have hp : 0 < 2^n := by positivity
  omega

/-- Exact score optimization after the entropy/incidence inequality.
    The hypotheses are explicit: this is NOT the entropy/incidence theorem. -/
theorem score_lower (t c x C ell : ℝ)
    (ht : 1 ≤ t) (hC : 0 ≤ C) (hce : 1 ≤ c*ell)
    (hinfo : c*ell*(x-t) ≤ C) : x ≤ t*(1+C) := by
  by_cases h : x ≤ t
  · have hmul := mul_nonneg (show 0 ≤ t by linarith) hC
    nlinarith
  · have hx : 0 ≤ x-t := by linarith
    have ha := mul_nonneg (show 0 ≤ c*ell-1 by linarith) hx
    have hc : x-t ≤ C := by nlinarith
    have hb := mul_nonneg (show 0 ≤ t by linarith) (show 0 ≤ C-(x-t) by linarith)
    have hd := mul_nonneg (show 0 ≤ t-1 by linarith) hx
    nlinarith

#print axioms Nightfall.StructuralInformation.SynthesisTensorDistance.weight_step
#print axioms Nightfall.StructuralInformation.SynthesisTensorDistance.distance_lower
#print axioms Nightfall.StructuralInformation.SynthesisTensorDistance.distance_witness
#print axioms Nightfall.StructuralInformation.SynthesisTensorDistance.exact_distance
#print axioms Nightfall.StructuralInformation.SynthesisTensorDistance.score_lower

end Nightfall.StructuralInformation.SynthesisTensorDistance
