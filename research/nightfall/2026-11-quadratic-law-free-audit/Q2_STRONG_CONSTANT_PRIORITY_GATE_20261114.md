# NIGHTFALL Q2 | strong coefficient and historical-priority gate

**Date:** 2026-11-14 UTC. **Status:** mathematical source derivation reconstructed; original-source stronger additive budget **NOT yet strict-Lean-certified**; novelty **NOT established**. Research direction: Devin J. Wright. AI-assisted audit and formalization.

## Objective and exact theorem type

For finite independent coordinates with possibly different finite alphabet types, original marginal laws p_i (nonnegative, normalized, zero atoms allowed), a pointwise bounded real observable |f| <= B with original-product Efron–Stein degree <=2:

    V = Var_p(f), I_i = E_p Var(f | X_{-i}), M = max_i I_i.

Target universal bound:

    V^2 <= K_2 B^2 M,
    K_2 = (10 + 2 sqrt(2))^2 (1 + sqrt(3))^2
        = 432 + 160 sqrt(2) + 216 sqrt(3) + 80 sqrt(6)
        = 1228.35632383722695106598133162... .

The actually strict compiled current-pin #479 theorem at commit d22962ba73b037a569196bc98d946dc192e4effa proves only
V^2 <= 256(1+sqrt(3))^2 B^2 M (=1910.810013475265...), for a **common finite alphabet type** and coordinate-dependent laws. [8/8 strict receipt](https://github.com/d3lefts/d3lefts/actions/runs/43611982294). Standard axiom allowance: Classical.choice, Quot.sound, propext. Stronger exact coefficient is *not* covered by this certificate.

## Stronger mechanism / cheapest decisive theorem gate

Existing source-derived #479 Lean mechanisms certify:
1. Original-source variance/singleton/pair influence ANOVA and owned pair-energy partition.
2. Exact source matching <=4B, greedy endpoint cost <=8B.
3. Actual original-source Hilbert fourth moment at distinct neighbor labels and owner moment bound s_i <= z_i(c_i+sqrt(3M)).
4. Original-source conditional projection + Jensen z_i<=u_i+A_i; sum u_i<=8B; A_i,z_i<=sqrt(M).
5. Scalar endpoint that accepts **actual** additive budget sum_i A_i<=alpha B.

The independent extra inequality for the sharper alpha=2(1+sqrt(2)) is:

    sum_i A_i <= 2(1+sqrt(2)) B.

Proof representation (author-analytic, not yet a Lean source certificate): for T_t=∏_i(E_i+t(Id−E_i)), the exact source Hoeffding decomposition gives T_t f = f_0 + t f_1 + t² f_2; T_t is a genuine positive Markov operator, so |T_t f(x)|<=B for all t∈[0,1]. For all x,y define r(t)=T_t f(x)-T_t f(y)=u t+v t² with u=f_1(x)-f_1(y). At s=sqrt(2)-1,

    u = (r(s)-s²r(1))/(s(1-s)),
    2(1+s²)/(s(1-s)) = 4(1+sqrt(2)).

Thus |u|<=4(1+sqrt(2))B. The additive source f_1=Σ_i h_i(x_i), and the full product domain lets all coordinate oscillations be attained simultaneously, so osc(f_1)=Σ_i osc(h_i). Weighted Popoviciu gives A_i<=osc(h_i)/2, including zero atoms. Therefore sum_i A_i<=2(1+sqrt(2))B. This last transition is the **exact source-level Lean task**, not a permission to add the budget as an axiom.

Conditional formalization: `ActualSourceQ2StrongConditional.actual_source_q2_strong_given_additive_budget` derives the 1228.356 numerical endpoint from the real p,f and the **explicit additional premise** sum originalSingletonNorm <= 2(1+sqrt2)B. It must compile with a separate strict axiom receipt; even if it passes, it does **not** certify the source-only strong theorem. Next: discharge the premise by strictly proving source noise spectral action, interpolation, coordinate extrema and original weighted variance/range bound. Then remove the premise and audit the single complete theorem.

**Stop rule:** do not promote the exact coefficient until the full source-only declaration compiles under Lean 4.36.0-rc2 with no custom/sorry axioms, no hidden assumption, all coordinate dimensions including 0/1, and a SHA-pinned receipt.

## Prior-art comparison, searched 2026-11-14

The claim of *historical novelty* needs an independent full-theorem subsumption test, not a keyword search or the presence of a fresh constant. Relevant dated works:

| Work / date | What its accessible theorem statement covers | Exact mismatch / unresolved question |
|---|---|---|
| Aaronson, Ambainis, Iraids, Kokainis, Smotrovs, **Polynomials, quantum query complexity, and Grothendieck's inequality**, CCC 2016; https://arxiv.org/abs/1511.08682 | Bounded Boolean-cube quadratics via real Grothendieck; binary exponent-two influence bounds known | **Binary exponent two is old**, not our novelty; whether some operator factorization lifts it to nonbinary unbounded alphabets without atom floor requires theorem-level audit |
| Briët, Escudero Gutiérrez, Gribling, **Grothendieck inequalities characterize converses to the polynomial method**, Quantum 8 (2024), https://doi.org/10.22331/q-2024-11-18-1526 | Bounded quadratic/bilinear forms and quantum one-query simulation under classical Boolean-polynomial framework | Explicit arbitrary heterogeneous finite-alphabet source Efron–Stein influence theorem not in accessible abstract; tensor/factorization implications must be reviewed |
| Grimmett, Janson, Norris, **Influence in product spaces**, arXiv 1207.1780 (2012), https://arxiv.org/abs/1207.1780 | General product-space BKKKL/KKL family, for events and general influence notions | Typical max-influence guarantee carries dimension via log(n)/n and is not an exponent-two low-degree law |
| Girish, Mittal, Nehoran, Raz, **Distributional Variants of the Aaronson-Ambainis Conjecture**, arXiv 2609.35327 (Sept 28, 2026), https://arxiv.org/abs/2609.35327 | Equivalence of biased *binary* product and slice variants to uniform AA, for fixed bias p | Not an explicit universal exponent-two theorem independent of bias/coordinate distributions/alphabet type |
| Turturean, **A proof of the Aaronson–Ambainis conjecture**, arXiv 2611.09773 (Nov 6, 2026), https://arxiv.org/abs/2611.09773 | General Boolean-cube degree d: max influence Ω(Var^(5/2)/d^6) | Does not explicitly give exponent two nor arbitrary categorical products |
| De la Peña, Montgomery-Smith, Szulga, **Contraction and decoupling inequalities for multilinear forms and U-statistics**, Ann. Probab. (1994) | Vector-valued random polynomial decoupling | A generic bounded quadratic-to-influence theorem **may** follow after factorization; full proof and constants not yet audited |
| Pisier, **Grothendieck's theorem, past and present** (2012), https://arxiv.org/abs/1101.4195 | Operator/bilinear factorization and absolutely summing methods | Critical potential indirect subsumption; no conclusive negative result from current evidence |
| Mossel–O'Donnell–Oleszkiewicz, **Noise stability of functions with low influences** (2005/2010) | Invariance for low-influence product ensembles, frequently with atom/hypercontractive assumptions | Does not directly supply an atom-floor-free degree-two variance-squared maximum-influence lower bound |

**Priority verdict:** no accessible reviewed statement here explicitly matches all original-source categorical Q2 hypotheses, but absence of an identical printed theorem **does not establish novelty**. Some listed classic bilinear-operator and decoupling results may logically imply it with a different proof or better constant. Those texts and their downstream citations must be scrutinized by an independent mathematical expert. The exact numerical coefficient alone is **not** a historical-newness certificate.

## Adversarial checks / excluded shortcuts

- Binary special case via Grothendieck is already known. A universal attribution of all exponent-two bounds to NIGHTFALL would be false.
- One-sided decoupling normalization: E[K_right²] = Var(f₂), not twice this amount.
- No universal sum_i sqrt(I_i) bound from ||f||∞ on categorical spaces: the address/sign construction in the 2026-11-13 author ledger falsifies it.
- Owner neighborhoods are disjoint **within** each owner enumeration, not across owners. Global martingale-independent-block fourth moments cannot be presumed.
- Computational randomized finite checks are counterexample searches, not universal proofs; internal AI review is not independent human refereeing.

## Completion/claim gates

A. Strict scalar conditional theorem: check the declaration and its axiom list at the exact new branch SHA.
B. Strict original source additive budget (the open Lean obligation), then source-only stronger terminal theorem.
C. Independent mathematical proof reconstruction and attempts to falsify the noise interpolation, matching rectangle, original conditional projection, and fifth-moment/source normalization edges.
D. Historical novelty: specialist reviews exact CCC 2016, Quantum 2024, decoupling 1994/1999, Pisier 2012 and related q-ary Grothendieck/vector-valued theory *with explicit theorem-hypothesis maps*; follow citation chains and date the negative/positive findings.
E. Only after A–D may the contribution be labeled 'new theorem'; human authorization is needed for publication.

This is a source/version-specific research checkpoint, not a publication/novelty certificate.
