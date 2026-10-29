# Vesper / NIGHTFALL — a sharp boundary-retreat obstruction for nested Sidon certificates

**Date:** 2026-10-29. **Owner:** Devin J. Wright. **Investigator:** Vesper.  
**Standing assignment:** [#96](https://github.com/d3lefts/d3lefts/issues/96). **Independent background:** Axiom [PR #62](https://github.com/d3lefts/d3lefts/pull/62) and Ryev [PR #89](https://github.com/d3lefts/d3lefts/pull/89).  
**Status:** elementary *method-specific* mathematical deduction with exact computer audit; mathematical originality and external referee open. No new infinite Sidon bound, no resolution of Erdős #44 or #329.

## Target and strongest baseline

For a finite Sidon prefix `A`, let `r=|A|`. The Bose–Chowla/Singer translation-and-deletion method has the sufficient asymptotic **certificate** (Axiom/Ryev's two-window bound)

\[
G_r(\alpha,\beta)=
\frac{1-\frac{16r}{27}\frac{\alpha^3}{\alpha-\beta}}{\sqrt{2-\beta}},
\qquad 0<\beta<\alpha\le\tfrac14.
\]

Here `α` is the low/high boundary width, `β` is the reduction in the maximum endpoint, and the numerator represents the certified retained block fraction. The coefficient describes **arbitrarily large finite extensions for each *fixed* A**, with the source size tending to infinity *after* A and the parameters are fixed. A positive numerator is required for any useful density guarantee. Ryev PR #89 optimizes this same proxy exactly in the unrestricted two-window parameters; the optimizer is inherited, **not independently claimed as Vesper's novelty**.

The classical infinite-Sidon benchmark is `1/sqrt(2)` (Krückeberg 1961); the optimal infinite coefficient is open. The present note examines what conclusions the *proxy inequalities alone* support when prefixes grow in a nested construction.

## The new boundary-retreat deduction (within the specified proxy)

**Proposition — forced endpoint retreat.** For every integer `r>=1` and every `0<β<α≤1/4`, if the *certificate* `G_r(α,β)` exceeds `1/sqrt(2)`, then

\[
\boxed{\beta<\frac1{8r}},\qquad
\boxed{G_r(\alpha,\beta)<\frac1{\sqrt{2-1/(8r)}}}.
\]

The second inequality also bounds every positive-numerator certificate that does **not** exceed the classical baseline, since its right-hand side is strictly larger than `1/sqrt(2)`.

**Proof.** For a fixed `β>0`, elementary differentiation shows
\[
\frac{\alpha^3}{\alpha-\beta}\ge\frac{27}{4}\beta^2
\]
for every `α>β`; equality occurs at `α=3β/2` when admissible. Hence the deletion-loss factor
\[
d=\frac{16r}{27}\frac{\alpha^3}{\alpha-\beta}\ge4r\beta^2.
\]
If `G_r>1/sqrt(2)`, then `1-d>\sqrt{1-\beta/2}`; therefore
\[
4r\beta^2\le d<1-\sqrt{1-\beta/2}
=\frac{\beta/2}{1+\sqrt{1-\beta/2}}<\frac\beta2.
\]
Cancelling `β>0` gives `β<1/(8r)`. Also `1-d<1`, so
\[
G_r<\frac1{\sqrt{2-\beta}}<
\frac1{\sqrt{2-1/(8r)}}.
\]
If `G_r≤1/sqrt(2)`, the same upper envelope holds trivially. QED.

**Concrete finite-horizon consequence.** Fix a desired infinite advantage `c>1/sqrt(2)`. Every stage that claims `G_r≥c` must have
\[
\boxed{r <\frac1{8(2-c^{-2})}}.
\]
Thus, after a finite prefix-size threshold, **no choice of α and β in this proof method certifies coefficient c**. This is a ceiling on the *proven sufficient lower estimate*, **not an upper bound** on the actual Sidon set density; the constructed sets may perform better than their conservative deletion estimates. The sharper exact optimum was already established by Ryev (#89).

## Quantifier transfer audit

Assume only that for each fixed finite Sidon `A`, arbitrarily large *finite* extensions `U` exist with
\[
\frac{|U|}{\sqrt{\max U}}\ge g(|A|)-o_A(1),
\quad g(r)>b:=1/\sqrt2,\quad
g(r)\to b.
\]
By recursively fixing the current finite prefix and then choosing the next source parameter large enough, one obtains an increasing sequence of finite Sidon sets and therefore an infinite Sidon union `S`, with selected-stage lower estimates approaching `b`. This proves `\limsup S(N)/\sqrt N\ge b`, **not** a strict gain. Nothing in the inequalities alone guarantees that the *actual* stage densities have a uniform excess.

The gap is genuine at the level of abstract numeric assertions. Consider a non-Sidon **endpoint/count oracle**: from any positive integer state `r`, allow arbitrary large integer `n` and set the successor state
\[
r'=\Big\lfloor n\sqrt{\tfrac12+\frac1{512r}}\Big\rfloor,\qquad M'=n^2.
\]
Choose `n\gg r` so `r'>r` and `r'/\sqrt{M'}>b`. Every state has arbitrarily large strictly superbaseline successors. Along **every** infinite sequence of these transitions with increasing endpoints, `r\to\infty` and
\[
r'/\sqrt{M'}=\sqrt{\tfrac12+\frac1{512r}}+O(1/n)\to b.
\]
This is a countermodel to deriving a fixed positive gain from *scalar scores alone*. It is deliberately **not** a Sidon construction and makes **no claim** about density between the selected endpoints. It demonstrates which logical inference requires additional arithmetic structure.

## A precise conditional theorem that would actually transfer

**Invariant-core transfer criterion (elementary, known-style induction).** Fix constants `0<η<δ<1/4`, `λ≥0`, and suppose
\[
c_0=\frac{1-\lambda}{\sqrt{2-\eta}}>b.
\]
Suppose a nonempty, **self-reproducing class** `\mathcal C` of finite integer Sidon prefixes has the following property:

For every `A∈\mathcal C`, every `H>0`, and every `\varepsilon>0`, there exists a finite Sidon extension `U∈\mathcal C` with `A⊂U`, `\max U>H`, and
\[
\frac{|U|}{\sqrt{\max U}}\ge c_0-\varepsilon.
\]
Then an infinite Sidon union `S` satisfies `\limsup_{N\to\infty}|S\cap[1,N]|/\sqrt N\ge c_0>b`. Choose each next extension inside `\mathcal C` with \(H\) increasing and \(\varepsilon\to0\); the union is Sidon because any finite forbidden additive collision already lies in one finite stage.

A **potentially more tractable sufficient construction target** is to prove an invariant class of Singer/Bose–Chowla block prefixes for which, at arbitrary source size, a translated block fits the same fixed endpoint retreat `η` while total deletions cost at most `(λ+o_A(1))q`, with `λ` independent of the *growing* prefix cardinality `r`. One may allow an `O(r^2)` additive cost from mixed-versus-mixed differences by choosing `q\gg r^2` at each stage. Current proofs instead supply an `r δ²q` loss, obstructing constant `δ,η` via the proposition above.

This conditional criterion is a standard inductive implication, not a claimed new theorem. **Its scientific value is a precisely measurable missing premise:** a *self-reproducing structured class* may suffice; one need not prove a uniform gain for **all** arbitrary finite prefixes. Establishing such a closed family with fixed positive gain would be a genuine new #329 advance, subject to external proof and priority review.

## Reproduce and adversarial controls

```sh
python3 research/nightfall/agent-reports/vesper_sidon_transfer_20261029/verify_ceiling.py
```

The standard-library script verifies the analytic proxy inequalities over a rational grid with **126,400 exact parameter cases** (all fractions, no floats); exercises six abstract-oracle stages using integer square roots; and rejects a fixed-width, arbitrarily-large-prefix spoof. The global proof above is symbolic; finite grid testing is a regression check, not a substitute.

## Research decisions and new assignments

- **Vesper #96:** exact negative result about the *current family of sufficient certificates*, with a sharply stated route to an actual infinite result. Continue only toward a nontrivial invariant core or an arithmetic no-go theorem for a mathematically defined family; do not count this elementary transfer analysis as a breakthrough meeting the issue's final significance gate.
- **Axiom #49:** derive a class-closed operator with total boundary collision losses `o(rq)`, ideally a uniform `O(q)` bound independent of prefix size inside a structured recursively generated class. Record failure modes when the class is not preserved.
- **Tessera #95:** test Singer repair hypergraphs on *previously constructed Singer prefixes*, rather than arbitrary unrelated prefixes. Prove a uniform cover/packing bound or construct a growing-prefix adversarial sequence with unavoidable linear-in-r loss.
- **Lemnis:** attack invariant-class closure, old/new/new collision exhaustion, and the logical separation between certified lower coefficients and actual possible densities.
- **Ryev:** cross-check this bound against PR #89's exact optimum and build an independent two-block oracle; no synthetic count oracle can be described as Sidon evidence.

**Related external baseline:** [Erdős #44](https://www.erdosproblems.com/44), [#329](https://www.erdosproblems.com/329). External originality is open. **No homepage theorem or record promotion.**
