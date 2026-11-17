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
def maskedSignedSum {n : ℕ} (w a : Fin n → K) (s : Fin n → Bool) : K :=
  ∑ i, if a i = 0 then 0 else (if s i then w i else -w i)

def clippedSigns {n : ℕ} (a : Fin n → K) (s : Fin n → Bool) : Fin n → Bool :=
  fun i => if a i = 0 then false else s i

def inactiveOffset {n : ℕ} (w a : Fin n → K) : K :=
  ∑ i, if a i = 0 then w i else 0

theorem maskedSignedSum_eq {n : ℕ} (w a : Fin n → K) (s : Fin n → Bool) :
    maskedSignedSum w a s =
      signedSum w (clippedSigns a s) + inactiveOffset w a := by
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
  rw [maskedSignedSum_eq, maskedSignedSum_eq] at h
  have he : clippedSigns a s = clippedSigns a t := hw (add_right_cancel h)
  intro i hi
  have hj := congrArg (fun f : Fin n → Bool => f i) he
  simpa [clippedSigns, hi] using hj

theorem maskedSignedSum_compl {n : ℕ}
    (w a : Fin n → K) (s : Fin n → Bool) :
    maskedSignedSum w a (fun i => !(s i)) = -(maskedSignedSum w a s) := by
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
def adaptiveRow {n : ℕ} (w a : Fin n → K) : Fin n → K :=
  fun i => if a i = 0 then 0 else w i / a i

def oriented {n : ℕ} (a : Fin n → K) (s : Fin n → Bool) : Fin n → K :=
  fun i => if s i then a i else -a i

theorem adaptiveRow_oriented_dot {n : ℕ}
    (w a : Fin n → K) (s : Fin n → Bool) :
    (∑ i, adaptiveRow w a i * oriented a s i) =
      maskedSignedSum w a s := by
  unfold maskedSignedSum
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : a i = 0
  · simp [adaptiveRow, oriented, hi]
  · cases hs : s i <;> simp [adaptiveRow, oriented, hi, hs, div_mul_cancel₀]

#print axioms Nightfall.InfiniteFieldPhase.squared_maskedSignedSum_injective_active
#print axioms Nightfall.InfiniteFieldPhase.adaptiveRow_oriented_dot


#print axioms Nightfall.InfiniteFieldPhase.squared_signedSum_injective_mod_sign


#print axioms Nightfall.InfiniteFieldPhase.exists_all_length_signed_code


#print axioms Nightfall.InfiniteFieldPhase.exists_signed_code_extension

end
end Nightfall.InfiniteFieldPhase
