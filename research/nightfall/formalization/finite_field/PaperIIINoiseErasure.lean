import Mathlib
import GenuinePrefixPhase
import ProductSphereObstruction

/-! Paper III, section 7, causal compensating-error replay and the high-noise
erasure floor. The actual row is selected at the observed prefix, with squared
Euclidean normalization. No topology premise enters these statements.
The manuscript-specific squared minimax formulation avoids square roots in the
loss itself. Candidate source: a fresh compiler receipt is required. -/

namespace Nightfall.PaperIIINoiseErasure
open Nightfall.GenuinePrefixPhase
open Nightfall.ProductSphereObstruction
open Finset

variable {V : Type*}

/-- Observations are stored in the same reverse order as the certified
noiseless transcript. Errors are indexed by the actual measurement stage. -/
def noisyTranscript (a : Oracle V) (e : ℕ → ℝ) : ℕ → V → List ℝ
  | 0, _ => []
  | j+1, x =>
    let h := noisyTranscript a e j x
    ((a h x)^2 + e j) :: h

theorem zero_noise (a : Oracle V) (m : ℕ) (x : V) :
    noisyTranscript a (fun _ => 0) m x = transcript a m x := by
  induction m with
  | zero => rfl
  | succ j ih => simp only [noisyTranscript, transcript, ih, add_zero]

/-- A single precomputed sequence of errors replays an actual noiseless
prefix on another signal, without regularity of selectors off that prefix. -/
def replayNoise (a : Oracle V) [AddCommGroup V] (x y : V) (j : ℕ) : ℝ :=
  (a (transcript a j x) x)^2 - (a (transcript a j x) y)^2

theorem replay_exact (a : Oracle V) [AddCommGroup V] (x y : V) (m : ℕ) :
    noisyTranscript a (replayNoise a x y) m y = transcript a m x := by
  induction m with
  | zero => rfl
  | succ j ih =>
    simp only [noisyTranscript, ih, replayNoise, transcript]
    congr 1 <;> ring

theorem bounded_replay_collision (a : Oracle V) [AddCommGroup V]
    (x y : V) (m : ℕ) (σ : ℝ)
    (h : ∀ j < m, |(a (transcript a j x) x)^2 -
      (a (transcript a j x) y)^2| ≤ σ) :
    ∃ e : ℕ → ℝ, (∀ j < m, |e j| ≤ σ) ∧
      noisyTranscript a e m y = transcript a m x := by
  exact ⟨replayNoise a x y, h, replay_exact a x y m⟩

def erasureNoise (a : Oracle V) (x : V) (σ : ℝ) (j : ℕ) : ℝ :=
  σ - (a (List.replicate j σ) x)^2

theorem erasure_replay (a : Oracle V) (x : V) (σ : ℝ) (m : ℕ) :
    noisyTranscript a (erasureNoise a x σ) m x = List.replicate m σ := by
  induction m with
  | zero => rfl
  | succ j ih =>
    simp only [noisyTranscript, ih, erasureNoise, List.replicate_succ]
    congr 1 <;> ring

abbrev Signal (n : ℕ) := Fin n → ℝ

def rowAmp {n : ℕ} (rows : List ℝ → Signal n) : Oracle (Signal n) :=
  fun h x => mixedDot n (rows h) x

theorem sqNorm_nonnegative (n : ℕ) (x : Signal n) :
    0 ≤ sqNorm n x := by
  unfold sqNorm
  exact Finset.sum_nonneg (fun i _ => sq_nonneg (x i))

theorem sqNorm_positive (n : ℕ) (x : Signal n) (hx : x ≠ 0) :
    0 < sqNorm n x := by
  have he : ∃ i, x i ≠ 0 := by
    by_contra! h
    apply hx
    funext i
    exact h i
  obtain ⟨i, hi⟩ := he
  have hl : x i ^ 2 ≤ sqNorm n x := by
    unfold sqNorm
    exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)
  exact lt_of_lt_of_le (sq_pos_of_ne_zero hi) hl

theorem normalized_intensity_bound {n : ℕ} (rows : List ℝ → Signal n)
    (hnorm : ∀ h, sqNorm n (rows h) ≤ 1) (h : List ℝ) (x : Signal n) :
    (rowAmp rows h x)^2 ≤ sqNorm n x := by
  have hc : (mixedDot n (rows h) x)^2 ≤ sqNorm n (rows h) * sqNorm n x := by
    exact Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (rows h) x
  exact hc.trans (by simpa using
    mul_le_mul_of_nonneg_right (hnorm h) (sqNorm_nonnegative n x))

theorem erasure_admissible {n : ℕ} (rows : List ℝ → Signal n)
    (hnorm : ∀ h, sqNorm n (rows h) ≤ 1) (x : Signal n)
    (σ : ℝ) (hx : sqNorm n x ≤ 2*σ) (j : ℕ) :
    |erasureNoise (rowAmp rows) x σ j| ≤ σ := by
  have hu := (normalized_intensity_bound rows hnorm (List.replicate j σ) x).trans hx
  have hl := sq_nonneg (rowAmp rows (List.replicate j σ) x)
  apply abs_le.mpr
  constructor <;> unfold erasureNoise <;> linarith

/-- Two coordinate axes suffice to construct a nonzero vector orthogonal
to any decoder output in dimension at least two. -/
theorem nonzero_orthogonal (n : ℕ) (hn : 2 ≤ n) (z : Signal n) :
    ∃ w : Signal n, w ≠ 0 ∧ mixedDot n w z = 0 := by
  classical
  let i : Fin n := ⟨0, by omega⟩
  let j : Fin n := ⟨1, by omega⟩
  have hij : i ≠ j := by
    intro h
    have h' := congrArg Fin.val h
    change 0 = 1 at h'
    omega
  let w : Signal n := fun k => if k = i then z j else if k = j then -z i else 0
  have hd : mixedDot n w z = 0 := by
    unfold mixedDot
    calc
      (∑ k, w k * z k) =
          ∑ k, ((if k = i then z j * z i else 0) +
            (if k = j then -z i * z j else 0)) := by
        apply Finset.sum_congr rfl
        intro k _
        by_cases hki : k = i
        · subst k
          simp [w, hij]
        · by_cases hkj : k = j
          · subst k
            simp [w, hij.symm]
          · simp [w, hki, hkj]
      _ = z j * z i + (-z i * z j) := by simp [Finset.sum_add_distrib]
      _ = 0 := by ring
  by_cases hw : w = 0
  · have hz : z i = 0 := by
      have hh : w j = 0 := congrFun hw j
      simpa [w, hij.symm] using hh
    let e : Signal n := fun k => if k = i then 1 else 0
    refine ⟨e, ?_, ?_⟩
    · intro he
      have hh : e i = 0 := congrFun he i
      norm_num [e] at hh
    · unfold mixedDot
      calc
        (∑ k, e k * z k) = ∑ k, (if k = i then z i else 0) := by
          apply Finset.sum_congr rfl
          intro k _
          by_cases hk : k = i
          · subst k
            simp [e]
          · simp [e, hk]
        _ = 0 := by simp [hz]
  · exact ⟨w, hw, hd⟩

theorem sqNorm_scale (n : ℕ) (c : ℝ) (x : Signal n) :
    sqNorm n (c • x) = c^2 * sqNorm n x := by
  unfold sqNorm
  simp only [Pi.smul_apply, smul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem mixedDot_scale (n : ℕ) (c : ℝ) (x z : Signal n) :
    mixedDot n (c • x) z = c * mixedDot n x z := by
  unfold mixedDot
  simp only [Pi.smul_apply, smul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem orthogonal_prescribed_sqNorm (n : ℕ) (hn : 2 ≤ n)
    (z : Signal n) (b : ℝ) (hb : 0 ≤ b) :
    ∃ x : Signal n, sqNorm n x = b ∧ mixedDot n x z = 0 := by
  obtain ⟨w, hw, hd⟩ := nonzero_orthogonal n hn z
  have hp := sqNorm_positive n w hw
  let c := Real.sqrt (b / sqNorm n w)
  have hc : c^2 = b / sqNorm n w := Real.sq_sqrt (div_nonneg hb hp.le)
  refine ⟨c • w, ?_, ?_⟩
  · rw [sqNorm_scale, hc]
    field_simp [ne_of_gt hp]
  · rw [mixedDot_scale, hd, mul_zero]

def signOrbitSqError (n : ℕ) (x z : Signal n) : ℝ :=
  min (sqNorm n (x-z)) (sqNorm n (x+z))

theorem sqNorm_parallelogram (n : ℕ) (x z : Signal n) :
    sqNorm n (x+z) + sqNorm n (x-z) = 2 * (sqNorm n x + sqNorm n z) := by
  unfold sqNorm
  simp only [Pi.add_apply, Pi.sub_apply]
  rw [← Finset.sum_add_distrib]
  calc
    (∑ i, ((x i + z i)^2 + (x i - z i)^2)) =
        ∑ i, 2 * ((x i)^2 + (z i)^2) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    _ = 2 * ((∑ i, (x i)^2) + ∑ i, (z i)^2) := by
      rw [← Finset.mul_sum, Finset.sum_add_distrib]

theorem orthogonal_sign_error (n : ℕ) (x z : Signal n)
    (h : mixedDot n x z = 0) :
    signOrbitSqError n x z = sqNorm n x + sqNorm n z := by
  have he := sqNorm_eq_of_mixedDot_zero n x z h
  have hs := sqNorm_parallelogram n x z
  have hp : sqNorm n (x+z) = sqNorm n x + sqNorm n z := by linarith
  have hm : sqNorm n (x-z) = sqNorm n x + sqNorm n z := by linarith
  simp [signOrbitSqError, hp, hm]

/-- Paper III, universal erasure floor, squared form: every normalized
causal protocol and decoder has an admissible input and noise sequence
incurring squared sign-quotient loss at least min(R², 2σ). -/
theorem high_noise_floor (n m : ℕ) (hn : 2 ≤ n) (R σ : ℝ)
    (hσ : 0 ≤ σ) (rows : List ℝ → Signal n)
    (hnorm : ∀ h, sqNorm n (rows h) ≤ 1) (decode : List ℝ → Signal n) :
    ∃ (x : Signal n) (e : ℕ → ℝ),
      sqNorm n x ≤ R^2 ∧ (∀ j < m, |e j| ≤ σ) ∧
      min (R^2) (2*σ) ≤ signOrbitSqError n x
        (decode (noisyTranscript (rowAmp rows) e m x)) := by
  let b := min (R^2) (2*σ)
  let z := decode (List.replicate m σ)
  have hb : 0 ≤ b := le_min (sq_nonneg R) (by linarith)
  obtain ⟨x, hx, hd⟩ := orthogonal_prescribed_sqNorm n hn z b hb
  have hxR : sqNorm n x ≤ R^2 := by rw [hx]; exact min_le_left _ _
  have hxσ : sqNorm n x ≤ 2*σ := by rw [hx]; exact min_le_right _ _
  refine ⟨x, erasureNoise (rowAmp rows) x σ, hxR,
    fun j _ => erasure_admissible rows hnorm x σ hxσ j, ?_⟩
  rw [erasure_replay]
  change b ≤ signOrbitSqError n x z
  rw [orthogonal_sign_error n x z hd, hx]
  linarith [sqNorm_nonnegative n z]

theorem zero_decoder_upper (n : ℕ) (R : ℝ) (x : Signal n)
    (hx : sqNorm n x ≤ R^2) :
    signOrbitSqError n x 0 ≤ R^2 := by
  simpa [signOrbitSqError] using hx

/-- Saturation at R²/2: lower bound for every decoder and an explicit
upper bound supplied by the zero decoder. Together these are the exact
squared minimax equality, not just a finite witness. -/
theorem high_noise_saturation (n m : ℕ) (hn : 2 ≤ n) (R σ : ℝ)
    (hσ : R^2 ≤ 2*σ) (rows : List ℝ → Signal n)
    (hnorm : ∀ h, sqNorm n (rows h) ≤ 1) :
    (∀ decode : List ℝ → Signal n, ∃ (x : Signal n) (e : ℕ → ℝ),
      sqNorm n x ≤ R^2 ∧ (∀ j < m, |e j| ≤ σ) ∧
      R^2 ≤ signOrbitSqError n x
        (decode (noisyTranscript (rowAmp rows) e m x))) ∧
    (∀ x : Signal n, sqNorm n x ≤ R^2 → signOrbitSqError n x 0 ≤ R^2) := by
  constructor
  · intro decode
    have hs : 0 ≤ σ := by linarith [sq_nonneg R]
    simpa [min_eq_left hσ] using high_noise_floor n m hn R σ hs rows hnorm decode
  · exact zero_decoder_upper n R

#print axioms bounded_replay_collision
#print axioms high_noise_floor
#print axioms high_noise_saturation
end Nightfall.PaperIIINoiseErasure
