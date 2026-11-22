# External methods ingestion — Németh–Seberry–Shu / prime circulant permanents

**Snapshot:** 2026-11-22. **Classification:** external mathematical case study and reusable research operators; **not** a NIGHTFALL theorem or independently certified asymptotic disproof. **No change** to frozen research catalogue, current claim registry, or certified finding count.

## Sources and priority

- Yair Lavi, [Minc's list, Conjecture 27](https://yair-lavi.com/mincs-list/conjecture-27/index.html) (viewed 2026-11-22): status "Disproved by others"; original question posed by E. Nemeth, J. Seberry and M. Shu (1979). Lavi states that he independently audited the Davis argument and found no gap; this is credited as a reported third-party paper audit, not a Lean or source-by-source audit undertaken here.
- Cinna Davis and GPT-6.2 Astra, [quadratic refinement](https://github.com/1337isnot1337/solved-conjectures/blob/d2ef0e62a395160883375b74cc84f20e003b4912/docs/nss/quadratic-refinement.md) (source revision d2ef0e62a395160883375b74cc84f20e003b4912, 2026-11-20; **author-labeled candidate, not externally reviewed**). This is the credited source of the claimed V(p) >= c p^2 theorem, not NIGHTFALL.
- [Underlying manuscript](https://github.com/1337isnot1337/solved-conjectures/blob/main/docs/nss/manuscript.md) and [fourth-moment refinement](https://github.com/1337isnot1337/solved-conjectures/blob/main/docs/nss/fourth-moment-refinement.md) document the weaker p^(3/2)/sqrt(log p) and p^(3/2) stages. Pin those files before any substantive derivative proof.
- External analytic dependency: Divoux–Wang, [arXiv:2610.23755v1](https://arxiv.org/abs/2610.23755), asymptotic permanent approximation. The strengthened **uniform O(1/p)** error extracted from the rook-polynomial argument and used in the quadratic refinement has **not** been independently source-checked in this ingestion.
- Classical predecessors: Brualdi–Newman congruence, affine invariance, Bernasconi–Codenotti–Crespi–Resta and Resta–Sburlati (bibliography on Lavi's page).

**Scope boundary:** The original conjecture ranges over all 2^p binary circulants and all row sums. The disproof constructs dense supports, with p/3 <= |S| <= 2p/3. It does **not** establish the conjectured fixed-small-k asymptotics (in particular k = 4).

## Mechanism graph: representation -> operator -> certificate -> limit

1. **Circulant Fourier representation.** Write A_S = sum_{s in S} P^s, D=A_S/k and B=D-J. The circulant eigenvalues are Fourier coefficients of the support; Parseval gives sum_{l neq 0}|lambda_l|^2=p/k-1 exactly. The log-determinant correction is driven by a controlled first conjugate mode and a fourth-moment bound on the others.
2. **Probabilistic construction plus cardinality repair.** Independent Bernoulli sampling specifies the first harmonic; fourth-moment estimates bound the spectral bulk. A finite number of support edits fixes k. The refinement uses sector swaps to steer the first coefficient to O(1) absolute error without destroying the bulk bound. This yields O(1/p) eigenvalue error after normalization, rather than O(1/sqrt p).
3. **Centered second-order approximation.** The permanent is represented using a rook polynomial evaluated at Z=p/T with T~Gamma(p+1,1). Exact identities E[Z]=1 and E[(Z-1)^2]=1/(p-1) cancel the first-order Taylor term. Subject to uniform bounded derivatives and the cited tail and rook estimates, the approximation error falls to O(1/p). **The external uniform analytic estimates remain the proof-critical unverified dependency here.**
4. **Certified separation by a modular invariant.** Prime-order cyclic translation acts on admissible permutations in orbits of 1 or p; fixed admissible permutations are exactly the k cyclic translations. Thus per(A_S) = k mod p. Distinct k in the dense interval yield distinct residues, while a monotone amplitude grid separates O(p) values per fixed k. Together these are the mechanism of the claimed quadratic lower bound.

### Generalization: a group-action congruence for every finite p-group

**Proved algebraically here; no novelty claim, no Lean formalization or independent non-author theorem review.** Let G be *any* finite group of order p^m, where p is prime, and S be a subset. Define A_{x,y}=1 iff x^{-1}y belongs to S. Then

    per(A) = |S| (mod p).

**Proof.** The permanent counts bijections sigma:G->G with x^{-1}sigma(x) in S for every x. Let g in G act by (g·sigma)(x)=g sigma(g^{-1}x). This preserves admissibility. Since G is a p-group, every non-singleton orbit has cardinality divisible by p. The action-fixed bijections commute with all left translations, hence have the form sigma(x)=x t, with t=sigma(e). Such a bijection is admissible exactly for t in S, giving |S| fixed objects and the claimed congruence. QED.

**Weighted strengthening (also elementary and not claimed novel).** Let w:G->Z be any integer-valued function, including negative entries, and set A_{x,y}=w(x^{-1}y). Then

    per(A) = sum_{g in G} w(g)  (mod p).

Indeed, the action above preserves the product weight of each admissible/permutation term, so every non-fixed orbit contributes a multiple of p. Fixed permutations are right translations and contribute w(g)^{|G|}; since |G| is a power of p, Fermat's congruence reduces each to w(g) modulo p. This is a genuine strengthening of the binary-special-case invariant, but **no worldwide novelty or Lean certificate is asserted**.

This extends the *elementary congruence mechanism* to **noncommutative** p-groups. It does not extend the Fourier/determinantal quadratic permanent-value lower bound: arbitrary nonabelian Cayley matrices need different spectral analysis. The scope matters. Exhaustive exact examples: C4 (16 supports), C8 (256), nonabelian D8 (256), plus original cyclic prime p=2,3,5,7 (172). **700 support checks** total, with selected independent permutation enumerations; a C6 support (mask=7) gives permanent 20 with |S|=3, disproving an unchecked extension of the mod-2 congruence to arbitrary groups. These finite tests do not themselves prove the p-group theorem; the orbit argument does. The same checker also tests **798 weighted integer Cayley matrices** (complete weights in {-2,-1,0,1,2} for C3 and C4; deterministic weighted C9 and nonabelian D8 cases), for **1,498 successful matrix cases total**, plus the failing C6 control.

### A reusable elementary centering lemma (not novel)

For any p>1 and T~Gamma(p+1,1), Z=p/T has E[Z]=1 and Var(Z)=1/(p-1). If g is C^2 on (0,infinity) with |g''|<=M everywhere, Taylor's theorem with the exact first-moment cancellation gives

    |E[g(Z)]-g(1)| <= M/(2(p-1)).

This statement is **not** a direct proof of the determinant estimate: its g(s)=det(I-s^2 B^T B)^(-1/2) has singularities outside a compact interval in general. To use the centering mechanism on a compact interval I, one must also prove the truncated first moment is small and both tail contributions are controlled. Do not silently extend a compact spectral gap to all s>0.

### Finite exact evidence, independently executable

Run:

    python3 scripts/check_circulant_permanent_invariants.py

The script uses exact row-subset DP for **every** support of prime orders 2,3,5,7 (172 total), plus every subset for C4, C8 and nonabelian D8 (528 additional supports; 700 total); compares with an independently formulated permutation enumeration for orders <=5 and selected D8 supports; checks the mod-p invariants and every affine map of prime cyclic supports; and includes negative controls, including the genuine failing case C6. Local replay on 2026-11-22 passed for all 700 binary support cases, 798 weighted cases, and the C6 scope check. This **only** certifies those finite computations and catches implementation mistakes in the reused invariants. It does not check the external O(1/p) analytic estimate or prove V(p)>=cp^2.

## What NIGHTFALL adopts

| Practice | Concrete application | Gate |
|---|---|---|
| **Question-first indexed research ledger** | Show original statement, poser, start date, live status, and historical baselines on every candidate; preserve superseded milestones | Do not change the canonical claim status from a web page alone |
| **Many weaker bounds, one exact scope** | Record p^(4/3), p^(3/2)/sqrt(log p), p^(3/2), p^2 progression as source claims, not four distinct discoveries | Require independently reproduced premises for promotion |
| **Focus Fourier energy, not all coefficients** | Try moment/fourth-moment bulk control in phase retrieval and low-degree product-space observability where the target only depends on aggregate spectral quantities | First state a testable inequality and its norm topology |
| **Construct, repair, and preserve invariants** | When using randomized or approximate designs, predefine an exact repair operator and prove it preserves feasibility, objective separation and error budgets | Independent checker and counterexample attempts |
| **Exploit centered statistics** | Audit cases where crude absolute-error bounds lose a square root; retain E(delta)=0 before applying Taylor | Exact moments plus certified tails |
| **Separate by a cheap invariant before numerical optimization** | Look for residues, parity, symmetry classes or conserved quantum charges to certify pairwise disjoint candidate families | Prove invariance and noncollision under actual query model |
| **Immediate competitor credit** | Credit Cinna Davis, GPT-6.2 Astra, Lavi, and predecessors; clearly state unrelated or open variants | Source revisions and dated priority audit |

## Cheapest decisive next experiment and stop rule

**Objective:** determine whether centered inverse-Gamma approximation yields a justified O(1/p) uniform error under the precise Divoux–Wang hypotheses, including matrices with zero entries. **Input:** version-pinned Divoux–Wang Prop. 3.1 / proof of Prop. 3.8 and §3.3, and the cited three Davis notes. **Verifier:** another researcher traces each O(1/p) constant, spectral-gap condition, tail region and quantifier for all k,a; an adversarial pass tries concentrated spectra and edge k. **Stop:** if any input is inaccessible, or if only o(1) is established, keep the quadratic result attributed, conditional-on-source-audit, with no NIGHTFALL theorem promotion. Only then test transfer to other research frontiers.

**Novelty:** no NIGHTFALL originality claim. **Significance:** methodology and external result useful; local gain is a reusable exact checker and an explicitly segregated evidence trail. **Independent review:** not yet obtained. **Ethics and licensing:** analysis and new code written independently; external author credits and links retained, no copied site templates or source code.

## Site communication contract

The site case study [external-methods.html](../../../docs/external-methods.html) renders the **original historical conjecture**, **credited solution claim**, **proof-critical external input**, **open fixed-sparsity variant**, **exact finite replay**, and **three transferable operators**. A status marked “disproved by others” does not license “certified by NIGHTFALL”, and an external author’s own “candidate, not externally reviewed” label remains visible.
