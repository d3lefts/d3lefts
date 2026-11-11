# Spectral Certificate-to-Observation — Frontier Theorem Ledger

**Research program:** NIGHTFALL, directed by Devin J. Wright  
**Checkpoint:** 10 November 2026 US/Eastern / 11 November UTC  
**Purpose:** A public, falsifiable ranking of the strongest mathematical results and hypotheses in the product-space / adaptive-observation program.  
**Validity ≠ formalization ≠ novelty ≠ significance.** A merged commit does not imply external mathematical review.

## The central research question

> **What are the strongest novel theorems NIGHTFALL has to date?**

The correct present-tense response is **no theorem in this research cluster has yet been independently established as globally novel and more important than Turturean's resolution of Aaronson–Ambainis**. The strongest kernel-checked new *domain extension* is finite heterogeneous-product influence. The highest-upside *candidate standalone theorems* are spectral adaptive prediction and the all-degree linear-interaction-support result. They are not yet Lean-certified or externally reviewed.

The proposed **Spectral Certificate-to-Observation Principle** is a research synthesis, not a single certified theorem: low interaction order and structured output covariance can bound the coordinate observations needed for prediction, while certificate overlap gives a concrete coordinate sampler and posterior resampling influence gives a descent potential.

## Proof dependency graph

| Stage | Mechanism and formal content | Verification |
|---|---|---|
| Input | Turturean's 2026 antipodal determinant and uniform Boolean-cube Aaronson–Ambainis theorem | **Imported external theorem**, pinned upstream Lean source; credit original author |
| Transport | Independent two-draw orientation, weighted finite product reciprocal inequality, localized two-sided theorem, competing-symbol row bound | **Lean-checked finite-product statements** in NIGHTFALL repository, subject to exact common-alphabet / positive-mass / normalization hypotheses at each declaration |
| Product-space influence | For finite heterogeneous products (including zero-mass atoms and heterogeneous alphabets via extension), $|f|\le1$, degree $d$, variance $V$: some coordinate $i$ obeys $3V^5\le12500(\pi^2d^2)^6I_i(f)^2$ | **Lean-checked** in merged PRs #317/#325, pinned Lean 4.33.0 receipts; inherits Turturean mechanism |
| Concrete observation | Nonconstant Boolean certificate overlap sampler and direct one-query posterior influence decrement, $\mathbb E[T_{\rm post}]\le T-\operatorname{Var}(g)/K^2$ under normalized finite laws and valid cost-$K$ rows | **Lean-checked** finite-product bridge in merged PRs #304/#308/#309/#312; do not conflate with whole-policy prediction |
| Quadratic structural operator | Matching of degree-two Hoeffding interactions, pointwise oscillation control and independent Hilbert-valued fourth moments yield $\operatorname{Var}(f)\le D B\sqrt{\max_i I_i(f)}$, $D=16(1+\sqrt3)$ | **Paper proof + internal exact checks**, no standalone kernel certificate / nonauthor referee |
| Spectral prediction | For Hilbert-valued degree $\le2$ observables with covariance spectral tail $\tau_r$, $N=O(rB^2/\eta)$ adaptive coordinate observations suffice for MSE $\le\tau_r+\eta$; $\Theta(r/\eta)$ claimed minimax for unit ball and rank $r$ | **Paper proof and matching lower construction**, no end-to-end Lean or independent priority clearance |
| Categorical fixed design | For degree $\le d$, coordinate alphabets of size $\le m$, fixed nonadaptive observation cost $\Theta_d(rm^{d-1}/\eta)$ claimed for unit-ball rank-$r$ output | **Paper proof + internal checks**, not Lean / externally certified; depends on signed categorical moments, Bonami hypercontractivity and Chebyshev |
| Linear-support all-degree | For degree $\le d$ with **linear** hypergraph of nonsingleton Hoeffding supports ($|S\cap T|\le1$ for distinct supports), a law-independent $V^2$ influence bound and $\Theta_d(r/\eta)$ adaptive spectral prediction are claimed | **v5 analytic extension and 36 exact rational examples**; no external review or Lean; not unrestricted cubic |
| All-degree general spectral tail | Arbitrary fixed $d$: a proposed dimension-/alphabet-independent adaptive spectral-tail estimate with polynomial (worse-than-quadratic) dependence on $d,r,1/\eta$ using imported finite-product scalar $(5/2,6)$ theorem | **PR #332 analytical draft + finite checks**, scalar input kernel-checked only; Hilbert lift, selections, infinite products unverified |
| Exact finite-palette recovery | For a degree-$d$ finite-valued output with $q$ values, range $R$ and spacing $\Delta$, an adaptive query-depth bound $d^3\min\{(q-1)^2,R/\Delta\}$ is proposed, even over infinite independent products | **Written proof + finite checks**; measurable-selection and a.s. null-set passages not independently certified |

Notation: $I_i(F)=\mathbb E\|F-\mathbb E_iF\|^2$; $V=\mathbb E\|F-\mathbb EF\|^2$; $\tau_r=\sum_{j>r}\lambda_j(\Sigma)$, where $\Sigma$ is output covariance. A query reveals a *whole coordinate*, and computational time for choosing coordinates is not bounded.

## Ranked novelty / significance assessment

### 1. All-degree linear-support spectral observability — highest-upside new structured theorem (provisional)

**Statement in v5 §6:** For arbitrary independent coordinate laws and bounded real/Hilbert outputs of interaction degree $d$ whose nonsingleton Hoeffding interaction supports form a linear hypergraph, there is a degree-dependent constant $C_d$ with

$$
V\le \frac{C_dB}{a_r}\sqrt{\max_i I_i(F)},\qquad
\max_i I_i(F)\ge\frac{a_r^2V^2}{C_d^2B^2}.
$$

The manuscript derives adaptive risk $\le\tau_r+\eta$ after $O_d(rB^2/\eta)$ observations, with a matching $\Omega(r/\eta)$ additive example in the stated minimax class. Here $a_r=\Gamma(r/2)/(\sqrt\pi\,\Gamma((r+1)/2))$ so $a_r^{-2}=\Theta(r)$.

**Mechanism:** an all-interaction-order parity activation bound, weighted maximal matching, linear support to ensure *disjoint residual coordinate blocks*, Hilbert fourth moments, and exact posterior influence descent. It is distinct from the known uniform-cube exponent-$5/2$ theorem because it proposes an exponent-$2$ guarantee in a structured all-degree family and a prediction consequence.

**Limits:** does not cover two supports sharing two or more coordinates. Its constants, finite-to-measurable-product support preservation, and optimization of a measurable policy need independent attack. v5 explicitly labels this a new synthesis, not independently refereed or kernel-compiled. A generic all-degree exponent-$2$ theorem is **not** established.

### 2. Quadratic arbitrary-product rank-sensitive minimax observability — strongest broad standalone analytic candidate

For bounded degree-$2$ $F$ on independent inputs with unrestricted alphabets, v5 states

$$
\max_i I_i(F)\ge\frac{a_r^2V(F)^2}{D^2B^2},\quad
D=16(1+\sqrt3),
$$

and adaptive coordinate-query minimax complexity $\Theta(r/\eta)$ for unit-ball covariance-rank-$r$ outputs, versus $\Theta(rm/\eta)$ for nonadaptive degree-$2$ fixed designs on $m$-ary inputs. This has a separate matching proof independent of the scalar Turturean transfer.

**Why it matters:** alphabet- and bias-independent *prediction*, not merely a scalar influential coordinate; the exact rank factor and adaptivity gap are potentially publishable even if the original Boolean low-degree influence conjecture is already solved.

**Limits:** not a kernel-checked theorem; source-level proof reviewer must separately verify the Hilbert matching argument and arbitrary-product measurable selection. The uniform Boolean-cube quadratic case and standard decision-tree/ANOVA mechanisms are prior art, not original contributions.

### 3. Finite heterogeneous product-space influence and certificate-to-posterior bridge — strongest certified mathematical scope

The finite influence theorem has **named Lean 4.33.0 compiler receipts** and extends the class of input laws / alphabets; the concrete certificate-to-observation theorem combines sampler normalization with an *actual finite posterior* and one-step potential reduction. These are the strongest reproducibly certified constructions in the program.

**Priority caution:** the finite influence theorem uses the original Turturean antipodal theorem and has the **same $(5/2,6)$ exponents**, with a **weaker** constant under the compared normalization. General product influence and product-space ANOVA have extensive precedent. The finite extension may be a meaningful technical contribution but cannot be described as a more significant discovery than the original Aaronson–Ambainis proof without independent argument. One-step potential descent is not the full adaptive MSE theorem.

### 4. Fixed-alphabet / Rényi nonadaptive minimax rate — strong separate candidate

For degree-$d$, at most $m$ symbols per coordinate, and rank-$r$ bounded Hilbert output, v5 states fixed-set query complexity $\Theta_d(rm^{d-1}/\eta)$, with the countably supported analogue $\Theta_d(rh^{d-1}/\eta)$ when the order-$1/2$ Rényi effective support $h=(\sum_s\sqrt{p_s})^2$ is uniformly bounded. This is complementary to item 2: it quantifies a cost for *precommitting* the observations.

**Printed-source safeguard:** v5 **already** uses $L=\sqrt{m+1}$ and $L=1+2\sqrt h$ in its Chebyshev extrapolation. An incorrect PDF text extraction made these radicals appear missing; this false-positive 'repair' was retracted in closed, unmerged PR #333. Do not present the existing bound as a newly discovered correction. The independent exact rational proxy checker on that branch provides additional but non-novel finite corroboration; it must not replace review of the full argument.

### 5. Finite-palette exact adaptive recovery — distinct high-upside theorem candidate

The v0.2/v0.3 manuscript proposes the $d^3\min\{(q-1)^2,R/\Delta\}$ almost-sure query bound for finite-palette outputs on arbitrary independent products. The finite-product core is related to block sensitivity and decision-tree complexity; the infinite-product measurable-selection argument remains unreviewed. Its significance may be distinct from spectral *approximation*, but it is **not** currently a theorem with independent global originality clearance.

### 6. Other finite exact and formal findings

Finite-field adaptive phase retrieval on special small fields, finite Sidon/overlap constructions, and Werner-state threshold certificates have separate exact artifacts and deserve domain-specific review. They are **not consequences** of the spectral program and are not given comparative novelty credentials by this ledger.

## Prior art checked this session

- David Turturean, *A proof of the Aaronson–Ambainis conjecture*, 6 November 2026, https://arxiv.org/abs/2611.09773 — original full low-degree uniform-cube theorem; pinned Lean source https://github.com/physical-superintelligence/aaronson-ambainis.
- Uma Girish, Kunal Mittal, Barak Nehoran, Ran Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*, 28 September 2026, https://arxiv.org/abs/2609.35327 — equivalences for fixed-bias product laws and slices. These do not directly subsume every arbitrary-alphabet quantitative constant.
- Thomas Huffstutler, David Miloschewsky, Supartha Podder, *A short proof of the Aaronson–Ambainis Conjecture via the completion framework*, 9 November 2026, https://arxiv.org/abs/2611.12795 — separate completion mechanism and special-case certificate proof.
- Earlier OSSS decision-tree and influence inequalities; Hoeffding/Efron–Stein decomposition; Filmus–Hatami–Keller–Lifshitz total $L_1$ influence, classical Bonami hypercontractivity, Chebyshev, and Hilbert-valued moment inequalities, as attributed in original manuscripts.

**Search limitation:** these are major direct comparisons from this session, not a worldwide exhaustive theorem-equivalence audit. Discovery of similar results with different terminology is a material remaining risk.

## Decisive independent audits / stop rule

1. Verify the v5 all-degree linear-support matching argument for overlapping assigned supports, and the conditional-section claim that support linearity persists after pinning coordinates; request an independent complete proof or concrete counterexample.
2. Reproduce the quadratic scalar matching bound with the exact oscillation constant and the vector fourth-moment estimate in **different code/proof representations**; then verify the rank-sensitive projection and observable policy.
3. Review the nonadaptive categorical signed-proxy moment transport, Bonami interpolation and joint Chebyshev line. **Inspect rendered PDF equations** before treating extraction artifacts as mathematical errors.
4. For infinite products, audit countable-support reduction, Fubini sections, jointly measurable posterior influence selectors and simultaneous null sets, separately from the finite theorem.
5. Compare final exact statements and constants against broader dated prior art; secure independent expert review. No publication, ownership claims of imported results, or global priority assertion without human sign-off.

**Current verdict:** a kernel-checked finite-product domain extension exists, and the spectral manuscripts contain compelling, distinct *candidate theorems*; **none yet has both independent proof review and global originality clearance**. The high-leverage next experiment is an independent proof attack on the all-degree linear-support fourth-moment certificate, followed by Lean formalization of the finite quadratic rank-sensitive core.
