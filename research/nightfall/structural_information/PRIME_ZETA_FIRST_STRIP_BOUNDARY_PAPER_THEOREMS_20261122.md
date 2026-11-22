# Prime-zeta deformation: promoted paper-level theorems and scope (v2.0)

**Research status (2026-11-22): PAPER THEOREM, DERIVATION CHECKED; independent specialist review and Lean kernel replay OPEN.** This document promotes two results from working proof *candidates* to **explicitly stated, self-contained paper theorems**. It does not claim a named formal proof, an external referee, or global novelty. Do not substitute "paper theorem" for "Certified Construction" or "Theorem" as defined by NIGHTFALL's strict certification ladder.

**Source identity.** September 2026 manuscript `affine_source_rigidity_v_final_corrected.tex`, *Affine Source Rigidity and Möbius Cancellation in a Shifted Prime-Zeta Deformation*. Previous research checkpoint: [PR #1035](https://github.com/d3lefts/d3lefts/pull/1035), merged as `e71ed7d14e4bdd9b11b5c1dc71c801794d08a8ef`. Independent proof-attack issue: [#1040](https://github.com/d3lefts/d3lefts/issues/1040).

## Definitions and two classical inputs

\[
P(w)=\sum_{p\ \mathrm{prime}}p^{-w}\qquad(\Re w>1),\qquad
A^+(s)=\sum_p((p-1)^{-s}-p^{-s})\qquad(\Re s>0).
\]
The paper establishes the locally normally convergent identity
\[
A^+(s)=sP(s+1)+H(s),\quad
H(s)=\sum_{j\ge2}\frac{(s)_j}{j!}P(s+j),\quad
H\in\mathcal O(\Re s>-1).
\]
Classical dependencies: Möbius inversion `P(w)=sum_{m>=1} mu(m)/m log zeta(mw)` on \(\Re w>1\), logarithmic derivative of \(\zeta\), zero-free line \(\Re w=1\) away from \(w=1\) (Hadamard/de la Vallée Poussin); and **the established natural boundary** \(\Re w=0\) of prime zeta (Landau–Walfisz; Fröberg). They are **imported predecessors**, not results of NIGHTFALL.

## Theorem 1 — complete first-strip local criterion

Let \(\rho\) be any nontrivial zero of \(\zeta\), \(n\ge1\), \(\lambda=\rho/n\) and \(s_0=\lambda-1\). Define the finite active dilation fiber
\[
F_\lambda=\{m\ge1:\mu(m)\ne0,\ \zeta(m\lambda)=0\},\quad
r_{m\lambda}=\operatorname{ord}_{m\lambda}\zeta,\quad
M(\lambda)=\sum_{m\in F_\lambda}\frac{\mu(m)}{m}r_{m\lambda}.
\]
There is a local analytic continuation of the original \(A^+\) in a punctured disk around \(s_0\), with local branch form
\[
\boxed{A^+(s)=sM(\lambda)\log(s-s_0)+g(s),\qquad g\in\mathcal O(s_0).}
\]
Therefore the continued germ extends holomorphically through \(s_0\) **if and only if** \(M(\lambda)=0\). Otherwise the monodromy around \(s_0\) at basepoint \(s\) is \(2\pi i sM(\lambda)\ne0\). This is unconditional with respect to RH and DOES NOT require the manuscript's additional all-layer normal-convergence hypothesis.

**Independent proof reconstruction.** In \(\Re w>1\), differentiate Möbius inversion to obtain
\[
D(w):=P'(w)=\sum_{m\ge1}\mu(m)\frac{\zeta'(mw)}{\zeta(mw)}.
\]
On any compact \(K\subset\{\Re w>0\}\) with \(a=\inf_K\Re w>0\), choose \(m_0\) such that \(ma\ge2\) for \(m\ge m_0\). The absolutely convergent von-Mangoldt expansion gives
\[
\sup_{w\in K}\left|\frac{\zeta'(mw)}{\zeta(mw)}\right|
\le\sum_{\ell\ge2}\Lambda(\ell)\ell^{-ma}=O_K(2^{-ma}).
\]
The tail converges normally; only finitely many low-index terms remain, all meromorphic. Thus \(D\) extends single-valuedly and meromorphically to \(\Re w>0\).

At nonreal \(\lambda\), only nontrivial zeta zeros contribute poles; since \(0<\Re(m\lambda)<1\), necessarily \(m<1/\Re\lambda\). If \(m\lambda\) is a zero of order \(r\), the local term \(\zeta'(mw)/\zeta(mw)\) has residue \(r/m\) at \(w=\lambda\). Therefore
\[
D(w)=\frac{M(\lambda)}{w-\lambda}+G(w),
\qquad G\in\mathcal O(\lambda).
\]
A local primitive is \(P(w)=M(\lambda)\log(w-\lambda)+p(w)\) with \(p\) holomorphic. This is an analytic-continuation branch of the original prime-zeta germ because the derivative agrees in the initial domain. Substitution in the proved shifted decomposition yields the asserted formula, with \(g(s)=s p(s+1)+H(s)\). Because \(s_0\ne0\), the nontrivial monodromy coefficient vanishes **precisely** with \(M\). QED.

**Arithmetic certificate.** For \(D_\lambda=\operatorname{lcm}F_\lambda\) (1 if empty), the integer \(A_\lambda=\sum_{m\in F_\lambda}\mu(m)(D_\lambda/m)r_{m\lambda}\) satisfies \(M=A_\lambda/D_\lambda\). Thus once a **complete certified** zero fiber is known, checking \(A_\lambda=0\) decides removability exactly. A nonzero coefficient obeys \(|s_0 M|\ge |s_0|/D_\lambda\). There is no known actual multi-member rational-dilation zero fiber supplied by the numerical checker; synthetic tests are arithmetic negative controls only.

## Theorem 2 — natural boundary at Re(s) = -1

Assume the classical prime-zeta natural boundary: no branch of \(P(w)\) continues holomorphically across any point of \(\Re w=0\). Then
\[
\boxed{\Re s=-1\text{ is a natural boundary for ordinary analytic continuation of }A^+(s).}
\]
The theorem is **unconditional in the usual sense**, i.e. its hypothesis is an already-established classical theorem, not RH or a new conjecture.

**Independent proof reconstruction.** Write
\[
H(s)=\frac{s(s+1)}2P(s+2)+H_3(s),\quad
H_3(s)=\sum_{j\ge3}\frac{(s)_j}{j!}P(s+j).
\]
The exponentially decaying prime-zeta tail and polynomial Pochhammer growth imply \(H_3\) is holomorphic for \(\Re s>-2\). At every \(s_*=-1+it\) with \(t\ne0\), \(s_*+2=1+it\) has \(\zeta(1+it)\ne0\); the other Möbius channels have real part at least 2, so \(P\) has a holomorphic local branch at \(1+it\). Hence \(H\) extends holomorphically through \(s_*\). If a continuation branch of \(A^+\) extended through \(s_*\), the quotient
\[
P(s+1)=\frac{A^+(s)-H(s)}s
\]
would extend prime zeta through \(it\), contradicting its established natural boundary. Since \(s_*\ne0\), division is harmless. No extension at the real point \(-1\) is possible either: an extension there would cover nearby nonreal boundary points. QED.

**Boundary scope.** Deeper formal coordinates \(\rho/n-k\) with \(k\ge2\) lie to the left of this line. Algebraic source-rigidity remains true there, but they cannot be interpreted as reachable ordinary analytic germs of the originally defined \(A^+\). This does not exclude separately defined generalized continuations or regularizations.

## Certification, dependency, and significance ledger

| Gate | First-strip | Boundary |
|:--|:--|:--|
| Exact theorem statement and written derivation | Supplied in this source | Supplied in this source |
| Classical input | Prime-zeta Möbius inversion, zeta meromorphy, zero-free line | Prime-zeta natural boundary; zero-free line |
| Independent exact numerical certificate | Synthetic fiber arithmetic only | Not applicable: analytic theorem |
| Independent non-author review | **Open, issue #1040** | **Open, issue #1040** |
| Named Lean kernel replay | **Absent** | **Absent** |
| Dated global priority clearance | **Open** | **Open** |
| External publication/submission | **Not authorized by this status update** | **Not authorized by this status update** |

This promotion authorizes **paper-level theorem presentation with full assumptions, classical attribution and explicit review status**; it does **not** authorize a "Lean-certified theorem" or a "Novel Contribution" badge.

**External sources, priority caution:** Fröberg, *On the prime zeta function*, BIT 8 (1968) 187–202, DOI 10.1007/BF01933420; MathWorld, *Prime Zeta Function* (attributes the natural boundary to Landau–Walfisz 1920); NIST DLMF §25.10 zero-free line; existing 2015 Pacific Journal of Mathematics discussion of prime-zeta natural boundaries. A literature search supports the classical inputs, but does not establish that the shifted-deformation corollaries are first discoveries. Full Fröberg text and a named specialist review remain uninspected.

**Next decisive independent checks:** (1) reconstruct the compact-uniform tail and each residue without citing #1035; (2) check branch-independent holomorphic-extension logic; (3) verify \(H_3\) across every nonreal boundary point and the classical theorem's all-branch scope; (4) reconcile publication priority from primary texts. Failures trigger demotion.


## 2026-11-22 direct prior-art correction: the residue mechanism is classical

The currently accessible MathWorld article *Prime Zeta Function*, equations (10)–(11) and the paragraphs immediately after them, explicitly states **all** of the following for P itself: (i) the Möbius-inversion and logarithmic-derivative identities, (ii) single-valued meromorphic continuation of P' into Re(w)>0, (iii) residues μ(m)r_{mλ}/m at scaled nontrivial zeta zeros, and (iv) addition of coincident residues and removability when their sum vanishes. Source: https://mathworld.wolfram.com/PrimeZetaFunction.html ; checked 2026-11-22. Thus **none of (i)–(iv) is new mathematics contributed by NIGHTFALL**.

The first-strip theorem for A⁺ is the **shifted corollary** obtained using the September manuscript's A⁺=sP(s+1)+H. The classical natural boundary of P is likewise prior art, and the boundary at Re(s)=−1 is its transfer through this holomorphic decomposition. No global originality claim is warranted for either. Future publication must foreground the classical provenance and identify any additional nontrivial contribution separately.
