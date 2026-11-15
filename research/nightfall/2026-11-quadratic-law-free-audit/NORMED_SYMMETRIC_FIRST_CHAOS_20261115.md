# First-chaos budget for symmetric independent increments in any normed space

**Research date:** 2026-11-15 UTC. **Status:** complete analytic proof, new broader scope and simpler operator than the Hilbert-only proof in merged PR #574. **Not Lean-certified, not independently human reviewed, novelty unestablished.** The all-length asymmetric nonorthogonal theorem and unrestricted Q2 C96 remain OPEN.

## Theorem

Let E be *any real normed linear space*, and let Y₁,…,Yₙ be independent symmetric finite-valued E-valued random vectors with ||Yᵢ|| ≤ c. For arbitrary deterministic h∈E, set F=||h+ΣᵢYᵢ||, u=EF, and W₁=Σᵢ Var(E[F|Yᵢ]). Then

```
W₁ ≤ ||h||² + c u .
```

Unlike the Hilbert proof, this argument uses no inner product or subgradient.

## Normed-space deletion lemma (new proof operator)

For fixed h,v₁,…,vₙ in E and independent fair signs εᵢ, put R=Eε||h+Σᵢ εᵢvᵢ|| and R₋ᵢ=Eε||h+Σⱼ≠ᵢ εⱼvⱼ||. Set Δᵢ=R−R₋ᵢ. Then

```
0 ≤ Δᵢ ≤ ||vᵢ||,     Σᵢ Δᵢ ≤ R.                        (D)
```

The first two bounds follow from sign-pair Jensen and the triangle inequality. For n=1 the last bound is R−||h||≤R. For n≥2, set S=Σ εᵢvᵢ and t=(n−1)/n. Jensen for *each fixed sign vector* yields

```
(1/n) Σᵢ ||h+S−εᵢvᵢ|| ≥ ||h+tS||.
```

Taking sign expectations: Σᵢ R₋ᵢ ≥ n E||h+tS||. Let g(a)=E||a+S||; symmetry of S makes g even, and the norm makes g convex. Any even convex g is radially nondecreasing, so g(h/t)≥g(h). By positive homogeneity,

```
E||h+tS|| = t g(h/t) ≥ t g(h)=tR.
```

Thus Σᵢ R₋ᵢ ≥ (n−1)R, proving (D). This is valid in every normed space. No Hilbert support-vector choice is used.

## First-chaos sign/amplitude decomposition

Represent each Yᵢ in law as εᵢVᵢ, with independent Vᵢ~Yᵢ and fair independent signs. For fixed v, set Q_h(v,ε)=||h+Σ εᵢvᵢ||, R(v)=EεQ_h(v,ε), and tᵢ(v)=Eε[εᵢQ_h(v,ε)].

The conditional norm mean given Zᵢ=εᵢVᵢ is

```
gᵢ(Vᵢ,εᵢ)=qᵢ(Vᵢ)+εᵢ bᵢ(Vᵢ),
qᵢ(vᵢ)=E_{V₋ᵢ} R(V),
bᵢ(vᵢ)=E_{V₋ᵢ} tᵢ(V).
```

This really is conditioning only on Zᵢ: the independent other blocks are averaged and the function depends on (vᵢ,εᵢ) solely through εᵢvᵢ. The fair sign gives the exact identity

```
W₁ = Σᵢ Var(qᵢ(Vᵢ)) + Σᵢ E[bᵢ(Vᵢ)²].          (S)
```

For the sign term, Q₀(v,ε)=||Σ εᵢvᵢ|| is invariant under global sign reversal, so Eε[εᵢQ₀]=0. Scalar Bessel orthogonality of the Rademacher signs and reverse triangle yield

```
Σᵢ tᵢ(v)² ≤ Eε[ (Q_h−Q₀)² ] ≤ ||h||².
```

Conditional Jensen then gives Σᵢ E bᵢ² ≤ ||h||².

For amplitudes, product ANOVA orthogonality and Efron–Stein give

```
Σᵢ Var(qᵢ(Vᵢ)) ≤ Var(R(V))
   ≤ Σᵢ E[(R−E[R|V₋ᵢ])²]
   ≤ Σᵢ E[(R−R₋ᵢ)²]
   = Σᵢ E[Δᵢ²]
   ≤ c EΣᵢΔᵢ
   ≤ c E R = c u.
```

Together with (S), this proves the theorem.

## Audit and boundaries

This is an analytic **all-n, arbitrary normed space, symmetric-product-law** theorem. It handles random amplitudes, zero atoms, heterogeneous distributions, and nonorthogonal directions. Exact external regression tests exercise ℓ₁ and ℓ∞ norms, which are not Hilbert norms, and check the pointwise deletion lemma and full first-chaos budget. Regression evidence is NOT a theorem certificate.

The required unrestricted centered asymmetric-law inequality remains unresolved, as does the universal 6B owner cover. Do not advertise an unconditional source-level Q2 coefficient below 100 from this result.

**Dependencies and priority:** PR #574 supplies the earlier Hilbert sign/amplitude proof; the normed deletion mechanism here replaces Hilbert subgradients with Jensen plus radial convexity. External comparisons required before originality: Latała–Oleszkiewicz (1994), sharp symmetric Rademacher L₁/L₂; Oleszkiewicz (2003), nonsymmetric Khintchine–Kahane; standard Efron–Stein/self-bounding methods.

**Checker:** `check_normed_symmetric_first_chaos.py`. Expected output: 34,944 exact cases, 168 zero-slack cases, minimum slack 0, SHA256 of ordered receipt stream `98fd56b8b714d3eac0aab95b49bf62cab3a50858fbdfd69365db8d464a90acd1`.
