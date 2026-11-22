import Mathlib
import GenuinePrefixPhase
import ProductSphereObstruction

/-! Continuous causal lower bound, with the zero theorem an explicit premise. -/

namespace Nightfall.CausalPhaseConditional

open Nightfall.GenuinePrefixPhase Nightfall.ProductSphereObstruction

abbrev Vec (n : ℕ) := Fin n → ℝ
abbrev Rows (n : ℕ) := ℕ → (ℕ → ℝ) → Vec n

/-- Padded reverse prefixes. The stage gives their unpadded length. -/
def encode : List ℝ → ℕ → ℝ
  | [], _ => 0
  | z :: _, 0 => z
  | _ :: h, j + 1 => encode h j

def oracle {n : ℕ} (r : Rows n) : Oracle (Vec n) :=
  fun h x => mixedDot n (r h.length (encode h)) x

def history {n : ℕ} (r : Rows n) (j : ℕ) (x : Vec n) : ℕ → ℝ :=
  encode (transcript (oracle r) j x)

/-- No continuity on unreachable histories is stipulated. -/
def ReachableContinuous {n : ℕ} (r : Rows n) : Prop :=
  ∀ j, ContinuousOn (r j) (Set.range (history r j))

theorem length_transcript {V : Type*} (a : Oracle V) (j : ℕ) (x : V) :
    (transcript a j x).length = j := by
  induction j with
  | zero => rfl
  | succ i ih => simp [transcript, ih]

theorem oracle_add {n : ℕ} (r : Rows n) (h : List ℝ) (x y : Vec n) :
    oracle r h (x + y) = oracle r h x + oracle r h y := by
  simp [oracle, mixedDot, mul_add, Finset.sum_add_distrib]

theorem oracle_sub {n : ℕ} (r : Rows n) (h : List ℝ) (x y : Vec n) :
    oracle r h (x - y) = oracle r h x - oracle r h y := by
  simp [oracle, mixedDot, mul_sub, Finset.sum_sub_distrib]

theorem oracle_neg {n : ℕ} (r : Rows n) (h : List ℝ) (x : Vec n) :
    oracle r h (-x) = -oracle r h x := by
  simp [oracle, mixedDot, Finset.sum_neg_distrib]

theorem continuous_row_of_history {n : ℕ} (r : Rows n)
    (hr : ReachableContinuous r) (j : ℕ)
    (hj : Continuous (history r j)) :
    Continuous (fun x => r j (history r j x)) := by
  apply continuousOn_univ.mp
  exact (hr j).comp hj.continuousOn (fun x _ => ⟨x, rfl⟩)

theorem continuous_history {n : ℕ} (r : Rows n) (hr : ReachableContinuous r)
    (j : ℕ) : Continuous (history r j) := by
  induction j with
  | zero =>
    apply continuous_pi
    intro i
    simpa [history, transcript, encode] using
      (continuous_const : Continuous (fun _ : Vec n => (0 : ℝ)))
  | succ j ih =>
    have hx := continuous_row_of_history r hr j ih
    have hread : Continuous (fun x : Vec n =>
        (mixedDot n (r j (history r j x)) x) ^ 2) :=
      ((continuous_mixedDot n).comp (hx.prodMk continuous_id)).pow 2
    apply continuous_pi
    intro i
    cases i with
    | zero =>
      simpa [history, transcript, encode, oracle, length_transcript] using hread
    | succ i =>
      change Continuous (fun x => history r j x i)
      exact (continuous_apply i).comp ih

theorem continuous_test {n : ℕ} (r : Rows n) (hr : ReachableContinuous r)
    (j : ℕ) (w : Vec n × Vec n → Vec n) (hw : Continuous w) :
    Continuous (fun p : Vec n × Vec n => comparison (oracle r) j p.1 p.2 (w p)) := by
  have hrow := continuous_row_of_history r hr j (continuous_history r hr j)
  have hplus := hrow.comp (continuous_fst.add continuous_snd)
  have hminus := hrow.comp (continuous_fst.sub continuous_snd)
  have h1 := (continuous_mixedDot n).comp (hplus.prodMk hw)
  have h2 := (continuous_mixedDot n).comp (hminus.prodMk hw)
  have hsum := h1.add h2
  change Continuous (fun z : Vec n × Vec n =>
    mixedDot n (r j (history r j (z.1 + z.2))) (w z) +
    mixedDot n (r j (history r j (z.1 - z.2))) (w z)) at hsum
  simpa [comparison, oracle, history, length_transcript] using hsum

theorem test_neg_arg {n : ℕ} (r : Rows n) (j : ℕ) (u v z : Vec n) :
    comparison (oracle r) j u v (-z) = -comparison (oracle r) j u v z := by
  simp [comparison, oracle_neg]
  ring

theorem nonsign_of_unit {n : ℕ} {u v : Vec n}
    (hu : UnitVec n u) (hv : UnitVec n v) :
    u + v ≠ u - v ∧ u + v ≠ -(u - v) := by
  constructor
  · intro h
    have hv0 : v = 0 := by
      funext i
      have hh := congrFun h i
      change u i + v i = u i - v i at hh
      change v i = 0
      linarith
    simp [UnitVec, hv0] at hv
  · intro h
    have hu0 : u = 0 := by
      funext i
      have hh := congrFun h i
      change u i + v i = -(u i - v i) at hh
      change u i = 0
      linarith
    simp [UnitVec, hu0] at hu

/-- Actual equal transcripts of signals in distinct sign classes, conditional
only on the indicated topological zero principle for a valid split. -/
theorem continuous_causal_collision_of_productSphereZero {n p q : ℕ}
    (hzero : ProductSphereZero n p q) (rows : Rows n)
    (hrows : ReachableContinuous rows) :
    ∃ x y : Vec n, transcript (oracle rows) (p + q) x =
      transcript (oracle rows) (p + q) y ∧ x ≠ y ∧ x ≠ -y := by
  let fU (u v : Vec n) (i : Fin p) := comparison (oracle rows) i.val u v u
  let fV (u v : Vec n) (i : Fin q) := comparison (oracle rows) (p + i.val) u v v
  have hcU : ∀ i, ContinuousOn (fun z : Vec n × Vec n => fU z.1 z.2 i)
      (SpherePair n) := fun i => (continuous_test rows hrows i.val Prod.fst continuous_fst).continuousOn
  have hcV : ∀ i, ContinuousOn (fun z : Vec n × Vec n => fV z.1 z.2 i)
      (SpherePair n) := fun i => (continuous_test rows hrows (p + i.val) Prod.snd continuous_snd).continuousOn
  have hU1 : ∀ u v i, UnitVec n u → UnitVec n v → fU (-u) v i = -fU u v i := by
    intro u v i _ _
    dsimp [fU]
    rw [comparison_flip_left (oracle rows) (oracle_neg rows), test_neg_arg]
  have hU2 : ∀ u v i, UnitVec n u → UnitVec n v → fU u (-v) i = fU u v i := by
    intro u v i _ _
    exact comparison_flip_right _ _ _ _ _
  have hV1 : ∀ u v i, UnitVec n u → UnitVec n v → fV (-u) v i = fV u v i := by
    intro u v i _ _
    exact comparison_flip_left _ (oracle_neg rows) _ _ _ _
  have hV2 : ∀ u v i, UnitVec n u → UnitVec n v → fV u (-v) i = -fV u v i := by
    intro u v i _ _
    dsimp [fV]
    rw [comparison_flip_right, test_neg_arg]
  obtain ⟨u, v, hu, hv, hzU, hzV⟩ := hzero fU fV hcU hcV hU1 hU2 hV1 hV2
  refine ⟨u + v, u - v, ?_, (nonsign_of_unit hu hv).1, (nonsign_of_unit hu hv).2⟩
  apply causal_collision_of_genuine_prefix_zeros _ (oracle_add rows) (oracle_sub rows)
  intro j hj
  by_cases h : j < p
  · exact Or.inl (hzU ⟨j, h⟩)
  · right
    have hi : j - p < q := by omega
    have ht := hzV ⟨j - p, hi⟩
    change comparison (oracle rows) (p + (j - p)) u v v = 0 at ht
    have he : p + (j - p) = j := by omega
    rwa [he] at ht

/-- One external hypothesis at the top split suffices for the sharp threshold;
taking equal prefixes gives counterexamples at every smaller budget. -/
theorem no_universal_continuous_causal_below_threshold {n : ℕ}
    (hzero : ProductSphereZero n (n - 1) (n - 1)) (rows : Rows n)
    (hrows : ReachableContinuous rows) (m : ℕ) (hm : m ≤ (n - 1) + (n - 1)) :
    ∃ x y : Vec n, transcript (oracle rows) m x = transcript (oracle rows) m y ∧
      x ≠ y ∧ x ≠ -y := by
  obtain ⟨x, y, hc, hne, hn⟩ := continuous_causal_collision_of_productSphereZero hzero rows hrows
  have shorten (k : ℕ) (hk : m ≤ k)
      (ht : transcript (oracle rows) k x = transcript (oracle rows) k y) :
      transcript (oracle rows) m x = transcript (oracle rows) m y := by
    induction k with
    | zero =>
      have h : m = 0 := by omega
      subst m
      rfl
    | succ i ih =>
      by_cases h : m = i + 1
      · simpa [h] using ht
      · apply ih (by omega)
        exact congrArg List.tail ht
  exact ⟨x, y, shorten _ hm hc, hne, hn⟩

#check no_universal_continuous_causal_below_threshold
#print axioms continuous_history
#print axioms continuous_causal_collision_of_productSphereZero
#print axioms no_universal_continuous_causal_below_threshold

end Nightfall.CausalPhaseConditional
