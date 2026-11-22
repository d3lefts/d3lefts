# Two-query simulation with a low-trace terminal effect
NIGHTFALL research note v0.1, 2026-11-22.
**Status: author-side mathematical proof candidate plus exact finite replay.
Not independently reviewed, not Lean certified, novelty not established.**

## Theorem candidate

Let s be uniform on F_2^d, and let R be a set of distinct, nonzero binary
oracle rows. Write D=R∪{0} and let
\[
M=\max\left(1,\max_{z\ne0}|\{(a,b)\in D^2:a+b=z\}|\right).
\]
Every purified two-query binary-oracle circuit has the phase-form
\[
O_s=\sum_{a\in D}\chi_a(s)\Pi_a,\quad
|\Psi_s\rangle=O_s U O_s|\psi\rangle,\quad
f(s)=\langle\Psi_s,P\Psi_s\rangle,
\]
where the projectors Π_a are mutually orthogonal and sum to I,
||ψ||=1, U is unitary and 0≤P≤I is the terminal effect. Any final fixed
unitary is absorbed into P; repeated oracle frequencies are grouped.
No orthogonality across two-query path vectors is assumed.

Let t=Tr(P) in this circuit representation. If t>0, then for all
0<ε,δ<1 there exists a deterministic nonuniform classical tree that
uses ONLY original row queries and returns g(s)∈[0,1] such that
\[
\Pr_{s}[|f(s)-g(s)|>\varepsilon]\le\delta,\qquad
Q_{\rm class}\le\min\{|R|,\lceil16Mt/(\varepsilon^2\delta)\rceil\}.
\tag{T2-low-trace}
\]
For t=0, f is constant zero. Apply the theorem to I−P and subtract
from one to replace t by t_*=min(Tr P,Tr(I−P)); t_*=0 means constant
acceptance. Trace is representation-dependent, potentially inflated by
unused workspace, and is a sufficient condition—not a universal
two-query simulation theorem.

For tensor-subcube rows, the paper-level all-depth pair-fiber
classification M=2L+2 from #960/#962 gives
\[
Q_{\rm class}\le\min\{3^L,
  \lceil32t_*(L+1)/(\varepsilon^2\delta)\rceil\}.
\]
Thus every two-query circuit whose accepting terminal projector has
rank 1 (and every rank-k terminal projector with k=poly(L)) has a
polynomial-in-L distributional classical simulator. This controls its
ENTIRE acceptance function, including cross-stage coherent interference.
The unrestricted high-rank case remains open.

## Proof: conditional expectation of the amplitude, not acceptance

Define Hilbert-valued amplitude
\[
F(s)=P^{1/2}O_sUO_s\psi
=\sum_{a,b\in D}\chi_{a+b}(s)c_{ba},\quad
c_{ba}=P^{1/2}\Pi_bU\Pi_a\psi .
\]
Then f(s)=||F(s)||² and ||F(s)||≤1. Put
\[
p_a=||\Pi_a\psi||^2,\quad q_b={\rm Tr}(\Pi_b P),
\quad \sum_a p_a=1,\quad \sum_b q_b=t.
\]
Fix positive thresholds η_a,η_b and heavy index sets
A={a:p_a≥η_a}, B={b:q_b≥η_b}.
Let W=span_F2(A∪B). Query the actual original rows in A∪B
(ignoring virtual zero). The queried parity characters determine
their sigma-algebra G, and the simulator computes
\[
F_W(s)=\mathbb E[F(S)\mid G](s),\qquad g(s)=||F_W(s)||^2.
\]
Nonuniform unbounded offline computation is allowed. Jensen gives
||F_W(s)||≤1, hence 0≤g(s)≤1.

The Walsh characters of uniform s are orthogonal; conditioning on
parities from W retains exactly the frequencies z∈W. Parseval and
Cauchy–Schwarz give
\[
\mathbb E||F-F_W||^2 =
\sum_{z\notin W}||\sum_{a+b=z}c_{ba}||^2
\le M\sum_{a+b\notin W}||c_{ba}||^2.
\tag{1}
\]
**The huge zero-XOR fiber is not bounded:** 0 belongs to W, so
all frequencies in (1) are nonzero. Moreover, if a∈A and b∈B,
then a+b∈W; any term on the right of (1) has a light first
or second label.

For p_a>0 let φ_a=Π_aψ/sqrt(p_a). These vectors are orthonormal.
By Bessel's inequality and summing over the second-label projectors,
\[
\begin{aligned}
\sum_{a\notin A,b}||c_{ba}||^2
&\le\eta_a\sum_{a,b}||P^{1/2}\Pi_bU\phi_a||^2\\
&\le\eta_a\sum_b{\rm Tr}(\Pi_bP\Pi_b)=\eta_a t.
\end{aligned}
\tag{2}
\]
On the other hand, positivity and trace give
||P^{1/2}Π_b||op² = ||Π_bPΠ_b||op ≤ Tr(Π_bPΠ_b)=q_b.
Consequently
\[
\begin{aligned}
\sum_{b\notin B,a}||c_{ba}||^2
&\le\eta_b\sum_{a,b}||\Pi_bU\Pi_a\psi||^2\\
&=\eta_b .
\end{aligned}
\tag{3}
\]
The last sum is 1 by unitarity and orthogonality of Π_b for
each fixed a; no false pair-path orthogonality is used.

Combining gives the **inspectable general certificate**
\[
\boxed{\mathbb E||F-F_W||^2\le M(t\eta_a+\eta_b).}
\tag{4}
\]
Since both vector norms are at most one,
|f−g|≤2||F−F_W||. Choose
η_a=ε²δ/(8Mt), η_b=ε²δ/(8M).
Then the RHS of (4) is ε²δ/4, so Chebyshev/Markov gives the
failure probability δ. Counts satisfy
|A|≤1/η_a and |B|≤t/η_b, giving at most
16Mt/(ε²δ) original row queries. Querying all rows gives
exact acceptance as a fallback. This completes the author-side proof.

## Reproduction, criticism, and provenance

The independent rational script check_tensor_t2_low_trace.py checks
tensor levels 1–2, rank-one and rank-two terminal projections with
nontrivial rational-orthogonal inter-query mixing: direct amplitudes,
Fourier coefficients, parity-conditioned amplitude averages,
vector Parseval, (1) and (4), and bounded prediction. The L=2
tests have genuinely nonzero discarded amplitude energy.
The checker also includes an exact L=3 rank-one, 25-sector dilute example with a cyclically mixing inter-query permutation: its conditional amplitude tail has genuine nonzero mean-squared norm 24/625 and the certified generic bound is 4/5 < 1, with zero heavy queried rows. The 64-path zero-fiber negative control demonstrates why the zero character must be retained. These are finite checks only.

**Independent audit tasks:**
1. Re-derive (2) using finite-dimensional trace/Bessel without assuming
   orthogonality of v_{ba} for different a; explicitly challenge the
   arbitrary-dimensional projector case.
2. Re-derive (3), including q_b=0 and zero-workspace components.
3. Check the character conditioning identity for dependent queried
   rows, and the indispensability of preserving z=0.
4. Test nonprojective general effects, rank>2, complex workspace,
   duplicated row labels and the fully general two-query circuit form.
5. Check same-model historical priority, especially
   Escudero Gutiérrez–Saucedo–Palazuelos arXiv:2609.05201, the
   completely bounded polynomial literature, and quantum
   measurement-rank results. Kernel formalization is still open.

The source literature supplies generic quantum polynomial and
trace inequalities; this is NOT yet a historical novelty claim.
The merged #996 same-stage dephasing isolates a coherent remainder
without a general bound; this theorem instead controls the FULL
acceptance for low-trace terminal effects. Open #980 supplies a
different tensor secant bound and does not imply the present result.
Do not conflate with all-circuit, high-rank T=2 simulation.

**Stop condition:** A valid counterexample to (4), the false use
of M on zero frequencies, or a documented earlier identical theorem
requires an immediate correction. Promotion needs non-author
review and ideally Lean kernel checking. No external publication
without human authorization.


## Exact counterexample to a zero-fiber shortcut

The condition \(z\notin W\) in the Parseval step is essential.
Take a Hilbert basis indexed by all \(a\in D\), let the oracle act
diagonally, let \(U=I\), let
\(\psi=|D|^{-1/2}\sum_{a\in D}|a\rangle\),
and set \(P=|\psi\rangle\langle\psi|\) (rank one).
Then \(O_s U O_s\psi=\psi\), so \(f(s)=1\) identically. Its
acceptance amplitude is
\[
\langle\psi,O_s^2\psi\rangle
=\frac1{|D|}\sum_{a\in D}\chi_{a+a}(s)=1.
\]
All \(|D|\) contributions lie in the **zero** XOR fiber. For the
tensor family \(|D|=3^L+1\) whereas the nonzero fiber bound is only
\(M=2L+2\). Naively bounding all frequency fibers by \(M\), or
discarding the light diagonal paths, would be incorrect. The actual
simulator retains this entire constant amplitude automatically because
\(0\in W\), and correctly predicts \(f\equiv1\) with zero queries.
This is a symbolic negative control, not an extra theorem about T=2.
