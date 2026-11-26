import Mathlib

/-! Prospectus Appendix A.2, Theorem B: exact adaptive leaf geometry.
The actual causal path is represented by a finite tree of linear readings.
Equality of full transcripts is equivalent to the difference of two secrets
annihilating the span of that path's labels, without assuming a fixed tree
of labels. The continuation below targets equal conditional restriction counts and the
touched-block dimension bound. Acceptance requires a new exact-head kernel receipt. -/
namespace Nightfall.PaperVIIAffinePosterior
variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
abbrev Secret (K V : Type*) [Field K] [AddCommGroup V] [Module K V] := V →ₗ[K] K

inductive Tree (K V : Type*) where
  | leaf : Tree K V
  | query : V → (K → Tree K V) → Tree K V

def trace : Tree K V → Secret K V → List (V × K)
  | .leaf, _ => []
  | .query a next, s => (a, s a) :: trace (next (s a)) s

theorem trace_consistent (t : Tree K V) (s : Secret K V)
    (p : V × K) (hp : p ∈ trace t s) : s p.1 = p.2 := by
  induction t generalizing s p with
  | leaf => simp [trace] at hp
  | query a next ih =>
    simp only [trace, List.mem_cons] at hp
    rcases hp with h | h
    · subst p
      rfl
    · exact ih (s a) s p h

theorem trace_eq_iff (t : Tree K V) (s r : Secret K V) :
    trace t r = trace t s ↔ ∀ p ∈ trace t s, r p.1 = p.2 := by
  induction t generalizing s r with
  | leaf => simp [trace]
  | query a next ih =>
    constructor
    · intro h p hp
      change (a, r a) :: trace (next (r a)) r =
        (a, s a) :: trace (next (s a)) s at h
      obtain ⟨hh, ht⟩ := List.cons.inj h
      have he : r a = s a := congrArg Prod.snd hh
      rw [he] at ht
      simp only [trace, List.mem_cons] at hp
      rcases hp with hp | hp
      · subst p
        exact he
      · exact (ih (s a) s r).mp ht p hp
    · intro h
      have he : r a = s a := h (a,s a) (by simp [trace])
      have ht : trace (next (s a)) r = trace (next (s a)) s :=
        (ih (s a) s r).mpr (by
          intro p hp
          exact h p (by simp [trace, hp]))
      simp only [trace, he, ht]

def pathSpan (t : Tree K V) (s : Secret K V) : Submodule K V :=
  Submodule.span K {a | ∃ b, (a,b) ∈ trace t s}

/-- The attainable leaf fiber is the affine annihilator translate
s + (pathSpan t s).dualAnnihilator, expressed as a kernel inclusion. -/
theorem trace_eq_iff_annihilator (t : Tree K V) (s r : Secret K V) :
    trace t r = trace t s ↔ pathSpan t s ≤ (r - s).ker := by
  rw [trace_eq_iff]
  constructor
  · intro h
    apply Submodule.span_le.mpr
    rintro a ⟨b,hb⟩
    apply LinearMap.mem_ker.mpr
    change r a - s a = 0
    exact sub_eq_zero.mpr ((h (a,b) hb).trans (trace_consistent t s (a,b) hb).symm)
  · intro h p hp
    have ha : p.1 ∈ pathSpan t s := Submodule.subset_span
      (show p.1 ∈ {a | ∃ b, (a,b) ∈ trace t s} from
        ⟨p.2, by simpa only [Prod.eta] using hp⟩)
    have hk : (r - s) p.1 = 0 := LinearMap.mem_ker.mp (h ha)
    change r p.1 - s p.1 = 0 at hk
    exact (sub_eq_zero.mp hk).trans (trace_consistent t s p hp)

#print axioms trace_consistent
#print axioms trace_eq_iff
#print axioms trace_eq_iff_annihilator

/-- Every functional on an untouched block extends to a functional
annihilating the actual transcript span. No posterior premise is assumed. -/
theorem untouched_lift (W U : Submodule K V) (hd : Disjoint W U)
    (z : Secret K U) : ∃ d : Secret K V, W ≤ d.ker ∧ U.dualRestrict d = z := by
  let f : U →ₗ[K] V ⧸ W := W.mkQ.comp U.subtype
  have hf : f.ker = ⊥ := by
    apply le_antisymm
    · intro u hu
      have hq : W.mkQ (u : V) = 0 := LinearMap.mem_ker.mp hu
      have hw : (u : V) ∈ W := by
        exact (Submodule.Quotient.mk_eq_zero W).mp hq
      have hz : (u : V) = 0 := by
        have hmem : (u : V) ∈ W ⊓ U := ⟨hw,u.property⟩
        have hh : W ⊓ U = ⊥ := disjoint_iff.mp hd
        rw [hh] at hmem
        simpa using hmem
      exact Submodule.mem_bot.mpr (Subtype.ext hz)
    · exact bot_le
  obtain ⟨g,hg⟩ := f.exists_leftInverse_of_injective hf
  let d : Secret K V := z.comp (g.comp W.mkQ)
  refine ⟨d, ?_, ?_⟩
  · intro v hv
    apply LinearMap.mem_ker.mpr
    have hq : W.mkQ v = 0 := (Submodule.Quotient.mk_eq_zero W).mpr hv
    change z (g (W.mkQ v)) = 0
    rw [hq, map_zero, map_zero]
  · ext u
    have hgu : g (W.mkQ (u : V)) = u := DFunLike.congr_fun hg u
    change z (g (W.mkQ (u : V))) = z u
    rw [hgu]

/-- Actual adaptive leaf, with a prescribed restriction. -/
abbrev RestrictionFiber (t : Tree K V) (s : Secret K V) (U : Submodule K V)
    (z : Secret K U) :=
  {r : Secret K V // trace t r = trace t s ∧ U.dualRestrict r = z}

/-- Translation bijection between any two restrictions of an untouched block.
The equality of cardinalities is exact, including nonuniform path lengths. -/
noncomputable def untouchedFiberEquiv (t : Tree K V) (s : Secret K V)
    (U : Submodule K V) (hd : Disjoint (pathSpan t s) U)
    (z w : Secret K U) : RestrictionFiber t s U z ≃ RestrictionFiber t s U w := by
  classical
  let h := untouched_lift (pathSpan t s) U hd (w-z)
  let d := Classical.choose h
  have hdker := (Classical.choose_spec h).1
  have hdres := (Classical.choose_spec h).2
  have hshift (r : Secret K V) (hr : trace t r = trace t s) :
      trace t (r+d) = trace t s := by
    apply (trace_eq_iff_annihilator t s (r+d)).mpr
    intro x hx
    have hr0 := LinearMap.mem_ker.mp ((trace_eq_iff_annihilator t s r).mp hr hx)
    have hd0 := LinearMap.mem_ker.mp (hdker hx)
    apply LinearMap.mem_ker.mpr
    change r x + d x - s x = 0
    change r x - s x = 0 at hr0
    rw [hd0, add_zero, hr0]
  have hback (r : Secret K V) (hr : trace t r = trace t s) :
      trace t (r-d) = trace t s := by
    apply (trace_eq_iff_annihilator t s (r-d)).mpr
    intro x hx
    have hr0 := LinearMap.mem_ker.mp ((trace_eq_iff_annihilator t s r).mp hr hx)
    have hd0 := LinearMap.mem_ker.mp (hdker hx)
    apply LinearMap.mem_ker.mpr
    change r x - d x - s x = 0
    change r x - s x = 0 at hr0
    rw [hd0, sub_zero, hr0]
  refine {
    toFun := fun r => ⟨r.1+d, hshift r.1 r.2.1, ?_⟩
    invFun := fun r => ⟨r.1-d, hback r.1 r.2.1, ?_⟩
    left_inv := ?_
    right_inv := ?_ }
  · rw [map_add, r.2.2, hdres]
    abel
  · rw [map_sub, r.2.2, hdres]
    abel
  · intro r
    apply Subtype.ext
    simp
  · intro r
    apply Subtype.ext
    simp

theorem untouched_equal_counts (t : Tree K V) (s : Secret K V)
    (U : Submodule K V) (hd : Disjoint (pathSpan t s) U)
    (z w : Secret K U) :
    Nat.card (RestrictionFiber t s U z) = Nat.card (RestrictionFiber t s U w) :=
  Nat.card_congr (untouchedFiberEquiv t s U hd z w)

/-- Each block with nonzero intersection consumes a dimension of W, because
the original block family is independent, not merely pairwise disjoint. -/
theorem touched_rank_bound {ι : Type*} [Fintype ι] [Module.Finite K V]
    (W : Submodule K V) (U : ι → Submodule K V) (hU : iSupIndep U) :
    Nat.card {i : ι // W ⊓ U i ≠ ⊥} ≤ Module.finrank K W := by
  classical
  let B : ι → Submodule K W := fun i => (U i).comap W.subtype
  have hB : iSupIndep B := by
    intro i
    apply disjoint_iff_inf_le.mpr
    intro x hx
    have hi : (x : V) ∈ U i := hx.1
    have hle : (⨆ j, ⨆ (_ : j ≠ i), B j) ≤
        (⨆ j, ⨆ (_ : j ≠ i), U j).comap W.subtype := by
      refine iSup_le fun j => iSup_le fun hj => ?_
      exact Submodule.comap_mono (le_iSup_of_le j (le_iSup_of_le hj le_rfl))
    have hj : (x : V) ∈ (⨆ j, ⨆ (_ : j ≠ i), U j) := hle hx.2
    have hmem : (x : V) ∈ U i ⊓ (⨆ j, ⨆ (_ : j ≠ i), U j) := ⟨hi,hj⟩
    rw [disjoint_iff.mp (hU i)] at hmem
    exact Submodule.mem_bot.mpr (Subtype.ext (Submodule.mem_bot.mp hmem))
  have hnb (i : ι) : W ⊓ U i ≠ ⊥ → B i ≠ ⊥ := by
    intro h hbot
    apply h
    apply le_antisymm
    · intro v hv
      have hx : (⟨v,hv.1⟩ : W) ∈ B i := hv.2
      rw [hbot] at hx
      have hz : (⟨v,hv.1⟩ : W) = 0 := Submodule.mem_bot.mp hx
      exact Submodule.mem_bot.mpr (congrArg Subtype.val hz)
    · exact bot_le
  let f : {i : ι // W ⊓ U i ≠ ⊥} → {i : ι // B i ≠ ⊥} :=
    fun i => ⟨i.1,hnb i.1 i.2⟩
  have hf : Function.Injective f := by
    intro a b hab
    exact Subtype.ext (congrArg Subtype.val hab)
  letI : Fintype {i : ι // W ⊓ U i ≠ ⊥} := Fintype.ofFinite _
  letI : Fintype {i : ι // B i ≠ ⊥} := Fintype.ofFinite _
  rw [Nat.card_eq_fintype_card]
  exact (Fintype.card_le_of_injective f hf).trans hB.subtype_ne_bot_le_finrank

/-- The span of the realized adaptive path is bounded by its actual length. -/
theorem pathSpan_rank_le_length (t : Tree K V) (s : Secret K V) :
    Module.finrank K (pathSpan t s) ≤ (trace t s).length := by
  classical
  let S := ((trace t s).map Prod.fst).toFinset
  have hS : (↑S : Set V) = {a | ∃ b, (a,b) ∈ trace t s} := by
    ext a
    constructor
    · intro ha
      have hm : a ∈ (trace t s).map Prod.fst := List.mem_toFinset.mp ha
      obtain ⟨p,hp,he⟩ := List.mem_map.mp hm
      exact ⟨p.2, by simpa only [← he, Prod.eta] using hp⟩
    · rintro ⟨b,hb⟩
      exact List.mem_toFinset.mpr (List.mem_map.mpr ⟨(a,b),hb,rfl⟩)
  unfold pathSpan
  rw [← hS]
  exact (finrank_span_finset_le_card S).trans (by
    simpa [S] using (List.toFinset_card_le ((trace t s).map Prod.fst)))

#print axioms untouched_lift
#print axioms untouched_equal_counts
#print axioms touched_rank_bound
#print axioms pathSpan_rank_le_length


/-- Full leaf is the product of the block dual and one fixed restriction
fiber. This exact cardinal identity is the uniform posterior probability
statement for a finite uniform prior. -/
noncomputable def untouchedLeafEquiv (t : Tree K V) (s : Secret K V)
    (U : Submodule K V) (hd : Disjoint (pathSpan t s) U)
    (z : Secret K U) :
    {r : Secret K V // trace t r = trace t s} ≃
      (Secret K U × RestrictionFiber t s U z) := by
  classical
  let e := fun w => untouchedFiberEquiv t s U hd w z
  refine {
    toFun := fun r => (U.dualRestrict r.1, e (U.dualRestrict r.1) ⟨r.1,r.2,rfl⟩)
    invFun := fun p => ⟨((e p.1).symm p.2).1, ((e p.1).symm p.2).2.1⟩
    left_inv := ?_
    right_inv := ?_ }
  · intro r
    apply Subtype.ext
    change (((e (U.dualRestrict r.1)).symm
      (e (U.dualRestrict r.1) ⟨r.1,r.2,rfl⟩)) : RestrictionFiber t s U
      (U.dualRestrict r.1)).1 = r.1
    rw [Equiv.symm_apply_apply]
  · rintro ⟨w,v⟩
    let a := (e w).symm v
    have ha : U.dualRestrict a.1 = w := a.2.2
    change (U.dualRestrict a.1, e (U.dualRestrict a.1) ⟨a.1,a.2.1,rfl⟩) = (w,v)
    have hh : ∀ (w' : Secret K U) (hw' : U.dualRestrict a.1 = w'),
        (U.dualRestrict a.1, e (U.dualRestrict a.1) ⟨a.1,a.2.1,rfl⟩) =
          (w', e w' ⟨a.1,a.2.1,hw'⟩) := by
      intro w' hw'
      cases hw'
      rfl
    rw [hh w ha]
    have heq : (⟨a.1,a.2.1,ha⟩ : RestrictionFiber t s U w) = a := Subtype.ext rfl
    rw [heq]
    simp [a]

theorem untouched_uniform_cardinality (t : Tree K V) (s : Secret K V)
    (U : Submodule K V) (hd : Disjoint (pathSpan t s) U) (z : Secret K U) :
    Nat.card {r : Secret K V // trace t r = trace t s} =
      Nat.card (Secret K U) * Nat.card (RestrictionFiber t s U z) := by
  rw [Nat.card_congr (untouchedLeafEquiv t s U hd z), Nat.card_prod]

theorem touched_path_bound {ι : Type*} [Fintype ι] [Module.Finite K V]
    (t : Tree K V) (s : Secret K V) (U : ι → Submodule K V) (hU : iSupIndep U) :
    Nat.card {i : ι // pathSpan t s ⊓ U i ≠ ⊥} ≤ (trace t s).length :=
  (touched_rank_bound (pathSpan t s) U hU).trans (pathSpan_rank_le_length t s)

#print axioms untouched_uniform_cardinality
#print axioms touched_path_bound

end Nightfall.PaperVIIAffinePosterior
