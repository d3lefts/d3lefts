import Mathlib

/-!
# Infinite-field fixed squared-oracle upper bound

Every infinite field has arbitrarily many distinct evaluation nodes. A
Vandermonde design with 2k-1 rows satisfies the phase-retrieval complement
property and recovers all vectors up to sign. The proof works in positive
characteristic other than two and does not use real/complex topology.
-/

namespace Nightfall.InfiniteFieldPhase.FixedUpper
open scoped BigOperators
noncomputable section

variable {K : Type*} [Field K] [Infinite K] [NeZero (2 : K)]

/-- A polynomial of degree below k that vanishes at k distinct nodes is zero,
phrased directly in the Vandermonde coefficient representation. -/
theorem vandermonde_zero_of_many {m k : ℕ}
    (nodes : Fin m → K) (hnodes : Function.Injective nodes)
    (v : Fin k → K) (s : Finset (Fin m))
    (hs : k ≤ s.card)
    (hz : ∀ i ∈ s, (∑ j : Fin k, (nodes i) ^ (j : ℕ) * v j) = 0) :
    v = 0 := by
  classical
  obtain ⟨e, he⟩ := Function.Embedding.exists_of_card_le_finset
    (α := Fin k) (β := Fin m) (by simpa only [Fintype.card_fin] using hs)
  have hinj : Function.Injective (fun i : Fin k => nodes (e i)) :=
    hnodes.comp e.injective
  apply Matrix.eq_zero_of_forall_index_sum_pow_mul_eq_zero hinj
  intro i
  exact hz (e i) (he ⟨i, rfl⟩)

/-- For any distinct nodes, 2k-1 Vandermonde rows separate every signal
up to one global sign using the actual squared-linear observation. -/
theorem vandermonde_fixed_separates (k : ℕ) (hk : 1 ≤ k)
    (nodes : Fin (2 * k - 1) → K)
    (hnodes : Function.Injective nodes) :
    ∀ x y : Fin k → K,
      (∀ i : Fin (2 * k - 1),
        (∑ j : Fin k, (nodes i) ^ (j : ℕ) * x j) ^ 2 =
        (∑ j : Fin k, (nodes i) ^ (j : ℕ) * y j) ^ 2) →
      x = y ∨ x = -y := by
  classical
  intro x y hread
  let s : Finset (Fin (2 * k - 1)) :=
    Finset.univ.filter (fun i =>
      (∑ j : Fin k, (nodes i) ^ (j : ℕ) * (x j - y j)) = 0)
  let t : Finset (Fin (2 * k - 1)) := Finset.univ \ s
  have hcard : s.card + t.card = 2 * k - 1 := by
    have hh := Finset.card_sdiff_add_card_eq_card (Finset.subset_univ s)
    have hh' : t.card + s.card = 2 * k - 1 := by
      simpa only [t, Finset.card_fin] using hh
    omega
  have hdiff (i : Fin (2 * k - 1)) :
      (∑ j : Fin k, (nodes i) ^ (j : ℕ) * (x j - y j)) = 0 ∨
      (∑ j : Fin k, (nodes i) ^ (j : ℕ) * (x j + y j)) = 0 := by
    have hsq := hread i
    have hmul :
        (∑ j : Fin k, (nodes i) ^ (j : ℕ) * x j) *
          (∑ j : Fin k, (nodes i) ^ (j : ℕ) * x j) =
        (∑ j : Fin k, (nodes i) ^ (j : ℕ) * y j) *
          (∑ j : Fin k, (nodes i) ^ (j : ℕ) * y j) := by
      simpa only [pow_two] using hsq
    rcases (mul_self_eq_mul_self_iff).mp hmul with he | he
    · left
      simp only [mul_sub, Finset.sum_sub_distrib]
      exact sub_eq_zero.mpr he
    · right
      simp only [mul_add, Finset.sum_add_distrib]
      rw [he]
      simp
  have hs_zero : ∀ i ∈ s,
      (∑ j : Fin k, (nodes i) ^ (j : ℕ) * (x j - y j)) = 0 := by
    intro i hi
    exact (Finset.mem_filter.mp hi).2
  have ht_zero : ∀ i ∈ t,
      (∑ j : Fin k, (nodes i) ^ (j : ℕ) * (x j + y j)) = 0 := by
    intro i hi
    rcases hdiff i with hl | hr
    · have hn : i ∉ s := (Finset.mem_sdiff.mp hi).2
      exact False.elim (hn (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hl⟩))
    · exact hr
  have hlarge : k ≤ s.card ∨ k ≤ t.card := by omega
  rcases hlarge with hbig | hbig
  · have hz := vandermonde_zero_of_many nodes hnodes
      (fun j : Fin k => x j - y j) s hbig hs_zero
    left
    funext j
    have hj := congrArg (fun f : Fin k → K => f j) hz
    have hzero : x j - y j = 0 := by simpa using hj
    exact sub_eq_zero.mp hzero
  · have hz := vandermonde_zero_of_many nodes hnodes
      (fun j : Fin k => x j + y j) t hbig ht_zero
    right
    funext j
    have hj := congrArg (fun f : Fin k → K => f j) hz
    have hzero : x j + y j = 0 := by simpa using hj
    exact (eq_neg_iff_add_eq_zero).2 hzero

/-- Canonical distinct nodes exist in every infinite field, including
infinite fields of positive characteristic. -/
noncomputable def distinctNodes (m : ℕ) : Fin m → K :=
  fun i => Infinite.natEmbedding K (i : ℕ)

theorem distinctNodes_injective (m : ℕ) :
    Function.Injective (distinctNodes (K := K) m) := by
  exact (Infinite.natEmbedding K).injective.comp Fin.val_injective

/-- A fixed design of precisely 2k-1 squared-linear queries suffices. -/
theorem exists_fixed_design (k : ℕ) (hk : 1 ≤ k) :
    ∃ rows : Fin (2 * k - 1) → Fin k → K,
      ∀ x y : Fin k → K,
        (∀ i, (∑ j, rows i j * x j) ^ 2 =
               (∑ j, rows i j * y j) ^ 2) →
        x = y ∨ x = -y := by
  let nodes := distinctNodes (K := K) (2 * k - 1)
  refine ⟨(fun i j => (nodes i) ^ (j : ℕ)), ?_⟩
  exact vandermonde_fixed_separates k hk nodes (distinctNodes_injective (K := K) _) 

#print axioms Nightfall.InfiniteFieldPhase.FixedUpper.vandermonde_zero_of_many
#print axioms Nightfall.InfiniteFieldPhase.FixedUpper.vandermonde_fixed_separates
#print axioms Nightfall.InfiniteFieldPhase.FixedUpper.exists_fixed_design

end
end Nightfall.InfiniteFieldPhase.FixedUpper
