# NIGHTFALL — An exact SAT-to-network compression transfer

27 October 2026. Independently checked algebraic reduction, quantitative mode-count lemma, and published-theorem-based contraction bound. This is a **derived corollary**, not a claim of an original subexponential SAT algorithm or original interpolation method.

## 1. Statement and provenance

For a 3-CNF F on n declared variables with m non-tautological, nonempty clauses, a polynomial-time algorithm constructs a bipartite Boolean tensor network G(F) of maximum degree 3 with

    s = 3L - 2v <= 9m,

where L is the total number of literal occurrences after deleting duplicates and tautological clauses, and v is the number of variables with at least one occurrence. Every local tensor has values 0 or 1 and a constant-time evaluation procedure. Writing Z(G) for its Boolean contraction,

    #SAT(F) = 2^(n-v) Z(G(F)).

Assuming Theorem D.1 of OpenAI's publicly released October 25, 2026 paper *The Exponential Time Hypothesis is False*, this gives a deterministic exact counting algorithm using polynomial space and

    poly(n+m) * 2^{O(s/sqrt(log_2(s+2)))}
      <= poly(n+m) * 2^{O(m/sqrt(log_2(m+2)))}

bit operations for m >= 1, with fixed universal constants in the O for this 3-CNF representation. The paper's separately formalized Lean comparator supports the weaker but still subexponential n-based bound stated in its `lean/docs/378.md`; Theorem D.1 and this explicit graph compiler have NOT been independently Lean-checked here. Independent external proof and originality review are outstanding.

For m <= D*n and fixed D > 0, the manuscript-based bound reads poly(n)*2^{O_D(n/sqrt(log(n+2)))}. For arbitrary clause density, the source paper itself uses sparse polynomial equations and parity tests to get poly(n+m)*2^{O(n loglog n / sqrt(log n))}; that reduction is not re-proved here.

**Important category distinction:** This upper bounds the size/time of an adaptive recursive exact *contraction program*, not the number of summands in a fixed global affine-quadratic decomposition. No chi_global <= 2^{o(n)} theorem for the particular affine-quadratic format is asserted.

Primary sources:
- OpenAI announcement, 26 Oct 2026: https://openai.com/index/building-scientific-understanding-with-academic-communities/
- OpenAI manuscript, 25 Oct 2026, Theorem D.1 and Appendix D.4: https://github.com/openai/math/blob/main/preprints/The-Exponential-Time-Hypothesis-is-False-October-25-2026/paper.pdf
- OpenAI documented Lean scope, result 378: https://github.com/openai/math/blob/main/lean/docs/378.md
- Anthropic competing construction: https://github.com/anthropics/formal-math/tree/16a5ce41304fcdaea4e0be7c132e1c361dc26da5/eth

## 2. Exact compiler and bijection

Normalize clauses: remove duplicate literals, remove tautologies containing both signs of a variable, return zero immediately if an empty clause exists. For each literal occurrence (j,k) of variable i, create a left-partition vertex O_{j,k}. Connect it to the clause vertex C_j on the right by a fresh Boolean wire. The clause tensor is 1 if at least one occurrence wire satisfies its corresponding literal and 0 otherwise.

For each variable i appearing d_i >= 1 times, put its d_i occurrence vertices in a chain. For each neighboring pair insert a right-partition degree-2 equality vertex B_{i,k} and connect B_{i,k} by wires to those two occurrences. At every occurrence vertex, set its tensor to 1 exactly when all incident wire bits are equal. Set each equality-vertex tensor to 1 exactly when its two incident bits are equal.

All left vertices have degree <= 3 (one clause wire plus up to two neighboring equalities), clause vertices have degree <= 3, and equality bridges degree 2. Every edge goes between the specified left and right partitions.

The clauses contribute L wires. The variable chains contribute exactly 2*sum_i(d_i-1) = 2(L-v) wires. Thus s=L+2(L-v)=3L-2v <=3L<=9m. The number of vertices is O(L+m), and all tensor entries have constant-size Boolean truth-table descriptions.

A network-edge assignment of nonzero total weight satisfies all equality tensors and consequently gives one consistent bit value for each active variable. Conversely each assignment to the v active variables uniquely determines all edge bits that satisfy equality tensors. Under this bijection, clause tensors test the original clauses. Hence Z(G) equals the number of satisfying assignments restricted to active variables. Each unused original variable independently doubles the count. This proves the exact identity.

If the network is empty, the contraction is 1 and the original count is 2^n. If a clause is empty, the original count is 0.

## 3. Ring and complexity compatibility

To compute Z(G) as an exact ordinary integer, work in (Z/2^P Z)[V]/(V) with P=v+1. Since 0 <= Z(G) <= 2^v, its residue modulo 2^(v+1) uniquely specifies the integer. For m >= 1 and L >= 1, s >= v; thus P <= s+1. The ring precision is O(s), truncation length ell=1, vertex count O(s+m), and every local entry is 0 or 1 computed in O(1) time. Theorem D.1 explicitly allows ell=1, degree <=ceil(s^0.9), and this ring. For small s its permitted finite exceptions are handled by enumeration. All required conditions hold after taking the theorem parameter to be max(s,2).

Invoke Theorem D.1 to obtain exact Z(G) in poly(s+m)*2^{O(s/sqrt(log(s+2)))} bit operations and polynomial space; multiplying by 2^(n-v) uses polynomially many bits. Substituting s<=9m proves the stated complexity bound.

## 4. Self-contained quantitative 2-adic mode-count lemma

Consider a collection of nonnegative integer multiplicities a_{j,h}, with each variable of positive weight j. Suppose there are at most 6M/D variables of every weight j, where M,D are positive, and retain only tuples satisfying sum_{j,h} j a_{j,h} < p for positive integer p.

Let N(M,D,p) count the retained tuples. For every theta>0, the product generating function yields

    N(M,D,p) <= exp(theta*p) * prod_{j>=1}(1-exp(-theta*j))^{-6M/D}.

Use -log(1-x)=sum_{h>=1}x^h/h to obtain

    sum_{j>=1} -log(1-exp(-theta*j))
       = sum_{h>=1} [h*(exp(theta*h)-1)]^{-1}
       <= pi^2/(6*theta).

Consequently

    log N(M,D,p) <= theta*p + (pi^2*M)/(D*theta).

Set theta=pi*sqrt(M/(D*p)) to obtain the explicit upper bound

    **N(M,D,p) <= exp(2*pi*sqrt(M*p/D)).**

This proof uses only the per-weight cap on modes; it is valid over every allowable system of mode variables, independently of its combinatorial provenance.

The public manuscript's Appendix D (display around (84), using (D.11) and (D.13)) describes a per-weight cap 6M/D and precision upper bound p<=C0 M D/u, so the lemma gives

    log N <= 2*pi*sqrt(C0)*M/sqrt(u).

If a recursive schedule has M_d <=s/8^d and u_d >= c*log_2(s)/2^d, then summing bounds along a path gives

    sum_d log N_d <= [2*pi*sqrt(C0) / (1-sqrt(2)/8)] * s/sqrt(c*log_2 s).

The exact geometric factor is 1/(1-sqrt(2)/8) = 1.214737233854593... . This calculation quantifies the *enumerated mode choices*, rather than assuming the number of high derivatives can be processed independently. The source paper handles tensor-group partitioning, precision management, and recursion correctness needed to convert this counting result into the full algorithm.

## 5. Verification and scope

Run:

    python verify_compilation.py
    python verify_mode_bound.py

As executed on 27 October 2026: 1,050 randomized CNF comparisons, including 554 full edge-state enumerations, all passed. Structural bipartition, exact wire count, max-degree bound, and exact counting bijection checks passed. Additional 496 independent truncated-partition counts passed the analytic mode bound. The tests validate these finite instances, not the global OpenAI interpolation proof.

## 6. Result classification

- Original SAT-to-degree-three graph transfer as written here: elementary derived proof, verified computationally; no originality claim.
- Mode-count bound with explicit constant 2*pi: exact self-contained calculation from standard generating-function estimate; not claimed novel.
- General s/sqrt(log s) contraction complexity: *published-theorem-based corollary* relying on OpenAI's new Theorem D.1, externally under review at date of this note.
- Formalized comparison: OpenAI's documented Lean general #k-SAT bound is slower by extra log-log factors; transfer to this graph compiler has not been formalized here.
- All-rank affine-quadratic stabilizer compression: remains unresolved. No stronger claim is made.
## 7. Agent verification update — 28 October 2026

A separate agent reconstructed this transfer as a **fully general factor-network identity** over arbitrary finite alphabets and commutative semirings, retaining repeated variable positions, zero-arity factors and signed weights. The [universal theorem and proof](sat-network-universal/THEOREM_AND_SCOPE.md) give the exact formulas `Z(F)=(q*1_R)^(n-v) Z(G)` and `s=3L-2v`, plus a **wire-minimality theorem within the explicitly restricted binary equality-bridge grammar**.

The [standalone checker](sat-network-universal/check_structural_certificate.py) accepts a JSON incidence/equality certificate and verifies polynomial-time that its wire equivalence classes correspond one-to-one with the active original variables. Combined with the written bijection, passing this check implies the exact contraction identity for **all possible local factor weights** on the submitted graph. The [machine verdict](sat-network-universal/AGENT_VERDICT.json) records 3,829 canonical small 3CNFs checked, 2,357 complete edge contractions, 510 signed weighted q-ary cases, 663 formal monomial comparisons, and 11 rejected corruptions.

The underlying COPY-tensor correspondence is established prior art; this audit contributes a precise proof-carrying implementation and explicit accounting. **No external tensor contraction complexity theorem was used** in this additional proof. The full standalone suite is preserved in the dated conversation ZIP `NIGHTFALL_UNIVERSAL_FACTOR_MACHINE_PROOF_20261028.zip` until its original binary archive is published separately.
