import ActualSourceMatchingCover

/-!
# Q2: dominant-endpoint owner for genuine bounded degree-two source
Each unordered pair has one owner: the endpoint with larger source-derived
cover cost, ties broken by a fixed linear order. This removes fractional
square roots while preserving exact unit-squared ownership and local norm
bounds. This is a scoped intermediate claim, not the terminal Q2 theorem.
-/
namespace Nightfall.Observability.ActualSourceDeterministicOwner
open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceMatchingCover
open Nightfall.Observability.ActualSourcePairAmplitudes
open Nightfall.Observability.ActualProductSourcePairCentering

variable {ι : Type*} [LinearOrder ι]

noncomputable def dominantOwner (c : ι → ℝ) (i j : ι) : ι :=
  if c (min i j) ≤ c (max i j) then max i j else min i j

theorem dominantOwner_symm (c : ι → ℝ) (i j : ι) :
    dominantOwner c i j = dominantOwner c j i := by
  unfold dominantOwner
  rw [min_comm i j, max_comm i j]

theorem dominantOwner_endpoint (c : ι → ℝ) (i j : ι) :
    dominantOwner c i j = i ∨ dominantOwner c i j = j := by
  rcases le_total i j with hij | hji
  · simp only [dominantOwner, min_eq_left hij, max_eq_right hij]
    split_ifs <;> simp
  · simp only [dominantOwner, min_eq_right hji, max_eq_left hji]
    split_ifs <;> simp

theorem dominantOwner_cost_eq_max (c : ι → ℝ) (i j : ι) :
    c (dominantOwner c i j) = max (c i) (c j) := by
  rcases le_total i j with hij | hji
  · simp only [dominantOwner, min_eq_left hij, max_eq_right hij]
    by_cases h : c i ≤ c j
    · simp [h, max_eq_right h]
    · have hh : c j ≤ c i := le_of_lt (lt_of_not_ge h)
      simp [h, max_eq_left hh]
  · simp only [dominantOwner, min_eq_right hji, max_eq_left hji]
    by_cases h : c j ≤ c i
    · simp [h, max_eq_left h]
    · have hh : c i ≤ c j := le_of_lt (lt_of_not_ge h)
      simp [h, max_eq_right hh]

noncomputable def ownedWeight (c : ι → ℝ) (i j : ι) : ℝ :=
  if dominantOwner c i j = i then 1 else 0

theorem ownedWeight_nonneg (c : ι → ℝ) (i j : ι) :
    0 ≤ ownedWeight c i j := by
  unfold ownedWeight
  split_ifs <;> norm_num

theorem ownedWeight_square_partition
    (c : ι → ℝ) (i j : ι) (hij : i ≠ j) :
    (ownedWeight c i j)^2 + (ownedWeight c j i)^2 = 1 := by
  have hs := dominantOwner_symm c i j
  have he := dominantOwner_endpoint c i j
  change (if dominantOwner c i j = i then (1 : ℝ) else 0)^2 +
    (if dominantOwner c j i = j then (1 : ℝ) else 0)^2 = 1
  rw [← hs]
  rcases he with hi | hj
  · simp [hi, hij]
  · simp [hj, hij]

theorem ownedWeight_pair_amplitude_bound
    (c : ι → ℝ) (hc : ∀ i, 0 ≤ c i)
    (w : ι → ι → ℝ)
    (hcover : ∀ i j, w i j ≤ max (c i) (c j))
    (i j : ι) :
    ownedWeight c i j * w i j ≤ c i := by
  have hb : w i j ≤ c (dominantOwner c i j) := by
    rw [dominantOwner_cost_eq_max]
    exact hcover i j
  by_cases hi : dominantOwner c i j = i
  · rw [hi] at hb
    simpa [ownedWeight, hi] using hb
  · simpa [ownedWeight, hi] using hc i

variable {α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Same genuine source derives c, the 8B budget and Boolean ownership.
No owner weights, matching budget or amplitude bound are assumed. -/
theorem original_source_dominant_owner_certificate
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∃ c : ι → ℝ,
      (∀ i, 0 ≤ c i) ∧
      (∑ i : ι, c i) ≤ 8 * B ∧
      (∀ i j : ι, i ≠ j →
        ∀ a b : α,
          ownedWeight c i j *
            |sourceDoubleCenteredPair p f i j a b| ≤ c i) ∧
      (∀ i j : ι, i ≠ j →
        (ownedWeight c i j)^2 +
          (ownedWeight c j i)^2 = 1) := by
  classical
  let T : Finset (ι × ι) :=
    Finset.univ.filter (fun e => e.1 ≠ e.2)
  have hne : ∀ e ∈ T, e.1 ≠ e.2 := by
    intro e he
    exact (Finset.mem_filter.mp he).2
  obtain ⟨c, hc, hbudget, hcover⟩ :=
    source_greedy_attained_endpoint_cover
      (E := ι × ι) (ι := ι) (α := α)
      p hp hp1 f hdegree base
      (fun e : ι × ι => e.1) (fun e : ι × ι => e.2)
      T hne B hf
  refine ⟨c, hc, hbudget, ?_, ?_⟩
  · intro i j hij a b
    have hw : pairAmplitudeWeight p f i j ≤ max (c i) (c j) := by
      apply hcover (i, j)
      simp [T, hij]
    have hpair : |sourceDoubleCenteredPair p f i j a b| ≤
        max (c i) (c j) :=
      (source_pair_amplitude_dominated p f i j a b).trans hw
    have hcost : |sourceDoubleCenteredPair p f i j a b| ≤
        c (dominantOwner c i j) := by
      rw [dominantOwner_cost_eq_max]
      exact hpair
    by_cases hi : dominantOwner c i j = i
    · rw [hi] at hcost
      simpa [ownedWeight, hi] using hcost
    · simpa [ownedWeight, hi] using hc i
  · intro i j hij
    exact ownedWeight_square_partition c i j hij
end Nightfall.Observability.ActualSourceDeterministicOwner
