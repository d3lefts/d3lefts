# Hadamard cubic link family — a bounded dense-overlap stress test

**11 November 2026.** Exact algebraic construction and integer replay. **Not** a counterexample to squared-variance influence, not a new global theorem claim, and not an independently reviewed discovery. The Walsh–Hadamard/bent-function ingredients are classical.

## Construction and exact parameters

For any integer \(k\ge1\) put \(n=2^{2k}=4^k\) and index \(a,e\in\mathbb F_2^{2k}\). Define the Sylvester–Hadamard matrix
\[
H_{a,e}=(-1)^{a\cdot e},\qquad HH^\top=nI_n.
\]
Let \(A_a,B_e,C_e\) be \(3n\) independent fair signs and define the bounded homogeneous cubic
\[
\boxed{f_n(A,B,C)=\frac1{n\sqrt n}\sum_{a,e}H_{a,e}A_aB_eC_e.}
\tag{H}
\]

It is 3-partite: every support is the triple \(\{A_a,B_e,C_e\}\), and there are \(n^2\) nonzero supports.

**Supremum is exactly one.** Given any fixed \(B,C\), let \(z_e=B_eC_e\in\{\pm1\}\). Maximizing over the A signs gives
\[
\sup_A|f_n|=\frac{\|Hz\|_1}{n\sqrt n}
\le\frac{\sqrt n\,\|Hz\|_2}{n\sqrt n}=1,
\]
since \(\|Hz\|_2=n\). Equality is attained by a bent Walsh sign vector
\[
z_e=(-1)^{e_1e_{k+1}+\cdots+e_ke_{2k}},
\]
whose transform has \(|(Hz)_a|=\sqrt n\) for every \(a\). Take \(A_a=\operatorname{sgn}(Hz)_a\) and \(B_e=z_e,C_e=1\). Hence \(\|f_n\|_\infty=1\).

**Variance and influences are exact.** Orthogonality of distinct fair-sign cubic monomials gives
\[
\boxed{
V(f_n)=\frac{n^2}{(n\sqrt n)^2}=\frac1n,\qquad
I_i(f_n)=\frac{n}{(n\sqrt n)^2}=\frac1{n^2}
\quad\text{for every one of the }3n\text{ coordinates}.
}
\]
Therefore \(\max_i I_i(f_n)=V(f_n)^2\). This family **saturates variance exponent two**, not refutes it.

## Structural separation from the parallel-instance theorems

- Every pair \(B_e,C_e\) appears in **n distinct cubic supports**, producing arbitrarily large repeated-pair links.
- The minimum vertex cover of cubic supports has size \(n\): either all A vertices are selected, or, if one A survives, every pair \(\{B_e,C_e\}\) must contribute a selected vertex.
- The minimum vertex deletion set leaving a linear 3-uniform support hypergraph has size \(n-1\): deleting all but one A suffices; if two A vertices remain, each B_e/C_e pair must be hit, costing at least n.
- The n repeated-pair stars are **not independent disjoint blocks**, because every A vertex participates in all n stars.

Thus no fixed-degree constant-size top cover or linearization set applies. The family belongs exactly to the dense, interlocking overlap regime left open by v5/v8 and PR #335.

## Exact failure of naive vector-valued matching

Holding A as an output block, the quadratic link field in B,C is
\[
Q_a(B,C)=\frac{1}{n\sqrt n}\sum_e H_{a,e}B_eC_e.
\]
For every input, \(\sum_a|Q_a(B,C)|\le1\), as proved above. However the vector coefficient for a single disjoint B_e–C_e link is \(v_e=(H_{a,e}/(n\sqrt n))_a\), and
\[
\boxed{\sum_{e=1}^n\|v_e\|_{\ell_1^n}
=\frac{n^2}{n\sqrt n}=\sqrt n.}
\]
The n B_e–C_e links form a matching, yet their summed \(\ell_1\) coefficient norm diverges while the entire link field remains pointwise in the \(\ell_1\) unit ball.

Consequently **the scalar quadratic matching argument does not transfer by simply replacing absolute edge amplitudes with vector \(\ell_1\)-amplitudes**. This is an actual bounded scalar cubic obstruction, stronger in relevance than the abstract weighted-hypergraph no-go in [PROOF_ATTACK.md](PROOF_ATTACK.md). It leaves the hoped-for link-energy inequality LE(C) fully consistent: this family has \(\mathcal V/B\sqrt{\mathcal M}=1\).

## Exact audit and next mechanism

Run \`python3 checks/hadamard_cubic_links.py\`. It uses integer-only Hadamard orthogonality and bent-Walsh identities for n=4,16,64, derives the exact V/M scaling, and exhaustively enumerates all 4096 vertex deletion sets at n=4 to check minimum cover 4 and minimum linearization deletion 3.

The next operator must control **cancellation across disjoint B–C links in an \(\ell_1\) output space** (e.g. via vector Khintchine/cotype or a link-covariance bound), rather than summing \(\ell_1\) norms of individual links. Any proof of LE(C) must include both this saturating Hadamard family and the rare-address selector family as adversarial tests.

**Limitations:** No new unrestricted exponent-two proof; Hadamard matrices and bent Walsh signs are established mathematics; global priority of the application not assessed; all checks finite and mathematical review outstanding.
