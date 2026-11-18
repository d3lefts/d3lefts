import EfronSteinDegree
import HeterogeneousAlphabets

/-!
# NIGHTFALL: iterated mixed differences and indicator-monomial degree

Finite algebra on a product of coordinate-dependent finite alphabets `∀ i, β i`.

* `mdelta l H` is the iterated mixed difference of `H` along a list `l` of steps
  `⟨k, (a, a')⟩` (`H(· with x_k := a) − H(· with x_k := a')`, nested).
* `mdelta_eq_zero_of_mem`: a mixed difference along distinct coordinates vanishes as soon as
  `H` ignores one of its letter pairs.
* `mdelta_comp`: coordinatewise retractions commute with mixed differences.
* `mdelta_anchor`: the anchored Möbius expansion of a mixed difference.
* `depDegree_of_mdelta`: if every mixed difference along `d + 1` distinct coordinates vanishes,
  then `F` is a combination of indicator monomials of order at most `d`
  (`Heterogeneous.DepDegreeLE F d`).
* `dinfl_eq_heatBath`: the pair form `dinfl` of the Efron–Stein influence equals the one-site
  heat-bath residual energy `E (F − E_j F)²`.
-/

namespace Nightfall.ProductSpace.MixedDifference

open Finset
open Nightfall.ProductSpace.Heterogeneous

/-- One step of a mixed difference: a coordinate and two letters. -/
abbrev Step {κ : Type} (β : κ → Type) : Type := Σ k : κ, β k × β k

variable {κ : Type} [Fintype κ] [DecidableEq κ] {β : κ → Type} [∀ i, Fintype (β i)]
  [∀ i, DecidableEq (β i)]

/-- Iterated mixed difference along a list of steps. -/
def mdelta : List (Step β) → ((∀ i, β i) → ℝ) → (∀ i, β i) → ℝ
  | [], H => H
  | s :: l, H => fun y =>
      mdelta l H (Function.update y s.1 s.2.1) - mdelta l H (Function.update y s.1 s.2.2)

theorem mdelta_nil (H : (∀ i, β i) → ℝ) : mdelta ([] : List (Step β)) H = H := rfl

theorem mdelta_cons (s : Step β) (l : List (Step β)) (H : (∀ i, β i) → ℝ) (y : ∀ i, β i) :
    mdelta (s :: l) H y =
      mdelta l H (Function.update y s.1 s.2.1) - mdelta l H (Function.update y s.1 s.2.2) :=
  rfl

theorem mdelta_append (l₁ l₂ : List (Step β)) (H : (∀ i, β i) → ℝ) :
    mdelta (l₁ ++ l₂) H = mdelta l₁ (mdelta l₂ H) := by
  induction l₁ with
  | nil => rfl
  | cons s l ih =>
    funext y
    simp only [List.cons_append, mdelta_cons, ih]

theorem mdelta_zero (l : List (Step β)) :
    mdelta l (fun _ : ∀ i, β i => (0 : ℝ)) = fun _ => 0 := by
  induction l with
  | nil => rfl
  | cons s l ih =>
    funext y
    simp only [mdelta_cons, ih, sub_self]

theorem mdelta_add (l : List (Step β)) (H₁ H₂ : (∀ i, β i) → ℝ) (y : ∀ i, β i) :
    mdelta l (fun z => H₁ z + H₂ z) y = mdelta l H₁ y + mdelta l H₂ y := by
  induction l generalizing y with
  | nil => rfl
  | cons s l ih =>
    simp only [mdelta_cons, ih]
    ring

/-- Updating a coordinate absent from the list commutes with the mixed difference. -/
theorem mdelta_update_invariant (l : List (Step β)) (k : κ) (a a' : β k)
    (hk : ∀ s ∈ l, s.1 ≠ k) (H : (∀ i, β i) → ℝ)
    (hH : ∀ z, H (Function.update z k a) = H (Function.update z k a')) (y : ∀ i, β i) :
    mdelta l H (Function.update y k a) = mdelta l H (Function.update y k a') := by
  induction l generalizing y with
  | nil => exact hH y
  | cons s l ih =>
    have hs : k ≠ s.1 := fun h => hk s (List.mem_cons_self) h.symm
    have hk' : ∀ t ∈ l, t.1 ≠ k := fun t ht => hk t (List.mem_cons_of_mem _ ht)
    simp only [mdelta_cons]
    rw [Function.update_comm hs a s.2.1, Function.update_comm hs a s.2.2,
      Function.update_comm hs a' s.2.1, Function.update_comm hs a' s.2.2,
      ih hk', ih hk']

/-- A mixed difference along distinct coordinates vanishes when `H` ignores one of its steps. -/
theorem mdelta_eq_zero_of_mem (l : List (Step β)) (hnd : (l.map Sigma.fst).Nodup)
    (s : Step β) (hs : s ∈ l) (H : (∀ i, β i) → ℝ)
    (hH : ∀ z, H (Function.update z s.1 s.2.1) = H (Function.update z s.1 s.2.2))
    (y : ∀ i, β i) : mdelta l H y = 0 := by
  induction l generalizing y with
  | nil => exact absurd hs List.not_mem_nil
  | cons t l ih =>
    rw [List.map_cons, List.nodup_cons] at hnd
    rcases List.mem_cons.mp hs with rfl | hsl
    · rw [mdelta_cons, mdelta_update_invariant l s.1 s.2.1 s.2.2
        (fun u hu h => hnd.1 (List.mem_map.mpr ⟨u, hu, h⟩)) H hH, sub_self]
    · rw [mdelta_cons, ih hnd.2 hsl, ih hnd.2 hsl, sub_self]

/-- Coordinatewise retractions commute with mixed differences. -/
theorem mdelta_comp (r : ∀ i, β i → β i) (l : List (Step β)) (H : (∀ i, β i) → ℝ)
    (y : ∀ i, β i) :
    mdelta l (fun z => H (fun i => r i (z i))) y =
      mdelta (l.map fun s => (⟨s.1, (r s.1 s.2.1, r s.1 s.2.2)⟩ : Step β)) H
        (fun i => r i (y i)) := by
  have hR : ∀ (z : ∀ i, β i) (k : κ) (a : β k),
      (fun i => r i (Function.update z k a i)) = Function.update (fun i => r i (z i)) k (r k a) := by
    intro z k a
    funext i
    by_cases h : i = k
    · subst h; simp
    · simp [Function.update_of_ne h]
  induction l generalizing y with
  | nil => rfl
  | cons s l ih =>
    simp only [List.map_cons, mdelta_cons, ih, hR]

/-- Anchored expansion of a mixed difference whose letters are `y k` and `s0 k`. -/
theorem mdelta_anchor (F : (∀ i, β i) → ℝ) (y s0 : ∀ i, β i) (L : List κ) (hL : L.Nodup)
    (b : ∀ i, β i) :
    mdelta (L.map fun k => (⟨k, (y k, s0 k)⟩ : Step β)) F b =
      ∑ U ∈ L.toFinset.powerset, (-1 : ℝ) ^ (L.length - U.card) *
        F (fun i => if i ∈ U then y i else if i ∈ L then s0 i else b i) := by
  induction L generalizing b with
  | nil => simp [mdelta_nil]
  | cons k L ih =>
    rw [List.nodup_cons] at hL
    have hkL : k ∉ L.toFinset := by simpa using hL.1
    rw [List.map_cons, mdelta_cons, ih hL.2, ih hL.2, List.toFinset_cons,
      Finset.sum_powerset_insert hkL]
    have hsub : ∀ U ∈ L.toFinset.powerset, U.card ≤ L.length := by
      intro U hU
      exact (Finset.card_le_card (Finset.mem_powerset.mp hU)).trans
        (List.toFinset_card_le L)
    have hkU : ∀ U ∈ L.toFinset.powerset, k ∉ U := fun U hU hk =>
      hkL (Finset.mem_powerset.mp hU hk)
    have h1 : ∀ U ∈ L.toFinset.powerset,
        (-1 : ℝ) ^ ((k :: L).length - (insert k U).card) *
          F (fun i => if i ∈ insert k U then y i else if i ∈ k :: L then s0 i else b i) =
        (-1 : ℝ) ^ (L.length - U.card) *
          F (fun i => if i ∈ U then y i else if i ∈ L then s0 i
            else Function.update b k (y k) i) := by
      intro U hU
      have hc : (k :: L).length - (insert k U).card = L.length - U.card := by
        rw [Finset.card_insert_of_notMem (hkU U hU), List.length_cons]
        have := hsub U hU
        omega
      rw [hc]
      congr 2
      funext i
      by_cases hi : i = k
      · subst hi
        simp [hkU U hU, hL.1]
      · simp [hi, Function.update_of_ne hi]
    have h2 : ∀ U ∈ L.toFinset.powerset,
        (-1 : ℝ) ^ ((k :: L).length - U.card) *
          F (fun i => if i ∈ U then y i else if i ∈ k :: L then s0 i else b i) =
        -((-1 : ℝ) ^ (L.length - U.card) *
          F (fun i => if i ∈ U then y i else if i ∈ L then s0 i
            else Function.update b k (s0 k) i)) := by
      intro U hU
      have hc : (k :: L).length - U.card = (L.length - U.card) + 1 := by
        rw [List.length_cons]
        have := hsub U hU
        omega
      rw [hc, pow_succ]
      have hpt : (fun i => if i ∈ U then y i else if i ∈ k :: L then s0 i else b i) =
          (fun i => if i ∈ U then y i else if i ∈ L then s0 i
            else Function.update b k (s0 k) i) := by
        funext i
        by_cases hi : i = k
        · subst hi
          simp [hkU U hU, hL.1]
        · simp [hi, Function.update_of_ne hi]
      rw [hpt]
      ring
    rw [Finset.sum_congr rfl h2, Finset.sum_congr rfl h1, Finset.sum_neg_distrib]
    ring

/-- Merge `y` on `U` with the anchor `s0` elsewhere. -/
def anchorMerge (U : Finset κ) (y s0 : ∀ i, β i) : ∀ i, β i :=
  fun i => if i ∈ U then y i else s0 i

/-- Anchored Möbius component on `T`. -/
noncomputable def anchorComp (F : (∀ i, β i) → ℝ) (s0 : ∀ i, β i) (T : Finset κ)
    (y : ∀ i, β i) : ℝ :=
  ∑ U ∈ T.powerset, (-1 : ℝ) ^ (T.card - U.card) * F (anchorMerge U y s0)

theorem anchorComp_eq_mdelta (F : (∀ i, β i) → ℝ) (s0 : ∀ i, β i) (T : Finset κ)
    (y : ∀ i, β i) :
    anchorComp F s0 T y =
      mdelta (T.toList.map fun k => (⟨k, (y k, s0 k)⟩ : Step β)) F s0 := by
  rw [mdelta_anchor F y s0 T.toList (Finset.nodup_toList T) s0, Finset.toList_toFinset,
    Finset.length_toList]
  unfold anchorComp anchorMerge
  refine Finset.sum_congr rfl fun U _ => ?_
  congr 2
  funext i
  by_cases h1 : i ∈ U
  · simp [h1]
  · by_cases h2 : i ∈ T <;> simp [h1, h2]

theorem anchorComp_mobius (F : (∀ i, β i) → ℝ) (s0 y : ∀ i, β i) :
    ∑ T : Finset κ, anchorComp F s0 T y = F y := by
  unfold anchorComp
  have h1 : ∑ T : Finset κ, ∑ U ∈ T.powerset, (-1 : ℝ) ^ (T.card - U.card) *
        F (anchorMerge U y s0) =
      ∑ U : Finset κ, ∑ T ∈ univ.filter (fun T : Finset κ => U ⊆ T),
        (-1 : ℝ) ^ (T.card - U.card) * F (anchorMerge U y s0) :=
    Finset.sum_comm' (fun T U => by simp [Finset.mem_powerset])
  rw [h1]
  have h2 : ∀ U : Finset κ, ∑ T ∈ univ.filter (fun T : Finset κ => U ⊆ T),
      (-1 : ℝ) ^ (T.card - U.card) * F (anchorMerge U y s0) =
        (if U = univ then 1 else 0) * F (anchorMerge U y s0) := by
    intro U
    rw [← Finset.sum_mul, EfronStein.inner_mobius U]
  rw [Finset.sum_congr rfl (fun U _ => h2 U), Finset.sum_eq_single (univ : Finset κ)]
  · rw [if_pos rfl, one_mul]
    congr 1
    funext i
    simp [anchorMerge]
  · intro U _ hU
    rw [if_neg hU, zero_mul]
  · intro h
    exact (h (mem_univ _)).elim

theorem anchorComp_dependsOn (F : (∀ i, β i) → ℝ) (s0 : ∀ i, β i) (T : Finset κ)
    (y y' : ∀ i, β i) (h : ∀ i ∈ T, y i = y' i) :
    anchorComp F s0 T y = anchorComp F s0 T y' := by
  unfold anchorComp
  refine Finset.sum_congr rfl fun U hU => ?_
  congr 2
  funext i
  unfold anchorMerge
  by_cases hi : i ∈ U
  · simp [hi, h i (Finset.mem_powerset.mp hU hi)]
  · simp [hi]

/-- **Vanishing `(d+1)`-fold mixed differences give indicator-monomial degree `≤ d`.** -/
theorem depDegree_of_mdelta (F : (∀ i, β i) → ℝ) (d : ℕ) (s0 : ∀ i, β i)
    (hvan : ∀ l : List (Step β), (l.map Sigma.fst).Nodup → l.length = d + 1 →
      ∀ y, mdelta l F y = 0) :
    DepDegreeLE F d := by
  classical
  have hzero : ∀ T : Finset κ, d < T.card → ∀ y, anchorComp F s0 T y = 0 := by
    intro T hT y
    rw [anchorComp_eq_mdelta]
    set l := T.toList.map fun k => (⟨k, (y k, s0 k)⟩ : Step β)
    have hlen : l.length = T.card := by simp [l]
    have hmap : l.map Sigma.fst = T.toList := by
      simp only [l, List.map_map]
      exact List.map_id' _
    set m := T.card - (d + 1)
    rw [← List.take_append_drop m l, mdelta_append]
    have hdrop : mdelta (l.drop m) F = fun _ => 0 := by
      funext z
      refine hvan _ ?_ ?_ z
      · rw [List.map_drop, hmap]
        exact (Finset.nodup_toList T).sublist (List.drop_sublist _ _)
      · rw [List.length_drop, hlen]
        omega
    rw [hdrop, mdelta_zero]
  refine ⟨fun T τ => if d < T.card then 0 else
      (if ∀ i, i ∉ T → τ i = s0 i then anchorComp F s0 T τ else 0), ?_, ?_⟩
  · intro T hT τ
    simp only [if_pos hT]
  · intro y
    rw [← anchorComp_mobius F s0 y]
    refine Finset.sum_congr rfl fun T _ => ?_
    by_cases hT : d < T.card
    · simp only [if_pos hT, zero_mul, Finset.sum_const_zero]
      exact hzero T hT y
    · simp only [if_neg hT]
      set τs : ∀ i, β i := anchorMerge T y s0
      rw [Finset.sum_eq_single τs]
      · have hτ : ∀ i, i ∉ T → τs i = s0 i := fun i hi => by simp [τs, anchorMerge, hi]
        have hind : dIndMono T τs y = 1 := by
          unfold dIndMono
          refine Finset.prod_eq_one fun i hi => ?_
          simp [τs, anchorMerge, hi]
        rw [if_pos hτ, hind, mul_one]
        exact anchorComp_dependsOn F s0 T y τs
          (fun i hi => by simp [τs, anchorMerge, hi])
      · intro τ _ hne
        by_cases hτ : ∀ i, i ∉ T → τ i = s0 i
        · have : dIndMono T τ y = 0 := by
            unfold dIndMono
            obtain ⟨i, hi⟩ : ∃ i, τ i ≠ τs i := by
              by_contra hcon
              push_neg at hcon
              exact hne (funext hcon)
            have hiT : i ∈ T := by
              by_contra hiT
              exact hi (by rw [hτ i hiT]; simp [τs, anchorMerge, hiT])
            refine Finset.prod_eq_zero hiT ?_
            have : y i ≠ τ i := by
              intro h
              exact hi (by rw [← h]; simp [τs, anchorMerge, hiT])
            simp [this]
          rw [this, mul_zero]
        · rw [if_neg hτ, zero_mul]
      · intro h; exact absurd (Finset.mem_univ _) h

/-! ## The pair form of the influence equals the heat-bath residual energy -/

/-- Exchange the coordinate `j` of a word with a fresh letter. -/
def swapPair (j : κ) : (∀ i, β i) × β j ≃ (∀ i, β i) × β j where
  toFun z := (Function.update z.1 j z.2, z.1 j)
  invFun z := (Function.update z.1 j z.2, z.1 j)
  left_inv z := by
    obtain ⟨y, b⟩ := z
    simp
  right_inv z := by
    obtain ⟨y, b⟩ := z
    simp

theorem dMass_mul_swap (q : ∀ i, β i → ℝ) (y : ∀ i, β i) (j : κ) (b : β j) :
    dMass q y * q j b = dMass q (Function.update y j b) * q j (y j) := by
  unfold dMass
  rw [← Finset.mul_prod_erase univ _ (mem_univ j), ← Finset.mul_prod_erase univ _ (mem_univ j)]
  have hrest : ∏ i ∈ univ.erase j, q i (Function.update y j b i) =
      ∏ i ∈ univ.erase j, q i (y i) := by
    refine Finset.prod_congr rfl fun i hi => ?_
    rw [Function.update_of_ne (Finset.ne_of_mem_erase hi)]
  rw [hrest, Function.update_self]
  ring

theorem resample (q : ∀ i, β i → ℝ) (hq1 : ∀ i, ∑ b, q i b = 1) (j : κ)
    (K : (∀ i, β i) → ℝ) :
    ∑ y, ∑ b : β j, dMass q y * q j b * K (Function.update y j b) = ∑ y, dMass q y * K y := by
  have h1 : ∑ y, ∑ b : β j, dMass q y * q j b * K (Function.update y j b) =
      ∑ z : (∀ i, β i) × β j, dMass q (swapPair j z).1 * q j (swapPair j z).2 *
        K (swapPair j z).1 := by
    rw [← Finset.univ_product_univ, Finset.sum_product]
    refine Finset.sum_congr rfl fun y _ => Finset.sum_congr rfl fun b _ => ?_
    simp only [swapPair, Equiv.coe_fn_mk]
    rw [dMass_mul_swap q y j b]
  rw [h1, Equiv.sum_comp (swapPair j) (fun z => dMass q z.1 * q j z.2 * K z.1),
    ← Finset.univ_product_univ, Finset.sum_product]
  refine Finset.sum_congr rfl fun y _ => ?_
  dsimp only
  rw [← Finset.sum_mul, ← Finset.mul_sum, hq1, mul_one]

/-- `dinfl` equals the heat-bath residual energy. -/
theorem dinfl_eq_heatBath (q : ∀ i, β i → ℝ) (hq1 : ∀ i, ∑ b, q i b = 1)
    (F : (∀ i, β i) → ℝ) (j : κ) :
    dinfl q F j =
      ∑ y, dMass q y * (F y - ∑ b : β j, q j b * F (Function.update y j b)) ^ 2 := by
  set H : (∀ i, β i) → ℝ := fun y => ∑ b : β j, q j b * F (Function.update y j b) with hHdef
  have hH : ∀ y c, H (Function.update y j c) = H y := by
    intro y c
    simp only [hHdef, Function.update_idem]
  have hcenter : ∀ y, ∑ b : β j, q j b * (F (Function.update y j b) - H y) = 0 := by
    intro y
    simp only [mul_sub, Finset.sum_sub_distrib, ← Finset.sum_mul, hq1, one_mul, hHdef]
    ring
  have hpt : ∀ y, ∑ b : β j, q j b * (F y - F (Function.update y j b)) ^ 2 =
      (F y - H y) ^ 2 + ∑ b : β j, q j b * (F (Function.update y j b) - H y) ^ 2 := by
    intro y
    have e : ∀ b : β j, q j b * (F y - F (Function.update y j b)) ^ 2 =
        q j b * (F y - H y) ^ 2 - 2 * (F y - H y) * (q j b * (F (Function.update y j b) - H y)) +
          q j b * (F (Function.update y j b) - H y) ^ 2 := by
      intro b; ring
    simp only [e, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul,
      ← Finset.mul_sum, hcenter, hq1]
    ring
  have hres := resample q hq1 j (fun z => (F z - H z) ^ 2)
  simp only [hH] at hres
  unfold dinfl
  have e2 : ∀ y, ∑ b : β j, dMass q y * q j b * ((F y - F (Function.update y j b)) ^ 2 / 2) =
      dMass q y * (∑ b : β j, q j b * (F y - F (Function.update y j b)) ^ 2) / 2 := by
    intro y
    rw [Finset.mul_sum, Finset.sum_div]
    refine Finset.sum_congr rfl fun b _ => ?_
    ring
  simp only [e2, hpt]
  have e3 : ∀ y, dMass q y * ((F y - H y) ^ 2 + ∑ b : β j, q j b *
      (F (Function.update y j b) - H y) ^ 2) / 2 =
      (dMass q y * (F y - H y) ^ 2 + ∑ b : β j, dMass q y * q j b *
        (F (Function.update y j b) - H y) ^ 2) / 2 := by
    intro y
    rw [mul_add, Finset.mul_sum]
    congr 2
    refine Finset.sum_congr rfl fun b _ => ?_
    ring
  simp only [e3, ← Finset.sum_div, Finset.sum_add_distrib, hres]
  ring

end Nightfall.ProductSpace.MixedDifference
