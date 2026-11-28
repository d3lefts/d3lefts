# External ingestion: Ye Yu's GRH exposition and Lean correspondence
Version 1.0 | 2026-11-28 | External result, not NIGHTFALL discovery

## Contract and provenance
Objective: extract reusable proof operators and distinguish prose from kernel evidence. Scope: RH and Dirichlet GRH, not general automorphic L-functions. Baseline: Alpöge–Claude 2026-11-20 proof, shortened by Luke Sernau and collaborators, and community maintained proof. No new RH bound or priority claim. Audit budget: bounded source/closure review, no large build; independent audit remains open. Stop once abstract cancellation is algebraically checked and transfer limitations recorded. Cheapest decisive next test: exact rational toy model with missing coverage and index cost.

* Original: https://alpo.ge/remark.pdf
* Exposition (Ye Yu with Gemini, MIT repository): https://github.com/sdyy1990/riemann-hypothesis/blob/main/GRH_Proof_EN.pdf — Git blob f18c4b27d7dd881ddef82fcc00953c204f898cde (binary returned by GitHub, not rendered in this environment).
* Text actually consulted: https://github.com/sdyy1990/riemann-hypothesis/blob/main/GRH_Proof_EN.md — blob 7d359f148b243bd3112ae822659b67eac526bfa1.
* Correspondence: https://github.com/sdyy1990/riemann-hypothesis/blob/main/GRH_Lean4_Correspondence.md — blob b9f5bbad45f78d88df9a6f27646f229f3c2ac66b.
* Author audit: https://github.com/sdyy1990/riemann-hypothesis/blob/main/AUDIT_NOTES.md — blob a7433faa2724888cb3b41cf74dda5c4d94cb3cba.
* Formal comparator: https://github.com/lsernau/grh-lean (readable and compact editions); https://github.com/leanprover-community/riemann-hypothesis
* Independent mathematical exposition/ongoing analysis: https://www.math.uwaterloo.ca/~mrubinst/alpoge_claude_grh/
* Lean FRO timeline: https://lean-lang.org/fro/about/

Blob hashes identify contents, not commit IDs. The PDF raw endpoint was served as octet-stream and web screenshot failed; container DNS unavailable. GitHub returned binary metadata and base64, but PDF layout and PDF/Markdown equivalence not independently inspected. No claim of full prose proof review. Source audit corrections and verification receipts are author-reported, not fresh NIGHTFALL runs.

## Discovery graph
RH/Dirichlet GRH -> weighted prime-power remainder -> one-sided Laplace transform and residue separation -> auxiliary cyclotomic CM representation -> local divisibility/short lifts (A), group translates and high-dimensional coverage (B), lower covolume/index inequality (C) -> master inequality -> decay and nonvanishing.

Theorem 4.2's composition (notation from exposition): D=d_T>0, n >= (1-4/b^2)D, n<=D, c=n(M-m rem+L), delta<=D I0. C yields D(M-3L)<=c+2delta. Since M+L>=0, n*m*rem<=D(4L+2I0). If n>=D/2 then m*rem<=8L+4I0. With L=f a log^4 b and I0=10 log(1+2b^2) f a log^3 b, admissible scales in source yield m rem<=f a log^5 b. Theorem 4.3 combines m>=sqrt(x), logarithmic auxiliary-scale control, and estimates at x1 to give one-sided R_q(y)<=y^(-1/2+epsilon). Lemma 2.2 and Theorem 2.3 convert one-sided decay into nonvanishing; Prop 1.3 uses reflection for the critical strip. This is a dependency map, not a proof of the deep inputs.

## Transfer candidate T1: common-baseline cancellation
Abstract statement (elementary conditional lemma; internal algebra only):
Let D>0, 0<n<=D, n>=rho D for 0<rho<=1, B+u>=0, u+v+2j>=0, and j>=0. Suppose c<=n(B-g+u), delta<=Dj, D(B-v)<=c+2delta. Rearrange:
n g <= n(B+u)-D(B-v)+2Dj <= D(u+v+2j),
hence g <= (u+v+2j)/rho.
More precisely n g <= D(u+v+2j)-(D-n)(B+u). This retains an exact coverage-deficit correction. The condition u+v+2j>=0 is needed to replace D/n by 1/rho in this general sign convention.
Negative control: D=2,n=1,rho=1/2,B=-10,u=v=j=0,g=5,c=-15,delta=0 satisfies both bounds but violates g<=0 if B+u>=0 removed. For positive error, low coverage increases the penalty; coverage must not be counted as a full basis.
Status: algebra checked by construction author, not independently reviewed, not a novelty claim. Cost O(1), exact rational arithmetic possible. Scope: objectives with independently proved matching extensive upper/lower baselines and quantified coverage. Candidate transfers: staged resource accounting (Paper VI), spectral-tail/fiber representation (Paper V); no improvement to either theorem established. Do not presume an arithmetic determinant or product formula exists for influence/quantum observables.

## Transfer candidate T2: greedy coverage with a spectral lower bound
For finite family of orthogonal projections P_s on D-dimensional H, if their uniform average >= alpha I for alpha in (0,1], then for any current subspace W with residual projector Q, mean tr(Q P_s)>=alpha dim(W^perp). Since rank(Q P_s)<=dimension increment and singular values <=1, some s increases covered dimension by at least alpha times residual. After k greedy choices residual <=D(1-alpha)^k. Proof: trace(Q P_s)=||Q P_s||_HS^2 <=rank(Q P_s); rank(Q P_s)=dim(W+range P_s)-dim W. Negative control: all P_s have a shared proper range; alpha=0 in uncovered direction, no coverage guarantee. This is an elementary standalone operator inspired by B, not an attribution of this exact statement to the GRH source. Potential use in task-sufficient sensing and representation selection, conditional on deriving a genuine lower frame bound and explicit per-query costs. No novelty claim, no general AA bound.

## Adversarial audit
* The algebra of Thm 4.2 closes given A/B/C and scale conditions; it does not certify the latter.
* Prop 1.3 prose uses a functional equation for imprimitive characters; safest mathematical derivation first strips missing Euler factors (nonzero in the open critical strip), then reflects the primitive L-function. Gamma poles should be distinguished from zeros of reciprocal gamma, or explicitly identify Lean's totalized convention. These are exposition checks, not contradictions of the formal result.
* The companion mentions Lean v4.33.1 for a speed-configuration claim, whereas the upstream README pins v4.35.0 with Mathlib 56a00585. Reconcile exact editions/receipts before borrowing build instructions. Upstream compact and readable editions have distinct paths.
* Source reports original independent con-leche comparison (2026-11-21) and condensed source build (2026-11-27). Keep exact challenge declaration, artifact hash, axiom allowlist, toolchain, exit status and logs together. The source's reported replay is not a local replay. Keep original proof and expositional claims separate.
* Independent next reviewer: Lemnis to attack T1/T2 sign/rank hypotheses and test missing primitive-factor step; Ryev to implement a distinct exact rational checker and negative controls only if transfer becomes load-bearing; Vesper to compare source statements and immutable receipts; Tessera to look for one concrete rank/coverage application. These are proposed handoffs, not assigned/completed reviews.
* No changes to Papers I–VII certification or compiler. No publication/submission. No GRH generalization inferred. No prior-art novelty search for T1/T2 beyond checked source references; elementary inequalities should be treated as known-style proof patterns.

## Next test and stop rule
On Paper V or VI, identify a concrete pair of matching inequalities with same extensive baseline and a rigorously controlled cost for uncovered directions. Compare against existing bound using exact symbolic algebra. Reject transfer if baseline/coverage cannot be derived or if it merely renames an existing proof; prioritize established open objectives rather than rerunning GRH.
