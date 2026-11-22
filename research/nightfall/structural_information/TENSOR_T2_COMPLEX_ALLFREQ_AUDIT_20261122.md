# Adversarial bridge: all-frequency primitive histogram and complex effects (2026-11-22)

**Certificate status:** [Exact-source CI PASS at commit 926cd7e72ee359f009b8d213a558edfe213b01c5](https://github.com/d3lefts/d3lefts/actions/runs/45055233596), source SHA-256 in [receipt 14766907071](https://github.com/d3lefts/d3lefts/actions/runs/45055233596/artifacts/14766907071). This is finite **adversarial execution**, not a mathematical all-level proof or Lean certificate for the full two-query simulator. Exact checker sources:
- [check_tensor_all_frequency_primitive_L4.cpp](check_tensor_all_frequency_primitive_L4.cpp)
- [check_tensor_t2_complex_group_energy_exact.py](check_tensor_t2_complex_group_energy_exact.py)

## A. Exact all-nonzero-frequency primitive histogram, L≤4

The earlier all-k polynomial law applies when the target z is itself a pure tensor row. Quantum Fourier frequencies include arbitrary nonzero XORs of up to four rows; a pure-row-only count must **never** replace a supremum over those frequencies.

Let A_k(z) count primitive distinct unordered k-row representations of z. For all z≠0 (pure or not), the independently implemented algorithm constructs exact unordered pair XOR frequencies p_v, then computes
\[
 \operatorname{All4}(z)=[\sum_v p_v p_{v\oplus z}-2(n-2)p_z]/6,\quad
 A_4(z)=\operatorname{All4}(z)-1_{z\in R}(T_0-p_z),
\]
where \(T_0=\#\{\text{unordered zero-XOR row triples}\}\). This excludes precisely the nonprimitive four-sets containing a zero triple, and requires no \(\binom n4\) quadruple enumeration. Similarly \(A_3(z)=[\sum_{r\in R}p_{r\oplus z}-(n-1)1_{z\in R}]/3\), with \(A_2(z)=p_z\) and \(A_1(z)=1_{z\in R}\). All divisibilities and nonnegativities are asserted, not tolerated.

Exact complete histogram maxima over **every** nonzero frequency z in the ambient \(\mathbb F_2^{2^L}\):

| L | pure-row maximum total | global maximum total | global maximum primitive four-row | witness nonrow when global greater |
|--:|--:|--:|--:|--:|
| 1 | 2 | 2 | 0 | none |
| 2 | 12 | **16** | 6 | mask z=6 |
| 3 | 61 | **84** | 72 | mask z=24 |
| 4 | 179 | 179 | 150 | none needed |

**New negative control:** At L=2 and L=3, the maximizer is NOT a pure tensor row. At L=2, nonrow max is 16 against 12 at a row; at L=3, 84 against 61. Therefore the exact pure-row binomial polynomial is *not a global primitive-four-lift maximum theorem*. This is a proof attack on any argument that conflates original-row frequencies with general acceptance Fourier frequencies. It does not refute #1016, which explicitly claims a separate all-frequency K_L bound; that bound still needs independent all-L mathematical audit.

## B. Exact complex, nonprojective effect tests

A second independently implemented checker uses rational orthogonal unitaries mixed with independent fourth-root-of-unity diagonal phases to generate genuinely complex two-query amplitudes. It evaluates the operator effect in two cases: a **nonprojective, full-rank effect** with rational eigenvalues inside (0,1), and a nontrivial high-rank projection. Exact calculations lie in \(\mathbb Q(i)\): Fourier coefficient aggregation, direct acceptance computation on all hidden secrets, and effect positivity are tested without floating-point tolerance.

At tensor depths L=1 and L=2 and thresholds η=1/100,1/10,1/2, it checks the individual outside-heavy-span energy bounds for each of the **six repeated-slot equality events** and each of the **four distinct-label zero-triple survivor groups**, against 2Mη and 20Mη respectively. The checks PASS in the pinned workflow with a separate source hash receipt. These are important operator-identity controls, especially because rank-free T2 cannot assume orthogonality of paths with the same XOR frequency.

**Qualification:** The finite circuits deliberately have rational rotations, unit workspace sectors, and a restricted phase parameterization. They do not prove inequalities for all complex unitaries, all effects, arbitrary ancillary workspace dimensions, or arbitrary L. The nonprojective effect tests are sufficient to challenge several false reductions, not sufficient for a theorem.

## C. Kernel certification and follow-ups

- [Lean source-exact PASS run 45054675450](https://github.com/d3lefts/d3lefts/actions/runs/45054675450) on head b8595999ec1ab7ad89c696abd40897119368e07f: actual kernel replay of repeated-label cancellations, **complete L=1,2 pair fiber classification**, and **five local primitive count lemmas through L=3**. The earlier failed Lean versions are retained in Actions history; their gaps were repaired with computable parity-of-bits definitions.
- [Dedicated local pair-spectrum Lean PASS run 45054675690](https://github.com/d3lefts/d3lefts/actions/runs/45054675690); build+leanchecker+standard axiom receipt and source hashes independent of the larger L3 enumeration.
- Source-level all-L tensor primitive polynomial remains paper-level with the **published Lovitz–Petrov 2023 splitting theorem** as explicit prior-art dependency; global novelty not cleared.
- Rank-free full two-query circuit theorem **remains an archived paper candidate** under [issue #1021](https://github.com/d3lefts/d3lefts/issues/1021), no complete Lean terminal, external specialist audit or priority clearance.

**Next decisive mathematics:** Independently prove or falsify the K_L all-frequency bound for *minimum primitive reference representations of size 3 and 4*, not merely pure z, and formalize the arbitrary-complex Hilbert-space path-frame inequality. Preserve the full frequency histogram as the negative-control fixture; avoid using any pure-target coefficient as an all-frequency bound.
