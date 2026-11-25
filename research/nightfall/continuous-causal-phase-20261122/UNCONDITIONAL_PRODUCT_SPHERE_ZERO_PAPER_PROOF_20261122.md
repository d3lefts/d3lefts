# Unconditional product-sphere zero theorem: a differential-topological proof

**NIGHTFALL paper proof v1.0 — 2026-11-22 (America/Chicago).**  
**Scope:** Complete mathematical proof of the *pure-character* product-sphere zero theorem, independent of importing the product-sphere Borsuk–Ulam theorem as a premise. Uses standard, named foundational results: real Stone–Weierstrass, Sard's theorem, the finite-dimensional inverse-function/regular-value theorems, and the classification of compact connected one-manifolds with boundary. This is a paper proof, **not** a Lean compiler receipt or independent non-author review. Its mathematical conclusion is classical; originality is not asserted. It discharges the R/T/E hypotheses of the earlier conditional all-point atlas construction for a **generic concrete augmented homotopy**, rather than asserting them for every parameter.

## Theorem (unconditional)

Let \(n\geq1\), \(0\le r,s\le n-1\), and \(S^{n-1}\subset\mathbb R^n\) the unit sphere. If continuous maps
\[
 f_U:S^{n-1}\times S^{n-1}\longrightarrow\mathbb R^r,\qquad
 f_V:S^{n-1}\times S^{n-1}\longrightarrow\mathbb R^s
\]
satisfy, for all unit \(u,v\),
\[
\begin{aligned}
 f_U(-u,v)&=-f_U(u,v), & f_U(u,-v)&=f_U(u,v),\\
 f_V(-u,v)&= f_V(u,v), & f_V(u,-v)&=-f_V(u,v),
\end{aligned}
\]
then some unit \(u,v\) satisfy \(f_U(u,v)=0=f_V(u,v)\).

In the repository this is the full proposition
\`Nightfall.ProductSphereObstruction.ProductSphereZero n r s\`
under \(1\le n\) and \(r,s\le n-1\). The condition \(n\ge1\) matters: with truncated natural subtraction \(n-1\), the bare maximal declaration at \(n=0\) would be **false**, since \(S^{-1}\) is empty.

## Proof

### 1. Reduction to the square target and equivariant polynomial inputs

For \(n=1\), necessarily \(r=s=0\), and any pair of unit vectors is a simultaneous zero. Suppose henceforth \(n=k+1\) with \(k\ge1\). Padding either target block with zero coordinates preserves all four parity identities and does not change its zero set. It therefore suffices to prove the maximal case \(r=s=k\).

Assume, for a contradiction, that \(f=(f_U,f_V):S^k\times S^k\to\mathbb R^{2k}\) is nowhere zero. Compactness gives
\[
\delta:=\min_{(u,v)\in S^k\times S^k}\|f(u,v)\|>0.
\]
By the real Stone–Weierstrass theorem, each scalar component of \(f\) admits a uniformly close polynomial approximation in the \(2(k+1)\) ambient coordinates. Enforce the characters exactly by applying the two finite-group projections
\[
\begin{aligned}
(P_U h)(u,v)&=\tfrac14\bigl[h(u,v)-h(-u,v)+h(u,-v)-h(-u,-v)\bigr],\\
(P_V h)(u,v)&=\tfrac14\bigl[h(u,v)+h(-u,v)-h(u,-v)-h(-u,-v)\bigr].
\end{aligned}
\]
Each projection is a contraction in the uniform scalar norm and fixes every function with its prescribed character. Applied componentwise to sufficiently close polynomial approximations, these yield **globally polynomial** maps \(g_U,g_V:\mathbb R^{k+1}\times\mathbb R^{k+1}\to\mathbb R^k\) satisfying the required parity identities at *every* ambient point and
\[
\|(g_U,g_V)-f\|_{\infty,S^k\times S^k}<\delta/2.
\]
Consequently \(g=(g_U,g_V)\) is nowhere zero on the sphere product. We derive a contradiction for this polynomial \(g\); therefore the original continuous \(f\) cannot have been zero-free.

### 2. Construct the actual augmented parameter homotopy

Write \(u=(u_0,\bar u)\) and \(v=(v_0,\bar v)\), where \(\bar u,\bar v\in\mathbb R^k\). Let
\[
F_0(u,v)=(\bar u,\bar v),\qquad F_1(u,v)=g(u,v).
\]
Let
\[
P=\mathbb R^{k\times(k+1)}\times\mathbb R^{k\times(k+1)}
\]
be the parameter space of two matrices \((A,B)\). Define for all real \(t\)
\[
H_{A,B}(u,v,t)=(1-t)F_0(u,v)+tF_1(u,v)
                  +t(1-t)(Au,Bv)
\]
and the **augmented Euclidean equation**
\[
\mathcal E(A,B;u,v,t)
=\left(H_{A,B}(u,v,t),\,\|u\|^2-1,\,\|v\|^2-1\right).
\tag{1}
\]
The domain of \(\mathcal E\) is \(P\times X\), where
\(X=\mathbb R^{k+1}\times\mathbb R^{k+1}\times\mathbb R\)
has dimension \(2k+3\), and the codomain
\(Y=\mathbb R^{2k}\times\mathbb R^2\)
has dimension \(2k+2\). All maps are polynomial and hence \(C^\infty\).
Each zero of \(\mathcal E\) has \(\|u\|=\|v\|=1\).

The independent sign flips
\((u,v,t)\mapsto(-u,v,t)\) and
\((u,v,t)\mapsto(u,-v,t)\)
preserve the zero set of (1), for every fixed \((A,B)\): under the first flip the \(U\)-response changes sign while the \(V\)-response and both norm defects remain unchanged, and conversely under the second flip.

### 3. Full derivative surjectivity on the **entire** parameterized zero locus

We claim that zero is a regular value of the joint map
\(\mathcal E:P\times X\to Y\), including all real times, not merely \(0\le t\le1\).

Fix any zero \((A,B;u,v,t)\).

**If \(t\notin\{0,1\}\):** Given an arbitrary prescribed target variation \((a,b,\rho,\sigma)\in\mathbb R^k\times\mathbb R^k\times\mathbb R^2\), choose
\[
\dot u=(\rho/2)u,\qquad \dot v=(\sigma/2)v,\qquad \dot t=0.
\]
Since \(u,v\) are unit, the norm-defect derivatives become exactly \(\rho,\sigma\).
Let \(c_U,c_V\) denote the first two derivative-block contributions made by these spatial variations with \(\dot A=\dot B=0\). Their specific values are irrelevant. Set \(d=t(1-t)\ne0\) and choose rank-one matrix variations rowwise by
\[
\dot A_{ij}=\frac{a_i-(c_U)_i}{d}\,u_j,\qquad
\dot B_{ij}=\frac{b_i-(c_V)_i}{d}\,v_j.
\]
Using \(\sum_j u_j^2=\sum_j v_j^2=1\),
\[
d\,\dot A u=a-c_U,\qquad d\,\dot B v=b-c_V.
\]
Thus the **true total derivative** of (1), applied to
\((\dot A,\dot B;\dot u,\dot v,0)\), is exactly
\((a,b,\rho,\sigma)\). It is surjective.

**If \(t=0\):** At a zero, \(H_{A,B}=F_0\), so
\(\bar u=\bar v=0\) and \(u_0,v_0\in\{-1,+1\}\).
The derivative of (1) with respect to the spatial variables alone is the square linear map
\[
(\dot u,\dot v)\longmapsto
\left(\overline{\dot u},\,\overline{\dot v},
       2u_0\dot u_0,\,2v_0\dot v_0\right).
\tag{2}
\]
Because \(u_0,v_0=\pm1\), (2) is invertible: the tail coordinates determine the tails of \(\dot u,\dot v\), and the last two outputs uniquely determine their first coordinates. Hence the full derivative is surjective. This also proves entrance-face transversality for **every** parameter \((A,B)\).

**If \(t=1\):** The first output block is \(F_1(u,v)=g(u,v)\), and the norm defects force unit \(u,v\). Since \(g\ne0\) on \(S^k\times S^k\), no zero exists. This case is vacuous.

All cases are exhausted; the joint map (1) is transverse to \(0\). \(\square\)

### 4. Choose a genuinely regular matrix pair by Sard, rather than assuming one

The total zero locus \(\mathcal M=\mathcal E^{-1}(0)\) is a smooth manifold of dimension \(\dim P+1\) by the regular-value theorem, since the full derivative is onto at every zero by §3.

Consider the smooth parameter projection \(\pi:\mathcal M\to P\). Sard's theorem says its critical values form a measure-zero subset of \(P\). Choose a regular value \(p=(A,B)\) of \(\pi\), possible because \(P\) has positive Lebesgue measure.

For clarity, **regularity of the projection entails regularity of the slice** and is not an extra assumption. Fix \(x\in X\) with \(\mathcal E(p,x)=0\), and let \(y\in Y\) be arbitrary. Surjectivity of the *joint* derivative supplies \((h,w)\in T_pP\times T_xX\) such that
\[
D\mathcal E_{(p,x)}(h,w)=y.
\]
Since \(p\) is a regular value of \(\pi\), its differential on
\(T_{(p,x)}\mathcal M=\ker D\mathcal E_{(p,x)}\)
is onto. Therefore some \((h,w')\in\ker D\mathcal E_{(p,x)}\) projects to the **same** \(h\). Subtracting,
\[
D_x\mathcal E_{(p,x)}(w-w')=y.
\]
Thus \(D_x\mathcal E_{(p,x)}\) is surjective. Because \(x\) was any slice zero, \(0\) is a regular value of the fixed smooth map
\[
E:X\to Y,\qquad E(x)=\mathcal E(p,x).
\tag{3}
\]
This **discharges interior regularity R** for the actual chosen matrix pair, without supposing it a priori. At \(t=0\), (2) **discharges T**, and at \(t=1\) the zero-free input **discharges E**.

### 5. Build the entire smooth one-manifold-with-boundary, including turning points and overlaps

The unconstrained level set \(M=E^{-1}(0)\) is a smooth embedded **one-dimensional** manifold without boundary: \(\dim X-\dim Y=1\) and (3) is regular. Define its genuine closed-time part
\[
Z=\{(u,v,t)\in M:0\le t\le1\}.
\tag{4}
\]
It is compact: the constraints in \(E=0\) force \(u,v\) into the compact sphere product, \(t\in[0,1]\), and the zero condition is closed. There are no points with \(t=1\).

We construct charts at **every** point of (4), not just at points where time happens to be a valid coordinate.

**Interior zero \(0<t_0<1\).** Let \(x_0=(u,v,t_0)\in Z\). The surjective map \(DE_{x_0}:X\to Y\) has one-dimensional kernel. Pick a nonzero vector \(w\) in that kernel, and choose a linear functional \(\ell:X\to\mathbb R\) with \(\ell(w)=1\). The square map
\[
Q_{x_0}(x)=\bigl(\ell(x-x_0),E(x)\bigr):X\to\mathbb R\times Y
\tag{5}
\]
has invertible derivative at \(x_0\): its derivative's kernel is the intersection of \(\ker DE_{x_0}=\mathbb Rw\) and \(\ker\ell\), which is zero, and the domain and codomain have equal dimension. By the smooth inverse-function theorem, (5) is a \(C^\infty\) diffeomorphism between open neighborhoods of \(x_0\) and \((0,0)\). Restricting (5) to \(M\) makes its zero fiber **exactly** the local graph
\[
x=Q_{x_0}^{-1}(a,0).
\]
Shrink the source neighborhood so its time coordinates satisfy \(0<t<1\). Then \(a\), or the positive half-space coordinate \(e^a\), defines an actual smooth interior chart on \(Z\). **This includes turning points with \(dt(w)=0\)**; no invertibility of \(D_{(u,v)}E\) is claimed or needed there.

**Entrance zero \(t_0=0\).** The spatial derivative \(D_{(u,v)}E\) is invertible by (2). Applying the smooth implicit-function theorem to the pair \((t,(u,v))\), on a single open ambient neighborhood we obtain a **smooth** function \(\psi\) on a real open interval \(J\ni0\) such that its exact zeros near \(x_0\) are \((\psi(t),t)\). Restrict to \(t\in J\cap[0,1)\). The time coordinate itself is a chart onto a relatively open neighborhood of \(0\) in the model half-line \([0,\infty)\). Its inverse \(t\mapsto(\psi(t),t)\) is smooth, with a real-open extension through negative time. This establishes a genuine boundary chart at **each** time-zero zero.

**Exhaustive cover.** Every point of \(Z\) has \(0\le t\le1\); there are no points with \(t=1\). If \(t=0\), the preceding boundary chart covers it; otherwise \(0<t<1\), the kernel-split interior chart covers it. Each source is open in the *original subspace topology* on the actual zero set (4), being an open ambient neighborhood intersected with (4).

**\(C^\infty\) compatibility.** On any overlap of two interior charts, the coordinate transition is the restriction of compositions of the \(C^\infty\) ambient local inverses from (5), the linear functionals \(\ell\), and smooth \(e^a,\log a\) changes. Between a boundary chart and an interior chart, every overlap point has \(t>0\), so the transition is a restriction of a composition of those same ambient smooth maps and the smooth zero-graph \((\psi(t),t)\). On an overlap of two entrance charts, **both forward coordinates are exactly the physical time \(t\)**, so the transition is the identity. Thus all overlaps are smooth in the manifold-with-boundary sense. No invalid inference from \(C^\infty\) at a single point to one common \(C^\infty\) neighborhood is used; each inverse-function theorem gives a genuine smooth local diffeomorphism on an *open set*.

**Exact boundary.** Every interior chart takes values in \((0,\infty)\), hence every point with \(t>0\) is an interior point. Every time-zero chart maps its base point to \(0\), hence every point with \(t=0\) is a boundary point. Since no \(t=1\) zero exists,
\[
\partial Z=Z\cap\{t=0\}
 =\{(\varepsilon e_0,\eta e_0,0):\varepsilon,\eta\in\{-1,+1\}\},
\qquad |\partial Z|=4.
\tag{6}
\]
Equations (4)–(6) **discharge actual global atlas covering, smooth compatibility, and physical boundary identification** mathematically, not as supplied topological premises.

### 6. Four-point free-orbit obstruction: \(4\ge8\) contradiction

The group \(G=(\mathbb Z/2)^2\) acts on \(Z\) by independently flipping \(u\) and \(v\), keeping \(t\) fixed. Equivariance of the polynomial \(H_{A,B}\) and invariance of the norm constraints show this action preserves the **actual** zero set. Each group element acts by a homeomorphism. The action is **free**: a nonidentity element negates at least one unit vector, which cannot equal its negative. It preserves (6).

Take \(p_0=(e_0,e_0,0)\in\partial Z\), and let \(C\) be its connected component. A one-manifold is locally connected, so connected components are open; they are always closed. Hence \(C\) is a compact connected one-manifold with boundary, and its boundary is nonempty (it contains \(p_0\)). By the standard classification of compact connected one-manifolds with boundary,
\[
C\cong[0,1],
\]
and \(C\) has exactly **two** distinct boundary points.

If a nonidentity \(h\in G\) preserved \(C\), then the continuous self-map \(h|_C:C\to C\), conjugated by a homeomorphism \(C\cong[0,1]\), would have a fixed point by the elementary interval fixed-point theorem. That contradicts the free action. Therefore \(C\) has trivial stabilizer in \(G\), so its orbit consists of **four distinct connected components** \(gC\), \(g\in G\).

Each \(gC\) is an interval component and has two distinct boundary points. Different components are disjoint, so this forces at least \(4\times2=8\) distinct boundary points of \(Z\). But (6) gives exactly four. Contradiction.

Our assumption that \(g\), hence \(f\), was nowhere zero is false. Thus the maximal two-block map has a simultaneous zero. Zero-padding gives the theorem for every \(r,s\le n-1\). \(\blacksquare\)

## Independent mathematical cross-check (different proof mechanism, not a non-author audit)

There is also a short characteristic-class proof. Over \(B=\mathbb RP^{n-1}\times\mathbb RP^{n-1}\), an equivariant pair \((f_U,f_V)\) induces a section of
\(L_U^{\oplus r}\oplus L_V^{\oplus s}\). With mod-2 degree-one generators \(\alpha,\beta\),
\[
H^*(B;\mathbb F_2)=\mathbb F_2[\alpha,\beta]/(\alpha^n,\beta^n),
\quad
w_{r+s}\!\left(L_U^{\oplus r}\oplus L_V^{\oplus s}\right)
=\alpha^r\beta^s\ne0
\]
when \(r,s<n\) and \(r+s>0\). A nowhere-zero section would split off a trivial real line, forcing the top Stiefel–Whitney class to vanish. This contradiction proves the same theorem (for \(r+s=0\), take any point). This checks the theorem by a mechanism independent of the augmented Sard/one-manifold argument; it is **not** an independent non-author proof review.

## Verification, boundaries of claims, and source correspondences

- **Mathematical status:** unconditional complete paper proof *relative only to the named standard foundational theorems*; the actual derivative regularity, good-parameter existence, all-point atlas, smooth overlaps, boundary set and free-orbit contradiction are all derived above. It does **not** assume the product-sphere Borsuk–Ulam theorem.
- **Formal status:** not Lean-compiled end-to-end. Existing exact source components include \`ProductBUParityReference\`, \`ProductBUEndpointRank\`, \`ProductBUAugmentedRank\`, \`ProductBUConcreteHomotopy\`, \`ProductBURegularParameter\`, \`ProductBUCompactFiber\`, \`ProductBUCompatibleAtlas\`, and the source-exact atlas terminal. Their partial/conditional receipts do not certify this assembled proof.
- **Priority:** the underlying product-sphere zero theorem is classical; compare Chan–Chen–Frick–Hull's product-of-spheres Borsuk–Ulam results and earlier equivariant obstruction theory. No originality claim for the zero theorem itself.
- **Edge controls:** \(n=1\) trivial; \(n=0\) must be excluded; rank padding handles \(r=0\) and/or \(s=0\); Sard is applied on **all real times**, including negative times and times \(>1\); time-zero spatial derivative is square/invertible; terminal time \(t=1\) is empty; interior charts do **not** use time as a forced coordinate; free action on points implies free action on an interval **component** by fixed-point contradiction; eight distinct endpoints contradict the four reference boundary zeros.
- **Outstanding certification contract:** formalize the actual finite-dimensional derivative identity and application of Sard to a good parameter, the regular level-set/local halfspace chart atlas, and the final interval component contradiction, with exact source/axiom audit and independent adversarial review. Nothing in this paper proof is a claim of a successful Lean run.

**Related source manuscripts:** \`AUGMENTED_EUCLIDEAN_PRODUCT_BU_SARD_REDUCTION.md\` and \`ALL_POINT_HALFSPACE_ATLAS_CONSTRUCTION_20261123.md\`; constituent Lean and mathematical contributions retained under their original authorship and PRs.