import Mathlib

/-!
# Infinite-field square oracle: signed-code extension

A reusable algebraic bridge for infinite-field phase retrieval.
Every injective finite signed code can be extended by one sign.
No source-level oracle terminal is claimed in this file.
-/

namespace Nightfall.InfiniteFieldPhase

noncomputable section

variable {K : Type*} [Field K] [Infinite K] [NeZero (2 : K)]

/-- Extend any injective finite code by one signed bit over an infinite field. -/
theorem exists_signed_code_extension
    {α : Type*} [Fintype α] (f : α → K) (hf : Function.Injective f) :
    ∃ z : K, Function.Injective (fun p : Bool × α =>
      f p.2 + (if p.1 then z else -z)) := by
  classical
  let bad : Finset K :=
    Finset.univ.image (fun p : α × α => (f p.1 - f p.2) / (2 : K))
  obtain ⟨z, hz⟩ := Infinite.exists_notMem_finset bad
  refine ⟨z, ?_⟩
  rintro ⟨b, x⟩ ⟨c, y⟩ heq
  have htwo : (2 : K) ≠ 0 := NeZero.ne _
  cases b with
  | false =>
      cases c with
      | false =>
          have hxy : x = y := hf (by linear_combination heq)
          simpa [hxy]
      | true =>
          have he : f x - z = f y + z := by simpa [sub_eq_add_neg] using heq
          have hcalc : z = (f x - f y) / (2 : K) := by
            apply (eq_div_iff htwo).2
            linear_combination -he
          have hmem : z ∈ bad := by
            apply Finset.mem_image.mpr
            refine ⟨(x, y), Finset.mem_univ _, ?_⟩
            simpa [hcalc]
          exact False.elim (hz hmem)
  | true =>
      cases c with
      | false =>
          have he : f x + z = f y - z := by simpa [sub_eq_add_neg] using heq
          have hcalc : z = (f y - f x) / (2 : K) := by
            apply (eq_div_iff htwo).2
            linear_combination he
          have hmem : z ∈ bad := by
            apply Finset.mem_image.mpr
            refine ⟨(y, x), Finset.mem_univ _, ?_⟩
            simpa [hcalc]
          exact False.elim (hz hmem)
      | true =>
          have hxy : x = y := hf (by linear_combination heq)
          simpa [hxy]


/-- Signed sums of Boolean orientations in a field. -/
def signedSum {n : ℕ} (w : Fin n → K) (s : Fin n → Bool) : K :=
  ∑ i, (if s i then (1 : K) else -1) * w i

private theorem signedSum_cons {n : ℕ} (z : K) (w : Fin n → K)
    (b : Bool) (s : Fin n → Bool) :
    signedSum (Fin.cons z w) (Fin.cons b s) =
      signedSum w s + (if b then z else -z) := by
  simp [signedSum, Fin.sum_univ_succ, add_comm]

/-- Every finite number of signs can be packed into one unsquared field
element over any infinite field with two invertible. -/
theorem exists_all_length_signed_code (n : ℕ) :
    ∃ w : Fin n → K, Function.Injective (signedSum w) := by
  classical
  induction n with
  | zero =>
      refine ⟨Fin.elim0, ?_⟩
      intro s t _
      funext i
      exact Fin.elim0 i
  | succ n ih =>
      obtain ⟨w, hw⟩ := ih
      obtain ⟨z, hz⟩ := exists_signed_code_extension (signedSum w) hw
      refine ⟨Fin.cons z w, ?_⟩
      intro s t hst
      have hs : signedSum (Fin.cons z w) s =
          signedSum w (Fin.tail s) + (if s 0 then z else -z) := by
        rw [← Fin.cons_self_tail s]
        exact signedSum_cons z w (s 0) (Fin.tail s)
      have ht : signedSum (Fin.cons z w) t =
          signedSum w (Fin.tail t) + (if t 0 then z else -z) := by
        rw [← Fin.cons_self_tail t]
        exact signedSum_cons z w (t 0) (Fin.tail t)
      have he : (s 0, Fin.tail s) = (t 0, Fin.tail t) := by
        apply hz
        change signedSum w (Fin.tail s) + (if s 0 then z else -z) =
          signedSum w (Fin.tail t) + (if t 0 then z else -z)
        exact hs.symm.trans (hst.trans ht)
      calc
        s = Fin.cons (s 0) (Fin.tail s) := (Fin.cons_self_tail s).symm
        _ = Fin.cons (t 0) (Fin.tail t) := by
          have hhead : s 0 = t 0 := congrArg Prod.fst he
          have htail : Fin.tail s = Fin.tail t := congrArg Prod.snd he
          rw [hhead, htail]
        _ = t := Fin.cons_self_tail t


/-- Flipping every Boolean sign negates the mixed linear reading. -/
theorem signedSum_compl {n : ℕ} (w : Fin n → K) (s : Fin n → Bool) :
    signedSum w (fun i => !(s i)) = -(signedSum w s) := by
  unfold signedSum
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro i _
  cases hs : s i <;> simp [hs]

/-- The ONE actual squared reading identifies the sign vector modulo its
single unavoidable global sign, once a separating weight row is chosen. -/
theorem squared_signedSum_injective_mod_sign {n : ℕ}
    (w : Fin n → K) (hw : Function.Injective (signedSum w))
    (s t : Fin n → Bool)
    (h : (signedSum w s) ^ 2 = (signedSum w t) ^ 2) :
    s = t ∨ s = (fun i => !(t i)) := by
  have hmul : signedSum w s * signedSum w s =
      signedSum w t * signedSum w t := by
    simpa only [pow_two] using h
  rcases (mul_self_eq_mul_self_iff).mp hmul with he | he
  · exact Or.inl (hw he)
  · right
    apply hw
    rw [signedSum_compl]
    exact he


/-! ## Support-safe sign packing for actual linear readings -/

/-- Inactive coordinates are zero, even when their Boolean label changes. -/
noncomputable def maskedSignedSum {n : ℕ} (w a : Fin n → K) (s : Fin n → Bool) : K := by
  classical
  exact ∑ i, if a i = 0 then 0 else (if s i then w i else -w i)

noncomputable def clippedSigns {n : ℕ} (a : Fin n → K) (s : Fin n → Bool) : Fin n → Bool := by
  classical
  exact fun i => if a i = 0 then false else s i

noncomputable def inactiveOffset {n : ℕ} (w a : Fin n → K) : K := by
  classical
  exact ∑ i, if a i = 0 then w i else 0

theorem maskedSignedSum_eq {n : ℕ} (w a : Fin n → K) (s : Fin n → Bool) :
    maskedSignedSum w a s =
      signedSum w (clippedSigns a s) + inactiveOffset w a := by
  classical
  unfold maskedSignedSum signedSum clippedSigns inactiveOffset
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : a i = 0
  · simp [hi]
  · cases hs : s i <;> simp [hi, hs]

theorem maskedSignedSum_injective_active {n : ℕ}
    (w a : Fin n → K) (hw : Function.Injective (signedSum w))
    (s t : Fin n → Bool)
    (h : maskedSignedSum w a s = maskedSignedSum w a t) :
    ∀ i, a i ≠ 0 → s i = t i := by
  classical
  rw [maskedSignedSum_eq, maskedSignedSum_eq] at h
  have he : clippedSigns a s = clippedSigns a t := hw (add_right_cancel h)
  intro i hi
  have hj := congrArg (fun f : Fin n → Bool => f i) he
  change (if a i = 0 then false else s i) =
    (if a i = 0 then false else t i) at hj
  simpa only [if_neg hi] using hj

theorem maskedSignedSum_compl {n : ℕ}
    (w a : Fin n → K) (s : Fin n → Bool) :
    maskedSignedSum w a (fun i => !(s i)) = -(maskedSignedSum w a s) := by
  classical
  unfold maskedSignedSum
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : a i = 0
  · simp [hi]
  · cases hs : s i <;> simp [hi, hs]

theorem squared_maskedSignedSum_injective_active {n : ℕ}
    (w a : Fin n → K) (hw : Function.Injective (signedSum w))
    (s t : Fin n → Bool)
    (h : (maskedSignedSum w a s) ^ 2 = (maskedSignedSum w a t) ^ 2) :
    (∀ i, a i ≠ 0 → s i = t i) ∨
    (∀ i, a i ≠ 0 → s i = !(t i)) := by
  classical
  have hmul : maskedSignedSum w a s * maskedSignedSum w a s =
      maskedSignedSum w a t * maskedSignedSum w a t := by
    simpa only [pow_two] using h
  rcases (mul_self_eq_mul_self_iff).mp hmul with he | he
  · exact Or.inl (maskedSignedSum_injective_active w a hw s t he)
  · right
    apply maskedSignedSum_injective_active w a hw s (fun i => !(t i))
    rw [maskedSignedSum_compl]
    exact he

/-- Coefficients divided by observed root representatives; zeros are safe. -/
noncomputable def adaptiveRow {n : ℕ} (w a : Fin n → K) : Fin n → K := by
  classical
  exact fun i => if a i = 0 then 0 else w i / a i

def oriented {n : ℕ} (a : Fin n → K) (s : Fin n → Bool) : Fin n → K :=
  fun i => if s i then a i else -a i

theorem adaptiveRow_oriented_dot {n : ℕ}
    (w a : Fin n → K) (s : Fin n → Bool) :
    (∑ i, adaptiveRow w a i * oriented a s i) =
      maskedSignedSum w a s := by
  classical
  unfold maskedSignedSum
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : a i = 0
  · simp [adaptiveRow, oriented, hi]
  · cases hs : s i <;> simp [adaptiveRow, oriented, hi, hs, div_mul_cancel₀]


/-! ## A legal row chosen from coordinate-square observations -/

theorem exists_oriented_scalar (a x : K) (h : x ^ 2 = a ^ 2) :
    ∃ b : Bool, x = if b then a else -a := by
  have hh : x * x = a * a := by simpa only [pow_two] using h
  rcases (mul_self_eq_mul_self_iff).mp hh with he | he
  · exact ⟨true, by simpa using he⟩
  · exact ⟨false, by simpa using he⟩

theorem exists_oriented_vector {n : ℕ} (a x : Fin n → K)
    (h : ∀ i, (x i) ^ 2 = (a i) ^ 2) :
    ∃ s : Fin n → Bool, x = oriented a s := by
  classical
  have hchoices : ∀ i : Fin n, ∃ s : Bool, x i = if s then a i else -a i := by
    intro i
    exact exists_oriented_scalar (a i) (x i) (h i)
  choose s hs using hchoices
  refine ⟨s, ?_⟩
  funext i
  exact hs i

theorem oriented_eq_of_active {n : ℕ} (a : Fin n → K) (s t : Fin n → Bool)
    (h : ∀ i, a i ≠ 0 → s i = t i) :
    oriented a s = oriented a t := by
  funext i
  by_cases hi : a i = 0
  · simp [oriented, hi]
  · have he := h i hi
    simp only [oriented]
    rw [he]

theorem oriented_neg_of_active_compl {n : ℕ}
    (a : Fin n → K) (s t : Fin n → Bool)
    (h : ∀ i, a i ≠ 0 → s i = !(t i)) :
    oriented a s = -(oriented a t) := by
  funext i
  by_cases hi : a i = 0
  · simp [oriented, hi]
  · have he := h i hi
    cases ht : t i <;> simp [oriented, he, ht]

theorem adaptiveRow_separates_square_fiber {n : ℕ}
    (w a x y : Fin n → K) (hw : Function.Injective (signedSum w))
    (hx : ∀ i, (x i) ^ 2 = (a i) ^ 2)
    (hy : ∀ i, (y i) ^ 2 = (a i) ^ 2)
    (hread : (∑ i, adaptiveRow w a i * x i) ^ 2 =
             (∑ i, adaptiveRow w a i * y i) ^ 2) :
    x = y ∨ x = -y := by
  classical
  obtain ⟨s, hs⟩ := exists_oriented_vector a x hx
  obtain ⟨t, ht⟩ := exists_oriented_vector a y hy
  have hcode : (maskedSignedSum w a s) ^ 2 =
      (maskedSignedSum w a t) ^ 2 := by
    rw [hs, ht] at hread
    simpa only [adaptiveRow_oriented_dot] using hread
  rcases squared_maskedSignedSum_injective_active w a hw s t hcode with hsame | hflip
  · left
    calc
      x = oriented a s := hs
      _ = oriented a t := oriented_eq_of_active a s t hsame
      _ = y := ht.symm
  · right
    calc
      x = oriented a s := hs
      _ = -(oriented a t) := oriented_neg_of_active_compl a s t hflip
      _ = -y := by rw [ht]

/-- A canonical square root when one exists; the other case is unreachable
on a fiber actually produced by a signal. -/
noncomputable def rootChoice (z : K) : K := by
  classical
  exact if h : ∃ a : K, a ^ 2 = z then Classical.choose h else 0

theorem rootChoice_square (x : K) :
    (rootChoice (x ^ 2)) ^ 2 = x ^ 2 := by
  classical
  have h : ∃ a : K, a ^ 2 = x ^ 2 := ⟨x, rfl⟩
  unfold rootChoice
  rw [dif_pos h]
  exact Classical.choose_spec h

/-- Global sign-code weights are fixed before measurements. -/
noncomputable def selectedWeights (n : ℕ) : Fin n → K :=
  Classical.choose (exists_all_length_signed_code (K := K) n)

theorem selectedWeights_injective (n : ℕ) :
    Function.Injective (signedSum (selectedWeights (K := K) n)) :=
  Classical.choose_spec (exists_all_length_signed_code (K := K) n)

/-- The final row depends ONLY on the previously observed coordinate squares. -/
noncomputable def observedSquareRow {n : ℕ} (data : Fin n → K) : Fin n → K :=
  adaptiveRow (selectedWeights (K := K) n) (fun i => rootChoice (data i))

theorem observedSquareRow_separates_fiber {n : ℕ}
    (data x y : Fin n → K)
    (hx : ∀ i, (x i) ^ 2 = data i)
    (hy : ∀ i, (y i) ^ 2 = data i)
    (hread : (∑ i, observedSquareRow data i * x i) ^ 2 =
             (∑ i, observedSquareRow data i * y i) ^ 2) :
    x = y ∨ x = -y := by
  classical
  let a : Fin n → K := fun i => rootChoice (data i)
  have ha (i : Fin n) : (a i) ^ 2 = data i := by
    change (rootChoice (data i)) ^ 2 = data i
    rw [← hx i]
    exact rootChoice_square (x i)
  have hxa (i : Fin n) : (x i) ^ 2 = (a i) ^ 2 := (hx i).trans (ha i).symm
  have hya (i : Fin n) : (y i) ^ 2 = (a i) ^ 2 := (hy i).trans (ha i).symm
  exact adaptiveRow_separates_square_fiber
    (selectedWeights (K := K) n) a x y
    (selectedWeights_injective (K := K) n) hxa hya
    (by simpa only [observedSquareRow, a] using hread)

/-- Exactly n coordinate-square readings and one history-dependent square. -/
noncomputable def adaptiveTranscript {n : ℕ} (x : Fin n → K) :
    (Fin n → K) × K :=
  let data : Fin n → K := fun i => (x i) ^ 2
  (data, (∑ i, observedSquareRow data i * x i) ^ 2)

/-- Certified upper bound: the actual n+1-query transcript recovers
every vector modulo the unavoidable global sign, including zeros. -/
theorem adaptiveTranscript_injective_mod_sign {n : ℕ} (x y : Fin n → K)
    (h : adaptiveTranscript x = adaptiveTranscript y) :
    x = y ∨ x = -y := by
  classical
  have hd : (fun i : Fin n => (x i) ^ 2) =
      (fun i : Fin n => (y i) ^ 2) := by
    exact congrArg Prod.fst h
  have hr :
      (∑ i, observedSquareRow (fun j : Fin n => (x j) ^ 2) i * x i) ^ 2 =
      (∑ i, observedSquareRow (fun j : Fin n => (x j) ^ 2) i * y i) ^ 2 := by
    have hs := congrArg Prod.snd h
    change
      (∑ i, observedSquareRow (fun j : Fin n => (x j) ^ 2) i * x i) ^ 2 =
      (∑ i, observedSquareRow (fun j : Fin n => (y j) ^ 2) i * y i) ^ 2 at hs
    rw [← hd] at hs
    exact hs
  apply observedSquareRow_separates_fiber (fun i => (x i) ^ 2) x y
  · intro i
    rfl
  · intro i
    exact (congrArg (fun f : Fin n → K => f i) hd).symm
  · exact hr

#print axioms Nightfall.InfiniteFieldPhase.adaptiveTranscript_injective_mod_sign


#print axioms Nightfall.InfiniteFieldPhase.squared_maskedSignedSum_injective_active
#print axioms Nightfall.InfiniteFieldPhase.adaptiveRow_oriented_dot


#print axioms Nightfall.InfiniteFieldPhase.squared_signedSum_injective_mod_sign


#print axioms Nightfall.InfiniteFieldPhase.exists_all_length_signed_code


#print axioms Nightfall.InfiniteFieldPhase.exists_signed_code_extension

end
end Nightfall.InfiniteFieldPhase
