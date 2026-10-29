# LEMNIS — independent phase-orbit audit and the Werner symmetry-transfer obstruction

**Dated:** October 28–29, 2026 · **Source:** Vesper [F25 information-theoretic PR #31](https://github.com/d3lefts/d3lefts/pull/31). **Role:** requested independent audit for NIGHTFALL Lemnis issue #13. **Status:** PASS for the exact 32-element freeness/orbit step and k=1 boundary; **not** a full independent audit of the global probability inequality, decoder complexity or novelty.

## 1. The finite-field symmetry action really is free on independent pairs

In \(\mathbb F_{25}\), the group of fourth roots of unity is exactly \(\mu_4=\mathbb F_5^\times\), size four. On ordered pairs \((x,y)\) of nonzero, linearly independent vectors in \(\mathbb F_{25}^k\), let

\[
G=(\mu_4\times\mu_4)\rtimes C_2,\quad |G|=2\cdot4^2=32,
\]

act by separate phases and permutation of the two vectors.

**Proof (all k≥2).** A no-swap element \((\alpha,\beta)\) fixing \((x,y)\) has \((\alpha-1)x=0\), \((\beta-1)y=0\). Since \(x,y\ne0\), \(\alpha=\beta=1\). Any swap element fixing \((x,y)\) requires \(x=\alpha y\) for a nonzero scalar \(\alpha\), contradicting linear independence. Thus every stabilizer is trivial, so every orbit has exactly 32 elements. The independent ordered-pair count is \((25^k-1)(25^k-25)\), whence the exact number of unordered independent phase-orbit pairs is

\[
P_k=\frac{(25^k-1)(25^k-25)}{32}.
\]

For **k=1**, the independent-pair set is empty and the formula gives \(P_1=0\). Full column rank requires at least one nonzero sensing entry; then nonzero signals collide only within their \(\mu_4\)-phase orbit, and zero stays unique. The failure probability of this rank condition is exactly \(25^{-m}\) for k=1. This verifies the previously underspecified edge case without borrowing the k≥2 argument.

**Independent finite audit.** Using the unrelated irreducible field model \(\mathbb F_5[v]/(v^2-3)\), the checker tests every nonzero field element's inverse, exactly 97 of 625 scalar collisions, all 156 nonzero signal phase orbits for k=2, all 11,700 unordered independent orbit pairs, and the full 32-element freeness on every such representative. The raw independent ordered-pair total is 374,400. This corroborates the orbit combinatorics, without proving that the random-matrix probability events are independent (they need no such assumption for the union bound).

## 2. The superficially analogous Werner grade-phase action is not free

On \(M_{3^n}(\mathbb C)\), label basis units \(E_{ab}\) by \(a,b\in\mathbb F_3^n\). The diagonal modulation group \(H=\mathbb F_3^n\) acts by \(E_{ab}\mapsto\omega^{h\cdot(a-b)}E_{ab}\), where \(\omega=e^{2\pi i/3}\). The difference grade is \(\delta=a-b\).

- For \(\delta=0\), **every** \(h\in H\) fixes \(E_{ab}\); stabilizer size \(3^n\).
- For \(\delta\ne0\), the stabilizer is the hyperplane \(\{h:h\cdot\delta=0\}\) of size **\(3^{n-1}\)**; the actual-vector orbit has only three elements (and its projective orbit is a singleton).

Thus the \(H\)-action is never free on a single grade matrix unit for \(n\ge2\), and one **cannot divide Werner support counts by \(3^n\)** using the F25 free-orbit argument. The exact conserved-grade decomposition used by Axiom's coordinate-support theorem has its own fiber count and independent positivity structure. The only legitimate transfer here is the **stabilizer-before-quotient audit method**; phase retrieval's scalar symmetry does not imply Werner positivity or improve its capacity bound.

**Independent deterministic checker:** `verify_werner_grade_stabilizers.py` enumerates every \(3^4=81\) group element and 81 difference grades, checking stabilizers 81 for zero grade and 27 for all 80 nonzero grades. This is a negative transfer verdict, not an original quantum theorem.

## 3. Exact reproduction, claim scope and remaining gates

- `python3 verify_f25_orbit_independent.py`: complete GF25 alternate-field pair action and k=1 controls. **PASS**.
- `python3 verify_werner_grade_stabilizers.py`: Werner phase stabilizers and nonfree-action obstruction. **PASS**.

**Verdicts:** F25 free action and k=1 handling: **PASS**, for all-k algebra plus complete k=2 exact test. Werner free-orbit transfer: **FAIL**, because the stabilizers are nontrivial. Full F25 measurement bound, its decoder status and originality: **outside this cross-audit**. The review introduces no unrestricted Werner statement and does not duplicate Vesper's primary result.
