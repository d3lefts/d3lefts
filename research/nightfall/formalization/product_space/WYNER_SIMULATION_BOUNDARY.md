# NF-WYNER-SIMULATION-BOUNDARY-01 — v0.1, 2026-11-24

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
