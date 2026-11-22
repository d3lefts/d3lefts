# Sharp-order adversarial noise modulus at the 2D phase-retrieval threshold

NIGHTFALL author-side mathematical checkpoint, 22 November 2026. **Paper-level proof candidate: not Lean-certified, independently refereed, or priority-cleared.** This is the first quantified mathematical target arising from the noise-robustness charter in draft PR #1001. It does not alter the historical theorem source or status of merged PR #997 or draft PRs #995/#999.

## Model and a falsifiable statement

Let D_R be the closed Euclidean ball of radius R in R^n. Stage j chooses a row a_j from its prior **noisy** transcript (globally defined and continuous), with norm at most 1, and receives

\[
z_j=\langle a_j(z_1,\ldots,z_{j-1}),x\rangle^2+e_j,
\qquad |e_j|\le\sigma.
\]

A deterministic decoder returns a sign class [x] with distance d_pm([x],[y]) = min(||x-y||,||x+y||). Let E_m(n,0,R;sigma) be the infimum worst-case distance over such selectors and unrestricted decoders. Strategies may depend on the known noise budget sigma. No runtime or decoder continuity guarantee is made.

**Theorem A (collision inflation, unconditional relative to its hypothesis).** Suppose a normalized causal intensity protocol has two signals x,y in D_R giving the same **noiseless** transcript, with d_pm(x,y) >= R. For 0 < sigma <= R^2/64, there are signals x',y' in D_R with a common transcript achievable under adversarial errors of absolute size at most sigma and

\[
d_{\pm}(x',y')\ge R\sqrt{1+\sigma/(2R^2)}.
\]

This assertion needs no continuity of the selectors, only their common-prefix interpretation and unit row norms. It applies in every n >= 2 and every number of readings.

**Theorem B (two fixed rows, upper bound).** For n=2 and 0 < sigma <= R^2/1024, a fixed, normalized two-row protocol and an unrestricted decoder achieve

\[
E_2(2,0,R;\sigma)\le R/2+18\sigma/R.
\]

**Sharp-order corollary (assuming the exact separated-collision theorem from merged #997).** For n=2, m=2, the annular topological collision gives d_pm(x,y)=R in the ball for every continuous causal policy. Therefore, for 0 < sigma <= R^2/1024,

\[
\boxed{\frac{\sigma}{12R}\le E_2(2,0,R;\sigma)-\frac R2
\le\frac{18\sigma}{R}}.
\]

Thus the minimax excess error is Theta(sigma/R), with a sharp *exponent* 1 and unoptimized constants. The lower is conditional on the source-level nontrivial topological collision statement in #997, not on a new Lean proof in this PR. The inequality also implies E_2(2,0,R;0)=R/2 by taking sigma down to zero and using the same collision lower bound. No strict advantage for adaptive rows at the level of the noise **exponent** follows, since Theorem B already uses fixed rows.

## Consequence: selection regularity is not the exponent bottleneck in 2D

For every prescribed nonnegative Lipschitz bound L on the noisy-prefix **row-selection maps**, the same Theta(sigma/R) excess holds at n=2,m=2: fixed rows have history-Lipschitz constant **zero**, and the lower bound applies to the larger unrestricted class. This finding therefore excludes a separation in the *noise exponent* based only on selector-history Lipschitz regularity in this particular minimax model. It does **not** establish equality of sharp constants, efficient decoding, or stability of the row parameters as sigma changes.

The chosen second row has transverse coefficient beta=2 sqrt(sigma)/R and consequently depends on the **known noise budget**. This dependence must not be silently replaced by one fixed frame used for all sigma. The paper-level nonattainment result in draft #999 suggests that a sigma-independent fixed frame cannot attain the noiseless R/2 benchmark; that separate conclusion still requires its own audit. Row implementation noise, decoder Lipschitz constraints, and higher-dimensional cases remain outside this theorem.

## Proof of Theorem A: inflate any exact collision

Scale R=1 and write s=sigma/R^2 <=1/64. Because phaseless transcripts are even, change the sign of y and exchange signals if necessary to write

\[
a=\|x\|\ge b=\|y\|,\quad c=\langle x,y\rangle\ge0,\quad
d_{\pm}(x,y)^2=a^2+b^2-2c\ge1.
\]

Since a <=1, we have 2c <= a^2+b^2-1 <= b^2. In particular c <=b^2/2.

**Case I: b^2 <= 1-s.** For b>0, replace y by y'=(b'/b)y with b'=sqrt(b^2+s). Then y' remains in the ball. Its squared quotient separation increases by

\[
d_{\pm}(x,y')^2-d_{\pm}(x,y)^2
=s-2c(b'/b-1)
\ge s-b(b'-b)=b'(b'-b)\ge s/2,
\]

because (b'-b)(b'+b)=s. For every unit-bounded row q,
\[
|\langle q,y'\rangle^2-\langle q,y\rangle^2|
=(s/b^2)\langle q,y\rangle^2\le s.
\]
If b=0, then a=1. Instead choose y' perpendicular to x with norm sqrt(s); the quotient squared separation increases by s and every squared reading changes by at most s.

**Case II: b^2>1-s.** If the original d_pm(x,y)^2 >=1+s/2 there is nothing to do. Otherwise
\[
c=(a^2+b^2-d^2)/2>1/2-5s/4>=123/256>0.48.
\]
Since a>=b, the angle theta between x and y satisfies
\[
0<\cos\theta=c/(ab)\le b/(2a)\le1/2,
\quad \sin\theta\ge\sqrt3/2.
\]
In the two-dimensional span of x,y rotate y away from x by phi=s/2, leaving its norm unchanged. As cos(theta)>=c>123/256 and phi<=1/128, cos(theta+phi)>0: indeed cos(theta+phi)>= (123/256)(1-1/32768)-1/128>0. The quotient distance therefore remains ||x-y'||. Also ab>1-s, sin(phi)>=3phi/4 (Taylor's inequality), and sqrt(3)>=5/3. Hence
\[
d_{\pm}(x,y')^2-d_{\pm}(x,y)^2
=2ab(\cos\theta-\cos(\theta+\phi))
\ge 2(1-s)(\sqrt3/2)(3\phi/4)
\ge (315/512)s > s/2.
\]
The perturbation satisfies ||y'-y|| <=phi. Therefore, for every unit-bounded row q,
\[
|\langle q,y'\rangle^2-\langle q,y\rangle^2|
\le(\|y'\|+\|y\|)\|y'-y\|\le2\phi=s.
\]

**Causal replay.** Let h be the common noiseless transcript of x and y. Feed the unchanged x with zero noise. Feed y' the stagewise adversarial errors

\[
e_j=h_j-\langle a_j(h_{<j}),y'\rangle^2.
\]

Induction forces y' to have exactly the same observed prefix h at every stage, and the preceding per-row estimates show |e_j| <=s. The decoder cannot distinguish the two resulting signals and must incur at least half their quotient distance on one of them. Rescale by R. This completes the proof.

## Proof of Theorem B: fixed near-parallel rows and fiber decoding

Again scale R=1, and write s=sigma/R^2 <=1/1024. Choose

\[
\beta=2\sqrt s,\quad\delta=4\sqrt s,\qquad
a_1=(1,0),\quad a_2=(1,\beta)/\sqrt{1+\beta^2}.
\]

These are fixed normalized rows; in particular they are continuous selectors on all possible noisy prefixes. Since the observation map is even, use the representative with x_1>=0. For any actually observed z, its nonempty *feasible fiber* F_z is the set of such representatives in the unit disk whose two exact squared readings differ from z by at most s in each coordinate. The decoder may inspect F_z noncomputably (allowed by the model).

**Near-axis fiber:** If some x in F_z has x_1 <=delta, every y in F_z satisfies
\[
y_1^2\le x_1^2+2s\le18s.
\]
Output [(0,1/2)]. For any y in F_z, since |y_2|<=1,
\[
d_{\pm}([(0,1/2)],[y])
\le\sqrt{y_1^2+(|y_2|-1/2)^2}
\le\sqrt{1/4+18s}\le1/2+18s.
\]

**Away-axis fiber:** Otherwise every x in F_z has x_1>delta. For any x,y in F_z, first-reading consistency implies
\[
|x_1-y_1|\le s/\delta\le1/128.
\]
Put A=x_1+beta*x_2, B=y_1+beta*y_2. Because beta=delta/2 and |x_2|,|y_2|<=1, both A and B are positive, with A+B>=delta. Squared-reading consistency and beta<=1/16 imply
\[
|A^2-B^2|\le2s(1+\beta^2)\le17s/8,
\quad |A-B|\le17s/(8\delta).
\]
Consequently
\[
|x_2-y_2|\le\frac{25s}{8\delta\beta}=\frac{25}{64},
\quad \|x-y\|\le\frac1{128}+\frac{25}{64}
=\frac{51}{128}<\frac12.
\]
Output any feasible representative. Its worst-case quotient error is less than 1/2, and the near-axis branch gives the stated upper bound after scaling.


### Quantitative upgrade and audit record (22 November 2026)

The earlier estimate used phi=s/8 and squared-distance increase s/16. The revised Case II uses the full admissible angle phi=s/2 and the radial Case I already provides at least s/2. This improves the provable uniform collision inflation **eightfold** while preserving the same normalized causal noise model. The Taylor and trigonometric inequalities were reduced to exact rational guards in the checker. The claims remain at **paper-proof candidate** status until independent mathematical review; updated exact-head CI must be checked separately.

## Audit and novelty gates

- Proof status: paper argument, exact rational constants independently checkable; no Lean theorem is claimed here.
- First source dependency: #997's separated collision on the radius-R ball, which uses product-sphere Borsuk-Ulam; #995/#1000 independently discuss the similar all-policy obstruction. Their mathematical proofs remain separate from this geometric noise inflation lemma.
- Closest *changing-model* prior art: classical fixed-frame complement property; phase-retrieval condition numbers and adversarial/noisy phase retrieval, including arXiv:2506.22053. A targeted 2026-11-22 search found no exact two-reading globally continuous selector, adversarial-prefix, unrestricted-decoder minimax result; **novelty remains unresolved**.
- Theorem A is an operator: exact collision -> strict noisy collision. It uses neither the number of readings nor continuity, so it transfers to any normalized causal intensity system with a matching exact collision.
- Adversarial reviewer should attack the sign quotient under radial/rotational perturbation, the noise transcript induction, zero-signal case, near-axis ambiguous decoder branch, and whether existing literature establishes the same sharp-order result. In particular avoid conflating fixed policies allowed to **depend on sigma** with one uniform fixed policy.
- Reproducibility: use the accompanying exact-constant and randomized negative-control checker. Random search never proves universal claims. A second implementation and a named Lean contract for the radial-inflation inequality remain open.
- If the topological collision theorem is falsified or its scope differs from globally continuous noisy-prefix policies at sigma=0, withdraw the corollary; Theorems A and B remain separate.
- No public priority, specialist acceptance, full theorem certification or publication authorization is asserted. Do not merge as a completed breakthrough.