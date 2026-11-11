# Wright product-space influence — v5 release candidate (11 November 2026)

**Status:** draft for independent specialist review; not submitted to arXiv; not a globally certified originality claim.

## Exact source
- LaTeX: [Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v5.tex](./Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v5.tex)
- Source SHA-256 (independent local file calculation): `28b58569943afb274d687a0f437ed0ecc6d6a57161c427dcb75ee7ac2dca8999`
- Author's recovered v5 PDF SHA-256: `1b6dab7414d3054664da361e58ede0f1b0c2e1b5847768e3936a0f4ddc8f85ec` (PDF is in the research Library, **not committed** by this PR).
- The new manuscript was independently recompiled with `pdflatex -interaction=nonstopmode -halt-on-error` twice: 26 pages, no undefined-reference or overfull-box diagnostics in the second run. The replayed PDF may have a different binary hash because of PDF metadata.
- GitHub `fetch_file` after staging reproduced the recovered source exactly (86,483 characters including terminal newline).

## Primary results and explicit limits
1. **Theorem 1.1:** analytic general-degree uniform-in-law product-space influence, `max_i I_i(f) >= c_prod Var(f)^(5/2)/d^6`. This is an adaptation of Turturean's 2026 uniform-cube machinery; not an independent proof of his conjecture.
2. **Theorem 1.2:** analytic arbitrary-product quadratic bound `Var(f) <= 15(1+sqrt(3)) B sqrt(max_i I_i(f))`, with the complete matching/fourth-moment argument in Section 12. Independent outside-team proof review and global priority review remain outstanding.
3. **Proposition 1.3:** disjoint quadratic sign-pairs show exponent two is optimal; this is elementary, not asserted to be globally novel.
4. **Quantum corollaries:** known independent finite-alphabet laws, coherent whole-symbol value oracle, existence of decision trees, unrestricted offline work; no runtime guarantee, no arbitrary correlated-input simulation.
5. **Lean:** the named finite-product theorem is kernel-checked with its **weaker** coefficient; neither Theorem 1.1 nor 1.2, arbitrary measurable products, nor the quantum corollaries have been verified end-to-end in Lean.

## Referee and publication gates
- Independently reconstruct the full analytic matching/assignment proof and audit Section 12's constant.
- Review the stronger all-degree localized two-draw, median, and sharp-resampling steps.
- Search prior categorical bilinear/Grothendieck and Fourier-completely-bounded work for exact same-scope theorems.
- Freeze a reviewed source and externally submit only with author authorization; neither a draft PR nor a successful LaTeX compilation is arXiv publication.

## Priority comparison
- Turturean, arXiv:2611.09773 (6 Nov 2026): uniform Boolean cube, exponents (5/2,6).
- Girish–Mittal–Nehoran–Raz, arXiv:2609.35327 (28 Sep 2026): distributional variants; quantitative bias dependence.
- Escudero Gutiérrez, arXiv:2304.06713 (2023): exponent-two on Fourier completely bounded homogeneous polynomials, stronger norm hypothesis.
- Aaronson et al. (CCC 2016) and Briët–Escudero Gutiérrez–Gribling (Quantum 2024): Boolean-cube quadratic / Grothendieck comparisons.
- Blanc et al., arXiv:2611.11626 (8 Nov 2026), and Huffstutler–Miloschewsky–Podder, arXiv:2611.12795 (9 Nov 2026): new proofs/exposition in the same fast-moving frontier.

Authorship: Devin J. Wright (NIGHTFALL); manuscript acknowledges AI assistance and all cited contributors.
