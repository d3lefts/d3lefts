# LEMNIS independent theorem attack — rank-conditioned phase-decision lower bounds

**30 October 2026.** NIGHTFALL Constellation, AI mathematical-audit role **Lemnis**. Research lead and publication authority: Devin J. Wright. Vesper's assignment: issue #257, original phase theorem candidate: draft PR #256; earlier finite audit role: #247. This document is an **internal mathematical proof candidate with executable arithmetic corroboration**, never a human expert referee, proof-assistant certification, worldwide priority conclusion, or manuscript release.

## Model and objective

Let \(K=\mathbb F_q\) for odd prime-power \(q\), and let \(B=(q+1)/2\). An adaptive algorithm chooses each \(K\)-linear functional \(a_t\in K^k\) as a function **only of its preceding legal square readings** and receives \(y_t=(a_t\cdot x)^2\). It must identify every \(x\in K^k\) modulo global \(\pm 1\) after at most \(m\) queries; earlier termination is permitted. No unpowered value is available. Distinguish the all-purpose lower bound \(B^m\ge(q^k+1)/2\) from the stronger rank-conditioned transcript bounds proved below.

Independent derivation and falsifier designed from the mathematical oracle **before consulting the producer's PR #256 proof internals**. After deriving the central principles, I checked the PR's claimed upper construction and cited prior art.

## Theorem 1 — exact rank-sensitive transcript capacity

Fix a **realizable** transcript \(\tau\) of \(s\) legal square observations in which all recorded outputs are nonzero. Because later coefficients depend only on preceding readings, the chosen \(s\) row vectors are **fixed across all signals compatible with \(\tau\)**. Let their row rank be \(r\).

If \(r=s\) (independent rows), the transcript contains **exactly**

\[
2^{s-1}q^{k-s}
\]

global-sign classes. Proof: each of the \(s\) nonzero square observations has two nonzero roots, all \(2^s\) sign assignments are feasible because the linear map onto \(K^s\) is surjective; each has an affine preimage of \(q^{k-s}\) vectors. Global sign pairs the entire nonzero solution set without fixed points. All adaptive row choices remain the same for this transcript.

**Rank-deficient extension:** If \(r<s\), fix any *one* legal vector of unpowered values of these \(s\) rows. Its solution set is an affine subspace of size \(q^{k-r}\). Since some reading is nonzero, no two vectors in this single affine fiber are global-sign equivalent. Thus \(\tau\) contains **at least** \(q^{k-r}\) distinguishable signal classes.

As every remaining query has at most \(B\) distinct values, a necessary condition for a correct worst-case \(m\)-query algorithm is

\[
\boxed{\ B^{m-s}\ge 2^{s-1}q^{k-s}\quad\text{if }r=s\ },\qquad
\boxed{\ B^{m-s}\ge q^{k-r}\quad\text{if }r<s.\ }
\]

These inequalities remain valid with early stopping: a tree of remaining depth \(m-s\) has at most \(B^{m-s}\) leaves.

**Corollary (first-branch lower bound).** The first useful query has nonzero row. Each of its nonzero square output branches contains exactly \(q^{k-1}\) sign classes. Thus

\[
\boxed{\ m\ge1+\lceil\log_{(q+1)/2}(q^{k-1})\rceil.\ }
\]

For \(q=9,k=12\), this rules out \(m=16\): \(9^{11}=31,381,059,609>5^{15}=30,517,578,125\), despite the global alphabet count allowing \(m=16\).

## Theorem 2 — exact previously unresolved F9 optima at k=6 and k=9

Set \(q=9\), so \(B=5\). The existing fully specified adaptive sign-packing decoder in PR #256 achieves \(k+\lceil(k-1)/2\rceil\) powered queries, including every zero/sparse signal. An unrelated F3[u]/(u²+u+2) implementation in `independent_audit.py` exhaustively reproduces all \(9^3=729\), \(9^4=6,561\), and \(9^5=59,049\) signals, plus failure/mutation controls. The upper bound for arbitrary \(k\) additionally relies on the elementary F3-basis packing proof—not those finite tests.

**(a) Six-dimensional exact optimum: \(A_9(6)=9\).** Suppose a correct eight-query adaptive protocol exists. Choose a nonzero first squared output (feasible for any nonzero first row). Along this transcript:

- A second row dependent on the first would preserve an affine fiber of \(9^5=59,049>5^6=15,625\) classes. Hence the second row **must be independent**. Taking its observation nonzero yields \(2\cdot9^4=13,122\le5^6\) classes.
- A dependent third row would preserve \(9^4=6,561>5^5=3,125\) classes. Thus the third is independent, and a nonzero reading leaves \(4\cdot9^3=2,916\le5^5\) classes.
- A dependent fourth row preserves \(9^3=729>5^4=625\) classes; an independent fourth row leaves \(8\cdot9^2=648>625\). **Both possibilities contradict the four remaining query slots.** Hence eight queries are impossible, and the known nine-query upper construction is optimal.

**(b) Nine-dimensional exact optimum: \(A_9(9)=13\).** Suppose twelve queries suffice. After a nonzero first reading, a dependent second row preserves \(9^8=43,046,721>5^{10}=9,765,625\) classes, so the second must be independent. The all-nonzero independent two-row transcript has \(2\cdot9^7=9,565,938\le5^{10}\) classes. A dependent third row preserves \(9^7=4,782,969>5^9=1,953,125\); an independent third row leaves \(4\cdot9^6=2,125,764>5^9\). **Both impossible.** Therefore twelve queries are impossible, and the existing thirteen-query decoder is optimal.

For these proofs, every selected nonzero branch is realizable: a newly independent linear form remains surjective on the previous affine solution fibers, while a dependent row is ruled out without requiring a further branch selection. No protocol is assumed to measure coordinates first. No restriction is made on allowed adaptive K-linear forms.

## Theorem 3 — general rank-forcing stopping operator

For any odd \(q\), dimension \(k\), put \(B=(q+1)/2\). Starting after one nonzero useful measurement, recursively maintain a legal all-nonzero independent prefix of length \(s\). If

\[
q^{k-s}>B^{m-s-1},
\]

a dependent \((s+1)\)st row is impossible, so it **must** be independent. If then

\[
2^s q^{k-s-1}>B^{m-s-1},
\]

we have a contradiction to an \(m\)-query protocol. If the first inequality fails, this operator is **inconclusive** (not an existence certificate). Each step is a proof-preserving rank/capacity dichotomy. This operator can be reused in other sign-orbit search problems without brute-force enumerating decision trees.

**Negative control:** If one illicitly switches the GF9 five-output square oracle to a six-output alphabet (as in a different GF16 cubic model), the critical \(k=6\) rank-four inequality reverses: \(8\cdot9^2=648\le6^4=1296\). This verifies the new bound is **oracle-specific** and cannot be transferred by analogy alone.

## Reproduction, provenance and audit gates

```bash
python3 independent_audit.py
python3 rank_branch_certificate.py
sha256sum independent_audit.py rank_branch_certificate.py REVIEW.md
```

- `independent_audit.py`: separate irreducible field representation, legal-query closure, every GF9 signal for \(k=3,4,5\), all supports and zero, rank-deficient negative control, exact 3-query \(k=2\) static design, explicitly ambiguous 4-query \(k=3\) static design.
- `rank_branch_certificate.py`: exhaustive small GF9 independent-row transcript fiber counts, dependent-row split, exact integer rank-forcing inequalities, exact information/rank bounds \(k=2,...,12\), and six-output model mutation control.
- Completeness of the **logical decision-tree argument**, not a finite brute-force tree search, establishes both optima, subject to non-author mathematical review. No independent human proof review, full Lean theorem, same-model novelty review, or authorized site/publication promotion performed.

**Status:** R1 / internal mathematical proof plus reproducible exact integer certificates. **Novelty threshold:** these might be new small-dimension query-optimality consequences, yet the counting/rank operator is elementary and related to classical algebraic decision-tree and phase retrieval theory; date-check that precise oracle and k6/k9 bounds before any global originality claim. Existing published intersecting-code results by Borello–Schmid–Scotti (JCTA 2025, arXiv:2406.04034) establish the static coding side. Author of internal role audit: AI persona Lemnis; no fictional agents treated as human referees.

**Falsifier for Axiom/Vesper:** exhibit an eight-query all-signal GF9²-power k6 decision tree; or a twelve-query k9 tree; or a *single legal* nonzero prefix for which the claimed exact \(2^{s-1}q^{k-s}\) count fails despite independent rows. Axiom should challenge adaptive-coefficient conditioning; Ryev independently enumerate the rank-fiber formula in a second GF9 model and construct Lean small proofs; Vesper check prior art and control public-facing claim scope. Next cross-problem transfer: rank-sensitive branch lower bounds for arbitrary scalar orbits \(H\) with \(|H|\mid(q-1)\) and oracle \(t^{|H|}\), where phase compatibility of dependent rows requires more careful analysis.