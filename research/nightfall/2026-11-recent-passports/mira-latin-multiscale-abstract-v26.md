# NIGHTFALL / Mira v2.6 — independent abstract multiscale exact sampler

**Status:** Complete independent **abstract conditional sampling theorem** at author level, *not* source-specific instantiation or the full Latin-square theorem. Directly grounded in Mira Cult's \`flattening-v2.tex\` at pinned source [30ddaaad27b48df2002225c3e3f40cffd02c5253](https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling). The construction belongs to Mira; this is a separate proof reconstruction. Exact-check \`scripts/audit_mira_multiscale.py\`.

## Abstract theorem (conditional on specified oracle semantics)

Let \(\mathcal S\) be any finite nonempty target set, \(N=|\mathcal S|\). A single randomized forward experiment outputs at most one \((s,w)\), otherwise null, with exact subprobabilities \(Q(s,w)\). For every \(s\), a *fresh*, normalized reverse history experiment has exact distribution \(R_s(w)\) and \(R_s(w)>0\Rightarrow Q(s,w)>0\). The history set may be finite or countable provided all expectations and simulations are well-defined; for the applications here, it is finite (random runtimes are not decorations).

Let \(T(s,w)=R_s(w)/Q(s,w)>0\) on reverse support. Assume that for fixed **known** rational \(H>0\) and known integer \(M\ge2\),
\[
\mathbb E_{R_s}\log(H/T)\ge0 \quad\forall s,\qquad
\log(H/T)\le M \quad R_s\text{-a.s. }\forall s.
\]
Assume a forward soft gate coin \(\mathrm{Bernoulli}(T/(T+a))\) on actual forward support and a fresh reverse soft gate coin \(\mathrm{Bernoulli}(a/(T+a))\) on prescribed \(s\), for every dyadic \(a=H/2^j\), \(0\le j\le\lceil\log_2M\rceil\). Assume these exact procedures have **unconditional** expected bit cost at most \(W\), uniformly in \(s,j\), with independent fresh randomness as required. This includes computing any deterministic rational parameters and sampling any needed marks, not amortized cost conditional on a chosen rare history. An independent standard linear Bernoulli factory of Huber with input bias \(p\le1/5\) realizes \(2p\) with O(1) expected calls plus O(1) expected auxiliary bit work at fixed slack; alternatively its elementary stage-by-stage proof can be supplied separately.

Then Mira's multiscale construction is an exactly uniform \(\mathcal S\)-sampler, terminates almost surely, and has expected total bit work
\[
 O((W+\log^2(2M))(1+H/N)\log^2(2M)).
\]
In particular when \(M=\operatorname{poly}(n)\), \(W=\widetilde O(n^{25})\) and \(H/N=O(1)\), the above overhead is polylogarithmic, not a further power of \(n\).

### Independent proof

Put \(z=H/T\), \(J=\lceil\log_2M\rceil\), \(m_j=2^j\), \(m=m_J\), \(u=1/64\). For a fixed target \(s\), define
\[
f_j=\mathbb E_{R_s}\frac{z}{1+z/m_j},\quad
g_j=f_j/m_j=\mathbb E_{R_s}\frac{z}{m_j+z},\quad
r_j=\frac{u}{u+f_j}.
\]
As \(\sum_wR_s(w)=1\), \(q_s=\mathbb E_{R_s}(1/T)=\sum_wQ(s,w)\le1\). Disjoint target atoms imply \(\sum_sq_s\le1\). Jensen and \(\mathbb E\log z\ge0\) give \(Hq_s=\mathbb Ez\ge1\), and monotonicity gives
\(0<f_j\le\min(m_j,Hq_s)\).

**Soft identity.** Exactly, without approximating any density,
\[
\sum_wQ(s,w)\frac{T(s,w)}{T(s,w)+H/m_j}
=\sum_w\frac{R_s(w)}{T(s,w)+H/m_j}
=f_j/H.
\]
The reverse soft gate returns heads with probability \(g_j=\mathbb E_R[H/m_j/(T+H/m_j)]\).

**Tail-to-terminal inequality.** For any \(v\ge2\), \(t\le v\), the elementary inequality
\[
\frac{e^t}{1+e^t/v}\ge\frac{1+t}{3}
\]
holds: when \(t\le\log v\) use denominator \(\le2\) and \(e^t\ge1+t\); when \(t>\log v\) use value \(>v/2\ge(1+t)/3\) because \(t\le v\). Set \(v=m\ge M\), \(t=\log z\le M\), average, obtain \(f_J\ge(1+\mathbb E\log z)/3\ge1/3\). Hence \(u/f_J\le3u<1\): the terminal Bernoulli probability is *valid*, not an assumed oracle.

**Exact construction and probabilities.** Uniformly choose \(j\in\{0,\ldots,J\}\), execute the forward soft gate at \(H/m_j\). If it returns target \(s\), sequentially execute independent \(r_i(s)\) coin tests for \(i=0,\ldots,j-1\), rejecting at the first failure. For \(j<J\), also accept with an \(r_j\) coin; at \(j=J\), accept instead with an \(u/f_J\) coin.

The \(r_i\) coin is a fair-side first-success race between \(u/m_i\) (known rational) and a fresh \(g_i\) coin; the fair-side race returns the \(u/m_i\) side with exact probability \(r_i\). A trial uses expected \(O(m_i)\) draws because the combined side-success rate is at least \(u/(2m_i)\).

To sample \(u/f_J\), let \(p=r_J=u/(u+f_J)\le 3u/(1+3u)<1/5\). A fair-side race yields a p coin; Huber's fixed-slack linear factory supplies \(2p\). Independently draw \(K\ge1\) with probability \(2^{-K}\) and return heads iff all K independently generated \(2p\)-coins are heads. Its bias is \(\sum_{k\ge1}2^{-k}(2p)^k=\sum_{k\ge1}p^k=p/(1-p)=u/f_J\). Expected number of K and input factory calls is O(1).

For a fixed \(s\), after multiplying gate and acceptance probabilities but before choosing \(j\), level \(j<J\) contributes
\[
\frac{f_j}{H}\,r_j\prod_{i<j}r_i
=\frac{u}{H}(1-r_j)\prod_{i<j}r_i
\]
and level \(J\) contributes \(\frac{u}{H}\prod_{i<J}r_i\).
The telescoping identity
\(\sum_{j<J}(1-r_j)\prod_{i<j}r_i+\prod_{i<J}r_i=1\)
implies **each target** has exact one-trial mass \(u/[H(J+1)]\). This is independent of \(\{f_j(s)\}\). The total success probability is \(Nu/[H(J+1)]>0\); independent restarts produce an exactly uniform output and almost-sure termination, with mean \(H(J+1)/(uN)\) trials.

**Work (including rare target protection).** Let \(B=\{s:Hq_s>m^4\}\). Since \(\sum_s q_s\le1\), \(|B|\le H/m^4\). At any level \(j\), its first-soft-gate mass on B is at most \(m_j|B|/H\le m^{-3}\). All subsequent tests along any path cost at most \(O(m(W+\log^2(2M)))\) in *unconditional expectation* (uniform oracle cost as assumed), hence the aggregate bad-target per-trial contribution is \(O(m^{-2}(W+\log^2(2M)))\).

For \(s\notin B\), set \(K=\log(8m^4)\). For \(t=\log z\), the elementary inequality \(0\le(t-K)_+\le e^{t-K}\) implies
\[
\mathbb E_{R_s}\min(t,K)\ge -e^{-K}\mathbb E z
=-Hq_s/(8m^4)\ge-1/8.
\]
Whenever \(m_i\ge\max(2,K)\), apply the earlier scalar inequality at \(\min(t,K)\) (monotonicity in t) to get
\(f_i\ge(1-1/8)/3=7/24>1/4\),
hence \(r_i=u/(u+f_i)\le1/17\).
Let \(i_0\) be the first such \(i\), if one exists. Summed costs \(O(2^{i})\) through \(i_0\) give \(O(K)\); past \(i_0\) the survival of consecutive gates has factor at most \(17^{-(i-i_0)}\), summable against the doubled \(2^i\) cost. The terminal \(O(mW)\) inversion is covered by the same geometric suppression. If no \(i_0\) exists, then \(m=O(K)\) and the naive bound suffices.

The first-gate masses at any level are a subprobability, and the level is uniform, so one full trial has expected cost \(O((W+\log^2(2M))\log(2M))\), with no factor m. Multiply by the mean number \(H(J+1)/(uN)\) of independent trials. The unconditional expected renewal work equals expected cost per trial divided by its success probability even if success and runtime within a trial correlate (sum costs over independent restarted trials, using tail independence). The stated work bound follows. \(\square\)

### Quantifier warnings and remaining source-specific gates

- The theorem requires **one common** \(H\), reverse support inclusion, and means \(\mathbb E\log(H/T)\ge0\) for **every target**. Replacing these by an average-target bound is invalid.
- The runtime hypothesis \(W\) is for **actual** soft coin implementations using fresh randomness; merely knowing \(\mathbb E Y=T\) for a proxy variable does not automatically bound W without analyzing sampling cost, size bias, and rare anchors.
- This theorem certifies the *probability transformer* conditional on Q/R and coin oracles. It does **not** prove Mira's decorated Q/R construction, source-specific \(H/N=O(1)\), \(\widetilde O(n^4)\) matching probes per soft coin, or all-target mean coverage.
- External input: Huber's linear Bernoulli factory for a strict fixed slack, [Huber 2016](https://arxiv.org/abs/1308.1562). No other deep probabilistic input.
- Exact rational tests (not proofs): \`scripts/audit_mira_multiscale.py\` uses two different finite examples, including z spanning 9 orders of magnitude, to replay \(f_j\), all forward and reverse soft identities, terminal coin and target-flat one-trial mass.

**Main theorem status: UNVERIFIED.** This remains a subordinate statement in the single audit program.
