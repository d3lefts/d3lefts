# Universal Discoverability: Witness Width, Packing Rank, and Observation Fibers
**NIGHTFALL research note v0.1 · 2026-11-10 · research direction: Devin J. Wright**

**Scientific status:** A theorem and proof in a finite noiseless sensor model, finite falsification, and a separately scoped Lean certificate core. This is a *classical-style reduction*, not evidence of world-historical novelty. The remaining valuable challenge is proving new width/rank estimates from physically or mathematically meaningful system structure, and extracting efficient witness-selection algorithms.

## 1. State the impossibility before the positive theorem

Let \(\mathcal X\) be an admissible set of possible static states, \(I\) a finite set of sensor labels, \(\rho_i:\mathcal X\to A_i\) the exact observation supplied by sensor \(i\), and \(f:\mathcal X\to Y\) the target. Any adaptive protocol chooses sensor labels based only on previous observed labels and returns the exact value of \(f\).

**Information obstruction.** If \(x,y\in\mathcal X\) satisfy \(\rho_i(x)=\rho_i(y)\) for every available sensor \(i\) but \(f(x)\ne f(y)\), no protocol using those sensors can always recover \(f\). This requires no probability theory. [Lean: conflicting_twins_block_all_certificates].

**Cost obstruction.** On \(n\) fair bits, parity needs \(n\) observations in the worst case. A degree-one *real-valued* target \(f(x)=\sum_{i=1}^{n}2^{i-1}x_i\) also requires \(n\) binary observations for exact output recovery: each bit independently changes the target. Thus degree alone is insufficient for dimension-free **exact** real-output recovery.

**Sensor alphabet obstruction.** If one sensor outputs an index from \(N\) possibilities (e.g. an address) and is charged as "one query", it may deliver \(\log_2N\) bits in one operation. A query count is not a communication-bit or laboratory-cost bound without explicitly accounting for per-sensor cost and outcome bandwidth.

## 2. Operational witness width

A history is an observed set \(Q\subseteq I\) and a nonempty observation fiber
\[
H(Q,a)=\{x\in\mathcal X:\rho_i(x)=a_i\text{ for all }i\in Q\}.
\]
It is unresolved if \(f\) is not constant on \(H\).

A **uniform revealing block** for an unresolved fiber is a **nonempty** \(B\subseteq I\setminus Q\) such that for every \(x\in H\) there exists \(y\in H\) satisfying
\[
f(y)\ne f(x),\qquad \rho_i(y)=\rho_i(x)\quad (i\notin B).
\]
The essential quantifier is \(\forall x\in H\exists y\in H\), with one block \(B\) chosen *from the observed fiber*, not from knowledge of the hidden actual \(x\).

Define \(w\) as the smallest integer such that **every unresolved fiber** admits such a \(B\) of size at most \(w\).

For a fixed state \(x\), a sensitive block is \(B\subseteq I\) such that some admissible \(y\) differs in target, but has identical sensor readouts outside \(B\). Define \(r=\max_x r(x)\), where \(r(x)\) is the largest number of pairwise disjoint sensitive blocks at \(x\). These are the usual notions of block sensitivity / packing rank generalized to arbitrary sensor alphabets and constrained admissible state classes.

## 3. Conditional finite adaptive discovery theorem

**Theorem (uniform witness packing).** Suppose:
1. The target is identifiable from complete sensor readings (no conflicting observational twins).
2. Every unresolved fiber has a uniform revealing block of at most \(w\) *unqueried* sensors.
3. Every state admits at most \(r\) pairwise disjoint sensitive blocks.

Then there exists a deterministic adaptive sensor protocol computing \(f\) exactly using at most \(wr\) individual sensors on every admissible state:
\[
\boxed{D(f)\le wr.}
\]

**Proof.** Keep a fiber of states compatible with all revealed sensor readings. If it is nonconstant, choose a uniform revealing block \(B\) of size at most \(w\) from this fiber, read all sensors in \(B\), and intersect the fiber with the new observed values. Repeat until the target is constant on the fiber.

On a fixed actual state \(x\), the uniform-witness definition provides a witness \(y_B\) at each selected block such that \(f(y_B)\ne f(x)\) and the two states agree outside \(B\). The block \(B\) is therefore sensitive *at the same original state \(x\)*, regardless of the observed previous blocks. Blocks from distinct rounds are disjoint, since we only query as-yet-unqueried sensors. Consequently the protocol can perform at most \(r\) rounds. Any further unresolved fiber would provide an \((r+1)\)st disjoint sensitive block, contradicting (3). Each round reads at most \(w\) sensors. This proves the claim. The finite-state choice is a legitimate deterministic function of the observed fiber; this does NOT imply that finding it is computationally efficient. QED.

**Weighted version.** Assign sensor costs \(c_i\ge0\). If every unresolved fiber admits a common revealing block with total cost at most \(\kappa\), the same proof gives total observation cost \(\le \kappa r\). Include sensor alphabet bit size or measurement expenditure in \(c_i\) where applicable.

**Scope:** arbitrary admissible states, heterogeneous sensor types, any target alphabet, no product law or probability assumption. The proof is a classical decision-tree/witness-packing mechanism; novelty is not established.

## 4. Static certificate theorem, separately kernel checked

For fixed \(x\), choose a family \(P\) of sensitive blocks with the *hitting property*: every sensitive block at \(x\) intersects at least one block of \(P\). Then the union \(U=\bigcup_{B\in P}B\) is an exact **pointwise certificate** at \(x\). If \(|P|\le r\) and each block has \(|B|\le w\), then \(|U|\le wr\).

**Proof.** If another state \(y\) agreed on every sensor in \(U\) but had \(f(y)\ne f(x)\), it would make the complementary sensor set \(I\setminus U\) sensitive at \(x\). That block is disjoint from every element of \(P\), contradicting the hitting property. The union-size bound is subadditivity of cardinality.

**Lean core:** see WitnessPacking.lean, with named theorems hitting_implies_certificate, bounded_union_cost, witness_packing_certificate, conflicting_twins_block_all_certificates, and full_transcript_certifies. This is a STATIC certificate theorem; do not mislabel it as a kernel proof of the adaptive theorem in §3.

## 5. Connection to NIGHTFALL product-space exact recovery

For a finite independent full-support product, an exactly degree-\(d\) Hoeffding observable (any real palette) has uniform witness width at most \(d\). At a nonconstant prefix section, take a maximal nonzero Hoeffding component \(f_S\) with \(|S|\le d\); orthogonality and centering give a positive conditional variance on \(S\) at *every* complementary input (all finite atoms have positive mass). The quantitative version with \(e_S=\|f_S\|_2^2\) and range \(R\) gives
\[
\Pr[f(z,U_S)\ne f(z,v)]\ge e_S/R^2.
\]
The finite analog of this mechanism is investigated and partially Lean-certified in NIGHTFALL PR #306.

Consequently the abstract theorem supplies \(D(f)\le d\,\mathrm{bs}(f)\) for finite products, where \(\mathrm{bs}(f)\) measures disjoint output-changing resampling blocks in the native product alphabet. This is a structural extension of classical degree-vs-block-sensitivity reasoning, **not a claimed new general Boolean decision-tree inequality**. Bounding \(\mathrm{bs}(f)\) by a polynomial in \(d\) for a fixed **finite output palette** additionally requires imported cube estimates; the countable-product measurable-selection bridge remains a distinct unresolved formalization task.

## 6. Independent finite falsification and deliberately bad cases

Check by running:
  python3 research/nightfall/formalization/discoverability/check_witness_rank.py

The checker computes exact optimal deterministic decision-tree depth \(D\), every-history uniform width \(w\), and maximum disjoint sensitive-block rank \(r\), independently of the theorem proof. It exhausts all 4, 16 and 256 total Boolean functions on 1, 2 and 3 sensors, respectively. Additional 4- and 5-sensor parity, OR and addressing examples are replayed.

- 4-bit parity: \(D=4,w=1,r=4\). The theorem is tight.
- 4-bit OR: \(D=4,w=4,r=4\). The theorem holds but gives 16, demonstrating that the upper bound need not be close.
- 4-bit address toy: \(D=2,w=2,r=2\), hence bound 4. The extra bits of the 4-bit input are ignored by the toy; this is a specific control, not the general N-address family.
- Conflicting observational twins falsify identifiability and cannot be exactly discovered.
- The degree-one weighted binary-code output illustrates arbitrarily high exact observation cost despite interaction degree one.

Finite checks cannot prove general claims or establish historical priority.

## 7. Prior art and scientific credit

- Classical decision-tree bounds include \(D(f)=O(\deg(f)\mathrm{bs}(f))\) and the usual certificate/block-sensitivity framework; see Chugh–Podder–Sanyal, *Decision Tree Complexity Versus Block Sensitivity and Degree*, FSTTCS 2023, Proposition 29(5), DOI 10.4230/LIPIcs.FSTTCS.2023.27, crediting Midrijanis (2004).
- Nisan (1989), *CREW PRAMs and decision trees*, introduced block sensitivity as a major measure.
- Tal's strengthening \(\mathrm{bs}(f)\le\deg(f)^2\) for Boolean functions improves the earlier Nisan–Szegedy constant.
- Related product-space decision-tree learning is studied by Soltani Moakahr et al., 2026, arXiv:2605.12983. Their problem concerns learning/approximation and is not the exact same theorem.

**Novelty threshold:** A new structural class with a provably small common witness width/rank, a new representation-to-witness certificate bound, efficient extraction from a nontrivial observation oracle, or a verified infinite-product extension not already covered by earlier query-complexity theory.

## 8. Next decisive proof obligations

1. Extend Lean from the static certificate to a finite **adaptive history-policy construction**. Use a state-fiber-dependent selector and prove it is nonanticipating; avoid feeding the hidden state into selector choice.
2. Connect explicit finite weighted ANOVA projections to uniform revealing blocks in Lean without assuming the conclusion.
3. Test weighted costs on high-arity address sensors and a non-product constrained state class. Report computation to find a witness separately from sensor observations.
4. Once end-to-end finite results are certified, tackle countable measurable selection and completed-product subtleties in a separate module. Obtain independent mathematical review.

**Stop rule:** If the universal result collapses to a textbook D<=degree*bs derivation without an original extension or a new certified structural bound, archive as a useful reusable lemma and transfer instrument, not an original mathematical flagship.


## 9. A self-contained finite-palette rank bound by polynomial Markov inequality

**Proposition (independent derivation, classical ingredients).** Suppose \(f\) on a finite full-support independent product has Hoeffding degree at most \(d\ge1\), essential output range \(R>0\), and finite-palette spacing \(\Delta>0\). Then its native-coordinate disjoint-block rank satisfies
\[
  \mathrm{bs}(f)\le 2d^2 R/\Delta,
\]
and the preceding uniform-witness theorem gives the entirely dimension-independent elementary bound
\[
  D(f)\le 2d^3 R/\Delta.
\]

**Proof of the rank bound.** Fix any state \(x\) and \(t\) pairwise disjoint sensitive blocks \(B_1,\ldots,B_t\), with alternative configurations \(y_j\) changing the output by at least \(\Delta\) inside only \(B_j\). Introduce a binary switch \(z_j\) selecting the original values on \(B_j\) when \(z_j=0\), or the replacement values when \(z_j=1\); all other original coordinates remain fixed. The resulting \(g:\{0,1\}^t\to\mathbb R\) has degree at most \(d\), by the finite degree-preserving disjoint-block switching lemma, and takes values inside the same interval of length \(R\).

Partition the switched coordinates into \(J_+=\{j:g(e_j)>g(0)\}\) and \(J_-=\{j:g(e_j)<g(0)\}\). For the positive group, let \(q_+(s)=\mathbb E[g(Z)]\) where \(Z_j\sim\mathrm{Bernoulli}(s)\) independently for \(j\in J_+\) and all other switches are zero. The function \(q_+\) is a real univariate polynomial of degree \(\le d\), and its range on \([0,1]\) lies in an interval of width \(R\). Direct differentiation at zero gives
\[
q_+'(0)=\sum_{j\in J_+}(g(e_j)-g(0))\ge |J_+|\Delta.
\]
The classical Markov derivative inequality, rescaled from \([-1,1]\), bounds the derivative of any degree-\(d\) polynomial whose range has width \(R\) on \([0,1]\) by \(d^2R\). Thus \(|J_+|\le d^2R/\Delta\). Apply the identical argument to \(-g\) over \(J_-\); the two counts sum to \(t\le2d^2R/\Delta\). Since \(x\) and the disjoint blocks were arbitrary, the rank bound follows. QED.

The sharper FHKL/Tal machinery used in the v0.2 exact-recovery research can improve constants under its applicable normalization; this section establishes a **separate elementary conservative bound** and is not a kernel formalization of Markov's inequality. For equally spaced \(q\)-level outputs this gives \(2(q-1)d^3\), while the v0.2 manuscript proposes \((q-1)d^3\) via a sharper imported derivative inequality. Neither factor is claimed as a new historical record.

**Critical scope:** This rank bound requires an actual finite palette with positive \(\Delta\). For unrestricted real outputs \(\Delta\) may vanish; the degree-one binary-encoding example above demonstrates why no degree-only exact query bound follows.


## 10. Infinite sensor sets: an abstract set-theoretic extension

The adaptive theorem of §3 does **not** require \(I\) to be finite, provided the uniformly revealing blocks are finite and \(w,r<\infty\). Let \(I\) be any set of exact sensors, and allow arbitrary state and answer sets. Every history still consists of **finitely many** observed sensor labels; the same proof selects at most \(r\) pairwise disjoint finite sensitive blocks and terminates after at most \(wr\) observations.

This is a set-theoretic existence statement under the full universal witness hypothesis, and may invoke choice to select blocks from all possible histories. It does **not** establish algorithmic computability of the selector, its measurability under a product probability law, any finite bound for arbitrary systems (which may have infinite width/rank), or arbitrary dynamic/interactive actuation. The current Lean module proves only the **finite-sensor static certificate core**; a separately audited formal proof of the infinite-index adaptive protocol remains open.

This distinction allows the abstract principle to cover infinite ambient complexity *conditionally* without pretending that countable-product adaptive recovery has already passed its measurable-selection review.


## 11. Two-sided characterization: rank is also an unavoidable lower bound

Every correct deterministic decision tree must query at least one sensor from each sensitive block at the actual state \(x\). Otherwise a witness state \(y\) changing only the readings in an unqueried block would follow the identical observation transcript but require a different target output. For \(r(x)\) pairwise disjoint sensitive blocks, the actual path must therefore contain at least \(r(x)\) distinct sensor observations.

Taking the worst case, \(\boxed{r\le D(f)}\). Together with the uniform-witness upper bound of §3:
\[
  \boxed{r\le D(f)\le w r.}
\]
If \(w=1\), this is an **exact characterization** \(D(f)=r\); in general, \(w\) is a multiplicative upper/lower approximation factor. This is the standard block-sensitivity lower-bound principle in a sensor-agnostic formulation, not a new first-discovery theorem. It also explains why bounded witness width *alone* is insufficient: parity has \(w=1\) but \(r=n\), so it necessarily costs \(n\) observations.

No lower-bound theorem for arbitrary noisy or interactive experiments follows without a corresponding indistinguishability model. For nonuniform sensor costs, every correct path must hit each disjoint sensitive block, giving a **minimum-cost hitting-set lower bound**; replacing it with the sum of the cheapest sensor in each sensitive block is valid because disjoint blocks cannot reuse one queried sensor.


## 12. High-arity addressing: fixed structural complexity, unbounded adaptivity gain

Let \(N\ge2\). The admissible state is \((K,B_1,\ldots,B_N)\) with one address sensor \(K\in\{1,\ldots,N\}\) and \(N\) binary data sensors \(B_j\in\{0,1\}\). The exact target is \(f=B_K\). Sensor outcomes are independently and noiselessly readable; one query to the N-ary address sensor is counted as **one sensor observation**, not one communication bit.

**Three exact assertions:**
\[
\deg_{\rm ES}(f)=2,\qquad
D_{\rm adaptive}(f)=2,\qquad
D_{\rm nonadaptive}(f)=N+1.
\]
The upper bound is achieved by observing \(K\) then \(B_K\). One query cannot suffice since no individual sensor determines \(f\) for all states. Any nonadaptive set must contain every \(B_j\) (otherwise choose \(K=j\) and flip that missing bit), and must also contain \(K\) (otherwise fix a nonconstant data vector and vary the address).

**Witness geometry:** The uniform revealing width is exactly \(w=2\). If the address is known, \(B_K\) alone is a uniform witness while the target remains unresolved. If the address is unknown and some data bit \(B_j\) is unqueried, the block \(\{K,B_j\}\) lets every current state change its target by setting \(K=j\) and \(B_j\) to the opposite output. If all bits are known and the address remains unknown, \(\{K\}\) suffices whenever the fiber is unresolved. No one-sensor block is uniformly sensitive on the initial full fiber.

The global disjoint sensitive-block rank is exactly \(r=2\): any sensitive block **not containing K** must contain the currently addressed bit \(B_K\), so at most one such disjoint block is possible, and at most one more block can contain K. Both can coexist (e.g. \(\{B_K\}\) and \(\{K,B_j\}\) for \(j\ne K\)), so r=2.

Thus \(w=r=2\) for every \(N\), while the nonadaptive exact observation cost grows as \(N+1\). This is a classical addressing/pointer mechanism, not a worldwide novelty claim. It is a concrete model-matched demonstration that witness geometry can remain bounded when ambient dimension increases. However, charging the address sensor by \(\lceil\log_2N\rceil\) bits makes the bit communication cost grow logarithmically rather than remain two.

**Independent exact falsification:** check_high_arity_address.py enumerates the entire state set and computes optimal deterministic adaptive and nonadaptive query counts for \(N=2,3,4,5\). The checker does not hard-code D=2 as the algorithm: it independently solves the finite minimax decision-tree recursion over observation fibers.
