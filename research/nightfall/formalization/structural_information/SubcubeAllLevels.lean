import SubcubeAllSpacesL3

set_option maxRecDepth 10000
set_option maxHeartbeats 3000000

namespace Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeAllSpacesL3

/-! The tower uses the *same* three tensor embeddings as the exact L<=3 theorem.
    All quantifiers below range over arbitrary linear subspaces, not preselected RREF matrices. -/

/-- Tensor ambient spaces: E_L has dimension 2^L. -/
def E : Nat → Type
  | 0 => K
  | n+1 => E n × E n

instance instAdd (n : Nat) : AddCommGroup (E n) := by
  induction n with
  | zero => change AddCommGroup K; infer_instance
  | succ n ih =>
      letI : AddCommGroup (E n) := ih
      change AddCommGroup (E n × E n)
      infer_instance

instance instMod (n : Nat) : Module K (E n) := by
  induction n with
  | zero => change Module K K; infer_instance
  | succ n ih =>
      letI : Module K (E n) := ih
      change Module K (E n × E n)
      infer_instance

instance instFD (n : Nat) : FiniteDimensional K (E n) := by
  induction n with
  | zero => change FiniteDimensional K K; infer_instance
  | succ n ih =>
      letI : FiniteDimensional K (E n) := ih
      change FiniteDimensional K (E n × E n)
      infer_instance

instance instDecEq (n : Nat) : DecidableEq (E n) := by
  induction n with
  | zero => change DecidableEq K; infer_instance
  | succ n ih =>
      letI : DecidableEq (E n) := ih
      change DecidableEq (E n × E n)
      infer_instance

/-- At every level take the union of (r,0), (0,r), and (r,r). -/
def R : (n : Nat) → Finset (E n)
  | 0 => R0
  | n+1 => rowsUp (R n)

/-- The exact dimension of the recursively represented tensor space. -/
theorem finrank_E : ∀ n : Nat, Module.finrank K (E n) = 2^n
  | 0 => by
      change Module.finrank K K = 1
      exact Module.finrank_self K
  | n+1 => by
      change Module.finrank K (E n × E n) = 2^(n+1)
      rw [Module.finrank_prod, finrank_E n, pow_succ]
      omega

/-- Reusable scalar criterion: any dimension-only integer budget stable under
    the three pairwise slice constraints bounds every tensor-level subspace. -/
theorem all_levels_budget (f : Nat → Nat)
    (hBase : ∀ q, cap0 q ≤ f q)
    (hScalar : ∀ q a b c : Nat,
      a+b ≤ q → a+c ≤ q → b+c ≤ q →
      f a + f b + f c ≤ f q) :
    ∀ n (W : Submodule K (E n)),
      rowHits (R n) W ≤ f (Module.finrank K W) := by
  intro n
  induction n with
  | zero =>
      intro W
      have h : rowHits (R 0) W ≤ cap0 (Module.finrank K W) := by
        classical
        by_cases hW : W = ⊥
        · subst W
          have hz : rowHits (R 0) (⊥ : Submodule K (E 0)) = 0 := by
            unfold rowHits
            rw [Finset.card_eq_zero]
            apply Finset.filter_eq_empty_iff.mpr
            intro x hx hzero
            have hx1 : x = (1 : K) := by simpa [R, R0] using hx
            exact (by decide : (1 : K) ≠ 0) (hx1.symm.trans hzero)
          rw [hz]
          exact Nat.zero_le _
        · have hq : 0 < Module.finrank K W :=
            Submodule.one_le_finrank_iff.mpr hW
          have hc : rowHits (R 0) W ≤ 1 := by
            calc
              rowHits (R 0) W ≤ (R 0).card := by
                unfold rowHits
                exact Finset.card_filter_le _ _
              _ = 1 := by decide
          simpa [cap0, Nat.ne_of_gt hq] using hc
      exact h.trans (hBase _)
  | succ n ih =>
      intro W
      rw [R]
      exact lift_bound (R n) f f (2^n) (finrank_E n) ih
        (by
          intro q a b c hab hac hbc
          exact hScalar q.val a.val b.val c.val hab hac hbc) W

private theorem triple_square (q a b c : Nat)
    (hab : a+b ≤ q) (hac : a+c ≤ q) (hbc : b+c ≤ q) :
    a*a + b*b + c*c ≤ q*q := by
  rcases le_total a b with hab' | hba
  · rcases le_total a c with hac' | hca
    · have hprod : a*a ≤ b*c := Nat.mul_le_mul hab' hac'
      have hpair : (b+c)*(b+c) ≤ q*q := Nat.mul_le_mul hbc hbc
      nlinarith
    · have hcb : c ≤ b := le_trans hca hab'
      have hprod : c*c ≤ a*b := Nat.mul_le_mul hca hcb
      have hpair : (a+b)*(a+b) ≤ q*q := Nat.mul_le_mul hab hab
      nlinarith
  · rcases le_total b c with hbc' | hcb
    · have hprod : b*b ≤ a*c := Nat.mul_le_mul hba hbc'
      have hpair : (a+c)*(a+c) ≤ q*q := Nat.mul_le_mul hac hac
      nlinarith
    · have hca : c ≤ a := le_trans hcb hba
      have hprod : c*c ≤ a*b := Nat.mul_le_mul hca hcb
      have hpair : (a+b)*(a+b) ≤ q*q := Nat.mul_le_mul hab hab
      nlinarith

private theorem cap0_le_square (q : Nat) : cap0 q ≤ q*q := by
  by_cases hq : q = 0
  · simp [cap0, hq]
  · have h1 : 1 ≤ q := Nat.one_le_iff_ne_zero.mpr hq
    simpa [cap0, hq] using (Nat.mul_le_mul h1 h1)

/-- Unconditional, all-L polynomial subspace-evasion theorem. This is a
    kernel-checked quadratic *upper bound*, weaker than the paper's sharp
    q^(log_2 3) claim. The geometric induction is complete for every L. -/
theorem all_levels_quadratic (n : Nat) (W : Submodule K (E n)) :
    rowHits (R n) W ≤ (Module.finrank K W) * (Module.finrank K W) := by
  exact all_levels_budget (fun q => q*q) cap0_le_square triple_square n W

/-- For comparison, the new recursive construction specializes definitionally to
    the formerly kernel-checked finite levels. -/
theorem source_L3 : R 3 = R3 := by
  rfl

#print axioms Nightfall.StructuralInformation.SubcubeAllLevels.finrank_E
#print axioms Nightfall.StructuralInformation.SubcubeAllLevels.all_levels_budget
#print axioms Nightfall.StructuralInformation.SubcubeAllLevels.all_levels_quadratic
#print axioms Nightfall.StructuralInformation.SubcubeAllLevels.source_L3

end Nightfall.StructuralInformation.SubcubeAllLevels
