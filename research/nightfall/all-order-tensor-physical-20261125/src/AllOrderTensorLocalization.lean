import AllOrderGeometry
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Fintype.Card

namespace Nightfall.AllOrder.Geometry
open Finset

section Concrete
variable {K : Type*} [Fintype K] [DecidableEq K]

def NonzeroFactor (K : Type*) := {v : K → ZMod 2 // v ≠ 0}
instance : Fintype (NonzeroFactor K) := inferInstanceAs (Fintype {v : K → ZMod 2 // v ≠ 0})
instance : DecidableEq (NonzeroFactor K) := inferInstanceAs (DecidableEq {v : K → ZMod 2 // v ≠ 0})
def dot (a : NonzeroFactor K) (u : K → ZMod 2) : ZMod 2 := ∑ k, a.val k * u k

def probe (j : K) : K → ZMod 2 := fun k => if k = j then 1 else 0

theorem dot_probe (a : NonzeroFactor K) (j : K) : dot a (probe j) = a.val j := by
  classical
  unfold dot probe
  rw [Finset.sum_eq_single j]
  · simp
  · intro k _ hkj; simp [hkj]
  · simp

theorem dot_add (a : NonzeroFactor K) (u v : K → ZMod 2) : dot a (u+v) = dot a u + dot a v := by
  unfold dot
  simp only [Pi.add_apply, mul_add, Finset.sum_add_distrib]

theorem zmod2_cases (z : ZMod 2) : z = 0 ∨ z = 1 := by
  fin_cases z
  · exact Or.inl rfl
  · exact Or.inr rfl

theorem nonzero_has_one (a : NonzeroFactor K) : ∃ k, a.val k = 1 := by
  by_contra h
  push_neg at h
  apply a.property
  funext k
  exact (zmod2_cases (a.val k)).resolve_right (h k)

theorem concrete_factor_separation (a b : NonzeroFactor K) (hne : b ≠ a) :
    ∃ u : K → ZMod 2, dot a u = 1 ∧ dot b u = 0 := by
  obtain ⟨i,hi⟩ := nonzero_has_one a
  by_cases hbi : b.val i = 0
  · exact ⟨probe i, by rw [dot_probe,hi], by rw [dot_probe,hbi]⟩
  have hbi' := (zmod2_cases (b.val i)).resolve_left hbi
  have hj : ∃ j, a.val j ≠ b.val j := by
    by_contra h
    push_neg at h
    exact hne (Subtype.ext (funext fun j => (h j).symm))
  obtain ⟨j,hj⟩ := hj
  rcases zmod2_cases (a.val j) with haj | haj
  · have hbj : b.val j = 1 := (zmod2_cases (b.val j)).resolve_left (fun h => hj (haj.trans h.symm))
    refine ⟨probe i + probe j, ?_, ?_⟩
    · rw [dot_add, dot_probe, dot_probe, hi,haj]; decide
    · rw [dot_add, dot_probe, dot_probe, hbi',hbj]; decide
  · have hbj : b.val j = 0 := (zmod2_cases (b.val j)).resolve_right (fun h => hj (haj.trans h.symm))
    exact ⟨probe j, by rw [dot_probe,haj], by rw [dot_probe,hbj]⟩
end Concrete

section Count
variable {I J A U : Type*} [Fintype J] [DecidableEq J] [DecidableEq I] [DecidableEq A] [Fintype A]

/-- The exact set of sites at which a finite family of rows varies. -/
noncomputable def varyingSites (f : I → J → A) (E : Finset I) : Finset J := by
  classical
  exact univ.filter (fun j => ∃ i ∈ E, ∃ k ∈ E, f i j ≠ f k j)

/-- A pattern on the members of a circuit. -/
def pattern (f : I → J → A) (E : Finset I) (j : J) : E → A := fun i => f i.val j

/-- A varying pattern cannot occupy at least as many sites as the circuit has
    rows, because repeated sites would separate one proper nonempty class. -/
theorem varying_pattern_fiber_lt (f : I → J → A) (pair : A → U → ZMod 2)
    (E : Finset I) (sep : ∀ a b, b ≠ a → ∃ u, pair a u = 1 ∧ pair b u = 0)
    (hm : MinimalZero (evalTensor f pair) E) (p : E → A) :
    ((varyingSites f E).filter (fun j => pattern f E j = p)).card < E.card := by
  classical
  let S := (varyingSites f E).filter (fun j => pattern f E j = p)
  by_contra! hle
  have hne : S.Nonempty := Finset.card_pos.mp (lt_of_lt_of_le (Finset.card_pos.mpr hm.1) hle)
  obtain ⟨j₀,hj₀⟩ := hne
  let inj : E → S := fun i => S.equivFin.symm (Fin.castLE hle (E.equivFin i))
  have hinj0 : Function.Injective inj := by
    intro i k h
    have h' := S.equivFin.symm.injective h
    exact E.equivFin.injective (Fin.ext (show (E.equivFin i).val = (E.equivFin k).val from congrArg (fun t : Fin S.card => t.val) h'))
  let e : I → J := fun i => if hi : i ∈ E then (inj ⟨i,hi⟩).val else j₀
  have he (i : I) (hi : i ∈ E) : e i = (inj ⟨i,hi⟩).val := by simp [e,hi]
  have hs (i : I) (hi : i ∈ E) : e i ∈ S := by rw [he i hi]; exact (inj ⟨i,hi⟩).property
  have hinj : Set.InjOn e ↑E := by
    intro i hi k hk h
    have h' : inj ⟨i,hi⟩ = inj ⟨k,hk⟩ := Subtype.ext (by simpa only [he i hi,he k hk] using h)
    exact congrArg Subtype.val (hinj0 h')
  have hpat : ∀ i ∈ E, ∀ k ∈ E, f i (e k) = f i j₀ := by
    intro i hi k hk
    have h1 := (Finset.mem_filter.mp (hs k hk)).2
    have h2 := (Finset.mem_filter.mp hj₀).2
    exact congrFun (h1.trans h2.symm) ⟨i,hi⟩
  have hall := minimal_pattern_constant f pair E j₀ e sep hpat hinj hm
  have hj := (Finset.mem_filter.mp hj₀).1
  obtain ⟨i,hi,k,hk,hne⟩ := Finset.mem_filter.mp hj |>.2
  exact hne (hall i hi k hk)

/-- Elementary (not sharp) unconditional polynomial-localization input:
    at most (n-1) * |A|^n varying tensor sites for a minimal n-row circuit.
    No external tensor splitting theorem enters this bound. -/
theorem minimal_varying_site_bound (f : I → J → A) (pair : A → U → ZMod 2)
    (E : Finset I) (sep : ∀ a b, b ≠ a → ∃ u, pair a u = 1 ∧ pair b u = 0)
    (hm : MinimalZero (evalTensor f pair) E) :
    (varyingSites f E).card ≤ (E.card - 1) * (Fintype.card A)^E.card := by
  classical
  let S := varyingSites f E
  have hsum : (∑ p : E → A, (S.filter (fun j => pattern f E j = p)).card) = S.card := by
    have h := Finset.sum_fiberwise_eq_sum_filter S (univ : Finset (E → A)) (pattern f E) (fun _ => (1 : ℕ))
    simpa using h
  calc
    S.card = ∑ p : E → A, (S.filter (fun j => pattern f E j = p)).card := hsum.symm
    _ ≤ ∑ _ : E → A, (E.card-1) := Finset.sum_le_sum (fun p _ => Nat.le_sub_one_of_lt (varying_pattern_fiber_lt f pair E sep hm p))
    _ = _ := by simp [Fintype.card_fun, Nat.mul_comm]
end Count

/-- Specialization to actual nonzero binary local factors and their dot tests. -/
theorem binary_tensor_varying_site_bound {I J K : Type*} [Fintype J] [DecidableEq J]
    [DecidableEq I] [Fintype K] [DecidableEq K]
    (f : I → J → NonzeroFactor K) (E : Finset I) (hm : MinimalZero (evalTensor f dot) E) :
    (varyingSites f E).card ≤ (E.card-1)*(Fintype.card (NonzeroFactor K))^E.card :=
  minimal_varying_site_bound f dot E concrete_factor_separation hm

#print axioms concrete_factor_separation
#print axioms varying_pattern_fiber_lt
#print axioms minimal_varying_site_bound
#print axioms binary_tensor_varying_site_bound
end Nightfall.AllOrder.Geometry
