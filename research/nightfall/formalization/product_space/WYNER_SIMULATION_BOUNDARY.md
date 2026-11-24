# NF-WYNER-SIMULATION-BOUNDARY-01 — v0.2, 2026-11-24

Status: paper-level deductions; new Lean source awaiting exact-head compiler and kernel receipt; independent review and novelty clearance pending. No manuscript publication or merge implied.

## Contract

Objective: connect NF-WYNER-LOCALITY-OBSTRUCTION-01 to a computational resource, and test whether the existing Route 1 query upper bound has any converse. Preserve the certified predecessor at commit 17922490919b24491b2e598228b0b055ac615e45, run 45482284099, artifact 14963596391. The new work is stacked separately.

Feasible model: exact local retraction and inverse on the latent support, finite alphabets, coordinatewise product components, nonnegative normalized weights, full projection through t, isolated source support, b*r+1 <= t and r>0. All entropy statements in the prose are in bits; the Lean source uses nats. The query theorem concerns a bounded function of product interaction degree d on the full ambient product domain, not a function bounded only on the correlated support. The table-size lower bound concerns explicit lists of independent-coordinate components, not arbitrary circuits or time.

Best verified predecessor: the general lower bound on actual general-latent Wyner information, with PPZ counting proved and discharged. Remaining gap: exact-head formal receipt for this extension, formal parity sharpness and robust-TV specialization, independent proof review, and a model-specific lower bound beyond explicit representation size.

Prior-art thresholds: a new result must be more than the standard inequality I <= H <= log K or the PPZ coding lemma, and must not restate the known exponential parity-mixture rank lower bound. Compare the robust constant against the literature before claiming improvement. Stop rule for this pass: one complete proof package, exact small-instance falsification check, source-pinned CI and preservation of open obligations. No record or novelty claim.

## A. Exact explicit-mixture obstruction

Let N be the original binary dimension and Z the encoded variable. The predecessor gives

    C_W(Z) >= H(Z) - N + N/r.

For any representation P_Z = sum_{j=1}^K w_j Q_j, with Q_j product distributions, the component index J is an admissible Wyner latent. Thus

    C_W(Z) <= I(Z;J) <= H(J) <= log_2 K.

Combining,

    K >= 2^(H(Z) - N + N/r).

This bounds the number of entries in a nonnegative product-mixture table. A uniform m-bit shared seed selecting such components needs m >= H(Z)-N+N/r. A fixed explicit list needs at least K entries. The bound is vacuous when the exponent is negative (the trivial K>=1 remains). Implicit sampling circuits can be efficient despite exponentially many possible seed values. There is no arbitrary-query lower bound here.

A stronger componentwise observation: the proof of the predecessor bounds the support of *each* product distribution supported on the valid latent support by M=2^(N-N/r). For an exact mixture, w_j <= P_Z(supp Q_j) <= M max_z P_Z(z), hence H_inf(J) >= H_inf(Z)-log_2 M. For a uniform target on V, any mixture supported inside V and within TV delta of uniform(V) has union of positive-weight component supports of size at least (1-delta)|V|, hence K >= (1-delta)|V|/M. This last extension is support-preserving only; do not apply it to arbitrary leaking approximate mixtures.

For a uniform binary linear [N,k] code of minimum distance at least two, dual distance d_perp and b*r<=d_perp-2, H(Z)=k and the bound is K>=2^(k-N+N/r). The full-projection condition follows from dual distance, isolation from minimum distance, and H(Z)=k from the exact inverse. This code corollary is paper-level and not yet separately formalized.

## B. Sharp parity construction for the unrestricted finite-alphabet model

Take X uniform on N-bit even parity, N>=3, partition the original bits into m=ceil(N/r) nonempty blocks of size <=r. Let Z_j be the entire bit string in block j, with padding to a common alphabet if needed. D_j reads its block in at most r queries; E reconstructs each original bit from one latent coordinate (b=1). Require r<=N-2 to meet the predecessor's hypotheses.

The block parities Y_j are uniform over even-parity m-bit strings. Given Y=y, blocks are independent and uniform over their own parity fibres. This supplies a product mixture with exactly 2^(m-1) components and I(Z;Y)=m-1.

Conversely, every product component supported in the valid global parity set must fix the parity of every block. If a block admits both parity values with positive mass, keep the other blocks at positive-mass values; one of the two resulting tuples has odd global parity, contradiction. Thus Y is determined by the component and I(Z;J)>=H(Y)=m-1. The same argument holds almost everywhere for a general latent, since the invalid set is finite and has zero mass.

Consequently the exact Wyner information is m-1 bits and the exact minimum finite product-mixture cardinality is 2^(m-1). When r divides N, this attains the universal lower bound N/r-1 exactly. For other N the gap is <1 bit. It works already at b=1; sharpness is for unrestricted finite alphabets, not a binary-only latent restriction.

Example N=100, r=5: 20 block coordinates, 19 bits of Wyner information, 524,288 exact components. Generating 99 fair bits and computing the final parity bit is nevertheless an O(N)-bit-operation sampler.

## C. Robust parity-mixture lower bound allowing support leakage

Let P be uniform over even parity on m>=1 bits, M=2^(m-1). Let Q=sum_{j=1}^K w_j Q_j be any mixture of Bernoulli product distributions with TV(P,Q)<=delta (standard half-L1 convention). Choose one mode a_j of each Q_j and let A contain these at most K modes. For a product component with Bernoulli parameters p_i,

    Q_j(even)-Q_j(odd) = prod_i (1-2p_i).

If a mode is even, its mass prod_i max(p_i,1-p_i) is at least the absolute parity bias; if a mode is odd, the parity bias is nonpositive (ties give zero). In either case Q_j(even outside A)<=Q_j(odd). Summing over components yields Q(even outside A)<=Q(odd)<=delta. By TV, P(even outside A)<=2delta. Therefore

    K >= (1-2delta) * 2^(m-1), for 0<=delta<1/2.

The inequality is nontrivial for every fixed delta<1/2; at delta=1/2 uniform product has exactly that distance and K=1. The proof allows arbitrary support leakage. It is not a claim of optimality of the constant. Applying coordinatewise block parity to a mixture on the blocks preserves product structure and cannot increase TV, so the same bound applies to approximate mixtures for the construction in B. It does not yet give a robust bound for arbitrary local encoders.

## D. The simulation-converse obstruction (negative transfer)

If a target law nu is pointwise dominated by M times a reference law mu, then for any nonnegative loss g,

    E_nu[g] <= M E_mu[g].

The existing certified product-law simulation theorem (ProductSimulation.lean, simulation_degree) gives a deterministic tree with at most O(d^6 epsilon^-3 delta^-5/2) queries, for bounded functions of interaction degree d, at error epsilon and failure probability delta on a product law.

Choose a product reference with nu<=M mu and run that theorem at delta/M. The very same tree on nu has failure probability at most delta, and the query upper bound increases by M^(5/2). A reference mixture can similarly use Route 1 with its own Wyner information, not the target's Wyner information. This motivates optimizing over dominating reference laws, not only over exact representations.

In particular, the uniform even-parity law on N bits has exact Wyner information N-1 (identity representation) and exact minimum mixture size 2^(N-1). But it is pointwise at most twice the uniform product law. Every globally bounded degree-d function therefore has the same dimension-free polynomial query bound up to a constant 2^(5/2), for fixed d, epsilon, delta. This explicitly falsifies a universal query-complexity lower bound growing with target C_W at fixed parameters. The lower bound on representation size survives; query complexity need not follow it.

For any uniform binary linear code of codimension c, the uniform product law dominates with factor 2^c. This gives a second upper-bound route for small-codimension correlated sources. It is not useful when c is large unless another reference is found.

## E. Independent attack plan and executed checks

Prediction before the finite check: each product component satisfies the off-mode even mass <= odd mass inequality; finite mixtures satisfy the robust cardinality bound; parity block fibres have equal size. Alternatives: modes tied, product parameters 0/1, odd modes, small m, overlapping modes, arbitrary component weights, partial final block. The test directly enumerates atom masses as integers, without implementing the parity-bias formula.

Command from this directory:

    python3 check_wyner_simulation_boundary.py

Observed: PASS: 3905 exact product components; 2600 exact rational mixtures; 55 parity block partitions.

Component grid p_i in {0,1/4,1/2,3/4,1}, dimensions 1..5; seeded mixture sample 20261124; partitions up to N=12. Source SHA-256 42a39130f1ca30588790efc477fabfedfc3d3c70f3019eaef9357002b2e96cee. Tests use integer arithmetic, not tolerance. This is a separately implemented falsification path, not independent human review and not a theorem proof. The parity constant must receive an independent proof audit and a Lean gate in a subsequent revision.

New formal source WynerLocalitySimulationBoundary.lean imports the existing certified terminal theorem. It proves the finite-mixture/cardinality transfer and dominated-product simulation, not the entire prose package. Strict bridge plus leanchecker is wired into CI. No promotion until exact-head success.

## F. Prior art, checked 2026-11-24

- Paturi, Pudlak, Zane, Satisfiability Coding Lemma (1997/1999), https://scholar.lib.vt.edu/ejournals/CJTCS/cjtcs-mirror/articles/1999/11/contents.html — established counting engine; not claimed novel.
- Montufar, Mixture decompositions of exponential families using a decomposition of their sample spaces (2013), https://www.kybernetika.cz/content/2013/1/23 — exact product-mixture worst-case cardinality already known.
- Montufar and Morton, When Does a Mixture of Products Contain a Product of Mixtures?, https://arxiv.org/abs/1206.0387 — product-mixture exponential expressivity separation and modes.
- Ahmed, Fan, Venkateswara, Patterson, Latent-Kernel Discrete Flow Maps for Few-Step Generation, https://arxiv.org/abs/2607.27529 — close recent prior art on approximate parity mixtures. Indexed text indicates an exponential bound for TV below 1/3; full primary theorem text could not be retrieved in this session. Do not claim improvement or novelty until its exact statement and related work are checked.
- Information-theoretic approximations of the nonnegative rank, https://eccc.weizmann.ac.il/report/2013/158/ — known Wyner/rank connection.
- NIGHTFALL ProductSimulation.lean, Route1WynerGeneral.lean, WynerLocalityInformation.lean — exact source dependencies at predecessor commit. Their Lean success does not establish publication priority.

## G. Discovery graph and next experiment

Local retraction -> full projection -> rectangle preimage -> isolated PPZ cap -> component entropy / support cap -> explicit mixture size -> shared seed size. Verified predecessor; new links A and D awaiting compiler receipt.

Parity -> block parity pushforward -> sharp construction -> robust-TV rank. Paper-level proof, exact small cases replayed, independent review outstanding.

Target law -> dominating reference -> loss transfer -> query upper bound. This is a proposed transfer operator to correlated code and quantum-query input laws; it exposes the invalid converse rather than inventing one.

Next cheapest decisive experiment: formalize the off-mode inequality using the parity expectation product identity and TV events; then compare with the complete 2607.27529 theorem. Search for a family where low-density-ratio reference laws also fail; only then pursue a true query lower bound with an explicit task and model. A high Wyner lower bound alone cannot suffice.


## H. v0.2 structural generalization: isolated supports and block-syndrome quotient

Status: paper-level proof, independent algorithmic falsification checks passed; no Lean or non-author proof receipt for this section.

### H1. Mode-anchored rectangles

Let A_i be finite alphabets, V a subset of their product with Hamming minimum distance >=2 (no two distinct points differ in exactly one coordinate), and P any probability law supported on V. Let Q=sum_{j=1}^K w_j Q_j be a mixture of arbitrary coordinate-product laws, TV(P,Q)<=delta. Choose a coordinatewise mode a_j of each product law, and put A={a_1,...,a_K}.

For a single marginal sorted p_1>=...>=p_q>=0, with p_(q+1)=0, define lambda_l=l(p_l-p_(l+1)). The weights are nonnegative, sum to one by telescoping, and the marginal is their mixture of uniform distributions on the first l symbols: the mass of symbol s is sum_{l>=s} lambda_l/l=p_s. Every prefix contains the chosen marginal mode, including in ties.

Taking products yields a mixture of uniform rectangles, every one containing the chosen joint mode a. In any nonsingleton rectangle, fix all coordinates except one with >=2 allowed values. The isolation hypothesis permits at most one V-point in each such fiber; hence uniform-rectangle mass of V is <=1/2. In the singleton rectangle {a}, V outside {a} has zero mass. Averaging these inequalities gives

    Q_j(V minus {a_j}) <= Q_j(V complement).

This immediately implies Q(V minus A)<=Q(V complement)<=delta and P(V minus A)<=2delta, by the TV event inequalities. In particular,

    P(A)>=1-2delta,
    K >= (1-2delta)/max_x P(x).

Equivalently, the sum of the K largest target atom probabilities must be at least 1-2delta. If P is uniform on V, K>=(1-2delta)|V|. This subsumes C, removes binary/parity/linearity assumptions, and tolerates arbitrary leakage. For the general isolated-support class the factor 2 is asymptotically necessary: an unbiased product law on a binary cube has TV=1/2 from uniform parity and K=1. For any fixed finite V, optimal constants may be stronger.

This stronger representation mechanism is a positive mixture of mode-anchored rectangles, not an approximate PPZ proof. It applies to isolated latent supports, or to an isolated coordinatewise quotient of the latent support; it does not automatically apply to arbitrary encoders in the original theorem.

### H2. Exact block-syndrome formula for binary linear codes

Let X be uniform on C=ker H, with H a binary parity-check matrix (not necessarily full row rank). Partition original coordinates into nonempty blocks B_j, and set Z_j=X restricted to B_j. Let H_j be the block-column restriction, W_j=image H_j, h_j=rank H_j, h=rank H. Let Y_j=H_j Z_j.

The syndrome tuple Y is uniform over

    V={(y_1,...,y_m) in product W_j : sum_j y_j=0}.

Indeed, the map product W_j -> image H given by summing is surjective, with kernel dimension s=sum_j h_j-h. Each y in V has exactly product_j 2^(|B_j|-h_j) preimages in C. Given Y, the blocks Z_j are independent and uniform on their local affine solution fibers. Also V is isolated in the categorical Hamming metric: changing exactly one syndrome while holding the others fixed breaks the sum-zero condition.

Every positive-weight exact product component of Z must have its coordinatewise syndrome pushforward supported in V. An isolated set cannot contain a nonsingleton rectangle, so each component fixes the syndrome tuple. It follows that

    C_W(Z) = s bits,
    minimum exact product-mixture size = 2^s,
    K_approx(delta) >= (1-2delta) 2^s   (delta<1/2).

The upper bound for the exact quantities is the explicit uniform mixture conditioned on Y; the lower bound on general-latent Wyner follows from I(Z;J)>=I(Y;J)=H(Y)=s (invalid tuples have zero integrated mass, hence zero component mass almost everywhere). Approximate TV contracts under the blockwise syndrome map and each product component remains product, so H1 gives the robust result.

This is a computable rank formula for every fixed block partition. It does not require the full-projection hypothesis of the general adaptive local-retraction theorem, but applies only to literal block grouping. If each block has size <=r and r<d_min(C), each H_j has full column rank, so s=N-h=k: no Wyner reduction at all despite bundling r bits. If d_min>=2, every nonempty H_j has rank>=1, so s>=m-h, recovering and sometimes improving the general locality bound for this restricted representation. For a single parity-check row, s=m-1 as in B.

Optimization problem: minimize sum_j rank(H_j) over partitions with |B_j|<=r; the global rank h is fixed. This is a concrete matroid partition objective for seeking compressible block representations, and the resulting optimum has both exact and robust mixture interpretations. The original adaptive theorem remains the broader lower bound.

### H3. Exact falsification receipt and prior-art correction

Executed an independently coded finite search before archiving this section:
    
    python3 check_wyner_isolated_support.py

PASS: 198233 exact isolated-set/product-law pairs; 720 GF(2) syndrome partitions.

The first test enumerates every isolated set and directly sums integer atom masses for binary dimensions up to 4 and ternary dimensions up to 2, with normalized rational marginals of denominators 3 or 4. It does not use the rectangle decomposition. The second directly enumerates binary kernel words for 720 seeded random matrices with 1..9 columns, compares syndrome-fiber counts with independent XOR elimination, and attacks isolation. Checker SHA-256 df66af2b90f77c7dbbcafbafd9339ee5f047b27f357af868bec1efd9adb338e2. These tests are not proof or independent human review.

Additional indexed source retrieval clarified Ahmed et al. (2026), arXiv:2607.27529, Theorem 2 and Appendix D.5: their stated lower bound is (1-3delta)2^(m-1) for delta<1/3. The mode/parity-bias estimate is shared prior art. Our C and H1 paper-level proof uses the tighter off-mode-inside-versus-outside inequality to avoid losing another delta, obtaining (1-2delta)2^(m-1) for delta<1/2, and H1 extends to arbitrary isolated finite categorical support. Primary HTML/PDF remained inaccessible directly; the precise statement and proof excerpt were retrieved through indexed full-text mirrors (ResearchGate publication 411032646 and bittide article b66ca2da-3476-4a9e-83ef-cf7c24fa537e). This is a specific candidate improvement against that statement, not established priority or novelty; compare other mode/mixture literature and obtain non-author review before promotion. Montufar and Morton arXiv:1206.0387, strong-mode results, are a particularly relevant additional dependency for novelty audit.

Next formalization: prove the nested-prefix uniform mixture identity, the rectangle-fiber bound, and the event transfer in Lean; derive the syndrome formula using finite linear map cardinalities. Preserve the scope of the existing certified theorem while the new formal work is pending.

### H4. Custody separation

The new stacked PR #1195 does not change the predecessor source commit or its successful kernel receipt. On the first stacked run, the repository-wide frozen pending-custody checks rejected the old PPZ/information blob hashes left in the predecessor branch. This is an integrity-ledger mismatch, not a disproof of the successful exact-head named/kernel receipt. Reconcile only the mutable pending-source custody entries on the stacked branch; keep the frozen 67-record registry unchanged and do not promote any off-main source to a main-branch certified record. Prior pending hashes remain archived here: PPZ 40c40ce49306570e615ae1435be382e9f1ff44ec; information ee2a51ca168e731eb364d862e2dfbc097238bc9e. The exact-head proof receipt identifies their replacements.
