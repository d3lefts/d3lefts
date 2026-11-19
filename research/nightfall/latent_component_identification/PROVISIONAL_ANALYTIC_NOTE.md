# Latent product identification: exact counterexample and bias-free repair
2026-11-19 · NIGHTFALL · **author-side paper proof, provisional; not Lean-certified or novelty-cleared**

## Context and coordination
Companion to parallel PR #893's `COMPONENT_IDENTIFICATION_20261119.md`. That branch obtains an O(d² ε⁻² c⁻² log(1/δ)) product-component query bound under minimum marginal mass c>0. Here we **remove c entirely** using common-part polynomial paths, paying d⁴ instead of d². The unqualified ">2ε" hypothesis is false without a quantitative excess margin. Do not merge an unconditional claim. The normalized circuit to product-degree bridge remains independently gated in #866/#877.

## Counterexample to the unqualified statement
For every integer m≥100 set n=m², p=1/2-20/m, q=1/2+20/m, μ=Bern(p)^n, ν=Bern(q)^n, and f(x)=n⁻¹ Σ_i x_i. This is the acceptance function of a quantum 1-query algorithm (also of a 1-query randomized classical algorithm). Set ε=1/10, a=2/5-10/m, b=3/5+10/m. Then b-a=1/5+20/m>2ε. Under μ, E f=p and Var f=p(1-p)/m² ≤1/(4m²). For m≥100, [p-10/m,p+10/m] lies inside [a-ε,a+ε], so Chebyshev gives μ(|f-a|>ε)≤1/400, and symmetrically ν(|f-b|>ε)≤1/400.
Each distinct coordinate has TV=|q-p|=40/m. Adaptive coupling of the query transcripts gives TV≤40k/m for any randomized classical tree of depth k. Individual errors ≤1/100 imply TV≥49/50, hence k≥49m/2000. Thus t=1 and fixed ε,δ do not bound the identification depth. Scaling 20 with δ yields the same obstruction for any desired small failure target. The defect is the arbitrarily small **excess separation margin**.

## Lemma A: bias-free product expectation stability
Let μ=⊗μ_i and ν=⊗ν_i on arbitrary finite alphabets, including zero atoms. Let f:Ω→[0,1] have indicator interaction degree ≤d≥1. Define η=max_i TV(μ_i,ν_i). Then

    |E_μ f - E_ν f| ≤ 2 d² η.                                  (A)

Proof: For each coordinate let c_i(a)=min(μ_i(a),ν_i(a)), with mass 1-η_i. Decompose μ_i=(1-η_i)r_i+η_i u_i and ν_i=(1-η_i)r_i+η_i v_i; if η_i=1 take r_i arbitrary. With η=max_i η_i>0, the two paths P_u(s)=⊗[(1-sη_i)r_i+sη_i u_i] and P_v(s) (using v_i) are valid product laws for all s∈[0,1/η]. Both start at R=⊗r_i, and at s=1 end at μ and ν. Their expectations of f are real polynomials of degree ≤d (multilinear marginal expectation of every at-most-d-coordinate term) with range [0,1] throughout the interval. Markov brothers' derivative inequality, scaled from [-1,1], gives |g'(s)|≤d²η. Integrate each path from s=0 to1 and apply triangle inequality. η=0 is trivial. QED.

## Theorem B: robust binary identification with logarithmic confidence
Suppose f has degree≤d and values in [0,1]. Assume known product μ,ν, centres a,b∈[0,1], radius ε≥0, concentration failure ≤ρ under **each** law, and **excess margin** g=|a-b|-2ε>0. For ζ∈(0,1) set θ=g/(4d²) and

    K=ceil((2/θ²) ln(1/ζ)) = ceil(32 d⁴ g⁻² ln(1/ζ)).

There is a **nonadaptive deterministic** likelihood-ratio classifier querying at most K coordinates, with each component-wise error ≤max{ζ,4ρ/g}. If ρ≤gζ/4, error ≤ζ. For t-query quantum acceptance, d≤2t yields K≤ceil(512 t⁴ g⁻² ln(1/ζ)), conditional on the usual circuit→degree bridge. Crucially, **no minimum marginal mass, alphabet size, n, or 1/a dependence**.

Proof:
1. Select any K indices with η_i=TV(μ_i,ν_i)≥θ if available; otherwise take **all** such indices. Call the selected set S. Query S and output the larger likelihood μ_S(z) or ν_S(z).
2. If |S|=K, each coordinate Hellinger affinity α_i=Σ_a sqrt(μ_i(a)ν_i(a)) satisfies α_i≤sqrt(1-η_i²)≤exp(-η_i²/2). The overlap L=Σ_z min(μ_S(z),ν_S(z)) ≤∏_{i∈S}α_i ≤exp(-Kθ²/2)≤ζ. The two component errors of likelihood classification **sum** to L.
3. If fewer than K high-TV indices exist, S contains all of them; residual max coordinate TV < θ. For every observed z, the restricted function y↦f(z,y) still has degree≤d. Lemma A implies |q_μ(z)-q_ν(z)|≤2d²θ=g/2 where q are expectations over the residual product laws. Let r_μ(z)=Pr_{μ_tail}(|f(z,Y)-a|>ε), r_ν similarly. Since f,a,b∈[0,1], |q_μ(z)-a|≤ε+r_μ(z) and |q_ν(z)-b|≤ε+r_ν(z). The triangle inequality gives r_μ(z)+r_ν(z)≥g/2. Multiply by min(μ_S(z),ν_S(z)) and sum: (g/2)L≤Σ_z μ_S(z)r_μ(z)+Σ_z ν_S(z)r_ν(z)≤2ρ. Thus L≤4ρ/g. QED.

## Limits, prior art, and certification gates
Theorem B **only** identifies two known components when f is concentrated with a quantitative margin. It does not by itself give arbitrary M-mixture simulation, strong simulation for f not concentrated under components, or a runtime bound. To compose with parallel PR #893, first audit all posterior/leaf conditioning and the product-source simulator; do not silently promote its conditional Theorem 2. External references checked: Blanc–Docter–Strassle–Tan (2026), *Quantum Speedups Require Structure or Depth* (arXiv:2608.19158); Girish–Mittal–Nehoran–Raz (2026), *Distributional Variants of the Aaronson–Ambainis Conjecture* (arXiv:2609.35327); existing classical Markov inequality and Hellinger testing. No complete priority search or independent expert review yet. Numeric checker is only a finite falsifier. Lean scalar certificate (if it compiles) does **not** certify Lemma A or Theorem B. The exact missing Lean targets are (i) degree of interpolated product expectation, (ii) Markov derivative bound, (iii) Hellinger/overlap and quantifier-correct concentration transfer.

## Next decisive experiment
Formalize (A) as an **unconditional finite-product theorem** in the pinned Lean workspace (not as a theorem with a supplied stability assumption). Independently test the quantitative constants and seek a stronger Bernstein/Hellinger route giving O(d²) rather than O(d⁴) **without c**. Then audit PR #893's claimed M-mixture composition against posterior-dependent duels, rare leaves, and strict total failure accounting.
