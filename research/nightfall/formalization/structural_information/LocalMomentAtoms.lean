import LocalMomentRisk

/-!
# Full atomwise finite-marginal → functional local-moment bridge

This file closes one precisely identified gap in PR #988 and the new
LocalMomentRisk kernel theorem: the ordinary statement "two laws agree
on every joint atom of ≤k coordinates" is sufficient to establish
LocalMomentAgreement, for arbitrary finite nonempty alphabets.

The proof is an exact partition of the full finite input table into
fibers of its restriction to a coordinate subset. No independence,
product law, probability normalization, density estimate or positivity
assumption is used.

A recursive decision-tree → mutually exclusive leaf system construction
and the proposed converse/sharpness theorem remain separate obligations.
-/

namespace Nightfall.LocalMomentAtoms

open Nightfall.LocalMomentRisk

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
variable [Fintype α] [DecidableEq α] [Inhabited α]

abbrev Assignment (S : Finset ι) := {i : ι // i ∈ S} → α

def restrict (S : Finset ι) (x : Input ι α) : Assignment (α := α) S :=
  fun i => x i.1

def extend (S : Finset ι) (a : Assignment (α := α) S) : Input ι α :=
  fun i => if h : i ∈ S then a ⟨i,h⟩ else default

theorem restrict_extend (S : Finset ι) (a : Assignment (α := α) S) :
    restrict S (extend S a) = a := by
  funext i
  simp [restrict, extend, i.property]

theorem local_factor {S : Finset ι} {g : Input ι α → ℝ}
    (hg : DependsOn S g) (x : Input ι α) (a : Assignment (α := α) S)
    (h : restrict S x = a) :
    g x = g (extend S a) := by
  apply hg x (extend S a)
  intro i hi
  have hval := congrArg (fun u : Assignment (α := α) S => u ⟨i,hi⟩) h
  simpa [restrict, extend, hi] using hval

def fiberMass (μ : Input ι α → ℝ)
    (S : Finset ι) (a : Assignment (α := α) S) : ℝ :=
  ∑ x ∈ Finset.univ.filter (fun x : Input ι α => restrict S x = a), μ x

/-- TRUE ordinary joint-atom equality: both weights assign equal mass to
every exact restriction of size ≤k. This formulation uses dependent
assignments on S instead of the equivalent full-input extension notation. -/
def AtomMarginalAgreement (μ ν : Input ι α → ℝ) (k : ℕ) : Prop :=
  ∀ (S : Finset ι), S.card ≤ k →
    ∀ (a : Assignment (α := α) S), fiberMass μ S a = fiberMass ν S a

theorem expectation_fiber_decomposition
    (μ : Input ι α → ℝ) (S : Finset ι)
    (g : Input ι α → ℝ) (hg : DependsOn S g) :
    expectation μ g =
      ∑ a : Assignment (α := α) S,
        fiberMass μ S a * g (extend S a) := by
  classical
  unfold expectation
  calc
    (∑ x : Input ι α, μ x * g x) =
      ∑ a : Assignment (α := α) S,
        ∑ x ∈ Finset.univ.filter (fun x : Input ι α => restrict S x = a),
          μ x * g x := by
          exact (Finset.sum_fiberwise Finset.univ (restrict S)
            (fun x => μ x * g x)).symm
    _ = ∑ a : Assignment (α := α) S,
          ∑ x ∈ Finset.univ.filter (fun x : Input ι α => restrict S x = a),
            μ x * g (extend S a) := by
          apply Finset.sum_congr rfl
          intro a _
          apply Finset.sum_congr rfl
          intro x hx
          have hrest : restrict S x = a := (Finset.mem_filter.mp hx).2
          rw [local_factor hg x a hrest]
    _ = ∑ a : Assignment (α := α) S,
          fiberMass μ S a * g (extend S a) := by
          apply Finset.sum_congr rfl
          intro a _
          unfold fiberMass
          rw [Finset.sum_mul]

/-- **Named Lean bridge to the actual PR #988 marginal condition.**
Atomwise matching of all ≤k-coordinate joint probabilities implies
equality of every k-local observable expectation. -/
theorem functional_moments_of_atom_marginals
    (μ ν : Input ι α → ℝ) (k : ℕ)
    (h : AtomMarginalAgreement μ ν k) :
    LocalMomentAgreement μ ν k := by
  intro S hS g hg
  rw [expectation_fiber_decomposition μ S g hg,
      expectation_fiber_decomposition ν S g hg]
  apply Finset.sum_congr rfl
  intro a _
  rw [h S hS a]

/-- ***Consequence: actual joint-coordinate marginal matching certifies
exact squared-risk transfer for all finite alphabets and dimensions.***

The tree is presented by its genuine mutually exclusive local leaf
cylinders; the remaining (separately needed) formalization is extraction
of these leaves from arbitrary recursive decision-tree syntax. -/
theorem exact_squared_risk_of_atom_marginals
    {β γ : Type*} [DecidableEq β] [Fintype β]
    [DecidableEq γ] [Fintype γ]
    (f : DegreeDecomposition (ι := ι) (α := α) d β)
    (t : LeafSystem (ι := ι) (α := α) q γ)
    (c : γ → ℝ) (μ ν : Input ι α → ℝ) (k : ℕ)
    (hmatch : AtomMarginalAgreement μ ν k)
    (hk : max (2*d) (d+q) ≤ k) :
    expectation μ (fun x => (targetValue f x - leafValue t c x)^2) =
      expectation ν (fun x => (targetValue f x - leafValue t c x)^2) := by
  apply exact_squared_risk_transfer f t c μ ν k
  · exact functional_moments_of_atom_marginals μ ν k hmatch
  · exact hk

#print axioms Nightfall.LocalMomentAtoms.restrict_extend
#print axioms Nightfall.LocalMomentAtoms.local_factor
#print axioms Nightfall.LocalMomentAtoms.expectation_fiber_decomposition
#print axioms Nightfall.LocalMomentAtoms.functional_moments_of_atom_marginals
#print axioms Nightfall.LocalMomentAtoms.exact_squared_risk_of_atom_marginals
#print Nightfall.LocalMomentAtoms.exact_squared_risk_of_atom_marginals

end Nightfall.LocalMomentAtoms
