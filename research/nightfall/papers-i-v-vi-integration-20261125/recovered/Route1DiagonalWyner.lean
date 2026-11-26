import Route1WynerGeneral

/-! #1150 exact diagonal common information.
Separate the support-to-Dirac argument from the entropy and infimum.
Uses the actual #970 general-latent definition, not mixture rank.
-/
namespace Nightfall.Route1Polylog

open Finset Real
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {I A : Type} [Fintype I] [DecidableEq I]
  [Fintype A] [DecidableEq A] [Nonempty A]

/-- Product support is a rectangle; a product law supported on the
duplicated-coordinate diagonal must be a point mass. -/
theorem diagonal_product_dirac (p : Sum I I → A → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (hdiag : ∀ x : Sum I I → A, 0 < prodMass p x →
      ∀ i, x (.inl i) = x (.inr i)) :
    ∃ x : Sum I I → A, ∀ y, prodMass p y = if y = x then 1 else 0 := by
  classical
  have hn : ∀ x : Sum I I → A, 0 ≤ prodMass p x := by
    intro x
    unfold prodMass
    exact Finset.prod_nonneg (fun i _ => hp0 i (x i))
  have ht := prodMass_total p hp1
  have hex : ∃ x : Sum I I → A, 0 < prodMass p x := by
    by_contra! h
    have hle : (∑ x : Sum I I → A, prodMass p x) ≤ 0 :=
      Finset.sum_nonpos (fun x _ => h x)
    linarith
  obtain ⟨x, hx⟩ := hex
  have hcoord (y : Sum I I → A) (hy : 0 < prodMass p y) (i : Sum I I) :
      0 < p i (y i) := by
    by_contra! h
    have hz : p i (y i) = 0 := le_antisymm h (hp0 i (y i))
    have hz' : prodMass p y = 0 := by
      unfold prodMass
      exact Finset.prod_eq_zero (mem_univ i) hz
    linarith
  have hunique (y : Sum I I → A) (hy : 0 < prodMass p y) : y = x := by
    let z : Sum I I → A := Sum.elim (fun i => x (.inl i)) (fun i => y (.inr i))
    have hz : 0 < prodMass p z := by
      unfold prodMass
      apply Finset.prod_pos
      intro i _
      cases i with
      | inl i => exact hcoord x hx (.inl i)
      | inr i => exact hcoord y hy (.inr i)
    funext i
    cases i with
    | inl i =>
      calc
        y (.inl i) = y (.inr i) := hdiag y hy i
        _ = x (.inl i) := (hdiag z hz i).symm
    | inr i =>
      calc
        y (.inr i) = x (.inl i) := (hdiag z hz i).symm
        _ = x (.inr i) := hdiag x hx i
  have hzero : ∀ y : Sum I I → A, y ≠ x → prodMass p y = 0 := by
    intro y hy
    by_contra h
    exact hy (hunique y (lt_of_le_of_ne (hn y) (Ne.symm h)))
  have hx1 : prodMass p x = 1 := by
    rw [Finset.sum_eq_single x (fun y _ hy => hzero y hy) (by simp)] at ht
    exact ht
  refine ⟨x, fun y => ?_⟩
  by_cases h : y = x
  · subst y; simp [hx1]
  · simp [h, hzero y h]

/-- A probability law supported on the duplicated-coordinate diagonal has
Wyner common information exactly equal to its Shannon entropy. -/
theorem diagonal_wyner_eq_entropy (ν : (Sum I I → A) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (hdiag : ∀ x, 0 < ν x → ∀ i, x (.inl i) = x (.inr i)) :
    wynerGen ν = Hent ν := by
  classical
  have hv : ∀ s ∈ wynerSet ν, s = Hent ν := by
    rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
    have he : ∀ θ, w θ * Hent (prodMass (Q θ)) = 0 := by
      intro θ
      rcases (hw0 θ).eq_or_lt with h | h
      · simp [← h]
      · have hs : ∀ x : Sum I I → A, 0 < prodMass (Q θ) x →
            ∀ i, x (.inl i) = x (.inr i) := by
          intro x hx
          have hle : w θ * prodMass (Q θ) x ≤ ν x := by
            rw [hν]
            exact Finset.single_le_sum
              (fun t _ => mul_nonneg (hw0 t)
                (Finset.prod_nonneg (fun j _ => hQ0 t j (x j)))) (mem_univ θ)
          exact hdiag x (lt_of_lt_of_le (mul_pos h hx) hle)
        obtain ⟨x,hx⟩ := diagonal_product_dirac (Q θ) (hQ0 θ) (hQ1 θ) hs
        have hH : Hent (prodMass (Q θ)) = 0 := by
          unfold Hent
          apply Finset.sum_eq_zero
          intro y _
          rw [hx]
          split_ifs <;> simp
        simp [hH]
    rw [mutInfo_eq Q hQ1 w hw1]
    have hm : (fun x => ∑ θ, w θ * prodMass (Q θ) x) = ν :=
      funext (fun x => (hν x).symm)
    rw [hm, Finset.sum_eq_zero (fun θ _ => he θ), sub_zero]
  have hne := wynerSet_nonempty ν hν0 hν1
  obtain ⟨s,hs⟩ := hne
  have he : wynerSet ν = {Hent ν} := by
    ext v
    constructor
    · intro h; exact Set.mem_singleton_iff.mpr (hv v h)
    · intro h
      have hvs : v = s := (Set.mem_singleton_iff.mp h).trans (hv s hs).symm
      simpa only [hvs] using hs
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  rw [he, csInf_singleton]

/-- Every normalized product source has zero general-latent Wyner
information: one component attains zero and information is nonnegative. -/
theorem product_wyner_zero (p : I → A → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1) :
    wynerGen (prodMass p) = 0 := by
  classical
  have hzero : (0 : ℝ) ∈ wynerSet (prodMass p) := by
    refine ⟨1, fun _ => 1, fun _ => p, fun _ => by norm_num, by simp,
      fun _ => hp0, fun _ => hp1, ?_, ?_⟩
    · intro x; simp
    · rw [mutInfo_eq (fun _ : Fin 1 => p) (fun _ => hp1) (fun _ => 1) (by simp)]
      simp
  have hnonneg : ∀ s ∈ wynerSet (prodMass p), 0 ≤ s := by
    rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,_,rfl⟩
    have hk : 0 < k := by
      rcases Nat.eq_zero_or_pos k with h | h
      · subst k; simp at hw1
      · exact h
    letI : Nonempty (Fin k) := ⟨⟨0,hk⟩⟩
    rw [← info_empty]
    exact info_nonneg Q hQ0 hQ1 _ ∅ w rfl hw0
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_antisymm
  · exact csInf_le ⟨0, hnonneg⟩ hzero
  · exact le_csInf ⟨0,hzero⟩ hnonneg

/-- Explicit pairing equivalence for the two blocks. -/
def diagonalPairEquiv : (Sum I I → A) ≃ (I → A) × (I → A) where
  toFun x := (fun i => x (.inl i), fun i => x (.inr i))
  invFun x := Sum.elim x.1 x.2
  left_inv x := by funext i; cases i <;> rfl
  right_inv x := by rcases x with ⟨x,y⟩; rfl

/-- Uniform law on duplicated words, with literal zero off diagonal. -/
noncomputable def uniformDiagonal : (Sum I I → A) → ℝ := by
  classical
  exact fun x => if (fun i => x (Sum.inl i)) = (fun i => x (Sum.inr i))
    then 1 / (Fintype.card (I → A) : ℝ) else 0

theorem uniformDiagonal_normalized :
    (∑ x : Sum I I → A, uniformDiagonal x) = 1 := by
  classical
  rw [← Equiv.sum_comp (diagonalPairEquiv (I := I) (A := A)).symm uniformDiagonal]
  rw [Fintype.sum_prod_type]
  have h : (Fintype.card (I → A) : ℝ) ≠ 0 := by positivity
  simp [uniformDiagonal, diagonalPairEquiv, Finset.sum_ite_eq, h] <;> field_simp [h]

theorem uniformDiagonal_entropy :
    Hent (uniformDiagonal (I := I) (A := A)) = Real.log (Fintype.card (I → A)) := by
  classical
  unfold Hent
  rw [← Equiv.sum_comp (diagonalPairEquiv (I := I) (A := A)).symm
    (fun x => negMulLog (uniformDiagonal x))]
  rw [Fintype.sum_prod_type]
  have h : (Fintype.card (I → A) : ℝ) ≠ 0 := by positivity
  simp [uniformDiagonal, diagonalPairEquiv, apply_ite negMulLog, Finset.sum_ite_eq,
    negMulLog_zero, negMulLog, Real.log_inv, one_div, h] <;> field_simp [h] <;> ring

/-- Actual #970 general-latent C_W, in nats, for N duplicated fair bits. -/
theorem fair_bit_diagonal_wyner (N : ℕ) :
    wynerGen (uniformDiagonal (I := Fin N) (A := Bool)) = (N : ℝ) * Real.log 2 := by
  classical
  rw [diagonal_wyner_eq_entropy]
  · rw [uniformDiagonal_entropy]
    simp [Fintype.card_fun, Real.log_pow]
  · intro x
    unfold uniformDiagonal
    split_ifs <;> positivity
  · exact uniformDiagonal_normalized
  · intro x hx i
    unfold uniformDiagonal at hx
    split_ifs at hx with h
    · exact congrFun h i
    · linarith

theorem fair_bit_product_wyner (N : ℕ) :
    wynerGen (prodMass (fun (_ : Fin N) (_ : Bool) => (1/2 : ℝ))) = 0 := by
  apply product_wyner_zero
  · intro i a; norm_num
  · intro i; norm_num [Fintype.sum_bool]

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.diagonal_product_dirac
#print axioms Nightfall.Route1Polylog.diagonal_wyner_eq_entropy
#print axioms Nightfall.Route1Polylog.product_wyner_zero
#print axioms Nightfall.Route1Polylog.fair_bit_diagonal_wyner
#print axioms Nightfall.Route1Polylog.fair_bit_product_wyner
