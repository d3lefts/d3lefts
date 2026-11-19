import ProductInfluence

/-!
# NIGHTFALL — classical simulation by decision trees, uniform over product laws

For a function `f` on a finite product `ι → α` with any product law `p` (zero masses allowed)
that has, at every point, a fractional-certificate row of cost at most `K`, we build a
deterministic decision tree that queries at most `n` coordinates on every input and outputs
`Q̃(x)` with

  `Pr_{x ∼ p} [ |f x - Q̃ x| > ε ] ≤ K / (η n) + τ / ε²`   whenever `144 K⁴ η² ≤ τ³`

(`simulation_rows`). The tree queries a coordinate whose mean absolute increment is at least `η`
while the variance of the current section exceeds `τ`, and otherwise outputs the mean.

The analysis uses three facts, none of which mentions the masses:

* the total mean absolute increment `L(g) = ∑_k pincr p g k` is at most the row cost
  (`Influence.sum_pincr_le`) and drops on average by `pincr p g j` when `x_j` is fixed
  (`sum_mul_Ltot_sect`);
* a section with variance above `τ` has a coordinate with increment at least `η`
  (`Influence.mean_increment`, Turturean's Theorem 7.10 on product spaces);
* the leaf error is the variance of the leaf section (Chebyshev).

For `f` with values in `[0,1]` and interaction degree at most `d` (the acceptance probability of a
quantum algorithm with `T` queries has `d = 2T`), rows of cost `π² d² / 2` exist
(`RowBound.product_row_bound` applied to `2f - 1`), and `simulation_degree` gives depth `n` with
`n · ε³ δ² √δ ≥ 6 √2 π⁶ d⁶` and error probability at most `δ`: depth
`O(d⁶ ε⁻³ δ^{-5/2})`, with no dependence on the alphabet, the masses or the number of coordinates.
-/

namespace Nightfall.ProductSpace.Simulation

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound

/-- Deterministic decision trees over `ι → α` with real outputs and a flag for unfinished leaves. -/
inductive DTree (ι α : Type) where
  | leaf (v : ℝ) (bad : Bool)
  | node (j : ι) (t : α → DTree ι α)

namespace DTree

variable {ι α : Type}

def eval : DTree ι α → (ι → α) → ℝ
  | leaf v _, _ => v
  | node j t, x => eval (t (x j)) x

def bad : DTree ι α → (ι → α) → Bool
  | leaf _ b, _ => b
  | node j t, x => bad (t (x j)) x

/-- Number of coordinates queried on input `x`. -/
def queries : DTree ι α → (ι → α) → ℕ
  | leaf _ _, _ => 0
  | node j t, x => queries (t (x j)) x + 1

end DTree

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-- The section `x ↦ g (x_j := c)`. -/
def sect (g : (ι → α) → ℝ) (j : ι) (c : α) : (ι → α) → ℝ := fun x => g (Function.update x j c)

/-- `g` does not depend on coordinate `i`. -/
def Inv (g : (ι → α) → ℝ) (i : ι) : Prop := ∀ x b, g (Function.update x i b) = g x

theorem inv_sect_self (g : (ι → α) → ℝ) (j : ι) (c : α) : Inv (sect g j c) j := by
  intro x b
  simp [sect]

theorem inv_sect {g : (ι → α) → ℝ} {i : ι} (hg : Inv g i) (j : ι) (hij : i ≠ j) (c : α) :
    Inv (sect g j c) i := by
  intro x b
  simp only [sect]
  rw [Function.update_comm hij, hg]

theorem sect_self (g : (ι → α) → ℝ) (j : ι) (x : ι → α) : sect g j (x j) x = g x := by
  simp [sect]

/-- Total mean absolute increment. -/
noncomputable def Ltot (p : ι → α → ℝ) (g : (ι → α) → ℝ) : ℝ := ∑ k, pincr p g k

theorem pincr_eq_zero_of_inv (p : ι → α → ℝ) {g : (ι → α) → ℝ} {i : ι} (hg : Inv g i) :
    pincr p g i = 0 := by
  unfold pincr
  refine Finset.sum_eq_zero fun x _ => Finset.sum_eq_zero fun b _ => ?_
  rw [hg x b, sub_self, abs_zero, mul_zero]

/-- Conditioning on coordinate `j`: for integrands that ignore `x_j` once `c` is fixed. -/
theorem sum_split (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1) (j : ι)
    (H : α → (ι → α) → ℝ) (hH : ∀ c x b, H c (Function.update x j b) = H c x) :
    ∑ x, prodMass p x * H (x j) x = ∑ c, p j c * ∑ x, prodMass p x * H c x := by
  have h := resample_sum p hp1 j (fun y => H (y j) y)
  simp only [Function.update_self, hH] at h
  rw [← h, Finset.sum_comm]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- Averaging a section's increments over the fixed value recovers the increment (`k ≠ j`). -/
theorem sum_mul_pincr_sect (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (j k : ι) (hkj : k ≠ j) :
    ∑ c, p j c * pincr p (sect g j c) k = pincr p g k := by
  let F : (ι → α) → ℝ := fun y => ∑ b, p k b * |g y - g (Function.update y k b)|
  have hs : ∀ c, pincr p (sect g j c) k = ∑ x, prodMass p x * F (Function.update x j c) := by
    intro c
    unfold pincr
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [F, sect, Finset.mul_sum]
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [Function.update_comm hkj]
    ring
  have hg : pincr p g k = ∑ x, prodMass p x * F x := by
    unfold pincr
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [F, Finset.mul_sum]
    exact Finset.sum_congr rfl fun b _ => by ring
  simp only [hs, hg]
  rw [← resample_sum p hp1 j F, Finset.sum_comm]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

theorem sum_mul_Ltot_sect (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (j : ι) :
    ∑ c, p j c * Ltot p (sect g j c) = Ltot p g - pincr p g j := by
  unfold Ltot
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]
  rw [← Finset.add_sum_erase _ _ (mem_univ j), ← Finset.add_sum_erase _ _ (mem_univ j)]
  have h0 : ∑ c, p j c * pincr p (sect g j c) j = 0 :=
    Finset.sum_eq_zero fun c _ => by rw [pincr_eq_zero_of_inv p (inv_sect_self g j c), mul_zero]
  rw [h0, zero_add]
  have : ∑ k ∈ univ.erase j, ∑ c, p j c * pincr p (sect g j c) k =
      ∑ k ∈ univ.erase j, pincr p g k :=
    Finset.sum_congr rfl fun k hk => sum_mul_pincr_sect p hp1 g j k (Finset.ne_of_mem_erase hk)
  rw [this]
  ring

/-! ## Rows -/

/-- `g` has a fractional-certificate row of cost at most `K` at every point. -/
def HasRows (g : (ι → α) → ℝ) (K : ℝ) : Prop :=
  ∃ a : (ι → α) → ι → ℝ, RealRow g a ∧ ∀ x, ∑ j, a x j ≤ K

theorem hasRows_sect {g : (ι → α) → ℝ} {K : ℝ} (h : HasRows g K) (j : ι) (c : α) :
    HasRows (sect g j c) K := by
  obtain ⟨a, ⟨ha0, hacov⟩, hK⟩ := h
  refine ⟨fun x => a (Function.update x j c), ⟨fun x i => ha0 _ i, fun x y => ?_⟩,
    fun x => hK _⟩
  refine (hacov _ _).trans (Finset.sum_le_sum_of_subset_of_nonneg ?_ fun i _ _ => ha0 _ i)
  intro i hi
  simp only [Transfer.disagree, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  by_cases hij : i = j
  · subst hij; simp at hi
  · simpa [Function.update_of_ne hij] using hi

/-! ## The tree -/

/-- The simulating tree with `n` queries of fuel. -/
noncomputable def build (p : ι → α → ℝ) (τ η : ℝ) : ℕ → ((ι → α) → ℝ) → DTree ι α
  | 0, g => .leaf (pexp p g) (decide (τ < pvar p g))
  | n + 1, g =>
    if h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j then
      .node h.choose (fun c => build p τ η n (sect g h.choose c))
    else .leaf (pexp p g) (decide (τ < pvar p g))

variable (p : ι → α → ℝ) (τ η : ℝ)

theorem build_zero (g : (ι → α) → ℝ) :
    build p τ η 0 g = .leaf (pexp p g) (decide (τ < pvar p g)) := rfl

theorem build_pos (n : ℕ) (g : (ι → α) → ℝ) (h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j) :
    build p τ η (n + 1) g = .node h.choose (fun c => build p τ η n (sect g h.choose c)) := by
  rw [build, dif_pos h]

theorem build_neg (n : ℕ) (g : (ι → α) → ℝ) (h : ¬ ∃ j, τ < pvar p g ∧ η ≤ pincr p g j) :
    build p τ η (n + 1) g = .leaf (pexp p g) (decide (τ < pvar p g)) := by
  rw [build, dif_neg h]

/-- The tree never reads a coordinate its function ignores. -/
theorem build_inv (hη : 0 < η) (n : ℕ) :
    ∀ (g : (ι → α) → ℝ) (i : ι), Inv g i → ∀ x b,
      (build p τ η n g).eval (Function.update x i b) = (build p τ η n g).eval x ∧
      (build p τ η n g).bad (Function.update x i b) = (build p τ η n g).bad x ∧
      (build p τ η n g).queries (Function.update x i b) = (build p τ η n g).queries x := by
  induction n with
  | zero => intro g i _ x b; simp [build_zero, DTree.eval, DTree.bad, DTree.queries]
  | succ n ih =>
    intro g i hg x b
    by_cases h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j
    · rw [build_pos p τ η n g h]
      have hj := h.choose_spec
      have hne : i ≠ h.choose := by
        intro hij
        have h0 := pincr_eq_zero_of_inv p hg
        rw [hij] at h0
        linarith [hj.2]
      have hxj : Function.update x i b h.choose = x h.choose := Function.update_of_ne hne.symm _ _
      have := ih (sect g h.choose (x h.choose)) i (inv_sect hg h.choose hne _) x b
      simp only [DTree.eval, DTree.bad, DTree.queries, hxj]
      exact ⟨this.1, this.2.1, by rw [this.2.2]⟩
    · rw [build_neg p τ η n g h]
      simp [DTree.eval, DTree.bad, DTree.queries]

theorem queries_le (n : ℕ) : ∀ (g : (ι → α) → ℝ) x, (build p τ η n g).queries x ≤ n := by
  induction n with
  | zero => intro g x; simp [build_zero, DTree.queries]
  | succ n ih =>
    intro g x
    by_cases h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j
    · rw [build_pos p τ η n g h]
      simp only [DTree.queries]
      exact Nat.succ_le_succ (ih _ x)
    · rw [build_neg p τ η n g h]
      simp [DTree.queries]

variable (hp : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
include hp hp1

/-- **Potential bound**: `η · E[queries] ≤ L(g)`. -/
theorem expected_queries (hη : 0 < η) (n : ℕ) :
    ∀ g : (ι → α) → ℝ,
      η * ∑ x, prodMass p x * ((build p τ η n g).queries x : ℝ) ≤ Ltot p g := by
  have hL0 : ∀ g : (ι → α) → ℝ, 0 ≤ Ltot p g :=
    fun g => Finset.sum_nonneg fun k _ => pincr_nonneg p hp g k
  induction n with
  | zero => intro g; simp [build_zero, DTree.queries, hL0 g]
  | succ n ih =>
    intro g
    by_cases h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j
    · rw [build_pos p τ η n g h]
      set j := h.choose with hjdef
      have hj := h.choose_spec
      rw [← hjdef] at hj
      have hsplit := sum_split p hp1 j
        (fun c x => ((build p τ η n (sect g j c)).queries x : ℝ))
        (fun c x b => by
          rw [(build_inv p τ η hη n (sect g j c) j (inv_sect_self g j c) x b).2.2])
      have hexp : ∑ x, prodMass p x * (((DTree.node j fun c => build p τ η n (sect g j c)).queries
          x : ℕ) : ℝ) = ∑ c, p j c * ∑ x, prodMass p x * ((build p τ η n (sect g j c)).queries x : ℝ)
            + 1 := by
        simp only [DTree.queries, Nat.cast_add, Nat.cast_one, mul_add, mul_one,
          Finset.sum_add_distrib, sum_prodMass p hp1]
        rw [hsplit]
      rw [hexp, mul_add, mul_one, Finset.mul_sum]
      have hc : ∀ c, η * (p j c * ∑ x, prodMass p x * ((build p τ η n (sect g j c)).queries x : ℝ))
          ≤ p j c * Ltot p (sect g j c) := by
        intro c
        rw [mul_left_comm]
        exact mul_le_mul_of_nonneg_left (ih _) (hp j c)
      have hsum := Finset.sum_le_sum fun c (_ : c ∈ univ) => hc c
      rw [sum_mul_Ltot_sect p hp1 g j] at hsum
      linarith [hj.2]
    · rw [build_neg p τ η n g h]
      simp [DTree.queries, hL0 g]

/-- Unfinished leaves are reached only after the full `n` queries. -/
theorem bad_queries {K : ℝ} (hK : 0 < K) (hτ : 0 ≤ τ) (hη : 0 ≤ η)
    (hητ : 144 * K ^ 4 * η ^ 2 ≤ τ ^ 3) (n : ℕ) :
    ∀ g : (ι → α) → ℝ, HasRows g K → ∀ x,
      (build p τ η n g).bad x = true → (build p τ η n g).queries x = n := by
  induction n with
  | zero => intro g _ x _; simp [build_zero, DTree.queries]
  | succ n ih =>
    intro g hg x hb
    by_cases h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j
    · rw [build_pos p τ η n g h] at hb ⊢
      simp only [DTree.bad] at hb
      simp only [DTree.queries]
      rw [ih _ (hasRows_sect hg _ _) x hb]
    · exfalso
      rw [build_neg p τ η n g h] at hb
      simp only [DTree.bad, decide_eq_true_eq] at hb
      apply h
      obtain ⟨a, hr, hKa⟩ := hg
      have hV : 0 < pvar p g := lt_of_le_of_lt hτ hb
      obtain ⟨j, hj⟩ := mean_increment p hp hp1 g a hr K hKa hV
      refine ⟨j, hb, ?_⟩
      by_contra hlt
      push_neg at hlt
      have h0 := pincr_nonneg p hp g j
      have h1 : pincr p g j ^ 2 < η ^ 2 := pow_lt_pow_left₀ hlt h0 two_ne_zero
      have h2 : τ ^ 3 < pvar p g ^ 3 := pow_lt_pow_left₀ hb hτ (by norm_num)
      have hK4 : 0 < 144 * K ^ 4 := by positivity
      have h3 := mul_lt_mul_of_pos_left h1 hK4
      linarith

/-- **Leaf error**: `E[(g - Q̃)²; finished leaf] ≤ τ`. -/
theorem leaf_error (hη : 0 < η) (hτ : 0 ≤ τ) (n : ℕ) :
    ∀ g : (ι → α) → ℝ,
      ∑ x, prodMass p x *
        (if (build p τ η n g).bad x then 0 else (g x - (build p τ η n g).eval x) ^ 2) ≤ τ := by
  have hleaf : ∀ g : (ι → α) → ℝ, ∑ x, prodMass p x *
      (if (DTree.leaf (pexp p g) (decide (τ < pvar p g)) : DTree ι α).bad x then 0
        else (g x - (DTree.leaf (pexp p g) (decide (τ < pvar p g)) : DTree ι α).eval x) ^ 2)
        ≤ τ := by
    intro g
    simp only [DTree.bad, DTree.eval]
    by_cases hv : τ < pvar p g
    · simp [hv, hτ]
    · simp only [hv, decide_false, Bool.false_eq_true, if_false]
      push_neg at hv
      exact hv
  induction n with
  | zero => intro g; rw [build_zero]; exact hleaf g
  | succ n ih =>
    intro g
    by_cases h : ∃ j, τ < pvar p g ∧ η ≤ pincr p g j
    · rw [build_pos p τ η n g h]
      set j := h.choose
      have hsplit := sum_split p hp1 j
        (fun c x => if (build p τ η n (sect g j c)).bad x then 0
          else (sect g j c x - (build p τ η n (sect g j c)).eval x) ^ 2)
        (fun c x b => by
          have hi := build_inv p τ η hη n (sect g j c) j (inv_sect_self g j c) x b
          simp only [hi.1, hi.2.1, inv_sect_self g j c x b])
      have hlhs : ∑ x, prodMass p x *
          (if (DTree.node j fun c => build p τ η n (sect g j c)).bad x then 0
            else (g x - (DTree.node j fun c => build p τ η n (sect g j c)).eval x) ^ 2) =
          ∑ x, prodMass p x * (fun c x => if (build p τ η n (sect g j c)).bad x then 0
            else (sect g j c x - (build p τ η n (sect g j c)).eval x) ^ 2) (x j) x := by
        refine Finset.sum_congr rfl fun x _ => ?_
        simp only [DTree.bad, DTree.eval]
        congr 2
        rw [sect_self g j x]
      rw [hlhs, hsplit]
      calc ∑ c, p j c * ∑ x, prodMass p x * (if (build p τ η n (sect g j c)).bad x then 0
              else (sect g j c x - (build p τ η n (sect g j c)).eval x) ^ 2)
          ≤ ∑ c, p j c * τ :=
            Finset.sum_le_sum fun c _ => mul_le_mul_of_nonneg_left (ih _) (hp j c)
        _ = τ := by rw [← Finset.sum_mul, hp1, one_mul]
    · rw [build_neg p τ η n g h]
      exact hleaf g

omit hp1 in
theorem prob_bad_le (n : ℕ) (hn : 0 < n) (t : DTree ι α)
    (hbq : ∀ x, t.bad x = true → t.queries x = n) :
    ∑ x, prodMass p x * (if t.bad x then (1 : ℝ) else 0) ≤
      (∑ x, prodMass p x * (t.queries x : ℝ)) / n := by
  rw [le_div_iff₀ (by exact_mod_cast hn), Finset.sum_mul]
  refine Finset.sum_le_sum fun x _ => ?_
  rw [mul_assoc]
  refine mul_le_mul_of_nonneg_left ?_ (prodMass_nonneg' p hp x)
  by_cases hb : t.bad x = true
  · simp [hb, hbq x hb]
  · simp only [Bool.not_eq_true] at hb
    simp [hb]

/-- **Simulation from rows.** If `f` has rows of cost at most `K` and `144 K⁴ η² ≤ τ³`, the tree
`build p τ η n f` makes at most `n` queries on every input and
`Pr[ |f - Q̃| > ε ] ≤ K / (η n) + τ / ε²`. -/
theorem simulation_rows (f : (ι → α) → ℝ) {K : ℝ} (hK : 0 < K) (hf : HasRows f K)
    (hτ : 0 ≤ τ) (hη : 0 < η) (hητ : 144 * K ^ 4 * η ^ 2 ≤ τ ^ 3)
    (ε : ℝ) (hε : 0 < ε) (n : ℕ) (hn : 0 < n) :
    (∀ x, (build p τ η n f).queries x ≤ n) ∧
      ∑ x, prodMass p x * (if ε < |f x - (build p τ η n f).eval x| then (1 : ℝ) else 0)
        ≤ K / (η * n) + τ / ε ^ 2 := by
  refine ⟨queries_le p τ η n f, ?_⟩
  set t := build p τ η n f
  have hbq := bad_queries p τ η hp hp1 hK hτ hη.le hητ n f hf
  have hpb := prob_bad_le p hp n hn t hbq
  have hq := expected_queries p τ η hp hp1 hη n f
  have hL : Ltot p f ≤ K := by
    obtain ⟨a, hr, hKa⟩ := hf
    exact sum_pincr_le p hp hp1 f a hr K hKa
  have herr := leaf_error p τ η hp hp1 hη hτ n f
  have hε2 : 0 < ε ^ 2 := by positivity
  -- pointwise: 1{ε < |f - Q̃|} ≤ 1{bad} + 1{¬bad} (f - Q̃)² / ε²
  have hpt : ∀ x, (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤
      (if t.bad x then (1 : ℝ) else 0) +
        (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2 := by
    intro x
    by_cases hb : t.bad x = true
    · simp only [hb, ite_true, zero_div, add_zero]
      split_ifs <;> norm_num
    · simp only [hb, Bool.false_eq_true, ite_false, zero_add]
      split_ifs with hlt
      · rw [le_div_iff₀ hε2, one_mul]
        have h1 : ε ^ 2 < |f x - t.eval x| ^ 2 := by
          have := abs_nonneg (f x - t.eval x); nlinarith
        rw [sq_abs] at h1
        exact h1.le
      · exact div_nonneg (sq_nonneg _) hε2.le
  calc ∑ x, prodMass p x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0)
      ≤ ∑ x, prodMass p x * ((if t.bad x then (1 : ℝ) else 0) +
          (if t.bad x then 0 else (f x - t.eval x) ^ 2) / ε ^ 2) :=
        Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left (hpt x) (prodMass_nonneg' p hp x)
    _ = ∑ x, prodMass p x * (if t.bad x then (1 : ℝ) else 0) +
        (∑ x, prodMass p x * (if t.bad x then 0 else (f x - t.eval x) ^ 2)) / ε ^ 2 := by
        rw [Finset.sum_div, ← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun x _ => by ring
    _ ≤ (∑ x, prodMass p x * (t.queries x : ℝ)) / n + τ / ε ^ 2 := by
        gcongr
    _ ≤ K / (η * n) + τ / ε ^ 2 := by
        have hn' : (0 : ℝ) < n := by exact_mod_cast hn
        have hd : (∑ x, prodMass p x * (t.queries x : ℝ)) / n ≤ K / (η * n) := by
          rw [div_le_div_iff₀ hn' (by positivity)]
          have : η * ∑ x, prodMass p x * (t.queries x : ℝ) ≤ K := hq.trans hL
          nlinarith
        linarith

/-! ## Bounded functions of low degree -/

omit hp hp1 in
theorem hasProdDegreeLE_two_mul_sub_one (f : (ι → α) → ℝ) (d : ℕ) (h : HasProdDegreeLE f d) :
    HasProdDegreeLE (fun x => 2 * f x - 1) d := by
  classical
  obtain ⟨a, ha0, hf⟩ := h
  refine ⟨fun T τ => 2 * a T τ - (if T = ∅ then 1 / (Fintype.card (ι → α) : ℝ) else 0), ?_, ?_⟩
  · intro T hT τ
    have hTne : T ≠ ∅ := by
      intro hT0; rw [hT0, Finset.card_empty] at hT; exact Nat.not_lt_zero _ hT
    simp [ha0 T hT τ, hTne]
  · intro x
    have hN : (0 : ℝ) < Fintype.card (ι → α) := by
      exact_mod_cast Fintype.card_pos_iff.mpr ⟨x⟩
    have h1 : ∑ T : Finset ι, ∑ τ : ι → α,
        (if T = ∅ then 1 / (Fintype.card (ι → α) : ℝ) else 0) * indMono T τ x = 1 := by
      rw [Finset.sum_eq_single (∅ : Finset ι)]
      · simp only [if_true, indMono, Finset.prod_empty, mul_one, Finset.sum_const,
          Finset.card_univ, nsmul_eq_mul]
        field_simp
      · intro T _ hT; simp [hT]
      · intro h; exact absurd (Finset.mem_univ _) h
    have h2 : ∑ T : Finset ι, ∑ τ : ι → α,
        (2 * a T τ - (if T = ∅ then 1 / (Fintype.card (ι → α) : ℝ) else 0)) * indMono T τ x =
        2 * ∑ T, ∑ τ, a T τ * indMono T τ x - ∑ T : Finset ι, ∑ τ : ι → α,
          (if T = ∅ then 1 / (Fintype.card (ι → α) : ℝ) else 0) * indMono T τ x := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun T _ => ?_
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun τ _ => by ring
    rw [h2, h1, ← hf x]

omit hp hp1 in
/-- A function with values in `[0,1]` and interaction degree at most `d` has rows of cost at most
`π² d² / 2` (Lemma B applied to `2f - 1`). -/
theorem hasRows_of_degree (f : (ι → α) → ℝ) (d : ℕ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f d) : HasRows f (Real.pi ^ 2 * (d : ℝ) ^ 2 / 2) := by
  have hg : ∀ x, |2 * f x - 1| ≤ 1 := fun x => by
    rw [abs_le]; constructor <;> linarith [(hf x).1, (hf x).2]
  have hrow := fun x => product_row_bound d (fun x => 2 * f x - 1) hg
    (hasProdDegreeLE_two_mul_sub_one f d hdeg) x
  choose a ha0 hasum hacov using hrow
  refine ⟨fun x i => a x i / 2, ⟨fun x i => div_nonneg (ha0 x i) (by norm_num), fun x y => ?_⟩,
    fun x => ?_⟩
  · have h := hacov x y
    have he : |f x - f y| = |(2 * f x - 1) - (2 * f y - 1)| / 2 := by
      rw [show (2 * f x - 1) - (2 * f y - 1) = 2 * (f x - f y) by ring, abs_mul]
      norm_num
    rw [he, ← Finset.sum_div]
    exact div_le_div_of_nonneg_right h (by norm_num)
  · rw [← Finset.sum_div]
    exact div_le_div_of_nonneg_right (hasum x) (by norm_num)

omit hp1 in
include hp1 in
/-- **Uniform simulation for bounded low-degree functions.** Let `p` be any product law on any
finite `ι → α` (zero masses allowed), and `f` take values in `[0,1]` with interaction degree at
most `d ≥ 1`. If `n · ε³ δ² √δ ≥ 6 √2 π⁶ d⁶`, some decision tree makes at most `n` queries on every
input and has `Pr_{x∼p}[ |f x - Q̃ x| > ε ] ≤ δ`. The acceptance probability of a `T`-query
quantum algorithm is the case `d = 2T`. -/
theorem simulation_degree (f : (ι → α) → ℝ) (d : ℕ) (hd : 1 ≤ d)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1) (hdeg : HasProdDegreeLE f d)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (n : ℕ)
    (hn : 6 * Real.sqrt 2 * Real.pi ^ 6 * (d : ℝ) ^ 6 ≤ n * (ε ^ 3 * δ ^ 2 * Real.sqrt δ)) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, prodMass p x * (if ε < |f x - t.eval x| then (1 : ℝ) else 0) ≤ δ := by
  obtain ⟨K, hKdef⟩ : ∃ K : ℝ, K = Real.pi ^ 2 * (d : ℝ) ^ 2 / 2 := ⟨_, rfl⟩
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hK : 0 < K := by rw [hKdef]; positivity
  obtain ⟨τ, hτdef⟩ : ∃ τ : ℝ, τ = ε ^ 2 * δ / 2 := ⟨_, rfl⟩
  have hτ : 0 < τ := by rw [hτdef]; positivity
  obtain ⟨s, hsdef⟩ : ∃ s : ℝ, s = Real.sqrt τ := ⟨_, rfl⟩
  have hs : 0 < s := by rw [hsdef]; exact Real.sqrt_pos.mpr hτ
  have hss : s ^ 2 = τ := by rw [hsdef]; exact Real.sq_sqrt hτ.le
  obtain ⟨η, hηdef⟩ : ∃ η : ℝ, η = τ * s / (12 * K ^ 2) := ⟨_, rfl⟩
  have hη : 0 < η := by rw [hηdef]; positivity
  have hη2 : η ^ 2 * (144 * K ^ 4) = τ ^ 3 := by
    rw [hηdef, div_pow, mul_pow, hss]
    field_simp
    ring
  have hητ : 144 * K ^ 4 * η ^ 2 ≤ τ ^ 3 := by rw [← hη2]; ring_nf; exact le_refl _
  have hsq2 : 0 < Real.sqrt 2 := by positivity
  have hs2 : s * Real.sqrt 2 = ε * Real.sqrt δ := by
    have h1 : (s * Real.sqrt 2) ^ 2 = (ε * Real.sqrt δ) ^ 2 := by
      rw [mul_pow, mul_pow, hss, Real.sq_sqrt (by norm_num), Real.sq_sqrt hδ.le, hτdef]; ring
    exact (pow_left_inj₀ (by positivity) (by positivity) two_ne_zero).mp h1
  have hnpos : 0 < n := by
    have hl : 0 < 6 * Real.sqrt 2 * Real.pi ^ 6 * (d : ℝ) ^ 6 := by positivity
    have hn0 : (n : ℝ) ≠ 0 := by
      intro h0; rw [h0, zero_mul] at hn; linarith
    exact Nat.pos_of_ne_zero (by exact_mod_cast hn0)
  have hrows : HasRows f K := by rw [hKdef]; exact hasRows_of_degree f d hf hdeg
  obtain ⟨hq, hP⟩ := simulation_rows p τ η hp hp1 f hK hrows hτ.le hη hητ ε hε n hnpos
  refine ⟨build p τ η n f, hq, hP.trans ?_⟩
  have hn' : (0 : ℝ) < n := by exact_mod_cast hnpos
  have hτε : τ / ε ^ 2 = δ / 2 := by rw [hτdef]; field_simp
  rw [hτε]
  have hK3 : 24 * K ^ 3 = 3 * Real.pi ^ 6 * (d : ℝ) ^ 6 := by rw [hKdef]; ring
  have hkey : 24 * K ^ 3 ≤ δ * τ * s * n := by
    rw [hK3]
    have h1 : (δ * τ * s * n) * Real.sqrt 2 = n * (ε ^ 3 * δ ^ 2 * Real.sqrt δ) / 2 := by
      rw [show δ * τ * s * n * Real.sqrt 2 = δ * τ * n * (s * Real.sqrt 2) by ring, hs2, hτdef]
      ring
    have h2 : 3 * Real.pi ^ 6 * (d : ℝ) ^ 6 * Real.sqrt 2 ≤ (δ * τ * s * n) * Real.sqrt 2 := by
      rw [h1]; linarith
    exact le_of_mul_le_mul_right h2 hsq2
  have hKη : K / (η * n) = 12 * K ^ 3 / (τ * s * n) := by
    rw [hηdef]; field_simp
  have hfin : 12 * K ^ 3 / (τ * s * n) ≤ δ / 2 := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  rw [hKη]
  linarith

end Nightfall.ProductSpace.Simulation

#print axioms Nightfall.ProductSpace.Simulation.simulation_rows
#print axioms Nightfall.ProductSpace.Simulation.simulation_degree

