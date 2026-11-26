import Route1WynerGeneral

/-! Paper I section 5.2: compact entropy fiber and exact attained endpoint,
with the original product-law and general latent definitions. -/
namespace Nightfall.Route1Polylog
open Finset Real MeasureTheory
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]

noncomputable def lawEntropyMap (θ : LawSpace ι α) : ((ι → α) → ℝ) × ℝ :=
  (fun x => prodMass θ.1 x, Hent (prodMass θ.1))

theorem lawEntropyMap_continuous :
    Continuous (lawEntropyMap (ι := ι) (α := α)) :=
  Continuous.prodMk (continuous_pi fun x => continuous_prodMass_law x) continuous_Hent_law

theorem wynerSet_compact (ν : (ι → α) → ℝ) : IsCompact (wynerSet ν) := by
  classical
  let E := ((ι → α) → ℝ) × ℝ
  let F : LawSpace ι α → E := lawEntropyMap
  let K := convexHull ℝ (Set.range F)
  let L : Set E := K ∩ {z | z.1 = ν}
  let J : E → ℝ := fun z => Hent ν - z.2
  have hK : IsCompact K :=
    isCompact_convexHull_of_isCompact (isCompact_range lawEntropyMap_continuous)
  have hL : IsCompact L := hK.inter_right (isClosed_eq continuous_fst continuous_const)
  have hJ : Continuous J := continuous_const.sub continuous_snd
  have heq : wynerSet ν = J '' L := by
    ext s
    constructor
    · rintro ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,rfl⟩
      let θ : Fin k → LawSpace ι α := fun i => ⟨Q i,hQ0 i,hQ1 i⟩
      let z : E := ∑ i, w i • F (θ i)
      have hz : z ∈ K := (convex_convexHull ℝ _).sum_mem (fun i _ => hw0 i) hw1
        (fun i _ => subset_convexHull ℝ _ ⟨θ i,rfl⟩)
      have hfst : z.1 = ν := by
        funext x
        simp [z,F,lawEntropyMap,← hν x]
      have hsnd : z.2 = ∑ i, w i * Hent (prodMass (Q i)) := by
        simp [z,F,lawEntropyMap]
      refine ⟨z,⟨hz,hfst⟩,?_⟩
      dsimp [J]
      rw [hsnd,mutInfo_eq Q hQ1 w hw1]
      congr 2
      funext x
      exact hν x
    · rintro ⟨z,⟨hz,hzν⟩,rfl⟩
      obtain ⟨β,_,c,p,hc0,hc1,hp,hsum⟩ := mem_convexHull_iff_exists_fintype.mp hz
      choose θ hθ using hp
      let e := Fintype.equivFin β
      let Q : Fin (Fintype.card β) → ι → α → ℝ := fun i => (θ (e.symm i)).1
      let w : Fin (Fintype.card β) → ℝ := fun i => c (e.symm i)
      have hw1 : ∑ i, w i = 1 := by
        unfold w
        rw [Equiv.sum_comp e.symm c]
        exact hc1
      have he : z = ∑ i, c i • F (θ i) := by
        rw [← hsum]
        apply Finset.sum_congr rfl
        intro i _
        rw [hθ]
      have hm : ∀ x, ν x = ∑ i, w i * prodMass (Q i) x := by
        intro x
        rw [← hzν, he]
        unfold w Q
        rw [Equiv.sum_comp e.symm (fun i => c i * prodMass (θ i).1 x)]
        simp [F,lawEntropyMap]
      refine ⟨Fintype.card β,w,Q,fun i => hc0 _,hw1,
        fun i => (θ (e.symm i)).2.1,fun i => (θ (e.symm i)).2.2,hm,?_⟩
      rw [mutInfo_eq Q (fun i => (θ (e.symm i)).2.2) w hw1]
      dsimp [J]
      have hfun : (fun x => ∑ i, w i * prodMass (Q i) x) = ν := by
        funext x
        exact (hm x).symm
      rw [hfun,he]
      unfold w Q
      rw [Equiv.sum_comp e.symm (fun i => c i * Hent (prodMass (θ i).1))]
      simp [F,lawEntropyMap]
  rw [heq]
  exact hL.image hJ

theorem wynerGen_attained (ν : (ι → α) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1) :
    wynerGen ν ∈ wynerSet ν := by
  rw [← wynerCI_eq_wynerGen]
  exact (wynerSet_compact ν).sInf_mem (wynerSet_nonempty ν hν0 hν1)

theorem route1_wyner_attained (ν : (ι → α) → ℝ)
    (hν0 : ∀ x, 0 ≤ ν x) (hν1 : ∑ x, ν x = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ) (hd : 1 ≤ d)
    (hdeg : HasProdDegreeLE f d) (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1)
    (ε : ℝ) (hε : 0 < ε) (n : ℕ) (hn : 0 < n) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          wynerGen ν / (etaC d τ ^ 2 * w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n + τ / ε ^ 2 := by
  obtain ⟨k,w,Q,hw0,hw1,hQ0,hQ1,hν,hInfo⟩ := wynerGen_attained ν hν0 hν1
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0; simp at hw1
    · exact h
  letI : Nonempty (Fin k) := ⟨⟨0,hk⟩⟩
  obtain ⟨t,htq,hb⟩ := route1_wyner_simulation Q hQ0 hQ1 w hw0 hw1 f hf01 d hd hdeg τ hτ hτ1 ε hε n hn
  refine ⟨t,htq,?_⟩
  have hEx : Ex Q w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) =
      ∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) := by
    unfold Ex pexp
    simp only [hν, Finset.mul_sum, Finset.sum_mul]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun θ _ => by ring
  rw [← hEx,hInfo]
  exact hb

#print axioms wynerSet_compact
#print axioms wynerGen_attained
#print axioms route1_wyner_attained
end Nightfall.Route1Polylog
