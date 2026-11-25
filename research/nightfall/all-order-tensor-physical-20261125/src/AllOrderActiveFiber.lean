import AllOrderHammingBall
import AllOrderAnchor
import Mathlib.Combinatorics.SimpleGraph.Connectivity.Finite

namespace Nightfall.AllOrder.Geometry
open Finset
variable {J K : Type*} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

abbrev Row (J K : Type*) := J → NonzeroFactor K
abbrev Tensor (J K : Type*) := (J → K) → ZMod 2

def tensorLabel (u : Row J K) : Tensor J K := coordTensor (fun _ : Unit => u) ()

theorem tensorLabel_eq (f : I → Row J K) (i : I) : tensorLabel (f i) = coordTensor f i := rfl

/-- Conservative radius for all circuits on at most 2d slots. -/
def circuitRadius (s d : ℕ) : ℕ := (2*d+1)*(s+1)^(2*d)

theorem short_circuit_near {I : Type*} [Fintype I] [DecidableEq I]
    (f : I → Row J K) (d : ℕ) (hd : Fintype.card I ≤ 2*d) (E : Finset I)
    (hm : MinimalZero (fun i => tensorLabel (f i)) E) (i j : I) (hi : i ∈ E) (hj : j ∈ E) :
    ham (f i) (f j) ≤ circuitRadius (Fintype.card (NonzeroFactor K)) d := by
  have h := circuit_hamming_bound f E hm i j hi hj
  have hc : E.card ≤ 2*d := (Finset.card_le_univ _).trans hd
  unfold circuitRadius
  apply h.trans
  apply Nat.mul_le_mul (by omega)
  calc
    _ ≤ (Fintype.card (NonzeroFactor K)+1)^E.card := Nat.pow_le_pow_left (Nat.le_succ _) _
    _ ≤ _ := Nat.pow_le_pow_right (by omega) hc

noncomputable def nearGraph {I : Type*} [DecidableEq I] (f : I → Row J K) (r : ℕ) : SimpleGraph I where
  Adj i j := i ≠ j ∧ ham (f i) (f j) ≤ r
  symm := by constructor; intro i j h; exact ⟨Ne.symm h.1, by rw [ham_symm]; exact h.2⟩
  loopless := by constructor; intro i h; exact h.1 rfl

/-- In a fixed r-near slot graph, an actual walk certifies a Hamming bound. -/
theorem walk_hamming {I : Type*} [DecidableEq I] (f : I → Row J K) (r : ℕ) {i j : I}
    (p : (nearGraph f r).Walk i j) : ham (f i) (f j) ≤ p.length*r := by
  induction p with
  | nil => simp [ham_refl]
  | @cons i k j h p ih =>
    have hh : ham (f i) (f k) ≤ r := h.2
    calc
      _ ≤ ham (f i) (f k) + ham (f k) (f j) := ham_triangle _ _ _
      _ ≤ r + p.length*r := Nat.add_le_add hh ih
      _ = _ := by simp [SimpleGraph.Walk.length, Nat.add_mul, Nat.add_comm]

theorem component_hamming {I : Type*} [Fintype I] [DecidableEq I] (f : I → Row J K) (r : ℕ) (i j : I)
    (h : (nearGraph f r).connectedComponentMk i = (nearGraph f r).connectedComponentMk j) :
    ham (f i) (f j) ≤ Fintype.card I*r := by
  obtain ⟨p,hp⟩ := (SimpleGraph.ConnectedComponent.exact h).exists_isPath
  exact (walk_hamming f r p).trans (Nat.mul_le_mul_right _ hp.length_lt.le)

theorem near_same_component {I : Type*} [DecidableEq I] (f : I → Row J K) (r : ℕ) (i j : I)
    (h : ham (f i) (f j) ≤ r) :
    (nearGraph f r).connectedComponentMk i = (nearGraph f r).connectedComponentMk j := by
  by_cases he : i = j
  · subst j; rfl
  · exact SimpleGraph.ConnectedComponent.sound (SimpleGraph.Adj.reachable (show (nearGraph f r).Adj i j from ⟨he,h⟩))

/-- Every component of an active tuple has a nonzero XOR. -/
noncomputable def activeGood {I : Type*} [Fintype I] [DecidableEq I] (f : I → Row J K) (r : ℕ) : Prop := by
  classical
  exact ∀ i : I, (∑ j ∈ univ.filter (fun j => (nearGraph f r).connectedComponentMk j =
      (nearGraph f r).connectedComponentMk i), tensorLabel (f j)) ≠ 0

theorem tensor_add_self (z : Tensor J K) : z+z=0 := by
  funext x
  change z x + z x = 0
  rcases zmod2_cases (z x) with h|h <;> rw [h] <;> decide

/-- Each actual active row is in a polynomial-size Hamming ball around one
    row of an arbitrary reference tuple of the same XOR frequency. -/
theorem active_row_near_reference {I H : Type*} [Fintype I] [DecidableEq I] [Fintype H] [DecidableEq H]
    (a : I → Row J K) (b : H → Row J K) (d : ℕ)
    (ha : Fintype.card I ≤ d) (hb : Fintype.card H ≤ d)
    (good : activeGood a (circuitRadius (Fintype.card (NonzeroFactor K)) d))
    (heq : (∑ i, tensorLabel (a i)) = ∑ j, tensorLabel (b j)) (i : I) :
    ∃ j : H, ham (a i) (b j) ≤ (d+1)*circuitRadius (Fintype.card (NonzeroFactor K)) d := by
  classical
  let r := circuitRadius (Fintype.card (NonzeroFactor K)) d
  let g := nearGraph a r
  let comp := g.connectedComponentMk
  let c := comp i
  have hlocal : ∀ E : Finset (I ⊕ H), MinimalZero (fun s => tensorLabel (Sum.elim a b s)) E →
      ∀ x ∈ E, ∀ y ∈ E, ham (Sum.elim a b x) (Sum.elim a b y) ≤ r := by
    intro E hE x hx y hy
    apply short_circuit_near (Sum.elim a b) d _ E hE x y hx hy
    rw [Fintype.card_sum]
    omega
  have hz : (∑ i, tensorLabel (a i)) + (∑ j, tensorLabel (b j)) = 0 := by rw [heq, tensor_add_self]
  have hnonzero : (∑ j ∈ univ.filter (fun j => comp j = c), tensorLabel (a j)) ≠ 0 := good i
  obtain ⟨k,hk,j,hj⟩ := nonzero_component_anchor tensorLabel a b (fun u v => ham u v ≤ r) comp c hlocal
    (near_same_component a r) hz hnonzero
  refine ⟨j,?_⟩
  have hh := component_hamming a r i k hk.symm
  calc
    _ ≤ ham (a i) (a k) + ham (a k) (b j) := ham_triangle _ _ _
    _ ≤ Fintype.card I*r + r := Nat.add_le_add hh hj
    _ ≤ (d+1)*r := by rw [Nat.add_mul, Nat.one_mul]; exact Nat.add_le_add_right (Nat.mul_le_mul_right _ ha) _

#print axioms short_circuit_near
#print axioms walk_hamming
#print axioms component_hamming
#print axioms active_row_near_reference
end Nightfall.AllOrder.Geometry
