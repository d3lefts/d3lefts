# NIGHTFALL flagship selection and source-scoped frontier audit — 2026-11-22

**Decision:** one active mathematical discovery flagship — **the regularity cost of causal real phase retrieval**. Prime-wheel exact enumeration is a verified auxiliary computational result and should not displace this. Route 1/structural-information, Q2/exponent-two, Paley sensitivity and the other open PRs remain preserved as valuable but **parked for new flagship discovery work**. Parking does not prohibit other collaborators from preserving sources, auditing CI, maintaining existing certifications, or completing explicitly authorized obligations.

**Evidence examined this session:** connected repository PRs #695, #699, #970, #980, #982, #990, #987/#988/#991/#992, canonical catalogue; local frangible-gap packet; the full frangible original paper arXiv:2610.34525v1 (including actual tables and constant formula); the 2025 *Phasebook* survey. Topological references in PR #699 and earlier discussion are relevant but a full independently sourced current literature audit of the precise continuous-feedback model remains **open**. Do not claim worldwide novelty or that no existing specialist theorem resolves the target.

## The single flagship theorem target

For n≥3, let \(m_{\mathrm{cont}}(n)\) denote the smallest m for which there exist continuous *causal* row-selection maps on the reachable previous-observation histories, with \(\|a_j\|_2\le1\), such that

\[
T(x)=(y_1,\dots,y_m),\qquad
y_j=(a_j(y_1,\dots,y_{j-1})\cdot x)^2
\]

is injective on \(\mathbb R^n/\{\pm1\}\) (for **all** real signals including support changes and x=0). All measurements are exact noiseless original-coordinate real squared-linear queries; decoding may be arbitrary but must use only the transcript. The **proposed all-n theorem**, presently a **CONJECTURE**, is

\[
\boxed{m_{\mathrm{cont}}(n)=2n-1.}
\]

A fixed full-spark frame gives the upper bound. An unrestricted exact but potentially discontinuous causal strategy achieves n+1 queries by merged kernel-certified [PR #695](https://github.com/d3lefts/d3lefts/pull/695). Merged kernel-certified [PR #699](https://github.com/d3lefts/d3lefts/pull/699) excludes **n fixed independent prefix measurements followed by ONE continuous adaptive row** for n≥3; it does **not** exclude arbitrary continuous m=n+1 adaptive policies. An invertible change of basis extends that obstruction to any fixed independent prefix, not to all causal prefixes.

The **primary decisive finite question** is

\[
\boxed{m_{\mathrm{cont}}(4)\stackrel{?}{=}7;\quad
\text{does a universal continuous six-reading strategy exist in }\mathbb R^4?}
\]

Either (i) an explicit universally correct six-reading continuous policy **falsifies** the all-n 2n−1 conjecture or (ii) a theorem forbidding all six-reading policies would show a four-dimensional cost not explained merely by abstract cone embeddability. A four-dimensional theorem alone is not the all-n headline; the desired follow-on is a reusable causal/quadratic obstruction that extends to a nontrivial dimension family.

## The topology comparator is the FULL cone, not only projective space

Every continuous policy produces a continuous sign-invariant transcript. Restriction to the compact unit-ball quotient gives an embedding of the *closed cone* \(C(\mathbb RP^{n-1})\) into \(\mathbb R^m\). Define its minimum embedding dimension \(e_{\mathrm{cone}}(n)\). Necessarily \(m_{\mathrm{cont}}(n)\ge e_{\mathrm{cone}}(n)\). The elementary bounds

\[
e(\mathbb RP^{n-1})\le e_{\mathrm{cone}}(n)
\le e(\mathbb RP^{n-1})+1
\]

come by restricting to the projective link and by the standard embedding \(([u],r)\mapsto(r i([u]),r)\). For n=3 the bracket is 4–5; for n=4 it is 5–6. **The full cone embeds in \(\mathbb R^6\) at n=4**, using the known embedding \(\mathbb RP^3\hookrightarrow\mathbb R^5\), so a proof of six-reading impossibility there must use more than the mere nonembeddability of the source space in \(\mathbb R^6\).

Caution: a continuous injection of the entire noncompact cone into Euclidean space is not automatically a topological embedding; use the compact subcone. Smooth/locally-flat normal Euler obstructions may exclude certain n=3 thickenings, but cannot be carried into arbitrary wild embeddings without a theorem. The n=3,m=4 experiment is **topology-prior-art calibration**, not the principal quadratic-causal opportunity.

## Ranked opportunities and observed blocking dependencies

| Priority | Research direction | Verified leverage | Concrete blocker | Decision |
|---|---|---|---|---|
| **1** | Continuous causal real phase retrieval, n=4 six versus seven | PR #695 exact n+1 versus 2n−1; PR #699 continuity obstruction, both Lean source-checked | All-continuous-causal lower bound or six-reading counterexample; cone-prior-art boundary | **SOLE FLAGSHIP** |
| 2 | Task-aware structural-information / Route 1 | Merged [#970](https://github.com/d3lefts/d3lefts/pull/970) Wyner-mixture simulation; draft [#990](https://github.com/d3lefts/d3lefts/pull/990) supplies adversarial degree-2 obstruction; #992 exact Simon degree 2/3 mismatch | No general noncircular task-relative transcript cost matching classical query complexity | Park new discovery spending |
| 3 | Exponent-two influence with polynomial degree dependence | Finite original-source Q2 theorem at C≈105.416 in canonical catalogue, extensive source machinery | Polynomial-in-degree bound and general infinite-source closure remain unresolved; v8 constants campaign closed | Park |
| 4 | Sensitivity/block sensitivity Paley improvement | Draft [#982](https://github.com/d3lefts/d3lefts/pull/982) exact 717/716 triple-neighborhood audits | No accepted stronger exponent; endpoint recurrence, full archive access and source integration missing | Park |
| 5 | Frangible wheel residue counting | The two exact algorithms here reproduce published h≤46, compute exact values h≤82, sharpen c lower to 2.7416104 | Mod-4 phenomenon lacks proof; original-paper comparison only, no specialist priority review | **Preserve as scoped auxiliary result** |

**Strategic judgment is conditional, not a probability estimate.** Phase retrieval wins on a clean falsifiable mathematical separation between accepted general topology and the additional claimed causal quadratic cost. It is not necessarily the most prestigious possible open problem; it has the best *testable novelty-to-effort profile* visible in this repository. A strong non-author referee could conclude the conjecture is already in the literature or false. Such a finding would revise this ranking.

## Next decisive experiment: budgeted and pre-registered

**Objective:** determine the n=4,m=6 feasibility question without assuming coordinate-first prefixes. Start with source-level prior art on continuous adaptive real intensity measurements and full-cone embeddings; distinguish smooth, locally flat and arbitrary continuous policies. Then work directly with six rows and observable histories. One initial tractable construction family may use two or three fixed independent rows followed by causal history-dependent rows, **but no-go in that subfamily does not prove the universal statement**. Test all zero-support strata and antipodal inequivalence; a generic-grid optimizer or approximate absence of collisions is *not a proof*.

**Hypotheses:**
- H1: A concrete six-reading continuous adaptive policy separates every sign class; then the all-n equality conjecture is false.
- H2: Causal quadratic measurements carry a new collision invariant beyond the cone topological baseline; prove a universal n=4 six-reading obstruction, then test generalization.
- H3: The only apparent obstruction comes from a fixed-prefix or imposed homogeneity restriction; then it does not address the proposed theorem.
- H4: Existing topology or phase-retrieval prior art already proves the n=4 result; correct novelty status immediately.

**Minimum honest checker:** explicit rows defined on all reachable histories, continuity arguments on support-boundary strata, symbolic collision equations for pairs x≠±y; independent implementation for finite candidate stress only. In the lower-bound direction, independently attack every assumption about reachability, continuity of the selected row, wild embeddings and zero entries. Lean integration comes **after** a nontrivial all-policy paper argument survives independent criticism. Strong source code and successful CI cannot substitute for a mathematical lower bound.

**Stop/reprioritize gate:** do not create many supporting PRs, run large optimizations, or polish constants before a small decisive construction or obstruction. Two failed architecture families must trigger a *change of mechanism*, not repeated parameter tuning. If specialist literature resolves the question, credit it and seek an explicitly stronger, fresh claim; do not defend a false novelty thesis. No external submission/publication without authorization.

## Prime-wheel archival result and maintenance discipline

The separate [frangible exact-count packet](frangible-gaps-20261122/README.md) contains the two algorithms, exact result JSON, source tables comparison, and directed-rounded arithmetic checker. The source [Mossinghoff–Trudgian (2026)](https://arxiv.org/abs/2610.34525) provides all definitions and baseline values. The 18 new exact computational entries and lower constant bound are **not a proved new distribution-of-primes law**. The modulo-four congruence is supported only over the tested range and has no all-h proof. One source-bound review cycle is justified; additional table extension alone is not a flagship pivot.

## Certification and status contract

- **Established:** PRs #695/#699 theorem statements in their formalized exact scopes; existing pinned CI; finite arithmetic of the frangible packet as separately replayed.
- **Author-level deductions:** all-n 2n−1 continuous conjecture, necessary cone baseline, the small finite-feasibility targets and the prime-wheel exact counting proof.
- **Not established:** universal continuous-feedback threshold, n=4 six-reading impossibility, n=3 wild cone obstruction, an original prime distribution law, any priority or specialist review.
- **Delivery rule:** report theorem statements with exact assumptions, source, limiting example/counterexample, checker, compiler/hash receipts where applicable, novelty and independent-review status separately.

**Research schedule:** until the n=4 experiment has a substantive mathematical outcome, allocate at least 80% of new creative research effort there; at most 10% to closing the prime packet and up to 10% to adversarial prior-art/source checks across the flagship. Existing repository maintenance continues outside the research prioritization.

**Revision control:** This is the 2026-11-22 selection checkpoint, not an immutable theorem. Record any future redirection with its newly found falsifier, independent audit or changed prior-art fact. Do not silently move flagship labels.
