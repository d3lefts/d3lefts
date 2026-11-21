# Audit of PR #980 and a sharp-exponent secant bound

**Author:** Claude (audit + sharpening), 21 Nov 2026. **Status:** author-side paper proof. Not Lean-certified, not externally reviewed, no prior-art clearance against Segre/secant-variety literature.

Notation is as in PR #980: $E_n=\mathbb F_2^{2^n}$, $R_n$ the tensor rows ($|R_n|=3^n$), $S_n=R_n+R_n$, $S_n^*=S_n\setminus\{0\}$, $\alpha=\log_2 3$.

## 1. Audit verdict on PR #980's Claims A–C: correct

Each step was re-derived on paper, independently of the PR's checker.

1. **Claim A (mixed products).** The pairs $(r,s)\in(R_n\times R_n)\cap U$ are counted as follows. First rows $r$ lie in $R_n\cap\pi_1(U)$, which has at most $q^2$ elements; the sharp certified bound gives $q^\alpha$. For a fixed $r$, the compatible second rows form one coset of $K_0=\{s:(0,s)\in U\}$, contributing at most $(q+1)^2$, or $(q+1)^\alpha$ by the sharp bound. When $q=0$ the count is empty. **Valid.**
2. **Claim B (six-way decomposition).** All $\binom{3}{2}+3$ type pairs check out. The sums $(r,0)+(r',0)$, $(0,r)+(0,r')$ and $(r,r)+(r',r')$ give the pure branches. The sums $(r,0)+(0,s)=(r,s)$, $(r,0)+(s,s)=(r+s,s)$ and $(0,r)+(s,s)=(s,r+s)$ give the mixed branches. The maps $(r,s)\mapsto(r+s,s)$ and $(r,s)\mapsto(s,r+s)$ are linear bijections. The slices $W_A=\{u:(u,0)\in W\}$, $W_B$ and $W_C=\{u:(u,u)\in W\}$ pairwise intersect trivially inside $W$, so $a+b,\ a+c,\ b+c\le q$. **Valid.**
3. **Scalar inequality.** Sort so that $a\ge b\ge c$. For every exponent $p\ge2$, $(a+b)^p\ge a^p+p\,a^{p-1}b\ge a^p+2b^p\ge a^p+b^p+c^p$. **Valid** for $p=4$ and for $p=2\alpha$.
4. **Induction and affine step.** The base case is $S_0^*=\varnothing$. Every affine flat satisfies $a+W\subseteq W+\langle a\rangle$. **Valid.** Also $A_n+A_n=S_n$ for $n\ge1$, because each row is the sum of the other two rows with the same prefix.

**Caveat on the evidence.** Exhaustive checks at $L\le3$ cannot falsify $1+12L(q+1)^4$. A coset holds at most $2^q$ points, and $|S_L|\le 9^L$. The bound is only nontrivial when both $2^q$ and $9^L$ exceed $12L(q+1)^4$, which first happens around $L\approx8$ and $q\approx35$. So the PR's "passing finite checks" carry no evidential weight for this claim. The paper proof is what matters.

## 2. Sharpening: the exponent drops from 4 to the optimal $2\log_2 3\approx3.17$

**Theorem.** For all $n\ge0$ and every $q$-dimensional $W\le E_n$,
$$|S_n^*\cap W|\le 9n\,q^{2\log_2 3}.$$
For every coset, $|(A_n+A_n)\cap(a+W)|\le1+9n(q+1)^{2\log_2 3}$.

*Proof.* Run PR #980's argument with the certified sharp bounds $|R\cap U|\le(\dim U)^\alpha$ and $|R\cap(b+U)|\le(\dim U+1)^\alpha$ in place of the exponent-2 bounds.
- Claim A becomes $q^\alpha(q+1)^\alpha\le 2^\alpha q^{2\alpha}=3q^{2\alpha}$ for $q\ge1$.
- With three mixed families, $F_{n+1}(W)\le F_n(W_A)+F_n(W_B)+F_n(W_C)+9q^{2\alpha}$.
- The scalar inequality at $p=2\alpha\ge2$ closes the induction. ∎

**Optimality of the exponent.** For $k\le n$, take $W$ to be a tensor-factor copy of $E_k$ (so $q=2^k$). Then $|S^*\cap W|\ge|S_k^*|$. Exact computation (`check_secant_lower_bound.py`) gives:

| k | q | \|S\*_k\| | \|S\*_k\|/q^{2α} |
|---|---|---|---|
| 1 | 2 | 3 | 0.333 |
| 2 | 4 | 15 | 0.185 |
| 3 | 8 | 189 | 0.259 |
| 4 | 16 | 2,349 | 0.358 |
| 5 | 32 | 25,191 | 0.427 |
| 6 | 64 | 247,131 | 0.465 |

The ratio climbs toward $\tfrac12$, as expected: almost all pairs of distinct rows have distinct sums, giving about $9^k/2$. So no exponent below $2\log_2 3$ works, and
$$\max_{\dim W=q}|S_n^*\cap W|=q^{2\log_2 3+o(1)}\quad(\text{up to the factor }n).$$

**Corollary (quotient-pair multiplicity).** $\mu(\pi_W(A_n))\le(n+1)\bigl[1+9n(q+1)^{2\log_2 3}\bigr]$.

## 3. Open

1. **The factor $n$.** Is the linear factor $n$ necessary, or is $|S_n^*\cap W|\le Cq^{2\alpha}$ uniformly in $n$? This is the natural next question. A family with $n$-growth at fixed $q$ would need secants spread across many levels.
2. **Sharp constant.** The upper constant is 9 and the lower one tends to 1/2.
3. **Lean.** The proof is a direct modification of PR #980's Lean skeleton: swap exponent 2 for the `SubcubeSharpAllLevels` bound and use `triple_rpow` at $p=2\alpha$.
4. **Prior art.** $R_n$ is the set of $\mathbb F_2$-points of the Segre variety $(\mathbb P^1)^n$, and $S_n$ is its secant set. Check finite-geometry results on linear sections of Segre secant varieties before claiming novelty.
5. **Not addressed.** The coherent $T\ge2$ quantum gate remains separate, as the handoff says.
