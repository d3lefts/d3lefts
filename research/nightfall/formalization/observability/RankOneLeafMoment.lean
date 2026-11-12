import HilbertManyIncrementMoment

/-!
# Exact finite rank-one independent-leaf second moment

Unconditional identity for any number of centered independent finite-alphabet
leaf features and arbitrary real control coefficients. Unlike the terminal
five-B certificate, no variance decomposition is assumed: the second moment
is derived using the already kernel-proved finite product theorem
`QuadraticHilbertMany.moment2_eq_budget`.

This is NOT an end-to-end fair-sign-control cubic selector theorem. A function
with random controls requires a further product/Fubini averaging step and the
unverified fair-sign vector influence bound.
-/

namespace Nightfall.Observability.RankOneLeafMoment

open Finset
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments

variable {α : Type*} [Fintype α]

/-- Independent centered rank-one leaf sections: the exact product-averaged
squared output equals the sum of coefficient-squared leaf energies.
All finite input alphabets are allowed and no atom floor is required. -/
theorem rank_one_leaf_second_moment
    (p : ℕ → α → ℝ)
    (u : ℕ → ℝ)
    (phi : ℕ → α → ℝ)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (hphi : ∀ j, (∑ a : α, p j a * phi j a) = 0)
    (n : ℕ) :
    moment2 p (fun j a (_ : PUnit) => u j * phi j a) n =
      ∑ j ∈ Finset.range n,
        u j ^ 2 * (∑ a : α, p j a * phi j a ^ 2) := by
  have hcenter : ∀ j (k : PUnit),
      (∑ a : α, p j a * (u j * phi j a)) = 0 := by
    intro j k
    calc
      (∑ a : α, p j a * (u j * phi j a)) =
          u j * (∑ a : α, p j a * phi j a) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            ring
      _ = 0 := by rw [hphi j]; ring
  have hbase := moment2_eq_budget p
    (fun j a (_ : PUnit) => u j * phi j a) hp1 hcenter n
  calc
    moment2 p (fun j a (_ : PUnit) => u j * phi j a) n =
        budget p (fun j a (_ : PUnit) => u j * phi j a) n := hbase
    _ = ∑ j ∈ Finset.range n,
        u j ^ 2 * (∑ a : α, p j a * phi j a ^ 2) := by
          unfold budget
          apply Finset.sum_congr rfl
          intro j _
          calc
            (∑ a : α, p j a *
                vecNormSq ((fun j a (_ : PUnit) => u j * phi j a) j a)) =
                ∑ a : α, p j a * (u j * phi j a) ^ 2 := by
                  apply Finset.sum_congr rfl
                  intro a _
                  simp [vecNormSq]
            _ = u j ^ 2 * (∑ a : α, p j a * phi j a ^ 2) := by
                  rw [Finset.mul_sum]
                  apply Finset.sum_congr rfl
                  intro a _
                  ring

end Nightfall.Observability.RankOneLeafMoment
