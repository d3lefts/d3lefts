# AXIOM / NIGHTFALL — Uniform finite-prefix Sidon extension beyond the disjoint-block coefficient

**Date:** 29 October 2026. **Program lead:** Devin J. Wright. **Derivation:** Axiom (GPT-6). **Proof status:** self-contained asymptotic argument with exact arithmetic checks and a separate full-list integer verifier; external referee and novelty priority **OPEN**.

## Theorem (arbitrary prescribed finite Sidon prefixes)

Let \(A\subset\mathbb N\) be an arbitrary nonempty finite integer Sidon set with \(r=|A|\), where *Sidon* means every unordered pair sum, including repeated-element pairs, is unique. Put

\[
\delta_r=\frac1{20r},\qquad
C_r=\frac{1-\frac{2}{675r}}{\sqrt{2-\frac1{40r}}}.
\]

There is a deterministic finite construction, for every sufficiently large **prime** \(q\), of a finite integer Sidon set \(U_q\) extending \(A\), such that \(M_q=\max U_q\to\infty\) and

\[
\liminf_{q\to\infty}\frac{|U_q|}{\sqrt{M_q}}\;\ge\; C_r\;>\;\frac1{\sqrt2}.
\]

An explicit quantitative form: for \(L=q^2-1\), \(J=\lceil\delta_r L\rceil+\max A+2\), \(I=[\lceil(1-\delta_r)L\rceil,\lfloor(1-\delta_r/2)L\rfloor]\cap\mathbb Z\), and \(W=q(2J+1)/L\), whenever \(I\neq\varnothing\), there are a cyclic translate of a \(q\)-element Bose–Chowla set \(S\subset\{0,\ldots,L-1\}\), a translation \(T\in I\), and a deletion subset \(R\subset S\) of size at most

\[
\boxed{\binom r2+\frac r{|I|}\left(\frac{2W^3}{27}+\frac{W^2}{8}\right)}
\]

such that \(U_q=A\cup\{T+s:s\in S\setminus R\}\) is integer Sidon. The rational bound holds up to the routine integer floor: the actual number of deletions is integer and bounded by the displayed real number. Its largest element is at most \((2-\delta_r/2)L\).

**Scope:** This is a strict asymptotic *fixed-prefix finite-extension* coefficient above \(1/\sqrt2\), dependent on \(r\). It is **not** an infinite Sidon sequence with limsup coefficient above \(1/\sqrt2\), nor a proof of the conjectured universal coefficient \(1\) in Erdős #44/#329. The gain tends to zero as \(r\to\infty\). The cyclic-group block, rotation, deletion and integer verification are all explicit, with polynomial complexity in \(q\); this is a proof of existence with an executable witness search.

## Proof

1. **Cyclic block.** Let \(q\) be prime, \(L=q^2-1\), \(\theta\) primitive in \(\mathbb F_{q^2}^\times\), and define \(S_0=\{e\in\mathbb Z/L\mathbb Z:\theta^e=\theta+t\text{ for some }t\in\mathbb F_q\}\). It has exactly \(q\) members and is Sidon modulo \(L\): an equality \(e_1+e_2=e_3+e_4\) gives \((\theta+t_1)(\theta+t_2)=(\theta+t_3)(\theta+t_4)\), and independence of \(1,\theta\) over \(\mathbb F_q\) implies equality of both elementary symmetric functions, hence the same unordered pair of \(t\)'s. Every cyclic translate remains modular Sidon; interpreting its representatives in \([0,L-1]\) makes it integer Sidon.

2. **Rotate to control both endpoint populations.** Fix \(\delta=1/(20r)\), \(N=\max A\) and \(J=\lceil\delta L\rceil+N+2\). For each cyclic translate \(S_t\), let \(v_t=|S_t\cap[0,J]|\) and \(h_t=|S_t\cap[L-J,L-1]|\). Averaging over the \(L\) cyclic shifts gives \(L^{-1}\sum_t(v_t+h_t)=q(2J+1)/L=W\), provided \(2J+1\le L\), true for large \(q\). Therefore there is a deterministic shift with \(v+h\le W\).

3. **The exact dangerous triples.** Choose \(T\) in the integer interval \(I\) displayed above. Internal \(A+A\) and \(S+S\) sums are Sidon; their bands are disjoint from each other and from \(A+(T+S)\) as appropriate once \(T>2N\). The only possible *low-vs-high* collision is

   \[
   a+(T+s_h)=(T+s_i)+(T+s_j),\quad\text{equivalently}\quad T=a+s_h-s_i-s_j.
   \]

   It forces \(s_h\in[L-J,L-1]\) and \(s_i,s_j\in[0,J]\). For every ordered \(a\in A\), high endpoint \(s_h\) and unordered low pair \(\{s_i,s_j\}\) (diagonals included), there is **at most one** \(T\in I\) creating a collision. Thus averaging over \(T\) gives one with at most \(r h v(v+1)/(2|I|)\) collisions. Remove a high endpoint for each such collision. Since \(h+v\le W\), the inequalities \(hv^2\le4W^3/27\) and \(hv\le W^2/4\) imply

   \[
   \frac{rh v(v+1)}{2|I|}\le\frac r{|I|}\left(\frac{2W^3}{27}+\frac{W^2}{8}\right).
   \]

4. **Mixed-sum repair at fixed old differences.** A remaining collision \(a+(T+s)=a'+(T+s')\) with \(a\ne a'\in A\) requires \(s-s'=a'-a\). Modulo \(L\), the cyclic Sidon property gives at most one ordered pair \((s,s')\) for each nonzero prescribed difference. Removing one block point per unordered old pair costs at most \(\binom r2\) further deletions. Removing points cannot create new pair-sum collisions. All \(A+A\), \(B+B\), \(A+B\) collisions are eliminated, so the resulting \(U_q\) is integer Sidon, with the finite deletion bound as stated.

5. **Asymptotic coefficient and strict gain.** Since \(q/\sqrt L\to1\), \(W=(2\delta+o(1))q\) and \(|I|=(\delta/2+o(1))L\), the relative number of deletions is at most

   \[
   \frac{|R|}{q}\le\frac{32}{27}r\delta^2+o(1)=\frac{2}{675r}+o(1).
   \]

   Also \(M_q\le(2-\delta/2)L\). This establishes the displayed \(C_r\). The strict comparison is an exact rational identity:

   \[
   2\left(1-\frac{2}{675r}\right)^2-\left(2-\frac1{40r}\right)
   =\frac{71}{5400r}+\frac{8}{455625r^2}>0.
   \]

   Therefore \(C_r>1/\sqrt2\). □

## Exact finite falsification fixture (not the asymptotic proof)

- Frozen prefix: \(A=\{1,2,4,8,13\}\), a previously studied prefix outside perfect-difference-set embeddings.
- Field: \(\mathbb F_{1009}[u]/(u^2-11)\), primitive \(\theta=7+u\), \(L=1,018,080\).
- Finite exploratory parameter \(\delta=0.27\), **distinct from the conservative theorem value \(\delta_r=0.01\)**.
- Cyclic shift \(786787\), integer translation \(T=872671\), 13 block marks deleted, final set \(|U|=1001\), \(M=1,890,093\).
- Independent integer checker verifies **501,501** distinct unordered pair sums and **500,500** distinct positive pair differences; numeric \(|U|/\sqrt M=0.7281024470094891\), \(2|U|^2-M=113909>0\). Full sorted integer coordinates are in `certificate_p1009_delta027.json`.
- SHA-256 of comma-separated sorted coordinates: `255f8cbf21a1dc65b52d38a4ad7253f51743eae03c19b7631676984a8c9e805d`.
- This is a finite *within-program* improvement on the previously archived 970-mark prefix extension at \(M=1,794,316\), with ratio \(970/\sqrt{1,794,316}\approx0.724140\). It is **not** a published extremal record or a new infinite Sidon density bound. Since this finite run uses \(\delta=0.27\), it cannot certify the conservative general deletion constant.

## Reproduction and independent attacks

```sh
cd research/nightfall/projects/erdos/sidon-repair-bridge-2026-10-29/prefix_boundary_20261029
python3 generate_frozen.py
python3 verify_certificate.py certificate_p1009_delta027.json
python3 verify_uniform_constant.py
```

The builder uses finite-field exponent arithmetic, cyclic translate selection and explicit cross-triple counting. `verify_certificate.py` imports **no builder code**, checks the frozen output solely from integer pair sums/differences, validates the SHA, and rejects an invalid point insertion. `verify_uniform_constant.py` uses exact rational arithmetic to test the constant and contains a symbolic algebraic identity independent of the finite data. Exact SHA-256 file hashes and execution logs accompany the sources.

## Source scope / novelty

- Existing finite Sidon blocks: Bose–Chowla construction and Singer/projective difference sets, classical.
- Published infinite-sequence coefficient \(1/\sqrt2\): Krückeberg (1961), cited by [Erdős #329](https://www.erdosproblems.com/329). The present fixed-prefix finite theorem has **different quantifiers** and supplies no improvement to the known global infinite limsup lower bound.
- [Erdős #44](https://www.erdosproblems.com/44) seeks arbitrarily close-to-1 finite-prefix embeddings. The theorem here reaches a specific \(C_r<1\), depending on the fixed prefix size. Erdős #44 remains open.
- Alexeev–Mixon (PNAS 2026) disproved the stronger perfect-difference-set embedding conjecture #707. That disproof does not concern ordinary finite Sidon extension by translated blocks.

**Priority status:** A specific earlier proof of this quantitative fixed-prefix constant was not identified in the bounded source scan; general boundary-rotation and deletion arguments may have established antecedents. Claim: internal self-contained theorem candidate and exact finite witness, **no global first-discovery assertion**, awaiting Lemnis proof attack, Ryev independently implemented verification, and Vesper dated priority review.

## Dated comparison correction (29 October 2026; PR #73)

The finite 1,001-mark sample above exceeds the **older 970-mark checkpoint**, yet the newer [NIGHTFALL PR #73](https://github.com/d3lefts/d3lefts/pull/73) supplies a **stronger finite same-prefix normalized ratio**: 977 marks through M=1,766,378, giving approximately **0.7351106932**, compared with this report's 1,001/sqrt(1,890,093)≈0.7281024470. PR #73's finite 37-cover optimality is scoped to its fixed cut/shift. Therefore the present 1,001-mark illustration is **not** the current best NIGHTFALL finite same-prefix ratio. The independent uniform *arbitrary-prefix* theorem above is logically distinct; its asymptotic coefficient still requires external same-scope priority review. The separate cross-track target of a **prefix-independent** ρ,δ inequality remains open, since the deletion bound here scales with r.