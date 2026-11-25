import RankPhaseAdaptiveTree

/-! Rank-phase budget equivalence on actual powered-linear decision trees.
The upper compiler calibrates every coordinate and transports a normalized
phase tree, including zero-coordinate dummy phases. The lower compiler
deletes rank-increasing readings using the explicit Gaussian pivot.
Finite phase packing is constructed by exhaustive legal equality queries,
so the equality of optimal depths is a theorem rather than a premise.
All statements are pending exact-head compilation and kernel review. -/
namespace Nightfall.FiniteField.RankPhaseAdaptiveTree
open Finset
open Nightfall.FiniteField.RankPhasePivot (coord)

namespace Tree
variable {Q Q' A O O' : Type*}

def mapPolicy (qm : Q → Q') (om : O → O') : Tree Q A O → Tree Q' A O'
  | .leaf o => .leaf (om o)
  | .node q next => .node (qm q) (fun b => mapPolicy qm om (next b))

theorem mapPolicy_within (qm : Q → Q') (om : O → O') (D : ℕ)
    (t : Tree Q A O) (ht : Within D t) : Within D (mapPolicy qm om t) := by
  induction D generalizing t with
  | zero =>
    cases t with
    | leaf o => exact leaf_within 0 (om o)
    | node q next => exact (show False from ht).elim
  | succ D ih =>
    cases t with
    | leaf o => exact leaf_within (D+1) (om o)
    | node q next =>
      intro b
      exact ih (next b) (ht b)

theorem mapPolicy_eval (qm : Q → Q') (om : O → O')
    (o₁ : Q → A) (o₂ : Q' → A) (h : ∀ q, o₂ (qm q) = o₁ q)
    (t : Tree Q A O) :
    eval o₂ (mapPolicy qm om t) = om (eval o₁ t) := by
  induction t with
  | leaf o => rfl
  | node q next ih =>
    simp only [mapPolicy, eval, h]
    exact ih (o₁ q)

/-- Scan a finite list of actual legal queries, retaining the transcript. -/
def collect (L : List Q) (finish : List A → Tree Q A O) : Tree Q A O :=
  match L with
  | [] => finish []
  | q::qs => .node q (fun b => collect qs (fun bs => finish (b::bs)))

theorem collect_eval (L : List Q) (finish : List A → Tree Q A O) (o : Q → A) :
    eval o (collect L finish) = eval o (finish (L.map o)) := by
  induction L generalizing finish with
  | nil => rfl
  | cons q qs ih =>
    simp only [collect,eval,List.map_cons]
    exact ih _

theorem collect_within (L : List Q) (finish : List A → Tree Q A O) (D : ℕ)
    (h : ∀ bs, Within D (finish bs)) : Within (L.length+D) (collect L finish) := by
  induction L generalizing finish with
  | nil => simpa [collect] using h []
  | cons q qs ih =>
    simp only [collect,List.length_cons]
    have he : qs.length+1+D = (qs.length+D)+1 := by omega
    rw [he]
    intro b
    exact ih _ (fun bs => h (b::bs))
end Tree

variable {K : Type*} [Field K] [DecidableEq K]
variable {n : ℕ}

noncomputable def root (d : ℕ) (b : K) : K := by
  classical
  exact if h : ∃ u : K, u^d=b then Classical.choose h else 0

theorem root_of_reading (d : ℕ) (x : K) : (root d (x^d))^d = x^d := by
  classical
  unfold root
  rw [dif_pos (show ∃ u : K, u^d=x^d from ⟨x,rfl⟩)]
  exact Classical.choose_spec (show ∃ u : K, u^d=x^d from ⟨x,rfl⟩)

noncomputable def roots (d : ℕ) (c : Vec K n) : Vec K n := fun i => root d (c i)

def liftCalibrated (u : Vec K n) (t : Fin (n+1)) : Vec K n →ₗ[K] Vec K n where
  toFun x := fun i =>
    if u (Equiv.swap 0 t i) = 0 then x t / u t
    else x (Equiv.swap 0 t i) / u (Equiv.swap 0 t i)
  map_add' x y := by
    funext i
    change (if u (Equiv.swap 0 t i) = 0 then (x t+y t)/u t
      else (x (Equiv.swap 0 t i)+y (Equiv.swap 0 t i))/u (Equiv.swap 0 t i)) =
      (if u (Equiv.swap 0 t i) = 0 then x t/u t
        else x (Equiv.swap 0 t i)/u (Equiv.swap 0 t i)) +
      (if u (Equiv.swap 0 t i) = 0 then y t/u t
        else y (Equiv.swap 0 t i)/u (Equiv.swap 0 t i))
    split_ifs <;> rw [add_div]
  map_smul' a x := by
    funext i
    change (if u (Equiv.swap 0 t i) = 0 then (a*x t)/u t
      else (a*x (Equiv.swap 0 t i))/u (Equiv.swap 0 t i)) =
      a * (if u (Equiv.swap 0 t i) = 0 then x t/u t
        else x (Equiv.swap 0 t i)/u (Equiv.swap 0 t i))
    split_ifs <;> rw [mul_div_assoc]

theorem liftCalibrated_apply (u x : Vec K n) (t i : Fin (n+1)) :
    liftCalibrated u t x i =
      if u (Equiv.swap 0 t i) = 0 then x t/u t
      else x (Equiv.swap 0 t i)/u (Equiv.swap 0 t i) := rfl

def decodeCalibrated (u : Vec K n) (t : Fin (n+1)) (y : Vec K n) : Vec K n :=
  fun i => u i * y (Equiv.swap 0 t i)

theorem zero_coordinate {d : ℕ} (hd : 0 < d) (u x : K)
    (h : u^d=x^d) (hu : u=0) : x=0 := by
  by_contra hx
  apply pow_ne_zero d hx
  rw [← h,hu,zero_pow (by omega : d≠0)]

/-- The actual original-coordinate query map and decoder, with all
zero coordinates handled without making an illegal latent query. -/
theorem calibrated_transport {d : ℕ} (hd : 0 < d) (u x : Vec K n)
    (hroot : ∀ i, u i ^ d = x i ^ d) (t : Fin (n+1)) (hut : u t ≠ 0) :
    ∃ y : Vec K n, Phase d y ∧
      (∀ q : Row K n, oracle d x (q.comp (liftCalibrated u t)) = oracle d y q) ∧
      Orbit d (decodeCalibrated u t y) x := by
  let l : K := x t/u t
  have hlpow : l^d=1 := by
    change (x t/u t)^d=1
    rw [div_pow,← hroot t,div_self (pow_ne_zero d hut)]
  have hl := root_ne_zero hd hlpow
  let B := liftCalibrated u t
  let y : Vec K n := l⁻¹ • B x
  have hBx : B x = l • y := by
    dsimp only [y]
    rw [smul_smul,mul_inv_cancel₀ hl,one_smul]
  have hBp (i : Fin (n+1)) : (B x i)^d=1 := by
    change (liftCalibrated u t x i)^d=1
    rw [liftCalibrated_apply]
    split_ifs with h
    · exact hlpow
    · rw [div_pow,← hroot (Equiv.swap 0 t i),div_self (pow_ne_zero d h)]
  have hB0 : B x 0 = l := by
    change liftCalibrated u t x 0 = l
    rw [liftCalibrated_apply]
    simp [hut,l]
  have hy : Phase d y := by
    refine ⟨?_,?_⟩
    · change l⁻¹ * B x 0 = 1
      rw [hB0,inv_mul_cancel₀ hl]
    · intro i
      change (l⁻¹ * B x i)^d=1
      rw [mul_pow,inv_pow,hlpow,hBp i,inv_one,one_mul]
  refine ⟨y,hy,?_,?_⟩
  · intro q
    change (q (B x))^d=(q y)^d
    rw [hBx,map_smul]
    change (l*q y)^d=(q y)^d
    rw [mul_pow,hlpow,one_mul]
  · refine ⟨l⁻¹,by rw [inv_pow,hlpow,inv_one],?_⟩
    funext i
    change u i * (l⁻¹ * liftCalibrated u t x (Equiv.swap 0 t i)) = l⁻¹*x i
    rw [liftCalibrated_apply]
    have hs : Equiv.swap (0 : Fin (n+1)) t (Equiv.swap 0 t i) = i := by simp
    rw [hs]
    by_cases hu : u i=0
    · have hx := zero_coordinate hd (u i) (x i) (hroot i) hu
      simp [hu,hx]
    · rw [if_neg hu]
      field_simp [hu] <;> ring

def readCoordinates (L : List (Fin (n+1))) (c : Vec K n)
    (finish : Vec K n → Policy K n) : Policy K n :=
  match L with
  | [] => finish c
  | i::is => .node (coord i) (fun b => readCoordinates is (Function.update c i b) finish)

theorem readCoordinates_within (L : List (Fin (n+1))) (c : Vec K n)
    (finish : Vec K n → Policy K n) (D : ℕ)
    (h : ∀ v, Tree.Within D (finish v)) :
    Tree.Within (L.length+D) (readCoordinates L c finish) := by
  induction L generalizing c with
  | nil => simpa [readCoordinates] using h c
  | cons i is ih =>
    simp only [readCoordinates,List.length_cons]
    have he : is.length+1+D=(is.length+D)+1 := by omega
    rw [he]
    intro b
    exact ih _

theorem readCoordinates_eval (d : ℕ) (x : Vec K n)
    (L : List (Fin (n+1))) (c : Vec K n) (finish : Vec K n → Policy K n) :
    Tree.eval (oracle d x) (readCoordinates L c finish) =
      Tree.eval (oracle d x) (finish
        (L.foldl (fun v i => Function.update v i ((x i)^d)) c)) := by
  induction L generalizing c with
  | nil => rfl
  | cons i is ih =>
    simp only [readCoordinates,Tree.eval,List.foldl_cons]
    change Tree.eval (oracle d x) (readCoordinates is
      (Function.update c i ((x i)^d)) finish) = _
    exact ih _

theorem fold_update_at (L : List (Fin (n+1))) (c v : Vec K n) (j : Fin (n+1)) :
    (L.foldl (fun z i => Function.update z i (v i)) c) j =
      if j∈L then v j else c j := by
  induction L generalizing c with
  | nil => simp
  | cons i is ih =>
    rw [List.foldl_cons,ih]
    by_cases h : j∈is
    · simp [h]
    · by_cases hji : j=i
      · subst j
        simp [h]
      · simp [h,hji,Function.update_of_ne hji]

noncomputable def calibratedFinish (d : ℕ) (t : Policy K n) (c : Vec K n) :
    Policy K n := by
  classical
  exact if h : ∃ j, roots d c j ≠ 0 then
    Tree.mapPolicy (fun q => q.comp (liftCalibrated (roots d c) (Classical.choose h)))
      (decodeCalibrated (roots d c) (Classical.choose h)) t
  else Tree.leaf 0

theorem calibratedFinish_within (d D : ℕ) (t : Policy K n)
    (ht : Tree.Within D t) (c : Vec K n) :
    Tree.Within D (calibratedFinish d t c) := by
  classical
  unfold calibratedFinish
  split_ifs with h
  · exact Tree.mapPolicy_within _ _ D t ht
  · exact Tree.leaf_within D 0

theorem calibratedFinish_correct (d : ℕ) (hd : 0 < d) (t : Policy K n)
    (ht : ∀ y, Phase d y → Tree.eval (oracle d y) t = y) (x : Vec K n) :
    Orbit d (Tree.eval (oracle d x) (calibratedFinish d t (fun i => (x i)^d))) x := by
  classical
  let c : Vec K n := fun i => (x i)^d
  let u := roots d c
  have hroot (i : Fin (n+1)) : u i ^ d = x i ^ d := root_of_reading d (x i)
  change Orbit d (Tree.eval (oracle d x) (calibratedFinish d t c)) x
  unfold calibratedFinish
  split_ifs with h
  · let j := Classical.choose h
    have hj : u j ≠ 0 := Classical.choose_spec h
    obtain ⟨y,hy,horacle,hout⟩ := calibrated_transport hd u x hroot j hj
    rw [Tree.mapPolicy_eval _ _ (oracle d y) (oracle d x) horacle,ht y hy]
    exact hout
  · have hx : x=0 := by
      funext i
      have hu : u i=0 := by
        by_contra hn
        exact h ⟨i,hn⟩
      exact zero_coordinate hd (u i) (x i) (hroot i) hu
    refine ⟨1,one_pow d,?_⟩
    rw [hx,smul_zero]
    rfl

/-- Coordinate calibration followed by legal transported powered-affine
queries is an actual depth (n+1)+D retrieval tree. -/
theorem packing_implies_retrieval (d D : ℕ) (hd : 0 < d)
    (h : Packing (K := K) (n := n) d D) :
    Retrieval (K := K) (n := n) d (n+1+D) := by
  classical
  obtain ⟨t,ht,hgood⟩ := h
  let L := (univ : Finset (Fin (n+1))).toList
  let T := readCoordinates L 0 (calibratedFinish d t)
  have hlen : L.length=n+1 := by simp [L]
  refine ⟨T,?_ ,?_⟩
  · rw [← hlen]
    exact readCoordinates_within L 0 _ D (calibratedFinish_within d D t ht)
  · intro x
    change Orbit d (Tree.eval (oracle d x) (readCoordinates L 0
      (calibratedFinish d t))) x
    rw [readCoordinates_eval]
    have hc : L.foldl (fun z i => Function.update z i ((x i)^d)) 0 =
        (fun i => (x i)^d) := by
      funext i
      rw [fold_update_at]
      have hi : i∈L := by simp [L]
      rw [if_pos hi]
    rw [hc]
    exact calibratedFinish_correct d hd t hgood x

/-- Exact feasible-budget equivalence, including early stopping and
unreachable answer branches (bounded-depth trees may be pruned there).
No pre-assumed optimal-depth or rank identity. -/
theorem rank_phase_budget_iff (d D : ℕ) (hd : 0 < d) :
    Retrieval (K := K) (n := n) d D ↔
      n+1≤D ∧ Packing (K := K) (n := n) d (D-(n+1)) := by
  constructor
  · exact retrieval_implies_rank_plus_packing d D hd
  · rintro ⟨hD,h⟩
    have hh := packing_implies_retrieval d (D-(n+1)) hd h
    have he : n+1+(D-(n+1))=D := by omega
    rwa [he] at hh

theorem map_eq_on_list {Q A : Type*} (L : List Q) (f g : Q → A)
    (h : L.map f=L.map g) : ∀ q∈L, f q=g q := by
  induction L with
  | nil => simp
  | cons a L ih =>
    simp only [List.map_cons,List.cons.injEq] at h
    intro q hq
    rcases List.mem_cons.mp hq with rfl|hq
    · exact h.1
    · exact ih h.2 q hq

noncomputable def phaseRows [Fintype K] (n : ℕ) : List (Row K n) :=
  (univ : Finset (Fin (n+1) × K)).toList.map
    (fun p => coord p.1 - p.2 • coord 0)

/-- Phase recovery is finite using legal powered-linear equality tests. -/
theorem phaseRows_injective [Fintype K] {d : ℕ} (hd : 0 < d)
    (y z : Vec K n) (hy : Phase d y) (hz : Phase d z)
    (he : (phaseRows (K := K) n).map (oracle d y) =
      (phaseRows (K := K) n).map (oracle d z)) : y=z := by
  classical
  funext i
  let q : Row K n := coord i - y i • coord 0
  have hq : q∈phaseRows (K := K) n := by
    unfold phaseRows
    apply List.mem_map.mpr
    exact ⟨(i,y i),by simp,rfl⟩
  have h := map_eq_on_list _ _ _ he q hq
  change (q y)^d=(q z)^d at h
  have hqy : q y=0 := by simp [q,hy.1]
  have hqz : q z=z i-y i := by simp [q,hz.1]
  rw [hqy,hqz,zero_pow (by omega : d≠0)] at h
  by_contra hn
  exact (pow_ne_zero d (sub_ne_zero.mpr (Ne.symm hn))) h.symm

noncomputable def decodePhaseRows [Fintype K] (d : ℕ) (bs : List K) : Vec K n := by
  classical
  exact if h : ∃ y : Vec K n, Phase d y ∧
    (phaseRows (K := K) n).map (oracle d y)=bs
  then Classical.choose h else 0

theorem packing_exists [Fintype K] (d : ℕ) (hd : 0 < d) :
    ∃ D, Packing (K := K) (n := n) d D := by
  classical
  let L := phaseRows (K := K) n
  let finish : List K → Policy K n := fun bs => Tree.leaf (decodePhaseRows d bs)
  refine ⟨L.length+0,Tree.collect L finish,?_ ,?_⟩
  · exact Tree.collect_within L finish 0 (fun _ => Tree.leaf_within 0 _)
  · intro y hy
    rw [Tree.collect_eval]
    change decodePhaseRows d (L.map (oracle d y)) = y
    unfold decodePhaseRows
    split_ifs with h
    · have hspec := Classical.choose_spec h
      exact phaseRows_injective hd _ y hspec.1 hy hspec.2
    · exact (h ⟨y,hy,rfl⟩).elim

theorem retrieval_exists [Fintype K] (d : ℕ) (hd : 0 < d) :
    ∃ D, Retrieval (K := K) (n := n) d D := by
  obtain ⟨D,hD⟩ := packing_exists (K := K) (n := n) d hd
  exact ⟨n+1+D,packing_implies_retrieval d D hd hD⟩

/-- Paper IV exact rank-phase identity: A(K,d,n+1)=(n+1)+S(K,d,n).
Both finite optimization sets have actual constructed inhabitants. -/
noncomputable def retrievalDepth [Fintype K] (d : ℕ) (hd : 0 < d) : ℕ := by
  classical
  exact Nat.find (retrieval_exists (K := K) (n := n) d hd)

noncomputable def packingDepth [Fintype K] (d : ℕ) (hd : 0 < d) : ℕ := by
  classical
  exact Nat.find (packing_exists (K := K) (n := n) d hd)

theorem exact_rank_phase_identity [Fintype K] (d : ℕ) (hd : 0 < d) :
    retrievalDepth (K := K) (n := n) d hd =
      n+1+packingDepth (K := K) (n := n) d hd := by
  classical
  let hP := packing_exists (K := K) (n := n) d hd
  let hR := retrieval_exists (K := K) (n := n) d hd
  change Nat.find hR = n+1+Nat.find hP
  apply Nat.le_antisymm
  · exact Nat.find_min' hR (packing_implies_retrieval d _ hd (Nat.find_spec hP))
  · obtain ⟨hD,hS⟩ := retrieval_implies_rank_plus_packing d _ hd (Nat.find_spec hR)
    have h := Nat.find_min' hP hS
    omega

#print axioms calibrated_transport
#print axioms packing_implies_retrieval
#print axioms rank_phase_budget_iff
#print axioms packing_exists
#print axioms exact_rank_phase_identity
end Nightfall.FiniteField.RankPhaseAdaptiveTree
