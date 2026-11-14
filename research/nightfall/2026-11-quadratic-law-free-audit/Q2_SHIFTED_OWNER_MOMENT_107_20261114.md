# NIGHTFALL Q2 — shifted-owner Hilbert moment and a new sub-353 route

**Research date:** 14 November 2026.  
**Status:** Author-side analytic Hilbert lemma with an **independent exact rational polynomial-positivity checker**; proposed source-level composition. **Not yet compiled as a named Lean theorem**, not independently human-refereed, not priority-certified. Do not replace the strongest passed Q2 certificate or merge into a publication-cleared claim.

## Research question and source boundaries

Can a degree-two variance-squared influence inequality improve beyond 353.293 *without* optimizing the same switching operator as PR #525? The target is the **actual original** finite independent product probability law, arbitrary common finite alphabet type with heterogeneous nonnegative marginals (including zero atoms), genuine Hoeffding degree at most two and a global bound \(|f|\le B\). The new operator incorporates the singleton component **inside** the owned-neighbor Hilbert fourth moment, before an \(L^1\) bound is applied.

Existing source-derived ingredients, to be used with their **actual proof provenance**:
- Original ANOVA identity \(V=\sum_i(a_i^2+s_i)\) with ownership of each pair exactly once;
- source influence cap \(a_i^2+s_i\le I_i(f)\le M\);
- original greedy owner costs \(c_i\ge0\), pointwise \(\|Y_{ij}\|_{\mathcal H_i}\le c_i\), \(\sum_i c_i\le8B\);
- genuine source section norm \(u_i=\mathbf E_{X_{-i}}\|h_i+\sum_{j\ne i}h_{ij}(\cdot,X_j)\|_{\mathcal H_i}\);
- **already source-derived** section budget \(\sum_i u_i\le8B\), versus current PR #525's separately gated \(5B\) and \(2(1+\sqrt2)B\) improvements.

The **new** Hilbert lemma is independent of the scalar golden-cubic local inequality in PR #516 and does not use the \(z_i\le u_i+a_i\) triangle bound. The source owner groups need only be independent **within each fixed owner**. Inter-owner blocks are *not* claimed independent.

## The new shifted independent-sum lemma

**Lemma (analytic, with exact rational scalar certificate).** Let \(\mathcal H\) be a real Hilbert space; let \(Y_1,\ldots,Y_k\) be independent, centered, square-integrable \(\mathcal H\)-valued random vectors with \(\|Y_j\|\le c\) almost surely, and let \(h\in\mathcal H\) be deterministic. Set
\[
Z=\sum_jY_j,\quad s=\mathbb E\|Z\|^2,\quad
a=\|h\|,\quad e=a^2+s,\quad u=\mathbb E\|h+Z\|.
\]
For every \(c\ge0\),
\[
\boxed{\sqrt e\le\sqrt3\,u+\tfrac14 c.}\tag{SM}
\]
No symmetry of \(Y_j\), uniform atom lower bound, minimum number of increments, or independence of scalar components is assumed. The empty family and \(e=0\) are included.

**Proof.** Centering and independence imply
\[
\mathbb E\|Z\|^4\le3s^2+c^2s,\quad
\mathbb E\langle h,Z\rangle^2\le a^2s,\quad
\big|\mathbb E[\langle h,Z\rangle\|Z\|^2]\big|
\le acs.
\]
The last identity reduces to \(\sum_j\mathbb E\langle h,Y_j\rangle\|Y_j\|^2\); all other third-order mixed terms vanish by independence and zero means. Expand \(\|h+Z\|^4\):
\[
\begin{aligned}
\mathbb E\|h+Z\|^4
&=a^4+2a^2s+
 4\mathbb E\langle h,Z\rangle^2+
 4\mathbb E[\langle h,Z\rangle\|Z\|^2]+
 \mathbb E\|Z\|^4\\
&\le3e^2-2a^4+4acs+c^2s.
\end{aligned}
\tag{1}
\]
When \(e>0\), write \(x=a/\sqrt e\in[0,1]\), \(d=c/\sqrt e\ge0\). Thus (1) gives
\[
\mathbb E\|h+Z\|^4\le e^2F(x,d),\qquad
F(x,d)=3-2x^4+4x(1-x^2)d+(1-x^2)d^2.
\]
The elementary exact rational polynomial certificate below proves
\[
\boxed{
 (1-d/4)^2F(x,d)\le3
 \quad(0\le x\le1,\;0\le d\le4).
}\tag{2}
\]
If \(d\ge4\), (SM) is trivial since \(c/4\ge\sqrt e\). Otherwise interpolate \(L^1,L^2,L^4\):
\[
 e^{3/2}=(\mathbb E\|h+Z\|^2)^{3/2}
 \le u\,(\mathbb E\|h+Z\|^4)^{1/2}
 \le u\,e\sqrt{F(x,d)}.
\]
Therefore \(u\ge\sqrt e/\sqrt{F(x,d)}\), and (2) gives
\[
\sqrt3u\ge(1-d/4)\sqrt e
=\sqrt e-c/4.
\]
This proves the lemma, including \(e=0\) by direct inspection.

**Exact algebra checker:** from repository root run

```sh
python3 research/nightfall/2026-11-quadratic-law-free-audit/check_shifted_owner_moment_107.py
```

The checker expands \(P(x,t)=3-(1-t)^2F(x,4t)\) over \([0,1]^2\), transforms exactly into degree-(4,4) rational Bernstein coefficients, and subdivides the rectangle at dyadic midpoints. At each leaf all 25 Bernstein coefficients are **nonnegative**; by the convex-hull property this proves \(P\ge0\) over that entire box, not merely a grid of sample points. The exact rational certificate has **15 nodes and 8 leaves**. Independently asserted leaf minima:
- \(x\in[0,1/4], t\in[0,1/2]\): \(0\).
- \(x\in[0,1/2], t\in[1/2,1]\): \(11/16\).
- \(x\in[1/4,1/2], t\in[0,1/4]\): \(1/128\).
- \(x\in[1/4,1/2], t\in[1/4,1/2]\): \(21/256\).
- \(x\in[1/2,3/4], t\in[0,1/4]\): \(15/256\).
- \(x\in[1/2,3/4], t\in[1/4,1/2]\): \(15/128\).
- \(x\in[1/2,1], t\in[1/2,1]\): \(25/32\).
- \(x\in[3/4,1], t\in[0,1/2]\): \(1693/3072\).

The checker tests polynomial corner values independently of the Bernstein transform. This is an **exact arithmetic certificate for (2)**, not an independent proof of the Hilbert moment expansion, owner independence, source projection or global terminal theorem.

## Source composition — three honest coefficient levels

Fix the actual finite independent source. Let \(\mathcal H_i=L^2(p_i)\) (real-valued). The canonical singleton \(h_i\in\mathcal H_i\) is deterministic. For a fixed owner \(i\), let
\[
Y_{ij}(\cdot)=h_{ij}(\cdot,X_j),\quad
Z_i=\sum_{j\in N_i}Y_{ij},\quad
e_i=\|h_i\|^2+\mathbb E\|Z_i\|^2.
\]
The \(X_j\), \(j\in N_i\), are distinct and independent under the original product; the centered Hilbert increments satisfy \(\|Y_{ij}\|\le c_i\). Conditional expectation of the full coordinate section onto the sigma-field of \(X_{N_i}\) gives exactly \(h_i+Z_i\); Jensen therefore yields
\[
\mathbb E\|h_i+Z_i\|\le
u_i:=\mathbb E\Big\|h_i+\sum_{j\ne i}h_{ij}(\cdot,X_j)\Big\|.
\tag{3}
\]
By (SM), \(\sqrt{e_i}\le\sqrt3\,u_i+c_i/4\). Since \(e_i\le I_i(f)\le M\),
\[
e_i\le\sqrt M\,\sqrt{e_i}
\le\sqrt M\,(\sqrt3\,u_i+c_i/4).
\]
Summing over owners **without assuming independence between different owners**,
\[
\boxed{
V=\sum_i e_i\le\sqrt M\left(\sqrt3\sum_i u_i+
 \frac14\sum_i c_i\right).
}\tag{4}
\]
If the original-source section budget is \(\sum_i u_i\le U B\) and
\(\sum_i c_i\le8B\), (4) yields
\[
\boxed{\operatorname{Var}_p(f)^2\le(\sqrt3\,U+2)^2 B^2 M.}\tag{5}
\]
Three applications, **not three separately certified theorems**:

| Source section budget | Coefficient \((\sqrt3U+2)^2\) | Additional gate |
|---|---:|---|
| \(U=8\) | \(251.4256258422\ldots\) | **New shifted Hilbert lemma and source projection**; existing 8B source budget |
| \(U=5\) | \(113.6410161514\ldots\) | The above plus PR #525's 5B source gate, which has not passed at the previously checked head |
| \(U=2(1+\sqrt2)\) | \(107.3934498998\ldots\) | The above plus PR #525's uncompiled sharp biased-switching section budget |

This gives a route **strictly below 353.293 that does not depend on the sharp switching operator**, with the \(251.426\) target. The \(107.393\) target uses both mechanisms. The exact optimal constant remains at least \(4\) by PR #521's independently established analytic witness.

### Where the old operator loses information

The previous fourth-moment route first controls the *unshifted* \(Z_i\) and subsequently estimates \(\mathbb E\|Z_i\|\le u_i+\|h_i\|\). The new operator directly controls \(W_i=h_i+Z_i\), and source conditional projection bounds its **own** first moment by \(u_i\). The singleton enters its second moment \(e_i\) automatically. This removes the need to pay a separate additive budget, eliminates the scalar golden-cubic interpolation, and replaces its larger coefficient by \(\sqrt3\,U+2\).

## Certification and independent attack plan

1. **Lean lemma:** implement Hilbert fourth-moment expansion with a deterministic shift and exact \(c/4\) scalar interpolation (or check a theorem-level rational Bernstein proof). Audit zero moments and arbitrary-dimensional real inner-product spaces.
2. **Source gluing:** prove original-source owner projection (3), bound each owned \(Y_{ij}\) by the *same actual* \(c_i\), and use the existing owner partition \(V=\sum e_i\). The final statement must have only genuine \(p,f,B,M,\deg f\) inputs; do not introduce a supplied shifted-moment lemma as an axiom.
3. **Decisive first experiment:** target \(U=8\) and **\(251.425626\)** using only already accepted source section and cover modules; do not wait for PR #525's \(5B\) or sharp switch.
4. **Proof attacks:** search for a failure of Jensen on true owned-neighbor sigma fields; verify third-order Hilbert cross terms vanish with arbitrary biased marginals; verify \(c_i\) pointwise bounds including zero atoms; inspect exact polynomial checker separately.
5. **Prior art:** the fourth-moment bound is related to classical Hilbert/Rosenthal and Khintchine inequalities (e.g. Ibragimov–Sharakhmetov and de la Peña–Giné), so no global originality claim. Earlier categorical root-influence summability is explicitly *false* by the address counterexample archived in Q2_GROTHENDIECK_DECOUPLING_SCOPE_AUDIT_20261113.md; this proof uses a different owner-local mechanism.
6. **Promotion stop:** no theorem certification or publication claim until the composed source-only named Lean declaration passes pinned strict compilation and its axiom receipt; specialist non-author review and historical priority remain separate gates.

**Discovery graph:** degree-two original law -> owned-neighbor independent Hilbert representation -> **shift the singleton before fourth-moment interpolation** -> rational Bernstein correction \(1/4\) -> conditional source projection and budgets -> candidate coefficients \(251.426\), \(113.641\), \(107.393\) -> Lean/source/priority gates -> potential transfer to rank-adaptive observation only after a separately proved vector/posterior lift.
