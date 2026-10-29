# Deterministic adaptive finite-field decoder — flagship dossier

**NIGHTFALL / PHASESHIFT · 29 October 2026**  
**Research proposal:** Axiom · **Program lead:** Devin J. Wright · **Follow-up proof audit and generalization:** NIGHTFALL review session (29 October 2026)  
**Evidence tier:** Complete algebraic proof candidate and independently coded exact finite checks. **External mathematical referee and same-model priority review remain open.** Flagship designation is editorial, not a claim of established publication priority.

## Phase-alphabet unification — finite subgroup power oracles (29 October 2026)

A new projective-alphabet criterion subsumes the established extension-degree basis construction and characteristic-three cancellation packing. In the more general oracle Phi_H(z)=z^{|H|}, where H is a specified multiplicative subgroup of F_q, additive shifts of H provide verifiable conditions for recovering **up to r relative phases per second-round measurement** over F_(q^r). Its two-round query count is k+ceil(max(s-1,0)/r) for certified subgroup/shift combinations; for 2<=k<=r+1 this attains the adaptive information lower bound.

The theorem includes cubic-phase examples over F_7, a quartic-phase two-shift cover over F_13, a fifth-power two-shift cover over F_31, and a sufficient existence condition q-1>|H|(|H|-1)^2. A standalone checker passed 11,500 exact signal reconstructions across nine subgroup models, plus exhaustive small-field phase-map classifications. The full-phase original oracle remains z^(q-1): subgroup results for smaller H use **different powers** and cannot be described as same-oracle improvements. Independent refereeing and same-model priority review remain pending.

- [Unified theorem, proofs, and exact collision criterion](PHASE_ALPHABET_PROJECTIVE_PACKING_20261029.md)
- [Standalone exact verifier](verify_unified.py) — run python3 verify_unified.py

## New independent result · Characteristic-three cancellation packing (29 October 2026)

For **base field q=3** and extension \(K=\mathbb F_{3^r}\), the earlier bound is strengthened to **\(m=k+\lceil\max(s-1,0)/r\rceil\le k+\lceil(k-1)/r\rceil\)** queries, with the same two-round oracle and exact reconstruction guarantee. A single mixed measurement encodes **r relative signs** by making its basis coordinates vanish exactly when a relative sign disagrees with the anchor. This is optimal for one anchored mixed query: \(r+1\) unknown independent signs force an unpowered linear collision. The new construction is globally query-optimal for \(2\le k\le r+1\), as well as further cases satisfying the exact counting lower bound.

**New independent test:** 54,461 exact reconstruction checks over F9, F27, F81, including 15,259 cases with strictly fewer queries than the earlier extension-degree count, and six constructive one-query obstructions. Source novelty and external mathematical refereeing remain open.

- [Complete cancellation-packing theorem, proof and sharp one-query obstruction](CHARACTERISTIC_THREE_CANCELLATION_20261029.md)
- [Standalone exact finite-field verifier](verify_q3_cancellation.py) (run: `python3 verify_q3_cancellation.py`)

The general \(q>2\) guarantee of \(k+\lceil(k-1)/(r-1)\rceil\) remains valid; the sharper expression above applies **only to q=3**.

## Earlier general result · Extension-degree packing (29 October 2026)

**New strongest theorem candidate:** for \(K=\mathbb F_{q^r}\), \(r\ge2\), \(q>2\), every signal with support size \(s\) is deterministically recovered up to \(\mathbb F_q^\times\) using exactly

    m = k + ceil(max(s-1, 0)/(r-1)) <= k + ceil((k-1)/(r-1))

powered linear measurements in two rounds. For q=2, the global optimum is k queries.

The original 2k-1 bound below is recovered at extension degree r=2. **This strictly improves the worst-case measurement count for r>=3, k>=3.** One second-round measurement now recovers up to r-1 distinct relative phases by scaling coordinate representatives onto an extension-field basis.

**Global adaptive optimality:** when q>2 and 2<=k<=r, **k+1 is optimal among all deterministic adaptive protocols**, by an exact decision-tree counting identity. A classical complement-property-style obstruction also forces every fixed nonadaptive design in the **same powered-field measurement model** to use at least 2k-1 rows. This gives a strict adaptive/nonadaptive separation for r>=3,k>=3. The older random/nonadaptive LLL phase-retrieval program remains a distinct problem with distinct assumptions.

**New exact audit:** 332,086 independently coded reconstruction tests and 3,000 constructive collision certificates pass, including q=2 and q=4 characteristic-two cases. Two independent self-contained checkers use integer polynomial arithmetic for prime-base extensions and binary polynomial arithmetic for the q=4 subfield. Same-model publication priority and external proof refereeing remain open.

- [Full theorems, proofs, exact optimality, and source-attributed nonadaptive obstruction](EXTENSION_DEGREE_PACKING_20261029.md)
- [Independent extension-degree checker](verify_extension_packing.py) (run: python3 verify_extension_packing.py)
- [Independent characteristic-two F4-subfield checker](verify_characteristic_two_subfield.py) (run: python3 verify_characteristic_two_subfield.py)

**Archival note.** The next section records the initial 2k-1 decoder milestone as originally published; the batched extension-degree result above supersedes its general measurement-count claim.

## Result at a glance

Let (L=\mathbb F_q), let (K=\mathbb F_{q^r}) with (r\ge2), and let the unknown signal be (x\in K^k). A permitted query chooses (a\in K^k) and returns ((a\cdot x)^{q-1}\in K). Query vectors in round two may depend on the outputs of round one.

**Claim (adaptive reconstruction):** There is an explicit deterministic two-round decoder recovering every (x\in K^k) up to a single global factor in (L^\times), with precisely (k+\max(s-1,0)\le2k-1) queries, where (s=|\operatorname{supp}(x)|). All reconstruction uses finite-field linear algebra and has polynomial bit complexity in (k,r,\log q) for an explicitly represented field. Zero coordinates and adversarially chosen input signals are included.

This **does not** improve the measurement count of NIGHTFALL's separate *random nonadaptive* fourth-power lattice-decoding campaign under the same hypotheses: it uses a different, adaptive sensing model and a subfield phase quotient. For the quadratic extension (\mathbb F_{25}/\mathbb F_5), its measurement is a fourth power; the query count is (2k-1).

## Algebraic mechanism and proof

1. **Read the coordinate classes.** Query (y_j=x_j^{q-1}), for (j=1,\ldots,k). These reveal the exact support. For each (y_j\ne0), solve the **(L)-linear homogeneous equation** (z^q=y_jz) in the (r)-dimensional (L)-vector space (K). Its nonzero solution set is exactly (x_jL^\times), so deterministic row reduction gives a representative (r_j\ne0) with (r_j^{q-1}=y_j).
2. **Select an anchor and separate phases.** If all outputs are zero, return zero. Otherwise let (t) be the first nonzero coordinate and fix any (\alpha\in K\setminus L). For each nonzero (j\ne t), set (c_j=1) when (r_t/r_j\notin L), and (c_j=\alpha) otherwise. Then (r_t) and (c_jr_j) are (L)-linearly independent. Query (w_j=(x_t+c_jx_j)^{q-1}).
3. **Recover relative phases.** Solve (z^q=w_jz) for any nonzero (z). Write (x_t=\gamma r_t), (x_j=\gamma\eta_jr_j), with (\gamma,\eta_j\in L^\times). The returned root lies on (L^\times(r_t+\eta_jc_jr_j)); consequently its **unique** decomposition (z=A r_t+B c_jr_j) has (A\ne0) and (B/A=\eta_j). Assemble \(\hat x_t=r_t\), \(\hat x_j=\eta_jr_j\), zero elsewhere. Then \(\hat x=\gamma^{-1}x\).

Exactly (k) first-round and (s-1) second-round measurements are used. Solving Frobenius kernels and (r\times2) systems is deterministic polynomial-time field arithmetic.

### Quadratic-extension shortcut

For (K=\mathbb F_p[\alpha]), (\alpha^2=D) a non-square, any nonzero ((p-1))-st power (y=c+d\alpha\) has norm one. A representative of (z^{p-1}=y) is (z=1) for (y=1), and otherwise (z=Dd+(1-c)\alpha). This identity follows by checking (z^p=yz). The specialized verifier uses exact prime-field pair arithmetic.

## Information lower bound and its limit

One query returns at most (M=1+(q^r-1)/(q-1)) different values. There are (S=1+(q^{rk}-1)/(q-1)) input classes modulo global (L^\times). A deterministic adaptive decision tree therefore needs (M^m\ge S), regardless of its choice of future rows. When (r=2) and (q=p\ge5), elementary arithmetic gives (S>(p+2)^{2k-2}) for (k=1,2,3), so **(2k-1) is worst-case optimal in these dimensions**. Optimality for all (k\ge4) is open. These are information counts, not a claim of noise robustness.

## Independent finite audit

Run `python3 checker.py`. Its quadratic-field implementation exhaustively checks every input over:
- (\mathbb F_{25}), (k=1,2,3): 25 + 625 + 15,625 vectors.
- (\mathbb F_{49}), (k=1,2): 49 + 2,401 vectors.

**18,725 / 18,725 exact reconstruction tests pass**, including zero support, full support, projective equivalence, and measurement counts. The checker is independent of the initial Axiom prototype; it is a finite exact test, not a replacement for a mathematical referee.

A second independent finite-field pair checker was run on all 2,880 nonzero ordered anchor-neighbor configurations across the quadratic fields. Its artifact is preserved in the 29 October frozen internal ZIP, pending a permanent public archive mirror.

## Related sparse-prime Cauchy result (distinct model)

Axiom's separate sparse protocol uses fourth powers in (\mathbb F_p), (p\equiv5\pmod8), (p>19), (p\ge k+2d), with (4d-1) adaptive queries. Its original uniform relative-phase separator searched coefficients (1,\ldots,19). An independent integer-norm argument sharpens the menu to **`{1,4}`**. Run `python3 separator_checker.py` to reconstruct the 144 Gaussian-integer collision checks and possible prime divisors. This improves coefficient selection while leaving the (4d-1) query bound unchanged.

## Evidence, attribution, and publication gates

- **Validity:** algebraic argument supplied; non-author proof review pending.
- **Computational audit:** the public exhaustive checker independently reruns exactly; finite fields and dimensions are explicitly limited.
- **Priority:** related work includes Alexeev–Bandeira–Fickus–Mixon, *Phase Retrieval with Polarization* (2014), DOI 10.1137/12089939X; Charikar–Wu–Ye, *Adaptive Discrete Phase Retrieval* (2020), DOI 10.1137/1.9781611976014.9; and earlier finite-field powered-interpolation methods. A focused same-model novelty audit remains outstanding.
- **Open problems:** optimal query counts for (k\ge4); adversarial error correction with additive redundancy; same-model nonadaptive construction; extended-field root extraction implementation edge cases.
- **Attribution:** Axiom proposed the adaptive decoder; the 29 October review derived the general extension and separately audited the Cauchy coefficient menu. Research program and project leadership: Devin J. Wright. Include original source contributors on further publication.

No unreviewed claim is labeled a theorem accepted by the community, a competitive record, or a novel published result.