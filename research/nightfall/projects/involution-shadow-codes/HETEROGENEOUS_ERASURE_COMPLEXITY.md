# NIGHTFALL — Heterogeneous erasure reliability: an exact optimization and complexity transition

**Research lead:** Devin J. Wright. **Independent extension:** October 28, 2026.

**Classification:** New theorem-level extension within NIGHTFALL's nonabelian involution-shadow framework. The distribution-free ambiguity identity, universal optimality under correlated exchangeable erasures, restricted NP-completeness reduction, and exact two-class Pareto dynamic program are proved below. Finite checks provide independently implemented corroboration. No worldwide novelty claim; related heterogeneous replication/allocation hardness is documented in earlier literature.

**Prior-art correction (28 October 2026):** The optimization \(\sum_c e^{W_c}\) is a special case of the convex **Workload Partition Problem** studied at least by Shabtay–Kaspi (2006) and Oron–Shabtay–Steiner (2017). Heterogeneous replication reliability, a balancing argument, and a 3-PARTITION hardness reduction appear in Benoit–Marchal–Robert–Sinnen (2010). The two-bin dynamic program is standard cardinality/subset-sum methodology. This paper's defensible current contribution is the **specific translated-involution code application**, exact code-dependent formulas, and joint distance–reliability packaging; priority for even that particular combination remains unverified. See [prior-art assessment](PRIOR_ART_ASSESSMENT_20261028.md).\n\n## 1. Model and the exact reliability law

Let G be a finite group with a nonidentity involutive automorphism S, H=Fix(S), q=[G:H] >=2. Use the orbit code C_T(x)=([x t_1]_S,...,[x t_m]_S), with labels δ(t)=S(t)t^{-1}. The existing NIGHTFALL theorem establishes that a set of retained observations distinguishes **all** messages precisely when it contains at least two distinct labels. This result is independent of whether G is abelian.

Suppose coordinate j independently survives with probability p_j in (0,1). Write r_j=1-p_j, R=product_j r_j. Assign each coordinate j to one of the q labels, with class I_c. Define the log-failure workload w_j=-log(r_j)>0 and W_c=sum_{j in I_c} w_j, W=sum_j w_j.

**Theorem A (exact heterogeneous erasure law).** The probability that the restricted code fails to distinguish all messages is

    P_fail = sum_c product_{j outside I_c} r_j - (q-1) product_j r_j
           = R * (sum_c exp(W_c) - q + 1).

**Proof.** For each label c, let E_c be the event that every surviving coordinate belongs to class c. Its probability equals the product of the erasure probabilities outside that class. For c≠d, E_c∩E_d is the event that every coordinate is erased, of probability R. The union of all E_c is precisely the ambiguous-recovery event; correcting the q-fold count of the all-erased event gives the formula. Equivalently, dividing each term by R yields exp(W_c). The formula includes empty label classes, arbitrary finite groups, and zero surviving coordinates. QED.

**Implication:** The optimal assignment minimizes the convex exponential load-balancing objective sum_c exp(W_c). The log-failure weights—not the number of sensors in each class—govern reliability. Jensen's inequality gives the universal unattainable-in-general bound

    P_fail >= R * (q exp(W/q) - q + 1),

with equality precisely when every class has the same total log-failure weight W/q. Equal survival probabilities recover the original balanced-cardinality theorem.

## 1b. Distribution-free identity and universal correlated-erasure optimality

**Theorem A′ (arbitrary correlated erasure distributions).** Let J be any random subset of surviving coordinates, with **no independence assumption**. Then

    Pr(ambiguous) = sum_c Pr(J is a subset of I_c) - (q-1) Pr(J is empty).

This is a distribution-free inclusion-exclusion identity: all pairwise intersections of the events {J is a subset of I_c} are exactly {J is empty}, giving the displayed correction term. Theorem A follows when each erasure decision is independent.

**Theorem A″ (exchangeable correlated-erasure optimality).** Suppose the joint distribution of J is invariant under all permutations of measurement coordinates. Let α_r=Pr(|J|=r). Conditional on |J|=r, every r-element coordinate subset is equally likely, even though erasures can be arbitrarily correlated. The exact failure law is

    Pr(ambiguous) = α_0 + sum_{r=1}^m α_r * [sum_c binom(n_c,r)]/binom(m,r).

For all such correlated exchangeable erasure distributions, a balanced cardinality assignment n_c in {floor(m/q),ceil(m/q)} is simultaneously optimal. The proof uses the elementary binomial transfer inequality: moving one item from a class of size u to one of size v when u>=v+2 weakly decreases binom(u,r)+binom(v,r) for every r>=1. This applies for every nonnegative mixture α_r, so independence of failures is unnecessary. The same allocation also maximizes adversarial Hamming distance. QED.

**Sharp boundary:** Exchangeable erasures (potentially correlated) retain the original universal balance theorem; unequal independent erasure rates already lead to the more difficult weighted problem of Theorem B.

An exact independent audit constructs a correlated, exchangeable law on six coordinates, with size-distribution α=(1,2,5,3,5,2,2)/20. Direct orbit-code enumeration gives balanced failure 1/5. Every one of the 729 assignments to three labels was checked; exactly 90 balanced assignments tie for optimality.

## 2. Exact incompatibility of equal-count distance and unequal-reliability resilience

Let G=Z_4, S(x)=-x and q=2. Use four observations with survival probabilities (7/8,1/2,1/2,1/2), hence dyadic log-failure weights a=(3,1,1,1).

* A 2+2 cardinality-balanced assignment has workloads (4,2), minimum message distance 2, and exact failure probability (2^4+2^2-1)/2^6 = **19/64**.
* A 1+3 allocation separating the high-reliability coordinate from the other three has workloads (3,3), minimum message distance 1, and failure probability (2^3+2^3-1)/2^6 = **15/64**.

Thus the design maximizing guaranteed adversarial error tolerance has strictly worse random-erasure recovery probability than another design. Both probabilities have been independently reproduced by exhaustive enumeration of the actual four-element group's orbit-code words and all 16 survival masks. The two criteria create a genuine Pareto tradeoff.

## 3. Restricted NP-completeness, already on cyclic groups

**Theorem B (NP-completeness of heterogeneous allocation).** Given q>=2, m, rational survival probabilities p_j in (0,1), and rational threshold τ, deciding whether labels can be assigned such that P_fail<=τ is NP-complete. Hardness persists for **G=Z_(2q)** with S(x)=-x, and **p_j=1-2^(-a_j)** for positive integers a_j that have polynomial size in the underlying restricted reduction.

**Proof.** Membership in NP follows by giving a label assignment and evaluating the products of input rational numbers exactly; their output bit lengths grow at most additively.

Reduce from strongly NP-complete 3-PARTITION: there are 3q positive integers a_j satisfying B/4<a_j<B/2 and sum_j a_j=qB. Define G=Z_(2q), S(x)=-x. The fixed subgroup consists of {0,q}, so δ(t)=-2t ranges over exactly q labels. Let observation j survive with p_j=1-2^(-a_j). Its erasure probability is 2^(-a_j), and every assignment to q labels is realizable by choosing appropriate t_j.

Let A_c be the sum of a_j assigned to label c. Theorem A becomes

    P_fail = (sum_c 2^(A_c) - q + 1) / 2^(qB).

Choose the rational decision threshold

    τ = (q 2^B - q + 1) / 2^(qB).

By strict convexity, sum_c 2^(A_c) >= q 2^B, with equality if and only if all A_c=B. The bounds B/4<a_j<B/2 imply that each such bin then contains exactly three integers. Hence P_fail<=τ precisely when the original 3-PARTITION instance is feasible. As strongly NP-complete restricted instances can take B polynomially bounded in the number of integers, writing each probability 1-2^(-a_j) and τ in binary requires polynomially many bits. The group G has order 2q; even an explicit Cayley table is polynomial in the source instance size. This is a polynomial-time reduction. QED.

**Scope:** This is a formal reduction to the established 3-PARTITION hardness theorem. It says that *variable-q* optimal heterogeneous allocation is NP-complete, even for elementary cyclic group observations. It neither implies P≠NP nor claims novelty for exponential-load partitioning itself.

## 4. Exact Pareto frontier for q=2

**Theorem C (pseudo-polynomial exact Pareto algorithm).** Suppose the erasure probabilities are dyadic 1-2^(-a_j), with positive integer a_j, and q=2. Let W=sum a_j. For each integer cardinality k, build the subset-sum reachable state table (k,s): can k observations have total log-weight s? Its time complexity is O(m²W), with O(mW) state-space memory using predecessor pointers.

For any state (k,s), the allocation's distance and failure probability are exactly

    d = min(k,m-k),
    P_fail = (2^s + 2^(W-s) - 1)/2^W.

For each d, minimize the above expression over all reachable states with min(k,m-k)=d. The resulting table is the **exact optimal random-erasure failure at every attainable worst-case Hamming distance**; deleting dominated pairs gives the full Pareto frontier.

**Proof.** Every assignment to two labels corresponds bijectively to a subset of observations assigned to label 0. Its subset size and weight sum are (k,s), and its complement has (m-k,W-s). The DP enumerates all reachable (k,s), and the displayed two objective functions depend solely on those statistics. Minimizing over each exact distance is exhaustive. QED.

The unconstrained minimum is reached by a reachable subset sum nearest W/2. Consequently the q=2 case has a pseudo-polynomial exact algorithm, while variable q is NP-complete by Theorem B.

## 5. Machine audit and falsification scope

The self-contained `verify_heterogeneous.py` uses independent *direct orbit-word comparison* over Z_(2q), not the algebraic label-characterization, to decide whether a surviving coordinate set preserves injectivity. It then sums all survival-mask probabilities as exact `Fraction` objects and compares them with the separate closed-form formula.

Frozen audit coverage (verified October 28):

- 252 seeded, independently drawn direct group-orbit reliability comparisons, q in {2,3,4}, lengths 1–7, strictly positive integer dyadic weights.
- One exchangeable, **correlated** six-coordinate erasure law tested by direct group-orbit enumeration, followed by exhaustive comparison of all **729** allocations (90 optimal ties).
- 90 random independent q=2 subset-sum DP versus full brute-allocation optimum comparisons.
- 120 random q=2 **entire Pareto frontier** DP comparisons against brute enumeration of every allocation.
- 2 adversarial 3-PARTITION fixtures with B=18: a feasible vector (5,6,7,5,6,7) attains τ=524287/68719476736 exactly; an infeasible vector (5,5,5,7,7,7) has minimum 655359/68719476736>τ. Each fixture's complete 2^6 allocation space is enumerated.
- A q=2, m=4 example checks the 19/64 versus 15/64 Pareto conflict using all sixteen direct group-orbit erasure patterns.

All tests passed in a standard Python runtime, with no floating point, no external library, and no SMT/optimization dependency. These are computational checks of finite instances. The universal propositions are established in the above self-contained arguments, pending a separate proof-assistant formalization and independent mathematical priority assessment.

## 6. Relationship to prior art

This extends NIGHTFALL's 2026-10-28 universal finite-group shadow-code theorem from identical to coordinate-dependent erasure probabilities. Convex load balancing and NP-hardness of heterogeneous reliability placement have substantial prior art. A previous replication/pipeline reliability analysis reduced a heterogeneous failure allocation problem from 3-PARTITION; the current contribution's asserted scope is the explicit identification, exact formula and full distance-reliability Pareto frontier **for translated involution-orbit group codes**, not a claim that weighted partitioning complexity itself is new.

Prior foundations:

- NIGHTFALL, `NONABELIAN_SHADOW_THEOREM.md` (2026-10-28).
- Garey and Johnson, 3-PARTITION (strongly NP-complete; see https://hardness.mit.edu/drafts/2026-02-16.pdf, Chapter 5).
- Heterogeneous-failure replication / pipeline placement hardness (see https://citeseerx.ist.psu.edu/document?doi=691964200df4b739e8eb608182723a99ef70845b&repid=rep1&type=pdf).
