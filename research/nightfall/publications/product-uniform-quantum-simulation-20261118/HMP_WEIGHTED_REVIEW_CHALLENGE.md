# Expert challenge: can the HMP completion proof be law-uniform?
**Review packet | 2026-11-18 | provisional, unreviewed**

## Target for the independent referee

Given finite index set I, arbitrary binary product law mu = tensor_i Bernoulli(p_i) with p_i in [0,1], and a Boolean G, set:

- U_b is a nonempty subset of G^{-1}(b), with delta_b = mu(U_b)>0.
- FC(G,x) is the minimum total weight of a nonnegative vector c_x satisfying sum_{i:x_i!=y_i} c_{x,i} >= 1 for every y with G(y)!=G(x). Assume FC(G,x) <= gamma_b for x in U_b.
- Heat-bath influence J_i(G) := Pr_{X~mu, B~mu_i}[G(X)!=G(X_{i<-B})].

**Candidate weighted HMP Lemma 4:** Is there a universal c>0 such that for every mu,G,U_0,U_1 as above,

    max_i J_i(G) >= c * delta_0 * delta_1 / (gamma_0 * gamma_1)  ?

If yes, supply c with complete proof and determine the corresponding simulation theorem for the *real-valued quantum acceptance probability* task, not merely partial Boolean function completion. A result about completion may not directly subsume the [0,1] acceptance approximation at fixed epsilon.

The original theorem is Lemma 4 of Huffstutler--Miloschewsky--Podder, arXiv:2611.12795, with uniform cube densities, flip influence, and constant 1. Their proof:
(1) builds weights w_i from certificate averages over U_1;
(2) marks at least half of U_0 x U_1 using an unweighted Markov bound;
(3) for each subcube C uses a determinant and opposite-pair counting argument N_C <= sum_{i free} w_i b_i;
(4) sums this over all 3^n subcubes and counts each marked (x,y) exactly once via the flip relation x^J=y;
(5) counts an unweighted boundary edge exactly 2^{n-1} times.

## First decisive mathematical obstruction to the naive port

**The flip involution is not measure-preserving under bias.** For n=1, mu(0)=1-p and mu(1)=p. Then

    mu(x^1)/mu(x) = p/(1-p) if x=0, and (1-p)/p if x=1,

so the ratio is unbounded as p->0 or p->1. Thus the original proof's unweighted pairing and summation over all subcubes C cannot simply be reinterpreted as mu-averages with unchanged constants. This is an exact obstruction to *that naive measure-change step*, NOT a counterexample to the candidate weighted lemma.

A heat-bath pair (X, X_{i<-B}) IS exchangeable under arbitrary product mu, which repairs the symmetry used in HMP Lemma 3. But it has repeated endpoints and its distribution differs from the deterministic flip path in the determinant argument. Any new weighted determinant proof must explain how repeated symbols and nonuniform masses interact with its alternating sum, the count of marked pairs, and its boundary-edge factor.

**Sanity case (n=1):** G(0)=0, G(1)=1, U_0={0}, U_1={1}, gamma_0=gamma_1=1. Then J_1(G)=2p(1-p), delta_0 delta_1=p(1-p), so c=1 passes this case. It is not a counterexample and gives no evidence for high dimensions.

## Cheapest reviewer experiments

1. State a probability-weighted replacement of HMP Eq. (4): choose exactly which pair weights go on the left and which heat-bath boundary weights on the right. Check n=1 symbolically and n=2 with p_1 != p_2, including p_i close to zero.
2. Check whether the algebraic determinant Eq. (6) survives a diagonal probability conjugation M -> DMD and whether its monomial-degree / weight argument survives. If not, identify the first false identity precisely.
3. If a valid weighted Lemma 4 follows, reproduce the analogue of HMP Theorem 2 with exact delta and epsilon exponents. Distinguish completion of a partial Boolean function from approximation of a real-valued bounded polynomial Q.
4. Independently inspect our selector Pv/Gsel at ProductRowBound.lean and the mean-increment derivation in ProductSimulation.lean. In particular check the section invariant, zero-mass atoms, the strict <= vs < threshold choices, query depth on all inputs, and how the distribution-dependent tree is selected.

## Preregistration and decision rule

Primary hypothesis H1: HMP weighted Lemma 4 holds with absolute c and yields a faster law-uniform result for partial Boolean completion. H2: it holds only with min-mass-dependent loss. H3: the proposed weighted lemma fails for some product law and Boolean G. These are mutually distinguishable by a full proof with explicit constants or a verified finite counterexample. Numerical counterexample search is a *refutation* tool only, never a proof of H1. Avoid claiming novelty of our simulation merely because an HMP adaptation has not been completed.

Reference: https://arxiv.org/pdf/2611.12795, Lemmas 3 and 4, especially Eq. (4), Eq. (6) and the final subcube sum on page 4. Frozen NIGHTFALL real-function theorem/receipt at 771d11a; run https://github.com/d3lefts/d3lefts/actions/runs/44433153026, artifact 14487982785.

**Certification status:** Challenge constructed; no independent expert has yet accepted or reviewed it. No external paper has been posted.
