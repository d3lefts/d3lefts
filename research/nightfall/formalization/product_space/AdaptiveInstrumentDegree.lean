import Mathlib

/-! Finite unnormalized adaptive linear instrument programs. Real coordinates may
encode complex density matrices. The physical cone and mass-preservation
conditions are local obligations; no Kraus/dilation instantiation is claimed. -/

namespace Nightfall.AdaptiveInstrument

open Finset

variable {ι α κ β : Type} [DecidableEq ι]

def Depends (S : Finset ι) (f : (ι → α) → ℝ) : Prop :=
  ∀ x y, (∀ i ∈ S, x i = y i) → f x = f y

/-- Finite additive span of functions supported on at most d coordinates. -/
inductive Degree (d : ℕ) : ((ι → α) → ℝ) → Prop where
  | atom (S : Finset ι) (f : (ι → α) → ℝ)
      (hc : S.card ≤ d) (hf : Depends S f) : Degree d f
  | add {f g : (ι → α) → ℝ} :
      Degree d f → Degree d g → Degree d (fun x => f x + g x)

theorem degree_const (d : ℕ) (c : ℝ) :
    Degree (ι := ι) (α := α) d (fun _ => c) := by
  exact Degree.atom ∅ _ (by simp) (by intro x y h; rfl)

theorem degree_mono {d e : ℕ} {f : (ι → α) → ℝ}
    (hf : Degree d f) (hde : d ≤ e) : Degree e f := by
  induction hf with
  | atom S f hc hd => exact Degree.atom S f (hc.trans hde) hd
  | add hf hg ihf ihg => exact Degree.add ihf ihg

theorem degree_mul_local {d k : ℕ} {f : (ι → α) → ℝ}
    (hf : Degree d f) (S : Finset ι) (g : (ι → α) → ℝ)
    (hs : S.card ≤ k) (hg : Depends S g) :
    Degree (d + k) (fun x => g x * f x) := by
  induction hf with
  | atom A f hA hd =>
      refine Degree.atom (S ∪ A) _ ?_ ?_
      · exact (Finset.card_union_le S A).trans (by omega)
      · intro x y hxy
        rw [hg x y (fun i hi => hxy i (Finset.mem_union_left _ hi)),
          hd x y (fun i hi => hxy i (Finset.mem_union_right _ hi))]
  | add hf hh ihf ihh =>
      simpa only [mul_add] using (Degree.add ihf ihh)

theorem degree_scale {d : ℕ} {f : (ι → α) → ℝ}
    (hf : Degree d f) (c : ℝ) : Degree d (fun x => c * f x) := by
  have h := degree_mul_local (k := 0) hf ∅ (fun _ => c) (by simp)
    (by intro x y h; rfl)
  simpa only [Nat.add_zero] using h

theorem degree_finset_sum {γ : Type} (s : Finset γ)
    (f : γ → (ι → α) → ℝ) (d : ℕ)
    (h : ∀ b ∈ s, Degree d (f b)) :
    Degree d (fun x => ∑ b ∈ s, f b x) := by
  classical
  induction s using Finset.induction_on with
  | empty => simpa using (degree_const (ι := ι) (α := α) d 0)
  | @insert b s hb ih =>
      simpa only [Finset.sum_insert hb] using
        (Degree.add (h b (Finset.mem_insert_self b s))
          (ih (fun a ha => h a (Finset.mem_insert_of_mem ha))))

theorem degree_sum {γ : Type} [Fintype γ]
    (f : γ → (ι → α) → ℝ) (d : ℕ)
    (h : ∀ b, Degree d (f b)) :
    Degree d (fun x => ∑ b, f b x) :=
  degree_finset_sum univ f d (fun b _ => h b)

variable [Fintype ι] [Fintype κ] [Fintype β]

noncomputable def linear (L : κ → κ → ℝ) (r : κ → ℝ) : κ → ℝ :=
  fun k => ∑ v, L k v * r v

/-- A two-address coefficient expansion of a density-matrix oracle update. -/
noncomputable def queryUpdate (C : ι → ι → α → α → κ → κ → ℝ)
    (x : ι → α) (r : κ → ℝ) : κ → ℝ :=
  fun k => ∑ i, ∑ j, ∑ v, C i j (x i) (x j) k v * r v

theorem linear_degree (L : κ → κ → ℝ) (r : (ι → α) → κ → ℝ)
    (d : ℕ) (hr : ∀ k, Degree d (fun x => r x k)) (k : κ) :
    Degree d (fun x => linear L (r x) k) := by
  unfold linear
  exact degree_sum _ d (fun v => degree_scale (hr v) (L k v))

theorem query_degree (C : ι → ι → α → α → κ → κ → ℝ)
    (r : (ι → α) → κ → ℝ) (d : ℕ)
    (hr : ∀ k, Degree d (fun x => r x k)) (k : κ) :
    Degree (d + 2) (fun x => queryUpdate C x (r x) k) := by
  unfold queryUpdate
  apply degree_sum
  intro i
  apply degree_sum
  intro j
  apply degree_sum
  intro v
  apply degree_mul_local (hr v) ({i, j} : Finset ι)
  · calc
      ({i, j} : Finset ι).card ≤ ({j} : Finset ι).card + 1 :=
        Finset.card_insert_le _ _
      _ = 2 := by simp
  · intro x y hxy
    rw [hxy i (by simp), hxy j (by simp)]

/-- The index bounds the number of query nodes on every history.
Stopping early is allowed; branch nodes consume no query budget. -/
inductive Program (ι α κ β : Type) : ℕ → Type where
  | stop (T : ℕ) (E : κ → ℝ) : Program ι α κ β T
  | branch {T : ℕ} (L : β → κ → κ → ℝ)
      (next : β → Program ι α κ β T) : Program ι α κ β T
  | query {T : ℕ} (C : ι → ι → α → α → κ → κ → ℝ)
      (next : Program ι α κ β T) : Program ι α κ β (T + 1)

/-- Actual unnormalized branch evaluation, not a supplied low-degree function. -/
noncomputable def eval : {T : ℕ} → Program ι α κ β T →
    (ι → α) → (κ → ℝ) → ℝ
  | _, .stop _ E, _, r => ∑ k, E k * r k
  | _, .branch L next, x, r => ∑ b, eval (next b) x (linear (L b) r)
  | _, .query C next, x, r => eval next x (queryUpdate C x r)

theorem eval_degree {T : ℕ} (P : Program ι α κ β T) :
    ∀ (d : ℕ) (r : (ι → α) → κ → ℝ),
      (∀ k, Degree d (fun x => r x k)) →
      Degree (d + 2 * T) (fun x => eval P x (r x)) := by
  induction P with
  | stop T E =>
      intro d r hr
      change Degree (d + 2 * T) (fun x => ∑ k, E k * r x k)
      apply degree_mono (e := d + 2 * T)
        (degree_sum _ d (fun k => degree_scale (hr k) (E k)))
      omega
  | @branch T L next ih =>
      intro d r hr
      change Degree (d + 2 * T)
        (fun x => ∑ b, eval (next b) x (linear (L b) (r x)))
      exact degree_sum _ _ (fun b => ih b d _ (linear_degree (L b) r d hr))
  | @query T C next ih =>
      intro d r hr
      change Degree (d + 2 * (T + 1))
        (fun x => eval next x (queryUpdate C x (r x)))
      rw [show d + 2 * (T + 1) = (d + 2) + 2 * T by omega]
      exact ih (d + 2) _ (query_degree C r d hr)

/-- Local positivity and conservation obligations on the chosen state cone.
They are not assumptions on the final acceptance function. -/
def Valid (G : (κ → ℝ) → Prop) (mass : (κ → ℝ) → ℝ) :
    {T : ℕ} → Program ι α κ β T → Prop
  | _, .stop _ E =>
      ∀ r, G r → 0 ≤ (∑ k, E k * r k) ∧ (∑ k, E k * r k) ≤ mass r
  | _, .branch L next =>
      (∀ r, G r → (∀ b, G (linear (L b) r)) ∧
        (∑ b, mass (linear (L b) r)) = mass r) ∧
      ∀ b, Valid G mass (next b)
  | _, .query C next =>
      (∀ x r, G r → G (queryUpdate C x r) ∧
        mass (queryUpdate C x r) = mass r) ∧ Valid G mass next

theorem eval_bounds (G : (κ → ℝ) → Prop) (mass : (κ → ℝ) → ℝ)
    {T : ℕ} (P : Program ι α κ β T) :
    ∀ (h : Valid G mass P) (x : ι → α) (r : κ → ℝ), G r →
      0 ≤ eval P x r ∧ eval P x r ≤ mass r := by
  induction P with
  | stop T E =>
      intro h x r hr
      exact h r hr
  | @branch T L next ih =>
      intro h x r hr
      have hl := h.1 r hr
      have hb (b : β) := ih b (h.2 b) x (linear (L b) r) (hl.1 b)
      change 0 ≤ (∑ b, eval (next b) x (linear (L b) r)) ∧
        (∑ b, eval (next b) x (linear (L b) r)) ≤ mass r
      refine ⟨Finset.sum_nonneg (fun b _ => (hb b).1), ?_⟩
      calc
        (∑ b, eval (next b) x (linear (L b) r)) ≤
            ∑ b, mass (linear (L b) r) :=
          Finset.sum_le_sum (fun b _ => (hb b).2)
        _ = mass r := hl.2
  | @query T C next ih =>
      intro h x r hr
      have hl := h.1 x r hr
      have hb := ih h.2 x (queryUpdate C x r) hl.1
      change 0 ≤ eval next x (queryUpdate C x r) ∧
        eval next x (queryUpdate C x r) ≤ mass r
      exact ⟨hb.1, hl.2 ▸ hb.2⟩

theorem adaptive_degree {T : ℕ} (P : Program ι α κ β T) (r : κ → ℝ) :
    Degree (2 * T) (fun x => eval P x r) := by
  simpa only [zero_add] using
    (eval_degree P 0 (fun _ => r) (fun k => degree_const 0 (r k)))

theorem adaptive_range (G : (κ → ℝ) → Prop) (mass : (κ → ℝ) → ℝ)
    {T : ℕ} (P : Program ι α κ β T) (h : Valid G mass P)
    (r : κ → ℝ) (hr : G r) (hn : mass r = 1) (x : ι → α) :
    0 ≤ eval P x r ∧ eval P x r ≤ 1 := by
  simpa only [hn] using eval_bounds G mass P h x r hr

end Nightfall.AdaptiveInstrument

namespace Nightfall.NegativeKnowledge

/-- Failure certificates survive only provable restriction of feasibility. -/
theorem failure_reuse {W : Type} {F G : Set W} (h : G ⊆ F)
    (hn : ¬ ∃ w, w ∈ F) : ¬ ∃ w, w ∈ G := by
  rintro ⟨w, hw⟩
  exact hn ⟨w, h hw⟩

def Hits {W : Type} (groups : Set (Set W)) (chosen : Finset W) : Prop :=
  ∀ g ∈ groups, ∃ w ∈ chosen, w ∈ g

def Feasible {W : Type} (groups : Set (Set W)) (k : ℕ) : Prop :=
  ∃ chosen : Finset W, chosen.card ≤ k ∧ Hits groups chosen

theorem hitting_feasible_mono {W : Type} {groups : Set (Set W)} {k l : ℕ}
    (hkl : k ≤ l) (h : Feasible groups k) : Feasible groups l := by
  rcases h with ⟨s, hs, hh⟩
  exact ⟨s, hs.trans hkl, hh⟩

theorem hitting_failure_reuse {W : Type} {groups more : Set (Set W)}
    {k l : ℕ} (hkl : l ≤ k) (hgroups : groups ⊆ more)
    (hn : ¬ Feasible groups k) : ¬ Feasible more l := by
  rintro ⟨s, hs, hh⟩
  exact hn ⟨s, hs.trans hkl, fun g hg => hh g (hgroups hg)⟩

theorem enlargement_counterexample :
    (¬ ∃ x : Bool, x ∈ (∅ : Set Bool)) ∧
      (∃ x : Bool, x ∈ ({true} : Set Bool)) := by
  simp

end Nightfall.NegativeKnowledge

namespace Nightfall.InstrumentCounterexamples

abbrev Qubit := Fin 2 → Fin 2 → ℚ
def flip (i : Fin 2) : Fin 2 := if i = 0 then 1 else 0
def branchA (r : Qubit) : Qubit := fun i j => r i j / 2
def branchB (r : Qubit) : Qubit := fun i j => r (flip i) (flip j) / 2
def trace2 (r : Qubit) : ℚ := r 0 0 + r 1 1
def zeroState : Qubit := fun i j => if i = 0 ∧ j = 0 then 1 else 0

/-- Both instruments have the same first-outcome probability on every density,
but their unnormalized postmeasurement states differ. -/
theorem same_outcome_mass (r : Qubit) : trace2 (branchA r) = trace2 (branchB r) := by
  norm_num [trace2, branchA, branchB, flip]
  ring

theorem terminal_separation :
    branchA zeroState 0 0 = 1 / 2 ∧ branchB zeroState 0 0 = 0 := by
  norm_num [branchA, branchB, zeroState, flip]

def parityFourthDifference : ℤ :=
  ∑ a : Fin 2, ∑ b : Fin 2, ∑ c : Fin 2, ∑ d : Fin 2,
    (-1 : ℤ) ^ (a.val + b.val + c.val + d.val) *
      (if (a.val + b.val + c.val + d.val) % 2 = 0 then 1 else 0)

theorem parity_degree_four_witness : parityFourthDifference = 8 := by
  norm_num [parityFourthDifference, Fin.sum_univ_two]

end Nightfall.InstrumentCounterexamples

#print axioms Nightfall.AdaptiveInstrument.query_degree
#print axioms Nightfall.AdaptiveInstrument.adaptive_degree
#print axioms Nightfall.AdaptiveInstrument.adaptive_range
#print axioms Nightfall.NegativeKnowledge.failure_reuse
#print axioms Nightfall.NegativeKnowledge.hitting_failure_reuse
#print axioms Nightfall.NegativeKnowledge.enlargement_counterexample
#print axioms Nightfall.InstrumentCounterexamples.same_outcome_mass
#print axioms Nightfall.InstrumentCounterexamples.terminal_separation
#print axioms Nightfall.InstrumentCounterexamples.parity_degree_four_witness
