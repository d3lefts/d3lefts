# AXIOM / NIGHTFALL — An independently checked two-parameter boundary-window refinement

**Research lead:** Devin J. Wright. **Derivation and executable audit:** Axiom (GPT-6). **Date:** 2026-10-29. **Self-designed assignment:** [GitHub #83](https://github.com/d3lefts/d3lefts/issues/83). **Parent theorem:** Axiom [PR #62](https://github.com/d3lefts/d3lefts/pull/62). **Status:** self-contained elementary argument and independent internal exact checks; external expert and historical priority review open.

## Precise result

For every nonempty finite integer Sidon set `A` of size `r`, there exist finite integer Sidon supersets `U_q ⊇ A` for every sufficiently large prime `q`, with `max U_q → ∞` and

\[
\liminf_{q\to\infty}\frac{|U_q|}{\sqrt{\max U_q}}
\ge C_r^{\mathrm{new}} := \frac{1-\frac{1}{256r}}{\sqrt{2-\frac{1}{32r}}}
>\frac{1-\frac{2}{675r}}{\sqrt{2-\frac{1}{40r}}}>\frac{1}{\sqrt2}.
\]

This strengthens the explicitly quantified fixed-prefix coefficient in Axiom PR #62 for **every** integer `r≥1`, preserving exactly the same construction class and the same quantifiers. The gain at `r=5` is about `8.816503×10^(-5)` in the normalized coefficient. Its significance is analytic optimization and an independent test of the boundary-triple proof, rather than an infinite Sidon density record.

## General two-parameter theorem

Let `0<δ<1/4`, `0<ε<1` be fixed, and put `L=q²−1`. For each sufficiently large prime `q`, form a modular Bose–Chowla Sidon block `S₀⊂ℤ/Lℤ` of cardinality `q`, rotate it cyclically to representatives `S⊂[0,L−1]` with the endpoint count `h+v≤W`, where

`J=ceil(δL)+max(A)+2`,
`v=|S∩[0,J]|`, `h=|S∩[L−J,L−1]|`, and
`W=q(2J+1)/L`.

By averaging all `L` rotations, this choice exists whenever `2J+1≤L`. Consider the integer translation window

`I=[ceil((1−δ)L), floor((1−(1−ε)δ)L)]∩ℤ`, so `|I|=εδL+O(1)`.

There is some `T∈I` and a deletion subset `R⊂S` such that `A∪(T+(S\R))` is Sidon and

\[
|R|\le {r\choose2}+\frac r{|I|}\left(\frac{2W^3}{27}+\frac{W^2}{8}\right).
\]

The maximum is bounded by `M≤(2−(1−ε)δ)L+O(1)`. Consequently

\[
\liminf_{q\to\infty}\frac{|U_q|}{\sqrt{\max U_q}}
\ge \frac{1-\frac{16r\delta^2}{27\epsilon}}{\sqrt{2-(1-\epsilon)\delta}},
\]

provided the numerator is positive.

### Proof and complete collision classes

1. **Cyclic source and rotation:** Bose–Chowla's usual `q`-element Sidon set modulo `q²−1` retains the Sidon property on every cyclic rotation. For each rotation, the count in the disjoint endpoint bands `[0,J]` and `[L−J,L−1]` has average `W`. Choose the first rotation attaining no more than `W`.
2. **Separated sum bands:** `A+A` is bounded by `2 max A`; `A+(T+S)` starts above `T`; `(T+S)+(T+S)` starts above `2T`. For large `q`, only the last two bands can overlap, plus collisions *within* the mixed band.
3. **Boundary collisions:** An equality `a+(T+s_h)=(T+s_i)+(T+s_j)` implies `T=a+s_h−s_i−s_j`. Since `T≥(1−δ)L` and `s_h≤L−1`, both `s_i,s_j≤δ L+max A` lie in the low band. Since `s_i+s_j≥0`, `s_h≥T−max A` lies in the high band. For each old `a`, one high word and unordered low pair (diagonals included), the equation defines at most one integer `T`. Thus a good `T` has ≤`rh v(v+1)/(2|I|)` such triples. Removing its high word in every triple kills every `A+B=B+B` collision. By the arithmetic-geometric maximum `hv²≤4(h+v)³/27` and `hv≤(h+v)²/4`, the stated bound follows.
4. **Mixed versus mixed:** Any equality `a+(T+s)=a'+(T+s')` with `a≠a'` requires `s−s'=a'−a`. A Sidon set modulo `L` has a unique **ordered** representation of every nonzero difference. Each unordered pair `{a,a'}` therefore needs at most one further deletion. This costs at most `binom(r,2)` and cannot restore an eliminated collision.
5. **Asymptotics:** `q/√L→1`; `W=(2δ+o(1))q`; and `|I|=(εδ+o(1))L`. Hence `|R|/q≤16rδ²/(27ε)+o(1)` and `M/L≤2−(1−ε)δ+o(1)`. For `δ=3/(64r)`, `ε=1/3` the relative deletion ceiling is exactly `1/(256r)` and the endpoint coefficient is `2−1/(32r)`, proving the headline.

### Exact strict inequality and all-r certificate

Set `t=1/r∈(0,1]`. Direct rational expansion gives

\[
(C_r^{\rm new})^2-(C_r^{\rm old})^2
=\frac{t(591667200+5514896t-25589t^2)}{186624000(80-t)(64-t)}>0.
\]

The numerator is positive for `0<t≤1` since `591667200−25589>0`. Also

\[
(C_r^{\rm new})^2-\tfrac12
=\frac{t(t+512)}{2048(64-t)}>0.
\]

These are exact algebraic identities; no reliance on floating-point comparisons or finite samples.

## Reproduction

Run (Python standard library):

```bash
python3 verify_constants.py
python3 independent_finite_replay.py > replay.json
