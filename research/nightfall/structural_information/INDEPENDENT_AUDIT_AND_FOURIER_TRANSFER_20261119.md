# Structural information — adversarial audit and Fourier-test transfer (v0.1, 2026-11-19)

**Source:** `REPRESENTATIONS_AND_NECESSITY_20261119.md`, authored at commit `6a74eefc960602a70c0ad25ddd9052a0d1881568` on `structural-information-theory`. **Status:** independent AI mathematical review and separate new proof derivations, NOT Lean-certified, human-refereed, or novelty-cleared. No original file is overwritten. All claims below use Shannon entropy in *bits*, whereas earlier Route 1 uses natural logarithms (convert as necessary). This audit is exact about the claim scope and preserves the source's contribution.

## 1. Logical correction: sufficiency, not necessity, was falsified

The source claims “no information-only measure can be **necessary** for quantum advantage” from a distribution with **high** Wyner common information but **no** quantum advantage. The evidence has form `large S AND no advantage`. It refutes `large S ⇒ advantage` (**sufficiency of high information for exploitable advantage**), not `advantage ⇒ large S` (**necessity**).

In fact, conditional on the already written (not end-to-end Lean-certified) Route 1 simulator bound `classical depth ≤ poly(T,1/ε,1/δ)(1+S)`, sufficiently large classical-vs-quantum query advantage **implies** large S. The random-function graph is consistent with this necessity implication.

Avoid the universal “no information-only measure”: the example only attacks particular monotone *converse* statements, and an arbitrarily constructed functional of the entire joint distribution might encode further information.

**Even simpler complete counterexample to sufficiency:** `X=(Z,Z)`, where `Z∈{0,1}^m` is a vector of m independent fair bits. `H(X)=m` and every coordinate is determined by its twin, so `DTC(X)=m`. The standard bound `C_W≥DTC` plus `W=Z` gives `C_W(X)=m` **exactly**. A coherent query to any coordinate of `X` is exactly a query to one coordinate of `Z`; hence the existing uniform/product Aaronson–Ambainis simulator gives dimension-independent classical depth `poly(T,1/ε,1/δ)`. Therefore this high-information/no-advantage separation was **already present in Section 2** of the source. The random-H theorem may still add the harder-to-represent phenomenon, but its claimed representation-cost lower bound is a conjecture.

**Prior art:** `C_W≥DTC` is explicitly in the 2017 multivariate common-information literature, e.g. Li–Hanna–Diggavi–Fragouli, *Distributed Simulation of Continuous Random Variables*, IEEE Transactions on Information Theory 63(10), Eq. (4), https://isl.stanford.edu/~abbas/papers/Distributed%20Simulation%20of%20Continuous%20Random%20Variables.pdf . Do not label the information inequality novel.

## 2. The conditional representation transfer theorem: author-side argument valid with explicit interfaces

Let `X′~ν′`, `X=Γ(X′)`, each `Γ_i` depend on at most c coordinates of X′, and let the **actual conditional law** `P(X′|X=x)` be a product of one-coordinate conditional kernels `κ_j(x_{B_j})` with `|B_j|≤c′`. All spaces finite, and conditionals may be arbitrarily chosen on zero-probability X.

If oracle values are encoded as reversible classical data, compile each coherent X-query into **c parallel X′ fetches, the original oracle action, then c uncomputations** (at most 2c X′ oracle queries and at most 2 oracle rounds per original round; the decoding circuit is input-independent and may be computationally unbounded). Given an X input, locally sample each first-requested X′_j from κ_j, memoizing previously sampled symbols. **Conditional independence** ensures exact joint X′|X for adaptive requested sets, and Γ(X′)=X almost surely. For a deterministic ν′ simulator τ′, the randomized decoded tree τ satisfies the identical error probability by the joint coupling; averaging its random seed produces one deterministic X decision tree of depth ≤c′ depth(τ′).

This establishes a **conditional transfer principle** for every source simulation theorem valid on ν′. Specifically the polylog-mixture bound still depends on unclosed Route 1 terminal assumptions. If ν′ is uniform or a genuinely independent product law, the already certified product simulation gives an unconditional source-specific corollary.

**Review gates:** exact coherent-oracle register convention and c parallel fetch implementation; deterministic seed fixing; correct conditional kernel (not merely any product kernel); round-count convention; mixed alphabets/zero atoms. No full Lean transfer terminal constructed here.

## 3. Random graph distribution: high information with a sharper certified-by-paper quantitative tail

Let `H:[N]×{0,1}^m→{0,1}` have independent fair table entries and `X=(s,H(1,s),…,H(N,s))` with uniform s. `H(X)=m`. All N output bits are determined by s. For each seed bit i, conditional entropy `H(s_i|X_{-i})` equals the fraction of the `2^{m-1}` seed pairs `(s,s⊕e_i)` whose N-bit H columns coincide. Each collision has probability `2^{-N}`. Thus

    E_H[m-DTC(D_H)] = m·2^{-N},  DTC(D_H) ≤ C_W(D_H) ≤ m.

For every a>0, Markov gives the explicit finite-size guarantee

    Pr_H[C_W(D_H) < m-a] ≤ m·2^{-N}/a.

For N=m and a=m·2^{-m/2}, the bound is `2^{-m/2}`, and the deficit tends to zero. This verifies the information claim without Gaussian approximations.

**The original uniform-convergence proof needs one repair:** coefficientwise rounding produces low-degree polynomials that may leave [0,1], so the imported product-AA simulator cannot automatically be applied to the rounded polynomials. Partition the bounded-degree class by coefficient grid cells and choose **one actual [0,1]-bounded low-degree representative per nonempty cell**. Then all simulator centers remain admissible. With `K=Σ_{j=0}^d binom(m+N,j)` and grid width `a/(2K)`, the number of representatives is at most `(1+4K/a)^K` and every bounded degree-d f is within a/2 in pointwise norm of its representative.

For each representative g choose a **deterministic** depth-`q(d,a/2,b/2)` tree τ_g under U=unif({0,1}^{m+N}) with bad-probability ≤b/2 at accuracy a/2. Let `B_g(s)=1[|τ_g-g|(s,H(·,s))>a/2]`. B_g(s) depend on independent H columns, and `E_H (2^{-m}Σ_sB_g(s))≤b/2`. Hoeffding and union bound give

    Pr_H[ EXISTS bounded degree≤d f with
         Pr_{D_H}(|τ_{rep(f)}-f|>a) > b ]
       ≤ exp[ K log(1+4K/a) − b²·2^{m-1} ].

**The choice of rep(f) and the tree may depend on H**, but the entire net/tree family was fixed before sampling H. This preserves the adversarial “algorithm tailored to H” quantifier. For fixed a,b>0 and `T≤c m/log m` with sufficiently small c, d=2T and `K log(K/a)=o(2^m)`, establishing the source's dimension-independent **scalar acceptance-probability** simulation. To claim all a,b uniformly, use countable dyadic parameters and explicitly union the failures; fixed a,b requires no extra work. This does not prove all quantum sampling/output tasks have no advantage.

**Priority:** net+Hoeffding uniform convergence is classical methodology, not a newly established method. Distinct graph example and quantifier may still be useful but require a targeted published-source comparison.

## 4. NEW noncircular reusable operator: low-degree Fourier-test discrepancy

On `{−1,+1}^n` let U be the uniform independent product and define

    B_k(ν)^2 = Σ_{S⊆[n],1≤|S|≤k} (E_ν χ_S)^2.

By Fourier expansion, Parseval and Cauchy–Schwarz, every `h:{±1}^n→[0,1]` of Fourier degree ≤k obeys

    |E_ν h − E_U h| ≤ B_k(ν).                              (F1)

**Simulator transfer (paper theorem):** Suppose each bounded degree≤d f has a *deterministic* depth-q classical decision tree τ_f on uniform inputs, with outputs clamped to [0,1], such that

    Pr_U[|τ_f−f|>a] ≤ b.

An adaptive depth-q Boolean decision tree is a polynomial of Fourier degree ≤q. Thus `h_f=(τ_f−f)^2` has degree≤`k=2 max(d,q)` and values in [0,1]. Consequently

    E_ν h_f ≤ a² + b + B_k(ν).
    Pr_ν[|τ_f−f|>ε] ≤ (a²+b+B_k(ν))/ε².                 (F2)

Choose `a=ε sqrt(δ)/2`, `b=ε²δ/4` and require `B_k(ν)≤ε²δ/2`. Then (F2) gives (ε,δ)-simulation at the **same depth q**, independent of n. This gives a **genuine noncircular structural sufficient criterion** and by contrapositive a degree-k correlation witness is **necessary to beat that q**. It is not an equivalence: the duplicate-bit distribution has huge low-degree correlations yet is classically easy. The method is elementary Fourier moment matching and should be treated as a reusable transfer lemma, not novelty-cleared.

**Cost/scope:** B_k is a sum of up to n^k moments and can be expensive to check; k includes the simulator depth q, which may be a high polynomial in T. Therefore this result alone DOES NOT cover the full source's `T≤c m/log m` random-H range. The independent coefficient-net argument above does; the Fourier operator covers fixed T or regimes with k ≪ m/log m.

## 5. Distinguishing the three model families with a precise low-degree test

**Graph H:** For each nonempty Fourier subset S involving at least one H-output bit, the character average under D_H is the mean of `2^m` independent unbiased signs (as H ranges randomly). Seed-only nonconstant characters vanish identically. Therefore

    E_H B_k(D_H)^2
      = 2^{-m}[Σ_{j=0}^{min(k,m+N)} binom(m+N,j)
               −Σ_{j=0}^{min(k,m)} binom(m,j)] .           (F3)

Markov gives `Pr_H[B_k>t]≤E B_k²/t²`. All summands and the formula are exact; this is a directly checkable pseudorandomness certificate. For k fixed and N=m it vanishes exponentially in m. It is not a sufficient substitute for the net argument when k=q(T) is huge.

**Bernstein–Vazirani codeword law:** For `X_y=(-1)^{s·y}`, `s∈F_2^m` uniform, choose nonzero distinct u,v with w=u⊕v (m≥2). The **degree-three Fourier character** `X_u X_v X_w=1` for every s, whereas its expectation under independent uniform bits is 0. So `B_3≥1`. This witnesses non-pseudorandomness at degree 3 without reference to a simulator.

**Unconditioned Gaussian-sign Forrelation:** Let `N=2^r`, `A_{ij}=(-1)^{i·j}`, `U=A/sqrt(N)`, Z independent standard Gaussians, and `F_i=sgn Z_i`, `G_j=sgn(UZ)_j`. The quadratic Forrelation statistic

    Q(F,G)=N^{-3/2} Σ_{ij} A_{ij} F_i G_j

is globally in [-1,1], because `A^T A=NI`. For independent uniform F,G it has expectation 0. The classical bivariate Gaussian sign formula `E sgn(V)sgn(W)=(2/π)arcsin(corr(V,W))` gives

    E_Forrelation Q=(2/π) sqrt(N) arcsin(1/sqrt(N))≥2/π.   (F4)

Hence `B_2(Forrelation)≥2/π`; an explicit bounded quadratic test detects structure at constant advantage. **This is prior-art Forrelation behavior** (Aaronson–Ambainis and subsequent work), not an independently novel Forrelation lower bound. It applies to the unconditioned Gaussian-sign ensemble and should not be silently transferred to a different promise-conditioned law.

## 6. Independent adversarial checker, novelty and decision gate

Script: `research/nightfall/structural_information/check_structural_fourier_exact.py` (separate exact Python). It checks (i) exhaustive H tables at (m,N)=(1,1),(2,2) against (F3), (ii) independent character-expansion and pairwise-kernel formulas for B_k², (iii) rational Fourier Cauchy transfers, (iv) exact BV parity witness, and (v) Walsh–Hadamard orthogonality and global boundedness for the Forrelation quadratic form. **3,158 exact integer/Fraction assertions passed locally**, with SHA-256 `170344f61355cfa31f854ae0e3fe0a4cadb8b32cced56f430a47cd4196ea2a0b` for the tested source bytes. This cannot certify Gaussian integration, universal bounds, uniqueness, or external novelty.

Prior-art anchors:
- multivariate Wyner≥DTC: Li et al., IEEE TIT 2017, Eq. (4): https://isl.stanford.edu/~abbas/papers/Distributed%20Simulation%20of%20Continuous%20Random%20Variables.pdf
- original AA uniform simulation / degree: Aaronson–Ambainis, *The Need for Structure in Quantum Speedups*, Theory of Computing 2014: https://www.theoryofcomputing.org/articles/v010a006/v010a006.pdf
- bounded independence/low-degree tests and averaging samplers: conventional Fourier/PRG literature; e.g. https://drops.dagstuhl.de/storage/00lipics/lipics-vol339-ccc2025/html/LIPIcs.CCC.2025.6/LIPIcs.CCC.2025.6.html
- Gaussian-sign Forrelation expected correlation at least 2/π: https://drops.dagstuhl.de/storage/00lipics/lipics-vol362-itcs2026/LIPIcs.ITCS.2026.72/LIPIcs.ITCS.2026.72.pdf
- exact Gaussian sign identity: https://www.cs.toronto.edu/~toni/Courses/Proofs-SOS-2018/Lectures/grothendieck.pdf

**Next decisive experiment:** independent source-level refutation attempt of (F1)–(F4) and exact query-tree degree q under adaptive symbol queries, followed by separate Lean kernel statements for the finite Boolean Fourier operator (not the Gaussian sign theorem without an analytic source import). Then compare the graph distribution to cheaper local representations *with a formally specified c,c′,S cost*, rather than asserting `Λ_T(D_H)≫1` from intuition. Contributor/AI source acknowledgment and human publication approval required. Do not promote any paper-level candidate to “certified” or “novel” on the finite checker alone.
