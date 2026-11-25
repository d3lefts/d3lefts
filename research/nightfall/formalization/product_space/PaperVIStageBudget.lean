import PaperVIRiskTree

/-!
Paper VI finite block accounting. The budget is a linearization of the
powered alternatives, not a stopping probability or conditional MSE
bound on selected leaves. Every leaf, including unfinished histories,
contributes to the final squared risk.
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

theorem frontier_nonneg (P : Θ → ι → α → ℝ) (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (F : Posterior ι α Θ → ℝ) (hF : ∀ s, S s → 0 ≤ F s)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) :
    0 ≤ frontier P F s t := by
  induction t generalizing s with
  | leaf c bad => exact hF s hs
  | node j ts ih =>
    obtain ⟨hj,hc⟩ := ht
    exact Finset.sum_nonneg fun b _ => ih b _ (hpres s j b hs hj) (hc b)

theorem frontier_mass (P : Θ → ι → α → ℝ)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1) (s : Posterior ι α Θ) (t : DTree ι α) :
    frontier P mass s t = mass s := by
  induction t generalizing s with
  | leaf c bad => rfl
  | node j ts ih =>
    simp only [frontier, ih, mass, child]
    exact Vs_upd_sum P hP1 s.weight j

theorem frontier_energy_cap (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (f : (ι → α) → ℝ) (K : ℝ) (d : ℕ) (s : Posterior ι α Θ)
    (t : DTree ι α) (hs : StD f K d s.read s.weight s.target) (ht : legal P s t) :
    frontier P (energyCost P) s t ≤ (d : ℝ) * frontier P (risk P) s t := by
  let S : Posterior ι α Θ → Prop := fun z => StD f K d z.read z.weight z.target
  have hpres : ∀ z j b, S z → j ∉ z.read → S (child P z j b) :=
    fun z j b hz hj => StD_pres P hP0 f K d z.read z.weight z.target j b hz hj
  have h := frontier_mono P S hpres (energyCost P) (fun z => (d : ℝ)*risk P z)
    (fun z hz => Phi2_le_degree_mvar P hP0 hP1 z.weight hz.1.1 z.target d hz.2)
    s t hs ht
  rwa [frontier_smul] at h

theorem frontier_risk_noninc (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (hpos : ∀ s, S s → ∀ θ, 0 ≤ s.weight θ)
    (choose : Posterior ι α Θ → Option ι)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) :
    frontier P (risk P) s (extend P choose s t) ≤ frontier P (risk P) s t := by
  apply extend_cost_le P S hpres choose (risk P) (risk P) _ s t hs ht
  intro z hz
  cases he : choose z with
  | none => exact le_rfl
  | some j => exact mvar_children_le P hP0 hP1 z.weight (hpos z hz) z.target j

/-- Source-connected block accounting with an explicit local risk charge.
The source crux establishes the charge separately; this theorem supplies
the previously missing exact terminal MSE accounting. -/
theorem risk_block
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (hpos : ∀ s, S s → ∀ θ, 0 ≤ s.weight θ)
    (choose : Posterior ι α Θ → Option ι)
    (hchoose : ∀ s j, S s → choose s = some j → j ∉ s.read)
    (F J : Posterior ι α Θ → ℝ) (hF : ∀ s, S s → 0 ≤ F s)
    (u : ℝ)
    (hcharge : ∀ s, S s → risk P s +
      (match choose s with | none => F s | some j => ∑ b, F (child P s j b))
      ≤ u*mass s + F s)
    (hJ : ∀ s, S s →
      (match choose s with | none => J s | some j => ∑ b, J (child P s j b)) ≤ J s)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) (n : ℕ) :
    ∃ t' : DTree ι α, legal P s t' ∧
      (∀ x, t'.queries x ≤ t.queries x+n) ∧
      frontier P (risk P) s t' ≤ frontier P (risk P) s t ∧
      frontier P J s t' ≤ frontier P J s t ∧
      (n : ℝ) * frontier P (risk P) s t' ≤
        (n : ℝ)*u*mass s + frontier P F s t - frontier P F s t' := by
  induction n with
  | zero =>
    exact ⟨t,ht,by intro x; simp,le_rfl,le_rfl,by simp⟩
  | succ n ih =>
    obtain ⟨t',ht',hq,hR,hj,hbudget⟩ := ih
    let t'' := extend P choose s t'
    have ht'' : legal P s t'' := extend_legal P S hpres choose hchoose s t' hs ht'
    have hR' : frontier P (risk P) s t'' ≤ frontier P (risk P) s t' :=
      frontier_risk_noninc P hP0 hP1 S hpres hpos choose s t' hs ht'
    have hj' : frontier P J s t'' ≤ frontier P J s t' :=
      extend_cost_le P S hpres choose J J hJ s t' hs ht'
    have hlocal : ∀ z, S z →
      (match choose z with | none => F z | some j => ∑ b, F (child P z j b))
        ≤ (u*mass z + F z) + (-1 : ℝ)*risk P z := by
      intro z hz
      have h := hcharge z hz
      linarith
    have hdrop := extend_cost_le P S hpres choose F
      (fun z => (u*mass z+F z)+(-1 : ℝ)*risk P z) hlocal s t' hs ht'
    change frontier P F s t'' ≤ _ at hdrop
    simp only [frontier_add, frontier_smul, frontier_mass P hP1] at hdrop
    have hmult := mul_le_mul_of_nonneg_left hR' (Nat.cast_nonneg n : (0 : ℝ) ≤ n)
    refine ⟨t'',ht'',?_,hR'.trans hR,hj'.trans hj,?_⟩
    · intro x
      have h := extend_queries P choose s t' x
      change t''.queries x ≤ t'.queries x + 1 at h
      have hprev := hq x
      omega
    · rw [Nat.cast_succ]
      nlinarith

theorem risk_block_budget
    (P : Θ → ι → α → ℝ)
    (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)
    (S : Posterior ι α Θ → Prop)
    (hpres : ∀ s j b, S s → j ∉ s.read → S (child P s j b))
    (hpos : ∀ s, S s → ∀ θ, 0 ≤ s.weight θ)
    (choose : Posterior ι α Θ → Option ι)
    (hchoose : ∀ s j, S s → choose s = some j → j ∉ s.read)
    (F J : Posterior ι α Θ → ℝ) (hF : ∀ s, S s → 0 ≤ F s)
    (u : ℝ)
    (hcharge : ∀ s, S s → risk P s +
      (match choose s with | none => F s | some j => ∑ b, F (child P s j b))
      ≤ u*mass s + F s)
    (hJ : ∀ s, S s →
      (match choose s with | none => J s | some j => ∑ b, J (child P s j b)) ≤ J s)
    (s : Posterior ι α Θ) (t : DTree ι α) (hs : S s) (ht : legal P s t) (n : ℕ) (hn : 0 < n) :
    ∃ t' : DTree ι α, legal P s t' ∧
      (∀ x, t'.queries x ≤ t.queries x+n) ∧
      frontier P J s t' ≤ frontier P J s t ∧
      frontier P (risk P) s t' ≤ u*mass s + frontier P F s t/n := by
  obtain ⟨t',ht',hq,_,hj,hb⟩ := risk_block P hP0 hP1 S hpres hpos choose hchoose
    F J hF u hcharge hJ s t hs ht n
  have hnon := frontier_nonneg P S hpres F hF s t' hs ht'
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  refine ⟨t',ht',hq,hj,?_⟩
  have h : (n : ℝ)*frontier P (risk P) s t' ≤ (n : ℝ)*u*mass s + frontier P F s t := by linarith
  have hd : frontier P (risk P) s t' - u*mass s ≤ frontier P F s t/n := by
    rw [le_div_iff₀ hnR]
    nlinarith
  linarith

#print axioms Nightfall.PaperVI.frontier_energy_cap
#print axioms Nightfall.PaperVI.risk_block
#print axioms Nightfall.PaperVI.risk_block_budget
end Nightfall.PaperVI
