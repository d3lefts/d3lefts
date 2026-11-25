import AllOrderChaos

namespace Nightfall.AllOrder
open Finset
variable {A : Type*} [Fintype A] [DecidableEq A]

noncomputable def signedSum (a : A → ℝ) (x : A → Bool) : ℝ := ∑ j, a j * rad (x j)

theorem signedSum_reindex {B : Type*} [Fintype B] (e : A ≃ B) (a : A → ℝ) (x : A → Bool) :
    signedSum a x = ∑ j : B, a (e.symm j) * rad (x (e.symm j)) := by
  unfold signedSum
  exact Fintype.sum_equiv e _ _ (fun j => by simp)

theorem signedSum_second (a : A → ℝ) : avg (fun x => (signedSum a x)^2) = ∑ j, (a j)^2 := by
  let e := Fintype.equivFin A
  let h := Equiv.arrowCongr e (Equiv.refl Bool)
  let b : Fin (Fintype.card A) → ℝ := fun j => a (e.symm j)
  have he : (fun x : A → Bool => (signedSum a x)^2) = (fun x => (linearRad b x)^2) ∘ h := by
    funext x
    unfold Function.comp linearRad b h
    rw [signedSum_reindex e]
    rfl
  rw [he, avg_equiv, linearRad_second]
  exact e.symm.sum_comp (fun j : A => (a j)^2)

theorem signedSum_fourth (a : A → ℝ) : avg (fun x => (signedSum a x)^4) ≤ 3 * (∑ j, (a j)^2)^2 := by
  let e := Fintype.equivFin A
  let h := Equiv.arrowCongr e (Equiv.refl Bool)
  let b : Fin (Fintype.card A) → ℝ := fun j => a (e.symm j)
  have he : (fun x : A → Bool => (signedSum a x)^4) = (fun x => (linearRad b x)^4) ∘ h := by
    funext x
    unfold Function.comp linearRad b h
    rw [signedSum_reindex e]
    rfl
  rw [he, avg_equiv]
  have h4 := linearRad_fourth (Fintype.card A) b
  have hs : (∑ j, (b j)^2) = ∑ j, (a j)^2 := e.symm.sum_comp (fun j : A => (a j)^2)
  rwa [hs] at h4

/-- Actual multilinear block coefficient array on the sign cube. -/
noncomputable def chaos {n : ℕ} (c : (Fin n → A) → ℝ) (x : Fin n → A → Bool) : ℝ :=
    ∑ b, c b * ∏ j, rad (x j (b j))

noncomputable def energy {n : ℕ} (c : (Fin n → A) → ℝ) : ℝ := ∑ b, (c b)^2

theorem energy_nonneg {n : ℕ} (c : (Fin n → A) → ℝ) : 0 ≤ energy c := by unfold energy; positivity

theorem sum_cons {n : ℕ} (f : (Fin (n+1) → A) → ℝ) :
    (∑ b, f b) = ∑ a : A, ∑ b : Fin n → A, f (Fin.cons a b) := by
  let e := Fin.consEquiv (fun _ : Fin (n+1) => A)
  rw [← e.sum_comp f, Fintype.sum_prod_type]
  rfl

theorem energy_cons {n : ℕ} (c : (Fin (n+1) → A) → ℝ) :
    energy c = ∑ a : A, energy (fun b : Fin n → A => c (Fin.cons a b)) := by
  unfold energy
  exact sum_cons _

theorem chaos_cons {n : ℕ} (c : (Fin (n+1) → A) → ℝ) (x : A → Bool) (y : Fin n → A → Bool) :
    chaos c (Fin.cons x y) = signedSum (fun a => chaos (fun b => c (Fin.cons a b)) y) x := by
  unfold chaos signedSum
  rw [sum_cons]
  apply Finset.sum_congr rfl
  intro a _
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro b _
  rw [Fin.prod_univ_succ]
  simp only [Fin.cons_zero, Fin.cons_succ]
  ring

/-- Average over a finite product in the opposite order. -/
theorem avg_swap {Ω Ξ : Type*} [Fintype Ω] [Fintype Ξ] (f : Ω → Ξ → ℝ) :
    avg (fun x => avg (f x)) = avg (fun y => avg (fun x => f x y)) := by
  rw [← avg_prod (fun p : Ω × Ξ => f p.1 p.2), ← avg_prod (fun p : Ξ × Ω => f p.2 p.1)]
  exact avg_equiv (Equiv.prodComm Ω Ξ) (fun p : Ξ × Ω => f p.2 p.1)

theorem chaos_second (n : ℕ) (c : (Fin n → A) → ℝ) :
    avg (fun x => (chaos c x)^2) = energy c := by
  induction n with
  | zero => simp [chaos, energy, avg]
  | succ n ih =>
    rw [avg_fin_succ]
    simp_rw [chaos_cons]
    rw [avg_swap]
    simp_rw [signedSum_second, avg_sum, ih]
    exact (energy_cons c).symm

theorem chaos_fourth (n : ℕ) (c : (Fin n → A) → ℝ) :
    avg (fun x => (chaos c x)^4) ≤ (3 : ℝ)^n * (energy c)^2 := by
  induction n with
  | zero => simp [chaos, energy, avg]; ring_nf; rfl
  | succ n ih =>
    let v (a : A) (y : Fin n → A → Bool) := chaos (fun b => c (Fin.cons a b)) y
    let E (a : A) := energy (fun b : Fin n → A => c (Fin.cons a b))
    rw [avg_fin_succ]
    simp_rw [chaos_cons]
    rw [avg_swap]
    change avg (fun y => avg (fun x => (signedSum (fun a => v a y) x)^4)) ≤ _
    have h1 : avg (fun y => avg (fun x => (signedSum (fun a => v a y) x)^4)) ≤
        avg (fun y => 3 * (∑ a, (v a y)^2)^2) := avg_mono _ _ (fun y => signedSum_fourth _)
    have hE (a : A) : 0 ≤ E a := energy_nonneg _
    have h4 (a : A) : avg (fun y => (v a y)^4) ≤ (3 : ℝ)^n * (E a)^2 := ih _
    have hp (a b : A) : avg (fun y => (v a y)^2 * (v b y)^2) ≤ (3 : ℝ)^n * E a * E b := by
      let p := avg (fun y => (v a y)^2 * (v b y)^2)
      have hpn : 0 ≤ p := avg_nonneg _ (fun y => by positivity)
      have h4a : 0 ≤ avg (fun y => (v a y)^4) := avg_nonneg _ (fun y => by positivity)
      have h4b : 0 ≤ avg (fun y => (v b y)^4) := avg_nonneg _ (fun y => by positivity)
      have hc := avg_cauchy (fun y => (v a y)^2) (fun y => (v b y)^2)
      have hc' : p^2 ≤ avg (fun y => (v a y)^4) * avg (fun y => (v b y)^4) := by
        simpa only [p, ← pow_mul, show 2*2=4 by decide] using hc
      have hbound := hc'.trans (mul_le_mul (h4 a) (h4 b) h4b (by positivity))
      have hsq : p^2 ≤ ((3 : ℝ)^n * E a * E b)^2 := by
        calc
          _ ≤ ((3 : ℝ)^n * (E a)^2) * ((3 : ℝ)^n * (E b)^2) := hbound
          _ = _ := by ring
      have hn : 0 ≤ (3 : ℝ)^n * E a * E b := mul_nonneg (mul_nonneg (by positivity) (hE a)) (hE b)
      nlinarith
    have h2 : avg (fun y => 3 * (∑ a, (v a y)^2)^2) =
        3 * ∑ a, ∑ b, avg (fun y => (v a y)^2 * (v b y)^2) := by
      rw [avg_const_mul]
      congr 1
      simp_rw [pow_two, Finset.sum_mul_sum, avg_sum]
    calc
      _ ≤ _ := h1
      _ = _ := h2
      _ ≤ 3 * ∑ a, ∑ b, (3 : ℝ)^n * E a * E b := by
        apply mul_le_mul_of_nonneg_left _ (by norm_num)
        exact Finset.sum_le_sum (fun a _ => Finset.sum_le_sum (fun b _ => hp a b))
      _ = (3 : ℝ)^(n+1) * (energy c)^2 := by
        rw [energy_cons, pow_succ, pow_two, Finset.sum_mul_sum]
        unfold E
        rw [Finset.mul_sum, Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro a _
        rw [Finset.mul_sum, Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro b _
        ring

#print axioms signedSum_second
#print axioms signedSum_fourth
#print axioms chaos_second
#print axioms chaos_fourth
end Nightfall.AllOrder
