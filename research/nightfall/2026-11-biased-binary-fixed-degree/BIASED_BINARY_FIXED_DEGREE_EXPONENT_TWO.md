# Exponent two on arbitrarily biased binary products, every fixed degree

**Status:** author-side proof (Claude, 20 Nov 2026). Not refereed, not Lean-certified, no novelty clearance. Constants are deliberately crude.

## Theorem

Let $X_1,\dots,X_n$ be independent $\{\pm1\}$-valued random variables with arbitrary means $m_i\in(-1,1)$, and $\sigma_i^2=1-m_i^2$. Let $f$ be a real multilinear polynomial of degree $\le d$ with centered radius $B=\inf_c\max_{x\in\{\pm1\}^n}|f(x)-c|$. Write $V=\operatorname{Var}f(X)$, $\operatorname{Inf}_i=\mathbb E\operatorname{Var}(f\mid X_{-i})$ and $M=\max_i\operatorname{Inf}_i$. Then

$$\sum_i\sqrt{\operatorname{Inf}_i}\le K_dB,\qquad\text{hence}\qquad V^2\le K_d^2\,B^2\,M,$$

$$K_d=d^2+\sum_{k=1}^{d-1}\frac{2^{k+1}\,2^{k/2}\,\bigl(2(k+1)d^2\bigr)^{k+1}}{\sqrt{k!}}.$$

$K_d$ does not depend on $n$, on the biases, or on how close any $m_i$ is to $\pm1$. Degenerate coordinates (mass 0 on one sign) are constants and can be deleted. Infinite binary products follow from the repo's finite-conditional-projection transfer.

**Consequence.** Degree three on biased binary products (the case flagged as smallest-open) is settled with variance exponent two and a bias-free constant, $K_3\approx1.79\times10^6$. The same holds at every fixed degree.

**What it does not do.** $K_d$ grows like $\exp(\Theta(d^2\log d))$. So it says nothing about N-UE2(6) or N-UE2(2), which need polynomial dependence on $d$. It also does not cover non-binary alphabets.

## Why the averaging obstacle disappears

The two-draw transfer fails because it averages square roots: it takes $\mathbb E\sqrt{\cdot}$ over random restrictions. Here, every averaging step is applied to *signed multilinear forms*, which are linear in the law (Lemma 2). Square roots enter only once, through the exact orthogonal Taylor expansion at the mean point $m$ (Lemma 1), and no averaging happens after that.

## Proof

Replace $f$ by $f-c$, so $|f|\le B$ on the cube. Its multilinear extension is then bounded by $B$ on $[-1,1]^n$. For a set $S$ write $\partial_Sf$ for the mixed partial derivative; it is multilinear in $x_{-S}$ and does not involve $x_S$.

**Lemma 1 (exact influence expansion).**
$$\operatorname{Inf}_i=\sigma_i^2\sum_{T\subseteq[n]\setminus i,\ |T|\le d-1}\bigl(\partial_{\{i\}\cup T}f(m)\bigr)^2\prod_{j\in T}\sigma_j^2.$$

*Proof.* $f=x_i\,\partial_if+(\text{terms free of }x_i)$, so $\operatorname{Var}(f\mid X_{-i})=\sigma_i^2(\partial_if)^2$. Exact multilinear Taylor expansion in $y_j=x_j-m_j$ gives $\partial_if(x)=\sum_T\partial_{iT}f(m)\prod_{j\in T}y_j$. The monomials $\prod_T y_j$ are orthogonal with squared norm $\prod_T\sigma_j^2$. ∎

Since $\sigma_j\le1$ and $\sqrt{\sum a_k}\le\sum\sqrt{a_k}$,
$$\sqrt{\operatorname{Inf}_i}\le\sum_{k=0}^{d-1}R_{k,i},\qquad R_{k,i}=\Bigl(\sum_{|T|=k}(\partial_{iT}f(m))^2\Bigr)^{1/2}.$$

**Lemma 2 (Jensen to vertices, linear in the law).** $\partial_Sf(m)=\mathbb E\,\partial_Sf(X)$, because $\partial_Sf$ is multilinear in independent coordinates outside $S$. Define the $(k+1)$-linear form
$$A_k(z)[u^0,\dots,u^k]=\sum_{(i_0,\dots,i_k)\ \text{distinct}}\partial_{i_0\cdots i_k}f(z)\,u^0_{i_0}\cdots u^k_{i_k}.$$
For fixed vectors $u$, $A_k(m)[u]=\mathbb E\,A_k(X)[u]$. Hence $|A_k(m)[u]|\le\max_{x\in\{\pm1\}^n}|A_k(x)[u]|$. ∎

**Lemma 3 (vertex bound).** For a vertex $x$ and sign vectors $s^0,\dots,s^k$,
$$|A_k(x)[s]|\le2^{k+1}N_{d,k}B,\qquad N_{d,k}=\bigl(2(k+1)d^2\bigr)^{k+1}.$$

*Proof.*
1. Reflect coordinates ($x_j\mapsto x_jx^*_j$) so that $x=\mathbf 1$. This preserves degree and the bound $B$; it only changes the signs of the $s^r$.
2. Write each $s^r=a^r-b^r$ with $a^r,b^r\in\{0,1\}^n$ and expand multilinearly into $2^{k+1}$ terms $A_k(\mathbf 1)[c^0,\dots,c^k]$ with $c^r\in[0,1]^n$.
3. For one such term, set $P(\lambda)=f(\mathbf 1-\sum_r\lambda_rc^r)$ on the cube $Q=[0,\tfrac1{k+1}]^{k+1}$. Each argument stays in $[0,1]^n$, so $|P|\le B$ on $Q$.
4. $P$ has degree $\le d$ in each $\lambda_r$. Because $f$ is multilinear, diagonal second derivatives vanish, so $\partial_{\lambda_0}\cdots\partial_{\lambda_k}P(0)=\pm A_k(\mathbf 1)[c]$.
5. Markov's inequality on an interval of length $h$, applied once per variable ($|g'|\le2d^2\|g\|/h$ with $h=1/(k+1)$), gives $\sup_Q|\partial_{\lambda_0}\cdots\partial_{\lambda_k}P|\le(2d^2(k+1))^{k+1}B$. ∎

**Lemma 4 (mixed Littlewood / Bohnenblust–Hille inequality; classical).** For any coefficients $\alpha(i_0,\dots,i_k)$,
$$\sum_{i_0}\Bigl(\sum_{i_1,\dots,i_k}\alpha^2\Bigr)^{1/2}\le2^{k/2}\sup_{s^r\in\{\pm1\}^n}\Bigl|\sum\alpha\,s^0_{i_0}\cdots s^k_{i_k}\Bigr|.$$

*Proof.* Let $\varepsilon^1,\dots,\varepsilon^k$ be independent uniform sign vectors. The left-hand summand is $\|\sum\alpha(i_0,\cdot)\varepsilon^1\cdots\varepsilon^k\|_{L^2}$. Iterate Szarek's sharp $L^1$-Khintchine inequality ($\sqrt2$) together with Minkowski's integral inequality to get $L^2\le2^{k/2}L^1$. Then $\sum_{i_0}\mathbb E|A(e_{i_0},\varepsilon)|=\mathbb E\sup_{s^0}A(s^0,\varepsilon)$. ∎

**Assembly.**
- Each unordered $T$ with $|T|=k$ appears $k!$ times among ordered distinct tuples, and the coefficients are symmetric. So $R_{k,i}=(k!)^{-1/2}\bigl(\sum_{\text{ordered}}\alpha_k(i,\cdot\,;m)^2\bigr)^{1/2}$.
- For $k\ge1$, Lemmas 4, 2 and 3 give $\sum_iR_{k,i}\le(k!)^{-1/2}\,2^{k/2}\,2^{k+1}N_{d,k}B$.
- For $k=0$: $f(x)-f(x^{\oplus i})=2x_i\,\partial_if(x)$, and the pointwise Filmus–Hatami–Keller–Lifshitz bound gives $\sum_i|f(x)-f(x^{\oplus i})|\le2d^2B$. So $\sum_i|\partial_if(x)|\le d^2B$ at every vertex, and by Lemma 2 also at $m$.
- Summing over $k$ gives $\sum_i\sqrt{\operatorname{Inf}_i}\le K_dB$.
- Efron–Stein gives $V\le\sum_i\operatorname{Inf}_i\le\sqrt M\sum_i\sqrt{\operatorname{Inf}_i}$. ∎

## Checks run

On random degree-3 polynomials with $n=6$ and random biases in $(-0.98,0.98)$, a numerical script confirmed:
- the Lemma 1 expansion to $10^{-9}$;
- $\sum_i\sqrt{\operatorname{Inf}_i}\le\sum_k\sum_iR_{k,i}$ in every trial.

These are sanity checks, not proof.

## Open items

1. **Prior art.** The uniform-cube case is classical: mixed Bohnenblust–Hille gives exponent two with an exponential $C(d)$. The biased extension is short and may already exist, e.g. in the 2023–26 literature on Bohnenblust–Hille for product and qudit measures. A literature search is needed before any novelty claim.
2. **Constants.** At $d=2$ this gives $K_2\approx1452$, versus the repo's $4(1+\sqrt2)$. The corner Markov step is the loose part.
3. **The real frontier.** Polynomial-in-$d$ constants, and non-binary alphabets. For non-binary alphabets, Lemma 1 has no single $\partial_if$, so the argument stops there.

## Audit addendum (21 Nov 2026): this route cannot reach polynomial degree dependence

The intermediate inequality $\sum_i\sqrt{\operatorname{Inf}_i}\le K_dB$ is itself exponential in $d$ already on the fair cube, so **no** sharpening of the constants in this proof can give a polynomial-in-$d$ exponent-two theorem.

**Witness (addressing function).** Take $k$ fair address bits $a$ and $2^k$ fair target bits $y$, and set $f(a,y)=y_a$, so degree $d=k+1$ and $B=1$. Resampling target bit $y_j$ changes $f$ only when $a=j$, and conditionally $f=y_j$ has variance $1$. So $\operatorname{Inf}_{y_j}=2^{-k}$, and the target bits alone contribute
$$\sum_j\sqrt{\operatorname{Inf}_{y_j}}=2^k\cdot2^{-k/2}=2^{(d-1)/2}.$$
Hence any valid $K_d$ satisfies $K_d\ge2^{(d-1)/2}$.

The addressing function does not threaten exponent two itself: each address bit has constant influence. It only rules out proofs that pass through $\sum_i\sqrt{\operatorname{Inf}_i}$.

**Prior art.** Defant–Mastyło–Pérez (Math. Ann. 2019) already give fixed-degree exponent two on the fair cube with an exponential degree factor. This note is therefore at most an arbitrary-bias extension of that toolkit with an exponential constant. Per the handoff's stop rule, it is logged as a lemma, not a lead.
