# Route 1: query-local Wyner transfer and an unbounded ambient-information separation

**NIGHTFALL paper proof / author-side certificate v1.0 — 2026-11-22.**  
**Status:** Paper proof, exact finite witness, and explicit derivation from already Lean-checked \`Route1WynerGeneral.route1_wyner_general\`. This note's new cross-oracle statement **has not been compiled as a Lean theorem**, independently reviewed, or priority-cleared. It is a quantitative strengthening of the **earlier NIGHTFALL query-local factor transfer (M-based)** in \`QUERY_LOCAL_PRODUCT_FACTOR_TRANSFER_20261119.md\`, not a claim to have invented local pullbacks or Wyner information.

## Objective / definitive hypothesis

The existing Lean-certified Route 1 bound is controlled by Wyner common information \(C_W(X)\) of the **observed full coordinate system**. That coordinate system can be a poor representation of the query task: it may duplicate or redundantly encode an independent source, arbitrarily inflating \(C_W(X)\) without increasing the query complexity.

**Goal:** bound observed-query simulation complexity using \(C_W(Z)\) of a query-recoverable **latent** product-mixture source \(Z\), charging both the locality cost of the pullback and the cost of implementing its queries against the original oracle. Obtain a proven, unbounded separation over the ambient \(C_W(X)\) bound.

The theorem is a *sufficient* simulation principle, not a necessary-and-sufficient characterization, and is unrelated to the time complexity of finding or evaluating a decision tree.

## 1. Source-exact certified input

For finite coordinate set \(J\), finite nonempty alphabet \(A\), \(\mu\) a probability law on \(A^J\), \(g:A^J\to[0,1]\) of coordinate/indicator interaction degree \(\le D\) with \(D\ge1\), and \(0<\tau\le1,\epsilon>0\), the existing Lean declaration \`Nightfall.Route1Polylog.route1_wyner_general\` gives, for every real \(s>C_W(\mu)\) and integer \(q>0\), a decision tree \(t\) with at most \(q\) input-coordinate queries and
\[
 \Pr_\mu\{|g(Z)-t(Z)|>\epsilon\}
 \le \frac{A_D(\tau)+s B_D(\tau)}{q}
      +\frac{\tau}{\epsilon^2},                                      \tag{1}
\]
where the constants are *exactly the ones in the source*:
\[
 K_D=\frac{\pi^2D^2}{2},\quad
 A_D(\tau)=\frac{K_D}{2\,\mathrm{gam}(D,\tau)},\quad
 B_D(\tau)=\frac{1}{
      \mathrm{etaC}(D,\tau)^2\,\mathrm{w0C}(K_D,D,\tau)}.
\tag{2}
\]
Here \(C_W=\mathrm{wynerGen}\) is general-latent Wyner common information; \`Route1WynerGeneral.lean\` proves equality with finite-latent values and the usual general-latent definition. Both \(A_D,B_D\) are strictly positive for the stated parameters. We do **not** change the constants or claim to have rerun the Lean compiler for this new theorem.

## 2. Query-local latent representation

Let \(I,J\) be finite sets of **observed** and **latent** coordinates; take a common finite nonempty alphabet \(A\) for both (the heterogeneous-alphabet statement follows from tagged finite alphabets, but is not needed here). Let
\[
 \Phi:A^J\longrightarrow A^I
\]
be a known deterministic encoding, \(\mu\) a probability law on \(A^J\), and \(\nu\) the target observed-input law on \(A^I\).

Two structural parameters are charged explicitly:

* **Encoding locality \(b\):** for each observed coordinate \(i\in I\), there exists a set \(S_i\subseteq J\), \(|S_i|\le b\), such that \(\Phi_i(z)\) depends only on \(z_{S_i}\).
* **Query recovery \(r\):** for each latent coordinate \(j\in J\), there is an explicitly known deterministic decision tree \(D_j\) querying at most \(r\) observed coordinates of \(x\in A^I\), which outputs \(z_j\) whenever \(x=\Phi(z)\) and \(z\) lies in the support of \(\mu\). The tree can be given arbitrary outputs off the image of the supported source. We require \(r\ge1\) for the simple budget formula; the free-recovery \(r=0\) case can be treated separately.

The target discrepancy is \(\zeta:=\operatorname{TV}(\nu,\Phi_*\mu)\). We may take \(\zeta=0\).

For an observed target \(f:A^I\to[0,1]\) of indicator interaction degree \(\le d\), define \(g=f\circ\Phi\) and put
\[
 D=\max\{1,bd\}.
\]
The theorem concerns standard single-observed-coordinate queries; observing a whole latent block for one unit of cost is **not** assumed.

## 3. Main theorem — query-local Wyner simulation

**Theorem 1.** Under the assumptions above, for every \(0<\tau\le1,\epsilon>0\), integer \(q\ge1\), and \(s>C_W(\mu)\), there is a deterministic **observed-coordinate** query decision tree \(\widehat t\) satisfying
\[
 \sup_{x\in A^I}\operatorname{queries}_{\widehat t}(x)\le rq,  \tag{3}
\]
and
\[
 \boxed{
 \Pr_{X\sim\nu}\{|f(X)-\widehat t(X)|>\epsilon\}
 \le \frac{A_D(\tau)+sB_D(\tau)}{q}
       +\frac{\tau}{\epsilon^2}+\zeta.
 }\tag{4}
\]
The latent law may be an arbitrary finite law: it need **not** be explicitly supplied as a mixture of finitely many products, because the certified general-latent Wyner theorem works for every finite probability law. Complexity of constructing the tree, computing \(C_W\), and evaluating conditional expectations is not asserted polynomial.

**Proof.**

*Degree preservation under local pullback.* The coordinate-interaction-degree-\(d\) space is spanned by cylinder functions on at most \(d\) observed coordinates (finite-alphabet indicator monomials). An individual indicator \(1[\Phi_i(z)=a]\) depends on at most \(b\) latent coordinates, so it is a finite linear combination of latent cylinder indicators on \(S_i\). A product of up to \(d\) observed indicators therefore becomes a linear combination of latent cylinders supported on a union of at most \(bd\) latent coordinates. Thus \(g=f\circ\Phi\) has indicator degree at most \(bd\), hence at most \(D\). Also \(0\le g\le1\) everywhere.

*Certified latent simulator.* Apply the already source-pinned Lean theorem (1) to \((\mu,g,D,\tau,\epsilon,q,s)\). It supplies a latent-coordinate decision tree \(t\) with worst-case latent depth \(q\) and the probability bound in (1).

*Exact oracle-preserving compilation.* Replace every node of \(t\) that requests latent \(z_j\) by its observed-coordinate decision tree \(D_j\), then follow the continuation branch labelled by the recovered value. This produces an ordinary deterministic decision tree \(\widehat t\) on original observed inputs. Any root-to-leaf path of \(t\) contains at most \(q\) latent requests; every substituted node requests at most \(r\) observed coordinates; therefore \(\widehat t\) has worst-case depth at most \(rq\). Repeated observed queries can be left in place; no caching or independence assumption is required. For every \(z\) in \(\mathrm{supp}(\mu)\), the recovery assumption ensures inductively that \(\widehat t(\Phi(z))=t(z)\). Hence
\[
 \Pr_{\Phi_*\mu}\{|f(X)-\widehat t(X)|>\epsilon\}
 =\Pr_\mu\{|g(Z)-t(Z)|>\epsilon\}.                          \tag{5}
\]

*Robust law transfer.* For every event \(E\subseteq A^I\), the definition of total variation gives
\(\Pr_\nu(E)\le \Pr_{\Phi_*\mu}(E)+\zeta\). Apply this to the failure event of \(\widehat t\), use (1) and (5), obtaining (4). \(\square\)

**Corollary 2 (optimized local common-information complexity).** Fix target error \(\delta>\zeta\), accuracy \(\epsilon\), \(\tau<\epsilon^2(\delta-\zeta)\). For every admissible representation \((J,\mu,\Phi,b,r,\zeta)\) and any \(s>C_W(\mu)\), choosing
\[
 q\ge \left\lceil
 \frac{A_{\max(1,bd)}(\tau)+sB_{\max(1,bd)}(\tau)}
 {\delta-\zeta-\tau/\epsilon^2}
 \right\rceil                                                   \tag{6}
\]
(and \(q\ge1\)) guarantees worst-case observed depth at most \(rq\) and failure probability at most \(\delta\). Optimizing the right-hand side **over representations** defines a task- and oracle-aware effective information budget, rather than just \(C_W(X)\). For fixed tolerances it is of order
\[
 r\cdot\mathrm{poly}(bd,1/\epsilon,1/(\delta-\zeta))
       \bigl(1+C_W(\mu)\bigr),
\]
with source-exact constants determined by (2); the degree and query-lift penalties must always be included.

**Scope:** The minimization is an upper bound on query complexity, not a claimed computable invariant, unique minimum, or exact complexity formula. A representation with a tiny latent \(C_W(\mu)\) but huge \(b\) or \(r\) need not help.

## 4. An unbounded strict improvement: duplicate-bit law

Fix any integer \(N\ge1\). Let \(Z=(Z_1,\ldots,Z_N)\) have independent fair bits and let the observed input have \(2N\) coordinates
\[
 X=(Z_1,\ldots,Z_N,Z_1,\ldots,Z_N)=\Phi(Z).                \tag{7}
\]

**Theorem 3 (exact ambient Wyner gap).** With natural logarithms,
\[
 C_W(X)=N\log2,\qquad C_W(Z)=0,
 \qquad b=1,\quad r=1.                                    \tag{8}
\]
For **every** bounded observed function \(f\) of indicator degree \(d\ge1\), the optimized query-local theorem (4) admits the same \(D=d\), same accuracy and failure tolerances, and **constant-in-\(N\)** Wyner-dependent budget by choosing \(s>0\) independent of \(N\). Direct application of (1) to the **observed** \(2N\)-coordinate representation charges \(s>N\log2\). Thus the *certified-bound's information term* is improved by an arbitrarily large factor in \(N\), with **zero** increase in interaction degree or query-lift cost. This is an unbounded gap in **theorem upper bounds**, not a lower bound on the optimal complexity of the direct algorithm.

**Proof.** Clearly \(b=r=1\): observed \(X_i\) equals one latent \(Z_i\), and latent coordinate \(Z_i\) can be recovered by a single query to observed coordinate \(i\). Since the \(Z_i\) are independent, take a constant auxiliary latent in Wyner's definition to see \(C_W(Z)=0\).

Now let \(W\) be **any** auxiliary variable for which all \(2N\) observed coordinates are conditionally independent and whose mixture reconstructs the diagonal law (7). Every pair \((X_i,X_{N+i})\) equals almost surely. Conditional independence and zero probability of disagreement imply, for almost every \(W=w\), that this pair's conditional product law has support on the diagonal of \(\{0,1\}^2\). A product probability measure supported on a two-point diagonal must be a **single point mass**: if both diagonal values had positive probability, conditional independence would assign positive mass to a forbidden off-diagonal point. Thus for each \(i\), \(X_i\) is conditionally deterministic given \(W\). Since \(N\) is finite, the entire observed vector \(X\) is conditionally deterministic given \(W\), and \(H(X\mid W)=0\). Therefore \(I(X;W)=H(X)=H(Z)=N\log2\). Point-mass product components attain this value, so the infimum in Wyner's definition equals \(N\log2\). Equation (8) follows. \(\square\)

**Independent algebraic negative control.** A model in which an individual latent query requires \(r=N\) observed queries does not inherit a constant observed-query bound, even if \(C_W(Z)=0\). Likewise a local encoding with \(b=N\) may elevate degree from \(d\) to \(Nd\). These are real constraints, not removable notation.

## 5. Certificate, provenance, test, and priority

**Core import and exact claim:** \`research/nightfall/formalization/product_space/Route1WynerGeneral.lean\`, \`route1_wyner_general\`, merged PR #970. The constants \`gam\`, \`etaC\`, and \`w0C\` were **not** simplified or approximated in (4). The existing Lean theorem has a finite homogeneous alphabet and all input masses nonnegative, including zero atoms.

**Earlier NIGHTFALL antecedent:** \`QUERY_LOCAL_PRODUCT_FACTOR_TRANSFER_20261119.md\` already establishes the **M-based** query-local factor transfer and duplicate-source example. The **new scope** proved here is replacing component count \(M\) by **general-latent** \(C_W(\mu)\), explicitly propagating the exact polylog-Wyner error bound through the query-oracle compiler, and proving the exact unbounded ambient-versus-latent Wyner separation \(N\log2\) vs zero.

**External antecedent:** Wyner's 1975 common-information definition; standard low-degree cylinder pullbacks and decision-tree substitution; product-space Aaronson–Ambainis machinery following Turturean 2026. A limited dated online query on 2026-11-22 found related local samplers, local membership-query and relevant-common-information literature, not a source-exact match for this three-parameter query-transfer bound. This is **not** global priority clearance and no competitive originality label is asserted.

**Reproduction plan:** An independent exact finite checker should enumerate every observed cylinder indicator with up to \(d\) coordinates for \(N\le5\), pull it back by (7), and verify that the resulting truth table has a representation using at most \(d\) latent coordinates; separately confirm one-query latent recovery, and test \(\operatorname{TV}\) transfer on small perturbations. The analytic \(C_W(X)=N\log2\) identity is proved above without floating-point optimization and is not certified by such finite tests.

**Gate:** Paper theorem and strictly improved certified-source *derivation* established. Full Lean formalization of the oracle tree compilation and new Wyner-local corollary is outstanding; an independent review of the degree definition's identification with indicator cylinders and the full exact constants is recommended. No background process or unpublished review is claimed.
