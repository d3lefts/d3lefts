# A Universal Quadratic Variance–Influence Inequality for Bounded Degree-Two Functions on Finite Product Spaces

**Author:** Devin J. Wright — NIGHTFALL research program  
**Version:** 1.0 / 15 November 2026 UTC  
**Status:** author-review mathematical preprint; no arXiv deposit, DOI, or journal acceptance asserted.  
**Source authority:** strict Lean 4.36.0-rc2, named declaration, source-specific dependencies.

This is the repository entrypoint for the nine-page LaTeX/PDF preprint prepared for deposit. The PDF, editable LaTeX, and `CITATION.bib` are included in the preprint handoff package. This draft PR does **not** represent an arXiv/Zenodo submission or final author publication approval.

## Main theorem — original-source unrestricted Q2, machine verified

Let (I) be any finite coordinate set, (A) a nonempty finite *common* alphabet, and (p_i:A\to[0,1]) independent normalized coordinate laws, possibly heterogeneous and with zero atoms. For every bounded real (f:A^I\to\mathbb R) whose original-(p) canonical Efron–Stein degree is at most two, define

\[
V=\operatorname{Var}_p(f),\qquad
M=\max_i \mathbb E_{X_{-i}}\operatorname{Var}_{X_i}\left(f(X)\mid X_{-i}\right).
\]

If (|f(x)|\le B) **pointwise on every configuration**, then

\[
\boxed{
V^2\le
\left[2\sqrt3(1+\sqrt2)+\frac{48}{25}\right]^2 B^2 M
=105.741756923658\ldots\,B^2M.
}
\]

No zero-singleton, minimum-atom, equal-bias, or extra caller-supplied probabilistic premise is used. The available Lean statement uses a common finite alphabet type; arbitrary coordinate-specific alphabet *types*, dependent laws, general degrees, and infinite products are not claimed as formally established here.

**Exact proof certificate:**

- Named theorem: `Nightfall.Observability.ActualSourceQ2105Terminal.actual_source_q2_105_unconditional`
- Original source module: `research/nightfall/formalization/observability/ActualSourceQ2105Terminal.lean`
- Exact verified PR head: `ae8ebec96d6c3ce4a25fb42bc7ae6ba170ca9103` on [PR #564](https://github.com/d3lefts/d3lefts/pull/564)
- [Direct original-source Lean receipt: PASS](https://github.com/d3lefts/d3lefts/actions/runs/43671321904), job 132681787993
- [Consolidated strict Lean receipt: PASS](https://github.com/d3lefts/d3lefts/actions/runs/43671321751)
- [Immutable direct audit artifact 14144552078](https://github.com/d3lefts/d3lefts/actions/runs/43671321904/artifacts/14144552078)
- Artifact SHA-256: `b3834d1b807567341c3554c20e8f548189386e61f852b95ae49cd7e5c72c5411`.
- The named declaration's audit reports only `Classical.choice`, `Quot.sound`, `propext`; no `sorryAx`.

## Inspectable proof mechanism

The proof is not a scalar theorem with external inequalities appended as assumptions. All quantities derive from the **same original source** ((p,f)).

1. **ANOVA identities.** Write (f=m+\sum_i h_i+\sum_{i<j}h_{ij}) and (I_i=\|h_i\|_2^2+\sum_{j\ne i}\|h_{ij}\|_2^2).
2. **Pair ownership.** The source-rectangle and matching argument yields costs (c_i\ge0) with (\sum_i c_i\le8B); each pairwise interaction is owned exactly once and bounded by its owner's cost. Distinct owned neighbors preserve independence.
3. **Sharp original-source sections.** Bernoulli switching plus weighted Popoviciu gives (\sum_i \mathbb E\,\sqrt{\operatorname{Var}_{X_i}(f\mid X_{-i})}\le2(1+\sqrt2)B).
4. **Shifted independent Hilbert lemma.** For an arbitrary deterministic shift and independent centered finite-valued increments (Y_j) with (\|Y_j\|\le c), let (e=\mathbb E\|h+\sum Y_j\|^2), (u=\mathbb E\|h+\sum Y_j\|). The Lean-checked exact ten-rectangle rational Bernstein inequality and moment identities give (\sqrt e\le\sqrt3u+6c/25).
5. **Actual-source composition.** Owned energies (e_i) partition (V), satisfy (e_i\le I_i\le M), and have first norms (u_i) bounded by the source sections. Hence
   \[
   V=\sum_i e_i\le\sqrt M\sum_i(\sqrt3u_i+6c_i/25)
   \le\sqrt M\,B[2\sqrt3(1+\sqrt2)+48/25].
   \]
   Squaring yields the theorem.

## Sharpness information: K is at least 4

For even (n), independent biased signs (mathbb E X_i=1/\sqrt2), and
(Q_n=\sum_{i<j}X_iX_j), subtract the midrange to obtain the pointwise bound (B_n=n^2/4). Exact formulas:

\[
\operatorname{Var}(Q_n)=\frac{n(n-1)(2n-1)}8,\qquad
I_i(Q_n)=\frac{n(n-1)}4.
\]

Therefore
\[
\frac{\operatorname{Var}(Q_n)^2}{B_n^2\max_i I_i(Q_n)}
=\frac{(n-1)(2n-1)^2}{n^3}\longrightarrow4.
\]
Thus (4\le K_*\le105.741756923658\ldots). The equality (K_*=4) is **not** established.

## Conditional route to 96.5735201305411

**Open, not certified:** Prove for all independently sampled centered finite Hilbert vectors (Y_j), each (\|Y_j\|\le c), and arbitrary shift (h) that

\[
e=\mathbb E\|h+\sum Y_j\|^2\le2u^2+cu,\qquad
u=\mathbb E\|h+\sum Y_j\|.
\]

Then (\beta=(\sqrt3-1)/4) satisfies the exact SOS
\[
(\sqrt3u+\beta c)^2-(2u^2+cu)=(u-\beta c)^2\ge0,
\]
so the existing source-owner and section lemmas would give
\[
K\le4(\sqrt6+2\sqrt3-1)^2=96.5735201305411\ldots .
\]
The **scalar SOS implication** is checked, but the unrestricted **law-level inequality** is not. The Jensen+fourth+Hölder pseudo-moment obstruction in [PR #563](https://github.com/d3lefts/d3lefts/pull/563) eliminates that particular proof relaxation, not the actual conjecture. A new direct original-source probabilistic argument is required. [Parallel-instance handoff](https://github.com/d3lefts/d3lefts/pull/564#issuecomment-6888660109) gives an exact one-sided scalar subcase and adversarial tests.

## Related work, attribution, publication limits

The variance-exponent-two phenomenon for **uniform Boolean inputs** precedes NIGHTFALL; in particular, Filmus–Hatami–Keller–Lifshitz (2014) implies a same-normalization uniform-cube (K\le32) corollary. The claimed contribution is the *simultaneous arbitrary finite product-law, zero-atom, nonzero-singleton, dimension-free degree-two theorem*, not the invention of influence inequalities. See [merged adversarial priority dossier #550](https://github.com/d3lefts/d3lefts/pull/550), and compare Turturean [arXiv:2611.09773](https://arxiv.org/abs/2611.09773) and Girish et al. [arXiv:2609.35327](https://arxiv.org/abs/2609.35327).

Research direction and named authorship: **Devin J. Wright**. AI systems assisted derivations, experiments, review, and Lean proof engineering. No independent human-referee or publication approval is represented. Reconcile this draft with the downloadable preprint PDF and source before a public archival deposit. **Do not add a DOI or arXiv identifier unless an actual deposit returns it.**

### Provisional repository citation

> Devin J. Wright, *A Universal Quadratic Variance–Influence Inequality for Bounded Degree-Two Functions on Finite Product Spaces*, NIGHTFALL mathematical preprint, version 1.0, 15 Nov. 2026. Formal theorem at exact commit [ae8ebec96d6c](https://github.com/d3lefts/d3lefts/commit/ae8ebec96d6c3ce4a25fb42bc7ae6ba170ca9103); source-checked Lean 4.36.0-rc2 receipt [43671321904](https://github.com/d3lefts/d3lefts/actions/runs/43671321904). Not peer-reviewed or deposited.

**Release gate:** full LaTeX/PDF source in immutable archive, author approval, DOI/arXiv identifier if actually assigned, paper/source hash ledger, independent adversarial mathematics review, and no unrestricted C96 promotion without a separate successful source-level Lean gate.
