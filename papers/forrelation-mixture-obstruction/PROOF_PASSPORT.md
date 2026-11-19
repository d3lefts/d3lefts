# Proof Passport — Gaussian-Sign Forrelation Mixture Obstruction

**Release:** NIGHTFALL companion working preprint v0.1, 2026-11-19.  
**Canonical manuscript:** [COMPANION_PAPER.md](COMPANION_PAPER.md).  
**Authors / review:** NIGHTFALL collaboration, final authorship and AI-assisted reviewer contributions to be reconciled; no independent human referee sign-off and no novelty certification.

## Exact claims, assumptions, and evidence

| ID | Exact claim | Status | Required external dependencies |
| --- | --- | --- | --- |
| FMR-01 | For any orthogonal \(N\times N\) matrix \(H\), the **unconditioned** law of \((\mathrm{sgn}Z,\mathrm{sgn}(HZ))\) has \(\log M\ge \sum_i\phi(r_i)\ge N\phi(2/\pi)\) for every \(M\)-component **block-product** mixture | Self-contained mathematical paper proof; **not complete Lean certificate** | Gaussian orthogonal transformation preserves iid standard normals; Sheppard sign-correlation identity; fair-sign information/Jensen; data processing |
| FMR-02 | Flat Walsh–Hadamard strengthens to \(\log M\ge N\phi((2\sqrt N/\pi)\arcsin(N^{-1/2}))\) | Paper proof | FMR-01; equal-magnitude entries |
| FMR-03 | For \(\mathrm{TV}(P,Q)\le\eta\le1/2\), every block-product mixture \(Q\) satisfies \(\log M\ge N[\phi(2/\pi)-2\eta\log2]-2h_2(\eta)\) | Paper proof, finite checks; **not complete Lean certificate** | FMR-01; common-part decomposition; classical conditional-entropy continuity |
| FMR-04 | Earlier weaker \(\log M\ge (2/\pi^2)N\) | Paper proof; abstract finite MGF operator pinned-Lean checked | Single Forrelation statistic; Rademacher MGF; Gibbs variational inequality; Sheppard |
| FMR-05 | Gaussian sign arcsine identity formally certified in Lean | **OPEN** | Mathlib issue [#42600](https://github.com/leanprover-community/mathlib4/issues/42600) |
| FMR-06 | Specific Forrelation bound novel relative to all prior art | **OPEN** | Dedicated dated priority, subject-expert assessment |

## Sources and controls

- **Constructed source:** Aaronson–Ambainis, 2018, [original Forrelation paper](https://arxiv.org/abs/1411.5729); Girish–Servedio, ITCS 2026, [Gaussian sign discussion](https://doi.org/10.4230/LIPIcs.ITCS.2026.72).
- **Prior-art mechanism:** Wyner common information (1975); Tim Austin, [mixtures of products](https://doi.org/10.14736/kyb-2020-3-0459) (2020). We do **not** claim invention of latent mixture data-processing, Jensen, binary entropy, or Sheppard's formula.
- **NIGHTFALL origin:** exponential mixture-obstruction idea appears in [PR #858 AI-assisted review](https://github.com/d3lefts/d3lefts/pull/858); sharp binary entropy and robust transfer in [PR #868 note](https://github.com/d3lefts/d3lefts/pull/868). The raw exact checkers were copied **without editing** from the source branch.
- **Lean limited certificate:** [PR #869](https://github.com/d3lefts/d3lefts/pull/869), [successful pinned run 44459219905](https://github.com/d3lefts/d3lefts/actions/runs/44459219905), source SHA \`99a2f6e32ac8be925ae3af1c7f193e765b562cac716cad7e2aba18c6b9edd540\`. Certifies abstract MGF-to-mixture exponent, not FMR-01/02/03.
- **Related conditional formalization:** [PR #871](https://github.com/d3lefts/d3lefts/pull/871) retains substantive analytic hypotheses and is not an end-to-end Gaussian-sign certificate.

## Reproducibility

Run:

    python3 papers/forrelation-mixture-obstruction/check_reproduction.py
    python3 papers/forrelation-mixture-obstruction/check_original_mgf.py

Both use Python standard library and finitely many cases. The first checks 3,486 rational conditional-entropy cases, exact \(N=2\) angular sectors and block support rank, robust examples, and the constants. The second checks small uniform Rademacher MGF cases and original \(2/\pi^2\) coefficient.

The exact numerical values, in natural logarithms, are:
\[
2/\pi^2=0.2026423672846755428877589\ldots,
\quad
\phi(2/\pi)=0.2192005468261677914571466\ldots.
\]
For \(\eta=0.01\), the robust coefficient is \(0.2053376032149688852688020\ldots\), with offset \(2h_2(\eta)=0.1120030687096946809041464\ldots\).

**Finite tests are falsifiers, not a proof of universal quantification.** Proof dependencies, authorship, external review, and exact prior-art clearance remain independent gates.

## Limits and release boundaries

This result concerns the unconditioned Gaussian-sign law on \(2N\) Boolean symbols. It does not extend automatically to a promise-conditioned YES distribution, arbitrary source distributions, all quantum-hard inputs, or efficient classical runtime. A high mixture rank is not sufficient for quantum hardness. It is a **representational obstruction**, not a quantum query lower bound. This repo release is public working-paper publication, **not arXiv submission, peer-reviewed publication, or an academic-venue acceptance**.

**Next decisive Lean test:** formalize finite fair-sign information/Jensen under an explicit correlation witness, then Sheppard's analytic sign law and its orthogonal Gaussian specialization. Do not promote any conditional terminal before its analytic premises are kernel-checked.
