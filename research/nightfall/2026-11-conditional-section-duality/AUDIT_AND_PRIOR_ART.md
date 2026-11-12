# Conditional-section duality: prior art, failure tests, and certification scope

Version 0.1, 2026-11-12. Claim owner/program: NIGHTFALL Constellation (Devin J. Wright). Public repository working record, not a certified novel contribution.

## Directly checked external comparators

1. Filmus--Hatami--Keller--Lifshitz, On the sum of the L1 influences of bounded functions (arXiv:1404.3396): classical low-degree L1-influence machinery and endpoint Markov argument. The section-budget step is a standard consequence, not claimed original.
2. Escudero Gutiérrez--Saucedo--Palazuelos, Optimal inequalities for completely bounded polynomials and the limitations of quantum query algorithms (arXiv:2609.05201, submitted 2026-09-04): obtains an optimal root-influence bound and NONADAPTIVE classical simulation for completely bounded block-multilinear polynomials. Its stated norm assumptions differ; the exact reduction to an arbitrary bounded-Hoeffding-product beta criterion has not been excluded. Do not describe nonadaptivity itself as first discovered here.
3. Turturean, A proof of the Aaronson--Ambainis conjecture (arXiv:2611.09773, 2026-11-06): arbitrary degree on fair cube, polynomial degree dependence, variance 5/2 bound, a different output from the present fixed-query result.
4. Classical real Khintchine, Bonami--Beckner hypercontractivity, Hoeffding ANOVA, Popoviciu, and Markov polynomial derivative inequalities are imported.
5. Existing NIGHTFALL conditional-root-influence proposals in fair-sign, mixed-law and cubic-leaf branches are antecedents, not automatically new theorems.

Primary exact claim: for bounded scalar finite-product interaction degree <=d and beta>0,
    min_{|S|<=q} E(f-E[f|X_S])^2 <= d^4 B^2/(beta^2 q).
The proof invokes (a) L1 sum of conditional standard deviations <=2d^2B; (b) sum of sqrt influences <=2d^2B/beta; (c) sorted root-influence tail <=L^2/(4q). Each step is explicit in README.md.

Adversarial checks: (i) rare-address block has beta=k^(-1/2), so no distribution-free NONADAPTIVE bound follows solely from low degree; (ii) beta of control sections can change after revealed transcripts, so the claim does not imply arbitrary posterior inheritance; (iii) higher-degree fair sign bounds incur 9^(d-1), so not degree-polynomial; (iv) the beta-parameter theorem is scalar only, not an operator-valued Hilbert bound, and the complex/quantum setting requires a separate proof; (v) arbitrary uncountable input index sets, zero-probability pointwise sections and computational cost are not covered by this standalone finite-product source.

Audit checklist: rerun Python source; adversarially check equality and missing-coordinate ANOVA decomposition; verify k=2 gate beta comparison; audit exact conditional-mean variance for address cases WITH and WITHOUT querying the gate; check L4/L2 to L1 constants; perform independent human literature comparison before any priority claim. Counterexample searches do not prove universal inequalities.

Certification status:
- Finite exact/numerical falsification: PASS (180 generated models, 352 address-query subsets).
- Universal finite-product proof: self-contained ANALYTIC ARGUMENT; not independently non-author reviewed.
- End-to-end Lean: NOT DONE.
- Arbitrary measurable finite-input factors: written L2-approximation argument; not independently audited.
- Arbitrary-index product generalization: NOT CLAIMED here.
- Worldwide priority: OPEN.
- Public scientific promotion or submission: NOT AUTHORIZED.

For original checkpoint provenance: November 12 conversation research ZIP SHA-256 02236687cece107747b84112d6bc4fc30c174381d1262f9e8b7997cb9effc379; original PDF/TeX/audit included in that ZIP, but this Git commit contains a separately edited Markdown derivation and independently authored small checker. Do not represent source hashes from the conversation ZIP as hashes of these Git files.
