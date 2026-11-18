# Exact fair-binary cubic routing: high-kurtosis proof attack

**Checkpoint:** 2026-11-17 US Eastern. **Direction:** Devin J. Wright / NIGHTFALL, AI-assisted construction and checking. **Status:** explicit finite mathematical construction; direct exact-arithmetic checker; **no unrestricted cubic upper theorem, Lean proof, independent human review, or dated novelty sign-off**.

## Representation and analytic certificate

Let (A_{s,t}), for (s,t\in\{-1,+1\}), and (B_1,B_2,C_1,C_2) be eight independent fair signs. Set

[
Q_{s,t}(B,C)=\frac{(B_1+sB_2)(C_1+tC_2)}4,\qquad
f=\sum_{s,t\in\{\pm1\}}A_{s,t}Q_{s,t}.
]

Every term in the expanded polynomial has **degree exactly three**, one coordinate from A, B and C. There are exactly sixteen distinct Walsh characters, all with coefficient (\pm1/4); all other characters vanish.

For every fixed B,C, exactly one row survives:
[
(s_*,t_*)=(B_1B_2,C_1C_2),\quad Q_{s_*,t_*}=B_1C_1,
\quad f=B_1C_1 A_{s_*,t_*}\in\{\pm1\}.
]
Thus (B_0=\|f\|_\infty=1), (mathbb Ef=0), and (V=\operatorname{Var}(f)=1). For each leaf (A_{s,t}), its source resampling influence is (1/4) (four Fourier terms). For each of the four B/C selector coordinates, the influence is (1/2) (eight Fourier terms). Therefore (M=1/2).

Every (Q_{s,t}) is a sign on exactly one quarter of B/C inputs and zero elsewhere. Consequently
[
v_{s,t}=\mathbb EQ_{s,t}^2=1/4,\quad \mathbb E Q_{s,t}^4=1/4,\quad
\kappa_{s,t}=4,\quad\sum_{s,t}|Q_{s,t}|=1\text{ pointwise}.
]
All four rows lie above the kurtosis threshold (K=3). Hence
[
\boxed{W_{\mathrm{spike}}(3)=1,\qquad
\frac{W_{\mathrm{spike}}(3)^2}{B_0^2 M}
=\frac{V^2}{B_0^2 M}=2.}
]

**Implication 1:** The particular guess (W_{\rm spike}(3)\le B_0\sqrt M) is **false even on uniform fair bits**. This does **not** refute the repository's general open spike-tail proposal with *some* constants (K_0,C_0).

**Implication 2:** Any universal pure-three-partite link-energy inequality (V\le C B_0\sqrt M) needs (C\ge\sqrt2). This improves the repository's prior *explicit pure-cubic example* (V^2/(B_0^2M)=25/24) and Hadamard ratio 1. It is a local witnessed improvement, **not an externally established best-known record**.

## Transfer, limitations, and operator choice

For (m\ge1), use (m) disjoint independent copies and set (f_m=m^{-1}\sum_{r=1}^m f^{(r)}). Then (B=1), (V=1/m), (M=1/(2m^2)), each row still has kurtosis four, and the squared normalized variance/spike ratio is 2. Every gadget has cubic cover number two: no single coordinate intersects all sixteen triples, while both B coordinates cover them. The disjoint union therefore has cover number (2m\to\infty).

**Limitation:** These replicated instances have independent blocks, so the repository's already proved restricted independent-block result covers them. They do not address arbitrary dense *connected* interlocking cubic links and do not close exponent two.

**New mechanism to transfer:** spikes are not exclusively a rare-atom phenomenon. **Low-degree balanced routing** can create mutually exclusive aggregate-link activations with high fourth moments. A future universal spike-tail argument must combine the selector-coordinate influences with overlapping-link cancellation. A decisive next test should interlock this routing gadget with the Hadamard connected family and search for a dimension-free energy certificate.

## Checker

`python3 -I research/nightfall/2026-11-12-cubic-overlap/check_fair_binary_routing.py`

This Python-standard-library checker exhausts the entire 256-state source table, computes each *genuine* influence from sign-flip conditional differences, separately computes all 256 Walsh coefficients from the table, and separately checks the B/C row second and fourth moments. Exact rational/integer arithmetic only. This is **finite exact verification**, not a Lean or global mathematical theorem certificate.

**Prior scope controls:** [Original tripartite conjecture](../../new-moon/spectral-observability/homogeneous-cubic-v8/TRIPARTITE_LINK_OPERATOR.md) and [conditional spike-tail analysis](AGGREGATE_LINK_OVERLAP_LEMMA.md). Known antecedent Turturean [arXiv:2611.09773](https://arxiv.org/abs/2611.09773), whose exponent-2 quantitative question remains open in the stated generality.
