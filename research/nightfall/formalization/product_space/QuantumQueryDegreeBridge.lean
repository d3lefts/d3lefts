import EfronSteinDegree

/-!
# Algebraic quantum-query polynomial bridge (finite symbol oracles)

A realified finite-dimensional query circuit has two sorts of layers:
1. an input-independent real linear transformation on amplitudes;
2. an oracle layer whose individual matrix entry depends on **one** input symbol.

This is a strictly more general algebraic model than an ordinary finite-symbol
addition oracle: no orthogonality is needed for the degree result. A complex
circuit is represented by doubling its real basis to store real and imaginary
parts. Normalization/unitarity, and hence the [0,1] acceptance bound, are
separate semantic conditions.

Main target: `acceptance_hasProdDegreeLE`, which gives *exactly* the
`RowBound.HasProdDegreeLE` predicate required by `Simulation.simulation_degree`
and `Mixture.mixture_simulation`. The key intermediate is an expansion as
a finite sum of functions each depending on at most d coordinates.

The standard oracle encoding, realification, and normalization API are
documented separately; until checked in Lean, do not advertise this as a
complete circuit-to-classical-simulation certificate.
-/

namespace Nightfall.ProductSpace.QuantumBridge

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.RowBound

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

/-- A bounded-order finite sum of local (junta) functions, over every possible
coordinate support. This is an intermediary representation, not an axiom. -/
def LocalExpansion (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∃ coeff : Finset ι → (ι → α) → ℝ,
    (∀ S, d < S.card → ∀ x, coeff S x = 0) ∧
    (∀ S, DependsOn S (coeff S)) ∧
    ∀ x, f x = ∑ S, coeff S x

theorem local_const (c : ℝ) :
    LocalExpansion (fun _ : ι → α => c) 0 := by
  classical
  refine ⟨fun S _ => if S = ∅ then c else 0, ?_, ?_, ?_⟩
  · intro S hS x
    have hne : S ≠ (∅ : Finset ι) := by
      intro he
      subst S
      simp at hS
    simp [hne]
  · intro S x y hxy
    rfl
  · intro x
    simp

theorem local_zero (d : ℕ) :
    LocalExpansion (fun _ : ι → α => 0) d := by
  classical
  refine ⟨fun _ _ => 0, ?_, ?_, ?_⟩
  · intro S h x; rfl
  · intro S x y hxy; rfl
  · intro x; simp

theorem local_coord (i : ι) (u : α → ℝ) :
    LocalExpansion (fun x : ι → α => u (x i)) 1 := by
  classical
  refine ⟨fun S x => if S = {i} then u (x i) else 0, ?_, ?_, ?_⟩
  · intro S hS x
    by_cases h : S = {i}
    · subst S
      simp at hS
    · simp [h]
  · intro S x y hxy
    by_cases hS : S = {i}
    · have hxi : x i = y i := hxy i (by simp [hS])
      simp [hS, hxi]
    · simp [hS]
  · intro x
    simp

theorem local_mono {f : (ι → α) → ℝ} {d e : ℕ}
    (hd : LocalExpansion f d) (hde : d ≤ e) :
    LocalExpansion f e := by
  obtain ⟨coeff, hc, hdep, heval⟩ := hd
  refine ⟨coeff, ?_, hdep, heval⟩
  intro S hS x
  exact hc S (lt_of_le_of_lt hde hS) x

theorem local_add {f g : (ι → α) → ℝ} {d : ℕ}
    (hf : LocalExpansion f d) (hg : LocalExpansion g d) :
    LocalExpansion (fun x => f x + g x) d := by
  classical
  obtain ⟨a, ha, hal, hae⟩ := hf
  obtain ⟨b, hb, hbl, hbe⟩ := hg
  refine ⟨fun S x => a S x + b S x, ?_, ?_, ?_⟩
  · intro S hS x
    simp [ha S hS x, hb S hS x]
  · intro S x y hxy
    simp [hal S x y hxy, hbl S x y hxy]
  · intro x
    rw [hae x, hbe x, Finset.sum_add_distrib]

theorem local_mul {f g : (ι → α) → ℝ} {d e : ℕ}
    (hf : LocalExpansion f d) (hg : LocalExpansion g e) :
    LocalExpansion (fun x => f x * g x) (d + e) := by
  classical
  obtain ⟨a, ha, hal, hae⟩ := hf
  obtain ⟨b, hb, hbl, hbe⟩ := hg
  let c : Finset ι → (ι → α) → ℝ :=
    fun W x => ∑ S, ∑ T, if S ∪ T = W then a S x * b T x else 0
  refine ⟨c, ?_, ?_, ?_⟩
  · intro W hW x
    dsimp [c]
    apply Finset.sum_eq_zero
    intro S hS
    apply Finset.sum_eq_zero
    intro T hT
    by_cases hST : S ∪ T = W
    · have hcard : W.card ≤ S.card + T.card := by
        rw [← hST]
        exact Finset.card_union_le S T
      by_cases hSd : d < S.card
      · simp [hST, ha S hSd x]
      · have hTd : e < T.card := by omega
        simp [hST, hb T hTd x]
    · simp [hST]
  · intro W x y hxy
    dsimp [c]
    apply Finset.sum_congr rfl
    intro S hS
    apply Finset.sum_congr rfl
    intro T hT
    by_cases hST : S ∪ T = W
    · have hxS : ∀ i ∈ S, x i = y i := by
        intro i hi
        apply hxy i
        rw [← hST]
        exact Finset.mem_union_left T hi
      have hxT : ∀ i ∈ T, x i = y i := by
        intro i hi
        apply hxy i
        rw [← hST]
        exact Finset.mem_union_right S hi
      simp [hST, hal S x y hxS, hbl T x y hxT]
    · simp [hST]
  · intro x
    dsimp [c]
    rw [hae x, hbe x]
    have hswap :
        (∑ W : Finset ι, ∑ S : Finset ι, ∑ T : Finset ι,
            if S ∪ T = W then a S x * b T x else 0)
          = ∑ S : Finset ι, ∑ T : Finset ι, a S x * b T x := by
      calc
        _ = ∑ S : Finset ι, ∑ W : Finset ι, ∑ T : Finset ι,
              if S ∪ T = W then a S x * b T x else 0 := Finset.sum_comm
        _ = ∑ S : Finset ι, ∑ T : Finset ι, ∑ W : Finset ι,
              if S ∪ T = W then a S x * b T x else 0 := by
                apply Finset.sum_congr rfl
                intro S hS
                exact Finset.sum_comm
        _ = ∑ S : Finset ι, ∑ T : Finset ι, a S x * b T x := by
              simp
    rw [hswap]
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro S hS
    rw [Finset.mul_sum]

theorem local_sum {β : Type} [DecidableEq β]
    (s : Finset β) (f : β → (ι → α) → ℝ) (d : ℕ)
    (hf : ∀ b ∈ s, LocalExpansion (f b) d) :
    LocalExpansion (fun x => ∑ b ∈ s, f b x) d := by
  classical
  induction s using Finset.induction_on with
  | empty =>
      simpa using (local_zero (ι := ι) (α := α) d)
  | @insert b s hbs ih =>
      have hsingle : LocalExpansion (f b) d := hf b (by simp)
      have hrest : ∀ c ∈ s, LocalExpansion (f c) d := by
        intro c hc
        exact hf c (by simp [hc])
      have h := local_add hsingle (ih hrest)
      simpa [Finset.sum_insert hbs] using h

theorem local_scale (c : ℝ) {f : (ι → α) → ℝ} {d : ℕ}
    (hf : LocalExpansion f d) :
    LocalExpansion (fun x => c * f x) d := by
  simpa using (local_mul (local_const (ι := ι) (α := α) c) hf)

/-- Conversion to the *actual* indicator-monomial degree predicate used by
the product-space AA and mixture simulators. The proof uses the existing
finite Efron–Stein equivalence, with a point-mass auxiliary law. -/
theorem local_to_product_degree [Nonempty α] {f : (ι → α) → ℝ} {d : ℕ}
    (hf : LocalExpansion f d) : HasProdDegreeLE f d := by
  classical
  obtain ⟨a, ha, hal, hae⟩ := hf
  let x₀ : α := Classical.choice ‹Nonempty α›
  let p : ι → α → ℝ := fun _ v => if v = x₀ then 1 else 0
  have hp : ∀ i, ∑ v, p i v = 1 := by
    intro i
    simp [p]
  apply prodDegree_of_esDegree p hp f d
  intro S hS x
  have hfun : f = fun y => ∑ T : Finset ι, (1 : ℝ) * a T y := by
    funext y
    simpa using hae y
  rw [hfun, esComp_lin p S (fun _ : Finset ι => (1 : ℝ)) a x]
  apply Finset.sum_eq_zero
  intro T hT
  by_cases hTd : d < T.card
  · have hzero : ∀ z, a T z = 0 := ha T hTd
    have hcomponent : esComp p S (a T) x = 0 := by
      simp [esComp, condExp, hzero]
    simp [hcomponent]
  · have hTS : T.card ≤ d := Nat.le_of_not_gt hTd
    have hex : ∃ i ∈ S, i ∉ T := by
      by_contra hcontra
      push_neg at hcontra
      have hsub : S ⊆ T := fun i hi => hcontra i hi
      have hcard : S.card ≤ T.card := Finset.card_le_card hsub
      omega
    obtain ⟨i, hiS, hiT⟩ := hex
    have hInv : ∀ z c, a T (Function.update z i c) = a T z := by
      intro z c
      apply hal T
      intro j hj
      have hne : j ≠ i := by
        intro he
        exact hiT (he ▸ hj)
      simp [Function.update_of_ne hne]
    have hcomponent : esComp p S (a T) x = 0 :=
      esComp_indep p S (a T) x i hiS hInv
    simp [hcomponent]

/-- Each matrix entry of an oracle depends on one coordinate of its input.
This includes standard finite-symbol response/phase oracles after realification. -/
structure OracleLayer (ι α β : Type) where
  coord : β → β → ι
  coeff : β → β → α → ℝ

/-- Algebraic finite-dimensional query programs. `mix` is input-independent;
`query` is one call to an oracle whose entries each inspect one symbol. -/
inductive Program (ι α β : Type) where
  | initial (v : β → ℝ)
  | mix (u : β → β → ℝ) (previous : Program ι α β)
  | query (oracle : OracleLayer ι α β) (previous : Program ι α β)

namespace Program

variable {β : Type} [Fintype β] [DecidableEq β]

def queryCount : Program ι α β → ℕ
  | .initial _ => 0
  | .mix _ q => queryCount q
  | .query _ q => queryCount q + 1

noncomputable def amplitude : Program ι α β → β → (ι → α) → ℝ
  | .initial v, b, _ => v b
  | .mix u q, b, x => ∑ c, u b c * amplitude q c x
  | .query oracle q, b, x =>
      ∑ c, oracle.coeff b c (x (oracle.coord b c)) * amplitude q c x

/-- Accepting squared amplitude, with the complex case represented in real
coordinates. The [0,1] normalization obligation is independent of this degree theorem. -/
noncomputable def acceptance (q : Program ι α β) (accept : Finset β) (x : ι → α) : ℝ :=
  ∑ b ∈ accept, amplitude q b x * amplitude q b x

theorem amplitude_local (q : Program ι α β) :
    ∀ b : β, LocalExpansion (amplitude q b) (queryCount q) := by
  classical
  induction q with
  | initial v =>
      intro b
      simpa [amplitude, queryCount] using
        (local_const (ι := ι) (α := α) (v b))
  | mix u q ih =>
      intro b
      have hterms : ∀ c ∈ (Finset.univ : Finset β),
          LocalExpansion (fun x => u b c * amplitude q c x) (queryCount q) := by
        intro c hc
        exact local_scale (u b c) (ih c)
      have h := local_sum (Finset.univ : Finset β)
        (fun c x => u b c * amplitude q c x) (queryCount q) hterms
      simpa [amplitude, queryCount] using h
  | query oracle q ih =>
      intro b
      have hterms : ∀ c ∈ (Finset.univ : Finset β),
          LocalExpansion
            (fun x => oracle.coeff b c (x (oracle.coord b c)) * amplitude q c x)
            (queryCount q + 1) := by
        intro c hc
        have h := local_mul
          (local_coord (ι := ι) (α := α) (oracle.coord b c) (oracle.coeff b c))
          (ih c)
        simpa [Nat.add_comm] using h
      have h := local_sum (Finset.univ : Finset β)
        (fun c x => oracle.coeff b c (x (oracle.coord b c)) * amplitude q c x)
        (queryCount q + 1) hterms
      simpa [amplitude, queryCount] using h

theorem acceptance_local (q : Program ι α β) (accept : Finset β) :
    LocalExpansion (acceptance q accept) (2 * queryCount q) := by
  classical
  have hterms : ∀ b ∈ accept,
      LocalExpansion (fun x => amplitude q b x * amplitude q b x)
        (2 * queryCount q) := by
    intro b hb
    have h := local_mul (amplitude_local q b) (amplitude_local q b)
    simpa [two_mul] using h
  have h := local_sum accept
    (fun b x => amplitude q b x * amplitude q b x)
    (2 * queryCount q) hterms
  simpa [acceptance] using h

/-- **Quantum polynomial-method bridge, algebraic layer form.**
Every finite realified quantum query circuit with `T` input-dependent oracle
layers has an accepting squared-amplitude function of product interaction
degree at most `2T`, in exactly the predicate used by the simulator.
This theorem does not assert normalization of arbitrary real matrices. -/
theorem acceptance_hasProdDegreeLE [Nonempty α]
    (q : Program ι α β) (accept : Finset β) :
    HasProdDegreeLE (acceptance q accept) (2 * queryCount q) :=
  local_to_product_degree (acceptance_local q accept)

end Program

end Nightfall.ProductSpace.QuantumBridge

#print axioms Nightfall.ProductSpace.QuantumBridge.Program.acceptance_hasProdDegreeLE
