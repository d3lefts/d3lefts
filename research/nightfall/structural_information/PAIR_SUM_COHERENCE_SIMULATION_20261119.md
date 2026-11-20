# Pair-sum collisions replace frames at one quantum query

Date: 2026-11-19. Source branch: structural-information-theory. Version: 1.0.

**Certification:** independent author-side universal mathematical proof, a distinct exact-rational finite regression, and dated partial prior-art screen. NOT Lean checked or independent human refereed. The result is an **all-algorithm one-query** approximation theorem; the all-T structural characterization remains OPEN. Do not confuse it with Boolean decision problems or worst-case input promises.

## Definitions

Let S be uniform on F_2^m, with query bits X_r = <r,S> for row vectors r in a finite set R. Duplicates can be identified because querying repeated oracle bits carries no additional information. Add a virtual zero row, A=R union {0}, to model the identity branch in the bit oracle. Let

    mu(A) = max_{v != 0} #{ unordered pairs {a,b} in A: a != b, a+b=v }.

The maximum of an empty set is zero. The error guarantee always refers to the random S, and the classical algorithm is allowed arbitrary offline computation from the known quantum circuit and R.

## Theorem I: exact one-query collision-multiplicity simulator

For any one-query quantum algorithm with acceptance probability f(S) in [0,1] and any eps,delta in (0,1), there is a deterministic **nonadaptive** classical estimator g that reads at most

    ceil(4 mu(A) / (delta eps^2))

original query bits and satisfies

    Pr_S[ |f(S)-g(S)| > eps ] <= delta.

If mu=0, f is constant and zero queries suffice.

### Complete author-side proof

A controlled-bit query is diagonal in the X-eigenbasis of its answer register. Every plus sector gets phase 1, and the minus sector for row a gets phase chi_a(S)=(-1)^{<a,S>}. The plus sectors can be grouped into the zero-frequency sector. Thus every one-query circuit, including arbitrary workspace, pre/post unitaries and a final two-outcome POVM, has an expansion

    |psi_S> = sum_{a in A} chi_a(S) |phi_a>,

where the vectors |phi_a> are **mutually orthogonal** before the final measurement; the final unitary preserves this property. Purification handles initial mixed states. Let p_a=||phi_a||^2 and sum p_a=1. With final POVM effect 0<=M<=I, form the real symmetric matrix H with entries

    H_ab = Re <phi_a|M|phi_b>.

It obeys 0<=H<=P=diag(p), because Gram(M) and Gram(I-M) are positive semidefinite and the phi_a are orthogonal. The acceptance probability is

    f(S) = sum_{a,b} H_ab chi_{a+b}(S).

Drop zero-p indices. Set H = sqrt(P) E sqrt(P) with 0<=E<=I, so E^2<=E. For every nonzero Fourier frequency v,

    fhat(v) = 2 sum_{unordered {a,b}:a+b=v} H_ab.

Choose eta=delta eps^2/(4mu) and the heavy set J={a:p_a>=eta}. Then |J|<=1/eta. Query all nonzero a in J and output g=E[f | (chi_a)_{a in J}]. Walsh orthogonality under uniform S gives

    E[(f-g)^2] = sum_{v not in span(J)} fhat(v)^2.

If v is outside span(J), every unordered pair realizing v contains at least one light index. Cauchy-Schwarz, at most mu pairs for each v, and the Gram domination yield

    E[(f-g)^2]
      <= 4mu sum_{unordered {a,b}, at least one light} H_ab^2
      <= 4mu sum_{a light,b} p_a p_b E_ab^2
      <= 4mu eta sum_b p_b sum_a E_ab^2
      <= 4mu eta sum_b p_b E_bb
      <= 4mu eta
       = delta eps^2.

The penultimate inequality is E^2<=E; the last one uses E_bb<=1 and sum_b p_b=1. Markov completes the claimed high-probability approximation. No local frame, low-degree influence inequality, product approximation, or high-wise independence theorem is used. QED.

**Important model distinction:** one classical output g approximates the **acceptance probability** of the quantum circuit on most random codewords. The bound is not a statement about measuring the quantum output once or matching all quantum output distributions simultaneously.

## Corollary I.1: grid graph rows have mu=2

Let G be the L-by-L square grid, L>=2, and R={e_u+e_v:uv edge}. For a nonzero XOR of two nonzero edge rows, either the two edges meet (the XOR is a two-vertex vector, indexed by an unordered length-two path), or the edges are disjoint (a four-vertex vector, indexed by a matching of the induced four-vertex graph).

The grid is bipartite: a direct {0,edge} representation of a two-vertex vector cannot overlap an adjacent-two-edge representation, since endpoints of an edge have no common neighbor. Two vertices have at most 2 common neighbors. Four vertices of a bipartite graph admit at most 2 perfect matchings. Square faces attain multiplicity 2. Thus mu(R union {0})=2 for every L>=2.

Consequently every one-query quantum acceptance probability on random grid-edge parity inputs has a nonadaptive classical approximation reading at most ceil(8/(delta eps^2)) edges, **independent of grid dimensions**. This coexists with the earlier Grid Obstruction G2 lower bound Omega(sqrt L) on exact globally high-girth local frames: expensive frames do not imply quantum advantage.

More generally, if G is bipartite with maximum common-neighbor count lambda over vertex pairs, mu<=max(2,lambda).

## Corollary I.2: tensor subcube rows have mu=L+1

Let R_L consist of all 3^L nonzero pure tensors from (F_2^2 minus {0}) raised to the tensor power L, i.e. the indicator vectors of nonempty axis-aligned subcubes of {0,1}^L. Then mu(R_L union {0})=L+1 for L>=2 (and mu=2 at L=1). Therefore all one-query quantum acceptance probabilities on this correlated input distribution have nonadaptive classical simulation cost

    ceil(4(L+1)/(delta eps^2)),

which is O(log m / (delta eps^2)) for secret dimension m=2^L.

### Exact pair-decomposition classification

Every nonzero local vector in F_2^2 is one of e_0, e_1, or e_0+e_1; any two distinct such vectors are independent.

For two distinct pure tensors U=tensor(u_i), V=tensor(v_i), let D be their differing-coordinate set. If |D|=1, U+V is pure. If |D|>=2, a mode-i flattening has rank two exactly when i is in D, because the two local vectors and the two complementary factors are each independent (another coordinate also differs); outside D the mode rank is one. Thus |D| is intrinsic to the sum.

* Pure tensor frequencies: exactly L unordered nonzero-pair representations, one from splitting at each coordinate (the local third vector is the sum of the other two), plus {0,U} gives multiplicity L+1.
* Mode-rank-two frequencies at exactly two positions: all possible two-term decompositions reduce to an invertible 2-by-2 binary matrix. Each ordered decomposition corresponds to a choice of one of the six ordered invertible local bases, with the opposite local basis forced; quotienting by swapping gives exactly three unordered pairs.
* Mode-rank-two frequencies at three or more positions: fix one varying coordinate and flatten. The complementary factors differ in at least two positions. Their binary two-dimensional span contains **only two** nonzero pure tensors (the sum is not pure by the flattening criterion). Any other two-term decomposition must use exactly those two complementary factors, and its two local factors are then forced. Hence exactly one unordered representation.

Maximum multiplicity is max(L+1,3)=L+1 for L>=2. This establishes the claimed classification, not merely a pattern fitted to finite examples.

**Consequences:** The tensor frame obstruction of Claude's Theorem H/H' is mathematically compatible with a positive **one-query, non-frame** classical simulator. No conclusion has been proved for arbitrary T.

## Corollary I.3: exponential random row sets below square-root density

Let r_1,...,r_n be independent uniform vectors in F_2^m, and take A to be the set of their distinct values plus the virtual zero vector. For every integer k>=2,

    Pr[mu(A)>=k] <= (n+1)^(2k) * 2^(-m(k-1)).

Indeed, representations of a nonzero frequency by **distinct unordered pairs are vertex-disjoint**: any a has only the possible partner a+v. Thus k pair representations require 2k distinct vector values, and hence 2k distinct sample/dummy indices. Each of their k pair XORs is an independent uniform F_2^m vector (the pair involving the dummy zero is a single independent uniform sample). The probability that all k XORs agree is exactly 2^(-m(k-1)). There are at most (n+1)^(2k) ordered candidate pair arrangements. The union bound proves the result, even if original sample duplicates occur (removing duplicates cannot create additional representations).

In particular, for any fixed zeta in (0,1/2), suppose n<=2^((1/2-zeta)m). Choose any fixed integer k>1/(2*zeta). Then

    Pr[mu(A)>=k] <= 2^(-m(2*zeta*k-1)+O(k)),

so with probability tending exponentially to 1 as m grows, mu(A)<=k-1. Theorem I then proves **every one-query quantum acceptance algorithm** on that random linear-code family has classical nonadaptive simulation cost

    O(1/(zeta*delta*eps^2))

independent of m or n, even though n can be exponentially large and the oracle coordinates strongly dependent. This is a **one-query only** positive result; the short-sum/spectral arguments still permit quantum advantage at larger query counts.

The bounded pair-representation property itself is a standard generalized Sidon/B_2[g] notion from additive combinatorics (not a novelty claim). What is being asserted here is its quantitative connection to one-query acceptance-probability simulation. Related classical B_2[g] literature requires a full priority check.

## Negative control: large pair collisions do not imply quantum advantage

Let the secret have independent bits s_0,s_1,...,s_n, and let the rows consist of e_i and e_i+e_0 for i=1,...,n. Then the nonzero frequency e_0 has exactly n representations

    e_0 = e_i + (e_i+e_0),

so mu>=n, and direct counting shows mu=n for n>=2. Yet every oracle coordinate is a function of at most two *independent* secret bits. Every s_i, i>=1, is directly queryable as x_{e_i}, and s_0 can be recovered from any pair x_{e_i},x_{e_i+e_0} using two original queries.

Thus the existing product-space AA simulation plus the exact local-representation transfer simulates **every T-query quantum algorithm** on this family with poly(T,1/eps,1/delta) original queries, independent of n. Specifically a quantum query of x_{e_i+e_0} is compiled into two secret-bit queries (plus uncomputation), followed by the product-input simulator; each simulated secret query costs at most two original row queries.

This is a **proof that the pair-collision criterion is sufficient, not necessary or sufficient-for-advantage in the reverse direction**: high mu can arise from a single shared latent bit that is cheap to identify. Therefore neither mu nor the earlier exact frame cost alone is a two-sided characterization. A successful all-T invariant must account for low-cost latent elimination *and* coherent Fourier collisions. This negative control is tested exactly by the accompanying script.

## General sufficient certificate: Fourier-sector coherence at T queries

This extension is **also author-side**, and is not a complete characterization. A T-query algorithm's final state has the Walsh expansion

    |psi_S> = sum_{a in A_T} chi_a(S) |phi_a>,
    A_T = union_{t=0}^T tR.

This follows inductively: a phase or controlled-bit oracle multiplies a sector by either 1 or chi_r, and between-query gates do not introduce secret dependence. For uniform S, Parseval plus ||psi_S||=1 gives sum_a p_a=1, p_a=||phi_a||^2. But for interleaved quantum queries the phi_a are generally **not orthogonal**.

Define the real Gram G_ab=Re<phi_a|phi_b>, P=diag(p), and

    kappa_T(Q) = lambda_max(P^(-1/2) G P^(-1/2)) >= 1

on the positive support. The acceptance Gram H satisfies 0<=H<=G<=kappa_T P. Repeating the proof with H=kappa_T sqrt(P) E sqrt(P), and querying each heavy frequency a as a sum of at most T original rows, gives a sufficient bound

    D_classical(Q,eps,delta)
        <= ceil(4 T mu(A_T) kappa_T(Q)^2 / (delta eps^2)).

For T=1, mutually orthogonal query sectors imply kappa_1=1. For fully parallel batches of phase queries, the history sectors remain orthogonal so kappa_T=1, although mu(A_T) may still be large. General sequential circuits may have kappa_T>1. **Never set kappa_T=1 for sequential algorithms without justification.**

This identifies two explicit failure modes for this particular simulator: additive pair collisions among query-reachable Fourier sectors, and overlap between different Fourier-sector workspace states. High values are not sufficient for a quantum advantage; even independent rows can have large mu(A_T) for T>=2. The real all-T problem is to replace this worst-case bound with a weighted, adaptive, structure-sensitive operator.

## Prior-art, novelty and reproducibility

**Prior art inspected on 2026-11-19:**
- Bogdanov, Cheung, Dinesh and Lui, Classical Simulation of One-Query Quantum Distinguishers (APPROX/RANDOM 2023), https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.APPROX/RANDOM.2023.43 . Bilinear/PSD representations and generic one-query classical simulation are **known**.
- Optimal inequalities for completely bounded polynomials and limitations of quantum query algorithms (2026), https://www.alphaxiv.org/abs/2609.05201 . General Fourier bounds and parallel-query simulation are relevant established methodology.
- Turturean, A proof of the Aaronson-Ambainis conjecture (2026), https://arxiv.org/abs/2611.09773 . The existing influence theorem is for product/uniform input and is not a frame necessity theorem for these correlated codewords.
No exact prior statement of this pair-sum collision parameter was found in a limited targeted search. That does **not** establish novelty, priority, or external proof validation.

**Finite falsifier:** python3 -I research/nightfall/structural_information/dichotomy_tests/check_pair_sum_onequery.py . This checks every pair collision in tensor levels L=1..6, grid sides L=2..7 and BV dimensions 1..5, nonuniform rational diagonal weights, explicit PSD contraction matrices, 70 exact rational conditional-mean tail inequalities and query-size checks, plus 40 independent exhaustive Walsh/Parseval equalities. Tests cannot prove the universal theorem. CI preserves exact commit, SHA256 source hashes and logs.

**Remaining goal:** characterize arbitrary T. First independent attack on kappa_T and mu(A_T) for T=2 on grid and tensor inputs. If the worst-case unweighted mu(A_T) already explodes for a classically easy input, switch to a posterior/weighted coherence quantity rather than optimizing a failed bound. Do not claim the full quantum-advantage characterization is settled.