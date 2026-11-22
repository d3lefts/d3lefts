# Rank-free two-query simulation on the tensor-subcube oracle

**Paper proof candidate.** Independent internal mathematical audit found no gap; not Lean-certified,
external review and same-model priority open. The product-tensor circuit lemma is
an application of Lovitz–Petrov, not claimed as independent prior-art novelty.

## Theorem

Let \(R\subseteq(\mathbb F_2^2)^{\otimes L}\) be the \(3^L\) nonzero product
tensors with nonzero local factors, \(D=R\cup\{0\}\), and \(L\ge1\). The secret
\(s\) is uniform on the dual vector space; an original-row query obtains
\(\chi_a(s)=(-1)^{a\cdot s}\) for \(a\in R\). For every finite-dimensional
two-query quantum circuit and arbitrary terminal effect \(0\preceq P\preceq I\),
there is a deterministic nonuniform original-row decision tree of depth
\[
\min\!\left(3^L,\left\lceil
  \frac{2(2\sqrt{K_L}+145\sqrt M)^2}{\varepsilon^2\delta}
\right\rceil\right)
\]
whose output \(g\in[0,1]\) approximates the acceptance \(f\) with
\(\Pr_s(|f(s)-g(s)|>\varepsilon)\le\delta\), for \(0<\varepsilon,\delta<1\).
Here
\[
M=\max\bigl(1,\max_{z\ne0}\#\{(x,y)\in D^2:x+y=z\}\bigr),\quad
K_L=\sum_{j=0}^{\min(6,L)}\binom Lj (1+4\cdot3^j)^4 .
\]
Thus the cost is \(O(L^6/(\varepsilon^2\delta))\); Section 2 gives
\(M=O(L^2)\) independently of sharper two-fiber results. Classical offline
preprocessing and evaluation time are unrestricted; the conclusion
is distributional acceptance approximation, not quantum state sampling.

## 1. Rank-free coefficient energy

Use the purified phase-oracle form \(O_s=\sum_{a\in D}\chi_a(s)\Pi_a\)
with pairwise orthogonal frequency projectors summing to \(I\), unit starting
state \(\psi\), inter-query unitary \(U\), and effect \(P\) absorbing any final
unitary. This includes the standard binary response oracle in its \(\pm\)
eigenbasis, grouping equal labels, with the always-positive parts in label
zero. Let
\[
\psi_a=\Pi_a\psi,\qquad t_{ba}=\Pi_bU\psi_a,\qquad
p_a=\|\psi_a\|^2,\qquad q_b=\sum_a\|t_{ba}\|^2.
\]
Both sequences sum to one. The final state is
\(T(s)=\sum_{a,b}\chi_{a+b}(s)t_{ba}\). Thus
\[
f(s)=\sum_{a,b,a',b'}\chi_{a+b+a'+b'}(s)
 c_{a,b,a',b'},\qquad c_{a,b,a',b'}=\langle t_{b'a'},P t_{ba}\rangle.
\]
Fix \(\eta>0\). Query the nonzero rows with \(p_a\ge\eta\) or \(q_a\ge\eta\);
there are at most \(2/\eta\) such rows. Let \(W\) be their binary span.
A light label in a first-query slot has \(p_a<\eta\); a light label in
a second-query slot has \(q_b<\eta\). Outside-\(W\) frequencies have at least
one slot outside \(W\) (and thus light). When a frequency is the sum
of surviving labels after cancellation, the same holds for the surviving slots.

The path frame sum \(G=\sum_{ba}|t_{ba}\rangle\langle t_{ba}|\) has trace
one. Restrict the sum to first slots with \(p_a<\eta\). The restricted
frame \(G_\ell\preceq\eta I\): before \(U\), the vectors \(\psi_a\) are
orthogonal of squared norms \(p_a\); applying \(U\) and the pinching
\(X\mapsto\sum_b\Pi_b X\Pi_b\) preserves the inequality. Restrict instead
to second slots with \(q_b<\eta\); then \(G_\ell\preceq\eta I\) by the
block traces \(q_b\). For either restriction,
\[
\sum_{ba\text{ restricted},\,b'a'} |c_{a,b,a',b'}|^2
 =\operatorname{Tr}(G_\ell P G P)
 \le\eta\operatorname{Tr}(P G P)\le\eta.
\]
The same holds for either primed slot by selfadjointness. The total
ungrouped squared coefficient energy with any light slot is therefore
at most \(4\eta\). In particular, any subfamily with at most \(B\) original
ordered lifts per outside-\(W\) frequency has outside-\(W\) Fourier norm
at most \(2\sqrt{B\eta}\), by Cauchy–Schwarz on the lifts and Parseval.

The estimator \(g=\mathbb E[f\mid\chi_w,w\in W]\) depends only on the
queried original rows. Uniform Walsh orthogonality shows this drops exactly
the outside-\(W\) frequencies, also for dependent queried rows. Its
output lies in \([0,1]\). Below we bound the total outside-\(W\) Fourier norm
by partitioning terms and using the triangle inequality.

## 2. Primitive XOR representations

Call an ordered tuple of distinct slots primitive when, after discarding
any zero entry, the remaining set of rows has no nonempty zero-sum subset.
For \(z\ne0\) with a primitive representation by at most four rows, fix
one underlying set \(C\). For any other \(C'\), their symmetric
difference has zero sum and partitions into disjoint minimal nonempty
zero-sum sets, by repeatedly extracting one. These are circuits in the
binary vector matroid; every one meets both \(C\) and \(C'\) by primitivity.

[Lovitz–Petrov](https://arxiv.org/abs/2103.15633), Theorem 4 and its
circuit corollary, apply over an arbitrary field, in particular \(\mathbb F_2\).
A circuit \(E\) is connected and has span dimension \(|E|-1\).
The splitting theorem, by contrapositive, bounds the sum of local dimensions
minus one by \(|E|-2\). Here this is exactly the number of places where
the local nonzero factor varies, since over \(\mathbb F_2\) any two distinct
nonzero vectors are nonproportional. For \(L=1\) this count is immediate.

The union of varying sites of the disjoint circuits has size at most
\(8-2=6\) when nonempty; if \(C'=C\) take this site set empty.
Outside these sites every new row agrees with an old row from its
circuit; a shared row agrees with itself. For any fixed set of \(j\)
sites each ordered slot has at most \(1+4\cdot3^j\) choices, including
the possible zero slot. Hence the number of primitive ordered lifts
is at most \(K_L\), giving outside-\(W\) norm \(2\sqrt{K_L\eta}\).
For pair sums the same proof uses reference size at most two and
at most two varying sites; all nonzero ordered pair sums are primitive
after deleting zero. This also establishes \(M=O(L^2)\).

## 3. Repeated labels: six equality events

Use inclusion–exclusion for the union of the six equalities between the
four slots, leaving first-order grouped sums unrestricted on other slots.
Any intersection of at least two distinct equality events either forces
two disjoint pairs or all four equal, hence frequency zero, or forces
one triple and a singleton, with different labels for a nonzero frequency.
A triple position is specified by the equality events. For such an
intersection the frequency is the XOR of the triple and singleton
labels; there are at most \(M\) ordered lifts for any \(z\ne0\).
By Section 1 its outside-\(W\) norm is at most \(2\sqrt{M\eta}\).
There are at most \(57\) higher-order intersections.

For one equality, group the canceled label and index a grouped coefficient
by the two ordered surviving labels. There are at most \(M\) survivor
pairs for each outside-\(W\) frequency, so a light-survivor norm bound
of \(2\eta\) yields outside-\(W\) norm \(\sqrt{2M\eta}\).

- **Same first label \(a=a'\):** the coefficient is
  \(\langle T_{b'},(\bigoplus_a P)T_b\rangle\), where
  \(T_b=\bigoplus_a t_{ba}\). These vectors are orthogonal with squared
  norms \(q_b\). Their full frame has trace one and the \(q_b<\eta\)
  restriction has operator norm at most \(\eta\). The same trace argument
  as in Section 1 bounds energy by \(\eta\) per light survivor.
- **Same second label \(b=b'\):** the coefficient is
  \(\langle U\psi_{a'},P_{\rm diag}U\psi_a\rangle\),
  where \(P_{\rm diag}=\sum_b\Pi_bP\Pi_b\preceq I\).
  Orthogonality and the squared norms \(p_a\) give the same bound.
- **Within path \(a=b\) or \(a'=b'\):** the canceled path group is
  the single vector \(T_0=\sum_a t_{aa}\) of norm at most one by
  output-sector orthogonality. The coefficient is
  \(\langle t_{b'a'},P T_0\rangle\) or its conjugate. Each of the two
  light restrictions on the surviving path is bounded by \(\eta\)
  via the restricted path frame in Section 1.
- **Opposite paths \(a=b'\) or \(b=a'\):** for \(a=b'\) the coefficient is
  \(\langle U\psi_{a'},F_b\rangle\), where
  \(F_b=\sum_a\Pi_a P\Pi_b U\psi_a\). The other event is its conjugate
  after exchanging primed and unprimed slots. For any scalars \(\beta_b\),
  \[
  \Big\|\sum_b\beta_bF_b\Big\|^2
  =\sum_a\Big\|\Pi_a P\sum_b\beta_b t_{ba}\Big\|^2
  \le\sum_{a,b}|\beta_b|^2\|t_{ba}\|^2
  =\sum_b|\beta_b|^2q_b .
  \]
  Here the equality uses orthogonality of \(\Pi_a\); the inequality
  uses the contraction and orthogonality of \(\Pi_b\) for fixed \(a\).
  Consequently the \(F_b\) frame has trace at most one and its light
  restriction has operator norm at most \(\eta\).
  The orthogonal \(U\psi_{a'}\) frame likewise has trace one and
  light restriction norm at most \(\eta\). The same trace estimate
  applies, with the identity between these two frames.

The total repeated-label outside-\(W\) norm is at most
\((6\sqrt2+114)\sqrt{M\eta}\). All constants lie in \(W\); large zero-fiber
terms have not been touched.

## 4. Distinct labels with a zero triple

There are four distinct slots. If one is zero and the frequency is
nonzero, the residual three nonzero labels are primitive, since only
the full triple could sum to zero. Otherwise all four are nonzero;
a nonprimitive nonzero-frequency tuple must contain a zero triple.
The triple is unique, since if two different triples summed to zero
their fourth labels would both be equal to \(z\), contradicting
distinctness. Partition by the survivor location \(d=z\).

For \(z\ne0\), put
\[
\widehat T_z^{\rm nz}=\sum_{a,b\in R:\,a+b=z}t_{ba},\qquad
\sum_{z\ne0}\|\widehat T_z^{\rm nz}\|^2\le M.
\]
The bound follows from the nonzero pair multiplicity and the sum
of squared path norms being one. For each triple group, temporarily
allow \(d\) to equal one of the triple labels. If \(d=a'\), the
resulting grouped coefficient is
\[
K_d=\left\langle U\psi_d,\sum_{b'\in R}\Pi_{b'}P
   \widehat T_{b'}^{\rm nz}\right\rangle.
\]
The second vector has squared norm at most \(M\) by orthogonality of
the \(\Pi_{b'}\) and the contraction. Summing the squared coefficients
over light initial \(d\) gives at most \(\eta M\). If \(d=b'\), then
\[
K_d=\sum_{a'\in R}
   \langle\Pi_d U\psi_{a'},P\widehat T_{a'}^{\rm nz}\rangle,\qquad
|K_d|^2\le q_d\sum_{a'\in R}\|\Pi_dP\widehat T_{a'}^{\rm nz}\|^2.
\]
Summing over light final \(d\) gives at most \(\eta M\), by completeness
of \(\Pi_d\) and contraction of \(P\). The two unprimed survivor positions
are conjugates of these cases. Outside \(W\) the only survivor is
\(d=z\), hence light at the position under consideration.

Subtract the terms where \(d\) equals one of its triple labels.
The triple entries are distinct already (they are nonzero and XOR
to zero). For each fixed \(d\) and repeated placement, the remaining
two entries XOR to \(d\), allowing at most \(M\) ordered lifts.
Thus the overlap correction has at most \(3M\) ordered lifts per
outside-\(W\) frequency, with light survivor \(d\). Its norm is at most
\(2\sqrt{3M\eta}\) by Section 1. This subtraction only corrects the
temporary triple group; the separate repeated-label union remains
as counted in Section 3. The four triple groups together contribute
at most \(4(1+2\sqrt3)\sqrt{M\eta}\).

## 5. Conclusion

The cases exhaust the outside-\(W\) terms. By the triangle inequality
their total Fourier norm is at most
\[
2\sqrt{K_L\eta}
 +(6\sqrt2+114+4(1+2\sqrt3))\sqrt{M\eta}
 \le (2\sqrt{K_L}+145\sqrt M)\sqrt\eta.
\]
Choose \(\eta=\varepsilon^2\delta/(2\sqrt{K_L}+145\sqrt M)^2\).
Parseval gives mean square error at most \(\varepsilon^2\delta\);
Markov yields the claimed probability. Querying all original rows
is an exact fallback.

**Verification boundary.** No Lean theorem or priority clearance.
The early-stage and late-stage heavy masses use only path energies,
not any bound on the rank or trace of the acceptance effect. This
proof does not assume orthogonality of paths carrying the same character.

