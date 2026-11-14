import Mathlib

/-!
# Infinite-index Efron–Stein transfer: an exact, assumption-transparent lemma

The index type is completely arbitrary (including uncountable).
The declared approximation and finite bound assumptions are distinct
obligations; THIS FILE DOES NOT prove they hold for an arbitrary
measure-theoretic product. Consequently passing this lemma is NOT an
end-to-end infinite-product Efron–Stein certificate.

The required final bridge must:
1. Identify projectionVar F with the actual L2 variance of
   E[f | sigma(X_i, i in F)] under Measure.infinitePi;
2. Prove finite-cylinder approximation for the cylinder sigma algebra;
3. Prove projectionVar F <= F.sum actualResamplingInfluence
   using finite Efron–Stein and conditional Jensen.
-/

namespace Nightfall.InfiniteEfronSteinTransfer

variable {Index : Type*} [DecidableEq Index]

/-- Finite-cylinder approximation plus a finite source-matched
influence estimate implies an arbitrary-index finite evidence bound. -/
theorem arbitrary_index_variance_approximation
    (variance : ℝ) (projectionVar : Finset Index → ℝ)
    (influence : Index → ℝ)
    (happrox : ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index, variance ≤ projectionVar F + ε)
    (hfinite : ∀ F : Finset Index,
      projectionVar F ≤ F.sum influence) :
    ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index, variance ≤ F.sum influence + ε := by
  intro ε hε
  obtain ⟨F, hF⟩ := happrox ε hε
  refine ⟨F, ?_⟩
  linarith [hfinite F]

/-- No degree bound and no cardinality bound are needed for this
existential deduction. Its actual-product hypotheses remain obligations. -/
theorem positive_coordinate_if_positive_variance
    (variance : ℝ) (projectionVar : Finset Index → ℝ)
    (influence : Index → ℝ)
    (hvariance : 0 < variance)
    (happrox : ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index, variance ≤ projectionVar F + ε)
    (hfinite : ∀ F : Finset Index,
      projectionVar F ≤ F.sum influence) :
    ∃ i : Index, 0 < influence i := by
  classical
  obtain ⟨F, hF⟩ :=
    arbitrary_index_variance_approximation
      variance projectionVar influence happrox hfinite
      (variance / 2) (by linarith)
  by_contra hn
  have hnonpos : ∀ i : Index, influence i ≤ 0 := by
    intro i
    by_contra hi
    exact hn ⟨i, lt_of_not_ge hi⟩
  have hsum : F.sum influence ≤ 0 :=
    Finset.sum_nonpos (fun i hi => hnonpos i)
  linarith

/-- For any claimed uniform bound on all coordinate influences, a
finite approximation with n active coordinates gives a finite-n bound.
The absence of a dimension-free n-independent bound is intentional. -/
theorem finite_support_cardinality_bound
    (variance : ℝ) (projectionVar : Finset Index → ℝ)
    (influence : Index → ℝ) (M : ℝ)
    (hM : ∀ i, influence i ≤ M)
    (happrox : ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index, variance ≤ projectionVar F + ε)
    (hfinite : ∀ F : Finset Index,
      projectionVar F ≤ F.sum influence) :
    ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index,
        variance ≤ (F.card : ℝ) * M + ε := by
  intro ε hε
  obtain ⟨F, hF⟩ :=
    arbitrary_index_variance_approximation
      variance projectionVar influence happrox hfinite ε hε
  refine ⟨F, ?_⟩
  have hsum : F.sum influence ≤ (F.card : ℝ) * M := by
    calc
      F.sum influence ≤ F.sum (fun _ => M) :=
        Finset.sum_le_sum (fun i hi => hM i)
      _ = (F.card : ℝ) * M := by simp
  linarith

end Nightfall.InfiniteEfronSteinTransfer
