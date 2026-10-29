# Lemnis / NIGHTFALL — 2-primary voltage-cover obstruction and independent Sidon-prefix audit

**Date:** 2026-10-29. **Owner:** NIGHTFALL / Devin J. Wright. **Agent:** Lemnis (Structural Theorem and Adversarial Review Lead). **Assignments:** self-assigned GitHub #80; Erdős #64 primary #47; Axiom Sidon #44/#329 cross-review #49 / PR #62. **Status:** internally proved elementary covering lemma and independently checked finite controls; world-first novelty, external referee review and full priority search **open**.

## 1. Exact covering-cycle theorem

Let \(G\) be a finite simple graph containing a **simple** cycle \(C\) of length \(2^k\), \(k\ge2\). Let \(p:\widetilde G\to G\) be a finite regular graph cover with deck-transformation group \(H\) a finite **2-group**. Then \(\widetilde G\) contains a simple cycle of length \(2^{k+a}\) for some integer \(a\ge0\). This also holds after any finite tower of two-sheeted graph covers, including towers whose composite regularity is unspecified.

**Proof.** Orient the base cycle \(C=(v_0,v_1,\ldots,v_{L-1},v_0)\), \(L=2^k\). A regular cover can be described by voltages in \(H\); following the lifted circuit sends the starting sheet \(h\) to \(h\,g\), where \(g\) is the ordered product of the edge voltages (up to an immaterial inverse and conjugation convention). Since \(H\) is a 2-group, \(\operatorname{ord}(g)=2^a\). Traversing the base circuit exactly \(2^a\) times returns to the initial lifted vertex, and fewer traversals do not. The resulting closed walk is **simple**: two distinct base positions project to different vertices of the simple cycle, and identical base positions at different passes have distinct fiber labels until the minimal return. Its length is \(L2^a=2^{k+a}\).

For a single two-sheeted cover, the return permutation on a fiber above \(v_0\) is either identity or the transposition. Accordingly, \(C\) lifts to two disjoint \(L\)-cycles or one \(2L\)-cycle. Applying this inductively to any tower of double covers completes the second assertion. \(\square\)

**Stronger monodromy criterion.** In *any* finite graph cover, the lifted cycles over a simple base cycle of length \(L\) correspond exactly to the cycles of the monodromy permutation \(\sigma_C\) on the fiber: a permutation cycle of length \(m\) gives a graph cycle of length \(Lm\). Therefore a power-of-two base cycle has a power-of-two lift **if and only if** the corresponding monodromy permutation has **some** cycle of power-of-two length. For a regular group-voltage cover every orbit has length \(\operatorname{ord}(g)\). This is the exact boundary condition; the deck-group 2-primary restriction is sufficient, yet not logically necessary for an individual covering.

### Important sharpness counterexamples

1. **Odd-order regular cover.** A regular \(C_3\)-voltage lift of base \(C_4\), with net voltage of order three, is \(C_{12}\). It has neither a 4-cycle nor an 8-cycle. The base has degree two: this does **not** contradict the Erdős–Gyárfás conjecture, whose minimum-degree hypothesis is three.
2. **Power-of-two degree is insufficient.** An arbitrary eight-sheeted cover of \(C_4\) with monodromy permutation having disjoint cycles of lengths three and five is \(C_{12}\sqcup C_{20}\). The cover degree is \(8\), yet no lifted cycle has power-of-two length. The general cover has monodromy in \(S_8\), not constrained to a 2-group.
3. A base graph with **no** power-of-two cycle is outside the theorem's hypothesis; no implication in either direction is asserted about such a base.

### Erdős #64 search consequences

A counterexample to the Erdős–Gyárfás conjecture cannot be constructed by taking any base graph **already possessing a power-of-two cycle** and applying finite regular voltage covers with 2-group deck groups. In particular, any tower of ordinary 2-lifts preserves the existence of a power-of-two simple cycle. Thus a proposed search relying on 2-lifts of previously certified bases is mathematically futile. To escape this obstruction, search families must use a base lacking the target property, a cover with odd-primary monodromy on the known base cycles, or structural graph substitutions beyond covering. The theorem does **not** show that all nonabelian voltage lifts are useless; nonabelian deck groups with odd-order elements remain possible search operators.

This is a specialized consequence of classical monodromy/regular-cover theory (Gross and Tucker, 1977/1987). No claim of newly invented covering-space mathematics is made. The value for NIGHTFALL is eliminating an entire search-operator family by a proved structural invariant.

## 2. Independent finite and mutation evidence

Two completely separate standard-library Python implementations are included:

- `verify_two_primary_covers.py`: independently defines the exact group multiplication tables of \(C_2^3\), \(C_8\), \(D_8\), and \(Q_8\); checks all group triples for associativity, builds a regular voltage cover from the labeled edges of \(K_4\); constructs the predicted lifted simple cycle; then searches the cover graph independently for that length. **80** seeded assignments (20 per group) passed. Element voltage orders include 1, 2, 4, 8 as the group permits. A separate regular \(C_3\) cover of \(C_4\) verifies the odd-order failure boundary.
- `verify_monodromy_and_towers.py`: constructs the **nonregular eight-sheeted** graph cover with monodromy `(0 1 2)(3 4 5 6 7)` and directly checks that only \(C_{12}\) and \(C_{20}\) occur as components; literal simple-cycle DFS rejects target lengths 4, 8, 16, 32. Separately creates **30 independent randomized towers** of three double covers of \(K_4\), checking after every lift that a genuine simple cycle of length \(4,8,16,\) or \(32\) persists.

These exact finite tests support the implementation and expose invalid generalizations; the universal theorem follows from the independent written group-order argument, not statistical sampling.

## 3. Assigned independent cross-review — Axiom's fixed-prefix finite Sidon bound

The strongest new Axiom result in #49 / draft PR #62 asserts that for every fixed nonempty integer Sidon prefix \(A\), of size \(r\), there exist arbitrarily large finite Sidon supersets whose normalized size has liminf at least

\[
C_r=\frac{1-2/(675r)}{\sqrt{2-1/(40r)}}>1/\sqrt2.
\]

This is a **finite-extension** result for each frozen prefix. It does not establish the same coefficient along an *infinite* Sidon sequence whose prefix size increases; the constant depends on \(r\). It does not solve the requested coefficient 1 of Erdős #44/#329.

### Independent proof-step attack

1. **Bose–Chowla ring:** the modular Sidon identity follows from comparing coefficients of \(1,\theta\) after multiplying \((\theta+t_1)(\theta+t_2)=(\theta+t_3)(\theta+t_4)\), with \(\theta\notin\mathbb F_q\). Exact unordered sums include diagonals.
2. **Endpoint rotation:** a cyclic shift averages the number of elements in the low interval \([0,J]\) plus high interval \([L-J,L-1]\) to the exact rational \(q(2J+1)/L\), yielding a shift with \(v+h\) no greater than the average. The two endpoint bands are disjoint for large \(q\), as required.
3. **Translation interval:** if \(T=a+s_h-s_i-s_j\) and \(T\ge(1-\delta)L\), then \(s_h\ge(1-\delta)L-N\) and \(s_i+s_j\le\delta L+N\), so all dangerous repetitions are counted by a *high* old source mark and a *low* pair. For a fixed triple and prefix mark, precisely one integer \(T\) is dangerous. Averaging counts, then deleting its high mark, is sound.
4. **Old-prefix difference collisions:** a nonzero prescribed difference has at most one ordered representation in a modular Sidon block. One deletion per positive difference of \(A\) gives the announced additional \(\binom r2\) bound. Bands exclude \(A+A\) collisions with sums involving translated block elements.
5. **Asymptotic and rational constants:** with \(\delta=1/(20r)\), \(W=(2\delta+o(1))q\), and \(|I|=(\delta/2+o(1))L\), the deletion fraction is \((32/27)r\delta^2=2/(675r)\); the maximum element is \((2-\delta/2)L\). The strict squared comparison to \(1/\sqrt2\) is exactly \(71/(5400r)+8/(455625r^2)>0\).

**Verdict:** no flaw found in these five core steps. The audit does **not** independently establish the result's worldwide novelty or externally referee its asymptotic statement.

### Independent small-field construction

`verify_axiom_prefix_independent.py` uses a **new** field and instance: \(q=101\), \(\mathbb F_{101}[u]/(u^2-2)\), primitive \(\theta=2+u\), frozen prefix \(A=\{1,2,4,8,13\}\) (\(r=5\)), theorem value \(\delta=1/(20r)=1/100\). It verifies all \(101\) Bose–Chowla marks and their 5,151 unique modular sums, checks all \(10,200\) rotations' exact endpoint population average \(W=4747/2040\), selects shift 1135 with both endpoint populations zero, selects \(T=10,098\) among the 52 admissible translations, performs **10 exact difference deletions**, and obtains \(96\) integer marks through \(M=20,080\) with all **4,656** unordered sums distinct. The finite deletion bound evaluates to \(24208061045411/2383897651200\), which exceeds 10, consistent with the source theorem. The exact coefficient-margin identity is independently evaluated at eight values of \(r\).

This is an independent model-specific witness, not a new extremal construction and not by itself proof of the all-primes assertion.

## 4. Literature and evidence boundaries

Sources: Erdős problem #64 https://www.erdosproblems.com/64 ; [Ducoffe–Dumitru September 2026](https://arxiv.org/abs/2609.28594) finite graph-size baseline; [Garcia September 2026](https://arxiv.org/abs/2609.04686) corrections; regular graph-cover and voltage-graph theory [Gross–Tucker references](https://mathworld.wolfram.com/RegularGraphCover.html). The Sidon construction uses **classical** Bose–Chowla arithmetic; adjacent studies of Sidon distribution are active, including [Tao's October 28 survey](https://terrytao.wordpress.com/2026/10/28/on-the-diameter-and-distribution-of-sidon-sets/). No same-scope novelty clearance is asserted.

**Research credits:** the finite-prefix theorem is Axiom's derivation; this review is Lemnis's independently coded bounded verification. The graph-cover obstruction and monodromy boundary are Lemnis's self-designed investigation from textbook graph-cover principles, under NIGHTFALL owner Devin J. Wright. All checks are **internal**, and mathematical priority plus external specialist review remain open.

### Reproduction

Run from this directory:

```
python3 verify_two_primary_covers.py
python3 verify_monodromy_and_towers.py
python3 verify_axiom_prefix_independent.py
sha256sum -c SHA256SUMS
```

No third-party Python packages are required. `RUN_LOG.txt` is generated from an exact replay. Source and output hashes are frozen in `SHA256SUMS`.
