# NIGHTFALL / Mira — independent fair-bit matching clock (v2.5)

**Claim status:** author-side *conditional proof reconstruction* of the \(\widetilde O(s^{21})\) perfect-matching backend, **not Lean-certified or externally reviewed**. The proof uses two explicitly verified external inputs: (1) the mixing/congestion bound in [Jerrum–Sinclair–Vigoda, Lemmas 4.1 and 4.4](https://www.math.cmu.edu/~af1p/Teaching/Markov_Chain_Mixing/Papers/permanent.pdf), and (2) the finite-table approximate-to-exact correction framework of [Göbel–Liu–Manurangsi–Pappik, Section 6 and Theorem 2](https://arxiv.org/html/2410.00882v2). These authors receive attribution. The exponent 21 is *not* directly stated as bit complexity in GLMP; the rational/dyadic adaptation is the subject of this proof.

Original Mira source: [pinned commit 30ddaaad27b48df2002225c3e3f40cffd02c5253](https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling), \`paper/complexity-v2.tex\`. This note independently traces the exponent and identifies the unit-cost versus bit-cost bridge. No claim about the full Latin sampler follows without the other gates.

## Statement

For each \(s\ge1\) and feasible \(s\times s\) 0–1 bipartite adjacency matrix, there is an algorithm using independent fair bits which outputs exactly a uniform perfect matching, terminates almost surely, and has expected **total Turing bit work** \(\widetilde O(s^{21})\). The expectation includes rational arithmetic, calibration, all rejected attempts and the rare exact correction branch. Constants do not depend on the board. Assume the cited JSV inverse-gap estimate holds for every factor-two approximate near-perfect hole-weight vector; GLMP's finite-state correction principle is used with explicit dyadic implementation below.

## Proof reconstruction

**(1) Rational gradual cooling and polynomial starting state.** Find any real perfect matching \(x_0\) by augmenting paths. Fill every absent edge with a *fake* edge, initially weight one; all real edges have weight one. For each left vertex in turn, reduce its incident fake-edge weights by a rational factor \(3/4\) until reaching exactly \(1/s!\). A last phase may use a rational ratio in \([3/4,1]\). There are \(R=O(s^2\log(2s))\) phases because each vertex needs \(O(s\log(2s))\) reductions. All edge weights are rational with \(O(s^2\log(2s))\) bits.

**(2) Hole calibration.** At a phase, let \(M\) be the total weighted perfect-matching mass and \(N_{uv}\) the unweighted near-perfect mass with holes \(u,v\), using the current edge weights. The *ideal* hole factor is \(w^*_{uv}=M/N_{uv}\). Under a factor-two approximation of every hole factor, JSV's canonical-path bound gives absolute inverse spectral gap \(O(s^6)\); all \(s^2+1\) perfect/near-perfect classes have stationary probability \(\Omega(s^{-2})\). More explicitly, the published congestion bounds \(48s^4\) and \(2+4(r+r^{-1})\), with \(r\in[s^2/2,2s^2]\), yield a conservative \(O(s^6)\) bound. For a good weight vector, the deterministic initial matching has stationary probability at least \(1/[(1+2s^2)s!]\), so mixing from it to a constant relative class-probability accuracy takes \(T_0=O(s^6s\log(2s))=\widetilde O(s^7)\) steps.

At each phase take \(S=O(s^2(u+\log(2s)))\) *independent* length-\(T_0\) chain endpoints, and update each hole factor by its previous value times the observed perfect/near class-frequency ratio. Since each class has mass \(\Omega(s^{-2})\), binomial Chernoff plus a union bound over \(R(s^2+1)\) classes makes the event that any empirical ratio differs from its true value by more than \(6/5\) have probability \(\le 2^{-20u}\), for an appropriate sufficiently large absolute sample multiplier. The exact stationary class ratio is \(M/(w_{uv}N_{uv})\), so the idealized update **resets**, rather than compounds, the previous error: \(w_{uv}\cdot \pi(\mathrm{perfect})/\pi(\mathrm{hole}_{uv})=w^*_{uv}\).

Cooling one vertex by a multiplier in \([3/4,1]\) scales every perfect or near-perfect matching weight by a number in this same interval; hence the ideal hole ratio shifts by at most a factor \(4/3\). The empirical \(6/5\) factor and \(4/3\) yield \(8/5<2\), closing the factor-two induction. On good calibration, the inverse gap stays \(O(s^6)\) in every phase. Failure probability \(\le2^{-20u}\) includes all earlier phases.

**(3) A uniformly likely real perfect endpoint.** After cooling, every fake perfect matching weighs at most \(1/s!\), while there are at most \(s!\) fake-containing matchings, so their total perfect-matching weight is at most one. Since the input has a real perfect matching, the real perfect mass is at least one. With good near-perfect weights, the stationary probability of being in the perfect class is \(\Omega(s^{-2})\); hence the probability of a *real* perfect endpoint is \(\Omega(s^{-2})\). Conditional on this event under the ideal stationary measure, all real perfect matchings are equiprobable because their edge-product weights equal one.

A final chain of \(T_1=O(s^6(s\log(2s)+u))\) steps is within \(2^{-20u}\) of stationarity on good weights. Repeat *whole independently calibrated attempts*, but cap their number at \(J=O(s^2u)\), returning \(x_0\) on cap exhaustion. Adjusting absolute constants, the conditional law \(Q_{\rm raw}\) of this capped sampler has total-variation distance at most \(2^{-10u}\) from the target uniform law, including the calibration failure event and cap exhaustion. The expected number of whole attempts is \(O(s^2)\); this bound is not multiplied by \(J\).

**(4) Dyadic transitions and exact finite-output law.** Every transition selects among \(O(s)\) options and uses at most a bounded number of Metropolis ratios of rational edge/hole weights. A hole weight is a product of \(O(R)\) frequency ratios involving integers at most \(S\), so the relevant per-transition numerator and denominator have \(B=O(R\log(S+1)+s\log(2s))=\widetilde O(s^2)\) bits. Fix \(b=64u+O(\log(2+J(RST_0+T_1)s))\); replace every categorical and acceptance probability by its precisely specified \(b\)-bit dyadic lower rounding, including all random branches. A coupling over the deterministic capped horizon costs at most \(2^{-60u}\) in total variation with a suitable additive \(O(\log s)\) margin in \(b\).

The rounded branch probabilities need not be calculated to \(b\) digits at every actual step. To simulate a \(b\)-bit rounded rational coin, compare fair random bits with the rational's successive binary digits (computable by doubling and subtracting a \(B\)-bit remainder), stopping at the first difference or after \(b\) digits. The expected number of examined bits is at most two; the expected bit cost per local rational test is \(\widetilde O(B)\), certainly \(\widetilde O(s^4)\). Categorical choices among \(O(s)\) options can use rational prefix comparisons or approximately uniform bins, also within this bound. **This is why the huge \(b\)-bit precision does not add \(s^4\) work to every transition.**

The fully capped rounded sampler has an **exact dyadic** finite-output law \(Q\), with \(\|Q-\pi\|_{\rm TV}\le 2^{-8u}\) after adjusting constants. A common denominator \(2^{bL}\) exists where \(L\) is a deterministic polynomial upper bound on all random substeps across the capped horizon. Hence all probabilities have polynomial-size exact integer representations, not least common multiples of unrelated rational denominators.

**(5) Rare exact correction.** Let \(\delta=2^{-u}\). For the target uniform law \(\pi\) on valid perfect matchings, each atom satisfies \(\pi(x)\ge1/s!\). Since \(7u>\log_2(s!)\), the TV guarantee ensures
\[
\pi(x)-(1-\delta)Q(x)\ge\delta/s!-2^{-8u}\ge0.
\]
Thus \(\nu(x)=[\pi(x)-(1-\delta)Q(x)]/\delta\) is a probability distribution and the mixture \((1-\delta)Q+\delta\nu\) is **exactly \(\pi\)**. Sample a \(\delta\)-coin by fair bits. On the rare branch compute \(\nu\) using a finite exact table and an ordinary cumulative rational draw.

To bound this slow branch, note that each of \(s^2\) hole weights is a product of \(R\) ratios of counts \(\le S\), so the number of possible weight vectors is at most \((S+1)^{2Rs^2}=\exp(O(s^4\log^2(2s)))\). For a fixed vector, the full Markov-state space has at most \((1+s^2)s!\) configurations. Compute finite chain-end distributions by exact dynamic programming and enumerate at most \((S+1)^{s^2+1}\) class histograms per phase. Repeat this over phases, then combine the exact capped-attempt laws; all integers have polynomially bounded bit length by the common dyadic denominator. The entire exact distribution and correction draw cost at most \(\exp(C_0s^4\log^2(2s))\) bit operations for some absolute \(C_0\) **independent of the large accuracy constant below**. Dependence on that accuracy constant enters only the lower-order \(\log S=\log(\mathrm{poly}(s)\,C)\) term.

Choose \(u=C(s+2)^4\log_2^2(s+2)\) with fixed \(C\) large enough that \(\delta\exp(C_0s^4\log^2(2s))=O(1)\) for large \(s\). Finitely many small \(s\) can be sampled by exact enumeration. Thus the slow branch has bounded expected bit work.

**(6) Exponent audit.** With the displayed \(u=\widetilde O(s^4)\), each attempt makes
\[
R\,S\,T_0+T_1
=\widetilde O(s^2\cdot s^{2+4}\cdot s^7+s^{6+4})
=\widetilde O(s^{15})
\]
Markov transitions. The \(O(s^2)\) mean number of attempts and the \(\widetilde O(s^4)\) expected bit work per transition give
\[
\boxed{\mathbb E\operatorname{BitWork}
=\widetilde O(s^{15+2+4})=\widetilde O(s^{21}).}
\]
The added exact correction has expected \(O(1)\) cost and restores *exact* uniformity. This completes the author-side matching-clock derivation, **conditional on the verified external JSV/GLMP chain results**. \(\square\)

## Independent attack, status and limits

1. The published GLMP Theorem 2 states an \(O(s^{15}\log^4s)\) **unit-cost** bound, not this explicitly conservative *fair-bit* \(s^{21}\) result. The latter is an independently reconstructed interface, not a direct restatement of GLMP.
2. The correction uses **dyadic** rounded transitions; without a common denominator, enumerating exponentially many rational path probabilities need not have a manageable bit length. The dyadic device is essential, not cosmetic.
3. The entire capped-horizon law must be computed *exactly* on the rare branch. Computation of a mere approximate law followed by renormalization would not satisfy the theorem.
4. The rarity exponent \(u=C s^4\log^2s\) must dominate the exact table's exponent without circular dependence on \(C\). The asymptotic expression \(\log S=O(\log s)+O(\log C)\) ensures this for fixed \(C\).
5. **Still unproved for the full Latin sampler:** a verified \(\widetilde O(n^4)\) matching-probe factorization for every actual decorated soft gate, the uniform all-target mean-log cover bound, and the middle/dense total-variation budgets. This note does not establish Mira's \(\widetilde O(n^{25})\) result.

**No Lean claim, human independent review, or novelty claim.**
