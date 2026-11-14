# Task-Relevant Quotient Observability and Change-Stable Certificates
**NIGHTFALL finite-field pilot v0.1 — 2026-11-13.** Authored collaboratively by Devin J. Wright and ChatGPT. **Status: author-side analytic proofs plus exact finite arithmetic audits, not independent peer review, Lean terminal proof, established novelty, or actual physical safety certification.**

## Defined observation and verifier interface
Let q be a prime power, F=GF(q), X in F^n be uniform with independent coordinates, and N in F^n be an arbitrary **jointly correlated** noise vector independent of X. A persistent observation oracle reveals one coordinate of Y=X+N per paid read; rereading does not generate another noise sample. The task is K=AX with A an explicit full-row-rank d by n matrix. The verifier has authenticated source records, a version-committed **known** joint noise law and a complete authenticated change manifest. It checks finite arithmetic and version transport but does not establish the actual physical measurement law, cryptographic authenticity or completeness of the manifest.

Separate source-read costs from two-input finite-field arithmetic and raw-word checking. A trusted direct-task oracle or cached aggregate fundamentally changes the stated lower bounds.

## 1. Exact quotient posterior
For observed coordinates Q, define U=im(A_{bar Q}) and the quotient map pi:F^d -> F^d/U; put r=dim(U). For all y_Q and k,

    P(K=k | Y_Q=y_Q)
      = q^(-r) P(pi A_Q N_Q = pi(A_Q y_Q - k)).

Hence (logarithms base two)

    I(K;Y_Q) = (d-r) log_2 q - H(pi A_Q N_Q),

and exact maximum average probability of task identification from Y_Q is

    p_MAP(Q) = q^(-r) max_z P(pi A_Q N_Q=z).

**Proof.** Since X is independent uniform, Y=X+N is uniform and independent of N, including when N has correlated coordinates. X_{bar Q} remains independent of (Y_Q,N_Q), so K=A_Q(Y_Q-N_Q)+A_{bar Q} X_{bar Q}. The last summand is independent uniform on U. Conditional task law is constant within each coset and its coset index is the shifted projected noise. Taking entropy and pointwise maximum proves the displayed formulae. All hypotheses matter.

## 2. Exact adaptive acquisition frontier for a scalar modular task
For S nonempty, |S|=p, K_S=sum_{i in S} X_i, and Z_S=sum_{i in S} N_i, put p_star=max_z P(Z_S=z). Assume p_star>1/q. If P is the set of already acquired coordinates and m=|S\P|, then to achieve mean identification success s in [1/q,p_star], any randomized adaptive strategy must make at least

    E[new sensor reads] >= m (s-1/q)/(p_star-1/q).

This bound is achieved by independently randomizing between reading all missing coordinates and reading none.

**Proof.** Any terminal transcript missing one S-coordinate leaves a fresh uniform, independent X_i masking K_S and permits success only 1/q. The full S-transcript allows posterior-mode success p_star independent of observed values. If alpha is the probability of finishing all m missing reads, success <= (1-alpha)/q+alpha*p_star, while expected reads >= m*alpha. Eliminate alpha. Randomize complete acquisition with exactly the alpha required.

Corollary: every proper subset of the support conveys zero task information; with full S,

    I(K_S;Y_S) = log_2 q-H(Z_S).

For q=2 independent bit flips at rate eta, p_star=(1+|1-2eta|^p)/2. For the two-coordinate correlated noise N_1=B, N_2=-B with uniform B, the total noise cancels and the complete task is recovered exactly. This is complementarity under a narrowly specified generative model.

## 3. Row-column task revelation lower/upper bound
For an r by r array of independent uniform latent shares, a task is revealed after b pre-observed cells: one row or one column sum. Every task's aggregate noise must be nonuniform so that its full-set Bayes accuracy strictly exceeds 1/q. The *pathwise* worst-case further cell reads necessary to reach that task's full Bayes accuracy is exactly

    L_r(b) = r - floor(b/r),    0<=b<=r^2.

**Lower bound.** By averaging row counts, some row contains <=floor(b/r) pre-observed cells; selecting that task forces its remaining cells to be read. **Upper bound.** Partition edges of the complete bipartite row-column incidence graph into r cyclic perfect matchings. Buy floor(b/r) matchings and b mod r extra edges. All rows and columns have >=floor(b/r) pre-observations. The acquisition theorem completes the proof. The quantification permits a worst-case task chosen after the pre-purchase set; do not replace it with an oblivious/adaptive expected guarantee without a new proof.

## 4. Exact authenticated-delta certificate maintenance
Let S be a fixed declared scalar-sum task. A baseline version v stores its verified raw readings and checked aggregate B_v=sum_{i in S} Y_i, together with a committed noise law and posterior mode z_star. The authorized edit T supplies complete, signed **exogenous deterministic shifts** to the latent X, with persistent noise realization and law and delta_i=Y_i^{v+1}-Y_i^v. Put k=|T intersect S| for the relevant explicitly supplied nonzero or potentially nonzero raw delta words. Then

    B_{v+1}=B_v+sum_{i in T intersect S} delta_i,
    Khat_{v+1}=Khat_v+sum_{i in T intersect S} delta_i.

Linearity proves these identities, and version-committed checking makes them inductively reusable. Under a cached arbitrary prior aggregate, individual raw delta inputs, and a two-input-gate arithmetic circuit with no aggregate oracle, k group additions suffice and are necessary, since a function essentially depending on k+1 independent inputs requires >=k fan-in-two connecting gates. Independently checking a claimed update needs k raw delta reads. From scratch a task of support p needs p raw source reads and >=p-1 sum gates, and raw-word aggregate checking must inspect all p. **These are not general RAM, cell-probe, cryptographic or circuit lower bounds** when the oracle is strengthened.

Fail closed on new/unknown noise law, task matrix/support change, new noise sampling, missing manifest entries, missing version binding or unauthenticated facts. These conditions are part of the actual theorem scope, not optional operational conveniences.

## 5. No sensor-only certificate for hidden noise-law drift
Take F_2, fair independent X_1,X_2, K=X_1+X_2, Y=X+N. Compare W0 with N=(B,B) for fair B and W1 with independent fair N=(B1,B2). In **both** worlds Y is uniform over all four readings and all raw sensor-only transcripts have identical law. Yet in W0 K=Y_1+Y_2 exactly, while W1 leaves K independent of Y and maximal confidence 1/2. Sensor-only reading therefore cannot certify which task accuracy regime holds following an unannounced noise-law change. A separately trusted model/label/calibration interface is indispensable for such a guarantee.

## Audit and limitations
Run \`python3 -I exact_audit.py\`. Committed audit counts: 240 random correlated-noise models, 1,860 observed sets, 41,706 exact rational posterior cells; 600 random noise models and 5,400 deterministic adaptive trees; 4,000 signed-delta tests; 66,064 pre-observation subsets for r=2,3,4; complete-observation non-identifiability counterexample with Bayes accuracies 1 and 1/2. Fixed seed 20261113. These checks falsify small cases independently of the symbolic derivation but cannot formally prove a universally quantified theorem. No independent external mathematical review was conducted.

**Prior art / novelty gate:** linear/additive-noise channels and secret sharing, data sufficiency, self-adjusting and incremental computation, dynamic data structures, test cover and change-aware assurance. This is a rigorous bounded-model pilot and a reusable research instrument, **not** a priority-validated new general theorem.

**Next decisive experiment:** a task-dependent trust-model change under a priced calibration oracle, with matching upper/lower bounds for newly required authenticating evidence that cannot be reduced to linear channel conditioning or ordinary incremental sums.

## Sources and integration
- [Incremental computation: Ramalingam (1993)](https://www.microsoft.com/en-us/research/publication/bounded-incremental-computation/)
- [Self-adjusting computation: Acar et al. (2006)](https://www.cs.cmu.edu/~guyb/papers/ABBHT06.pdf)
- [Assurance evidence reuse: Mukhopadhyay–Nalla (2026)](https://arxiv.org/abs/2610.27672)
- [Amortized cell-probe lower bounds: Ko (2026)](https://arxiv.org/abs/2611.11508)

The companion typed synthesis is in ../DISSERTATION_INSERT.md, with independently bounded combinatorial and signed-lag examples under ../TASK_DISTINCTIONS_LIFECYCLE_SYNTHESIS.md.
