# Centered compressed-effect certificate for T=2 quantum simulation

**NIGHTFALL v0.2 / 2026-11-22. Author-side proof candidate, not Lean-certified, not independently externally refereed, not priority-cleared.**
This is a quantitative strengthening of the trace-sufficient condition in
[TENSOR_TWO_QUERY_LOW_TRACE_20261122.md](TENSOR_TWO_QUERY_LOW_TRACE_20261122.md).
It does **not** solve unrestricted T=2 simulation.

## Target, exact model, and stronger parameter

Let \(s\in\mathbb F_2^d\) be uniform, \(R\) be the distinct available
nonzero parity rows, \(D=R\cup\{0\}\), and
\[
M=\max\left(1,\max_{z\ne0}
  |\{(a,b)\in D^2:a+b=z\}|\right).
\]
Any purified two-query circuit has the form
\[
|\psi_s\rangle=O_s U O_s|\psi\rangle,\qquad
O_s=\sum_{a\in D}\chi_a(s)\Pi_a,\qquad
f(s)=\langle\psi_s,P\psi_s\rangle ,
\]
where \(\sum_a\Pi_a=I\), the \(\Pi_a\)'s are orthogonal projectors,
\(U\) is unitary, \(\|\psi\|=1\), and \(0\preceq P\preceq I\).
A fixed final unitary is absorbed into \(P\). All states are normalized.

Define the *attainable final-state span*
\[
\mathcal S=\operatorname{span}_{\mathbb C}
  \{\psi_s:s\in\mathbb F_2^d\},
\quad Q= \operatorname{Proj}_{\mathcal S},
\]
and the **centered effective trace parameter**
\[
\Theta=\min_{0\le\lambda\le1}
  \|\,Q(P-\lambda I)Q\,\|_1.
\tag{CE}
\]
Here \(\|\cdot\|_1\) is trace norm (sum of singular values), and
\(Q(P-\lambda I)Q\) is viewed as an operator supported on
\(\mathcal S\). The minimum exists.

**Proposed theorem:** A deterministic nonuniform classical estimator
based only on original row parities \(R\) satisfies
\[
\Pr_s(|f(s)-g(s)|>\varepsilon)\le\delta,\quad
0\le g(s)\le1,\quad
Q_{\rm class}\le\min\{|R|,\lceil
  16M\Theta/(\varepsilon^2\delta)\rceil\}.
\tag{CE-T2}
\]
If \(\Theta=0\), the function \(f\) is constant and requires zero
queries. Classical preprocessing and evaluation time are unbounded;
this is a *query complexity* statement. The same theorem holds for
arbitrary finite dimensional workspaces, with an initial purified
state, arbitrary inter-query unitary, and arbitrary binary POVM effect.

In the tensor-subcube source, \(M=2L+2\), so
\[
Q_{\rm class}\le\min\{3^L,\lceil
  32(L+1)\Theta/(\varepsilon^2\delta)\rceil\}.
\]
The unrestricted problem still requires a uniform polynomial
bound on \(\Theta\) or a genuinely different mechanism.

## Proof: absorb signed spectral information into the amplitude

Choose \(\lambda\in[0,1]\) minimizing (CE), and set
\(A=Q(P-\lambda I)Q\). Because \(\psi_s\in\mathcal S\),
\[
f(s)=\lambda+\langle\psi_s,A\psi_s\rangle .
\]
The selfadjoint \(A\) has \(\|A\|_{\rm op}\le1\). Write its
spectral polar decomposition \(A=J|A|\), with
\(J=\operatorname{sgn}(A)\) selfadjoint, commuting with \(|A|\),
and \(\|J\|_{\rm op}\le1\). Define
\[
F(s)=|A|^{1/2}\psi_s,\quad
f(s)=\lambda+\langle F(s),J F(s)\rangle .
\tag{1}
\]
Now \(\|F(s)\|^2\le1\). We may independently Fourier expand
\[
F(s)=\sum_{a,b\in D}\chi_{a+b}(s)c_{ba},\quad
c_{ba}=|A|^{1/2}\Pi_b U\Pi_a\psi .
\tag{2}
\]
Set \(t=\operatorname{Tr}|A|=\Theta\), and
\[
p_a=\|\Pi_a\psi\|^2,\qquad
q_b=\operatorname{Tr}(\Pi_b|A|\Pi_b).
\]
Then \(\sum_a p_a=1\), \(\sum_b q_b=t\).
For arbitrary positive thresholds \(\eta_a,\eta_b\), let
\(H_A=\{a:p_a\ge\eta_a\}\),
\(H_B=\{b:q_b\ge\eta_b\}\),
and \(W=\operatorname{span}_{\mathbb F_2}(H_A\cup H_B)\).
Query all nonzero *original* rows in \(H_A\cup H_B\).
Let \(F_W=\mathbb E[F(S)\mid\chi_w(S),w\in W]\).

As in #1002 v0.1, uniform-character Parseval, retaining all
frequencies in \(W\) (including the potentially huge \(z=0\)
fiber), proves
\[
\begin{aligned}
\mathbb E\|F-F_W\|^2
&=\sum_{z\notin W}\|\sum_{a+b=z}c_{ba}\|^2\\
&\le M\sum_{a+b\notin W}\|c_{ba}\|^2\\
&\le M\Bigl(
   \sum_{a\notin H_A,b}\|c_{ba}\|^2
  +\sum_{b\notin H_B,a}\|c_{ba}\|^2\Bigr).
\end{aligned}
\tag{3}
\]

**First-label light energy.** For nonzero \(p_a\), the normalized
vectors \(\phi_a=\Pi_a\psi/\sqrt{p_a}\) are orthonormal.
Bessel and trace yield
\[
\sum_{a\notin H_A,b}\|c_{ba}\|^2
\le\eta_a\sum_{a,b}
  \||A|^{1/2}\Pi_bU\phi_a\|^2
\le\eta_a\operatorname{Tr}|A|=\eta_a t.
\tag{4}
\]
Terms with \(p_a=0\) vanish. This does *not* assume
orthogonality of two-query path vectors.

**Second-label light energy.**
\(\||A|^{1/2}\Pi_b\|_{\rm op}^2
 =\|\Pi_b|A|\Pi_b\|_{\rm op}
 \le \operatorname{Tr}(\Pi_b|A|\Pi_b)=q_b\).
Therefore
\[
\sum_{b\notin H_B,a}\|c_{ba}\|^2
\le\eta_b\sum_{a,b}\|\Pi_bU\Pi_a\psi\|^2
=\eta_b.
\tag{5}
\]
The last equality uses the projective completeness
\(\sum_b\Pi_b=I\) for each fixed \(a\), followed by
\(\sum_a\|\Pi_a\psi\|^2=1\). Combining (3)-(5):
\[
\boxed{\quad\mathbb E\|F-F_W\|^2
 \le M(t\eta_a+\eta_b).\quad}
\tag{6}
\]

Define the raw predictor
\(g_0(s)=\lambda+\langle F_W(s),J F_W(s)\rangle\).
Because \(\|F_W(s)\|\le
  \mathbb E[\|F(S)\|\mid W]\le1\), and \(\|J\|\le1\),
\[
|f(s)-g_0(s)|
\le (\|F(s)\|+\|F_W(s)\|)\|F-F_W\|
\le2\|F-F_W\|.
\tag{7}
\]
Clamp \(g_0\) to \([0,1]\), which cannot increase error against the
true \(f(s)\in[0,1]\). If \(t>0\), take
\(\eta_a=\varepsilon^2\delta/(8Mt)\) and
\(\eta_b=\varepsilon^2\delta/(8M)\).
Then (6) is at most \(\varepsilon^2\delta/4\).
Markov gives the failure probability, while
\[
|H_A|+|H_B|\le 1/\eta_a+t/\eta_b
 =16Mt/(\varepsilon^2\delta).
\]
If this exceeds \(|R|\), query all rows and evaluate acceptance
exactly from their oracle transcript. For \(t=0\), \(A=0\) and
\(f(s)\equiv\lambda\). This proves the author-side claim.

**Why compressed/centered is strictly stronger.**
The eigenvalues \(\mu_1,\dots,\mu_k\) of \(Q P Q\) restricted
to \(\mathcal S\) belong to \([0,1]\), and
\(\Theta=\min_{\lambda\in[0,1]}\sum_i|\mu_i-\lambda|\).
A median of the \(\mu_i\)'s is optimal. In particular,
\[
\Theta\le\min\{\operatorname{Tr}P,\operatorname{Tr}(I-P)\}.
\]
Unlike the ambient trace, \(\Theta\) is unchanged under an
isometric extension of the reachable states and arbitrary
measurements on a completely *unused* orthogonal workspace.
It is **not claimed to be invariant across inequivalent quantum
implementations of the same acceptance function.**

## Exact high-rank-projector separation (all L)

Let \(N=|D|=3^L+1\) and \(\mathcal H=\mathbb C^N\oplus\mathbb C^N\).
Choose a unit vector \(w=e_0\) in the first block, and its
rank-one projection \(W=ww^*\). Define on the first block
\[
C=\frac9{25}I+\frac7{25}W,\qquad
P=\begin{pmatrix}
 C&\frac{12}{25}I\\[2pt]
 \frac{12}{25}I&I-C
\end{pmatrix}.
\tag{8}
\]
Since \(C\) has eigenvalues \(9/25\) and \(16/25\),
\[
C(I-C)=\frac{144}{625}I,
\quad P^2=P,\quad P^*=P,\quad
\operatorname{Tr}P=\operatorname{Tr}(I-P)=N.
\]
Thus \(P\) is an honest **rank-N accepting projector**.

Use the first two query-frequency sectors \(a=0,1\), start in
\(\psi=(3e_0+4e_1)/5\oplus0\), and let the inter-query unitary
rotate \(e_0,e_1\) by \(c=3/5,s=4/5\) inside the first block,
acting as identity elsewhere. The phase oracle acts on that
block with labels \(D\), and on the idle second block with
the identity (zero-frequency sector). The final states,
for the parity \(\chi_1(s)=\pm1\), are exactly
\[
\psi_+=(-7e_0+24e_1)/25\oplus0,\quad
\psi_-=e_0\oplus0.
\]
Their span is \(\operatorname{span}(e_0,e_1)\) in the first block.
Hence the two eigenvalues of the **compressed effect** are
\(16/25,9/25\), and
\[
\boxed{\Theta=\frac7{25}},\qquad
\min\{\operatorname{Tr}P,\operatorname{Tr}(I-P)\}
=N=3^L+1.
\]
The gain in this sufficient bound is the exact factor
\(25(3^L+1)/7\), which grows exponentially in L. The acceptance
is nonconstant:
\[
f(\chi_1=+1)=5968/15625,\qquad f(\chi_1=-1)=16/25.
\]
This example is **not a hardness separation**: one classical
original-row query determines the acceptance function. It is an
exact, useful *certificate-efficiency separation* demonstrating
that high projective rank alone does not require a large simulator.

The central choice \(\lambda=1/2\) yields an indefinite signed
compressed effect with eigenvalues \(\pm7/50\), and realizes
the same optimal \(\Theta=7/25\). This checks that the
signed-amplitude extension is not limited to PSD shifts.

## Independent adversarial gates

1. Re-derive the spectral compression identity and confirm
   \(QPQ\) cannot be replaced by P on idle ancillas.
2. For indefinite A, audit the \(\operatorname{sgn}(A)\)
   bilinear predictor, clamping, and absolute-difference estimate.
3. Verify Bessel/trace and second-label bounds for genuinely
   complex workspaces and arbitrary-dimensional projectors;
   check no false T=1 orthogonality is used.
4. Prove the rank-N block construction (8) exactly for arbitrary N;
   replay its spectrum, traces, two final states and acceptance
   in a separately implemented rational checker.
5. Search prior art on effective trace/compressed measurement
   simulatability, low-rank perturbations of scalar POVMs, and
   repeated-correlated quantum parity queries. A generic trace
   ideal inequality is *not* automatically new mathematics.
6. Lean kernel integration is a distinct future gate. Source-hashed
   finite CI only verifies the stated examples and algebra.

**Status:** paper proof candidate plus independent exact finite tests;
not a certified unrestricted two-query theorem, and not historically
novel until specialist priority review.


## v0.3 extension — soft spectral-tail certificate (quantitative operator transfer)

**Additional author-side corollary, not independently reviewed or Lean certified.**

The compressed-effect trace can still be large when many individually
tiny eigenvalue deviations accumulate. A controlled spectral
approximation gives a stricter *error-budget-aware* condition.

Let \(\mu_i\) be the eigenvalues of \(QPQ\) restricted to the
attainable final-state span \(\mathcal S\). For
\(0\le\kappa<\varepsilon\), define the soft spectral-tail charge

\[
\Theta_\kappa=
 \min_{\lambda\in[0,1]}\sum_i
     (|\mu_i-\lambda|-\kappa)_+ ,
\qquad (x)_+=\max(x,0).
\tag{ST}
\]

**Provisional corollary:** Under the same T=2 hypotheses, there is a
deterministic nonuniform original-row simulator satisfying
\[
\boxed{
Q_{\rm class}\le \min\{|R|,
 \lceil 16 M\Theta_\kappa/
       ((\varepsilon-\kappa)^2\delta)\rceil\},\quad
\Pr(|f-g|>\varepsilon)\le\delta .
}
\tag{ST-T2}
\]
It may optimize over \(\kappa\in[0,\varepsilon)\). The v0.2
certificate is the special case \(\kappa=0\).

**Proof.** Choose \(\lambda\) attaining (ST) and write
\(A=Q(P-\lambda I)Q\). Spectrally soft-threshold it:
\[
B=\operatorname{sgn}(A)(|A|-\kappa Q)_+ .
\]
Then \(B=B^*\), \(\|B\|_{\rm op}\le1\),
\(\operatorname{Tr}|B|=\Theta_\kappa\), and
\(\|A-B\|_{\rm op}\le\kappa\).
Therefore
\[
|f(s)-\{\lambda+\langle\psi_s,B\psi_s\rangle\}|
 \le\kappa\quad\text{for every }s.
\]
Apply the entire v0.2 conditional-amplitude/trace argument to
the selfadjoint \(B\), whose polar sign remains a contraction, with
target accuracy \(\varepsilon-\kappa\) and failure probability \(\delta\).
The simulated signed quadratic predictor need not itself be in
\([0,1]\) before clamping. Clamp its output; because the true
\(f(s)\in[0,1]\), clamping cannot increase error.
The resulting total error is at most \(\kappa+\varepsilon-\kappa
=\varepsilon\) outside the bad event. Query count follows.
If \(\Theta_\kappa=0\), the constant output \(\lambda\)
approximates f uniformly within \(\kappa\), using zero queries.

This is NOT a free truncation: the deterministic uniform error
\(\kappa\) is paid from \(\varepsilon\), and the remaining classical
simulation is charged at accuracy \(\varepsilon-\kappa\).

### Exact finite full-span example

In the L=2 tensor oracle there are 10 frequency sectors and 16
possible hidden secrets. Take an initial dense rational normalized
state from a Householder transform with all-ones vector, and an
inter-query rational Householder unitary using vector
\((1,2,\ldots,10)\). The resulting 16 final states span all
10 dimensions (independently checked by exact-rational elimination).
Let the terminal effect be diagonal with eigenvalues
\[
\underbrace{9/20,\ldots,9/20}_{5},\quad
\underbrace{11/20,\ldots,11/20}_{4},\quad
9/10 .
\]
The exact centered trace is \(\Theta_0=17/20\).
Choose \(\kappa=1/10\) and \(\lambda=11/20\).
All nine bulk directions shrink to zero, leaving
\(B=\tfrac14|e_9\rangle\langle e_9|\),
with \(\Theta_\kappa=1/4\), while
\(\|Q(P-\lambda I)Q-B\|_{\rm op}=1/10\).
At accuracy \(\varepsilon=1/2\), the *uncapped*
new query coefficient is better by exactly
\[
\frac{\Theta_0/\varepsilon^2}
     {\Theta_\kappa/(\varepsilon-\kappa)^2}
=\frac{272}{125}=2.176.
\]
The worst-case bound in this small ten-row example is still capped
by querying all original rows, so the improvement is a **certificate
coefficient**, not an observed reduction of the realized finite
tree depth. The distributional acceptance is nonconstant on the
16 secrets. The exact Walsh/Parseval checker finds a positive
soft-amplitude conditional MSE of \(48/5929\).

Replay: check_t2_soft_spectrum_exact.py. It independently verifies
full span, the rational oracle/inter-query circuit, spectra,
uniform residual error \(\kappa\), soft effect rank, exact
Fourier coefficients and conditional-amplitude MSE.
This finite test is *not* independent proof of the all-circuit
spectral-tail theorem, not a Lean certificate, and not a
historical novelty determination.

**Research transfer:** the next high-rank test should examine
whether the spectrum of the reachable-state compressed effect has
a polynomially bounded soft tail at meaningful \(\kappa\), rather
than asking only for a small accepting-projector rank.
No such universal upper bound is established here.


### Exact minimizer check for the full-span example

The centered absolute-trace objective has its minimum at any
median eigenvalue. Here the 5th and 6th eigenvalues are \(9/20\)
and \(11/20\), giving \(\Theta_0=17/20\).

For the soft-tail objective, the exact minimizer \(\lambda=11/20\)
is also globally valid, not just a trial point. If
\(\lambda\le11/20\), the \(9/10\) outlier alone costs at least
\(9/10-1/10-11/20=1/4\). If
\(11/20\le\lambda\le4/5\), the five \(9/20\) eigenvalues
and the outlier cost at least
\(5(\lambda-11/20)+(4/5-\lambda)
 =4\lambda-39/20\ge1/4\).
If \(\lambda\ge4/5\), the five lower eigenvalues cost at least
\(5(4/5-11/20)=5/4\).
Thus \(\Theta_{1/10}=1/4\) exactly.
The checker separately minimizes the convex piecewise-linear
objectives over all exact rational breakpoints, not just the
chosen center.


## Adversarial exact check with multidimensional oracle sectors

A separate independent rational checker,
check_t2_multidim_indefinite_exact.py, uses the L=2 tensor source
but assigns a **two-dimensional Hilbert projector to each of the
ten frequency labels**. The 20-dimensional circuit has a dense
rational initial state, two genuine oracle applications separated
by a nontrivial rational Householder unitary, and a full-rank
positive effect
\[
P=\frac12 I+\frac14 uu^*-\frac1{16}vv^*,\quad
\langle u,v\rangle=0,\ \|u\|=\|v\|=1.
\]
Its centered signed effect is indefinite, with
\(\operatorname{Tr}|P-\tfrac12I|=5/16\).
The test independently constructs every path amplitude and
compares against all 16 direct circuit states, reconstructs its
Walsh spectrum, explicitly averages over groups with identical
queried original parities, and verifies all three operator-energy
inequalities with **three nonzero original queried rows**.

The exact nonzero discarded amplitude energy and strict bound are
\[
\mathbb E\|F-F_W\|^2
=\frac{6035410741}{585003171025000}>0,\qquad
M(t\eta_a+\eta_b)=\frac{1887}{20000}<1.
\]
It also verifies the signed quadratic acceptance-prediction
Lipschitz bound on every secret, not merely a phase-vector norm.
This targets a genuine risk in one-dimensional-only test cases:
there is no assumption that two-query path states
from different first-query labels are orthogonal.

The check is exact finite arithmetic, **not** a proof of the
all-circuit claim or a Lean kernel theorem.
