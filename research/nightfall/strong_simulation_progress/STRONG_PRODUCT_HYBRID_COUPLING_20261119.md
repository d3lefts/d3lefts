# Strong product simulation and mixture identification by one-sided coupling + quantum hybrid
Date 2026-11-19. **Author-side paper proof, not a full Lean certificate, not reviewed.**

## Why this operator matters

The earlier #893 argument transfers a uniform-cube strong simulator to arbitrary
product laws by applying Bernstein/Markov to a high-degree smoothing polynomial
of a failure indicator. That introduces an analytic formalization obligation and
a block-size fixed point involving the classical simulator depth. The
one-sided dyadic rounding/coupling in #895, combined with the *quantum hybrid
argument on the original query algorithm*, yields a simpler transfer: **no
smoothing, no polynomial-degree interpolation, no fixed point, and no positive
atom margin** for the **product** case.

A second use of the same hybrid argument supplies the **component
identification mean-shift step under a positive atom margin**, thereby
closing the analytic Bernstein dependency of the original #893
positive-margin *paper proof*. This does **not** settle the bias-free
known-component classifier of #894, which is a stronger target.

Strongest external theorem used: Blanc–Docter–Strassle–Tan,
*Quantum Speedups Require Structure or Depth* (arXiv:2608.19158v1),
Theorem 1 and Proposition B.1, on uniform Boolean input and the query
hybrid bound. This note treats those as established external results,
not kernel formalized by NIGHTFALL.

## Lemma H: quantum conditional-mismatch stability

Let A be a quantum algorithm with at most t>=1 total symbol-oracle
queries in the standard coherent value-oracle model. Write
f(x)∈[0,1] for its acceptance probability.
Suppose (X,Y) is an arbitrary coupling of two input arrays with

    sup_i Pr[Y_i ≠ X_i | X=x] ≤ λ            (H1)

for every x in the support of X, where 0≤λ≤1.
The coordinates of Y need not be independent conditional on X; only
the indicated one-coordinate conditional bounds are used.

For each query occurrence q∈[t] and input x, let w_(q,i)(x) be the
nonnegative probability that A's query index equals i immediately
before query q on input x. Then

    Σ_i w_(q,i)(x)=1.

The standard quantum hybrid argument, telescoping the oracle
substitutions while keeping A's pre-query states on x, gives

    |f(x)-f(y)| ≤ 4 Σ_(q=1)^t
        sqrt(Σ_(i:x_i≠y_i) w_(q,i)(x)).             (H2)

(The factor 4 accommodates both state-vector telescoping and the
acceptance-measurement Lipschitz bound; a smaller constant might hold
in the phase oracle model.)

Conditioning on X=x, Jensen/Cauchy–Schwarz for the concave square root
and (H1) yield

    E[|f(X)-f(Y)| | X=x]
     ≤ 4 Σ_q sqrt(Σ_i w_(q,i)(x) Pr[Y_i≠X_i|X=x])
     ≤ 4 t sqrt(λ).                                 (H3)

Hence

    E|f(X)-f(Y)| ≤ 4t sqrt(λ),
    Pr(|f(X)-f(Y)|>h) ≤ 4t sqrt(λ)/h  (h>0).          (H4)

No dimension n, atom margin, or degree argument occurs in this proof.
For a parallel d-round algorithm, enumerate all t query registers
in causal order (parallel queries can be treated as sequential with no
extra queries) when deriving (H2). The **quantum oracle interface and
hybrid telescoping proof are an independent formalization obligation**.

## Lemma D: one-sided dyadic uniform encoding of a product law

Let P=⊗ p_i, each alphabet Σ_i finite with |Σ_i|≤A≥2, permitting
zero atoms. Choose m with N=2^m≥A(A-1). For each coordinate choose an
anchor a_i maximizing p_i(a); then p_i(a_i)≥1/A.

For each non-anchor symbol a set q_i(a)=ceil(N p_i(a))/N and let
q_i(a_i)=1−Σ_(a≠a_i)q_i(a). Every q_i is a valid dyadic probability
vector. There is a Markov kernel C_i(y|x), supported on y=x
for x≠a_i, that pushes p_i to q_i:

    C_i(x|x)=1 when x≠a_i;
    C_i(y|a_i)=(q_i(y)-p_i(y))/p_i(a_i) when y≠a_i;
    C_i(a_i|a_i)=q_i(a_i)/p_i(a_i).

Consequently, for all x with p_i(x)>0,

    Pr[Y_i≠X_i | X_i=x]≤A(A-1)/N≤A² 2^(-m).  (D1)

Sample the coordinates independently conditional on X, generating Y,
which has law Q=⊗q_i.

Partition {0,1}^m into preimages of sizes Nq_i(a), defining a
deterministic block decoder g_i. Given Y_i=a sample U_i uniformly
from g_i^{-1}(a). The resulting U=(U_i) is **uniform on the
Boolean cube of m-bit blocks**, and g(U)=Y. Given an original input x,
the same joint law can be lazily simulated by drawing each U_i
from its conditional distribution given X_i=x_i when the corresponding
block is first accessed, then caching it for all subsequent adaptive
bit queries. It uses **one whole-symbol input query per distinct block
queried** by the simulator.

Even if q_i(a)=0, symbols with p_i(a)>0 cannot have q_i(a)=0
under the one-sided construction: all non-anchor atoms were rounded
up. Moreover the anchor is strictly positive when N≥A(A−1):
its rounding loss is strictly less than (A−1)/N≤1/A≤p_i(a_i).
Thus Y is supported on symbols with q_i(a)>0, so the second-stage
conditional distribution U_i|Y_i exists; sampling the composite
U_i|X_i works on the entire support of P.

## Theorem P: strong product transfer without a margin

Assume the original t-query d-round coherent finite-alphabet
quantum algorithm A and the strong uniform Boolean simulator of
BDST Theorem 1, with worst-case decision-tree depth

    S(T,r,α,β) =
       2^{O(r²)} (T log(1/β)/α)^{O(r)}.

Construct g and C as in Lemma D. The pulled-back algorithm
A∘g on uniform bit blocks uses at most 2mt Boolean-oracle queries,
at most 2d query rounds. Its acceptance probability is f(g(U))=f(Y).

Choose the uniform simulator's accuracy α=ε/2 and failure β=δ/2.
Decode its queried bits through the lazy conditional U|X sampler
to obtain a *randomized* whole-symbol tree of depth at most
S(2mt,2d,ε/2,δ/2). Under X~P, the induced U is uniform.
Hence the simulator fails to approximate f(Y) within ε/2 on
probability at most δ/2.

By (H4), with λ=A²2^-m,

    Pr(|f(X)-f(Y)|>ε/2) ≤ 8t A 2^(-m/2)/ε.

Choose m such that N=2^m≥A(A-1) and

    A² 2^-m ≤ (εδ/(16t))²,

equivalently m≥2 log₂ A+2 log₂(16t/(εδ)).
The quantum coupling failure is then at most δ/2. A union bound gives

    Pr_(X~P,decoder randomness)(|f(X)-T(X)|>ε) ≤ δ.

Average over the lazy decoder's global random tape and fix a tape:
there exists a **deterministic** whole-symbol tree T of the same
worst-case depth satisfying

    Pr_(X~P)(|f(X)-T(X)|>ε) ≤ δ.

Therefore

    D_product(t,d,ε,δ,A)
      ≤ 2^{O(d²)}
         (t[log A+log(t/(εδ))] log(1/δ)/ε)^{O(d)}

with universal hidden constants inherited from BDST (d becomes 2d).
For fixed d this is polylogarithmic in 1/δ with **no lower
bound on atom probabilities**. This is a paper-level reduction of
one established quantum theorem to another setting, not a Lean proof
of either theorem.

## Lemma C: positive-margin component identification without Bernstein

Let P and Q be known finite products with **every atom** at least
c>0 and let f be the acceptance probability of a t>=1 query
algorithm. For coordinate i set
γ_i=max_a|p_i(a)-q_i(a)|. Let
γ=max_i γ_i.

A coordinatewise maximal coupling X~P,Y~Q can be chosen so that,
conditionally on X_i=x,

    Pr(Y_i≠X_i | X_i=x)
       =(p_i(x)-q_i(x))_+/p_i(x) ≤ γ_i/c.

Apply Lemma H to A, or to A after fixing any subset of coordinates
to an observed assignment. Then

    |E_P f - E_Q f| ≤ 4t sqrt(γ/c).            (C1)

For the conditioned tail under a frozen assignment to large-gap
coordinates, the restricted quantum algorithm still makes at most t
unfixed-coordinate queries. Thus (C1) holds at every frozen assignment.

Fix ε>0 and choose θ = c ε²/(64 t²).
Let L={i: γ_i≥θ} and R be the remaining coordinates. For every
assignment x_L, (C1) yields

    |E_(P_R) f(x_L,.) - E_(Q_R) f(x_L,.)|
       ≤4t sqrt(θ/c)=ε/2<ε.

If f is concentrated within ε of u,v∈[0,1] under P,Q
with failures ≤ρ and |u−v|≥4ε, Steps 3–4 of the previous
component-identification proof imply that a likelihood-ratio test on L
has total error ≤2ρ/(|u−v|−(5/2)ε), in particular ≤2ρ/ε.

If |L| is large, query any K coordinates of L. Each coordinate
has total variation ≥θ and squared Hellinger distance ≥θ²/2,
so taking

    K = ceil(2 θ^(-2) log(1/ζ))
      = ceil(8192 t^4 /(c² ε⁴) log(1/ζ))

gives a product Bhattacharyya affinity ≤ζ, and hence total
likelihood test error ≤ζ. Otherwise query every coordinate of L,
at most K, and use the failure-mass bound above.

Therefore, in the positive-margin setting, the entire **analytic
Bernstein step** of Lemma 1 can be replaced by a quantum-hybrid
argument; its query budget is looser, but still polynomial in
t, 1/ε, 1/c, log(1/ζ).

## Theorem M: positive-margin strong latent-mixture simulation (paper reduction)

For each of M known product components, apply Theorem P with
per-component error radius ε and failure probability ρ,
producing a deterministic tree of depth D_product.
Run all M component trees and freeze their joint preliminary
transcript. At every transcript, the unqueried coordinates are still
product under each component and the restricted f is still an
at-most-t-query quantum acceptance probability.
For pairs of outputs differing by at least 4ε, invoke Lemma C
with test-tail ζ; select the test query sets **before seeing duel
outcomes**. The weighted posterior-duel argument of #893 implies
the two-sided probability of a wrong duel between j,k is at most
ζ+2ρ/ε, even with unequal preliminary transcript masses.

When the true component's simulator is ε-accurate and it
wins every decisive duel it enters, it is undefeated and every
undefeated candidate is within 4ε of its value. The final value
is within 5ε of f. For instance take ζ=δ/(4M),
ρ=εδ/(8M), for 0<ε≤1/2 and δ∈(0,1).
The resulting total mixture failure is ≤δ. Its depth is at most

    M D_product(t,d,ε,εδ/(8M),A)
    + binom(M,2) ceil(
        8192 t^4/(c² ε⁴) log(4M/δ)
      ).

For fixed d this is polynomial in M,t,1/c,1/ε and
**polylogarithmic** in 1/δ. All constructions are query-depth
existence results; no running-time claim is made.

Theorem P's product transfer permits zero atoms. Theorem M,
as stated here, still uses positive margin in Lemma C. The stronger
fully zero-atom mixture theorem requires PR #894's
Markov/common-part classifier or another no-margin identification
inequality; it is **not** claimed here.

## Obligations and adversarial audit

- **Analytical source checked:** BDST Theorem 1 and hybrid Proposition B.1,
  arXiv:2608.19158v1. The textbook hybrid proof extends to whole-symbol
  oracle values with the same ≤2 operator-norm difference per query;
  verify the exact finite-alphabet query model in an independent review.
- **Exact finite coupling:** #895's `conditional_seed_exact_check.py`
  checks 240+ dyadic examples using `Fraction` but does not prove
  general reconstruction or the quantum query hybrid bound in Lean.
- **Lean obligations:** (i) the conditional quantum hybrid expectation
  bound with actual query weights, (ii) source-to-encoded coherent oracle
  circuit, (iii) dyadic conditional sampler, (iv) product Hellinger
  tensorization, (v) source-level global frozen tournament.
- **External authorship:** The central hybrid method is due to
  Bennett–Bernstein–Brassard–Vazirani, and BDST prove the uniform
  bounded-round strong simulation theorem. The distributional
  composition and one-sided conditional coupling are NIGHTFALL
  author-side derivations, not independently reviewed or novelty-cleared.
- **Failure of unjustified stronger claim:** The previous interpolation
  bounds for arbitrary degree-d functions are not consequences of
  the quantum hybrid lemma, because the hybrid requires an actual
  quantum-query realization of f. Do not extend Theorem M to all
  bounded degree≤2t functions using this replacement.
