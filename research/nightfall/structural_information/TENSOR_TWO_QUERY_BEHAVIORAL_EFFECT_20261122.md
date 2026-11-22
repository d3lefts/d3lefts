# Task-aware measurement-effect compression for T=2 parity simulation

**NIGHTFALL v0.4, 2026-11-22. Provisional general theorem/corollary,
author-side derivation and finite exact witness only. Not Lean certified,
not independent non-author reviewed, and not prior-art cleared.**
This strengthens the centered compressed-effect T2 bound documented in
[TENSOR_TWO_QUERY_COMPRESSED_EFFECT_20261122.md](TENSOR_TWO_QUERY_COMPRESSED_EFFECT_20261122.md).
It does not prove unrestricted two-query classical simulation.

## Objective: pay only for the task-visible part of the measurement

Let \(\psi_s=O_s U O_s\psi\) be the final state of a fixed
two-query quantum circuit on the uniform secret \(s\).
Let \(\mathcal S=\operatorname{span}_{\mathbb C}\{\psi_s\}\);
all matrix variables below act **on \(\mathcal S\)**, so idle
workspace and unrelated accepting subspaces are already discarded.
Let \(f(s)\in[0,1]\) be its actual acceptance probability.

A terminal effect \(E\) on \(\mathcal S\) is *behaviorally equivalent*
for this task if
\[
0\preceq E\preceq I_{\mathcal S},\quad
\langle\psi_s,E\psi_s\rangle=f(s)
\qquad\text{for every hidden secret }s.
\]
This is a **finite set of explicit linear constraints** in the
entries of \(E\), not a predicate that encodes classical tree depth.
The original terminal effect compressed onto \(\mathcal S\) is
feasible, so the set is nonempty.

Define the **task-visible centered trace**
\[
\boxed{
\Theta_{\mathrm{task}}
=\min_{\substack{E=E^*,\ 0\preceq E\preceq I_{\mathcal S}\\
     \langle\psi_s,E\psi_s\rangle=f(s)\ \forall s\\
     0\le\lambda\le1}}
  \|E-\lambda I_{\mathcal S}\|_1.
}
\tag{TC}
\]
This is invariant under isometries of \(\mathcal S\) and under any
change of the terminal effect that preserves every acceptance
probability on the particular reachable state family. It is **not**
claimed invariant under changing the circuit's *state family*
while preserving the same scalar acceptance function.

## Provisional theorem: task-aware T2 upper bound

Let \(R\) be the original set of available nonzero parity rows,
and \(M=\max(1,\max_{z\ne0}|\{(a,b)\in(R\cup\{0\})^2:
 a+b=z\}|)\) the ordered nonzero XOR fiber count.

For every \(\varepsilon,\delta\in(0,1)\), there exists a
deterministic nonuniform classical simulator querying only rows
in \(R\) and producing \(g(s)\in[0,1]\) with
\[
\boxed{
Q_{\rm class}\le\min\{|R|,
\lceil16M\Theta_{\mathrm{task}}/(\varepsilon^2\delta)\rceil\},
\qquad
\Pr_s(|f(s)-g(s)|>\varepsilon)\le\delta.
}
\tag{TC-T2}
\]
If \(\Theta_{\mathrm{task}}=0\), then \(f\) is constant and
zero queries suffice. For tensor-subcube \(R_L\), substitute
\(M=2L+2\), giving at most
\(\lceil32(L+1)\Theta_{\rm task}/(\varepsilon^2\delta)\rceil\)
original row queries, capped by \(3^L\).

**Proof.** Choose an optimal feasible \(E,\lambda\).
Extend \(E\) to a valid effect on the full circuit workspace,
for instance as \(E\oplus\lambda I\) on
\(\mathcal S\oplus\mathcal S^\perp\).
All reachable \(\psi_s\) lie in \(\mathcal S\), hence the new
terminal effect produces **exactly the same** \(f(s)\).
Its centered compression is \(E-\lambda I_{\mathcal S}\),
with trace norm \(\Theta_{\mathrm{task}}\).
The v0.2 signed-amplitude truncation theorem applies to this
equivalent effect. Its proof does not require a physically executed
replacement circuit; it needs only a mathematical representation
of the same acceptance function. This proves (TC-T2),
conditional on independent acceptance of the v0.2 theorem.

### Explicit finite-dimensional SDP

For Hermitian matrices \(E,X_+,X_-\) on \(\mathcal S\) and
real \(0\le\lambda\le1\), minimize
\[
\operatorname{Tr}(X_++X_-)
\]
subject to
\[
0\preceq E\preceq I,\quad
X_\pm\succeq0,\quad
E-\lambda I=X_+-X_-,\quad
\langle\psi_s,E\psi_s\rangle=f(s)\quad(\forall s).
\]
The standard positive/negative trace decomposition gives
exactly (TC); this is a convex semidefinite optimization.
**No efficiency claim:** the secret set and SDP may have
exponential size; the original one-query and two-query simulator
statements allow unrestricted nonuniform offline processing.
Every actual classical oracle query is still counted.

### Information-theoretic annihilator

The nullspace of task-visible quadratic evaluations is
\[
\mathcal N_{\mathcal S}=
\{H=H^*:
\langle\psi_s,H\psi_s\rangle=0\ \forall s\}.
\]
Changing \(E\mapsto E+H\) with \(H\in\mathcal N_{\mathcal S}\)
and respecting \(0\preceq E+H\preceq I\) changes neither
acceptance values nor the task. Such changes can dramatically
reduce the centered trace, as in the exact witness below.
This is a concrete quotient of operators by task-invisible
directions, **not** a general characterization of classical
query complexity.

## Exact strict separation in a full-span, nonconstant T2 circuit

Use L=2 tensor rows: 10 phase frequency sectors, 16 hidden secrets,
and a rational Householder initial state and inter-query unitary
as defined in check_t2_behavioral_effect_exact.py.
The exact 16 final real vectors span the **entire**
complex 10-dimensional Hilbert space (rational row-reduction
rank 10); this is NOT idle-ancilla compression.

Let \(K\) be the block diagonal real skew-symmetric matrix with
five \(2\times2\) blocks \(\begin{psmallmatrix}0&-1\\1&0\end{psmallmatrix}\).
Then \(iK\) is Hermitian with eigenvalues \(+1,-1\), each
of multiplicity five. Define two **valid terminal effects**
\[
P=\tfrac12 I+\tfrac14 iK+\tfrac18 e_0e_0^*,
\qquad
E=\tfrac12 I+\tfrac18 e_0e_0^*.
\tag{X}
\]
Both lie between 0 and I: for P,
\(\|P-\tfrac12I\|_{\rm op}\le\tfrac14+\tfrac18
=\tfrac38<\tfrac12\), and E is diagonal with
eigenvalues \(1/2,5/8\).

Every reachable state \(\psi_s\) is real. Because
\(K^\top=-K\), its invisible part obeys
\(\langle\psi_s,iK\psi_s\rangle=i\psi_s^\top K\psi_s=0\).
Consequently P and E have **identical, nonconstant**
acceptance probability
\[
f(s)=\tfrac12+\tfrac18|\langle e_0,\psi_s\rangle|^2
\]
for each of the 16 secrets. This has 11 distinct exact rational
acceptance values.

Yet their centered-trace certificates differ sharply.
For any scalar \(\lambda\), the operator
\((\tfrac12-\lambda)I+\tfrac14iK\) has trace norm at
least \(10/4=5/2\) (five equal \(+,-\) pairs).
Using the reverse triangle inequality for the extra
rank-one perturbation,
\[
\Theta(P)=\min_{\lambda\in[0,1]}
 \|P-\lambda I\|_1
\ge \frac52-\frac18=\frac{19}{8}.
\]
The behaviorally equivalent E has centered trace norm
at most \(1/8\), with \(\lambda=1/2\).
Therefore
\[
\boxed{\Theta_{\rm task}\le\tfrac18,\qquad
\Theta(P)\ge\tfrac{19}{8},\qquad
\Theta(P)/\Theta_{\rm task}\ge19.}
\]
The ratios compare **uncapped sufficient-query certificates**,
not measured classical query complexity. This witness is not an
unconditional separation between quantum and classical algorithms.

The exact checker confirms the real two-query state family has
full span, verifies \(K^\top=-K\), \(K^2=-I\), the Hermitian
operator-norm feasibility argument, equality of acceptance for
all 16 secrets, the explicit SDP feasible witness, and the
factor-19 inequality using rational arithmetic. The strict
separation occurs in the **observable effect representation**,
not just by padding inactive workspace.

## Remaining gap and adversarial review

1. Independent proof audit: equivalence of the task-effect SDP and
   the trace-norm parameter; extension to the full Hilbert effect;
   confirmation of no hidden original-oracle queries or circuit
   runtime assumptions.
2. Check whether the map from behavioral acceptance data to
   trace-minimizing effects can be solved with acceptable complexity
   or approximated by a separate source-dependent certificate.
   No such polynomial-time algorithm is claimed.
3. Search prior art on observable operator quotients, POVM
   completion, nuclear-norm representation minimization,
   quantum query/SDP simulation, and the completely bounded
   polynomial method. The core trace-norm/SDP machinery is standard;
   no historical originality is asserted.
4. Crucial unresolved question: whether for the tensor-subcube
   family **every** T=2 circuit has a task-equivalent effect
   with \(\Theta_{\rm task}=\operatorname{poly}(L)\).
   No proof or counterexample is known from these tests;
   this is **not** a restatement of observed classical tree depth.
5. Any statement about a computationally efficient simulator
   must separately charge the SDP and effect-construction work.
   Here only quantum/original-row query counts are addressed.

**Certification stage:** reproducible finite mathematical example
and general paper-level conditional operator theorem; independent
non-author review and Lean kernel certification remain open.
