# Sharp top-Hoeffding-layer removal on arbitrary product spaces

**NIGHTFALL research note · 11 November 2026 · v1.0**

**Status:** Self-contained analytic theorem with explicit sharpness construction; independently replayed exact-rational computations for degrees 1–8 and 288 finite model instances. **Not Lean-certified, not externally peer-reviewed, and not certified globally novel.** The polynomial extremal argument is classical Chebyshev theory; its arbitrary-product projection consequence and lower-bound model are recorded explicitly here with full attribution to the underlying ideas. In particular, see the pre-existing *Fourier Growth of Bounded Functions* Chebyshev coefficient program and classical product-noise/Hoeffding decomposition literature.

## Theorem: exact universal operator norm

Let \(d\ge1\). On any finite independent probability product \(\Omega=\prod_{i=1}^n(\Omega_i,\mu_i)\), let \(f\in L^\infty(\Omega)\) have Hoeffding degree at most \(d\), and write \(f^{=j}=\sum_{|S|=j}f_S\) for its orthogonal Hoeffding levels. Then

\[
\boxed{\|f-f^{=d}\|_\infty\ \le\ (2^{2d-1}-1)\|f\|_\infty.}\tag{1}
\]

**Sharpness:** the coefficient \(2^{2d-1}-1\) is the exact supremum of this norm ratio over all finite independent product probability spaces, arbitrary finite input alphabets, and all bounded nonzero functions of Hoeffding degree at most \(d\). The limit is approached already on independent Bernoulli products whose success probabilities tend to zero, with all atoms strictly positive at each finite stage. No fixed positive minimum-atom bound is imposed.

For \(d=1,2,3,4,5\) the exact norms are \(1,7,31,127,511\), respectively. In particular, the degree-two additive projection coefficient \(7\) in the quadratic influence proof is **optimal in the law-free setting**, and the degree-three quadratic projection has exact universal norm \(31\).

### Proof: universal upper bound

For \(0\le t\le1\), define the independent-resampling/noise operator

\[
\mathcal T_t=\prod_{i=1}^n\big[t\operatorname{Id}+(1-t)\mathbb E_i\big].
\]

It is a Markov averaging operator, hence \(\|\mathcal T_tf\|_\infty\le\|f\|_\infty\), for **every** product law. Hoeffding orthogonality implies

\[p_x(t):=(\mathcal T_tf)(x)=\sum_{j=0}^d t^j f^{=j}(x),\qquad 0\le t\le1,\]

at almost every \(x\); we may take a common full-measure set for the finitely many nodes below. The quantity we want to bound is the linear polynomial functional

\[L(p_x):=p_x(1)-[t^d]p_x=f(x)-f^{=d}(x).\]

Choose the degree-\(d\) Chebyshev extremal nodes \(t_j=(1+\cos(j\pi/d))/2\), \(j=0,\ldots,d\), so \(t_0=1>\cdots>t_d=0\). Lagrange interpolation gives

\[[t^d]p=\sum_{j=0}^d \lambda_j p(t_j),\qquad
\lambda_j=\prod_{\substack{0\le \ell\le d\\\ell\ne j}}(t_j-t_\ell)^{-1}.\]

The sign of \(\lambda_j\) is \((-1)^j\). Because the Chebyshev polynomial \(T_d(2t-1)\) equals \((-1)^j\) at \(t_j\) and has leading coefficient \(2^{2d-1}\), the exact total variation is

\[\sum_{j=0}^d|\lambda_j|=2^{2d-1}.\tag{2}\]

Also \(\lambda_0\ge1\) (strict for \(d>1\)). Thus

\[
\begin{aligned}
|L(p_x)|
&=\left|(1-\lambda_0)p_x(t_0)-\sum_{j=1}^d\lambda_j p_x(t_j)\right|\\
&\le\big[(\lambda_0-1)+\sum_{j=1}^d|\lambda_j|\big]\|f\|_\infty\\
&=(2^{2d-1}-1)\|f\|_\infty.
\end{aligned}
\]

Taking essential sup proves (1). No hypercontractivity, fair-sign symmetry, or lower bound on the atom masses is used. QED.

### Proof: exact sharpness, including strictly positive atom masses

Fix \(d\), let \(n\ge d\), and let \(X_1,\ldots,X_n\) be independent Bernoulli variables with \(p_n=n^{-2}\) (for \(n\ge2\)). Set \(S_n=X_1+\cdots+X_n\) and define

\[f_n(X)=T_d(2S_n/n-1).\]

Because \(0\le S_n/n\le1\) and \(T_d\) maps \([-1,1]\) into \([-1,1]\), \(\|f_n\|_\infty=1\); equality holds at the all-ones point, which has positive probability \(p_n^n\). The function has multilinear/Hoeffding degree at most \(d\).

The coefficient of \(z^d\) in \(T_d(2z-1)\) is \(c_d=2^{2d-1}\). On expanding \(f_n\) as a multilinear function of the Bernoulli variables, the coefficient of every degree-\(d\) monomial \(\prod_{i\in S}X_i\) is precisely \(c_d d!/n^d\); lower powers of \(S_n\) cannot contribute at the top degree. Hence its exact top Hoeffding level is

\[f_n^{=d}(X)=\frac{c_d d!}{n^d}\sum_{|S|=d}\prod_{i\in S}(X_i-p_n).\]

At the all-ones input \(\mathbf1\),

\[f_n^{=d}(\mathbf1)=c_d\frac{(n)_d}{n^d}(1-p_n)^d,\]

where \((n)_d=n(n-1)\cdots(n-d+1)\). Therefore

\[(f_n-f_n^{=d})(\mathbf1)=1-c_d\frac{(n)_d}{n^d}(1-p_n)^d\longrightarrow1-c_d.\]

The absolute values converge to \(2^{2d-1}-1\), establishing the exact norm and showing that the exponential \(4^d\) growth is intrinsic to **top-degree removal by projection** on arbitrary product laws. QED.

## A concrete degree-three filter and frontier consequence

For \(d=3\) the four Chebyshev nodes are \(0,1/4,3/4,1\), and the exact interpolation filter is

\[
\boxed{P_{\le2}f=\frac{16\mathcal T_0f-32\mathcal T_{1/4}f+32\mathcal T_{3/4}f-13\mathcal T_1f}{3}.}\tag{3}
\]

Thus \(\|P_{\le2}f\|_\infty\le31B\), sharply. In particular the cubic-defect version of the quadratic-backdoor theorem in [`QUADRATIC_BACKDOOR_TRANSFER_v1.md`](QUADRATIC_BACKDOOR_TRANSFER_v1.md) strengthens to

\[
(\operatorname{Var}(f)-\delta_C)^2\le(961\cdot5043+2|C|)B^2\max_i I_i(f)
=(4{,}846{,}323+2|C|)B^2M.
\]

When the cubic energy \(\delta_\varnothing\) is at most half the variance, this gives an alphabet- and bias-uniform exponent-two estimate for **every cubic function in that spectral regime**:

\[\max_i I_i(f)\ge\frac{\operatorname{Var}(f)^2}{4\cdot4{,}846{,}323B^2}.\]

This spectral-regime corollary **does** depend on the separate, not-yet-end-to-end-certified analytic quadratic influence result. The sharp projection theorem (1) itself does not.

Crucially, the exact exponential constant shows why naive iterative degree truncation is **not** a credible path to a polynomial-in-\(d\) influence bound without some entirely different structural ingredient. It does not rule out a more sophisticated method.

## Certification, prior art, and replay

- **Proof certificate:** formulas (2)–(3), the explicit Bernoulli witness, and exact coefficient calculations. There is no assumed hidden polynomial inequality.
- **Independent audit:** `check_sharp_projection.py` (stdlib-only exact rational checker), replayed 288 finite biased-product functions of degrees 1–6 plus explicit sharpness sequences for degrees 1–8. Exact rational arithmetic; no float tolerances used in arithmetic assertions.
- **Prior-art distinction:** Classical Chebyshev extremal polynomials and Lagrange interpolation are longstanding. Published Fourier-growth work (e.g. *The Fourier Growth of Bounded Functions*, Theorem 1, for uniform Boolean cubes) obtains Chebyshev-based degree-level bounds; arbitrary product noise decomposition was already standard by 2010 (*Polynomial regression under arbitrary product distributions*). This note does **not** certify that the combined exact norm statement is worldwide new, and must not be presented as a novel general Chebyshev discovery without specialist review.
- **Scope:** finite independent product laws, finite Hoeffding degree, bounded real functions; extension to general independent measurable products follows when the finite ANOVA/noise identities and essential-sup Markov bounds are available.
- **No Lean kernel assertion:** This is a full handwritten derivation with exact finite checks, not an end-to-end machine certificate.

Reproduce with:

```sh
python3 check_sharp_projection.py
```

Expected `PASS exact_projection_models=288` and `PASS exact_sharpness_degrees=8`.