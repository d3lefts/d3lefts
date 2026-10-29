# NIGHTFALL / Vesper — uniform fourth-power identifiability from direct pair collisions

**Date:** 2026-10-28 (America/New_York). **Research owner:** Devin J. Wright. **Derivation and independent proof audit:** Vesper (GPT-6). **Status:** self-contained elementary theorem with independent finite exact checker. **Priority:** unestablished; external mathematical review remains required. **Scope:** *information-theoretic uniqueness*, no polynomial-time decoding claim.

## Precise theorem

Let \(\mathbb F=\mathbb F_{25}\), \(k\ge 1\), \(s\ge1\) and \(m\ge \lceil 83k/24\rceil+s\). Choose each of the \(m\) rows \(a_j\in\mathbb F^k\) independently uniformly, with replacement; reveal \(A\) to the observer. Consider

\[
\Phi_A(x)=((a_1\cdot x)^4,\ldots,(a_m\cdot x)^4),\qquad x\in\mathbb F^k.
\]

Write \(\mu_4=\{\omega\in\mathbb F^\times:\omega^4=1\}\); in characteristic five \(\mu_4=\mathbb F_5^\times\) and \(|\mu_4|=4\).

**Theorem.** With probability strictly greater than \(1-5^{-s}\) over a **single** random \(A\), simultaneously for all \(x,x'\in\mathbb F^k\),

\[
\Phi_A(x)=\Phi_A(x')\quad\Longleftrightarrow\quad x'=\omega x
\quad\text{for some }\omega\in\mu_4.
\]

The zero signal forms a singleton orbit. A deterministic brute-force decoder that enumerates all \(25^k\) signals and returns the matching \(\mu_4\)-orbit is correct under this event; its worst-case running time is exponential in \(k\).

**Comparison within NIGHTFALL:** Axiom's latest rank-stratified Frobenius-kernel theorem (draft PR #16) guarantees a one-dimensional lifted kernel and a polynomial-time decoder under the same iid F25 observation law with \(m\ge\lceil(149/38)k\rceil+s\), i.e. a sufficient leading coefficient \(\approx3.9211\) (improved from an earlier \(5.882\)). The new \(\lceil(83/24)k\rceil+s\) uniqueness-only count uses approximately **11.8% fewer leading measurements** than Axiom's latest efficient-decoder sufficient count, while proving a strictly weaker computational guarantee. It neither improves the proven *efficient-decoding guarantee* nor establishes same-scope external publication priority. The older systematic 2k large-field LLL method uses a different ensemble and field-size regime.

## Exact counting proof

Set \(q=25\), \(\rho=(1+4(q-1))/q^2=97/625\).

**Rank-deficient designs.** If \(A\) has a nonzero kernel vector, it kills the entire one-dimensional \(\mathbb F\)-line containing that vector. There are \(L_k=(q^k-1)/(q-1)\) such lines, and any fixed nonzero line is killed by all rows with probability \(q^{-m}\). Hence

\[
\Pr[\operatorname{rank}A<k]\le L_k\,q^{-m}.
\]

For a full-rank \(A\), two proportional nonzero signals \(x'=\lambda x\) have identical fourth powers only if \(\lambda^4=1\), because some \(a_j\cdot x\ne0\). Also \(\Phi_A(x)=0\) forces \(x=0\).

**Independent pairs.** For any linearly independent \(x,x'\), the map \(a\mapsto(a\cdot x,a\cdot x')\) is surjective onto \(\mathbb F^2\), so a single row gives a uniformly distributed pair \((u,v)\). The equation \(u^4=v^4\) has exactly one zero pair \((0,0)\), and for each of the \(q-1\) nonzero \(u\) precisely four choices \(v=\omega u\). Thus the one-row collision probability is exactly \(\rho=97/625\); over \(m\) independent rows it is \(\rho^m\).

The equality event depends only on the unordered pair of nonzero \(\mu_4\)-orbits, and each linearly independent ordered pair belongs to an orbit of size \(2\cdot4^2=32\) under separate phases and swapping. Thus the **exact number** of unordered independent phase-orbit pairs is

\[
P_k=\frac{(q^k-1)(q^k-q)}{32}.
\]

For \(k=1\), \(P_k=0\). Union bounding the genuinely different independent pairs, along with rank deficiency, yields the explicit **all-dimensions, all-signal** estimate

\[
\boxed{\Pr[\text{non-phase ambiguity}]
\le \frac{q^k-1}{q-1}\,q^{-m}
 + \frac{(q^k-1)(q^k-q)}{32}\left(\frac{97}{625}\right)^m.}\tag{*}
\]

This bound is valid for every \(m,k\), without assuming the terms independent.

**Sharper sample count.** Let c=83/24≈3.458333, and B=q²ρ^c. The exact integer inequality

\[
97^{83}<625^{59}
\]

implies \(B^{24}=97^{83}/625^{59}<1\). Since \(\rho=97/625<1/5\), for every \(m\ge\lceil c k\rceil+s\),

\[
P_k\rho^m<
\frac{1}{32}\,(q^2\rho^c)^k\rho^s
<
\frac{1}{32}5^{-s}.
\]

Since \(c>3\), the rank-deficient term satisfies

\[
L_kq^{-m}<
\frac{q^{(1-c)k}}{q-1}q^{-s}
<
\frac{1}{24q^2}5^{-s}
=\frac{1}{15000}5^{-s}.
\]

Thus the sum in \((*)\) is strictly below \((1/32+1/15000)5^{-s}<5^{-s}\), proving the new rational-coefficient theorem. The earlier \(m\ge\lceil 7k/2\rceil+s\) follows as a weaker corollary.

**Exact limiting coefficient.** The identical proof works for

\[
m\ge \lceil c_* k\rceil+s,\quad
c_*=\frac{2\log25}{\log(625/97)}\approx3.4555078421748546.
\]

At \(c=c_*\), \(q^2\rho^c=1\); the fixed finite prefactors and \(\rho^s<5^{-s}\) still give a strict failure bound. The rational \(83/24>c_*\) gives an elementary integer-power certificate without reliance on floating-point logarithms. Neither coefficient is a necessary bound for identifiability: both describe sufficient measurements under this particular union argument. The decoder remains exponential-time in k.

## Reproduction and independent proof checks

Run:

\`\`\`bash
python3 research/nightfall/projects/f25-pairwise-identifiability-20261028/verify_pair_collision.py
node scripts/test_f25_pair_collision.cjs
\`\`\`

The Python checker uses the separate field realization \(\mathbb F_5[u]/(u^2-2)\) and exact integer/rational arithmetic. It explicitly counts all \(625\) possible \((u,v)\), verifies \(97\) one-row collisions, enumerates all \(625\) two-coordinate signals for deterministic eight-row designs, checks no non-phase collisions in an accepted design, and confirms failure of the coordinate-only and zero-row controls. It tests \((*)\) for multiple \(k,s\) and the exact rational inequality \(97^{83}<625^{59}\), alongside the original \(97^7<5^{20}\) control.

The independent Node checker uses **only** the arithmetic API already on the website in \`docs/research-tools-core.js\`, cross-checks field power and full pair-collision enumeration, and independently verifies the combinatorial pair count. The mathematical proof does not depend on either test.

**Adversarial boundaries:** (1) a kernel deficiency is a sufficient reason for a zero ambiguity, (2) multiplying by \(\mu_4\) never changes outputs and is intentionally an allowed equivalence, (3) a large lifted kernel need not create a second nonphase signal, (4) exact pair counts and a union bound prove injectivity but give no efficient inverse, and (5) finite tests do not validate an asymptotic theorem in isolation.

## Publication priority and source comparisons

- Axiom fixed-F25 iid kernel theorem and checker: [draft PR #16](https://github.com/d3lefts/d3lefts/pull/16).
- Prior literature on conventional **real/complex magnitude** phase retrieval examines different observation maps and ensembles (e.g. Bandeira–Cahill–Mixon–Nelson, *Saving Phase*, 2014; Liu–Krahmer, *Phase Retrieval Without Small-Ball Probability Assumptions*, 2017/18).
- The direct pair-collision proof is elementary enough that its originality requires a dedicated **same-field, same-fourth-power observation law** literature search. No universal novelty, record, practical decoding performance, or expert acceptance is asserted.

**Next Axiom handoff:** determine whether an efficient decoder can achieve this smaller measurement regime (a stronger open task), and whether the pairwise collision events admit a sharper uniform first-moment quotient. **Next Lemnis transfer test:** compare phase-orbit quotient counting with the conserved-grade Werner support orbit framework without asserting that either positivity theorem follows from the other.
