# An explicit 2-adic equilibrium taper for Hermite reconstruction

Date: 2026-10-26. Scope: exact refinement of the interpolation multiplicity/precision analysis in OpenAI's October 25 ETH manuscript, `build/quantitative-contraction.tex`, especially Lemma `tapered-hermite` and equation `tensor-hermite-loss`.

**Mathematical status:** Proof given below; independently audited by a separate exact-rational checker, low-dimensional Hermite reconstruction, and an LP check. **Originality status:** undetermined; no priority claim. **Algorithmic effect:** constant-factor improvement in interpolation precision, unchanged asymptotic exponent.

## 1. Definitions

Let `a>=u>=1`, `L=2^a`, `M>=1`, `D=M(2L-1)`. The nonzero interpolation nodes are the integers `t` in `[-L,L-1]`, each of 2-adic valuation `i=v2(t)`.
There are exactly `N_i=L/2^i` nodes at valuation `i` for `0<=i<=a`.
Choose multiplicities `q_i` for `0<=i<u`, and set `q_i=0` above the cutoff. For a node of valuation `i`, write its Hermite cardinal multiplier as

`E_t(T) = PROD_{s != 0,t} ((T-s)/(t-s))^{q_{v2(s)}}`.

OpenAI's exact identity gives the negative valuation of the cardinal multiplier:

`-v2(E_t(0)) = (L/2^i) (Aq)_i`,

where

`(Aq)_i = SUM_{j=1}^{a-i} (j/2^j) (q_i - q_{i+j})`,

with `q_j=0` for `j>=u`. Define the *normalized valuation loss* as `(Aq)_i`. Hermite reconstruction is available whenever

`SUM_{i=0}^{u-1} N_i q_i > D`.

## 2. Exact explicit taper

Define `g(k)=k/6+5/18+(2/9)4^{-k}` for `k>=1`, and

`S_u=u/3+(2/9)(1-4^{-u})`,

`R=D/(L*S_u)`.

Set, for `0<=i<u`,

`q_i = ceil(R*g(u-i))+1`.

**Theorem A.** These integer multiplicities satisfy:

1. `SUM_i N_i q_i > D`.
2. `(Aq)_i <= R+4` for every `0<=i<u`.
3. `1<=q_i<=4M` for every `0<=i<u`.

**Proof.** Write `c_j=j/2^j`. For the ideal infinite grid, with `g(k)=0` for `k<=0`, the triangular recurrence is

`2g(k)-SUM_{j=1}^{k-1}c_j*g(k-j)=1`, `k>=1`.

Indeed the generating function `G(z)=SUM_{k>=1}g(k)z^k` equals

`G(z)=z(z-2)^2/[2(1-z)^2(4-z)]`,

by multiplying the recurrence through by `z^k` and using `SUM_{j>=1}c_j z^j = (z/2)/(1-z/2)^2`. Partial fractions yield precisely the stated `g(k)`.

A finite grid truncates some positive terms `c_j (g(k)-g(k-j))`, so for `f_i=R*g(u-i)` one has `(Af)_i<=R`.

The exact weighted-sum identity is

`SUM_{i=0}^{u-1} 2^{-i}g(u-i)=u/3+(2/9)(1-4^{-u})=S_u`.

Hence `SUM_i N_i f_i = R*L*S_u=D`. Every `q_i` exceeds `f_i`, proving (1).

Write `q_i=f_i+e_i` where `1<=e_i<2` (and `e_i=0` beyond `u`). Then `(Aq)_i=(Af)_i+(Ae)_i<=R+2*SUM_{j=1}^{a-i}c_j<R+4`, proving (2).

The sequence `g(k)` increases with `k`. Further, `S_u>=g(u)` for every positive integer `u`, since

`S_u-g(u)=u/6-1/18-(4/9)4^{-u}>=0`,

with equality at `u=1` and strict inequality afterward. Consequently `R*g(u)<=D/L=M(2-1/L)<2M`. Therefore `q_i<=2M+1<=4M`, proving (3). QED.

## 3. Certified precision change

With a working precision `p` at a recursive call and local parameter `alpha=2^{a+1}`, the exact Hermite formula reconstructs the target modulo `2^p` if each active node's Taylor coefficients are available modulo `2^{p_i}`, where a sufficient bound is

`p_i = p + ceil((L/2^i)(R+4)) + (q_i-1)(a+1-i)`.

Reason: the coefficient series of `F(t+alpha*z)/E_t(t+alpha*z)` remains integral after dividing by the unit series `E_t(t+alpha*z)`. Multiplication by `E_t(0)` loses at most `(L/2^i)(R+4)` valuation units. Substituting `z=-t/alpha` into a polynomial of degree below `q_i` loses at most `(q_i-1)(a+1-i)` additional units. Summation incurs no additional binary valuation loss.

In OpenAI's recursive parameter regime `a=a_prev+2u` and `u>=lambda^{4/5}`, so `L/2^i >=2^{a_prev+u}`. The inherited precision and Taylor substitution term are absorbed in `O(M(L/2^i)/u)` exactly as in the published proof. The mode-count and recursive time exponent therefore remain of order `2^{O(s/sqrt(log s))}`. The new leading valuation precision is `R~6M/u`, versus the publication's specified `8h~24M/u` for `h=ceil(3M/u)`. The leading coefficient in the precision allowance improves fourfold for growing `u` and `M/u`.

## 4. Exact finite-grid minimax theorem

Let `A` be the `u x u` upper-triangular matrix described in section 1; it has strictly positive diagonal and nonpositive off-diagonal entries. Its inverse is entrywise nonnegative, as follows by backward substitution. Set `w_i=L/2^i`, `v=A^{-1}1` and `D=M(2L-1)`.

**Theorem B.** Among all real-valued `q_i>=0` satisfying `w^T q>=D`, the smallest possible maximum normalized interpolation loss equals

`R_* = D/(w^T v)`.

It is attained by `q_*=R_* v`.

**Proof.** If `Aq<=B*1`, multiplying by `A^{-1}>=0` gives `q<=B*v`, hence `D<=w^T q<=B*w^T v`, establishing `B>=R_*`. Equality is attained at `q=R_* v`. QED.

The explicit `g` is the infinite-grid solution to this minimax problem. For the finite grid, `A g<=1`, so `R_*<=R`. Write `b=a-u` and `epsilon=g(u)(b+3)/2^{b+1}`. If `epsilon<1`, the omitted tail in row `i` is at most `epsilon`. Consequently `A g >=(1-epsilon)*1`. Inverse positivity yields

`g<=v<=g/(1-epsilon)`, hence

`(1-epsilon) R <= R_* <= R`.

For the actual recursive regime `a-u>=u`, this gives an explicit near-optimality certificate (and `epsilon<1`). The additive constant `+4` in Theorem A is the rounding overhead.

## 5. Reproducible checks

- `eth_closed_form_taper.py`: exact-rational construction for all listed examples.
- `generate_witness.py`: creates `taper_witness.json` with concrete multiplicities and exact maxima.
- `audit_taper_independent.py`: independently calculates the valuations of the *original Hermite cardinal products* by traversing grid nodes. It checks all active nodes for `a<=8`, plus representative nodes at every valuation for `a=12` and `a=16`. It also solves an independent real LP.
- `check_hermite_independent.py`: performs direct symbolic Hermite reconstruction on a degree-seven test polynomial using a distinct method.

Representative audited instance: `a=12,u=6,M=1000`. Published normalized maximum is exactly `2849.12109375`, the new maximum exactly `895.22216796875`. The ratio is `3.182586...`.

## 6. Scope and next barrier

These theorems are precise improvements in the *constants* of the existing tensor-contraction method. The `M/sqrt(u)` mode-entropy exponent remains. An improved asymptotic exponent requires aggregating weighted modes symbolically rather than enumerating their admissible exponent tuples. A polynomial-time SAT theorem would require a substantially stronger algorithmic mechanism. The present work establishes neither P=NP nor a new #SAT asymptotic exponent.

Dated source inspection: October 26, 2026. Search found general antecedents in p-adic Hermite interpolation and the original October 25 ETH manuscript, yet no exact match to Theorems A/B was identified during this limited search. Treat originality as unverified until an extensive prior-art review.
