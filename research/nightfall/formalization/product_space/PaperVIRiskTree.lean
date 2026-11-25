import PaperVISquaredEnergy

/-!
Finite-source posterior variance and explicit decision-tree frontier.
Every leaf is the conditional mean, every internal node is an actual
original coordinate, and posterior mass is unnormalized. This module
does not use the older failure-probability stopping-time terminal.
-/
namespace Nightfall.PaperVI
open Finset
open Nightfall.Route1Polylog
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

theorem mvar_le_constant (P : Θ → ι → α → ℝ)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (g : (ι → α) → ℝ) (c : ℝ) :
    mvar P v g ≤ Ex P v (fun x => (g x-c)^2) := by
  have hV : 0 ≤ Vs v := Finset.sum_nonneg fun θ _ => hv θ
  have hm : Ex P v g = Vs v * mmean P v g := by
    rcases hV.eq_or_lt with hz | hp
    · have hz' : ∀ θ, v θ = 0 := fun θ =>
        (Finset.sum_eq_zero_iff_of_nonneg (fun θ _ => hv θ)).mp hz.symm θ (mem_univ θ)
      simp [Ex, hz', ← hz]
    · unfold mmean
      field_simp [hp.ne']
  have hshift (a : ℝ) :
      Ex P v (fun x => (g x-a)^2) =
        Ex P v (fun x => (g x)^2) - 2*a*Ex P v g + a^2*Vs v := by
    unfold Ex pexp
    have he (θ : Θ) (x : ι → α) :
        prodMass (P θ) x * (g x-a)^2 =
        prodMass (P θ) x * (g x)^2 - 2*a*(prodMass (P θ) x*g x) +
          a^2 * prodMass (P θ) x := by ring
    simp_rw [he, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      sum_prodMass _ (hP1 _), mul_one]
    simp only [mul_sub, mul_add, Finset.sum_add_distrib, Finset.sum_sub_distrib]
    unfold Vs
    have h1 : (∑ θ, v θ * (2*a*∑ x, prodMass (P θ) x*g x)) =
        2*a*∑ θ, v θ * ∑ x, prodMass (P θ) x*g x := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun θ _ => by ring
    have h2 : (∑ θ, v θ * a^2) = a^2*∑ θ, v θ := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun θ _ => by ring
    rw [h1,h2]
  unfold mvar
  rw [hshift, hshift, hm]
  nlinarith [mul_nonneg hV (sq_nonneg (mmean P v g-c))]

theorem mvar_children_le (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (g : (ι → α) → ℝ) (j : ι) :
    ∑ b, mvar P (upd P v j b) (sect g j b) ≤ mvar P v g := by
  have h := Ex_split P hP1 v j
    (fun b x => (sect g j b x - mmean P v g)^2)
    (fun b x c => by rw [inv_sect_self g j b x c])
  simp only [sect_self] at h
  unfold mvar
  rw [h]
  exact Finset.sum_le_sum fun b _ =>
    mvar_le_constant P hP1 (upd P v j b)
      (fun θ => mul_nonneg (hv θ) (hP0 θ j b)) (sect g j b) (mmean P v g)

theorem mvar_nonneg_source (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (g : (ι → α) → ℝ) : 0 ≤ mvar P v g := by
  unfold mvar Ex pexp
  exact Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ)
    (Finset.sum_nonneg fun x _ => mul_nonneg (prodMass_nonneg' (P θ) (hP0 θ) x) (sq_nonneg _))

theorem mvar_le_quarter_mass (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (g : (ι → α) → ℝ)
    (hg : ∀ x, 0 ≤ g x ∧ g x ≤ 1) : mvar P v g ≤ (1/4)*Vs v := by
  refine (mvar_le_constant P hP1 v hv g (1/2)).trans ?_
  have h := Ex_mono P v hv hP0 (fun x => (g x-(1/2))^2) (fun _ => (1/4 : ℝ))
    (fun x => by nlinarith [(hg x).1, (hg x).2, mul_nonneg (hg x).1 (sub_nonneg.mpr (hg x).2)])
  rwa [Ex_const P hP1] at h

structure Posterior (ι α Θ : Type) where
  read : Finset ι
  weight : Θ → ℝ
  target : (ι → α) → ℝ

def child (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ) (j : ι) (b : α) : Posterior ι α Θ :=
  ⟨insert j s.read, upd P s.weight j b, sect s.target j b⟩

def legal (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ) : DTree ι α → Prop
  | .leaf c _ => c = mmean P s.weight s.target
  | .node j ts => j ∉ s.read ∧ ∀ b, legal P (child P s j b) (ts b)

noncomputable def frontier (P : Θ → ι → α → ℝ) (F : Posterior ι α Θ → ℝ)
    (s : Posterior ι α Θ) : DTree ι α → ℝ
  | .leaf _ _ => F s
  | .node j ts => ∑ b, frontier P F (child P s j b) (ts b)

noncomputable def mass (s : Posterior ι α Θ) : ℝ := Vs s.weight
noncomputable def risk (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ) : ℝ := mvar P s.weight s.target
noncomputable def entropyCost (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ) : ℝ := Info P s.read s.weight
noncomputable def incrementCost (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ) : ℝ := Phi P s.weight s.target
noncomputable def energyCost (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ) : ℝ := Phi2 P s.weight s.target

theorem frontier_add (P : Θ → ι → α → ℝ) (F G : Posterior ι α Θ → ℝ)
    (s : Posterior ι α Θ) (t : DTree ι α) :
    frontier P (fun z => F z + G z) s t = frontier P F s t + frontier P G s t := by
  induction t generalizing s with
  | leaf c b => rfl
  | node j ts ih =>
    simp only [frontier, ih, Finset.sum_add_distrib]

theorem frontier_smul (P : Θ → ι → α → ℝ) (a : ℝ) (F : Posterior ι α Θ → ℝ)
    (s : Posterior ι α Θ) (t : DTree ι α) :
    frontier P (fun z => a * F z) s t = a * frontier P F s t := by
  induction t generalizing s with
  | leaf c b => rfl
  | node j ts ih => simp only [frontier, ih, Finset.mul_sum]

theorem frontier_mono (P : Θ → ι → α → ℝ) (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (F G : Posterior ι α Θ → ℝ) (hle : ∀ s, S s → F s ≤ G s)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) :
    frontier P F s t ≤ frontier P G s t := by
  induction t generalizing s with
  | leaf c bad => exact hle s hs
  | node j ts ih =>
    obtain ⟨hj, hc⟩ := ht
    exact Finset.sum_le_sum fun b _ => ih b _ (hpres s j b hs hj) (hc b)

theorem legal_eval_inv (P : Θ → ι → α → ℝ) (s : Posterior ι α Θ)
    (t : DTree ι α) (ht : legal P s t) :
    ∀ i ∈ s.read, ∀ x b, t.eval (Function.update x i b) = t.eval x := by
  induction t generalizing s with
  | leaf c bad => simp [DTree.eval]
  | node j ts ih =>
    obtain ⟨hj, hc⟩ := ht
    intro i hi x b
    have hne : j ≠ i := fun he => hj (he.symm ▸ hi)
    simp only [DTree.eval, Function.update_of_ne hne]
    exact ih (x j) _ (hc (x j)) i (Finset.mem_insert_of_mem hi) x b

theorem frontier_risk_exact (P : Θ → ι → α → ℝ)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (s : Posterior ι α Θ) (t : DTree ι α) (ht : legal P s t) :
    frontier P (risk P) s t = Ex P s.weight (fun x => (s.target x - t.eval x)^2) := by
  induction t generalizing s with
  | leaf c bad =>
    change c = mmean P s.weight s.target at ht
    subst c
    rfl
  | node j ts ih =>
    obtain ⟨hj, hc⟩ := ht
    change (∑ b, frontier P (risk P) (child P s j b) (ts b)) = _
    simp_rw [ih _ _ (hc _)]
    have hsplit := Ex_split P hP1 s.weight j
      (fun b x => (sect s.target j b x - (ts b).eval x)^2)
      (fun b x c => by rw [inv_sect_self s.target j b x c,
        legal_eval_inv P (child P s j b) (ts b) (hc b) j (mem_insert_self j s.read) x c])
    simpa only [child, sect_self, DTree.eval] using hsplit.symm

/-- Extend every terminal by one actual query (or freeze it). -/
noncomputable def extend (P : Θ → ι → α → ℝ) (choose : Posterior ι α Θ → Option ι)
    (s : Posterior ι α Θ) : DTree ι α → DTree ι α
  | .leaf c bad =>
    match choose s with
    | none => .leaf c bad
    | some j => .node j fun b => .leaf (mmean P (child P s j b).weight (child P s j b).target) false
  | .node j ts => .node j fun b => extend P choose (child P s j b) (ts b)

theorem extend_legal (P : Θ → ι → α → ℝ) (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (choose : Posterior ι α Θ → Option ι)
    (hchoose : ∀ s j, S s → choose s = some j → j ∉ s.read)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) :
    legal P s (extend P choose s t) := by
  induction t generalizing s with
  | leaf c bad =>
    cases he : choose s with
    | none => simpa [extend,he] using ht
    | some j => exact (by
        simp only [extend,he,legal]
        exact ⟨hchoose s j hs he, fun _ => True.intro⟩)
  | node j ts ih =>
    obtain ⟨hj,hc⟩ := ht
    exact ⟨hj, fun b => ih b _ (hpres s j b hs hj) (hc b)⟩

theorem extend_queries (P : Θ → ι → α → ℝ) (choose : Posterior ι α Θ → Option ι)
    (s : Posterior ι α Θ) (t : DTree ι α) (x : ι → α) :
    (extend P choose s t).queries x ≤ t.queries x + 1 := by
  induction t generalizing s with
  | leaf c bad => cases he : choose s <;> simp [extend, he, DTree.queries]
  | node j ts ih =>
    simp only [extend, DTree.queries]
    have h := ih (x j) (child P s j (x j))
    omega

/-- Exact aggregation of a local one-round cost comparison across a
legal physical transcript. Local statements need only hold on reachable
invariant states. -/
theorem extend_cost_le (P : Θ → ι → α → ℝ) (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (choose : Posterior ι α Θ → Option ι) (F G : Posterior ι α Θ → ℝ)
    (hlocal : ∀ s, S s →
      (match choose s with | none => F s | some j => ∑ b, F (child P s j b)) ≤ G s)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) :
    frontier P F s (extend P choose s t) ≤ frontier P G s t := by
  induction t generalizing s with
  | leaf c bad => cases he : choose s <;> simpa [extend,he,frontier] using hlocal s hs
  | node j ts ih =>
    obtain ⟨hj,hc⟩ := ht
    exact Finset.sum_le_sum fun b _ => ih b _ (hpres s j b hs hj) (hc b)

#print axioms Nightfall.PaperVI.mvar_le_constant
#print axioms Nightfall.PaperVI.mvar_children_le
#print axioms Nightfall.PaperVI.mvar_le_quarter_mass
#print axioms Nightfall.PaperVI.frontier_risk_exact
#print axioms Nightfall.PaperVI.extend_cost_le
#print axioms Nightfall.PaperVI.extend_queries
end Nightfall.PaperVI
