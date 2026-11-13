# Tree-convex and almost-tree safety evidence: exact margins, cost, and versioned certificates

**NIGHTFALL mathematical note | 13 November 2026 | Direction: Devin J. Wright | AI-assisted technical development**

**Status: author-side analytic derivation plus independent finite enumeration.** This is *not* an externally refereed novelty claim, a Lean-certified theorem, or a deployed safety mechanism. It extends the earlier [Agent Safety Under Abstraction](../agent-safety-under-abstraction/README.md) and [Proof After Scarcity](../pas/PAS_V2_20261029.md) work. An explicit tree representation, sound component-impact declarations, authenticated version manifests, and trusted evidence semantics are **inputs**, not outputs, of these results.

## Discovery objective and scope

The question is how much trusted evidence and per-version checking work is needed to maintain a safety margin after components change. The preceding binary change-stability note reduced evidence survival to hypergraph hitting; a later quantitative note handled *mutually exclusive* update groups. The present contribution is the exact transition to **overlapping connected dependencies**, then to dependencies with a bounded exceptional component set.

Evidence row i has: safety lower bound b_i, maximal certified post-change weakening delta_i >= 0, nonempty dependency support D_i, evidence-acquisition/authentication cost e_i >= 0, and per-version leaf-check cost t_i >= 0. A changed component set U makes its transported lower bound a_i(U) = b_i - delta_i if U intersects D_i, otherwise b_i. At most k components change. This *rectangular-envelope model* is exact relative to permitted abstract update scenarios and may be conservative for physically coupled changes. No inference is made from file hashes alone.

For selected evidence I, define the worst certified margin:

    R_k(I) = min_{U subset V, |U| <= k} max_{i in I} a_i(U).

This is a **certified lower bound**, not the unknown system's true physical safety margin. Improvement of a safety decision is justified only if R_k(I) >= a separately specified threshold gamma and the hazard envelope and decision rule are sound.

## Theorem A: exact margin for connected subtree dependencies

Assume the component graph is a supplied finite tree T, and each D_i induces a nonempty connected subtree. Define

    S(I) = max_{i in I} (b_i - delta_i).

    Q_{k+1}(I) = max over pairwise vertex-disjoint D_{i_1},...,D_{i_{k+1}}
                 of min(b_{i_1},...,b_{i_{k+1}}).

Set Q = -infinity if no such collection exists. Then the **exact** robustness margin in the declared envelope is

    R_k(I) = max( S(I), Q_{k+1}(I) ).

**Proof.** For any real threshold z <= S, an item with b_i-delta_i >= z survives every update. For z > S, every baseline-eligible item b_i >= z is fragile: to make *all* evidence fall below z an adversary must hit the supports of *all* baseline-eligible items. For a family of explicitly represented connected subtrees of a tree, minimum cardinality of a vertex-hitting set equals maximum cardinality of a pairwise vertex-disjoint subfamily (proved in the next paragraph). Hence no update of size k can kill all eligible items iff k+1 disjoint eligible supports exist. This is exactly z <= Q_{k+1}; threshold equivalence for every z proves the identity.

**Subtree hitting/packing lemma (classical graph-theoretic substance).** Root T. Among remaining subtrees select one whose highest/root-nearest node is as deep as possible, record that node as a hitting point, and remove every subtree containing the node. Any subtree intersecting the selected subtree contains the recorded node: their root-nearest vertices lie on one ancestor chain above their intersection, and deepest-first makes the selected vertex the lower one. Thus selected subtrees are pairwise disjoint, while recorded nodes hit every subtree. Any hitting set needs at least as many nodes as a disjoint packing, so both constructions are optimal.

This subtree result is not being claimed as invented here; see Gavril (1974), chordal intersection graphs of subtrees, and van den Heuvel & Johnson (2004), subtree hypergraph transversals. **Explicitly supplying the host tree and finite supports is essential**; published work on more general/implicit subtree hypergraphs has different input complexity.

## Theorem B: exact minimum evidence cost and check-budget frontier

Let q be the maximum admissible *one-leaf* trusted verification cost after a version change; acquiring/authenticating an item is charged separately by e_i. Define

    d(gamma,q) = min{e_i : b_i-delta_i >= gamma and t_i <= q}.

    p_{k+1}(gamma,q) = min{sum_{i in J} e_i :
          |J|=k+1, all D_i in J pairwise disjoint,
          b_i >= gamma and t_i <= q}.

An infeasible minimum is +infinity. Then

    E_k(gamma,q) = min(d(gamma,q), p_{k+1}(gamma,q)).

**Proof.** Theorem A says that any robust collection either contains a durable item or contains k+1 baseline-adequate items on disjoint supports. Dropping all other evidence does not worsen validity or increase nonnegative cost. Conversely, each of these two forms survives any k changes. Minimizing within both forms is thus necessary and sufficient.

**Exact polynomial-time construction.** Root the host tree. For each node v and each upstream already-selected subtree a containing v (or no such subtree), record minimum new evidence cost for selecting exactly j subtrees whose highest nodes occur below v. If a is present, no subtree may start at v; propagate a to a child precisely when the child's vertex lies in a. Otherwise select no new subtree at v or select exactly one whose highest node is v, charging its evidence cost. Combine independent children by min-plus convolution of their cardinality arrays. Every feasible disjoint packing has exactly one such decomposition, so induction on subtree height proves the recurrence exact. The total number of node/active/cardinality states and transitions is polynomial in |V|, m and k. For a given gamma,q this computes p_{k+1}, retaining an optimal set of evidence-row IDs.

The selected certificate contains at most k+1 evidence items, sharply so (k+1 distinct singleton supports with all rows fragile). The *offline optimizer* and the *per-version leaf verifier* have different costs; this theorem does **not** claim that provenance authentication, the initial item audits, or manifest verification are free.

## Theorem C: a complete certificate with a bounded non-tree exception set

Let V=C disjoint-union E. A supplied tree has vertex set C; |E|=s exceptional components. For every evidence dependency D_i, the residual D_i intersect C is either empty or a connected subtree of the supplied tree. Dependencies may overlap arbitrarily on E.

For each A subset E let F_A be the family of **residual supports** D_i intersect C for rows with D_i intersect A empty. Keep empty residual supports. Define tau(F_A) as the minimum number of C-nodes hitting all rows; tau(empty family)=0 and tau(family containing an empty set)=infinity. Then

    tau({D_i}) = min_{A subset E} ( |A| + tau(F_A) ).

This gives an exact O(2^s poly(|V|,m)) computation of the minimum number of component changes required to invalidate all rows.

**Proof.** Every adversarial hitting set U partitions uniquely into A=U intersect E and U intersect C. The latter must hit exactly the rows not already hit by A; minimizing over A proves the equation. Every nonempty residual support is a subtree, so its hitting number equals its disjoint packing number and is computable by the preceding greedy lemma. An empty residual row that A has not hit cannot be hit by C and forces tau=infinity.

Consequently **resilience to every <= k-component change** admits a branch certificate: for every A subset E with |A|<=k, supply either
1. one not-yet-hit evidence row with empty residual support, or
2. k-|A|+1 rows not hit by A, with pairwise disjoint nonempty residual subtrees.

A checker verifies these elementary claims, the tree representation, and the complete list of A branches in O(2^s poly(|V|,m,k)). Conversely, if a branch fails, its greedy residual hitting set combined with A is an explicit destructive update touching at most k components. This is a *complete* acceptance/rejection certificate for the stated finite model.

**Strict extension beyond global packing.** Let C={0,1} be a tree edge, E={2}, and supports D_1={0,2}, D_2={1,2}, D_3={0,1}. Every two full supports intersect, so global pairwise-disjoint packing has size one. Nevertheless, a single update cannot invalidate all three: when A=empty, residual rows {0} and {1} are disjoint; when A={2}, row D_3 still survives. A branch certificate verifies k=1 resilience where a naive two-disjoint-full-support certificate fails.

## Sharp tractability limits

- For multiple hazards, the same check applies separately to evidence excluding each hazard. Minimum *shared* evidence acquisition remains NP-hard already for k=0: weighted Set Cover embeds directly by letting each evidence row exclude a subset of hazards and assigning every dependency the same singleton tree node. Thus efficient certificate checking does not imply efficient joint evidence selection.
- Arbitrary disconnected supports defeat the subtree packing identity: for supports {0,1}, {1,2}, {0,2} on a three-node path, the minimum hitting size is 2 but maximum disjoint packing is 1. Tree-convexity (or the separately proved exceptional decomposition) cannot be silently omitted.
- The near-tree algorithm is parameterized by **a supplied exception set E**; discovering the smallest such set is a separate problem and is not claimed to be easy.
- A system update outside the declared component universe, correlated deterioration exceeding delta_i, forged or incomplete manifests, or missing hazards invalidates the operational inference.

## Empirical reproducibility, 13 November 2026

Two separately implemented exact rational paths compared algorithmic predictions with exhaustive enumeration over all small component-update sets and all candidate evidence subsets:

- 5,000 generated tree instances: exact worst-case margins match brute update enumeration.
- 5,000 instances: greedy subtree packings and hitting numbers match exhaustive optimal values.
- 4,518 instances: dynamic-programming acquisition optima match all-subset enumeration.
- 69,557 direct post-update certificate checks pass.
- 7,500 nearly-tree instances with up to 3 exceptional components: branch resilience exactly matches exhaustive component-update enumeration and every emitted branch proof passes its separate checker; 4,557 cases correctly return destructive updates.

These checks are finite falsification tests, not proof of mathematical priority, end-to-end Lean compilation, real-world guard efficacy, or independence from the author.

## Prior-art boundary (checked November 13, 2026)

- Gavril, “The intersection graphs of subtrees in trees are exactly the chordal graphs,” *JCT B* 16 (1974): https://doi.org/10.1016/0095-8956(74)90094-X
- van den Heuvel and Johnson, “Transversals of Subtree Hypergraphs and the Source Location Problem in Digraphs,” CDAM-2004-10 (2004): https://matthewjohnsondurham.github.io/papers/cdam-2004-10.pdf
- Bertsimas and Sim, “The Price of Robustness,” *Operations Research* 52 (2004).
- Chassein et al., “Faster algorithms for min-max-min robustness for combinatorial problems with budgeted uncertainty,” *EJOR* 279 (2019): https://doi.org/10.1016/j.ejor.2019.05.045
- Abboud et al., “Dynamic Set Cover: Improved Algorithms and Lower Bounds,” STOC 2019: https://doi.org/10.1145/3313276.3316376
- Braverman et al., “Dynamic Set Cover with Worst-Case Recourse,” ICALP 2026: https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ICALP.2026.153
- Dynamic/incremental proof-carrying code and assurance cases are antecedents for certificate revalidation; the provided signed change manifest remains an *assumption*.

**Novelty boundary:** The combination of thresholded safety margins, exact cost and per-version verification budgets, explicit tree supports, and branch certificates for a bounded exception set is an author-derived result *in this research programme*. The individual tree-packing and robust-optimization ingredients are classical; a broader external subsumption search and non-author review are needed before a worldwide originality or publication claim.

## Next decisive tests

1. Translate a concrete AgentDojo or software-assurance guard's authenticated dependencies into an independently audited host tree / exception set. Falsify the hypothesis that small s occurs in practice.
2. Compare certified policy yield and measured verification work against full revalidation, dynamic set cover, and incremental proof-carrying code on the **same input and trusted checker**.
3. Attempt a more expressive theorem where weakening accumulates over several changed dependency components; current binary delta_i is not compositional across arbitrary repeated changes.
4. Preserve the exact dated branch, commit, test manifest, failure modes, and changes in status. No automatic promotion to a new theorem of general AI safety.
