import Route1WynerGeneral
import Route1StaticObstruction
import Route1RecoveryEntropy
import Route1OrthogonalCorrelation
import Route1FiniteEntropyProjection

/-! Source-exact terminal composition with #970's general-latent Wyner
information. No alternate definition of information, finite mixture rank,
or custom axiom is introduced. -/
namespace Nightfall.Route1Polylog

open Finset Real
open Nightfall.ProductSpace.Mixture
open Nightfall.Route1StaticObstruction
open Nightfall.Route1RecoveryEntropy

variable {J A : Type} [Fintype J] [DecidableEq J]
  [Fintype A] [DecidableEq A] [Nonempty A]

/-- A uniform componentwise entropy upper bound gives a lower bound for
the actual general-latent common information. This uses #970's proven
finite/general equivalence, not an assumption on the size of the latent. -/
theorem wynerGen_lower_of_component_entropy
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (K : ℝ)
    (hK : ∀ p : J → A → ℝ, (∀ j a, 0 ≤ p j a) →
      (∀ j, ∑ a, p j a = 1) →
      (∀ z, 0 < prodMass p z → 0 < ν z) →
      Hent (prodMass p) ≤ K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
  rw [mutInfo_eq Q hQ1 w hw1]
  have hm : (fun z => ∑ θ, w θ * prodMass (Q θ) z) = ν :=
    funext (fun z => (hν z).symm)
  rw [hm]
  have he : ∑ θ, w θ * Hent (prodMass (Q θ)) ≤ K := by
    calc
      _ ≤ ∑ θ, w θ * K := by
        apply Finset.sum_le_sum
        intro θ _
        rcases (hw0 θ).eq_or_lt with h | h
        · simp [← h]
        · apply mul_le_mul_of_nonneg_left _ (hw0 θ)
          apply hK (Q θ) (hQ0 θ) (hQ1 θ)
          intro z hz
          have hle : w θ * prodMass (Q θ) z ≤ ν z := by
            rw [hν]
            exact Finset.single_le_sum
              (fun t _ => mul_nonneg (hw0 t)
                (Finset.prod_nonneg (fun j _ => hQ0 t j (z j)))) (mem_univ θ)
          exact lt_of_lt_of_le (mul_pos h hz) hle
      _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
  linarith

/-- More general entropy-budget version, needed for the TV-robust code
argument and orthogonal correlation, where the bound is on the average
rather than on each component separately. -/
theorem wynerGen_lower_of_average_entropy
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (K : ℝ)
    (hK : ∀ (k : ℕ) (w : Fin k → ℝ) (Q : Fin k → J → A → ℝ),
      (∀ θ, 0 ≤ w θ) → (∑ θ, w θ = 1) →
      (∀ θ j a, 0 ≤ Q θ j a) → (∀ θ j, ∑ a, Q θ j a = 1) →
      (∀ z, ν z = ∑ θ, w θ * prodMass (Q θ) z) →
      ∑ θ, w θ * Hent (prodMass (Q θ)) ≤ K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
  rw [mutInfo_eq Q hQ1 w hw1]
  have hm : (fun z => ∑ θ, w θ * prodMass (Q θ) z) = ν :=
    funext (fun z => (hν z).symm)
  rw [hm]
  have he := hK k w Q hw0 hw1 hQ0 hQ1 hν
  linarith

/-- Actual product mass positivity is equivalent to membership in the
coordinate-support rectangle, including zero atoms. -/
theorem prodMass_pos_iff_box (p : J → A → ℝ)
    (hp0 : ∀ j a, 0 ≤ p j a) (z : J → A) :
    0 < prodMass p z ↔ z ∈ box (fun j => univ.filter (fun a => 0 < p j a)) := by
  classical
  constructor
  · intro hz j
    apply mem_filter.mpr
    refine ⟨mem_univ _, ?_⟩
    by_contra! h
    have he : p j (z j) = 0 := le_antisymm h (hp0 j (z j))
    have hzero : prodMass p z = 0 := by
      unfold prodMass
      exact Finset.prod_eq_zero (mem_univ j) he
    linarith
  · intro hz
    unfold prodMass
    exact Finset.prod_pos (fun j _ => (mem_filter.mp (hz j)).2)

/-- The exact entropy bound on a genuine product mass supported by a
finite rectangle. This theorem counts the rectangle directly. -/
theorem product_entropy_le_log_support (p : J → A → ℝ)
    (hp0 : ∀ j a, 0 ≤ p j a) (hp1 : ∀ j, ∑ a, p j a = 1)
    (L : ℕ) (hL : (univ.filter (fun z => 0 < prodMass p z)).card ≤ L) :
    Hent (prodMass p) ≤ Real.log (L : ℝ) := by
  classical
  let S : Finset (J → A) := univ.filter (fun z => 0 < prodMass p z)
  have hnonneg : ∀ z, 0 ≤ prodMass p z :=
    fun z => Finset.prod_nonneg (fun j _ => hp0 j (z j))
  have hzero : ∀ z ∉ S, prodMass p z = 0 := by
    intro z hz
    have hn : ¬ 0 < prodMass p z := by simpa [S] using hz
    exact le_antisymm (le_of_not_gt hn) (hnonneg z)
  have hm : ∑ z ∈ S, prodMass p z = 1 := by
    rw [← prodMass_total p hp1]
    exact Finset.sum_subset (subset_univ _) (fun z _ hz => hzero z hz)
  have hs : S.Nonempty := by
    by_contra hn
    have he : S = ∅ := Finset.not_nonempty_iff_eq_empty.mp hn
    simp [he] at hm
  have he : Hent (prodMass p) = ∑ z ∈ S, negMulLog (prodMass p z) := by
    unfold Hent
    symm
    exact Finset.sum_subset (subset_univ _) (fun z _ hz => by simp [hzero z hz])
  rw [he]
  have hpos : (0 : ℝ) < S.card := Nat.cast_pos.mpr (Finset.card_pos.mpr hs)
  exact (support_entropy_le S hs _ (fun z _ => hnonneg z) hm).trans
    (Real.log_le_log hpos (by exact_mod_cast hL))

/-- A literal general-latent static obstruction from a proved
component support cardinality bound. The geometry-to-cardinality step
is separate, so this statement does not assume a mutual information
or Wyner inequality. -/
theorem static_wyner_cardinality_terminal
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (L : ℕ)
    (hL : ∀ p : J → A → ℝ, (∀ j a, 0 ≤ p j a) →
      (∀ j, ∑ a, p j a = 1) →
      (∀ z, 0 < prodMass p z → 0 < ν z) →
      (univ.filter (fun z => 0 < prodMass p z)).card ≤ L) :
    Hent ν - Real.log (L : ℝ) ≤ wynerGen ν := by
  apply wynerGen_lower_of_component_entropy ν hν0 hν1
  intro p hp0 hp1 hs
  exact product_entropy_le_log_support p hp0 hp1 L (hL p hp0 hp1 hs)


/-- Exact static representation obstruction for an arbitrary finite
latent alphabet, genuinely adaptive binary recovery, and the actual
general-latent Wyner infimum. The integer m bounds the number of active
axes via m+1 times the code distance exceeding the total incidence budget.
The source entropy remains explicit (e.g. k log 2 for a uniform 2^k code). -/
theorem exact_static_wyner
    {I : Type} [Fintype I] [DecidableEq I]
    (ν : (J → A) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (dep : I → Finset J) (Φ : (J → A) → I → Bool)
    (recover : J → BinaryRecovery I A) (r b D m : ℕ)
    (hb : ∀ i, (dep i).card ≤ b)
    (hbudget : Fintype.card I * b < (m + 1) * D)
    (hloc : ∀ i x y, (∀ j ∈ dep i, x j = y j) → Φ x i = Φ y i)
    (hrec : ∀ z, 0 < ν z → ∀ j, (recover j).eval (Φ z) = z j)
    (hr : ∀ z, 0 < ν z → ∀ j, (recover j).queries (Φ z) ≤ r)
    (hdist : ∀ x y, 0 < ν x → 0 < ν y → Φ x ≠ Φ y →
      D ≤ (diff (Φ x) (Φ y)).card) :
    Hent ν - (r * m : ℕ) * Real.log 2 ≤ wynerGen ν := by
  classical
  have hterminal : Hent ν - Real.log (((2 : ℕ) ^ (r * m)) : ℝ) ≤ wynerGen ν := by
    apply static_wyner_cardinality_terminal ν hν0 hν1
    intro p hp0 hp1 hs
    let S : J → Finset A := fun j => univ.filter (fun a => 0 < p j a)
    let T : Finset (J → A) := Fintype.piFinset S
    have hT : ∀ z, z ∈ T ↔ z ∈ box S := by
      intro z
      simp [T, box, Fintype.mem_piFinset]
    have hpos : ∀ z ∈ box S, 0 < ν z := fun z hz =>
      hs z ((prodMass_pos_iff_box p hp0 z).mpr hz)
    have hS : ∀ j, (S j).Nonempty := by
      intro j
      by_contra hn
      have hz : ∀ a, p j a = 0 := by
        intro a
        apply le_antisymm _ (hp0 j a)
        apply le_of_not_gt
        intro ha
        exact hn ⟨a, mem_filter.mpr ⟨mem_univ _, ha⟩⟩
      have he := hp1 j
      simp [hz] at he
    let z : J → A := fun j => (hS j).choose
    have hz : z ∈ box S := fun j => (hS j).choose_spec
    have hinj : Set.InjOn Φ (box S) := by
      intro x hx y hy he
      funext j
      rw [← hrec x (hpos x hx) j, ← hrec y (hpos y hy) j, he]
    have ha := active_count_bound dep Φ S z hz D b hb hloc hinj
      (fun x y hx hy hne => hdist x y (hpos x hx) (hpos y hy) hne)
    have ham : (active S).card ≤ m := by
      by_contra hn
      have hle : m + 1 ≤ (active S).card := by omega
      have hh := Nat.mul_le_mul_right D hle
      omega
    have hc : ∀ j, (S j).card ≤ 2 ^ r := by
      intro j
      let X := T.image Φ
      have hh : ∀ x ∈ X, (recover j).queries x ≤ r := by
        intro x hx
        obtain ⟨y,hy,rfl⟩ := mem_image.mp hx
        exact hr y (hpos y ((hT y).mp hy)) j
      apply (Finset.card_le_card (show S j ⊆ X.image (recover j).eval from ?_)).trans
        (BinaryRecovery.image_card_le (recover j) X r hh)
      intro a ha
      let y := Function.update z j a
      have hy : y ∈ box S := by
        intro l
        by_cases he : l = j
        · subst l
          simpa [y] using ha
        · simpa [y, Function.update_of_ne he] using hz l
      apply mem_image.mpr
      refine ⟨Φ y, mem_image.mpr ⟨y,(hT y).mpr hy,rfl⟩, ?_⟩
      rw [hrec y (hpos y hy) j]
      simp [y]
    have he : univ.filter (fun z => 0 < prodMass p z) = T := by
      ext y
      simpa only [mem_filter, mem_univ, true_and, hT] using
        (prodMass_pos_iff_box p hp0 y)
    rw [he, show T = Fintype.piFinset S from rfl, Fintype.card_piFinset]
    calc
      (∏ j, (S j).card) ≤ ∏ j : J, if j ∈ active S then 2 ^ r else 1 := by
        apply Finset.prod_le_prod'
        intro j _
        split_ifs with hj
        · exact hc j
        · have hh : ¬ 1 < (S j).card := by simpa [active] using hj
          omega
      _ = ∏ j ∈ active S, 2 ^ r := by
        unfold active
        rw [Finset.prod_filter]
      _ = 2 ^ (r * (active S).card) := by simp [pow_mul]
      _ ≤ 2 ^ (r * m) := by
        exact Nat.pow_le_pow_right (by decide) (Nat.mul_le_mul_left r ham)
  simpa only [Nat.cast_pow, Nat.cast_ofNat, Real.log_pow] using hterminal


/-- Source-level conditional analytic terminal for the exact and robust
orthogonal correlation bound. The two actual mutual-information marginal
bounds, correlation factorization, and squared-bias convexity remain
explicit obligations, not hidden axioms. The infimum is genuinely #970. -/
theorem orthogonal_wyner_of_marginal_entropy
    {I : Type} [Fintype I] [DecidableEq I] [Nonempty I]
    (ν : (Sum I I → Bool) → ℝ)
    (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (U : (I → ℝ) → (I → ℝ))
    (hU : ∀ b, Nightfall.Route1OrthogonalCorrelation.energy (U b) =
      Nightfall.Route1OrthogonalCorrelation.energy b)
    (c loss : ℝ) (hc : c ∈ Set.Icc (0 : ℝ) 1)
    (hconv : ConvexOn ℝ (Set.Icc (0 : ℝ) 1)
      Nightfall.Route1OrthogonalCorrelation.psi)
    (hmono : MonotoneOn Nightfall.Route1OrthogonalCorrelation.psi (Set.Icc (0 : ℝ) 1))
    (hdecomp : ∀ (k : ℕ) (w : Fin k → ℝ) (Q : Fin k → Sum I I → Bool → ℝ),
      (∀ θ, 0 ≤ w θ) → (∑ θ, w θ = 1) →
      (∀ θ j a, 0 ≤ Q θ j a) → (∀ θ j, ∑ a, Q θ j a = 1) →
      (∀ z, ν z = ∑ θ, w θ * prodMass (Q θ) z) →
      let a : Fin k → I → ℝ := fun θ i => Q θ (.inl i) true - Q θ (.inl i) false
      let b : Fin k → I → ℝ := fun θ i => Q θ (.inr i) true - Q θ (.inr i) false
      (∀ θ i, (a θ i)^2 ∈ Set.Icc (0 : ℝ) 1) ∧
      (∀ θ i, (b θ i)^2 ∈ Set.Icc (0 : ℝ) 1) ∧
      (Fintype.card I : ℝ) * c ≤
        (∑ θ, w θ * Nightfall.Route1OrthogonalCorrelation.score (a θ) (U (b θ))) ∧
      ((∑ θ, w θ * ∑ i, Nightfall.Route1OrthogonalCorrelation.psi ((a θ i)^2)) - loss ≤ mutInfo Q w) ∧
      ((∑ θ, w θ * ∑ i, Nightfall.Route1OrthogonalCorrelation.psi ((b θ i)^2)) - loss ≤ mutInfo Q w)) :
    (Fintype.card I : ℝ) * Nightfall.Route1OrthogonalCorrelation.psi c - loss ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
  let a : Fin k → I → ℝ := fun θ i => Q θ (.inl i) true - Q θ (.inl i) false
  let b : Fin k → I → ℝ := fun θ i => Q θ (.inr i) true - Q θ (.inr i) false
  obtain ⟨ha,hb,hscore,hma,hmb⟩ := hdecomp k w Q hw0 hw1 hQ0 hQ1 hν
  let N : ℝ := Fintype.card I
  have hN : 0 < N := Nat.cast_pos.mpr Fintype.card_pos
  let p : Fin k × I → ℝ := fun t => w t.1 / N
  have hp : ∀ t, 0 ≤ p t := fun t => div_nonneg (hw0 t.1) hN.le
  have hp1 : ∑ t, p t = 1 := by
    rw [Fintype.sum_prod_type]
    change ∑ θ : Fin k, ∑ _ : I, w θ / N = 1
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    have he : ∀ θ : Fin k, (Fintype.card I : ℝ) * (w θ / N) = w θ := by
      intro θ
      change N * (w θ / N) = w θ
      field_simp
    simp only [he, hw1]
  have hj (d : Fin k → I → ℝ)
      (hd : ∀ θ i, (d θ i)^2 ∈ Set.Icc (0 : ℝ) 1)
      (he : N * c ≤ ∑ θ, w θ * Nightfall.Route1OrthogonalCorrelation.energy (d θ))
      (hm : (∑ θ, w θ * ∑ i, Nightfall.Route1OrthogonalCorrelation.psi ((d θ i)^2)) - loss ≤ mutInfo Q w) :
      N * Nightfall.Route1OrthogonalCorrelation.psi c - loss ≤ mutInfo Q w := by
    let x : Fin k × I → ℝ := fun t => (d t.1 t.2)^2
    have hx : ∀ t, x t ∈ Set.Icc (0 : ℝ) 1 := fun t => hd t.1 t.2
    have hmean : (∑ t, p t * x t) =
        (∑ θ, w θ * Nightfall.Route1OrthogonalCorrelation.energy (d θ)) / N := by
      rw [Fintype.sum_prod_type, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro θ _
      unfold p x Nightfall.Route1OrthogonalCorrelation.energy
      rw [Finset.mul_sum, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro i _
      ring
    have hmem : (∑ t, p t * x t) ∈ Set.Icc (0 : ℝ) 1 := by
      constructor
      · exact Finset.sum_nonneg fun t _ => mul_nonneg (hp t) (hx t).1
      · calc
          _ ≤ ∑ t, p t * 1 := Finset.sum_le_sum fun t _ =>
            mul_le_mul_of_nonneg_left (hx t).2 (hp t)
          _ = 1 := by simp [hp1]
    have hle : c ≤ ∑ t, p t * x t := by
      rw [hmean]
      apply (le_div_iff₀ hN).2
      simpa [mul_comm] using he
    have hJ := Nightfall.Route1OrthogonalCorrelation.weighted_bias_jensen p x hp hp1 hx hconv
    have hψ := (hmono hc hmem hle).trans hJ
    have hsum : (∑ t, p t * Nightfall.Route1OrthogonalCorrelation.psi (x t)) =
        (∑ θ, w θ * ∑ i, Nightfall.Route1OrthogonalCorrelation.psi ((d θ i)^2)) / N := by
      rw [Fintype.sum_prod_type, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro θ _
      unfold p x
      rw [Finset.mul_sum, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [hsum] at hψ
    have hh := (le_div_iff₀ hN).mp hψ
    rw [mul_comm] at hh
    linarith
  rcases Nightfall.Route1OrthogonalCorrelation.one_block_energy U hU w hw0 a b (N*c) hscore with he | he
  · exact hj a ha he hma
  · exact hj b hb he hmb


/-- Split a two-block product law without redefining the source. -/
def blockPairEquiv (I A : Type) : (Sum I I → A) ≃ (I → A) × (I → A) where
  toFun z := (fun i => z (.inl i), fun i => z (.inr i))
  invFun z := Sum.elim z.1 z.2
  left_inv z := by funext i; cases i <;> rfl
  right_inv z := by rcases z with ⟨x,y⟩; rfl

theorem prodMass_split_blocks {I A : Type} [Fintype I] [DecidableEq I]
    (p : Sum I I → A → ℝ) (x y : I → A) :
    prodMass p (Sum.elim x y) =
      prodMass (fun i => p (.inl i)) x * prodMass (fun i => p (.inr i)) y := by
  unfold prodMass
  rw [Fintype.prod_sum_type]
  rfl

/-- Genuine #970 latent information dominates the left-block marginal
information, for all finite normalized product decompositions. -/
theorem mutInfo_ge_left_block {I A W : Type} [Fintype I] [DecidableEq I]
    [Fintype A] [DecidableEq A] [Nonempty A] [Fintype W]
    (Q : W → Sum I I → A → ℝ) (w : W → ℝ)
    (hw0 : ∀ t, 0 ≤ w t) (hw1 : ∑ t, w t = 1)
    (hQ0 : ∀ t i a, 0 ≤ Q t i a) (hQ1 : ∀ t i, ∑ a, Q t i a = 1) :
    Hent (fun x : I → A => ∑ t, w t * prodMass (fun i => Q t (.inl i)) x) -
      (∑ t, w t * Hent (prodMass (fun i => Q t (.inl i)))) ≤ mutInfo Q w := by
  classical
  let u : W → (I → A) → ℝ := fun t => prodMass (fun i => Q t (.inl i))
  let v : W → (I → A) → ℝ := fun t => prodMass (fun i => Q t (.inr i))
  have hu : ∀ t x, 0 ≤ u t x :=
    fun t x => Finset.prod_nonneg (fun i _ => hQ0 t (.inl i) (x i))
  have hv : ∀ t y, 0 ≤ v t y :=
    fun t y => Finset.prod_nonneg (fun i _ => hQ0 t (.inr i) (y i))
  have hu1 : ∀ t, ∑ x, u t x = 1 :=
    fun t => prodMass_total _ (fun i => hQ1 t (.inl i))
  have hv1 : ∀ t, ∑ y, v t y = 1 :=
    fun t => prodMass_total _ (fun i => hQ1 t (.inr i))
  have h := Nightfall.Route1FiniteEntropyProjection.product_mixture_information_ge_marginal
    w u v hw0 hu hv hu1 hv1
  have hj : Hent (fun z => ∑ t, w t * prodMass (Q t) z) =
      Nightfall.Route1FiniteEntropyProjection.H
        (fun z : (I → A) × (I → A) => ∑ t, w t * u t z.1 * v t z.2) := by
    unfold Hent Nightfall.Route1FiniteEntropyProjection.H
    rw [← Equiv.sum_comp (blockPairEquiv I A).symm]
    apply Finset.sum_congr rfl
    intro z _
    congr 1
    apply Finset.sum_congr rfl
    intro t _
    change w t * prodMass (Q t) (Sum.elim z.1 z.2) = w t * u t z.1 * v t z.2
    rw [prodMass_split_blocks]
    unfold u v
    ring
  have hk (t : W) : Hent (prodMass (Q t)) =
      Nightfall.Route1FiniteEntropyProjection.H
        (fun z : (I → A) × (I → A) => u t z.1 * v t z.2) := by
    unfold Hent Nightfall.Route1FiniteEntropyProjection.H
    rw [← Equiv.sum_comp (blockPairEquiv I A).symm]
    apply Finset.sum_congr rfl
    intro z _
    congr 1
    exact prodMass_split_blocks (Q t) z.1 z.2
  rw [mutInfo_eq Q hQ1 w hw1, hj]
  simp only [hk]
  exact h

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.wynerGen_lower_of_component_entropy
#print axioms Nightfall.Route1Polylog.wynerGen_lower_of_average_entropy
#print axioms Nightfall.Route1Polylog.prodMass_pos_iff_box
#print axioms Nightfall.Route1Polylog.product_entropy_le_log_support
#print axioms Nightfall.Route1Polylog.static_wyner_cardinality_terminal

#print axioms Nightfall.Route1Polylog.exact_static_wyner

#print axioms Nightfall.Route1Polylog.orthogonal_wyner_of_marginal_entropy

#print axioms Nightfall.Route1Polylog.prodMass_split_blocks
#print axioms Nightfall.Route1Polylog.mutInfo_ge_left_block
