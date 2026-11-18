# Rényi-stable quantum query simulation (research draft, 2026-11-18)

Status: author-side derivation, not independently reviewed or Lean checked. Depends on the Lean-checked product-space AA bound in NIGHTFALL PR #858 (CI 44406881226); branch stacked on that PR. Not a novelty or breakthrough claim.

## Theorem A: product-space simulator

Let μ=⊗_{i=1}^n μ_i be any finite product of discrete probability spaces with possibly unequal coordinate alphabets, biases and zero-mass atoms. If f:∏Ω_i→[0,1] has Efron–Stein degree ≤d with d≥1, then for ε,δ∈(0,1) a deterministic classical decision tree (whose branching queries each whole coordinate symbol) produces D with

Pr_μ(|D(X)-f(X)|≥ε)≤δ,

using at most ceil(22000 d^7 ε^(-5) δ^(-7/2)) queries. This is **query complexity only**, not a polynomial-time construction.

**Proof.** Set c=8 sqrt(3/12500)/π^6. Center f by 1/2 and apply PR #858 to obtain max_i I_i(f)≥c Var(f)^(5/2)/d^6. The independent-product ANOVA decomposition yields J(f):=∑_i I_i(f)=∑_{S≠∅}|S|‖f_S‖²≤d Var(f)≤d/4. Conditional on the revealed value of a chosen coordinate i, the remaining law stays product and the conditional f stays bounded and of degree≤d. The *exact* expected potential identity is E_{Xi}J(f|Xi)=J(f)−I_i(f). Recursively query an index of largest conditional I_i as long as conditional variance V>η:=ε²δ/2. Each active step decreases expected potential by at least a:=c η^(5/2)/d^6. Hence the expected stopping time τ obeys a Eτ≤J(f)≤d/4, so Eτ≤d^7/(4c η^(5/2)). Truncate after ceil(2 Eτ/δ) steps (or the explicit bound); Markov gives truncation probability≤δ/2. At each successful leaf output the conditional mean, whose conditional additive-error probability is ≤η/ε²=δ/2 by Chebyshev. Since 2^(3/2)/c≈21940.6062<22000, the displayed bound follows.

**Important adversarial counterexample.** A single query need not decrease conditional variance by its heat-bath influence: for independent fair signs X1,X2 and f=(1+X1X2)/2, V=I_1=1/4 but E_{X1}Var(f|X1)=1/4. The correct potential is total influence J, not V.

## Theorem B: arbitrary correlated distributions at bounded Rényi divergence

Let ν≪μ be any joint distribution, α∈(1,∞], and K=D_α(ν‖μ) in natural logs. The tree can be chosen so that

Pr_ν(|D(X)-f(X)|≥ε)≤δ

with at most

ceil(22000 d^7 ε^(-5) exp(7K/2) δ^(-7α/[2(α-1)]))

whole-symbol queries, with exponent δ^(-7/2) when α=∞. A T-query quantum decision algorithm has an acceptance-probability function of coordinate degree≤2T in the standard one-coordinate symbol-oracle model; substitute d=max(1,2T).

**Proof.** For h=dν/dμ, Hölder gives ν(E)≤(E_μ h^α)^(1/α) μ(E)^((α−1)/α)=exp((α−1)K/α) μ(E)^((α−1)/α). For α=∞, ν(E)≤exp(K)μ(E). Run Theorem A with product failure δ0=exp(−K) δ^(α/(α−1)), interpreting the exponent as 1 for α=∞. Then ν(error)≤δ; substituting δ0 proves the query count.

Let R_α(ν)=inf_{product μ}D_α(ν‖μ), which allows an optimal independent reference. If R_α(ν)=O(log T) uniformly over instances, a T-query quantum decision acceptance function has a classical poly(T,1/ε,1/δ)-query approximation, for fixed α>1, ε and δ. Therefore a superpolynomial query advantage at fixed accuracy and success probability requires R_α(ν)=ω(log T). This is a *necessary condition*, not a characterization.

For ν=μ conditioned on S of μ-probability ρ, D_α=log(1/ρ) and the Hölder event inequality for E=S holds with equality. Thus the event-transfer dependence is sharp; the query exponent itself is not claimed optimal. KL divergence alone does not give the same polynomial event transfer: set μ(E)=e^(−N), ν(E)=1/N and ν outside E proportional to μ. Then D_KL(ν‖μ)=O(1) while ν(E) decays only as 1/N.

## Auxiliary theorem C: likelihood-ratio-stable heat-bath influences

If 0<a≤dν/dμ≤b μ-a.s., true conditional-resampling influences satisfy

a I_i^μ(f)≤I_i^ν(f)≤b I_i^μ(f),  Var_ν(f)≤b Var_μ(f),

and so max_i I_i^ν(f)≥c a b^(-5/2) Var_ν(f)^(5/2)/d^6.

Proof: disintegrate with respect to all coordinates except i and use the variational form of conditional variance:
I_i^ν(f)=∫_{μ_-i} inf_{z∈R}∫_{μ_i}h(x_-i,x_i)(f(x)-z)^2 dμ_i dμ_-i.
Bound h by a and b. The global variance comparison uses the same variational form. DO NOT use the product total-influence decrement identity under ν; it does not generally hold for correlations.

## Audit and provenance

Independent exact Fraction spot checker: research/nightfall/2026-11-product-all-degree/check_renyi_transfer.py. Tests heterogeneous binary–ternary–binary original laws, degree-two Efron–Stein decomposition, all coordinate J decrements, a correlated nonproduct tilt, and the parity counterexample. Tests do not establish an all-instance theorem.

Sources checked 2026-11-18: David Turturean (arXiv:2611.09773); Aaronson–Ambainis 2014; Girish–Mittal–Nehoran–Raz, Distributional Variants (arXiv:2609.35327); Huffstutler–Miloschewsky–Podder, completion framework (arXiv:2611.12795); NIGHTFALL #858. Rényi/Hölder transfer is standard. Independent novelty/priority review and new Lean certificates remain OPEN. Keep this draft stacked on #858; no flagship release or merge.

Next proof gate: Lean-formalize finite Theorem A using the independently verified J-decrement identity, then formalize finite-space Hölder transfer separately. Seek adversarial referee review and exact earlier work addressing Rényi-near-product quantum query simulation.
