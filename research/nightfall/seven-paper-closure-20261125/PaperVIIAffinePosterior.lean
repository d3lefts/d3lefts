import Mathlib

/-! Prospectus Appendix A.2, Theorem B: exact adaptive leaf geometry.
The actual causal path is represented by a finite tree of linear readings.
Equality of full transcripts is equivalent to the difference of two secrets
annihilating the span of that path's labels, without assuming a fixed tree
of labels. This establishes the affine-fiber statement, not yet its uniform
restriction probabilities or the touched-block rank bound. -/
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
    rw [LinearMap.mem_ker]
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
end Nightfall.PaperVIIAffinePosterior
