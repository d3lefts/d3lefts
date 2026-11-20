# NIGHTFALL short-sum / bent-frame theorem — author-side v0.1

Date 2026-11-19 ET. **Status:** independent author-side mathematical argument with separate exact finite replay. **Not Lean certified, externally reviewed, or priority-cleared. Conjecture E remains open.**

## Provenance and proof contract

Original linear testbed: research/nightfall/structural_information/LINEAR_DISTRIBUTIONS_20261119.md, commit fb993f31b430519cc52d594fa199a6d58c6942e9. The source defines the row law X_i=<g_i,s> for uniform s in F2^m, and a (c,c',h)-frame B with every g_i a sum of <=c frame vectors, every b in B a sum of <=c' original rows, and no nonempty dependency of <=h B-elements. The complete two-sided necessity statement is a conjecture there; do not substitute a proof of a subcase for it.

**Only deep external additive-combinatorics input:** Sanders's quasi-polynomial Bogolyubov–Ruzsa theorem. An explicit source check is the exposition by Ben-Sasson, Ron-Zewi, Tulsiani, and Wolf, Theorem 1.4, page 3, https://eccc.weizmann.ac.il/report/2012/029/download/; original Sanders https://arxiv.org/abs/1011.0107. The theorem states: if |R+R|<=K|R|, then a subspace V is contained in the fourfold sumset and |V| >= |R| exp(-O(log^4(2K))). We do NOT infer any local frame from the PFR coset-cover theorem.

Elementary ingredients independently derived below: Bernstein–Vazirani phase extraction, the flat Walsh spectrum of a quadratic bent function, affine posterior fibers of parity decision trees, and a pivot-word property of binary subspaces. Their individual mechanisms are known and not claimed novel.

## Theorem I: a subspace in kR forces a k-query quantum advantage

Let R be a nonempty indexed family of F2^m row vectors, and let kR contain all sums of EXACTLY k rows (repetitions allowed). Suppose V <= F2^m, V subset kR, and r=dim V. Set r'=2 floor(r/2) and assume r'>=8.

Then a fixed nonuniform k-query quantum bit-oracle algorithm exists whose acceptance probability is 0 or 1 for every input X=Gs on the source support. Against this target, any randomized adaptive classical algorithm querying at most q rows, even if strengthened to query arbitrary linear forms in s, has error probability at least

  (1 - 2^(q-r'/2))/2

when output accuracy is strictly better than 1/2. Therefore q<=r'/4 gives error >=3/8, and classical constant-error query complexity is Omega(r).

**Exact quantum construction.** Choose an r'-dimensional V'<=V with basis v_1,...,v_r'. For each v in V', fix one exactly-k-row representation v=g_{i_1(v)}+...+g_{i_k(v)}; including v=0 is harmless, as 0 in kR by assumption. For y in F2^r', let v(y)=sum_j y_j v_j. A coherent reversible lookup computes the k original row indices for v(y). Apply k phase queries to the observed bit oracle, uncomputing each selector register. The phase is (-1)^(v(y) dot s)=(-1)^(y dot z), where z_j=v_j dot s. A final Hadamard transform yields z **exactly** (Bernstein–Vazirani). Accept iff

  h(z)=sum_{j=1}^{r'/2} z_{2j-1} z_{2j} mod 2

equals 1. This is an ordinary scalar acceptance-probability task, not an unsupported multi-output simulation. The row-representation lookup may be exponentially expensive in gates; no time-efficiency claim is made.

**Classical lower bound.** The linear map s -> z has full rank r'; z is initially uniform. At every q-query adaptive parity transcript, the original secret s lies uniformly in an affine flat cut out by <=q linear equations. The image distribution of z is uniform on an affine flat A of codimension t<=q. This holds even when the queried linear forms are chosen adaptively and lie outside R. Let F(z)=(-1)^h(z). Its Walsh transform factorizes over the r'/2 independent two-bit quadratic factors, giving

  |Fhat(u)|=2^(-r'/2) for EVERY character u.

For a nonempty affine flat A=z0+H, normalized indicator Fourier expansion yields

  E_{z in A} F(z) = sum_{u in H_perp} (-1)^(u dot z0) Fhat(u),

so |E_{z in A} F(z)|<=2^(t-r'/2)<=2^(q-r'/2). Consequently the optimal Boolean label prediction on this transcript succeeds with probability at most (1+2^(q-r'/2))/2. Any scalar prediction within less than 1/2 of the 0/1 acceptance probability necessarily classifies h, so the identical lower bound applies to approximating the acceptance probability. Averaging over transcripts and private randomness proves the claim. If q<=r'/4 and r'>=8, the failure is >=3/8. This proof does not assume Conjecture E or Route 1.

## Theorem II: short-sum subspaces are OBSTRUCTIONS to cheap high-girth frames

Let V subset kR have dimension r, and let B be a (c,c',h)-frame for R with c,c'>=1 and h>=3kc. Then

  dim V <= k c, and c c' >= r/k.

**Proof.** Each v in V is the sum of exactly k rows and therefore the sum of <=kc frame vectors. Choose a representation sigma(v) as a subset of B with <=kc elements after mod-2 cancellation. For any u,v in V, the symmetric difference of sigma(u), sigma(v), and sigma(u+v) has sum zero and size <=3kc<=h. By the frame girth assumption it is empty. Thus sigma: V -> F2^B is a LINEAR injection, and every word in its image has Hamming weight <=kc. Any binary linear subspace of dimension r has a word of weight at least r: project to r linearly independent pivot coordinates and choose the vector with all these coordinates 1. Hence r<=kc. As c'>=1, the product bound follows.

For the exact frame threshold from the pinned linear-distribution note, choose epsilon=delta=1/4, T>=1. Its smoothing cutoff k_phi=ceil[(2/(9 epsilon^4)) ln(8/delta)]=198, so h(2cT)=2k_phi max(2cT,D)>=792cT>=12c. Consequently for k=4 every admissible source frame satisfies

  Lambda_T(R) >= dim V / 4.

This is a NECESSARY frame-cost signature from short-sum structure. The reverse implication is not proved.

## Corollary III: small doubling produces both obstructions simultaneously

Let R be nonempty, K=|R+R|/|R|, and choose the Sanders subspace V subset 4R. Then

  dim V >= log2|R| - O((log(2K))^4).

If the positive right side is at least 9, Theorem I gives a **4-query** quantum predicate with Omega(log|R|-O(log^4(2K))) classical row-query complexity, and Theorem II gives

  Lambda_T(R) >= (log2|R|-O(log^4(2K)))/4

at the fixed accuracy and confidence parameters stated above. In particular if K=O(1), both the quantum-vs-classical separation and the frame-cost lower bound grow as Omega(log|R|).

Thus the bounded-doubling case does NOT need a cheap-frame theorem. Small doubling actually forces EXPENSIVE frames through a short-sum subgroup, and supplies an explicit quantum witness. The larger Conjecture E remains open where K grows enough that the Sanders bound becomes vacuous, or where costs may arise from qualitatively different structures. This corollary is a composition of known additive-combinatorics and parity-query facts; novelty and priority have not been checked exhaustively.

## A decisive counting barrier for the middle regime

There is a model-independent capacity restriction on ANY short-sum/Bernstein–Vazirani proof strategy. If the indexed row family has n entries, the number of possible ordered k-term sums is at most n^k. Hence

  V subset kR, dim V=r  ==>  2^r<=|kR|<=n^k,
  so r<=k log2 n.                                                   (9)

In particular, for n=poly(m), a constant-query BV subspace witness can force at most O(log m) classical queries. Even taking k=polylog(m) gives only polylog(m)-dimensional V and hence at most a polylogarithmic classical lower bound via Theorem I. To obtain a BV witness of dimension Omega(m^a) from polynomially many rows would require k=Omega(m^a/log m) queries, not polylogarithmically many.

This is a rigorous **proof-strategy barrier** directly relevant to Conjecture E: if its frame cost L grows as a polynomial in the ambient rank m while the input has only polynomially many rows, then a polylog(L)-query quantum witness requiring L^Omega(1) classical queries cannot arise solely by invoking a large V subset kR and a bent/BV predicate. It must use a different quantum mechanism, a different structural certificate, or Conjecture E is false. None of these alternatives is resolved here.

## Middle-regime counterexample surface: graph-edge rows

Let R be rows e_u+e_v from edges in a graph on v vertices. A sum of k edges has vertex Hamming weight <=2k. Any dimension-r subspace contains a vector of weight >=r (same pivot lemma), hence

  V subset kR, V a subspace  ==>  dim V <= 2k.

Therefore a growing-dimensional fourfold-sumset subspace is IMPOSSIBLE for these row families, independent of graph size. Graphs with many local short cycles (e.g. rectangular grids) are a useful test family for a high-Lambda/no-large-subspace obstruction. We have NOT shown that their optimized Lambda_T diverges, nor that they have or lack quantum query advantage. This graph observation attacks the short-sum/BV PROOF STRATEGY, not Conjecture E itself.

Exact basis-frame calibration in rank 5: cycle C6 has minimum c*c'=5, 2x3 grid has 3; in rank 4: K2,3 has 3. The minima were obtained by exhaustive enumeration of all independent frame bases of the full span, using exact breadth-first search for reverse row cost. They apply in the high-h finite setting where any admissible frame must be an independent basis. They are NOT asymptotic estimates.

## Independent audit and stop rule

Exact reproducible checker: scripts/check_shortsum_bent_frames.py. It verifies all Walsh coefficients (integer arithmetic) at ranks 2,4,6,8,10,12, enumerates ALL codimension <=2 affine flats at rank 8 (10,795 dual two-spaces), confirms fourfold sumset coverage for R=F2^m minus zero at m=3..7, and exhausts the stated small-graph bases. No sampling, tolerances or approximate rank tests are used. Finite tests do not prove the global theorem; the symbolic Walsh, pivot and Fourier arguments above supply it.

Conjecture E status: OPEN. End-to-end Lean: NOT STARTED for these two new theorems. Attribution: Sanders (additive theorem), Bernstein–Vazirani (phase algorithm), classical bent-function Fourier theory, source authors (NIGHTFALL structural-information-theory). No publication or merge permitted without independent review.

**Next cheapest decisive experiment:** for graph-cut row systems with fixed T and many short cycles, compute / lower-bound the unrestricted frame profile allowing every synthetic vector in span(R), not merely spanning-tree edges; then independently search for a quantum advantage not explained by a bounded-short-sum subspace. If neither direction is decisive, switch operator family to matroid circuit structure / LDPC-style local dependency decomposition.
