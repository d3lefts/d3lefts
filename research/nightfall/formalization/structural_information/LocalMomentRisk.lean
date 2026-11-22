import Mathlib

/-!
# Exact finite low-degree / leaf-tree risk conservation (PR #988)

This file formalizes the algebraic heart of the published-in-repository paper
proof, for any finite coordinate set and any finite alphabet.

The `LocalMomentAgreement` hypothesis is the FUNCTIONAL form of matching
k-coordinate marginals: it says *every* observable depending on ≤k
coordinates has the same expectation. A separate equivalence with atomwise
finite marginals is still to be formalized. A decision-tree observable is
represented by finitely many mutually exclusive, idempotent leaf indicators,
each depending on ≤q coordinates. The actual recursive decision-tree →
leaf-indicator representation is another open interface.

The theorem is about actual squared risk for arbitrary real coefficients
and all finite dimensions, not about a fixed example. No product, density,
independence, boundedness, or positivity assumptions are made on the weights.
It is a *conditional kernel theorem*, not full certification of PR #988.
-/

namespace Nightfall.LocalMomentRisk

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
variable [Fintype α] [DecidableEq α]

abbrev Input (ι α : Type*) := ι → α

def DependsOn (S : Finset ι) (g : Input ι α → ℝ) : Prop :=
  ∀ x y, (∀ i ∈ S, x i = y i) → g x = g y

theorem dependsOn_mul {S T : Finset ι}
    {g h : Input ι α → ℝ} (hg : DependsOn S g) (hh : DependsOn T h) :
    DependsOn (S ∪ T) (fun x => g x * h x) := by
  intro x y hxy
  have h1 : g x = g y :=
    hg x y (fun i hi => hxy i (Finset.mem_union.mpr (Or.inl hi)))
  have h2 : h x = h y :=
    hh x y (fun i hi => hxy i (Finset.mem_union.mpr (Or.inr hi)))
  rw [h1, h2]

theorem dependsOn_const_mul {S : Finset ι}
    {g : Input ι α → ℝ} (hg : DependsOn S g) (c : ℝ) :
    DependsOn S (fun x => c * g x) := by
  intro x y hxy
  rw [hg x y hxy]

def expectation (μ : Input ι α → ℝ) (g : Input ι α → ℝ) : ℝ :=
  ∑ x : Input ι α, μ x * g x

def LocalMomentAgreement (μ ν : Input ι α → ℝ) (k : ℕ) : Prop :=
  ∀ (S : Finset ι), S.card ≤ k →
    ∀ (g : Input ι α → ℝ), DependsOn S g →
      expectation μ g = expectation ν g

theorem expectation_sum {β : Type*} [DecidableEq β] (μ : Input ι α → ℝ)
    (T : Finset β) (u : β → Input ι α → ℝ) :
    expectation μ (fun x => ∑ j ∈ T, u j x) =
      ∑ j ∈ T, expectation μ (u j) := by
  classical
  simp only [expectation, Finset.mul_sum]
  rw [Finset.sum_comm]

theorem expectation_sub_sq (μ : Input ι α → ℝ)
    (f t : Input ι α → ℝ) :
    expectation μ (fun x => (f x - t x) ^ 2) =
       expectation μ (fun x => (f x)^2) -
         2 * expectation μ (fun x => f x * t x) +
         expectation μ (fun x => (t x)^2) := by
  classical
  unfold expectation
  calc
    (∑ x, μ x * (f x - t x)^2) =
      ∑ x, (μ x * f x^2 - 2 * (μ x * (f x * t x)) + μ x * t x^2) := by
        apply Finset.sum_congr rfl
        intro x _
        ring
    _ = _ := by
      rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
      rw [← Finset.mul_sum]
      ring

theorem square_sum_of_disjoint {β : Type*} [DecidableEq β]
    (T : Finset β) (u : β → ℝ)
    (horth : ∀ i ∈ T, ∀ j ∈ T, i ≠ j → u i * u j = 0) :
    (∑ i ∈ T, u i) ^ 2 = ∑ i ∈ T, u i ^ 2 := by
  classical
  induction T using Finset.induction_on with
  | empty => simp
  | @insert a T ha ih =>
      have horthT : ∀ i ∈ T, ∀ j ∈ T, i ≠ j → u i * u j = 0 := by
        intro i hi j hj hij
        exact horth i (Finset.mem_insert_of_mem hi)
          j (Finset.mem_insert_of_mem hj) hij
      have hc : u a * (∑ i ∈ T, u i) = 0 := by
        rw [Finset.mul_sum]
        apply Finset.sum_eq_zero
        intro i hi
        apply horth a (Finset.mem_insert_self a T) i
          (Finset.mem_insert_of_mem hi)
        exact fun hai => ha (hai ▸ hi)
      have ht := ih horthT
      simp only [Finset.sum_insert ha]
      nlinarith [hc, ht]

/-- A complete leaf-indicator system: each leaf is q-local, every indicator
is {0,1}-valued in the algebraic idempotence sense, and different leaves
cannot be simultaneously active. In particular, this covers deterministic
decision-tree leaves (including repeated queries). -/
structure LeafSystem (q : ℕ) (β : Type*) [DecidableEq β] [Fintype β] where
  support : β → Finset ι
  indicator : β → Input ι α → ℝ
  card_le : ∀ j, (support j).card ≤ q
  local : ∀ j, DependsOn (support j) (indicator j)
  idempotent : ∀ j x, (indicator j x)^2 = indicator j x
  exclusive : ∀ i j, i ≠ j → ∀ x, indicator i x * indicator j x = 0

def leafValue {β : Type*} [DecidableEq β] [Fintype β]
    (sys : LeafSystem (ι := ι) (α := α) q β) (c : β → ℝ) (x : Input ι α) : ℝ :=
  ∑ j : β, c j * sys.indicator j x

theorem leafValue_sq {β : Type*} [DecidableEq β] [Fintype β]
    (sys : LeafSystem (ι := ι) (α := α) q β) (c : β → ℝ) (x : Input ι α) :
    (leafValue sys c x)^2 = ∑ j : β, c j ^ 2 * sys.indicator j x := by
  classical
  unfold leafValue
  have horth : ∀ i ∈ (Finset.univ : Finset β), ∀ j ∈ Finset.univ,
      i ≠ j → (c i * sys.indicator i x) * (c j * sys.indicator j x) = 0 := by
    intro i _ j _ hij
    calc
      (c i * sys.indicator i x) * (c j * sys.indicator j x) =
        (c i * c j) * (sys.indicator i x * sys.indicator j x) := by ring
      _ = 0 := by rw [sys.exclusive i j hij x]; ring
  rw [square_sum_of_disjoint Finset.univ
      (fun j => c j * sys.indicator j x) horth]
  apply Finset.sum_congr rfl
  intro j _
  calc
    (c j * sys.indicator j x)^2 =
      c j ^ 2 * (sys.indicator j x)^2 := by ring
    _ = c j ^ 2 * sys.indicator j x := by rw [sys.idempotent]

/-- A degree-d decomposition into finitely many genuinely d-local terms;
the individual amplitudes may be unbounded. -/
structure DegreeDecomposition (d : ℕ) (β : Type*) [DecidableEq β] [Fintype β] where
  support : β → Finset ι
  component : β → Input ι α → ℝ
  card_le : ∀ j, (support j).card ≤ d
  local : ∀ j, DependsOn (support j) (component j)

def targetValue {β : Type*} [DecidableEq β] [Fintype β]
    (sys : DegreeDecomposition (ι := ι) (α := α) d β) (x : Input ι α) : ℝ :=
  ∑ j : β, sys.component j x

/-- **Theorem #988: exact universal squared-risk transfer (functional
marginal form)**. Both laws may be arbitrary, not necessarily product
or positive. The threshold is max(2*d,d+q), not 2*(d+q): a tree's square
has the same leaf supports because indicators are exclusive/idempotent. -/
theorem exact_squared_risk_transfer
    {β γ : Type*} [DecidableEq β] [Fintype β]
    [DecidableEq γ] [Fintype γ]
    (f : DegreeDecomposition (ι := ι) (α := α) d β)
    (t : LeafSystem (ι := ι) (α := α) q γ)
    (c : γ → ℝ) (μ ν : Input ι α → ℝ) (k : ℕ)
    (hmatch : LocalMomentAgreement μ ν k)
    (hbound : max (2*d) (d+q) ≤ k) :
    expectation μ (fun x => (targetValue f x - leafValue t c x)^2) =
    expectation ν (fun x => (targetValue f x - leafValue t c x)^2) := by
  classical
  have htwo : 2*d ≤ k := le_trans (le_max_left _ _) hbound
  have hmix : d+q ≤ k := le_trans (le_max_right _ _) hbound
  have hq : q ≤ k := by omega
  let fv : Input ι α → ℝ := targetValue f
  let tv : Input ι α → ℝ := leafValue t c
  have ff_expand (x : Input ι α) :
      (fv x)^2 = ∑ i : β, ∑ j : β, f.component i x * f.component j x := by
    dsimp [fv, targetValue]
    simp only [pow_two, Finset.sum_mul, Finset.mul_sum]
  have ft_expand (x : Input ι α) :
      fv x * tv x =
        ∑ i : β, ∑ j : γ,
          f.component i x * (c j * t.indicator j x) := by
    dsimp [fv, tv, targetValue, leafValue]
    simp only [Finset.sum_mul, Finset.mul_sum]
  have hff : expectation μ (fun x => (fv x)^2) =
      expectation ν (fun x => (fv x)^2) := by
    have convert (w : Input ι α → ℝ) :
        expectation w (fun x => (fv x)^2) =
        ∑ i : β, ∑ j : β,
           expectation w (fun x => f.component i x * f.component j x) := by
      calc
        _ = expectation w (fun x => ∑ i : β, ∑ j : β,
               f.component i x * f.component j x) := by
             congr 1; funext x; exact ff_expand x
        _ = _ := by
             rw [expectation_sum]
             apply Finset.sum_congr rfl
             intro i _
             exact expectation_sum w Finset.univ _
    rw [convert μ, convert ν]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    apply hmatch (f.support i ∪ f.support j)
    · calc
        (f.support i ∪ f.support j).card ≤
          (f.support i).card + (f.support j).card := Finset.card_union_le _ _
        _ ≤ d + d := Nat.add_le_add (f.card_le i) (f.card_le j)
        _ ≤ k := by omega
    · exact dependsOn_mul (f.local i) (f.local j)
  have hft : expectation μ (fun x => fv x * tv x) =
      expectation ν (fun x => fv x * tv x) := by
    have convert (w : Input ι α → ℝ) :
        expectation w (fun x => fv x * tv x) =
        ∑ i : β, ∑ j : γ,
          expectation w (fun x => f.component i x * (c j * t.indicator j x)) := by
      calc
        _ = expectation w (fun x => ∑ i : β, ∑ j : γ,
              f.component i x * (c j * t.indicator j x)) := by
            congr 1; funext x; exact ft_expand x
        _ = _ := by
            rw [expectation_sum]
            apply Finset.sum_congr rfl
            intro i _
            exact expectation_sum w Finset.univ _
    rw [convert μ, convert ν]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    apply hmatch (f.support i ∪ t.support j)
    · calc
        (f.support i ∪ t.support j).card ≤
          (f.support i).card + (t.support j).card := Finset.card_union_le _ _
        _ ≤ d + q := Nat.add_le_add (f.card_le i) (t.card_le j)
        _ ≤ k := hmix
    · exact dependsOn_mul (f.local i) (dependsOn_const_mul (t.local j) (c j))
  have htt : expectation μ (fun x => (tv x)^2) =
      expectation ν (fun x => (tv x)^2) := by
    have convert (w : Input ι α → ℝ) :
        expectation w (fun x => (tv x)^2) =
          ∑ j : γ,
            expectation w (fun x => c j ^ 2 * t.indicator j x) := by
      calc
        _ = expectation w (fun x => ∑ j : γ,
               c j ^ 2 * t.indicator j x) := by
            congr 1; funext x; exact leafValue_sq t c x
        _ = _ := expectation_sum w Finset.univ _
    rw [convert μ, convert ν]
    apply Finset.sum_congr rfl
    intro j _
    apply hmatch (t.support j)
    · exact (t.card_le j).trans hq
    · exact dependsOn_const_mul (t.local j) (c j ^ 2)
  rw [expectation_sub_sq μ fv tv, expectation_sub_sq ν fv tv, hff, hft, htt]

end Nightfall.LocalMomentRisk


#print axioms Nightfall.LocalMomentRisk.dependsOn_mul
#print axioms Nightfall.LocalMomentRisk.expectation_sum
#print axioms Nightfall.LocalMomentRisk.expectation_sub_sq
#print axioms Nightfall.LocalMomentRisk.square_sum_of_disjoint
#print axioms Nightfall.LocalMomentRisk.leafValue_sq
#print axioms Nightfall.LocalMomentRisk.exact_squared_risk_transfer
#print Nightfall.LocalMomentRisk.exact_squared_risk_transfer
