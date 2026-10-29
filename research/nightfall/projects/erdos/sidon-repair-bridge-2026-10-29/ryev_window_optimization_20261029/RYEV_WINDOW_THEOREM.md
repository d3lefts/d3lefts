# RYEV / Optimized two-endpoint Sidon extension window

**Date:** 2026-10-29. **Program lead:** Devin J. Wright. **Research contribution:** Ryev (parameter optimization and separate exact-rational checker) building on Axiom's fixed-prefix block-and-translation mechanism in [draft PR #62](https://github.com/d3lefts/d3lefts/pull/62). **Own assignment:** [issue #81](https://github.com/d3lefts/d3lefts/issues/81).

**Status:** internal theorem-strengthening and separately coded arithmetic audit; independent human mathematical review and same-scope historical priority OPEN. There is **no** claim of improved infinite Sidon limsup, a record finite set, or a solution of Erdős #44/#329.

## The precise stronger coefficient

Let \(A\subset\mathbb N\) be any fixed, nonempty, finite integer Sidon set, where repeated-element unordered sums must be distinct, and put \(r=|A|\ge1\).

For every sufficiently large prime \(q\), a translated-and-trimmed Bose–Chowla block extends \(A\) into a finite Sidon set \(U_q\) such that \(\max U_q\to\infty\) and

\[
\liminf_{q\to\infty}\frac{|U_q|}{\sqrt{\max U_q}}
\ge
\boxed{\widetilde C_r=\frac{1-\frac{1}{256r}}{\sqrt{2-\frac1{32r}}}}.
\]

Moreover, for **every** integer \(r\ge1\),

\[
\widetilde C_r>
C_r^{\rm Axiom}=
\frac{1-\frac2{675r}}{\sqrt{2-\frac1{40r}}}
>\frac1{\sqrt2}.
\]

The stronger coefficient comes from optimizing a two-parameter translation window. It uses the **same** Bose–Chowla block, exact collision classes, frozen finite prefix, and deterministic rotation/deletion construction as Axiom; the gain is in an analytic parameter optimization.

### Explicit finite deletion bound

Write \(L=q^2-1\), \(N=\max A\) and introduce two independently selectable endpoint parameters

\[
\alpha_r=\frac{3}{64r},\qquad
\beta_r=\frac1{32r},\qquad 0<\beta_r<\alpha_r.
\]

Let \(J=\lceil\alpha_r L\rceil+N+2\), let

\[
I=[\lceil(1-\alpha_r)L\rceil,\ \lfloor(1-\beta_r)L\rfloor]\cap\mathbb Z,
\quad
W=\frac{q(2J+1)}L .
\]

For sufficiently large \(q\), the interval is nonempty, \(2J+1\le L\), and \(T>2N\) for every \(T\in I\). A cyclic rotation of a Bose–Chowla \(q\)-point modular Sidon block has endpoint populations \(v,h\) satisfying \(v+h\le W\). Then some \(T\in I\) admits deletions \(R\) of at most

\[
|R|\le \binom r2+\frac r{|I|}
\left(\frac{2W^3}{27}+\frac{W^2}{8}\right).
\]

The remaining translated block plus \(A\) is integer Sidon, and its maximum is at most \((2-\beta_r)L\).

### Complete proof of the optimization

1. **Same exact finite mechanism.** For a \(q\)-point Sidon block \(S\subset[0,L-1]\), a cyclic rotation gives \(v+h\le W\) by averaging endpoint occupancy. For \(T\in I\), any cross-type equality

   \[
   a+(T+s_h)=(T+s_i)+(T+s_j)
   \]

   forces \(s_h\in[L-J,L-1]\) and \(s_i,s_j\in[0,J]\): rearrange \(T=a+s_h-s_i-s_j\); since \(T\ge(1-\alpha_r)L\), \(s_h\ge T-N\ge L-J\). Since \(T\ge(1-\alpha_r)L\) and \(s_h<L\), \(s_i+s_j=a+s_h-T<\alpha_r L+N<J\). This includes diagonal pairs \(s_i=s_j\).

2. **Average over translation.** Each old \(a\), high \(s_h\), and unordered low pair \(\{s_i,s_j\}\) fixes at most one integer \(T\). The mean number of bad triples is no greater than \(r h v(v+1)/(2|I|)\). Choose a \(T\) no worse than this mean and delete one high block element for each collision. The deterministic counting bound holds because

   \[
   hv^2\le\frac{4W^3}{27},\quad hv\le\frac{W^2}{4},
   \quad v+h\le W.
   \]

   Cross-collisions between two old marks and two distinct translated marks are subsequently removed at cost at most \(\binom r2\) using the unique ordered difference property of cyclic Sidon sets. Because \(q\to\infty\) with \(A\) fixed, the disjoint band assumptions hold for all sufficiently large \(q\).

3. **Compute the limiting loss.** Since \(J=\alpha_r L+O_A(1)\) and \(|I|=(\alpha_r-\beta_r)L+O(1)\),

   \[
   W=(2\alpha_r+o(1))q,\qquad
   \frac{|R|}{q}
   \le \frac{16}{27}\frac{r\alpha_r^3}{\alpha_r-\beta_r}+o(1).
   \]

   Substituting \(\alpha_r=3/(64r)\), \(\beta_r=1/(32r)\) gives **exactly** \(1/(256r)\). Meanwhile \(\max U_q\le (2-\beta_r)L\) and \(q/\sqrt L\to1\). The displayed \(\widetilde C_r\) follows.

4. **Prove strict improvement by integer polynomials.** The exact difference of squared coefficients is

   \[
   \widetilde C_r^2-(C_r^{\rm Axiom})^2=
   \frac{591667200r^2+5514896r-25589}
        {186624000\,r(64r-1)(80r-1)}.
   \]

   Its denominator is positive for \(r\ge1\); the numerator is already positive at \(r=1\) and strictly increases. Independently,

   \[
   2\left(1-\frac1{256r}\right)^2-\left(2-\frac1{32r}\right)
    =\frac1{64r}+\frac1{32768r^2}>0,
   \]

   proving \(\widetilde C_r>1/\sqrt2\). All identities are checked through exact polynomial arithmetic and fractions in \`check_window.py\`.

### Why these parameters?

Write \(\alpha=a/r\), \(\beta=b/r\) with \(0<b<a\). The **first-order large-\(r\) squared-coefficient advantage above \(1/2\)** is

\[
\frac1r\left(\frac b4-\frac{16a^3}{27(a-b)}\right)+O(r^{-2}).
\]

Put \(b=ta\), \(0<t<1\). For each \(t\), this concave quadratic is maximized at \(a=27t(1-t)/128\). The remaining factor \(t^2(1-t)\) is largest at \(t=2/3\). Therefore \(a=3/64\) and \(b=1/32\) maximize the **leading \(1/r\) coefficient within Axiom's cubic endpoint-loss proxy**. This does not assert global optimality of finite-prefix Sidon constructions or exact finite-\(r\) parameter optimality outside that proxy.

## Separate independent finite-source audit

The same script reads Axiom's published \`certificate_p1009_delta027.json\`, without invoking Axiom's builder or verifier, and checks:

- exactly 1,001 sorted positive integer coordinates, preserving \(\{1,2,4,8,13\}\);
- exactly 501,501 unique unordered pair sums and 500,500 positive differences;
- \(M=1,890,093\), coordinate SHA-256 and \(2|U|^2-M=113,909>0\);
- a deliberately bad insertion at \(M-1\), which forces \(1+M=2+(M-1)\).

**Boundary:** This 1,001-mark integer witness uses **Axiom's exploratory \(\delta=0.27\)**, not the new conservative \(\alpha_r\) window. It independently corroborates the finite certificate only. It is **not** a witness for the new asymptotic constant and **not** the strongest current same-prefix ratio: Axiom's later 977-mark PR #73 attains a larger normalized finite ratio at a smaller endpoint.

## Reproduction and review gates

\`\`\`bash
python3 research/nightfall/projects/erdos/sidon-repair-bridge-2026-10-29/ryev_window_optimization_20261029/check_window.py
\`\`\`

The checker is Python 3 standard library only, with no floating-point value used to decide the theorem. Its negative test is mandatory. CI is attached to the draft review PR.

**Requested independent attacks:** Lemnis should challenge all cross-collision bands and the two-parameter floor/ceiling accounting. Axiom should check this coefficient against the original construction and test the first-order optimizing argument. Vesper should perform a dated same-model priority scan before any Original Findings status or published novel theorem claim. Neither this coefficient nor the internal finite sample improves the established **infinite-sequence** lower bound \(1/\sqrt2\) associated with Krückeberg (1961), as summarized by [Erdős #329](https://www.erdosproblems.com/329).
