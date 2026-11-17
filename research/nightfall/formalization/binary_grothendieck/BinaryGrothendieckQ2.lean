import ActualSourceEfronStein

/-!
# Binary products: degree-two influence bound with coefficient 16·K² (< 51 with Krivine)

For a real multilinear polynomial `f` of degree at most two on the cube
`{-1,1}^n` with `|f| ≤ B` at every cube point, and ANY product law on the
cube (coordinate biases arbitrary, including degenerate coordinates),

  `Var(f)^2 ≤ 16 · K^2 · B^2 · max_i Inf_i(f)`

whenever the real Grothendieck inequality holds with constant `K`.
Variance and influences are the repository's original-source
`sourceVariance` / `sourceInfluence` (heat-bath resampling), so the
statement uses the same definitions as the finite Q2 terminal.

**Imported premise (explicit, not proved here).** `GrothendieckIneq K` is
the standard finite-dimensional real Grothendieck inequality in unit-ball
form. With Krivine's classical constant `K = π / (2 log(1 + √2))`
(Krivine 1979) the coefficient `16 K^2` is proved below to be `< 51`.
Grothendieck's inequality itself is NOT formalized here; no Lean library
known to us contains it. This theorem is a corollary of classical
Grothendieck theory and is not claimed as original mathematics.

Proof (all kernel-checked except the named premise):
* residual identity: `f − E_i f = (x_i − m_i) · h_i(x)` with `h_i` the
  coordinate derivative, so `Inf_i ≤ ‖h_i‖²` (exact factorization of the
  product law, `Var(x_i) ≤ 1`);
* Grothendieck with the unit vectors `1, x_1, …, x_n` of `L²(law)` gives
  `Σ_i ‖h_i‖ ≤ K · max_{s,t} Σ_i s_i h_i(t)`;
* polarization: `Σ_i s_i h_i(t) = (3f(u)+f(−u)−f(v)−3f(−v))/2`, and every
  multilinear value at `u = (s+t)/2`, `v = (s−t)/2` is a uniform average of
  cube values, so the sign maximum is at most `4B`;
* certified finite Efron–Stein `Var ≤ Σ Inf_i`, then
  `Var ≤ √M Σ ‖h_i‖ ≤ 4 K B √M`.
-/

namespace Nightfall.BinaryGrothendieck

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.Observability.ActualSourceEfronStein

noncomputable section

/-! ## The imported premise and Krivine's constant -/

/-- Real Grothendieck inequality with constant `K`, finite-dimensional
unit-ball form (vectors in `ℝ^ι` with the standard dot product). -/
def GrothendieckIneq (K : ℝ) : Prop :=
  ∀ (m k : ℕ) (ι : Type) [Fintype ι] (A : Fin m → Fin k → ℝ)
    (u : Fin m → ι → ℝ) (v : Fin k → ι → ℝ),
    (∀ i, ∑ x, u i x ^ 2 ≤ 1) → (∀ j, ∑ x, v j x ^ 2 ≤ 1) →
    ∃ s : Fin m → ℝ, ∃ t : Fin k → ℝ,
      (∀ i, s i = 1 ∨ s i = -1) ∧ (∀ j, t j = 1 ∨ t j = -1) ∧
      ∑ i, ∑ j, A i j * ∑ x, u i x * v j x ≤ K * ∑ i, ∑ j, A i j * s i * t j

/-- Krivine's upper bound for the real Grothendieck constant. -/
def krivineConstant : ℝ := Real.pi / (2 * Real.log (1 + Real.sqrt 2))

theorem log_one_add_sqrt_two_gt : (0.881 : ℝ) < Real.log (1 + Real.sqrt 2) := by
  have h2 : (1.414 : ℝ) < Real.sqrt 2 := by
    rw [show (1.414 : ℝ) = Real.sqrt (1.414 ^ 2) by
      rw [Real.sqrt_sq]; norm_num]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  have hb := Real.exp_bound (x := (0.881 : ℝ)) (by rw [abs_of_pos (by norm_num : (0 : ℝ) < 0.881)]; norm_num)
    (n := 12) (by norm_num)
  rw [abs_of_pos (by norm_num : (0 : ℝ) < 0.881)] at hb
  obtain ⟨_, hb2⟩ := abs_le.mp hb
  norm_num [Finset.sum_range_succ, Nat.factorial] at hb2
  have hexp : Real.exp 0.881 < 1 + Real.sqrt 2 := by linarith
  rw [← Real.exp_lt_exp, Real.exp_log (by positivity)]
  exact hexp

theorem krivine_pos : 0 < krivineConstant := by
  unfold krivineConstant
  have hL := log_one_add_sqrt_two_gt
  exact div_pos Real.pi_pos (by linarith)

theorem krivine_coefficient_lt_51 : 16 * krivineConstant ^ 2 < 51 := by
  have hpi : Real.pi < 3.1416 := by
    first
      | exact Real.pi_lt_d4
      | exact Real.pi_lt_3141593.trans (by norm_num)
      | exact Real.pi_lt_31416
  have hL := log_one_add_sqrt_two_gt
  have hK0 := krivine_pos
  have hK : krivineConstant < 1.783 := by
    unfold krivineConstant
    have hden : (0 : ℝ) < 2 * Real.log (1 + Real.sqrt 2) := by linarith
    first
      | rw [div_lt_iff₀ hden]
      | rw [div_lt_iff hden]
    linarith
  nlinarith

/-! ## Product-law factorization -/

section Factor
variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

theorem originalMass_nonneg' (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) (x : ι → α) :
    0 ≤ originalMass p x := by
  unfold originalMass
  exact Finset.prod_nonneg (fun i _ => hp i (x i))

/-- Independence of one coordinate from a function of the others, from the
certified heat-bath stationarity `actual_source_resample_sum`. -/
theorem mass_factor (p : ι → α → ℝ) (hp1 : ∀ t, ∑ a, p t a = 1) (j : ι)
    (g : α → ℝ) (H : (ι → α) → ℝ)
    (hH : ∀ x a, H (Function.update x j a) = H x) :
    ∑ x, originalMass p x * (g (x j) * H x) =
      (∑ a, p j a * g a) * ∑ x, originalMass p x * H x := by
  classical
  have key := actual_source_resample_sum p hp1 j (fun x => g (x j) * H x)
  try beta_reduce at key
  rw [← key, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  have hin : ∑ a, p j a * (g (Function.update x j a j) * H (Function.update x j a)) =
      (∑ a, p j a * g a) * H x := by
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro a _
    rw [hH, Function.update_apply, if_pos rfl]
    ring
  rw [hin]
  ring

end Factor

/-! ## Signs -/

def sgn (b : Bool) : ℝ := if b then 1 else -1

@[simp] theorem sgn_true : sgn true = 1 := by simp [sgn]
@[simp] theorem sgn_false : sgn false = -1 := by simp [sgn]

theorem sgn_sq (b : Bool) : sgn b ^ 2 = 1 := by cases b <;> norm_num [sgn]

theorem sgn_not (b : Bool) : sgn (!b) = -sgn b := by cases b <;> norm_num [sgn]

theorem sgn_decide {r : ℝ} (h : r = 1 ∨ r = -1) : sgn (decide (r = 1)) = r := by
  rcases h with h | h <;> subst h <;> norm_num [sgn]

variable {n : ℕ}

def sgnv (x : Fin n → Bool) : Fin n → ℝ := fun j => sgn (x j)

def negb (x : Fin n → Bool) : Fin n → Bool := fun j => !x j

theorem sgnv_negb (x : Fin n → Bool) (i : Fin n) : sgnv (negb x) i = -sgnv x i := by
  show sgn (!x i) = -sgn (x i)
  exact sgn_not (x i)

theorem sgnv_update (x : Fin n → Bool) (i : Fin n) (b : Bool) :
    sgnv (Function.update x i b) = Function.update (sgnv x) i (sgn b) := by
  funext j
  show sgn (Function.update x i b j) = Function.update (sgnv x) i (sgn b) j
  rw [Function.update_apply, Function.update_apply]
  split_ifs <;> rfl

theorem sum_delta (f : Fin n → ℝ) (i : Fin n) :
    ∑ k, f k * (if k = i then (1 : ℝ) else 0) = f i := by
  rw [Finset.sum_eq_single i]
  · simp
  · intro k _ hk
    simp [hk]
  · intro h
    exact absurd (Finset.mem_univ i) h

/-! ## Uniform averaging over the cube -/

def unif (n : ℕ) : Fin n → Bool → ℝ := fun _ _ => 1 / 2

theorem unif_sum (i : Fin n) : ∑ a, unif n i a = 1 := by
  rw [Fintype.sum_bool]
  norm_num [unif]

theorem unif_nonneg (i : Fin n) (a : Bool) : 0 ≤ unif n i a := by
  norm_num [unif]

/-- Uniform expectation over `σ ∈ {false,true}^n`. -/
def E (F : (Fin n → Bool) → ℝ) : ℝ := ∑ σ, originalMass (unif n) σ * F σ

theorem E_add (F G : (Fin n → Bool) → ℝ) :
    E (fun σ => F σ + G σ) = E F + E G := by
  unfold E
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro σ _
  ring

theorem E_cmul (c : ℝ) (F : (Fin n → Bool) → ℝ) :
    E (fun σ => c * F σ) = c * E F := by
  unfold E
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro σ _
  ring

theorem E_sum (F : Fin n → (Fin n → Bool) → ℝ) :
    E (fun σ => ∑ i, F i σ) = ∑ i, E (F i) := by
  unfold E
  simp only [Finset.mul_sum]
  exact Finset.sum_comm

theorem E_const (c : ℝ) : E (fun _ : Fin n → Bool => c) = c := by
  unfold E
  rw [← Finset.sum_mul, sum_originalMass' (unif n) unif_sum, one_mul]

theorem E_abs_le (B : ℝ) (F : (Fin n → Bool) → ℝ) (hF : ∀ σ, |F σ| ≤ B) :
    |E F| ≤ B := by
  unfold E
  have hm : ∀ σ, 0 ≤ originalMass (unif n) σ :=
    fun σ => originalMass_nonneg' (unif n) unif_nonneg σ
  calc |∑ σ, originalMass (unif n) σ * F σ|
      ≤ ∑ σ, |originalMass (unif n) σ * F σ| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ σ, originalMass (unif n) σ * |F σ| := by
        apply Finset.sum_congr rfl
        intro σ _
        rw [abs_mul, abs_of_nonneg (hm σ)]
    _ ≤ ∑ σ, originalMass (unif n) σ * B := by
        apply Finset.sum_le_sum
        intro σ _
        exact mul_le_mul_of_nonneg_left (hF σ) (hm σ)
    _ = B := by
        rw [← Finset.sum_mul, sum_originalMass' (unif n) unif_sum, one_mul]

/-! ## Binary quadratic polynomials -/

/-- `f(u) = c + Σ_i a_i u_i + Σ_{i<j} b_ij u_i u_j`, stored with a
symmetric zero-diagonal coefficient matrix. -/
structure BinQuad (n : ℕ) where
  c : ℝ
  a : Fin n → ℝ
  b : Fin n → Fin n → ℝ
  symm : ∀ i j, b i j = b j i
  diag : ∀ i, b i i = 0

namespace BinQuad

variable (Q : BinQuad n)

/-- Multilinear extension to `ℝ^n`. -/
def eval (u : Fin n → ℝ) : ℝ :=
  Q.c + ∑ i, (Q.a i * u i + 1 / 2 * ∑ j, Q.b i j * u i * u j)

/-- Coordinate derivative `∂_i f`, independent of `u_i`. -/
def h (i : Fin n) (u : Fin n → ℝ) : ℝ := Q.a i + ∑ j, Q.b i j * u j

/-- The function on the cube. -/
def cube (x : Fin n → Bool) : ℝ := Q.eval (sgnv x)

theorem h_update (i : Fin n) (u : Fin n → ℝ) (t : ℝ) :
    Q.h i (Function.update u i t) = Q.h i u := by
  unfold BinQuad.h
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  rw [Function.update_apply]
  split_ifs with hj
  · subst hj
    rw [Q.diag]
    ring
  · rfl

theorem eval_affine (i : Fin n) (u : Fin n → ℝ) (t : ℝ) :
    Q.eval (Function.update u i t) = Q.eval (Function.update u i 0) + t * Q.h i u := by
  set w := Function.update u i 0 with hw
  have hv : Function.update u i t = fun j => w j + t * (if j = i then (1 : ℝ) else 0) := by
    funext j
    rw [hw, Function.update_apply, Function.update_apply]
    split_ifs <;> ring
  have hhw : Q.h i w = Q.h i u := Q.h_update i u 0
  rw [hv, ← hhw]
  simp only [BinQuad.eval, BinQuad.h]
  have key : ∀ k,
      Q.a k * (w k + t * (if k = i then (1 : ℝ) else 0)) +
        1 / 2 * ∑ l, Q.b k l * (w k + t * (if k = i then (1 : ℝ) else 0)) *
          (w l + t * (if l = i then (1 : ℝ) else 0))
      = (Q.a k * w k + 1 / 2 * ∑ l, Q.b k l * w k * w l)
        + t * (Q.a k * (if k = i then (1 : ℝ) else 0))
        + t / 2 * ((∑ l, Q.b k l * w l) * (if k = i then (1 : ℝ) else 0))
        + t / 2 * ∑ l, Q.b k l * w k * (if l = i then (1 : ℝ) else 0)
        + t ^ 2 / 2 * ((∑ l, Q.b k l * (if l = i then (1 : ℝ) else 0)) *
            (if k = i then (1 : ℝ) else 0)) := by
    intro k
    have hs : ∑ l, Q.b k l * (w k + t * (if k = i then (1 : ℝ) else 0)) *
          (w l + t * (if l = i then (1 : ℝ) else 0))
        = ∑ l, (Q.b k l * w k * w l
            + t * (Q.b k l * w l * (if k = i then (1 : ℝ) else 0))
            + t * (Q.b k l * w k * (if l = i then (1 : ℝ) else 0))
            + t ^ 2 * (Q.b k l * (if l = i then (1 : ℝ) else 0) *
                (if k = i then (1 : ℝ) else 0))) := by
      apply Finset.sum_congr rfl
      intro l _
      ring
    rw [hs]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.sum_mul]
    ring
  rw [Finset.sum_congr rfl (fun k _ => key k)]
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
  have d1 : ∑ k, Q.a k * (if k = i then (1 : ℝ) else 0) = Q.a i := sum_delta _ i
  have d2 : ∑ k, (∑ l, Q.b k l * w l) * (if k = i then (1 : ℝ) else 0) =
      ∑ l, Q.b i l * w l := sum_delta _ i
  have d3 : ∑ k, ∑ l, Q.b k l * w k * (if l = i then (1 : ℝ) else 0) =
      ∑ k, Q.b i k * w k := by
    apply Finset.sum_congr rfl
    intro k _
    have hk : ∑ l, Q.b k l * w k * (if l = i then (1 : ℝ) else 0) = Q.b k i * w k :=
      sum_delta _ i
    rw [hk, Q.symm k i]
  have d4 : ∑ k, (∑ l, Q.b k l * (if l = i then (1 : ℝ) else 0)) *
      (if k = i then (1 : ℝ) else 0) = 0 := by
    rw [sum_delta _ i, sum_delta _ i, Q.diag]
  rw [d1, d2, d3, d4]
  ring

theorem cube_update (x : Fin n → Bool) (i : Fin n) (b : Bool) :
    Q.cube (Function.update x i b) =
      Q.eval (Function.update (sgnv x) i 0) + sgn b * Q.h i (sgnv x) := by
  unfold BinQuad.cube
  rw [sgnv_update, Q.eval_affine]

theorem cube_self (x : Fin n → Bool) (i : Fin n) :
    Q.cube x = Q.eval (Function.update (sgnv x) i 0) + sgn (x i) * Q.h i (sgnv x) := by
  have hc := Q.cube_update x i (x i)
  rwa [Function.update_eq_self] at hc

theorem residual (q : Fin n → Bool → ℝ) (hq1 : ∀ i, ∑ a, q i a = 1)
    (x : Fin n → Bool) (i : Fin n) :
    Q.cube x - ∑ b, q i b * Q.cube (Function.update x i b) =
      (sgn (x i) - ∑ b, q i b * sgn b) * Q.h i (sgnv x) := by
  have hs : ∑ b, q i b * Q.cube (Function.update x i b) =
      Q.eval (Function.update (sgnv x) i 0) * ∑ b, q i b +
        (∑ b, q i b * sgn b) * Q.h i (sgnv x) := by
    rw [Finset.mul_sum, Finset.sum_mul, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro b _
    rw [Q.cube_update]
    ring
  rw [hs, hq1 i, Q.cube_self x i]
  ring

/-- Each original-source influence is at most the `L²(law)` norm of the
coordinate derivative. -/
theorem influence_le (q : Fin n → Bool → ℝ) (hq : ∀ i a, 0 ≤ q i a)
    (hq1 : ∀ i, ∑ a, q i a = 1) (i : Fin n) :
    sourceInfluence q Q.cube i ≤ ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2 := by
  classical
  unfold sourceInfluence
  set μ := ∑ b, q i b * sgn b with hμ
  have hpt : ∀ x, originalMass q x *
      (Q.cube x - ∑ b, q i b * Q.cube (Function.update x i b)) ^ 2
      = originalMass q x * ((sgn (x i) - μ) ^ 2 * Q.h i (sgnv x) ^ 2) := by
    intro x
    rw [Q.residual q hq1 x i, ← hμ]
    ring
  rw [Finset.sum_congr rfl (fun x _ => hpt x)]
  have hfac := mass_factor q hq1 i (fun a => (sgn a - μ) ^ 2)
    (fun y => Q.h i (sgnv y) ^ 2) (by
      intro y a
      show Q.h i (sgnv (Function.update y i a)) ^ 2 = Q.h i (sgnv y) ^ 2
      rw [sgnv_update, Q.h_update])
  try beta_reduce at hfac
  rw [hfac]
  have hvar : ∑ a, q i a * (sgn a - μ) ^ 2 ≤ 1 := by
    have hb := hq1 i
    rw [Fintype.sum_bool] at hb
    have hμ' : μ = q i true - q i false := by
      rw [hμ, Fintype.sum_bool, sgn_true, sgn_false]
      ring
    rw [Fintype.sum_bool, sgn_true, sgn_false, hμ']
    have hr : q i false = 1 - q i true := by linarith
    rw [hr]
    nlinarith [sq_nonneg (2 * q i true - 1), hq i true]
  have hS : 0 ≤ ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2 :=
    Finset.sum_nonneg (fun x _ => mul_nonneg (originalMass_nonneg' q hq x) (sq_nonneg _))
  calc (∑ a, q i a * (sgn a - μ) ^ 2) * ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2
      ≤ 1 * ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2 :=
        mul_le_mul_of_nonneg_right hvar hS
    _ = ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2 := one_mul _

/-! ## Polarization and the sign maximum -/

theorem bilinear_symm (s t : Fin n → ℝ) :
    ∑ i, ∑ j, Q.b i j * t i * s j = ∑ i, ∑ j, Q.b i j * s i * t j := by
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  rw [Q.symm j i]
  ring

theorem polarization (s t : Fin n → ℝ) :
    ∑ i, s i * Q.h i t =
      (3 * Q.eval (fun i => (s i + t i) / 2) + Q.eval (fun i => (-s i + -t i) / 2)
        - Q.eval (fun i => (s i + -t i) / 2) - 3 * Q.eval (fun i => (-s i + t i) / 2)) / 2 := by
  have h1 : ∑ i, s i * Q.h i t =
      ∑ i, (Q.a i * s i + 1 / 2 * ∑ j, (Q.b i j * s i * t j + Q.b i j * t i * s j)) := by
    have hsym := Q.bilinear_symm s t
    have hl : ∑ i, s i * Q.h i t = ∑ i, Q.a i * s i + ∑ i, ∑ j, Q.b i j * s i * t j := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro i _
      unfold BinQuad.h
      rw [mul_add, Finset.mul_sum]
      congr 1
      · ring
      · apply Finset.sum_congr rfl
        intro j _
        ring
    rw [hl]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [hsym]
    ring
  rw [h1]
  have hi : ∀ i, Q.a i * s i + 1 / 2 * ∑ j, (Q.b i j * s i * t j + Q.b i j * t i * s j) =
      (3 * (Q.a i * ((s i + t i) / 2) +
            1 / 2 * ∑ j, Q.b i j * ((s i + t i) / 2) * ((s j + t j) / 2))
        + (Q.a i * ((-s i + -t i) / 2) +
            1 / 2 * ∑ j, Q.b i j * ((-s i + -t i) / 2) * ((-s j + -t j) / 2))
        - (Q.a i * ((s i + -t i) / 2) +
            1 / 2 * ∑ j, Q.b i j * ((s i + -t i) / 2) * ((s j + -t j) / 2))
        - 3 * (Q.a i * ((-s i + t i) / 2) +
            1 / 2 * ∑ j, Q.b i j * ((-s i + t i) / 2) * ((-s j + t j) / 2))) / 2 := by
    intro i
    have hj : ∑ j, (Q.b i j * s i * t j + Q.b i j * t i * s j) =
        ∑ j, (3 * (Q.b i j * ((s i + t i) / 2) * ((s j + t j) / 2))
          + Q.b i j * ((-s i + -t i) / 2) * ((-s j + -t j) / 2)
          - Q.b i j * ((s i + -t i) / 2) * ((s j + -t j) / 2)
          - 3 * (Q.b i j * ((-s i + t i) / 2) * ((-s j + t j) / 2))) / 2 := by
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [hj]
    simp only [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum]
    ring
  rw [Finset.sum_congr rfl (fun i _ => hi i)]
  simp only [BinQuad.eval, ← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum]
  ring

/-- Multilinear values at `(s+t)/2` are uniform averages over coordinate
mixtures of `s` and `t`. -/
theorem mix (s t : Fin n → ℝ) :
    E (fun σ => Q.eval (fun i => if σ i then s i else t i)) =
      Q.eval (fun i => (s i + t i) / 2) := by
  classical
  have e1 : ∀ i, E (fun σ => if σ i then s i else t i) = (s i + t i) / 2 := by
    intro i
    unfold E
    have h := mass_factor (unif n) unif_sum i (fun a => if a then s i else t i)
      (fun _ => (1 : ℝ)) (fun _ _ => rfl)
    try beta_reduce at h
    simp only [mul_one] at h
    rw [h, sum_originalMass' (unif n) unif_sum, Fintype.sum_bool]
    norm_num [unif]
    try ring
  have e2 : ∀ i j, j ≠ i →
      E (fun σ => (if σ i then s i else t i) * (if σ j then s j else t j)) =
        (s i + t i) / 2 * ((s j + t j) / 2) := by
    intro i j hji
    unfold E
    have h := mass_factor (unif n) unif_sum i (fun a => if a then s i else t i)
      (fun σ => if σ j then s j else t j) (by
        intro x a
        show (if Function.update x i a j then s j else t j) = (if x j then s j else t j)
        rw [Function.update_apply, if_neg hji])
    try beta_reduce at h
    have e1j := e1 j
    unfold E at e1j
    rw [h, e1j, Fintype.sum_bool]
    norm_num [unif]
    try ring
  have e2' : ∀ i j, Q.b i j *
      E (fun σ => (if σ i then s i else t i) * (if σ j then s j else t j)) =
        Q.b i j * ((s i + t i) / 2 * ((s j + t j) / 2)) := by
    intro i j
    by_cases hji : j = i
    · subst hji
      rw [Q.diag]
      ring
    · rw [e2 i j hji]
  simp only [BinQuad.eval, E_add, E_const, E_sum, E_cmul, mul_assoc, e1, e2']

/-- The sign maximum of `Σ_i s_i ∂_i f(t)` is at most `4B`. -/
theorem sign_bound (B : ℝ) (hB : ∀ x, |Q.cube x| ≤ B) (S T : Fin n → Bool) :
    |∑ i, sgnv S i * Q.h i (sgnv T)| ≤ 4 * B := by
  have hE : ∀ S' T' : Fin n → Bool,
      |Q.eval (fun i => (sgnv S' i + sgnv T' i) / 2)| ≤ B := by
    intro S' T'
    rw [← Q.mix (sgnv S') (sgnv T')]
    apply E_abs_le
    intro σ
    show |Q.eval (fun i => if σ i then sgnv S' i else sgnv T' i)| ≤ B
    have hz : (fun i => if σ i then sgnv S' i else sgnv T' i) =
        sgnv (fun i => if σ i then S' i else T' i) := by
      funext i
      by_cases hσ : σ i <;> simp [hσ, sgnv]
    rw [hz]
    exact hB _
  have hpol := Q.polarization (sgnv S) (sgnv T)
  have h1 := hE S T
  have h2 := hE (negb S) (negb T)
  have h3 := hE S (negb T)
  have h4 := hE (negb S) T
  simp only [sgnv_negb] at h2 h3 h4
  rw [hpol]
  obtain ⟨h1l, h1r⟩ := abs_le.mp h1
  obtain ⟨h2l, h2r⟩ := abs_le.mp h2
  obtain ⟨h3l, h3r⟩ := abs_le.mp h3
  obtain ⟨h4l, h4r⟩ := abs_le.mp h4
  rw [abs_le]
  constructor <;> linarith

/-! ## Main theorem -/

/-- **Binary degree-two influence bound, conditional on Grothendieck.**
Any product law `q` on the cube; `sourceVariance`/`sourceInfluence` are the
repository's original-source definitions. -/
theorem binary_q2_grothendieck (K : ℝ) (hK0 : 0 ≤ K) (hG : GrothendieckIneq K)
    (q : Fin n → Bool → ℝ) (hq : ∀ i a, 0 ≤ q i a) (hq1 : ∀ i, ∑ a, q i a = 1)
    (B : ℝ) (hB : ∀ x, |Q.cube x| ≤ B) (M : ℝ) (hM0 : 0 ≤ M)
    (hM : ∀ i, sourceInfluence q Q.cube i ≤ M) :
    (sourceVariance q Q.cube) ^ 2 ≤ 16 * K ^ 2 * B ^ 2 * M := by
  classical
  have hm : ∀ x, 0 ≤ originalMass q x := fun x => originalMass_nonneg' q hq x
  have hm1 : ∑ x, originalMass q x = 1 := sum_originalMass' q hq1
  have hS : ∀ i, 0 ≤ ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2 :=
    fun i => Finset.sum_nonneg (fun x _ => mul_nonneg (hm x) (sq_nonneg _))
  obtain ⟨N, hN⟩ : ∃ N : Fin n → ℝ,
      ∀ i, N i = Real.sqrt (∑ x, originalMass q x * Q.h i (sgnv x) ^ 2) :=
    ⟨_, fun _ => rfl⟩
  have hNsq : ∀ i, N i ^ 2 = ∑ x, originalMass q x * Q.h i (sgnv x) ^ 2 := by
    intro i
    rw [hN i]
    exact Real.sq_sqrt (hS i)
  have hN0 : ∀ i, 0 ≤ N i := fun i => by rw [hN i]; exact Real.sqrt_nonneg _
  have hI0 : ∀ i, 0 ≤ sourceInfluence q Q.cube i := by
    intro i
    unfold sourceInfluence
    exact Finset.sum_nonneg (fun x _ => mul_nonneg (hm x) (sq_nonneg _))
  have hIN : ∀ i, sourceInfluence q Q.cube i ≤ N i ^ 2 := fun i => by
    rw [hNsq i]
    exact Q.influence_le q hq hq1 i
  -- Grothendieck: Σ_i ‖∂_i f‖ ≤ 4 K B
  have hsumN : ∑ i, N i ≤ K * (4 * B) := by
    obtain ⟨u, hu⟩ : ∃ u : Fin n → (Fin n → Bool) → ℝ,
        ∀ i x, u i x = Real.sqrt (originalMass q x) * Q.h i (sgnv x) / N i :=
      ⟨_, fun _ _ => rfl⟩
    obtain ⟨v, hv⟩ : ∃ v : Fin (n + 1) → (Fin n → Bool) → ℝ,
        ∀ j x, v j x = Real.sqrt (originalMass q x) *
          (Fin.cons (1 : ℝ) (sgnv x) : Fin (n + 1) → ℝ) j :=
      ⟨_, fun _ _ => rfl⟩
    obtain ⟨A, hA⟩ : ∃ A : Fin n → Fin (n + 1) → ℝ,
        ∀ i j, A i j = (Fin.cons (Q.a i) (Q.b i) : Fin (n + 1) → ℝ) j :=
      ⟨_, fun _ _ => rfl⟩
    have hvn : ∀ j, ∑ x, v j x ^ 2 ≤ 1 := by
      intro j
      have hc : ∀ x : Fin n → Bool,
          ((Fin.cons (1 : ℝ) (sgnv x) : Fin (n + 1) → ℝ) j) ^ 2 = 1 := by
        intro x
        cases j using Fin.cases with
        | zero => simp
        | succ j' => simp only [Fin.cons_succ]; exact sgn_sq (x j')
      apply le_of_eq
      rw [← hm1]
      apply Finset.sum_congr rfl
      intro x _
      rw [hv, mul_pow, Real.sq_sqrt (hm x), hc x, mul_one]
    have hun : ∀ i, ∑ x, u i x ^ 2 ≤ 1 := by
      intro i
      have hrw : ∑ x, u i x ^ 2 =
          (∑ x, originalMass q x * Q.h i (sgnv x) ^ 2) / N i ^ 2 := by
        rw [Finset.sum_div]
        apply Finset.sum_congr rfl
        intro x _
        rw [hu, div_pow, mul_pow, Real.sq_sqrt (hm x)]
      rw [hrw, ← hNsq i]
      by_cases h0 : N i ^ 2 = 0
      · rw [h0]; norm_num
      · rw [div_self h0]
    have hAv : ∀ i x, ∑ j, A i j * v j x =
        Real.sqrt (originalMass q x) * Q.h i (sgnv x) := by
      intro i x
      rw [Fin.sum_univ_succ]
      simp only [hA, hv, Fin.cons_zero, Fin.cons_succ]
      unfold BinQuad.h
      rw [mul_add, Finset.mul_sum]
      congr 1
      · ring
      · apply Finset.sum_congr rfl
        intro j _
        ring
    have hrow : ∀ i, ∑ j, A i j * ∑ x, u i x * v j x = N i := by
      intro i
      have step : ∑ j, A i j * ∑ x, u i x * v j x = ∑ x, u i x * ∑ j, A i j * v j x := by
        simp only [Finset.mul_sum]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro x _
        apply Finset.sum_congr rfl
        intro j _
        ring
      rw [step]
      have hx : ∀ x, u i x * ∑ j, A i j * v j x =
          originalMass q x * Q.h i (sgnv x) ^ 2 / N i := by
        intro x
        rw [hAv, hu]
        have e := Real.mul_self_sqrt (hm x)
        calc Real.sqrt (originalMass q x) * Q.h i (sgnv x) / N i *
              (Real.sqrt (originalMass q x) * Q.h i (sgnv x))
            = (Real.sqrt (originalMass q x) * Real.sqrt (originalMass q x)) *
                Q.h i (sgnv x) ^ 2 / N i := by ring
          _ = originalMass q x * Q.h i (sgnv x) ^ 2 / N i := by rw [e]
      rw [Finset.sum_congr rfl (fun x _ => hx x), ← Finset.sum_div, ← hNsq i]
      by_cases h0 : N i = 0
      · rw [h0]; norm_num
      · rw [pow_two, mul_div_assoc, div_self h0, mul_one]
    obtain ⟨s, t, hs, ht, hGt⟩ := hG n (n + 1) (Fin n → Bool) A u v hun hvn
    have hτ := ht 0
    have hττ : t 0 * t 0 = 1 := by rcases hτ with h | h <;> rw [h] <;> norm_num
    have hSb : ∀ i, sgnv (fun i => decide (s i = 1)) i = s i :=
      fun i => sgn_decide (hs i)
    have hTb : ∀ j : Fin n, sgnv (fun j : Fin n => decide (t 0 * t j.succ = 1)) j =
        t 0 * t j.succ := by
      intro j
      apply sgn_decide
      rcases hτ with h | h <;> rcases ht j.succ with h' | h' <;> rw [h, h'] <;> norm_num
    have hrow2 : ∀ i, ∑ j, A i j * s i * t j =
        t 0 * (sgnv (fun i => decide (s i = 1)) i *
          Q.h i (sgnv (fun j : Fin n => decide (t 0 * t j.succ = 1)))) := by
      intro i
      rw [Fin.sum_univ_succ, hSb i]
      simp only [hA, Fin.cons_zero, Fin.cons_succ]
      unfold BinQuad.h
      have hX : ∑ j, Q.b i j * sgnv (fun j : Fin n => decide (t 0 * t j.succ = 1)) j =
          t 0 * ∑ j, Q.b i j * t j.succ := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j _
        rw [hTb j]
        ring
      have hY : ∑ j : Fin n, Q.b i j * s i * t j.succ = s i * ∑ j, Q.b i j * t j.succ := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j _
        ring
      rw [hX, hY]
      linear_combination (-(s i * ∑ j, Q.b i j * t j.succ)) * hττ
    have hbound : ∑ i, ∑ j, A i j * s i * t j ≤ 4 * B := by
      rw [Finset.sum_congr rfl (fun i _ => hrow2 i), ← Finset.mul_sum]
      have hP := Q.sign_bound B hB (fun i => decide (s i = 1))
        (fun j : Fin n => decide (t 0 * t j.succ = 1))
      have habs : |t 0| = 1 := by rcases hτ with h | h <;> rw [h] <;> norm_num
      calc t 0 * ∑ i, sgnv (fun i => decide (s i = 1)) i *
            Q.h i (sgnv (fun j : Fin n => decide (t 0 * t j.succ = 1)))
          ≤ |t 0 * ∑ i, sgnv (fun i => decide (s i = 1)) i *
            Q.h i (sgnv (fun j : Fin n => decide (t 0 * t j.succ = 1)))| := le_abs_self _
        _ = |∑ i, sgnv (fun i => decide (s i = 1)) i *
            Q.h i (sgnv (fun j : Fin n => decide (t 0 * t j.succ = 1)))| := by
              rw [abs_mul, habs, one_mul]
        _ ≤ 4 * B := hP
    calc ∑ i, N i = ∑ i, ∑ j, A i j * ∑ x, u i x * v j x :=
          (Finset.sum_congr rfl (fun i _ => hrow i)).symm
      _ ≤ K * ∑ i, ∑ j, A i j * s i * t j := hGt
      _ ≤ K * (4 * B) := mul_le_mul_of_nonneg_left hbound hK0
  -- Efron–Stein and assembly
  have hES := original_source_all_degree_efron_stein q hq hq1 Q.cube
  have hV0 : 0 ≤ sourceVariance q Q.cube := by
    unfold sourceVariance
    exact Finset.sum_nonneg (fun x _ => mul_nonneg (hm x) (sq_nonneg _))
  have hIle : ∀ i, sourceInfluence q Q.cube i ≤ Real.sqrt M * N i := by
    intro i
    have a1 : Real.sqrt (sourceInfluence q Q.cube i) ≤ Real.sqrt M :=
      Real.sqrt_le_sqrt (hM i)
    have a2 : Real.sqrt (sourceInfluence q Q.cube i) ≤ N i := by
      rw [show N i = Real.sqrt (N i ^ 2) from (Real.sqrt_sq (hN0 i)).symm]
      exact Real.sqrt_le_sqrt (hIN i)
    calc sourceInfluence q Q.cube i
        = Real.sqrt (sourceInfluence q Q.cube i) * Real.sqrt (sourceInfluence q Q.cube i) :=
          (Real.mul_self_sqrt (hI0 i)).symm
      _ ≤ Real.sqrt M * N i :=
          mul_le_mul a1 a2 (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hVle : sourceVariance q Q.cube ≤ Real.sqrt M * (K * (4 * B)) := by
    calc sourceVariance q Q.cube ≤ ∑ i, sourceInfluence q Q.cube i := hES
      _ ≤ ∑ i, Real.sqrt M * N i := Finset.sum_le_sum (fun i _ => hIle i)
      _ = Real.sqrt M * ∑ i, N i := by rw [Finset.mul_sum]
      _ ≤ Real.sqrt M * (K * (4 * B)) :=
          mul_le_mul_of_nonneg_left hsumN (Real.sqrt_nonneg M)
  have hR0 : 0 ≤ Real.sqrt M * (K * (4 * B)) := hV0.trans hVle
  have hsq : Real.sqrt M * Real.sqrt M = M := Real.mul_self_sqrt hM0
  have hRR : (Real.sqrt M * (K * (4 * B))) * (Real.sqrt M * (K * (4 * B))) =
      16 * K ^ 2 * B ^ 2 * M := by
    rw [show (Real.sqrt M * (K * (4 * B))) * (Real.sqrt M * (K * (4 * B))) =
        (Real.sqrt M * Real.sqrt M) * (16 * K ^ 2 * B ^ 2) by ring, hsq]
    ring
  calc (sourceVariance q Q.cube) ^ 2
      = sourceVariance q Q.cube * sourceVariance q Q.cube := by ring
    _ ≤ (Real.sqrt M * (K * (4 * B))) * (Real.sqrt M * (K * (4 * B))) :=
        mul_le_mul hVle hVle hV0 hR0
    _ = 16 * K ^ 2 * B ^ 2 * M := hRR

/-- **Coefficient below 51 for binary products**, conditional only on the
real Grothendieck inequality with Krivine's constant. -/
theorem binary_q2_coefficient_lt_51 (hG : GrothendieckIneq krivineConstant)
    (q : Fin n → Bool → ℝ) (hq : ∀ i a, 0 ≤ q i a) (hq1 : ∀ i, ∑ a, q i a = 1)
    (B : ℝ) (hB : ∀ x, |Q.cube x| ≤ B) (M : ℝ) (hM0 : 0 ≤ M)
    (hM : ∀ i, sourceInfluence q Q.cube i ≤ M) :
    (sourceVariance q Q.cube) ^ 2 ≤ 51 * B ^ 2 * M := by
  have h := Q.binary_q2_grothendieck krivineConstant (le_of_lt krivine_pos) hG
    q hq hq1 B hB M hM0 hM
  have hBM : 0 ≤ B ^ 2 * M := mul_nonneg (sq_nonneg B) hM0
  have hc := mul_le_mul_of_nonneg_right (le_of_lt krivine_coefficient_lt_51) hBM
  nlinarith [h, hc]

end BinQuad

end

end Nightfall.BinaryGrothendieck

#print axioms Nightfall.BinaryGrothendieck.krivine_coefficient_lt_51
#print axioms Nightfall.BinaryGrothendieck.BinQuad.polarization
#print axioms Nightfall.BinaryGrothendieck.BinQuad.mix
#print axioms Nightfall.BinaryGrothendieck.BinQuad.influence_le
#print axioms Nightfall.BinaryGrothendieck.BinQuad.binary_q2_grothendieck
#print axioms Nightfall.BinaryGrothendieck.BinQuad.binary_q2_coefficient_lt_51
