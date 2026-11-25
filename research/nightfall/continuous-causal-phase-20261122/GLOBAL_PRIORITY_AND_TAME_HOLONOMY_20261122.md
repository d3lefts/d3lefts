# Dated global-priority search and tame-detector upgrade — 2026-11-22

**Research status:** bounded global-search effort using public web and SciSpace academic index, an exact rational construction improvement, and proof-scope reconciliation. This is **not** a guarantee of worldwide novelty, independent human review, or full Lean certification. The sole mathematical flagship is real causal phase retrieval. Source notes are preserved in draft PR #1047.

## 1. Exact model and what NIGHTFALL has

For unknown x∈R^n modulo ±, a causal signed-row protocol reads y_j=(a_j(y_<j)·x)^2. The following claims have distinct status:

| Claim | Source, state | Priority/certificate gate |
|---|---|---|
| Arbitrary causal exact rows: n+1; fixed real rows: 2n−1 | Merged #695, pinned Lean | Classical fixed-frame threshold is prior art; no blanket originality assertion |
| n fixed independent coordinate squares + one continuous final row fails, n≥3 | Merged #699, Lean | Architecture-specific, not full continuous feedback |
| Every continuous **oriented** causal row protocol needs 2n−1 | Merged #995, AI independent audit #1000; paper proof based on CCFH 2019/2020 Remark 2.7 | Established paper-level reasoning; causal Lean terminal **conditional** on ProductSphereZero, not unconditional Lean; human/novelty review open |
| Nonzero normalized physical projectors continuous on entire nonnegative history orthant also need 2n−1 | PR #1047, covering-space deduction | Paper-level extension, not new topology |
| Continuity of normalized projector solely on actually attained histories need not permit a signed-row lift | PR #1047, explicit H3 and H4 constructions | Candidate original causal-model realization; classical Möbius holonomy |
| Every two-reading even scalar transcript after PSD quadratic first reading has contractible image; first normalized non-lift at stage 4, zero-gain non-lift at stage 3 | PR #1047 sharp-onset note | Paper-level; no independent human review or Lean |
| Every everywhere-full-rank n-reading causal signed prefix is odd-homeomorphic to coordinate squares; ≤n−2 further continuous scalars cannot recover | PR #1047 full-rank-prefix note, ordinary BU | Scoped paper proof; adaptive-linear-information predecessor exists |
| n−1 full-rank rows admit odd signed-coordinate + one-kernel-coordinate trivialization; next reading has (β(z)+c(d)t)² fibers | PR #1047 singular-prefix note | Paper-level, rank-drop mechanism only |
| Exact minimum for continuous normalized projectors on attained histories | None | **OPEN**: n=4, 6 vs 7 |

**Important audit repair:** The H2-lifting proof requires no unproved assertion that arbitrary H2 is locally path-connected: covering maps have the homotopy-lifting property, and the explicit vertical strong deformation onto the continuous ray section supplies the required lifting homotopy. The previous stronger-sounding local-path-connectedness assertion has been removed from the sharp-onset source note on this branch.

## 2. Dated external prior-art ledger

**Verified closest source statements:**

1. **Balan–Casazza–Edidin (2006)** — fixed-frame real complement property and 2n−1 threshold. Known and properly credited.
2. **Heinosaari–Mazzarella–Wolf (2013)** — quantum pure-state topological measurement lower bounds. Their projective-space obstructions must not be rebranded as new sensing topology.
3. **Bandeira–Cahill–Mixon–Nelson; Conca–Edidin–Hering–Vinzant; Vinzant (2014–2015)** — mainly fixed complex 4n−4 generic threshold and non-universal necessity. Distinguish complex from real and generic from universal.
4. **Chan–Chen–Frick–Hull, arXiv:1902.00935v2 (2019-11-06), printed p.5 Remark 2.7, published 2020** — states the exact separate-antipodal product-sphere zero result used by #995. This is **classical published mathematics** (Ramos/Fadell–Husseini ancestry), not NIGHTFALL's invention. Source was directly visually checked: https://arxiv.org/pdf/1902.00935 .
5. **Charikar–Wu–Ye, Adaptive Discrete Phase Retrieval (online 2019-12-17, SOSA 2020)** — adaptive phase retrieval for finite-bit signal classes. Publisher abstract verified; full primary text was not accessible in this check: https://epubs.siam.org/doi/10.1137/1.9781611976014.9 .
6. **Krieg–Novak–Ullrich (2024), How many continuous measurements are needed to learn a vector?; Forum of Mathematics, Sigma (2025), On the power of adaption and randomization** — adaptive continuous functional information; supports much broader historical roots of adaptive coordinate changes. Selector continuity and rank-one phaseless constraints differ. https://www.cambridge.org/core/journals/forum-of-mathematics-sigma/article/on-the-power-of-adaption-and-randomization/3633856556AFDE5A9942452F04CC5D39 .
7. **Favazza–Frank–Freeman–Ghoreishi–King–Randrianarivony (SampTA 2025), Frames and Phase Retrieval for Vector Bundles** — moving bundle frames and phase retrieval of sections are already studied. Do NOT claim to originate vector-bundle phase retrieval. Primary PDF indexed text was accessible; full PDF screenshot was blocked by an OpenReview bot challenge. https://openreview.net/pdf/8548d0356e3c391f613cc52452489d46b36ea786.pdf .
8. **Ballas–Needham–Shonkwiler (2025), On the Existence of Parseval Frames for Vector Bundles** — more bundle/frame antecedents. Direct full-text not checked; scholarly index confirmed source metadata.
9. **Ullrich, A Borsuk–Ulam theorem for adaptive continuous measurements (2026-10-24), arXiv:2610.33781, p.2 Theorem 1** — adaptive functional selection may depend arbitrarily on prior values; shows an antipodal-distinguishing complexity bound of logarithmic order. Squared intensities *never* distinguish x and −x, which is not the present task. Original PDF pp.2–3 visually checked: https://arxiv.org/pdf/2610.33781 .
10. **Classical information-based complexity, including Traub–Wasilkowski–Woźniakowski (1980s)** — adaptive linear information operators and their comparison to nonadaptive algorithms precede NIGHTFALL. Historical source result was found; do not claim invention of causal-coordinate homeomorphisms as a general concept.
11. **Phasebook survey (2025), generalized quadratic/projection phase retrieval and 2026 rank-r fusion frame work** — mature adjacent fields; no exact same-model threshold located in accessible records. https://link.springer.com/article/10.1007/s43670-025-00117-0 .

**Search coverage and limits:** public fast/slow engines plus SciSpace's scholarly index; exact and conceptual queries for adaptive phaseless real measurement count, continuous row-choice, continuous physical projectors, history spaces, line-bundle holonomy, bundle frames, and Borsuk–Ulam. Accessed during 2026-11-22. No inspected source stated NIGHTFALL's *precise* universal continuous oriented-row theorem or earliest attainable-history holonomy stage, but this **does not establish global priority**. Search engines miss full-text, unpublished material, terminology variants and inaccessible paywalls. Explicit independent specialist novelty and referee gates remain OPEN. Some SciSpace results were duplicates or identified a gap in an unrelated real-projections paper; such records are not used as proof of a new lower bound.

## 3. Exact new semialgebraic realization of detector holonomy

Previously the non-liftable normalized projector examples in PR #1047 used a trigonometric path. Replace the trigonometric path by the **rational semialgebraic** map

\[
D(s)=(1-s)^2+s^2\ge\tfrac12,\qquad
w(s)=\frac{(1-2s,\;2s(1-s))}{D(s)},\qquad
P_{\mathrm{alg}}(s)=w(s)w(s)^\top,\quad 0\le s\le1.
\]

The exact polynomial identity
\[
(1-2s)^2+4s^2(1-s)^2=D(s)^2
\]
implies \(\|w(s)\|_2=1\). The endpoints satisfy \(w(0)=e_1\) and \(w(1)=-e_1\) while \(P_{\rm alg}(0)=P_{\rm alg}(1)\).

**Theorem (scoped paper upgrade).** The two non-liftable *attained-history* detector constructions in PR #1047 remain valid with \(P_{\rm alg}\), and all sensing and detector maps involved become continuous **semialgebraic** functions of the exact attained histories:
- The R² graph-sheet H3 construction realizes a non-liftable normalized **fourth** physical detector after three continuous oriented rows. On the overlap of the two sheets, τ=min(1,d1,d2) equals 0 on an axis or 1 on the interior circle, where \(P_{\rm alg}(0)=P_{\rm alg}(1)\). Closed-pasting gives continuity on H3; connected-sheet orientation choices must disagree between the axis and circle intersection.
- The R⁴ interior-rank-collapse construction has coordinate-square first three rows and normalized fourth row \((1,1,0,c(d))/\sqrt{2+c(d)^2}\), \(c(d)=(d1-2)^2+(d2-2)^2-1\). On c<0, form the clipped semialgebraic parameter \(s=\operatorname{clip}_{[0,1]}((y_4-f_-(d))/(f_+(d)-f_-(d)))\), with \(f_\pm=(\sqrt{d1}\pm\sqrt{d2})^2/2\), and use \(P_{\rm alg}(s)\). On c≥0 use \(P_{\rm alg}(0)\). At c=0, the only actually attained fourth outputs are f− and f+, so limits on the pinching fibers agree with the exterior value. The closed two-arc loop has sign holonomy −1, proving no continuous signed lift of the **fifth** detector on H4.

The graph sheets, rank-collapse circle, square roots, min/clip, rational P and the relative-history pasting are all semialgebraic. This rules out an explanation that relies on *wild* embeddings or pathologies of arbitrary continuous functions. **It does not yield a six-query recovering protocol**, and the specified first-five R⁴ architecture is already shown in PR #1047 S4 to be impossible to finish with any continuous sixth scalar output.

**Exact checker:** check_semialgebraic_detector_exact.py, standalone Python stdlib rational arithmetic, separately executed in this session. It checks the degree-4 polynomial identity using five rational arguments (enough for a polynomial of degree at most 4), idempotent trace-one projectors, endpoint agreement, and rational overlap signs +,+,+,− (product −1). The **topological** no-lift theorem relies on the written sheet-pasting argument, not finite sampling.

**Novelty limits:** rational half-turn parametrization, real eigenline nonorientability, and the homotopy obstruction are classical. Potentially original is their **explicit causal attained-history realization** at the exact first possible stage (four for nonzero projectors, three for zero-gain PSD), with all maps tame. The original 2n−1 theorem remains the main result; the physically broader query-count threshold is OPEN.

## 4. Claim ladder, audit and next decisive test

**Established externally:** complement property, ordinary/product Borsuk–Ulam, covering spaces, bundle orientation and semialgebraic geometry.

**Paper proof with independent AI audit:** sharp 2n−1 lower bound for continuous oriented causal rows; source zero theorem CCFH. **Not yet Lean end-to-end.**

**Paper proof pending independent mathematical review:** contractible H2, earliest holonomy stages, rank-drop normal form, full-rank-prefix impossibility, semialgebraic attainable-history examples, and quantitative robust zero statement. Existing repository check workflows can validate arithmetic/source integrity but do not independently certify topological statements.

**OPEN:** globally optimal physical-detector count for continuous normalized projector choices on attained histories. In R⁴, ask whether 6 can work or 7 is necessary. The currently explicit rank-collapse+holonomy five-reading family fails to capture one coordinate, so no sixth continuous scalar can rescue it. Do not optimize this dead end. New mechanisms must couple all four coordinates before the final reading and preserve actual-history continuity and rank-one positivity. Any six-reading candidate needs an exact universal recovery checker, including zero/support boundaries; a numerical search is not a theorem.

**Stop rule:** Further promotion requires (a) an actual universal 6-reading construction or a general lower bound, (b) an independent adversarial proof audit, (c) full source-scope and external priority review; otherwise preserve provisional status. No publication or author contact is authorized by this research ledger.
