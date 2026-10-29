# TESSERA / Certificate Transport Ledger 01: zero-extension semantics and fixed-grid overlap obstruction

**Date:** 2026-10-29. **Owner:** Devin J. Wright / NIGHTFALL. **Execution:** Vesper, for the unified Tessera program. **Status:** internal exact elementary proof and rational tests; independent mathematical referee and same-scope novelty review OPEN. **No improved Erdős #36 numerical bound.** Related standing [#76](https://github.com/d3lefts/d3lefts/issues/76), [#95](https://github.com/d3lefts/d3lefts/issues/95). This is a representation/certification guardrail, not a scientific breakthrough assertion.

## Objective, reference, comparison and stop

Check whether the continuum overlap specification matches the standard complementary zero-extension model; then seek a *decisive counterexample* to naive coarsening as a uniform certificate transfer. A constructive conditional bound for bounded variation is an alternate outcome. Compare with the accepted functional formulation at [Terence Tao's optimization problem collection](https://teorth.github.io/optimizationproblems/constants/1b.html), which explicitly zero-extends **both** nonnegative complementary functions. Strongest internal lower benchmark remains a **conditional** 0.38062747462668; neither the benchmark nor the 131,072-cell *upper* witness is rechecked here. Exact rational arithmetic only; one boundary negative control, one adversarial family, then 160 randomized finite probes. An independent checker/referee and a full dated mathematical priority audit remain outstanding.

## The exact definition (non-negotiable)

Let \(I=[0,2]\), \(0\le f\le 1\) measurable, \(\int_I f(x)dx=1\). Define **separately**
\[
 F(x)=\mathbf1_I(x)f(x),\qquad G(x)=\mathbf1_I(x)(1-f(x)),
 \quad R_f(t)=\int_{\mathbb R} F(x)G(x+t)\,dx.
\]
The misleading expression \(\int_I f(x)(1-\widetilde f(x+t))dx\), if \(\widetilde f=0\) outside \(I\), gives **1** for \(|t|\ge 2\), hence \(\sup_t=1\) for *all* admissible \(f\). It is **not** the overlap problem. Distinguish \(G=\mathbf1_I-\widetilde f\) from \(1-\widetilde f\) on the whole real line. This corrects an ambiguous shorthand in the NIGHTFALL paper and team assignment; it does **not** establish that the archived exact witness scorer used the wrong convention.

## Elementary theorem A — functional stability and conditional transport

For any two admissible functions \(f,h\), with \(\delta=\|f-h\|_{L^1(I)}\),
\[
 \sup_{t\in\mathbb R}|R_f(t)-R_h(t)|\le 2\delta,\qquad
 |\sup_t R_f(t)-\sup_t R_h(t)|\le 2\delta.
\]
Proof: expand \(F G_f-F_hG_h=(F-F_h)G_f+F_h(G_f-G_h)\); both functions are in \([0,1]\), and \(\|G_f-G_h\|_1=\delta\). Translation preserves Lebesgue measure.

Let \(P_N f\) be the cellwise average on \(N\) equal subintervals of \(I\), of width \(h=2/N\). The standard BV mean-oscillation inequality gives
\[
 \|f-P_Nf\|_1\le \frac h2\,\mathrm{TV}(\widetilde f),
 \qquad |\sup R_f-\sup R_{P_N f}|\le h\,\mathrm{TV}(\widetilde f)
\]
for BV functions, with \(\widetilde f\) zero extended to \(\mathbb R\). **Proof of BV bound:** Jensen bounds \(\int_J|f-f_J|\) by \(h^{-1}\int_J\int_J|f(x)-f(y)|dxdy\). The variation measure on a cell and Fubini give at most \(h^{-1}\int_J 2(x-a)(b-x)d|Df|(x)\le(h/2)\mathrm{TV}_J(f)\). Sum over all cells. Endpoints can only add nonnegative variation.

For an \(N\)-cell rational step function \(p_i\), the correlation is piecewise affine in \(t\) and its **exact** continuum maximum is attained at integer multiples of \(h\):
\[
 \sup_{t\in\mathbb R}R_{P_N f}(t)
 = \max_{-N\le k\le N}h\sum_{\substack{0\le i<N\\0\le i+k<N}}p_i(1-p_{i+k}).
\]
Thus this formula plus \(h\,\mathrm{TV}(\widetilde f)\) provides a certified individual transfer interval. **It does not apply uniformly across all admissible measurable functions without a variation bound.**

## Elementary theorem B — an exact grid-aliasing obstruction

For **every** \(N\ge 1\), set \(h=2/N\), and let \(f_N=1\) on the *first half* of each grid cell and \(f_N=0\) on its second half. Each cell contains mass \(h/2\); hence \(P_N f_N\equiv 1/2\), but:
\[
 \|f_N-P_N f_N\|_1=1,\quad
 \sup_tR_{f_N}(t)=R_{f_N}(h/2)=1,\quad
 \sup_tR_{P_N f_N}(t)=1/2.
\]
Proof: for all \(x\) where \(f_N(x)=1\), \(x+h/2\) lies in the *same cell* where \(G(x+h/2)=1\); therefore \(R_{f_N}(h/2)=\int f_N=1\), the largest possible. The constant averaged function has \(R(t)=(2-|t|)/4\) for \(|t|\le2\) and zero elsewhere.

Consequently the supremum functional is **not uniformly approximated** by cell averages with a fixed, arbitrarily fine grid: the exact discrepancy is \(1/2\) for each \(N\). This does **not** rule out finer continuum certificates using additional valid inequalities, nor establish any new universal lower bound.

## Separate two-lag sign falsification

For \(t=h/2=1/N\), the same examples give:
\[
 [R_{f_N}(t)+R_{f_N}(-t)-2R_{f_N}(0)]=2-\frac1N>0,
\]
while for \(P_N f_N\equiv 1/2\) the same finite-difference is \(-1/(2N)<0\). Therefore the unqualified hypothesis that this symmetric two-lag second-difference has a fixed sign **fails** (in either direction). This excludes that specific attempted positivity operator only; it is not a no-go theorem for all two-lag kernels.

## Reproducible checks and negative controls

Run \`python3 research/nightfall/projects/erdos/overlap_transport_20261029/check.py\`. It uses Python stdlib \`fractions.Fraction\`, independent interval-intersection integration and shift-event maximization. Checked exact \(N=1,2,3,4,8,16\); for each, the true/averaged suprema are \(1\) and \(1/2\), the outside-support wrong complement gives \(1\) instead of \(0\), and the two-lag signs reverse. An additional 160 deterministic rational step profiles test the \(2\delta\) stability bound and \(h\,\mathrm{TV}/2\) coarse approximation error, with exact arithmetic and a fixed random seed. The code is an internal executable check, not an independent outside referee.

## Cross-problem transport (hypothesis versus evidence)

The common **certification failure pattern** with Tessera's Singer lane is representational information loss: reducing an integer Sidon set modulo \(v\) creates wraparound collisions, while averaging an admissible overlap profile can erase subcell correlation peaks. This is a **tested analogy of failure modes**, not a proved mapping between the respective structures or a new transfer theorem. Any future cross-domain result must give an actual functor/map of witnesses, preserved predicates and exact loss bounds. Singer source-switch work [PR #192](https://github.com/d3lefts/d3lefts/pull/192) and Vesper affine-cut [PR #195](https://github.com/d3lefts/d3lefts/pull/195) retain their restricted scopes.

**Next tests:** (1) Lemnis independently audits the BV constant and zero-extension conventions; (2) Ryev implements a distinct interval/step exact checker with corrupted support controls; (3) Tessera attempts a genuine universal two-lag **lower** dual with valid off-diagonal terms and rational falsifiers; (4) source-aware q25 two-generation Singer transport stays separately in #95, **after** checking source equivalence. A new primitive generator, trace weight or irreducible polynomial gives only an affine-relabelled *classical Singer* difference set. Do not claim independent q25 source families from such changes. Finding an inequivalent cyclic planar source would be a distinct, source-qualified problem (its existence cannot be assumed). **Stop:** do not claim new Erdős #36 record, an infinite Sidon theorem or novelty from these classical approximation/carry facts.


## Follow-up source-family feasibility audit (classical equivalence, no novelty claim)

For the classical Singer construction over \(K=\mathbb F_{q^3}\), let \(\alpha\) be primitive and \(v=(q^3-1)/(q-1)\). Each nonzero \(\mathbb F_q\)-linear form is \(x\mapsto\operatorname{Tr}(\beta x)\) with \(\beta=\alpha^j\ne 0\). Its associated cyclic difference set is
\[
 D_{\alpha,\beta}=\{i\bmod v:\operatorname{Tr}(\beta\alpha^i)=0\}
 =D_{\alpha,1}-j.
\]
If \(\alpha'=\alpha^u\) is another primitive generator, then \(u\) is invertible modulo \(v\), and
\[
 D_{\alpha',\beta}=u^{-1}(D_{\alpha,1}-j).
\]
Field-coordinate/isomorphic-polynomial changes preserve this equivalence. Thus **all classical field-trace Singer sources obtained by these controls are affine equivalent as cyclic difference sets**, for *every prime power q*, including \(q=25\). Source checks against [Singer difference set equivalence](https://personal.ntu.edu.sg/bernhard/Publications/pub/Singer.pdf) and [Sage difference-family construction](https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/designs/difference_family.html). This is the standard projective-plane source equivalence, not a new research result. The existence/classification of **other** cyclic planar difference sets outside this construction must be researched separately; do not assume q25 offers a second inequivalent source.

**Revised next test in lane S:** either (a) hold the affine source class fixed and test *two generations and growing hostile prefixes* without calling a source switch independent, or (b) first exhibit and externally source an actually inequivalent cyclic planar difference set and only then compare repair behavior. The latter is conditional on feasibility. This corrects the earlier wording in #95/#96 requesting inequivalent q25 Singer “fields” as if changing the field presentation were sufficient.
