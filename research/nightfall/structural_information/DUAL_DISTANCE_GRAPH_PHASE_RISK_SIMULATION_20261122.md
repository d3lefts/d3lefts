# Dual-distance compiler: high-girth phase retrieval to all-T quantum scalar simulation

NIGHTFALL research checkpoint v1.0, 2026-11-22.

**Status:** complete author-side paper argument assembled from previously established mechanisms; finite exact tests; no new named Lean end-to-end certificate, non-author referee report, world-novelty clearance, or publication/merge authorization. This is a scope-limited **all-T** extension on sufficiently high-girth source codes, not a universal graph theorem or a replacement for draft #1068's unrestricted T2 work.

## Preregistered problem, prior work, and scope

Question: Can a well-formed T-query quantum circuit accessing only the original correlated graph-edge phase/intensity oracle have its **scalar acceptance probability** predicted with a number of legal classical original-edge intensity reads independent of graph size, for every fixed T (not only T=1 or a conditional T=2)?

Dependencies:
- Merged #858: source-checked ProductSimulation.simulation_rows, simulation_degree, leaf_error, prob_bad_le. Uniform-over-all-product-laws bounded low-degree decision-tree simulator. Turturean's general influence ideas are explicit prior art, not an original NIGHTFALL discovery.
- Merged #988: paper proof of exact marginal-matching squared-risk transfer at k = max(2d,d+q), with finite scoped Lean core merged via #1065; the full recursive-tree-to-leaf-system assembly is not certified as one Lean terminal.
- Draft #1095: affine-code Wyner and graph edge intensities; full all-code entropy theorem paper-level, not Lean.
- Draft #1068: coherent normalized graph-intensity bit/phase oracle, local XOR fiber theory and *still unverified* T2 arbitrary Hilbert-frame estimate; not used as a premise here.
- External: Turturean, 2026-11-06, arXiv:2611.09773, AA conjecture proof and public Lean source; Blanc–Docter–Strassle–Tan, arXiv:2611.11626; Girish–Mittal–Nehoran–Raz, arXiv:2609.35327. Code dual distance/k-wise independence and graph cut/cycle duality are classical. TQC 2026, Limitations of Decoded Quantum Interferometry for MaxCut, explicitly identifies graph girth with the distance of the graphic parity-check code.

No same-model predecessor of this *exact composition* was identified in a targeted search on 2026-11-22; that is **NOT** a worldwide novelty certificate.

## Theorem A (uniform affine-code original-query scalar simulation, paper proof)

Let C = a+L be any affine code in F_2^m, with X uniform on C. Set its dual distance g = min {weight(h): 0 != h in L^perp}, g=infinity when L^perp={0}. Let A be any finite well-formed T-query quantum circuit, T>=1, with a coherent controlled original-bit response oracle defined and unitary on **all** m-bit words (not only valid codewords), input-independent gates and an accept effect. Let f: F_2^m -> [0,1] be its acceptance probability (interaction degree d<=2T).

For 0<epsilon,delta<1 let the integer Q satisfy

    Q >= 384*sqrt(2)*pi^6*T^6/(epsilon^5*delta^(5/2)).

If g > max(4T, 2T+Q), there exists a deterministic depth-Q classical decision tree D making only **original code-coordinate bit queries** such that

    Pr_{X uniform C}(|f(X)-D(X)| > epsilon) <= delta.

No classical runtime, coherent quantum state, all-input or unrestricted graph claim.

### Proof A1 — local law

For any S subset [m] with |S|<g, the coordinate projection pi_S(L) is onto F_2^S: otherwise a nonzero functional on F_2^S vanishes on pi_S(L), producing a nonzero dual word supported on S and contradicting dual distance. Fibers of the linear projection have equal size, and affine shifts preserve uniformity. Therefore the uniform code law has exactly the same marginals of every order k<g as the independent uniform bit law U.

### Proof A2 — sharper MSE reading of merged product theorem

Under uniform independent source U, existing ProductSimulation.lean constructs a tree with leaf outputs that are conditional means of f and thus in [0,1]. Use d=2T, source fractional row cost K=pi^2*d^2/2, tau=epsilon^2*delta/2, and eta=tau^(3/2)/(12*K^2). Its proven leaf_error bounds the *finished*-leaf expected squared loss by tau; prob_bad_le and the row-potential estimate bound the bad/unresolved leaf mass by K/(eta*Q). Unresolved leaf squared loss is <=1 because both f and D are in [0,1]. Hence

    E_U[(f-D)^2] <= tau + K/(eta*Q).

The stipulated Q gives K/(eta*Q) <= epsilon^2*delta/2 = tau, because

    24*K^3/(tau^(3/2)*epsilon^2*delta)
      = 6*sqrt(2)*pi^6*d^6/(epsilon^5*delta^(5/2))
      = 384*sqrt(2)*pi^6*T^6/(epsilon^5*delta^(5/2)).

Thus E_U[(f-D)^2] <= epsilon^2*delta. This is a new source-combination *paper* MSE corollary of the merged certified row machinery, not a newly compiled Lean theorem.

### Proof A3 — transfer adaptive risk exactly

Quantum polynomial expansion gives interaction degree f <= d=2T on **the original m edge/code symbols**. Its square f^2 has degree <=2d. Every depth-Q decision tree has leaf indicators depending on at most Q queried coordinates; since they partition the input, both D and D^2 have degree <=Q (NOT 2Q). The product fD has degree <=d+Q. Thus the squared loss (f-D)^2 has degree <= max(2d,d+Q) <= max(4T,2T+Q) < g. By A1, its expectation is **exactly equal** under the code law and the independent uniform source, in line with the exact local-moment risk theorem #988/#1065. Finally Markov gives Pr_code(|f-D|>epsilon) <= E_code[(f-D)^2]/epsilon^2 <= delta.

For an arbitrary finite field F_q, the same projection proof and all-finite-alphabet product simulator #858 yield the corresponding q-ary theorem, provided quantum queries are original q-ary symbols and the full-alphabet circuit is well-formed. This is a general structural transfer, not dependent on graph geometry.

## Corollary A' — arbitrary exogenous correlated bit noise

Theorem A's proof requires **only** that the observed source law agrees with the independent uniform law on all coordinate marginals of size less than g; exact affine-code support is merely one sufficient construction. A useful strictly broader physical-source class follows.

Let X be uniform on affine C with dual distance g, and let N be **any** random binary m-vector **independent of X**, with no restrictions on correlations, support, entropy, noise rate, or dependencies *among the coordinates of N*. Set the **observed** source Y = X XOR N. Then for every coordinate set S of size <g, the marginal X_S is independent uniform; conditional on N_S=n, Y_S=X_S XOR n is still independent uniform. Thus Y matches uniform independent bits through order g-1, and precisely the same Theorem A Q-query risk-transfer proof applies to a well-formed T-query coherent oracle with inputs **Y**, approximated by classical queries to **Y's actual observed coordinates**.

This does **not** recover the clean X from noisy Y, does **not** permit simulating a quantum circuit that has coherent access to X while the classical algorithm only observes Y, and does **not** assert that arbitrary intensity measurement noise necessarily has the binary XOR independent-mask form. The independence condition is essential: if N=X, then Y=0 deterministically and even the one-coordinate uniformity conclusion fails.

The scope gain is structural: some substantial spatial correlations of the raw observable law need no Wyner-latent decoding, no graph-level code-support argument after noise, and no special handling of the correlated noise distribution; local moment indistinguishability alone suffices. This does not solve bounded-girth sources or grant a same-model novelty certificate.

## Theorem B — actual squared-linear graph sensors

For a known finite simple graph G=(V,E), n=|V|>=2, draw uniform independent vertex signs sigma_v. Set the unit signal x_v=sigma_v/sqrt(n) and legal unit sensor a_uv=(e_u+e_v)/sqrt(2). The physical squared intensity satisfies

    y_uv=|a_uv dot x|^2=(1+sigma_u*sigma_v)/n in {0,2/n},

and the indexed original edge bit b_uv=1-n*y_uv/2=(1-sigma_u*sigma_v)/2 is determined by **one** original classical squared-intensity query. The set of edge-bit words is the GF(2) image of the vertex-edge incidence matrix, whose dual is the cycle space. The minimum nonzero dual weight is graph girth (infinity for forests). Therefore Theorem A applies if girth(G)>max(4T,2T+Q).

The quantum model is explicitly an **ideal coherent reversible response-bit oracle** O_b|e,z,w> = |e,z XOR b_e,w>. It is not supplied by destructive measurement apparatus. The simulator's classical queries are real physical/intensity reads from the fixed sensor menu, never free hidden vertex signs, never a new sensing row.

For connected bridgeless graphs, draft #1095's paper-level affine-code support-rectangle computation gives raw coordinate multivariate Wyner CI = (n-1) bits, and complete sign-class reconstruction needs n-1 binary edge reads. High-girth bridgeless graph families of unbounded size therefore have growing raw common information and full-reconstruction cost while **fixed-T scalar acceptance** admits Q original-edge reads independent of n. The comparison is between *different tasks*: full decoding versus acceptance prediction; it is not a lower bound on all raw-source algorithms for a particular acceptance target.

## Exact negative control and finite checker contract

A 4-cycle has parity b0 XOR b1 XOR b2 XOR b3=0. Let f(b)=1[b0=b1], a degree-2 bounded observable, and the legal depth-2 tree D(b)=1[b2=b3]. Under uniform independent edge bits the exact squared risk is 1/2; under the actual four-cycle code f=D always, risk=0. Thus the strict g>k moment threshold cannot in general be weakened to g>=k for d=2,Q=2,k=max(4,4)=4. This does **not** refute an alternative algorithm on 4-cycles.

Exact checker: python3 scripts/check_dual_distance_phase_risk_exact.py. Test every simple graph on 2 through 5 vertices (1098 total), every projection of up to four raw edges, finite-sign integer source tables, and the cycle-4 risk mismatch using fractions. Tests certify finite tables and the boundary falsifier, not a general theorem or a Lean kernel replay. Negative controls: cycles at k=g, graph loops/multiedges excluded, full-domain unitarity, no illicit hidden vertex-sign access.

## Dated adversarial prior-art reconciliation (2026-11-22)

The strongest **additional** published comparisons identified during this session materially narrow originality:

1. *Toward Separating QMA from QCMA with a Classical Oracle* (ITCS 2025; https://drops.dagstuhl.de/storage/00lipics/lipics-vol325-itcs2025/html/LIPIcs.ITCS.2025.95/LIPIcs.ITCS.2025.95.html) explicitly states that **k-wise independent versus uniform random oracles are perfectly indistinguishable** by quantum algorithms making at most k/2 queries. It is a direct antecedent to our \(2T\)-moment observation, but concerns the **expectation of acceptance**, not a low-depth original-symbol classical **predictor of acceptance on most individual codewords**. We make no novelty claim for quantum indistinguishability.
2. William Hoza and Zelin Lv, *Fooling Near-Maximal Decision Trees* (APPROX/RANDOM 2025; https://drops.dagstuhl.de/storage/00lipics/lipics-vol353-approx-random2025/html/LIPIcs.APPROX-RANDOM.2025.35/LIPIcs.APPROX-RANDOM.2025.35.html), develops k-wise probable uniformity and pseudorandom generators to fool decision trees and explicitly uses leaf subcubes. Thus even the adaptive leaf-locality portion is **standard pseudorandomness methodology**.
3. *Limitations of Decoded Quantum Interferometry for MaxCut* (TQC 2026; https://drops.dagstuhl.de/storage/00lipics/lipics-vol389-tqc2026/html/LIPIcs.TQC.2026.6/LIPIcs.TQC.2026.6.html), Remark 3, identifies the cut/cycle space duality and graph girth with distance of the cycle code. We do not claim new graph coding theory.
4. Turturean (2026-11-06), Blanc–Docter–Strassle–Tan (2026-11-08), and Huffstutler–Miloschewsky–Podder (2026-11-09; arXiv:2611.12795) already settle or simplify the original AA uniform-cube problem. Our product simulator itself is **existing merged #858** and independently adapted Turturean's mechanism.

**What survives the priority test:** the repository-specific quantitative composition of (i) an existing product-degree scalar predictor's **mean-square** envelope, (ii) *exact* marginal preservation of adaptive squared prediction risk, (iii) arbitrary-affine/graphic high-dual-distance sources with **one legal classical measured-symbol read per predicted symbol**, and (iv) arbitrary *exogenous correlated noise* invariance. The combination is a useful clean theorem statement and transfer operator, not shown to be globally new. The sharp threshold \(g>2T+Q\) is a sufficient condition of this method, not an optimal quantum-classical separation criterion.

## Priority, independent audit and completion gate

What is new **to this project's graph-phase lane** is the unconditional all-T *high-girth* classical original-edge simulation via source exact moments, bypassing the 31-constant T2 Hilbert operator conjecture. It is a meaningful scope gain, NOT a globally new AA proof, graphic-code theorem, phase-retrieval theorem, or classical k-wise-independence principle. The all-T condition requires girth larger than a potentially huge constant; short-cycle triangular tori remain outside this theorem and retain their separate T2 challenge.

Before theorem promotion, independent reviewer must check (1) the all-raw-input Born bound, (2) the MSE budget from leaf_error and prob_bad_le, (3) the dependency of the squared loss on at most max(2d,d+Q) coordinates despite adaptive repeated reads, (4) code-distance equivalence, (5) original intensity-vs-coherent oracle semantics, (6) exact-head provenance of #858/#1065, and (7) dated same-model literature. The Lean work is a genuine mean-square theorem using #858, explicit recursive DTree->leaf-system connection to #1065, and dual-distance/girth projection lemma; fail closed on nonstandard axioms and source drift.

Stop if any of these gates fails or external prior art already subsumes the complete same-model corollary. No external publication or automatic merge. Origin and credit: user's recover-then-simulate phase/Route1 idea; #858/#988/#1065 formal authors; #1095 graph source; #1068 coherent oracle; Turturean and named prior literature.
