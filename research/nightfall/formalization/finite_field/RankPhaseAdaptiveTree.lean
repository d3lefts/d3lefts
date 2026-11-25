import RankPhasePivot

/-! Actual arbitrary finite powered-linear decision trees. A normalized
phase input is an element of H^(n+1) with coordinate zero fixed to one,
equivalent to H^n with powered-affine queries. Free pivot steps consume
one physical query and no phase query; dependent steps consume both.
The proof below targets the full lower compiler, with no rank axiom,
assuming only the independently compiled pivot algebra. -/
namespace Nightfall.FiniteField.RankPhaseAdaptiveTree
open Finset
open Nightfall.FiniteField.RankPhasePivot (unit coord rank_increase_normalize dependent_row_agrees)

inductive Tree (Q A O : Type*) where
  | leaf : O → Tree Q A O
  | node : Q → (A → Tree Q A O) → Tree Q A O

namespace Tree
variable {Q A O : Type*}
def eval (oracle : Q → A) : Tree Q A O → O
  | .leaf out => out
  | .node q next => eval oracle (next (oracle q))

def Within : ℕ → Tree Q A O → Prop
  | _, .leaf _ => True
  | 0, .node _ _ => False
  | d+1, .node _ next => ∀ a, Within d (next a)

theorem leaf_within (d : ℕ) (o : O) : Within d (Tree.leaf o : Tree Q A O) := by
  cases d <;> trivial

theorem within_mono {d e : ℕ} (h : d ≤ e) (t : Tree Q A O)
    (ht : Within d t) : Within e t := by
  induction d generalizing e t with
  | zero =>
    cases t with
    | leaf o => exact leaf_within e o
    | node q next => exact (show False from ht).elim
  | succ d ih =>
    cases t with
    | leaf o => exact leaf_within e o
    | node q next =>
      cases e with
      | zero => omega
      | succ e =>
        intro a
        exact ih (by omega) (next a) (ht a)
end Tree

variable {K : Type*} [Field K] [DecidableEq K]
abbrev Vec (K : Type*) (n : ℕ) := Fin (n+1) → K
abbrev Row (K : Type*) [Field K] (n : ℕ) := Vec K n →ₗ[K] K
abbrev Policy (K : Type*) [Field K] (n : ℕ) := Tree (Row K n) K (Vec K n)

def Phase {n : ℕ} (d : ℕ) (y : Vec K n) : Prop :=
  y 0 = 1 ∧ ∀ i, y i ^ d = 1

def Orbit {n : ℕ} (d : ℕ) (o x : Vec K n) : Prop :=
  ∃ l : K, l ^ d = 1 ∧ o = l • x

def Prefix {n : ℕ} (r : ℕ) (y z : Vec K n) : Prop :=
  ∀ i, i.val < r → z i = y i

def oracle {n : ℕ} (d : ℕ) (x : Vec K n) (a : Row K n) : K := (a x)^d

def normalize {n : ℕ} (x : Vec K n) : Vec K n := fun i => x i / x 0

theorem root_ne_zero {d : ℕ} (hd : 0 < d) {l : K} (hl : l^d = 1) : l ≠ 0 := by
  intro hz
  rw [hz, zero_pow (by omega : d ≠ 0)] at hl
  exact zero_ne_one hl

theorem normalize_smul {n d : ℕ} {y : Vec K n} (hy : Phase d y)
    {l : K} (hl : l ≠ 0) : normalize (l • y) = y := by
  funext i
  change (l * y i)/(l * y 0) = y i
  rw [hy.1, mul_one]
  field_simp [hl]

theorem pull_orbit {n d : ℕ} (e : Vec K n ≃ₗ[K] Vec K n)
    {o z : Vec K n} (ho : Orbit d o (e z)) : Orbit d (e.symm o) z := by
  obtain ⟨l, hl, ho⟩ := ho
  refine ⟨l, hl, ?_⟩
  rw [ho, map_smul, LinearEquiv.symm_apply_apply]

/-- If a leaf can answer on every feasible vector in a prescribed phase
fiber, there cannot be even one unassigned coordinate. -/
theorem terminal_full {n d r : ℕ} (hd : 0 < d) (hr : r ≤ n+1)
    (e : Vec K n ≃ₗ[K] Vec K n) (o y : Vec K n) (hy : Phase d y)
    (hc : ∀ z, Prefix r y z → Orbit d o (e z)) : r = n+1 := by
  by_contra hne
  have hlt : r < n+1 := by omega
  let j : Fin (n+1) := ⟨r,hlt⟩
  have hself : Prefix r y y := fun _ _ => rfl
  obtain ⟨l, hl, ho⟩ := pull_orbit e (hc y hself)
  have hl0 := root_ne_zero hd hl
  by_cases hzero : r = 0
  · have hz : Prefix r y 0 := by
      intro i hi
      omega
    obtain ⟨l', hl', ho'⟩ := pull_orbit e (hc 0 hz)
    have heq : l • y = (0 : Vec K n) := by rw [← ho, ho', smul_zero]
    have h := congrFun heq 0
    change l * y 0 = 0 at h
    rw [hy.1, mul_one] at h
    exact hl0 h
  · let z := Function.update y j 0
    have hz : Prefix r y z := by
      intro i hi
      have hij : i ≠ j := by
        intro he
        have hv : i.val = r := congrArg Fin.val he
        omega
      exact Function.update_of_ne hij 0 y
    obtain ⟨l', hl', ho'⟩ := pull_orbit e (hc z hz)
    have heq : l • y = l' • z := ho.symm.trans ho'
    have hzj : z j = 0 := by simp [z]
    have hj := congrFun heq j
    change l * y j = l' * z j at hj
    rw [hzj, mul_zero] at hj
    exact (mul_ne_zero hl0 (root_ne_zero hd (hy.2 j))) hj

theorem leaf_compile {n d D r : ℕ} (hd : 0 < d) (hr : r ≤ n+1)
    (e : Vec K n ≃ₗ[K] Vec K n) (S : Set (Vec K n))
    (hS : ∀ y ∈ S, Phase d y) (o : Vec K n)
    (hc : ∀ y ∈ S, ∀ z, Prefix r y z → Orbit d o (e z)) :
    (S.Nonempty → n+1-r ≤ D) ∧
      ∃ u : Policy K n, Tree.Within (D-(n+1-r)) u ∧
        ∀ y ∈ S, Tree.eval (oracle d y) u = y := by
  refine ⟨?_, Tree.leaf (normalize (e.symm o)), Tree.leaf_within _ _, ?_⟩
  · rintro ⟨y,hy⟩
    have hf := terminal_full hd hr e o y (hS y hy) (hc y hy)
    omega
  · intro y hy
    obtain ⟨l, hl, ho⟩ := pull_orbit e (hc y hy y (fun _ _ => rfl))
    change normalize (e.symm o) = y
    rw [ho]
    exact normalize_smul (hS y hy) (root_ne_zero hd hl)

/-- Actual adaptive lower compiler. For every phase fiber set S, if a
physical tree is correct on the union of the fibers, then it must pay
all remaining rank increases and can be transformed into a phase tree
with the residual budget. Empty branches are permitted. -/
theorem lower_compiler {n : ℕ} (d : ℕ) (hd : 0 < d)
    (D r : ℕ) (hr : r ≤ n+1)
    (e : Vec K n ≃ₗ[K] Vec K n) (S : Set (Vec K n))
    (hS : ∀ y ∈ S, Phase d y) (t : Policy K n) (ht : Tree.Within D t)
    (hc : ∀ y ∈ S, ∀ z, Prefix r y z →
      Orbit d (Tree.eval (oracle d (e z)) t) (e z)) :
    (S.Nonempty → n+1-r ≤ D) ∧
      ∃ u : Policy K n, Tree.Within (D-(n+1-r)) u ∧
        ∀ y ∈ S, Tree.eval (oracle d y) u = y := by
  classical
  induction D generalizing r e S t with
  | zero =>
    cases t with
    | leaf o => exact leaf_compile hd hr e S hS o hc
    | node a next => exact (show False from ht).elim
  | succ D ih =>
    cases t with
    | leaf o => exact leaf_compile hd hr e S hS o hc
    | node a next =>
      by_cases hne : S.Nonempty
      · let a' : Row K n := a.comp e.toLinearMap
        by_cases hfree : ∃ p : Fin (n+1), r ≤ p.val ∧ a' (unit p) ≠ 0
        · obtain ⟨p,hpr,hp⟩ := hfree
          have hlt : r < n+1 := lt_of_le_of_lt hpr p.isLt
          let j : Fin (n+1) := ⟨r,hlt⟩
          obtain ⟨L,hread,hkeep⟩ := rank_increase_normalize a' j p hp
          let e' := L.trans e
          have hc' : ∀ y ∈ S, ∀ z, Prefix (r+1) y z →
              Orbit d (Tree.eval (oracle d (e' z)) (next 1)) (e' z) := by
            intro y hy z hz
            have hprev : Prefix r y (L z) := by
              intro i hi
              have hij : i ≠ j := by
                intro hh
                have hv : i.val = r := congrArg Fin.val hh
                omega
              have hip : i ≠ p := by
                intro hh
                have hv := congrArg Fin.val hh
                omega
              rw [hkeep z i hij hip, hz i (by omega)]
            have hyj : z j = y j := hz j (by change r < r+1; omega)
            have hanswer : oracle d (e (L z)) a = 1 := by
              change (a' (L z))^d = 1
              rw [hread z,hyj,(hS y hy).2 j]
            have hh := hc y hy (L z) hprev
            change Orbit d (Tree.eval (oracle d (e (L z))) (next (oracle d (e (L z)) a))) (e (L z)) at hh
            rw [hanswer] at hh
            exact hh
          obtain ⟨hcost,u,hu,hgood⟩ :=
            ih (r := r+1) (e := e') (S := S) (t := next 1)
              (by omega) hS (ht 1) hc'
          have hb : D+1-(n+1-r) = D-(n+1-(r+1)) := by omega
          refine ⟨?_, u, ?_, hgood⟩
          · intro hh
            have := hcost hh
            omega
          · rw [hb]
            exact hu
        · let A : Finset (Fin (n+1)) := univ.filter (fun i => i.val < r)
          have hz : ∀ i, i ∉ A → a' (unit i) = 0 := by
            intro i hi
            by_contra hn
            apply hfree
            refine ⟨i, ?_, hn⟩
            have hnlt : ¬ i.val < r := by simpa [A] using hi
            omega
          have hagree : ∀ y z, Prefix r y z → oracle d (e z) a = oracle d y a' := by
            intro y z h
            change (a' z)^d = (a' y)^d
            have hh := dependent_row_agrees a' A hz z y
              (fun i hi => h i (by simpa [A] using hi))
            rw [hh]
          let S' (b : K) : Set (Vec K n) := {y | y ∈ S ∧ oracle d y a' = b}
          have hrec (b : K) :
              ((S' b).Nonempty → n+1-r ≤ D) ∧
                ∃ u : Policy K n, Tree.Within (D-(n+1-r)) u ∧
                  ∀ y ∈ S' b, Tree.eval (oracle d y) u = y := by
            apply ih (r := r) (e := e) (S := S' b) (t := next b) hr
            · intro y hy
              exact hS y hy.1
            · exact ht b
            · intro y hy z h
              have hh := hc y hy.1 z h
              change Orbit d (Tree.eval (oracle d (e z)) (next (oracle d (e z) a))) (e z) at hh
              rw [hagree y z h,hy.2] at hh
              exact hh
          have hcost : n+1-r ≤ D := by
            obtain ⟨y,hy⟩ := hne
            exact (hrec (oracle d y a')).1 ⟨y,hy,rfl⟩
          let u (b : K) := Classical.choose (hrec b).2
          have hu (b : K) : Tree.Within (D-(n+1-r)) (u b) :=
            (Classical.choose_spec (hrec b).2).1
          have hgood (b : K) : ∀ y ∈ S' b, Tree.eval (oracle d y) (u b) = y :=
            (Classical.choose_spec (hrec b).2).2
          have hb : D+1-(n+1-r) = (D-(n+1-r))+1 := by omega
          refine ⟨fun _ => by omega, Tree.node a' u, ?_, ?_⟩
          · rw [hb]
            exact hu
          · intro y hy
            exact hgood (oracle d y a') y ⟨hy,rfl⟩
      · refine ⟨fun h => (hne h).elim, Tree.leaf 0, Tree.leaf_within _ _, ?_⟩
        intro y hy
        exact (hne ⟨y,hy⟩).elim

def Retrieval {n : ℕ} (d D : ℕ) : Prop :=
  ∃ t : Policy K n, Tree.Within D t ∧ ∀ x, Orbit d (Tree.eval (oracle d x) t) x

def Packing {n : ℕ} (d D : ℕ) : Prop :=
  ∃ t : Policy K n, Tree.Within D t ∧ ∀ y, Phase d y → Tree.eval (oracle d y) t = y

/-- The source-level rank-sensitive lower half of the identity. -/
theorem retrieval_implies_rank_plus_packing {n : ℕ} (d D : ℕ) (hd : 0 < d)
    (h : Retrieval (K := K) (n := n) d D) :
    n+1 ≤ D ∧ Packing (K := K) (n := n) d (D-(n+1)) := by
  obtain ⟨t,ht,hcorrect⟩ := h
  let S : Set (Vec K n) := {y | Phase d y}
  obtain ⟨hcost,u,hu,hgood⟩ :=
    lower_compiler d hd D 0 (by omega) (LinearEquiv.refl K (Vec K n)) S
      (fun _ hy => hy) t ht (fun _ _ z _ => hcorrect z)
  have hnonempty : S.Nonempty := by
    refine ⟨fun _ => 1, ?_⟩
    change Phase d (fun _ => 1)
    exact ⟨rfl, fun _ => one_pow d⟩
  have hbound := hcost hnonempty
  simp only [Nat.sub_zero] at hbound hu
  exact ⟨hbound, u, hu, fun y hy => hgood y hy⟩

#print axioms terminal_full
#print axioms lower_compiler
#print axioms retrieval_implies_rank_plus_packing
end Nightfall.FiniteField.RankPhaseAdaptiveTree
