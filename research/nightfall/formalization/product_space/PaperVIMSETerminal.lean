import PaperVILinearCharge

/-!
Paper VI actual-law risk terminal. All query trees read the original
alphabet only. The dyadic quadratic schedule uses the exact source
degree-weighted energy cap. The general degree budget uses one block.
The constants are conservative (the original switching inequality).
-/
namespace Nightfall.PaperVI
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

theorem incrementCost_nonneg (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (s : Posterior ι α Θ) (hv : ∀ θ, 0 ≤ s.weight θ) :
    0 ≤ incrementCost P s := by
  unfold incrementCost Phi Ltot
  exact Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ)
    (Finset.sum_nonneg fun i _ => pincr_nonneg (P θ) (hP0 θ) s.target i)

theorem incrementCost_le_rows (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (s : Posterior ι α Θ) (hv : ∀ θ, 0 ≤ s.weight θ) (K : ℝ)
    (hrows : HasRows s.target K) : incrementCost P s ≤ K*mass s := by
  obtain ⟨a,ha,hK⟩ := hrows
  unfold incrementCost Phi mass Vs
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun θ _ => ?_
  rw [mul_comm K]
  exact mul_le_mul_of_nonneg_left (sum_pincr_le (P θ) (hP0 θ) (hP1 θ)
    s.target a ha K hK) (hv θ)

theorem source_block
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (f : (ι → α) → ℝ) (K : ℝ) (d : ℕ)
    (F : Posterior ι α Θ → ℝ) (a b u : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hu : 0 < u)
    (hF : ∀ z, StD f K d z.read z.weight z.target → 0 ≤ F z)
    (hgood : ∀ z, StD f K d z.read z.weight z.target →
      u*mass z < risk P z →
      ∃ j, j ∉ z.read ∧ risk P z + (∑ c, scaledCost P F a b (child P z j c))
        ≤ scaledCost P F a b z)
    (s : Posterior ι α Θ) (t : DTree ι α)
    (hs : StD f K d s.read s.weight s.target) (ht : legal P s t)
    (n : ℕ) (hn : 0 < n) :
    ∃ t' : DTree ι α, legal P s t' ∧
      (∀ x, t'.queries x ≤ t.queries x+n) ∧
      frontier P (entropyCost P) s t' ≤ frontier P (entropyCost P) s t ∧
      frontier P (risk P) s t' ≤ u*mass s +
        (a*frontier P F s t + b*frontier P (entropyCost P) s t)/n := by
  classical
  let S : Posterior ι α Θ → Prop := fun z => StD f K d z.read z.weight z.target
  let H : Posterior ι α Θ → ℝ := scaledCost P F a b
  let G : Posterior ι α Θ → ι → Prop := fun z j =>
    j ∉ z.read ∧ risk P z + (∑ c, H (child P z j c)) ≤ H z
  let choose : Posterior ι α Θ → Option ι := fun z =>
    if h : u*mass z < risk P z ∧ ∃ j, G z j then some h.2.choose else none
  have hpres : ∀ z j c, S z → j ∉ z.read → S (child P z j c) :=
    fun z j c hz hj => StD_pres P hP0 f K d z.read z.weight z.target j c hz hj
  have hpos : ∀ z, S z → ∀ θ, 0 ≤ z.weight θ := fun z hz => hz.1.1
  have hH0 : ∀ z, S z → 0 ≤ H z := by
    intro z hz
    have hj : 0 ≤ entropyCost P z := info_nonneg P hP0 hP1 _ z.read z.weight rfl (hpos z hz)
    exact add_nonneg (mul_nonneg ha (hF z hz)) (mul_nonneg hb hj)
  have hchoose : ∀ z j, S z → choose z = some j → j ∉ z.read := by
    intro z j hz he
    by_cases h : u*mass z < risk P z ∧ ∃ j, G z j
    · have h' : h.2.choose = j := by simpa only [choose,dif_pos h,Option.some.injEq] using he
      rw [← h']
      exact h.2.choose_spec.1
    · simp [choose,h] at he
  have hcharge : ∀ z, S z → risk P z +
      (match choose z with | none => H z | some j => ∑ c, H (child P z j c)) ≤ u*mass z + H z := by
    intro z hz
    by_cases h : u*mass z < risk P z ∧ ∃ j, G z j
    · simp only [choose,dif_pos h]
      have hc := h.2.choose_spec.2
      have hm : 0 ≤ mass z := Finset.sum_nonneg fun θ _ => hpos z hz θ
      linarith [mul_nonneg hu.le hm]
    · simp only [choose,dif_neg h]
      have hle : risk P z ≤ u*mass z := by
        by_contra! hh
        exact h ⟨hh,hgood z hz hh⟩
      linarith
  have hJ : ∀ z, S z →
      (match choose z with | none => entropyCost P z | some j => ∑ c, entropyCost P (child P z j c))
        ≤ entropyCost P z := by
    intro z hz
    by_cases h : u*mass z < risk P z ∧ ∃ j, G z j
    · simp only [choose,dif_pos h]
      have hV : 0 < Vs z.weight := Vs_pos_of_var P z.weight (hpos z hz) z.target u h.1
      have hj := h.2.choose_spec.1
      have hc := info_chain P hP0 hP1 z.read h.2.choose hj z.weight (hpos z hz) hV
      have hk := kl_sum_ge P hP0 hP1 z.weight (hpos z hz) hV h.2.choose
      have hn : 0 ≤ ∑ θ, z.weight θ * tvd (P θ h.2.choose) (qmix P z.weight h.2.choose)^2 :=
        Finset.sum_nonneg fun θ _ => mul_nonneg (hpos z hz θ) (sq_nonneg _)
      change (∑ c, Info P (insert h.2.choose z.read) (upd P z.weight h.2.choose c)) ≤ Info P z.read z.weight
      rw [hc]
      linarith
    · simp only [choose,dif_neg h,le_refl]
  obtain ⟨t',ht',hq,hj,hr⟩ := risk_block_budget P hP0 hP1 S hpres hpos choose hchoose
    H (entropyCost P) hH0 u hcharge hJ s t hs ht n hn
  refine ⟨t',ht',hq,hj,?_⟩
  have he : frontier P H s t = a*frontier P F s t+b*frontier P (entropyCost P) s t := by
    change frontier P (fun z => a*F z+b*entropyCost P z) s t = _
    rw [frontier_add,frontier_smul,frontier_smul]
  rwa [he] at hr

/-- One-block actual-law general-degree MSE budget. No supplied good-query
condition or supplied posterior moment inequality in the statement. -/
theorem mean_mse_mixture
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (u : ℝ) (hu : 0 < u) (n : ℕ) (hn : 0 < n) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Ex P w (fun x => (f x-t.eval x)^2) ≤ u +
        (meanWeight d u*rowK d + infoWeight d u*mutInfo P w)/n := by
  let s : Posterior ι α Θ := ⟨∅,w,f⟩
  let t : DTree ι α := .leaf (mmean P w f) false
  have hS : StD f (rowK d) d s.read s.weight s.target :=
    ⟨⟨hw0,fun i hi => absurd hi (Finset.notMem_empty i),
      hasRows_of_degree f d hf hdeg,rep_empty f,hf⟩,hdeg⟩
  have ht : legal P s t := rfl
  have hmass : mass s = 1 := hw1
  have ha : 0 ≤ meanWeight d u := by unfold meanWeight; positivity
  have hb : 0 ≤ infoWeight d u := by unfold infoWeight rowK; positivity
  obtain ⟨t',ht',hq,_,hr⟩ := source_block P hP0 hP1 f (rowK d) d
    (incrementCost P) (meanWeight d u) (infoWeight d u) u ha hb hu
    (fun z hz => incrementCost_nonneg P hP0 z hz.1.1)
    (fun z hz hl => source_mean_charge P hP0 hP1 f d hd u hu z hz hl)
    s t hS ht n hn
  have hcap : incrementCost P s ≤ rowK d := by
    have h := incrementCost_le_rows P hP0 hP1 s hw0 (rowK d) hS.1.2.2.1
    rwa [hmass,mul_one] at h
  have hJ : entropyCost P s = mutInfo P w := info_empty P w
  change frontier P (risk P) s t' ≤ u*mass s +
      (meanWeight d u*incrementCost P s + infoWeight d u*entropyCost P s)/n at hr
  rw [hmass,mul_one,hJ,frontier_risk_exact P hP1 s t' ht'] at hr
  refine ⟨t',fun x => by simpa [t,DTree.queries] using hq x,hr.trans ?_⟩
  have h := mul_le_mul_of_nonneg_left hcap ha
  have hnR : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  have hsum : meanWeight d u*incrementCost P s + infoWeight d u*mutInfo P w ≤
      meanWeight d u*rowK d + infoWeight d u*mutInfo P w := by linarith only [h]
  have hdiv := div_le_div_of_nonneg_right hsum hnR
  linarith only [hdiv]

/-- One actual quadratic stage, with the information charge shared across
stages. The cap is on the expected frontier variance, not each branch. -/
theorem quadratic_halve_stage
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (f : (ι → α) → ℝ) (s : Posterior ι α Θ)
    (hs : StD f (rowK 2) 2 s.read s.weight s.target)
    (hmass : mass s = 1) (t : DTree ι α) (ht : legal P s t)
    (u J : ℝ) (hu : 0 < u)
    (hr : frontier P (risk P) s t ≤ u)
    (hJ : frontier P (entropyCost P) s t ≤ J)
    (n : ℕ) (hn : 0 < n)
    (hbudget : quadWeight (u/4)*(2*u) + infoWeight 2 (u/4)*J ≤ (n : ℝ)*(u/4)) :
    ∃ t' : DTree ι α, legal P s t' ∧ (∀ x, t'.queries x ≤ t.queries x+n) ∧
      frontier P (risk P) s t' ≤ u/2 ∧ frontier P (entropyCost P) s t' ≤ J := by
  have hu4 : 0 < u/4 := by positivity
  have ha : 0 ≤ quadWeight (u/4) := by unfold quadWeight; have := quadraticC_pos; positivity
  have hb : 0 ≤ infoWeight 2 (u/4) := by unfold infoWeight rowK; positivity
  obtain ⟨t',ht',hq,hj,hnew⟩ := source_block P hP0 hP1 f (rowK 2) 2
    (energyCost P) (quadWeight (u/4)) (infoWeight 2 (u/4)) (u/4) ha hb hu4
    (fun z hz => Phi2_nonneg P hP0 z.weight hz.1.1 z.target)
    (fun z hz hl => source_quad_charge P hP0 hP1 f (u/4) hu4 z hz hl)
    s t hs ht n hn
  have hcap := frontier_energy_cap P hP0 hP1 f (rowK 2) 2 s t hs ht
  have hcap' : frontier P (energyCost P) s t ≤ 2*u := by
    norm_num at hcap
    linarith
  have hcost := add_le_add (mul_le_mul_of_nonneg_left hcap' ha) (mul_le_mul_of_nonneg_left hJ hb)
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdiv : (quadWeight (u/4)*frontier P (energyCost P) s t +
      infoWeight 2 (u/4)*frontier P (entropyCost P) s t)/n ≤ u/4 := by
    rw [div_le_iff₀ hnR]
    exact hcost.trans (by simpa [mul_comm] using hbudget)
  rw [hmass,mul_one] at hnew
  exact ⟨t',ht',hq,by linarith,hj.trans hJ⟩

noncomputable def dyadicRisk (j : ℕ) : ℝ := 1/(4*(2 : ℝ)^j)

theorem dyadicRisk_pos (j : ℕ) : 0 < dyadicRisk j := by unfold dyadicRisk; positivity

theorem dyadicRisk_succ (j : ℕ) : dyadicRisk (j+1) = dyadicRisk j/2 := by
  unfold dyadicRisk
  rw [pow_succ]
  field_simp
  <;> ring

theorem quad_dyadic_budget (j n : ℕ) (A B J : ℝ)
    (hA : 2048*quadraticC ≤ A) (hB : (2^40 : ℝ)*rowK 2*J ≤ B)
    (hn : A*(2 : ℝ)^j+B*(8 : ℝ)^j ≤ n) :
    quadWeight (dyadicRisk j/4)*(2*dyadicRisk j) +
        infoWeight 2 (dyadicRisk j/4)*J ≤
      (n : ℝ)*(dyadicRisk j/4) := by
  have hu := dyadicRisk_pos j
  have hp : 0 < (2 : ℝ)^j := by positivity
  have h1 : quadWeight (dyadicRisk j/4)*(2*dyadicRisk j) = 128*quadraticC := by
    unfold quadWeight
    field_simp [hu.ne'] <;> ring
  have h2 : infoWeight 2 (dyadicRisk j/4)*J =
      (2^32 : ℝ)*rowK 2*J/(dyadicRisk j)^2 := by
    unfold infoWeight
    norm_num
    field_simp [hu.ne'] <;> ring
  have hpow : (8 : ℝ)^j = ((2 : ℝ)^j)^3 := by
    rw [← pow_mul, Nat.mul_comm, pow_mul]
    norm_num
  have hA' := mul_le_mul_of_nonneg_right hA hp.le
  have hB' := mul_le_mul_of_nonneg_right hB (show 0 ≤ (8 : ℝ)^j by positivity)
  have hs := (add_le_add hA' hB').trans hn
  rw [h1,h2]
  have hcalc :
      (128*quadraticC+(2^32 : ℝ)*rowK 2*J/(dyadicRisk j)^2) / (dyadicRisk j/4) =
        2048*quadraticC*(2 : ℝ)^j+(2^40 : ℝ)*rowK 2*J*(8 : ℝ)^j := by
    rw [hpow]
    unfold dyadicRisk
    field_simp [hp.ne'] <;> ring
  have hdiv : (128*quadraticC+(2^32 : ℝ)*rowK 2*J/(dyadicRisk j)^2)/(dyadicRisk j/4) ≤ n := by
    rw [hcalc]
    exact hs
  exact (div_le_iff₀ (by positivity : 0 < dyadicRisk j/4)).mp hdiv

/-- Exact dyadic MSE terminal with real coefficients and per-stage
rounding. In particular, no spurious τ^(-3) term when J=0. -/
theorem quadratic_mse_mixture_dyadic
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2)
    (J : ℝ) (hJ : mutInfo P w ≤ J) (A B : ℝ)
    (hA0 : 0 ≤ A) (hB0 : 0 ≤ B)
    (hA : 2048*quadraticC ≤ A) (hB : (2^40 : ℝ)*rowK 2*J ≤ B) (N : ℕ) :
    ∃ t : DTree ι α, (∀ x, (t.queries x : ℝ) ≤ 2*N+A*2^N+B*8^N) ∧
      Ex P w (fun x => (f x-t.eval x)^2) ≤ dyadicRisk N := by
  let s : Posterior ι α Θ := ⟨∅,w,f⟩
  let t0 : DTree ι α := .leaf (mmean P w f) false
  have hS : StD f (rowK 2) 2 s.read s.weight s.target :=
    ⟨⟨hw0,fun i hi => absurd hi (Finset.notMem_empty i),
      hasRows_of_degree f 2 hf hdeg,rep_empty f,hf⟩,hdeg⟩
  have hm : mass s = 1 := hw1
  have hstart : legal P s t0 := rfl
  have hR0 : frontier P (risk P) s t0 ≤ dyadicRisk 0 := by
    have h := mvar_le_quarter_mass P hP0 hP1 w hw0 f hf
    change mvar P w f ≤ _
    simpa [dyadicRisk,Vs,hw1] using h
  have hJ0 : frontier P (entropyCost P) s t0 ≤ J := by
    change Info P ∅ w ≤ J
    rwa [info_empty]
  have H : ∀ k : ℕ, ∃ t : DTree ι α, legal P s t ∧
      (∀ x, (t.queries x : ℝ) ≤ 2*k+A*2^k+B*8^k) ∧
      frontier P (risk P) s t ≤ dyadicRisk k ∧ frontier P (entropyCost P) s t ≤ J := by
    intro k
    induction k with
    | zero =>
      refine ⟨t0,hstart,?_,hR0,hJ0⟩
      intro x
      simp [t0,DTree.queries]
      linarith
    | succ k ih =>
      obtain ⟨t,ht,hq,hr,hj⟩ := ih
      let c : ℝ := A*2^k+B*8^k
      have hc : 0 ≤ c := by dsimp [c]; positivity
      let n : ℕ := ⌈c⌉₊+1
      have hn : c ≤ n := by
        have h := Nat.le_ceil c
        dsimp [n]
        push_cast
        linarith
      have hnup : (n : ℝ) ≤ c+2 := by
        have h := Nat.ceil_lt_add_one hc
        dsimp [n]
        push_cast
        linarith
      obtain ⟨t',ht',hq',hr',hj'⟩ := quadratic_halve_stage P hP0 hP1 f s hS hm
        t ht (dyadicRisk k) J (dyadicRisk_pos k) hr hj n (by dsimp [n]; omega)
        (quad_dyadic_budget k n A B J hA hB hn)
      refine ⟨t',ht',?_,?_,hj'⟩
      · intro x
        have hh : (t'.queries x : ℝ) ≤ (t.queries x : ℝ)+(n : ℝ) := by exact_mod_cast hq' x
        have h := hq x
        have hb8 : 0 ≤ B*(8 : ℝ)^k := by positivity
        dsimp [c] at hnup
        rw [Nat.cast_succ,pow_succ,pow_succ]
        nlinarith only [hh,h,hnup,hb8]
      · rwa [dyadicRisk_succ]
  obtain ⟨t,ht,hq,hr,_⟩ := H N
  exact ⟨t,hq,by simpa only [frontier_risk_exact P hP1 s t ht,s] using hr⟩

#print axioms Nightfall.PaperVI.source_block
#print axioms Nightfall.PaperVI.mean_mse_mixture
#print axioms Nightfall.PaperVI.quadratic_halve_stage
#print axioms Nightfall.PaperVI.quad_dyadic_budget
#print axioms Nightfall.PaperVI.quadratic_mse_mixture_dyadic
end Nightfall.PaperVI
