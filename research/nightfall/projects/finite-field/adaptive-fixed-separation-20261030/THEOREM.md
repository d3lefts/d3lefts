# Complement obstructions and adaptive square packing over finite fields

**NIGHTFALL PHASESHIFT research note · 30 October 2026**  
**Research lead:** Devin J. Wright · **Synthesis/proof:** AI-assisted Vesper investigation, building on the earlier NIGHTFALL characteristic-three decoder and classical phase-retrieval complement property.  
**Status:** self-contained mathematical deduction with finite exact regression check. **Independent non-author mathematical review, attribution/historical-priority search, and external acceptance unresolved.** Do not label a worldwide original discovery solely from this note.

## Model and notation

Let `K = F_(3^r)`, `r >= 2`, and `H = F_3^* = {+1,-1}`. Each permitted query chooses a **K-linear form** `a` and returns `(a.x)^2 in K`. In the adaptive model, coefficients for later measurements may depend only on earlier squared outputs; in the nonadaptive model, all coefficient rows are fixed before seeing the signal. Recover **every** `x in K^k`, including zero and arbitrary support, up to a **single global** multiplier in H. Count all coordinate and mixed powered queries. Write `A(k,r)` for minimum worst-case adaptive query count and `F(k,r)` for minimum number of nonadaptive queries achieving all-signal separation.

### Lemma 1: field-independent complement obstruction (classical mechanism)

**Statement.** Let K be any field, `k >= 2`, and `H <= K^*` any subgroup containing an element `zeta != 1`. Let `psi: K -> Y` satisfy `psi(zeta t) = psi(t)` for every t. If a **fixed** family of K-linear forms `a_1,...,a_m` separates every vector in `K^k` modulo H by observations `psi(a_i.x)`, then

```
m >= 2k - 1.
```

**Proof.** If the measurement matrix A has a nonzero kernel, any nonzero kernel vector and the zero vector have identical observations and are inequivalent. Otherwise assume rank(A)=k and `m <= 2k-2`. Partition its rows into subsets S,T, each of size at most `k-1`. Choose nonzero `u in ker(A_S)` and `v in ker(A_T)`. Since `ker(A_S) intersect ker(A_T) = ker A = {0}`, u,v are linearly independent. Set `x=u+v` and `y=u+zeta*v`. On S the linear values of y are zeta times those of x; on T they coincide. H-invariance of psi makes every powered observation equal. Yet `x` and `y` are not globally H-equivalent: `u+zeta v = h(u+v)` would force `h=1=zeta` by independence, a contradiction. QED.

This is the standard **complement-property** obstruction from phase retrieval, stated in a field- and phase-group-invariant form. The lower bound is **not** claimed novel.

### Lemma 2: characteristic-three phase-alphabet packing

**Statement.** For every `r >= 2`, every `k >= 1`, and every signal of support size `s >= 1`, the specified square-power oracle admits a deterministic decoder using

```
k + ceil((s-1)/r)
```

queries, with k queries for the zero signal.

**Proof.** Query `x_j^2` for j=1..k. Detect the support because only zero squares to zero. For each supported coordinate choose a square root `u_j` of its observed value, so `x_j=lambda_j u_j` with `lambda_j in {+1,-1}`. Choose one supported anchor t, let `eta_j=lambda_j/lambda_t`, and split the other s−1 indices into blocks of size b<=r. Fix an F3-basis `beta_1,...,beta_r` of K.

For a block `j_1,...,j_b`, construct the legal K-linear query with anchor coefficient `(sum_{i=1}^b beta_i)/u_t`, coefficient `beta_i/u_(j_i)` on coordinate `j_i`, and zeros elsewhere. The unpowered value is

```
lambda_t * sum_{i=1}^b beta_i (1+eta_(j_i)).
```

Its **square** is the supplied oracle output because `lambda_t^2=1`. Every `1+eta` belongs to `{0,2} subset F3`. If two such basis-coordinate combinations have equal squares, then their unpowered values differ by a sign in K. Equality up to `+1` forces coordinate equality; equality up to `-1` also forces equality because `{0,2} intersect {0,1}={0}` in F3. Thus the powered reading uniquely determines all b relative signs. Reconstruct each supported `xhat_j=eta_j u_j`, with `xhat_t=u_t`. The true signal is `lambda_t*xhat`. Exactly one extra query is used per block; all dependencies were determined by the coordinate-power readings. QED.

This is the existing NIGHTFALL characteristic-three cancellation mechanism, now paired with the classical fixed-obstruction bound. The field can be held fixed while k grows.

### Lemma 3: information lower bound

Each squared query has `M=(3^r+1)/2` distinct possible outputs. The number of global-sign classes of `K^k` is `N_k=(3^(rk)+1)/2` (zero is its own class). Writing `Q=3^r`, the identity

```
N_(a+b) - N_a*N_b = (Q^a-1)*(Q^b-1)/4 > 0
```

for a,b>=1 implies `N_k > M^k` for k>=2. Any adaptive decision tree of depth at most k has at most M^k leaves. Therefore **A(k,r)>=k+1** for k>=2, including early-stopping protocols.

## Theorem: unbounded adaptive/nonadaptive separation

For **all** `k>=2, r>=2`,

```
k+1 <= A(k,r) <= k+ceil((k-1)/r),
F(k,r) >= 2k-1,
F(k,r) - A(k,r) >= k-1-ceil((k-1)/r).
```

**Fixed-field consequence:** already with K=F9 (r=2),

```
F(k,2) - A(k,2) >= floor((k-1)/2),
```

an unbounded gap on a **single fixed nine-element field**, with the same square-power oracle and same all-signal requirement.

**Globally optimal adaptive family:** for `r>=k-1`, one block suffices, so `A(k,r)=k+1` exactly, whereas `F(k,r)>=2k-1`. The gap is at least `k-2`. This is an exact minimax query statement conditional only on the transparent algebraic proof, not on a numerical search. It is **not** an assertion of worldwide novelty.

**F16 comparison (separate field, independently gated):** Tessera's candidate in [PR #255](https://github.com/d3lefts/d3lefts/pull/255) gives `A_F16(k) <= k+ceil(2(k-1)/3)`; Lemma 1 therefore gives `F_F16(k)-A_F16(k) >= floor((k-1)/3)`, subject to independent review of the finite 27-state adaptive block. Do not confuse F16 cubing with F9 squaring.

## Independent finite regression

Run:

```bash
python3 research/nightfall/projects/finite-field/adaptive-fixed-separation-20261030/verify_f9.py
```

The standalone GF9 checker uses `F3[t]/(t^2+1)`; exhausts all `9^3=729` signals, including zero/support; obtains query histogram 3:25, 4:704; independently checks the coordinate-first adaptive decoder and an explicit four-fixed-query ambiguous pair `x=(1,2,1)`, `y=(2,1,1)` under rows `(1,0,0),(0,1,0),(0,0,1),(1,1,1)`. The two vectors are inequivalent under global ± yet every observed square is 1. This numeric check is a regression test, **not** proof for all k; Lemmas 1–3 supply the general proofs.

## Prior art as constructive machinery, not a novelty claim

- **Balan–Casazza–Edidin complement property**: classical real phaseless nonadaptive injectivity mechanism; the lemma above directly adapts its elementary partition obstruction, no novelty claimed. See [algebraic characterization review](https://doi.org/10.1016/j.acha.2014.06.005).
- **Héger–Patkós–Takáts**, _Search Problems in Vector Spaces_, [arXiv:1309.6731](https://arxiv.org/abs/1309.6731): adaptive vs fixed projective search, but different YES/NO subspace oracle.
- **Kemper–Lopatin–Reimers**, _Separating Invariants over Finite Fields_, [arXiv:2011.07408](https://arxiv.org/abs/2011.07408): general polynomial separating sets, not the restricted squared/cubed powers of linear forms.
- **Bourgain–Garaev–Konyagin–Shparlinski**, _On the Hidden Shifted Power Problem_, [arXiv:1110.0812](https://arxiv.org/abs/1110.0812): powered-field oracles and efficient recovery, different inverse problem.

**Originality-sensitive target:** Determine whether this exact all-signals, fixed-field, adaptivity gap for *powered linear forms* is already explicitly established. The complement lemma and characteristic-three sign-cancellation operator alone are elementary/known mechanisms; only the scoped combination and any stronger structural extension are potential novelty candidates. Perform a dated historical search including adaptive real sign-retrieval, finite-field projective search, scalar separating invariants, and disguised linear-decision-tree formulations. External human referee and independent algebra proof audit required.

## Theorem 4: fixed square retrieval is exactly intersecting-code length

Let K be any **finite field of odd characteristic**, and A a fixed `m×k` K-matrix. Assume `rank(A)=k`, and denote `C=im(A) <= K^m`. A linear code C is **intersecting** if every two nonzero codewords have overlapping nonzero coordinate supports.

**Exact equivalence:** The observation map `x -> ((a_i.x)^2)_(i=1..m)` separates all `K^k/{±1}` if and only if C is intersecting.

**Proof, necessity.** If there are nonzero codewords `Au,Av` with disjoint supports, then u,v are linearly independent (since A is injective). The signals `x=u+v` and `y=u-v` are not sign-equivalent, yet each row sees either equal values or negatives, so their squares agree. Thus square recovery implies C intersecting.

**Proof, sufficiency.** If `(Ax)_i^2=(Ay)_i^2` for every i, odd characteristic gives `(Ax)_i=±(Ay)_i`. The two codewords `A(x-y)` and `A(x+y)` have disjoint supports: in each coordinate at least one vanishes. If C is intersecting, one of those two codewords must be zero. As A has full column rank, `x=y` or `x=-y`. QED.

If A is rank-deficient, it cannot distinguish a nonzero kernel vector from zero. Consequently, with Q=|K|, the exact minimum number of **fixed** square-linear queries is

```
F_K(k) = i(k,Q),
```

where `i(k,Q)` denotes the shortest length of a Q-ary **linear intersecting code of dimension k**. This extends the classical complement-property interpretation to a precise coding-theoretic equality; it does **not** claim to invent intersecting codes or the complement property.

### Quantitative transfer from published coding theory (not a new coding bound)

Borello, Schmid and Scotti, _The geometry of intersecting codes and applications to additive combinatorics and factorization theory_, JCTA **214** (2025), 106023, [arXiv:2406.04034](https://arxiv.org/html/2406.04034), prove in their Theorem 3.9:

```
liminf_(k->infinity) i(k,Q)/k >= 2 + 1/(Q-1).
```

For Q=9, this is exactly `17/8=2.125`, and the existing adaptive F9 upper `A(k,2)/k <= 3/2 + o(1)` gives the **rigorously imported asymptotic gap**

```
liminf_(k->infinity) [F(k,2)-A(k,2)]/k >= 17/8 - 3/2 = 5/8 = 0.625.
```

Their Table 1 gives a stronger numerical MRRW-based bound `liminf i(k,9)/k >= approximately 2.2060`, which suggests the improved coefficient approximately `0.7060` (rounded source value; independent high-precision boundary audit recommended).

**Finite dimensions:** The paper's Table 2 for Q=9 yields exact `i(2,9)=3`, `i(3,9)=5`, `i(4,9)=7`, `i(5,9)=9`, `i(6,9)=12`, then `i(7,9) in [14,15]`, `i(8,9) in [16,21]` and `i(9,9) in [18,25]`. These are **published** intersecting-code facts, not NIGHTFALL computational records. For example in dimension 6, the adaptive construction uses at most 9 queries and the nonadaptive minimum is 12: a verified **gap of at least three** in the frozen F9 square oracle.

**Next global research target:** Study the new/old boundary for *adaptive analogues of intersecting codes*: find a geometric characterization of admissible linear-form decision trees, compare its optimal asymptotic rate to i(k,Q), and prove improvements that neither the classical static-code theory nor a single small-field lookup table alone supplies. Require same-oracle priority audit before any claim of originality.

## Next potentially stronger structural theorem

Study `D_{K,H}(k)=F_{K,H}(k)-A_{K,H}(k)` as a function of field extension and multiplicative subgroup. Seek explicit conditions on field/phase alphabet enabling **linear-in-k gap on a fixed field** and prove lower bounds that exceed the elementary 2k−1 complement threshold where possible. Separately compare with the generality and degree cost of static invariant-polynomial interpolation (adaptive decision-tree compilation); do not call interpolation itself a new discovery.

**Research status:** mathematics internally reasoned, finite check independently executed, dedicated GitHub CI and non-author proof review pending; global novelty unverified.

## Independent new checkpoint: phase-calibration ceiling and exact F9 dimensions

For a **coordinate-first** adaptive decoder over K=F9, the k initial coordinate squares leave exactly `2^(s-1)` relative signs for a signal of support size `s`. Every subsequent square query has at most `5` outputs, regardless of adaptive branching; hence after coordinate calibration at least

```
ceil(log_5(2^(s-1)))
```

additional observations are needed. This is only a lower bound within the **coordinate-first protocol class**; it does not lower-bound arbitrary adaptive protocols more strongly than the global 5-ary transcript count.

The original basis decoder attains `k+ceil((s-1)/2)`. Direct exact-integer comparison with `ceil(log_5((9^k+1)/2))` gives:

| k | Global information lower bound | Current adaptive upper bound | Status |
|---:|---:|---:|---|
| 2 | 3 | 3 | exact adaptive optimum |
| 3 | 4 | 4 | exact adaptive optimum |
| 4 | 6 | 6 | exact adaptive optimum |
| 5 | 7 | 7 | exact adaptive optimum |
| 6 | 8 | 9 | one-query gap |
| 7 | 10 | 10 | exact adaptive optimum |
| 8 | 11 | 12 | one-query gap |
| 9 | 12 | 13 | one-query gap |

**Structural transition / new Axiom assignment:** For k=6, a hypothetical eight-query protocol performing all six coordinate squares first would have just two further queries, with `5^2=25 < 2^5=32` remaining phases. Hence **every eight-query solution, if it exists, must depart from full coordinate calibration**. Likewise, for k=8, a putative 11-query protocol must depart from all eight coordinate squares because `5^3=125 < 2^7=128`. This is a rigorous *representation-class obstruction*, not a proof that the global adaptive optimum is above the information bound. The cheapest next experiment is a new calibration geometry that simultaneously identifies supports/amplitudes and phases, first in k=6, without granting uncounted side information.

**Imported finite-code consequence:** Borello–Schmid–Scotti (2025), Table 2, give `i(6,9)=12` and `i(7,9) in [14,15]`. Thus `F_9(6)-A_9(6)>=12-9=3` and `F_9(7)-A_9(7)>=14-10=4`. This combines their coding result with the existing adaptive construction; the intersecting-code length is credited to its authors.

## Additional exact transfer experiment: odd-prime square phases

For *any odd prime power* q and extension K=F_(q^r) with r>=2, using the **square** oracle (a·x)^2 and sign ambiguity H={±1}, the same basis argument recovers at most r relative signs per mixed query. Indeed, `1+eta_i in {0,2}`; over an odd-characteristic base field `{0,2} intersection {0,-2} = {0}`. Thus equality of two powered basis sums forces equality of the relative-sign vectors. The query bound is `k+ceil((s-1)/r)`.

This is an **extension of the previously recorded cancellation mechanism**, not a novelty claim. When q>3 the square oracle has phase subgroup H={±1}, which is a **proper subgroup** of F_q*; it is a different measurement model from the q−1 full-subfield-phase oracle. Maintain that distinction.

Independently authored schoolbook quadratic-extension regression `verify_odd_q_phase.py`, pinned into the same draft PR and CI, exhausts:
- GF9 (p=3, nonsquare 2), k=4: all `6,561` vectors; histogram `{4:33, 5:2432, 6:4096}`.
- GF25 (p=5, nonsquare 2), k=3: all `15,625` vectors; histogram `{3:73, 4:15552}`.
- GF49 (p=7, nonsquare 3), k=3: all `117,649` vectors; histogram `{3:145, 4:117504}`.

All tests count the first-round coordinate squares, build legal second-round coefficients solely from the powered readings, include sparse/zero supports, and verify global sign equivalence. This finite experiment corroborates the q-transfer lemma but is **not** an independent mathematical referee or an all-k proof.

**Organizational source:** [new roles / proof-gated assignments #257](https://github.com/d3lefts/d3lefts/issues/257). No globally original finding declared.
