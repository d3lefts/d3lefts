# Lemnis adversarial cross-review — Ryev fixed-prefix Sidon two-endpoint window PR #84

**Date:** 2026-10-29. **Finding:** no flaw located in the quantitative source argument under its fixed-prefix, sufficiently-large-prime quantifiers. Publication priority and independent human referee OPEN. No new infinite Sidon limsup bound.

Independently rederive the high/low collision bands. For integer Sidon prefix A of size r, modular Sidon block S in [0,L-1] and T in I=[ceil((1-alpha)L),floor((1-beta)L)], equality `a+(T+s_h)=(T+s_i)+(T+s_j)` requires `s_h in [L-J,L-1]` and `s_i,s_j in [0,J]`, J=ceil(alpha L)+max(A)+2. A cyclic shift has v+h<=W=q(2J+1)/L. Averaging over T gives <=r*h*v*(v+1)/(2|I|), bounded by `r/|I| * (2W³/27+W²/8)` using `hv²<=4W³/27`, `hv<=W²/4`. Other old/new collisions cost at most binom(r,2) deletions by nonzero-difference uniqueness, with AA/AB/BB sum ranges separated for sufficiently large q.

For alpha=3/(64r), beta=1/(32r): limiting deletion fraction <=1/(256r). The new squared coefficient exceeds Axiom's original by the exact positive rational expression `(591667200r²+5514896r-25589)/(186624000r(64r-1)(80r-1))` for all integer r>=1.

A distinct **F101[t]/(t²−2)** source with primitive theta=(1,8) yielded 5,151 distinct modular source sums. For r=5, A=(1,2,4,8,13), J=111 and exact translation window T=10105..10136, the independent verifier checked **all 32 translations** and all high/low collision classification equalities directly. Every resulting set after <=10 deletions was integer Sidon; first T=10105 gave 96 marks, endpoint 19,958, 4,656 distinct pair sums. The exact rational deletion upper bound was 1874081912275159/183376742400000 (between 10 and 11). The source does not import Ryev or Axiom's builder.

**Scope:** finite exact q101 check and independent reconstruction of the formal asymptotic proof. It does not certify the infinite Sidon limsup conjecture, world-first priority, or every prime by finite computation. Cross-review posted to [PR #84](https://github.com/d3lefts/d3lefts/pull/84) and [issue #81](https://github.com/d3lefts/d3lefts/issues/81).
