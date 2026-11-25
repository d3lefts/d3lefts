import Route1WynerGeneral

/-! Direct incidence/recovery entropy obstruction for the actual Route1
general-latent Wyner definition. No PPZ or assumed component entropy bound
in the final incidence theorem. Entropy bridge adapted from archived #1193;
all newly assembled declarations require exact-head kernel replay. -/
namespace Nightfall.SynthesisWynerEntropy
open Finset Real
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.Transfer (prodMass)

section Entropy
variable {X : Type} [Fintype X] [DecidableEq X]

noncomputable def positiveSupport (p : X → ℝ) : Finset X := by
  classical
  exact univ.filter fun x => 0 < p x

theorem entropy_le_log_support (p : X → ℝ)
    (hp0 : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1) :
    (∑ x, negMulLog (p x)) ≤ Real.log ((positiveSupport p).card : ℝ) := by
  classical
  let A := positiveSupport p
  have hzero : ∀ x, x ∉ A → p x = 0 := by
    intro x hx
    have hn : ¬ 0 < p x := by simpa [A, positiveSupport] using hx
    exact le_antisymm (le_of_not_gt hn) (hp0 x)
  have hs : (∑ x ∈ A, p x) = 1 := by
    calc
      _ = ∑ x, p x := Finset.sum_subset (Finset.subset_univ A) (fun x _ hx => hzero x hx)
      _ = 1 := hp1
  have hH : (∑ x ∈ A, negMulLog (p x)) = ∑ x, negMulLog (p x) := by
    apply Finset.sum_subset (Finset.subset_univ A)
    intro x _ hx
    rw [hzero x hx, Real.negMulLog_zero]
  have hA : 0 < A.card := by
    by_contra hn
    have he : A = ∅ := Finset.card_eq_zero.mp (by omega)
    simp [he] at hs
  have hM : (0 : ℝ) < A.card := Nat.cast_pos.mpr hA
  have hw : (∑ _x ∈ A, (1 : ℝ) / A.card) = 1 := by
    rw [Finset.sum_const, nsmul_eq_mul]
    field_simp
  have hcon := ConcaveOn.le_map_sum Real.concaveOn_negMulLog (t := A)
    (w := fun _ => 1 / (A.card : ℝ)) (p := p)
    (fun _ _ => by positivity) hw
    (fun x _ => Set.mem_Ici.mpr (hp0 x))
  simp only [smul_eq_mul] at hcon
  have hleft : (∑ x ∈ A, (1 / (A.card : ℝ)) * negMulLog (p x)) =
      (∑ x, negMulLog (p x)) / A.card := by
    rw [← Finset.mul_sum, hH]
    ring
  have hright : (∑ x ∈ A, (1 / (A.card : ℝ)) * p x) = 1 / (A.card : ℝ) := by
    rw [← Finset.mul_sum, hs, mul_one]
  have hv : negMulLog (1 / (A.card : ℝ)) = Real.log (A.card : ℝ) / A.card := by
    unfold negMulLog
    rw [one_div, Real.log_inv]
    ring
  rw [hleft, hright, hv] at hcon
  exact (div_le_div_iff_of_pos_right hM).mp hcon

end Entropy

section Wyner
variable {κ α : Type} [Fintype κ] [DecidableEq κ]
    [Fintype α] [DecidableEq α] [Nonempty α]

theorem product_mass_nonneg (p : κ → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (z : κ → α) : 0 ≤ prodMass p z := by
  unfold prodMass
  exact Finset.prod_nonneg fun i _ => hp i (z i)

theorem product_mass_pos_iff (p : κ → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (z : κ → α) : 0 < prodMass p z ↔ ∀ i, 0 < p i (z i) := by
  unfold prodMass
  constructor
  · intro h i
    by_contra hn
    have hz : p i (z i) = 0 := le_antisymm (le_of_not_gt hn) (hp i (z i))
    rw [Finset.prod_eq_zero (Finset.mem_univ i) hz] at h
    exact (lt_irrefl 0) h
  · intro h
    exact Finset.prod_pos fun i _ => h i

/-- Lower bound on the existing general-latent Wyner infimum from a bound on
all normalized product components supported in the original positive support. -/
theorem wyner_general_lower_of_component_entropy
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (K : ℝ)
    (hcap : ∀ p : κ → α → ℝ, (∀ i a, 0 ≤ p i a) →
      (∀ i, ∑ a, p i a = 1) →
      (∀ z, 0 < prodMass p z → 0 < ν z) → Hent (prodMass p) ≤ K) :
    Hent ν - K ≤ wynerGen ν := by
  classical
  rw [← wynerCI_eq_wynerGen]
  unfold wynerCI
  apply le_csInf (wynerSet_nonempty ν hν0 hν1)
  rintro s ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩
  have hmix : Hent ν = Hent (fun z => ∑ θ, w θ * prodMass (Q θ) z) := by
    congr 1
    funext z
    exact hν z
  rw [mutInfo_eq Q hQ1 w hw1, ← hmix]
  have hsum : (∑ θ, w θ * Hent (prodMass (Q θ))) ≤ K := by
    calc
      _ ≤ ∑ θ, w θ * K := by
        apply Finset.sum_le_sum
        intro θ _
        by_cases hz : w θ = 0
        · simp [hz]
        · have hw : 0 < w θ := lt_of_le_of_ne (hw0 θ) (Ne.symm hz)
          apply mul_le_mul_of_nonneg_left _ (hw0 θ)
          apply hcap (Q θ) (hQ0 θ) (hQ1 θ)
          intro z hpos
          rw [hν z]
          exact (mul_pos hw hpos).trans_le
            (Finset.single_le_sum
              (fun i _ => mul_nonneg (hw0 i) (product_mass_nonneg (Q i) (hQ0 i) z))
              (Finset.mem_univ θ))
      _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
  linarith

end Wyner


/-- Binary observed-coordinate recovery tree, with arbitrary finite leaf alphabet. -/
inductive Recovery (ι α : Type) where
  | leaf : α → Recovery ι α
  | query : ι → Recovery ι α → Recovery ι α → Recovery ι α

namespace Recovery
variable {ι α : Type} [DecidableEq α]

def eval : Recovery ι α → (ι → Bool) → α
  | .leaf a, _ => a
  | .query j l r, x => if x j then r.eval x else l.eval x

def depth : Recovery ι α → ℕ
  | .leaf _ => 0
  | .query _ l r => max l.depth r.depth + 1

def leaves : Recovery ι α → Finset α
  | .leaf a => {a}
  | .query _ l r => l.leaves ∪ r.leaves

theorem eval_mem_leaves (t : Recovery ι α) (x : ι → Bool) :
    t.eval x ∈ t.leaves := by
  induction t with
  | leaf a => simp [eval, leaves]
  | query j l r hl hr =>
    cases hx : x j <;> simp [eval, leaves, hx, hl, hr]

theorem leaves_card_le (t : Recovery ι α) : t.leaves.card ≤ 2^t.depth := by
  induction t with
  | leaf a => simp [depth, leaves]
  | query j l r hl hr =>
    simp only [depth, leaves, pow_succ]
    have h1 : 2^l.depth ≤ 2^(max l.depth r.depth) :=
      Nat.pow_le_pow_right (by decide) (le_max_left _ _)
    have h2 : 2^r.depth ≤ 2^(max l.depth r.depth) :=
      Nat.pow_le_pow_right (by decide) (le_max_right _ _)
    exact (Finset.card_union_le _ _).trans (by omega)
end Recovery

section Incidence
variable {ι κ α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype κ] [DecidableEq κ] [Fintype α] [DecidableEq α] [Nonempty α]

/-- A normalized finite product law has positive atoms in every marginal. -/
private theorem exists_positive (p : α → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hp1 : ∑ a, p a = 1) : ∃ a, 0 < p a := by
  by_contra h
  push_neg at h
  have hz : ∀ a, p a = 0 := fun a => le_antisymm (h a) (hp0 a)
  simp [hz] at hp1

/-- Direct source theorem: every positive product component is a rectangle;
its active coordinates each require at least dist dependency incidences.
Binary recovery bounds every active marginal by 2^r. -/
theorem component_entropy_incidence
    (S : Set (ι → Bool)) (dist b r : ℕ) (hd : 0 < dist)
    (E : (κ → α) → (ι → Bool)) (T : κ → Recovery ι α)
    (L : ι → Finset κ)
    (hL : ∀ i, (L i).card ≤ b)
    (hlocal : ∀ i z z', (∀ j ∈ L i, z j = z' j) → E z i = E z' i)
    (hdepth : ∀ j, (T j).depth ≤ r)
    (hdist : ∀ x ∈ S, ∀ y ∈ S, x ≠ y →
      dist ≤ (univ.filter fun i => x i ≠ y i).card)
    (p : κ → α → ℝ) (hp0 : ∀ j a, 0 ≤ p j a)
    (hp1 : ∀ j, ∑ a, p j a = 1)
    (hsource : ∀ z, 0 < prodMass p z → E z ∈ S)
    (hinv : ∀ z, 0 < prodMass p z → ∀ j, (T j).eval (E z) = z j) :
    Hent (prodMass p) ≤
      (((b * Fintype.card ι * r : ℕ) : ℝ) / dist) * Real.log 2 := by
  classical
  let A : κ → Finset α := fun j => positiveSupport (p j)
  have hA : ∀ j a, a ∈ A j ↔ 0 < p j a := by
    intro j a
    simp [A, positiveSupport]
  choose z0 hz0 using fun j => exists_positive (p j) (hp0 j) (hp1 j)
  have hzpos : 0 < prodMass p z0 :=
    (product_mass_pos_iff p hp0 z0).mpr hz0
  let U : Finset κ := univ.filter fun j => 1 < (A j).card
  let incid : κ → Finset ι := fun j => univ.filter fun i => j ∈ L i
  have hsize : ∀ j, (A j).card ≤ 2^r := by
    intro j
    have hsub : A j ⊆ (T j).leaves := by
      intro a ha
      let z := Function.update z0 j a
      have hz : 0 < prodMass p z := by
        apply (product_mass_pos_iff p hp0 z).mpr
        intro k
        by_cases hk : k = j
        · subst k
          simpa [z] using (hA j a).mp ha
        · simpa [z, Function.update_of_ne hk] using hz0 k
      have hev := (T j).eval_mem_leaves (E z)
      rw [hinv z hz j] at hev
      simpa [z] using hev
    exact (Finset.card_le_card hsub).trans
      ((T j).leaves_card_le.trans (Nat.pow_le_pow_right (by decide) (hdepth j)))
  have hinc : ∀ j ∈ U, dist ≤ (incid j).card := by
    intro j hj
    have hjactive : 1 < (A j).card := (Finset.mem_filter.mp hj).2
    have ha : ∃ a ∈ A j, a ≠ z0 j := by
      by_contra hn
      push_neg at hn
      have hsub : A j ⊆ {z0 j} := by
        intro a ha
        simpa using hn a ha
      have hcard := Finset.card_le_card hsub
      simp at hcard
      omega
    obtain ⟨a, ha, hne⟩ := ha
    let z := Function.update z0 j a
    have hz : 0 < prodMass p z := by
      apply (product_mass_pos_iff p hp0 z).mpr
      intro k
      by_cases hk : k = j
      · subst k
        simpa [z] using (hA j a).mp ha
      · simpa [z, Function.update_of_ne hk] using hz0 k
    have he : E z0 ≠ E z := by
      intro he
      have h := hinv z0 hzpos j
      rw [he, hinv z hz j] at h
      exact hne (by simpa [z] using h)
    have hdis := hdist (E z0) (hsource z0 hzpos) (E z) (hsource z hz) he
    refine hdis.trans (Finset.card_le_card ?_)
    intro i hi
    have hdiff := (Finset.mem_filter.mp hi).2
    apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_univ _, ?_⟩
    by_contra hjL
    apply hdiff
    apply hlocal i z0 z
    intro k hk
    have hkne : k ≠ j := fun h => hjL (h ▸ hk)
    simp [z, Function.update_of_ne hkne]
  have hcount : dist * U.card ≤ b * Fintype.card ι := by
    calc
      dist * U.card = ∑ _j ∈ U, dist := by simp [Nat.mul_comm]
      _ ≤ ∑ j ∈ U, (incid j).card := Finset.sum_le_sum hinc
      _ ≤ ∑ j : κ, (incid j).card :=
        Finset.sum_le_sum_of_subset (Finset.subset_univ U)
      _ = ∑ j : κ, ∑ i : ι, if j ∈ L i then 1 else 0 := by
        apply Finset.sum_congr rfl
        intro j _
        simp [incid, Finset.sum_filter]
      _ = ∑ i : ι, ∑ j : κ, if j ∈ L i then 1 else 0 := Finset.sum_comm
      _ = ∑ i : ι, (L i).card := by
        apply Finset.sum_congr rfl
        intro i _
        rw [← Finset.sum_filter]
        simp
      _ ≤ ∑ _i : ι, b := Finset.sum_le_sum fun i _ => hL i
      _ = b * Fintype.card ι := by simp [Nat.mul_comm]
  let B := positiveSupport (prodMass p)
  have hB : ∀ z, z ∈ B ↔ ∀ j, z j ∈ A j := by
    intro z
    simp only [B, positiveSupport, Finset.mem_filter, Finset.mem_univ, true_and]
    rw [product_mass_pos_iff p hp0 z]
    exact forall_congr' fun j => (hA j (z j)).symm
  have hrect : B.card = ∏ j : κ, (A j).card := by
    let e : {z // z ∈ B} ≃ (∀ j : κ, {a // a ∈ A j}) :=
      { toFun := fun z j => ⟨z.1 j, (hB z.1).mp z.2 j⟩
        invFun := fun f => ⟨fun j => (f j).1, (hB _).mpr fun j => (f j).2⟩
        left_inv := by intro z; apply Subtype.ext; rfl
        right_inv := by intro f; funext j; apply Subtype.ext; rfl }
    simpa only [Fintype.card_coe, Fintype.card_pi] using Fintype.card_congr e
  have hInactive : ∀ j, j ∉ U → (A j).card = 1 := by
    intro j hj
    have hle : (A j).card ≤ 1 := by
      by_contra hn
      exact hj (Finset.mem_filter.mpr ⟨Finset.mem_univ _, by omega⟩)
    have hpos : 0 < (A j).card :=
      Finset.card_pos.mpr ⟨z0 j, (hA j _).mpr (hz0 j)⟩
    omega
  have hprod : B.card ≤ (2^r)^U.card := by
    rw [hrect]
    calc
      _ = ∏ j ∈ U, (A j).card := by
        symm
        exact Finset.prod_subset (Finset.subset_univ U) fun j _ hj => hInactive j hj
      _ ≤ ∏ _j ∈ U, 2^r := Finset.prod_le_prod' fun j _ => hsize j
      _ = _ := by simp
  have hBpos : (0 : ℝ) < B.card := by
    exact Nat.cast_pos.mpr (Finset.card_pos.mpr ⟨z0, (hB z0).mpr
      fun j => (hA j _).mpr (hz0 j)⟩)
  have hlog : Real.log (B.card : ℝ) ≤ (r : ℝ) * U.card * Real.log 2 := by
    have hmono : (B.card : ℝ) ≤ ((2 : ℝ)^r)^U.card := by exact_mod_cast hprod
    have h := Real.log_le_log hBpos hmono
    rw [Real.log_pow, Real.log_pow] at h
    nlinarith
  have hcount' : (dist : ℝ) * U.card ≤ (b : ℝ) * Fintype.card ι := by
    exact_mod_cast hcount
  have hd' : (0 : ℝ) < dist := by exact_mod_cast hd
  have hU : (U.card : ℝ) ≤ (b : ℝ) * Fintype.card ι / dist := by
    apply (le_div_iff₀ hd').mpr
    simpa [mul_comm] using hcount'
  have hscale := mul_le_mul_of_nonneg_left hU (show (0 : ℝ) ≤ r by positivity)
  have hscale2 := mul_le_mul_of_nonneg_right hscale (Real.log_nonneg (by norm_num : (1:ℝ) ≤ 2))
  unfold Hent
  refine (entropy_le_log_support (prodMass p) (product_mass_nonneg p hp0)
    (prodMass_total p hp1)).trans (hlog.trans ?_)
  push_cast
  convert hscale2 using 1 <;> ring

/-- Full general-latent Wyner lower bound over every exact locally encoded,
recoverable finite source supported on a binary distance code. No supplied
product-entropy or rectangle-cardinality hypothesis remains. -/
theorem wyner_entropy_obstruction
    (S : Set (ι → Bool)) (dist b r : ℕ) (hd : 0 < dist)
    (E : (κ → α) → (ι → Bool)) (T : κ → Recovery ι α) (L : ι → Finset κ)
    (hL : ∀ i, (L i).card ≤ b)
    (hlocal : ∀ i z z', (∀ j ∈ L i, z j = z' j) → E z i = E z' i)
    (hdepth : ∀ j, (T j).depth ≤ r)
    (hdist : ∀ x ∈ S, ∀ y ∈ S, x ≠ y →
      dist ≤ (univ.filter fun i => x i ≠ y i).card)
    (ν : (κ → α) → ℝ) (hν0 : ∀ z, 0 ≤ ν z) (hν1 : ∑ z, ν z = 1)
    (hsource : ∀ z, 0 < ν z → E z ∈ S)
    (hinv : ∀ z, 0 < ν z → ∀ j, (T j).eval (E z) = z j) :
    Hent ν - (((b * Fintype.card ι * r : ℕ) : ℝ) / dist) * Real.log 2
      ≤ wynerGen ν := by
  apply wyner_general_lower_of_component_entropy ν hν0 hν1
  intro p hp0 hp1 hs
  exact component_entropy_incidence S dist b r hd E T L hL hlocal hdepth hdist
    p hp0 hp1 (fun z hz => hsource z (hs z hz))
    (fun z hz => hinv z (hs z hz))

end Incidence
end Nightfall.SynthesisWynerEntropy

#print axioms Nightfall.SynthesisWynerEntropy.Recovery.leaves_card_le
#print axioms Nightfall.SynthesisWynerEntropy.wyner_general_lower_of_component_entropy
#print axioms Nightfall.SynthesisWynerEntropy.component_entropy_incidence
#print axioms Nightfall.SynthesisWynerEntropy.wyner_entropy_obstruction
