import Route1PolylogSimulation

/-!
# NIGHTFALL Route 1 — Wyner common-information form

`route1_wyner_simulation`: for **any** finite product decomposition `ν = ∑_θ w_θ ⊗_i P θ i`, the
depth bound of `route1_polylog_simulation` holds with `log M` replaced by the mutual information
`I_w(Θ; X) = H(Θ) − H(Θ | X)` of that decomposition. Consequently (`route1_wyner_CI`) the bound holds
with any `s` above the (finite-latent) Wyner common information
`C_W(ν) = inf { I(Θ; X) : ν = ∑_θ w_θ ⊗_i P θ i }`.

This is **not** a substitution in the `log M` theorem: the entropy potential `H(Θ | x_A)` used there
starts at `H(Θ) ≤ log M` and can be exponentially larger than `I(Θ;X)`. The tree here charges the
*remaining information* `Info A v = Vs v · I(Θ ; X_{Aᶜ} | x_A)`, which depends on the queried set,
satisfies the exact chain rule `∑_b Info (A ∪ {j}) (child_b) = Info A v − ∑_θ v_θ KL(P_θj ‖ q_j)`
(`info_chain`), is nonnegative (`info_nonneg`), vanishes once every coordinate is queried, and starts
at `I_w(Θ;X)`. The crux (`crux`) is already `M`-free and is reused unchanged.

Queried coordinates are frozen at a fixed letter `aStar`, so `Info` is an ordinary sum over `ι → α`.
-/

namespace Nightfall.Route1Polylog

open Finset Real
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]
variable (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

omit [DecidableEq Θ] [Nonempty Θ] in
theorem ent_zero : Ent (fun _ : Θ => (0 : ℝ)) = 0 := by unfold Ent Vs; simp

/-- The frozen letter. -/
noncomputable def aStar : α := Classical.arbitrary α

/-- Component laws with the coordinates of `B` frozen at `aStar`. -/
noncomputable def Qd (B : Finset ι) (θ : Θ) (i : ι) (a : α) : ℝ :=
  if i ∈ B then (if a = aStar then 1 else 0) else P θ i a

/-- Mass of `x` under component `θ` with `B` frozen. -/
noncomputable def mB (B : Finset ι) (θ : Θ) (x : ι → α) : ℝ := ∏ i, Qd P B θ i (x i)

/-- **Remaining information** `Vs v · I(Θ ; X_{Bᶜ})` under the (unnormalised) posterior `v`:
`Ent v − ∑_x Ent(v · m_x) = Vs·(H(Θ) − H(Θ | X_{Bᶜ}))`. -/
noncomputable def Info (B : Finset ι) (v : Θ → ℝ) : ℝ :=
  Ent v - ∑ x : ι → α, Ent (fun θ => v θ * mB P B θ x)

/-- Mutual information `I_w(Θ;X) = H(Θ) − H(Θ|X)` of the decomposition `(w, P)`. -/
noncomputable def mutInfo (w : Θ → ℝ) : ℝ :=
  Ent w - ∑ x : ι → α, Ent (fun θ => w θ * prodMass (P θ) x)

omit [DecidableEq Θ] [Nonempty Θ] in
theorem info_empty (w : Θ → ℝ) : Info P ∅ w = mutInfo P w := by
  unfold Info mutInfo mB Qd prodMass; simp

/-! ## Slicing a coordinate -/

omit [DecidableEq Θ] [Nonempty Θ] [Nonempty α] in
theorem sum_slice (j : ι) (c c' : α) (K : (ι → α) → ℝ)
    (hK : ∀ y b, K (Function.update y j b) = K y) :
    ∑ y : ι → α, (if y j = c then K y else 0) = ∑ y : ι → α, (if y j = c' then K y else 0) := by
  let e : (ι → α) → (ι → α) := fun y => Function.update y j (Equiv.swap c c' (y j))
  have he : Function.Involutive e := by
    intro y
    simp only [e, Function.update_self, Function.update_idem, Equiv.swap_apply_self,
      Function.update_eq_self]
  rw [← Equiv.sum_comp (he.toPerm e)]
  refine Finset.sum_congr rfl fun y _ => ?_
  simp only [Function.Involutive.coe_toPerm, e, Function.update_self, hK]
  congr 1
  rw [Equiv.swap_apply_eq_iff, Equiv.swap_apply_left]

/-! ## Factorisation at an unqueried coordinate -/

/-- Mass of the coordinates other than `j`. -/
noncomputable def Rj (B : Finset ι) (j : ι) (θ : Θ) (x : ι → α) : ℝ :=
  ∏ i ∈ univ.erase j, Qd P B θ i (x i)

omit [DecidableEq Θ] [Nonempty Θ] in
theorem Rj_update (B : Finset ι) (j : ι) (θ : Θ) (x : ι → α) (b : α) :
    Rj P B j θ (Function.update x j b) = Rj P B j θ x := by
  unfold Rj
  refine Finset.prod_congr rfl fun i hi => ?_
  rw [Function.update_of_ne (Finset.ne_of_mem_erase hi)]

omit [DecidableEq Θ] [Nonempty Θ] in
theorem mB_split (B : Finset ι) (j : ι) (hj : j ∉ B) (θ : Θ) (x : ι → α) :
    mB P B θ x = P θ j (x j) * Rj P B j θ x := by
  unfold mB Rj
  rw [← Finset.mul_prod_erase univ _ (mem_univ j)]
  simp [Qd, hj]

omit [DecidableEq Θ] [Nonempty Θ] in
theorem mB_insert_split (B : Finset ι) (j : ι) (θ : Θ) (x : ι → α) :
    mB P (insert j B) θ x = (if x j = aStar then 1 else 0) * Rj P B j θ x := by
  unfold mB Rj
  rw [← Finset.mul_prod_erase univ _ (mem_univ j)]
  congr 1
  · simp [Qd]
  · refine Finset.prod_congr rfl fun i hi => ?_
    have hij := Finset.ne_of_mem_erase hi
    simp [Qd, Finset.mem_insert, hij]

omit [DecidableEq Θ] [Nonempty Θ] in
/-- Re-indexing the conditional entropies across the children of a query. -/
theorem cond_ent_children (B : Finset ι) (j : ι) (hj : j ∉ B) (v : Θ → ℝ) :
    ∑ b, ∑ x : ι → α, Ent (fun θ => upd P v j b θ * mB P (insert j B) θ x) =
      ∑ x : ι → α, Ent (fun θ => v θ * mB P B θ x) := by
  set E : (ι → α) → ℝ := fun y => Ent (fun θ => v θ * mB P B θ y) with hE
  have hterm : ∀ b x, Ent (fun θ => upd P v j b θ * mB P (insert j B) θ x) =
      if x j = aStar then E (Function.update x j b) else 0 := by
    intro b x
    split_ifs with hx
    · simp only [hE]
      congr 1; funext θ
      rw [mB_insert_split, mB_split P B j hj, Rj_update, hx, if_pos rfl, Function.update_self]
      unfold upd; ring
    · have : (fun θ => upd P v j b θ * mB P (insert j B) θ x) = fun _ => 0 := by
        funext θ; rw [mB_insert_split, if_neg hx]; ring
      rw [this, ent_zero]
  simp only [hterm]
  have hsl : ∀ b, ∑ x : ι → α, (if x j = aStar then E (Function.update x j b) else 0) =
      ∑ x : ι → α, (if x j = b then E x else 0) := by
    intro b
    rw [sum_slice j aStar b (fun y => E (Function.update y j b))
      (fun y c => by simp only [Function.update_idem])]
    refine Finset.sum_congr rfl fun x _ => ?_
    split_ifs with hx
    · rw [← hx, Function.update_eq_self]
    · rfl
  simp only [hsl]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_ite_eq]; simp

include hP0 hP1 in
/-- **Chain rule for the remaining information.** -/
theorem info_chain (B : Finset ι) (j : ι) (hj : j ∉ B) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (hV : 0 < Vs v) :
    ∑ b, Info P (insert j B) (upd P v j b) = Info P B v - ∑ θ, v θ * kl (P θ j) (qmix P v j) := by
  unfold Info
  rw [Finset.sum_sub_distrib, ent_children P hP0 hP1 v hv hV j, cond_ent_children P B j hj v]
  ring

include hP0 hP1 in
theorem kl_sum_ge (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v) (j : ι) :
    ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 ≤ ∑ θ, v θ * kl (P θ j) (qmix P v j) := by
  have h1 := ent_children P hP0 hP1 v hv hV j
  have h2 := ent_drop_ge P hP0 hP1 v hv hV j
  linarith

omit [DecidableEq Θ] [Nonempty Θ] in
theorem info_univ (v : Θ → ℝ) : Info P univ v = 0 := by
  have hm : ∀ θ (x : ι → α), mB P univ θ x = if x = fun _ => aStar then 1 else 0 := by
    intro θ x
    unfold mB Qd
    simp only [Finset.mem_univ, if_true]
    split_ifs with hx
    · subst hx; simp
    · obtain ⟨i, hi⟩ : ∃ i, x i ≠ aStar := by
        by_contra h; push Not at h; exact hx (funext h)
      exact Finset.prod_eq_zero (mem_univ i) (if_neg hi)
  unfold Info
  simp only [hm]
  rw [Finset.sum_eq_single (fun _ => aStar)]
  · simp
  · intro x _ hx; simp [hx, ent_zero]
  · simp

omit [DecidableEq Θ] [Nonempty Θ] in
theorem info_zero (B : Finset ι) : Info P B (fun _ : Θ => 0) = 0 := by
  unfold Info; simp [ent_zero]

include hP0 hP1 in
/-- **Nonnegativity** of the remaining information. -/
theorem info_nonneg : ∀ (n : ℕ) (B : Finset ι) (v : Θ → ℝ), (univ \ B).card = n →
    (∀ θ, 0 ≤ v θ) → 0 ≤ Info P B v := by
  intro n
  induction n with
  | zero =>
    intro B v hc _
    have : B = univ := by
      rw [Finset.card_eq_zero, Finset.sdiff_eq_empty_iff_subset] at hc
      exact Finset.univ_subset_iff.mp hc
    rw [this, info_univ]
  | succ n ih =>
    intro B v hc hv
    obtain ⟨j, hjm⟩ : (univ \ B).Nonempty := Finset.card_pos.mp (by omega)
    have hj : j ∉ B := (Finset.mem_sdiff.mp hjm).2
    have hV0 : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
    rcases hV0.eq_or_lt with h0 | hV
    · have hz : v = fun _ => 0 := funext fun θ =>
        (Finset.sum_eq_zero_iff_of_nonneg (fun θ _ => hv θ)).mp h0.symm θ (mem_univ θ)
      rw [hz, info_zero]
    · have hch := info_chain P hP0 hP1 B j hj v hv hV
      have hcard : (univ \ insert j B).card = n := by
        rw [Finset.sdiff_insert, Finset.card_erase_of_mem hjm, hc]; rfl
      have hkids : 0 ≤ ∑ b, Info P (insert j B) (upd P v j b) :=
        Finset.sum_nonneg fun b _ => ih _ _ hcard fun θ => mul_nonneg (hv θ) (hP0 θ j b)
      have hkl := kl_sum_ge P hP0 hP1 v hv hV j
      have htv : 0 ≤ ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 :=
        Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (sq_nonneg _)
      linarith

/-! ## The remaining-information tree -/

/-- Increment potential plus remaining-information potential (depends on the queried set). -/
noncomputable def PotW (ga gb : ℝ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ :=
  Phi P v g / ga + Info P A v / gb

def GoodW (ga gb : ℝ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) : Prop :=
  ∑ b, PotW P ga gb (insert j A) (upd P v j b) (sect g j b) + Vs v ≤ PotW P ga gb A v g

section WTree


open Classical in
/-- The simulating tree for the mixture. -/
noncomputable def wbuild (τ ga gb : ℝ) :
    ℕ → Finset ι → (Θ → ℝ) → ((ι → α) → ℝ) → DTree ι α
  | 0, _, v, g => .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g))
  | n + 1, A, v, g =>
    if h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j then
      .node h.choose
        (fun b => wbuild τ ga gb n (insert h.choose A) (upd P v h.choose b) (sect g h.choose b))
    else .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g))

variable (τ ga gb : ℝ)

theorem wbuild_zero (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) :
    wbuild P τ ga gb 0 A v g = .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) := rfl

theorem wbuild_pos (n : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j) :
    wbuild P τ ga gb (n + 1) A v g = .node h.choose
      (fun b => wbuild P τ ga gb n (insert h.choose A) (upd P v h.choose b)
        (sect g h.choose b)) := by
  rw [wbuild, dif_pos h]

theorem wbuild_neg (n : ℕ) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (h : ¬ ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j) :
    wbuild P τ ga gb (n + 1) A v g = .leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) := by
  rw [wbuild, dif_neg h]

/-- The tree never reads a coordinate of `A`. -/
theorem wbuild_inv (n : ℕ) : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ),
    ∀ i ∈ A, ∀ x b,
      (wbuild P τ ga gb n A v g).eval (Function.update x i b) = (wbuild P τ ga gb n A v g).eval x ∧
      (wbuild P τ ga gb n A v g).bad (Function.update x i b) = (wbuild P τ ga gb n A v g).bad x ∧
      (wbuild P τ ga gb n A v g).queries (Function.update x i b) =
        (wbuild P τ ga gb n A v g).queries x := by
  induction n with
  | zero => intro A v g i _ x b; simp [wbuild_zero, DTree.eval, DTree.bad, DTree.queries]
  | succ n ih =>
    intro A v g i hi x b
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j
    · rw [wbuild_pos P τ ga gb n A v g h]
      have hj := h.choose_spec
      have hne : i ≠ h.choose := fun hij => hj.1 (hij ▸ hi)
      have hxj : Function.update x i b h.choose = x h.choose := Function.update_of_ne hne.symm _ _
      have := ih (insert h.choose A) (upd P v h.choose (x h.choose))
        (sect g h.choose (x h.choose)) i (Finset.mem_insert_of_mem hi) x b
      simp only [DTree.eval, DTree.bad, DTree.queries, hxj]
      exact ⟨this.1, this.2.1, by rw [this.2.2]⟩
    · rw [wbuild_neg P τ ga gb n A v g h]
      simp [DTree.eval, DTree.bad, DTree.queries]

theorem wqueries_le (n : ℕ) : ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ) x,
    (wbuild P τ ga gb n A v g).queries x ≤ n := by
  induction n with
  | zero => intro A v g x; simp [wbuild_zero, DTree.queries]
  | succ n ih =>
    intro A v g x
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j
    · rw [wbuild_pos P τ ga gb n A v g h]
      simp only [DTree.queries]
      exact Nat.succ_le_succ (ih _ _ _ x)
    · rw [wbuild_neg P τ ga gb n A v g h]
      simp [DTree.queries]


include hP0 hP1 in
theorem PotW_nonneg (hga : 0 < ga) (hgb : 0 < gb) (A : Finset ι) (v : Θ → ℝ)
    (hv : ∀ θ, 0 ≤ v θ) (g : (ι → α) → ℝ) : 0 ≤ PotW P ga gb A v g := by
  unfold PotW
  have h1 : 0 ≤ Phi P v g := Finset.sum_nonneg fun θ _ =>
    mul_nonneg (hv θ) (Finset.sum_nonneg fun k _ => pincr_nonneg (P θ) (hP0 θ) g k)
  have h2 : 0 ≤ Info P A v := info_nonneg P hP0 hP1 _ A v rfl hv
  positivity

include hP0 hP1 in
/-- **Potential bound** for the mixture tree: `E[queries] ≤ Ψ`. -/
theorem wexpected (hga : 0 < ga) (hgb : 0 < gb) (n : ℕ) :
    ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => ((wbuild P τ ga gb n A v g).queries x : ℝ)) ≤ PotW P ga gb A v g := by
  induction n with
  | zero =>
    intro A v g hv
    simp only [wbuild_zero, DTree.queries, Nat.cast_zero]
    rw [Ex_const P hP1, zero_mul]
    exact PotW_nonneg P hP0 hP1 ga gb hga hgb A v hv g
  | succ n ih =>
    intro A v g hv
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j
    · rw [wbuild_pos P τ ga gb n A v g h]
      set j := h.choose with hjdef
      have hj := h.choose_spec
      rw [← hjdef] at hj
      have hsplit := Ex_split P hP1 v j
        (fun c x => ((wbuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).queries x : ℝ))
        (fun c x b => by
          rw [(wbuild_inv P τ ga gb n (insert j A) (upd P v j c) (sect g j c) j
            (Finset.mem_insert_self j A) x b).2.2])
      have hexp : Ex P v (fun x => (((DTree.node j fun c =>
            wbuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).queries x : ℕ) : ℝ)) =
          Ex P v (fun x => ((wbuild P τ ga gb n (insert j A) (upd P v j (x j))
            (sect g j (x j))).queries x : ℝ)) + Vs v := by
        simp only [DTree.queries, Nat.cast_add, Nat.cast_one]
        rw [Ex_add, Ex_const P hP1, one_mul]
      rw [hexp, hsplit]
      have hc : ∀ b, Ex P (upd P v j b)
          (fun x => ((wbuild P τ ga gb n (insert j A) (upd P v j b) (sect g j b)).queries x : ℝ))
          ≤ PotW P ga gb (insert j A) (upd P v j b) (sect g j b) :=
        fun b => ih _ _ _ (fun θ => mul_nonneg (hv θ) (hP0 θ j b))
      have := Finset.sum_le_sum fun b (_ : b ∈ univ) => hc b
      have hg := hj.2.2
      unfold GoodW at hg
      linarith
    · rw [wbuild_neg P τ ga gb n A v g h]
      simp only [DTree.queries, Nat.cast_zero]
      rw [Ex_const P hP1, zero_mul]
      exact PotW_nonneg P hP0 hP1 ga gb hga hgb A v hv g

include hP0 hP1 in
/-- **Leaf error** for the mixture tree. -/
theorem wleaf_error (hτ : 0 ≤ τ) (n : ℕ) :
    ∀ (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => if (wbuild P τ ga gb n A v g).bad x then 0
        else (g x - (wbuild P τ ga gb n A v g).eval x) ^ 2) ≤ τ * Vs v := by
  have hleaf : ∀ (v : Θ → ℝ) (g : (ι → α) → ℝ), (∀ θ, 0 ≤ v θ) →
      Ex P v (fun x => if (DTree.leaf (mmean P v g) (decide (τ * Vs v < mvar P v g)) :
        DTree ι α).bad x then 0 else (g x - (DTree.leaf (mmean P v g)
          (decide (τ * Vs v < mvar P v g)) : DTree ι α).eval x) ^ 2) ≤ τ * Vs v := by
    intro v g hv
    have hV : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
    simp only [DTree.bad, DTree.eval]
    by_cases hlt : τ * Vs v < mvar P v g
    · simp only [hlt, decide_true, ite_true]
      rw [Ex_const P hP1, zero_mul]
      positivity
    · simp only [hlt, decide_false, Bool.false_eq_true, ite_false]
      push Not at hlt
      exact hlt
  induction n with
  | zero => intro A v g hv; rw [wbuild_zero]; exact hleaf v g hv
  | succ n ih =>
    intro A v g hv
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j
    · rw [wbuild_pos P τ ga gb n A v g h]
      set j := h.choose
      have hsplit := Ex_split P hP1 v j
        (fun c x => if (wbuild P τ ga gb n (insert j A) (upd P v j c) (sect g j c)).bad x then 0
          else (sect g j c x - (wbuild P τ ga gb n (insert j A) (upd P v j c)
            (sect g j c)).eval x) ^ 2)
        (fun c x b => by
          have hi := wbuild_inv P τ ga gb n (insert j A) (upd P v j c) (sect g j c) j
            (Finset.mem_insert_self j A) x b
          simp only [hi.1, hi.2.1, inv_sect_self g j c x b])
      have hlhs : (fun x => if (DTree.node j fun c => wbuild P τ ga gb n (insert j A)
            (upd P v j c) (sect g j c)).bad x then (0 : ℝ)
          else (g x - (DTree.node j fun c => wbuild P τ ga gb n (insert j A)
            (upd P v j c) (sect g j c)).eval x) ^ 2) =
          (fun x => (fun c x => if (wbuild P τ ga gb n (insert j A) (upd P v j c)
            (sect g j c)).bad x then 0 else (sect g j c x - (wbuild P τ ga gb n (insert j A)
              (upd P v j c) (sect g j c)).eval x) ^ 2) (x j) x) := by
        funext x
        simp only [DTree.bad, DTree.eval]
        congr 2
        rw [sect_self g j x]
      rw [hlhs, hsplit]
      calc ∑ b, Ex P (upd P v j b) (fun x => if (wbuild P τ ga gb n (insert j A)
              (upd P v j b) (sect g j b)).bad x then 0 else (sect g j b x -
                (wbuild P τ ga gb n (insert j A) (upd P v j b) (sect g j b)).eval x) ^ 2)
          ≤ ∑ b, τ * Vs (upd P v j b) :=
            Finset.sum_le_sum fun b _ => ih _ _ _ (fun θ => mul_nonneg (hv θ) (hP0 θ j b))
        _ = τ * Vs v := by rw [← Finset.mul_sum, Vs_upd_sum P hP1]
    · rw [wbuild_neg P τ ga gb n A v g h]
      exact hleaf v g hv

/-- Unfinished leaves need the full fuel, given that any state in the invariant `S` with large
variance has a good query outside `A`. -/
theorem wbad_queries (S : Finset ι → (Θ → ℝ) → ((ι → α) → ℝ) → Prop)
    (hpres : ∀ A v g j b, S A v g → j ∉ A → S (insert j A) (upd P v j b) (sect g j b))
    (hgood : ∀ A v g, S A v g → τ * Vs v < mvar P v g → ∃ j, j ∉ A ∧ GoodW P ga gb A v g j)
    (n : ℕ) : ∀ A v g, S A v g → ∀ x,
      (wbuild P τ ga gb n A v g).bad x = true → (wbuild P τ ga gb n A v g).queries x = n := by
  induction n with
  | zero => intro A v g _ x _; simp [wbuild_zero, DTree.queries]
  | succ n ih =>
    intro A v g hS x hb
    by_cases h : ∃ j, j ∉ A ∧ τ * Vs v < mvar P v g ∧ GoodW P ga gb A v g j
    · rw [wbuild_pos P τ ga gb n A v g h] at hb ⊢
      simp only [DTree.bad] at hb
      simp only [DTree.queries]
      rw [ih _ _ _ (hpres A v g _ _ hS h.choose_spec.1) x hb]
    · exfalso
      rw [wbuild_neg P τ ga gb n A v g h] at hb
      simp only [DTree.bad, decide_eq_true_eq] at hb
      obtain ⟨j, hjA, hj⟩ := hgood A v g hS hb
      exact h ⟨j, hjA, hb, hj⟩


end WTree

include hP0 hP1 in
/-- **Good query (Wyner form).** Same crux; the information case is charged to `Info`. -/
theorem good_exists_wyner (f : (ι → α) → ℝ) (d : ℕ) (hd : 1 ≤ d) (K : ℝ) (hK : 0 < K)
    (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (A : Finset ι) (v : Θ → ℝ) (g : (ι → α) → ℝ)
    (hS : StD f K d A v g) (hvar : τ * Vs v < mvar P v g) :
    ∃ j, j ∉ A ∧ GoodW P (2 * gam d τ) (etaC d τ ^ 2 * w0C K d τ) A v g j := by
  obtain ⟨⟨hv, hinv, hrows, _, hg01⟩, hdeg⟩ := hS
  have hV := Vs_pos_of_var P v hv g τ hvar
  have hγ := gam_pos d τ hτ
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hη : 0 < etaC d τ := by unfold etaC; positivity
  have hw : 0 < w0C K d τ := by unfold w0C; positivity
  set ga := 2 * gam d τ with hga
  set gb := etaC d τ ^ 2 * w0C K d τ with hgb
  have hga0 : 0 < ga := by positivity
  have hgb0 : 0 < gb := by positivity
  obtain ⟨j, hjA, hj⟩ := crux P hP0 hP1 v hv hV g hg01 d hd hdeg K hK hrows A hinv τ hτ hτ1 hvar
  refine ⟨j, hjA, ?_⟩
  unfold GoodW PotW
  rw [Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.sum_div, Phi_sum P hP1 v g j,
    info_chain P hP0 hP1 A j hjA v hv hV]
  have hkl := kl_sum_ge P hP0 hP1 v hv hV j
  have hinc0 : 0 ≤ ∑ θ, v θ * pincr (P θ) g j :=
    Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (pincr_nonneg (P θ) (hP0 θ) g j)
  have htv0 : 0 ≤ ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 :=
    Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (sq_nonneg _)
  rcases hj with hinc | hinfo
  · have h1 : (Phi P v g - ∑ θ, v θ * pincr (P θ) g j) / ga ≤ Phi P v g / ga - Vs v := by
      rw [sub_div]
      have : Vs v ≤ (∑ θ, v θ * pincr (P θ) g j) / ga := by rw [le_div_iff₀ hga0]; linarith
      linarith
    have h2 : (Info P A v - ∑ θ, v θ * kl (P θ j) (qmix P v j)) / gb ≤ Info P A v / gb :=
      div_le_div_of_nonneg_right (by linarith) hgb0.le
    linarith
  · have h1 : (Phi P v g - ∑ θ, v θ * pincr (P θ) g j) / ga ≤ Phi P v g / ga :=
      div_le_div_of_nonneg_right (by linarith) hga0.le
    have h2 : (Info P A v - ∑ θ, v θ * kl (P θ j) (qmix P v j)) / gb ≤ Info P A v / gb - Vs v := by
      have : Info P A v - ∑ θ, v θ * kl (P θ j) (qmix P v j) ≤ Info P A v - gb * Vs v := by
        rw [hgb]; linarith
      rw [le_sub_iff_add_le, div_add' _ _ _ hgb0.ne', div_le_div_iff_of_pos_right hgb0]
      linarith
    linarith

/-! ## The theorem for a fixed decomposition -/

include hP0 hP1 in
/-- **Route 1, mutual-information form.** For any finite product decomposition `(w, P)` of the
source, the `log M` of `route1_polylog_simulation` is replaced by `I_w(Θ;X)`. -/
theorem route1_wyner_simulation (w : Θ → ℝ) (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ) (hd : 1 ≤ d)
    (hdeg : HasProdDegreeLE f d) (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      Ex P w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          mutInfo P w /
            (etaC d τ ^ 2 * w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n + τ / ε ^ 2 := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set K : ℝ := Real.pi ^ 2 * (d : ℝ) ^ 2 / 2 with hKdef
  have hK : 0 < K := by positivity
  have hγ := gam_pos d τ hτ
  set ga := 2 * gam d τ with hgadef
  set gb := etaC d τ ^ 2 * w0C K d τ with hgbdef
  have hga : 0 < ga := by positivity
  have hgb : 0 < gb := by
    have : 0 < etaC d τ := by unfold etaC; positivity
    have : 0 < w0C K d τ := by unfold w0C; positivity
    positivity
  set t := wbuild P τ ga gb n ∅ w f with htdef
  refine ⟨t, wqueries_le P τ ga gb n ∅ w f, ?_⟩
  have hS0 : StD f K d ∅ w f :=
    ⟨⟨hw0, fun i hi => absurd hi (Finset.notMem_empty i), hasRows_of_degree f d hf01 hdeg,
      rep_empty f, hf01⟩, hdeg⟩
  have hbq := wbad_queries P τ ga gb (StD f K d)
    (fun A v g j b hS hj => StD_pres P hP0 f K d A v g j b hS hj)
    (fun A v g hS hvar => good_exists_wyner P hP0 hP1 f d hd K hK τ hτ hτ1 A v g hS hvar)
    n ∅ w f hS0
  have hq := wexpected P hP0 hP1 τ ga gb hga hgb n ∅ w f hw0
  have herr := wleaf_error P hP0 hP1 τ ga gb hτ.le n ∅ w f hw0
  have hVw : Vs w = 1 := hw1
  rw [hVw, mul_one] at herr
  have hε2 : 0 < ε ^ 2 := by positivity
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hpt : ∀ x, (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (t.queries x : ℝ) / n + (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    intro x
    by_cases hb : t.bad x = true
    · have hqn : (t.queries x : ℝ) = n := by exact_mod_cast hbq x hb
      rw [hqn, div_self hn'.ne']
      simp only [hb, ite_true, zero_div, add_zero]
      split_ifs <;> norm_num
    · simp only [hb, Bool.false_eq_true, ite_false]
      have hq0 : 0 ≤ (t.queries x : ℝ) / n := by positivity
      split_ifs with hlt
      · have h1 : ε ^ 2 < (f x - t.eval x) ^ 2 := by
          have := pow_lt_pow_left₀ hlt hε.le two_ne_zero; rwa [sq_abs] at this
        have : 1 ≤ (f x - t.eval x) ^ 2 / ε ^ 2 := by rw [le_div_iff₀ hε2, one_mul]; exact h1.le
        linarith
      · have : 0 ≤ (f x - t.eval x) ^ 2 / ε ^ 2 := by positivity
        linarith
  have hmono := Ex_mono P w hw0 hP0 _ _ hpt
  have hsplit : Ex P w (fun x => (t.queries x : ℝ) / n +
      (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2) =
      Ex P w (fun x => (t.queries x : ℝ)) / n +
        Ex P w (fun x => if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    rw [Ex_add]
    unfold Ex pexp
    congr 1
    · rw [Finset.sum_div]
      refine Finset.sum_congr rfl fun θ _ => ?_
      rw [mul_div_assoc, Finset.sum_div]
      congr 1
      exact Finset.sum_congr rfl fun x _ => by ring
    · rw [Finset.sum_div]
      refine Finset.sum_congr rfl fun θ _ => ?_
      rw [mul_div_assoc, Finset.sum_div]
      congr 1
      exact Finset.sum_congr rfl fun x _ => by ring
  rw [hsplit] at hmono
  have hPot : PotW P ga gb ∅ w f ≤ K / ga + mutInfo P w / gb := by
    unfold PotW
    have hPhi : Phi P w f ≤ K := by
      unfold Phi
      obtain ⟨a, hr, hKa⟩ := hasRows_of_degree f d hf01 hdeg
      calc ∑ θ, w θ * Ltot (P θ) f ≤ ∑ θ, w θ * K :=
            Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left
              (sum_pincr_le (P θ) (hP0 θ) (hP1 θ) f a hr K hKa) (hw0 θ)
        _ = K := by rw [← Finset.sum_mul, hw1, one_mul]
    have h1 : Phi P w f / ga ≤ K / ga := div_le_div_of_nonneg_right hPhi hga.le
    have h2 : Info P ∅ w / gb ≤ mutInfo P w / gb := by rw [info_empty]
    linarith
  have hfinal : Ex P w (fun x => (t.queries x : ℝ)) / n ≤
      (K / ga + mutInfo P w / gb) / n :=
    div_le_div_of_nonneg_right (hq.trans hPot) hn'.le
  have herr' : Ex P w (fun x => if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 ≤ τ / ε ^ 2 :=
    div_le_div_of_nonneg_right herr hε2.le
  linarith


/-! ## Wyner common information -/

section Wyner

/-- Values `I_w(Θ;X)` over all finite-latent product decompositions of the mass function `ν`. -/
def wynerSet (ν : (ι → α) → ℝ) : Set ℝ :=
  {s | ∃ (k : ℕ) (w : Fin k → ℝ) (Q : Fin k → ι → α → ℝ), (∀ θ, 0 ≤ w θ) ∧ ∑ θ, w θ = 1 ∧
    (∀ θ i a, 0 ≤ Q θ i a) ∧ (∀ θ i, ∑ a, Q θ i a = 1) ∧
    (∀ x, ν x = ∑ θ, w θ * prodMass (Q θ) x) ∧ s = mutInfo Q w}

/-- (Finite-latent) **Wyner common information** of `ν`: the infimum of `I(Θ;X)` over latents
`Θ` that render the coordinates conditionally independent. -/
noncomputable def wynerCI (ν : (ι → α) → ℝ) : ℝ := sInf (wynerSet ν)

/-- **Route 1, Wyner form.** If `ν` has a finite product decomposition, then for every
`s > C_W(ν)` there is a depth-`n` tree with
`Pr_ν[|f − tree| > ε] ≤ (K/(2γ) + s/(η² w₀))/n + τ/ε²`, i.e. depth
`poly(d, 1/ε, 1/δ) · (1 + C_W(ν))`. No dependence on the number of components. -/
theorem route1_wyner_CI (ν : (ι → α) → ℝ) (hne : (wynerSet ν).Nonempty)
    (f : (ι → α) → ℝ) (hf01 : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (d : ℕ) (hd : 1 ≤ d)
    (hdeg : HasProdDegreeLE f d) (τ : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (ε : ℝ) (hε : 0 < ε)
    (n : ℕ) (hn : 0 < n) (s : ℝ) (hs : wynerCI ν < s) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
        ((Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) / (2 * gam d τ) +
          s / (etaC d τ ^ 2 * w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ)) / n + τ / ε ^ 2 := by
  obtain ⟨s0, ⟨k, w, Q, hw0, hw1, hQ0, hQ1, hν, rfl⟩, hlt⟩ := exists_lt_of_csInf_lt hne hs
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with h0 | h
    · subst h0; simp at hw1
    · exact h
  haveI : Nonempty (Fin k) := ⟨⟨0, hk⟩⟩
  obtain ⟨t, htq, hb⟩ := route1_wyner_simulation Q hQ0 hQ1 w hw0 hw1 f hf01 d hd hdeg τ hτ hτ1 ε hε
    n hn
  refine ⟨t, htq, ?_⟩
  have hEx : Ex Q w (fun x => if ε < |f x - t.eval x| then (1 : ℝ) else 0) =
      ∑ x, ν x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) := by
    unfold Ex pexp
    simp only [hν, Finset.mul_sum, Finset.sum_mul]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun θ _ => by ring
  rw [← hEx]
  refine hb.trans ?_
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hγ := gam_pos d τ hτ
  have hgb : 0 < etaC d τ ^ 2 * w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ := by
    have : 0 < etaC d τ := by unfold etaC; positivity
    have : 0 < w0C (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) d τ := by unfold w0C; positivity
    positivity
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  gcongr

end Wyner

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.info_chain
#print axioms Nightfall.Route1Polylog.info_nonneg
#print axioms Nightfall.Route1Polylog.route1_wyner_simulation
#print axioms Nightfall.Route1Polylog.route1_wyner_CI
