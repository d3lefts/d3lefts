# Adaptive Forrelation lower bound: source-matched sign reduction

Date: 19 November 2026. Scope: v2 Section 5 provisional application. Checked for exact **unconditioned sign-Gaussian P** versus independent uniform signs U. This does not assert hardness for separately promise-conditioned YES/NO laws.

## Authoritative theorem

Aaronson–Ambainis, *Forrelation: A Problem That Optimally Separates Quantum from Classical Computing*, Section 4, Theorem 11 (Gaussian Distinguishing), original PDF pp. 17 and 21:
https://www.scottaaronson.com/papers/for.pdf

Given at most K unit test vectors, distinct vector inner products in absolute value at most kappa, distinguishing independent N(0,1) answers from responses given by projections of ONE fixed standard Gaussian vector requires

    Omega(1/kappa / log(K/kappa))

queries at constant distinguishing bias. The algorithm may select the next test vector **adaptively** based on previous responses (original paper, p. 17). Instantiate with the standard basis e_i and orthogonal Walsh–Hadamard basis H_j, so K=2N, kappa=N^(-1/2). Thus

    q_real = Omega(sqrt(N)/log N).

This is a distributional real-valued Gaussian distinguishing theorem, not merely a Boolean promise-problem lower bound.

## Exact query-preserving sign reduction

Let P_real be the law of (Z,HZ), with Z standard Gaussian in R^N. Let U_real be (Z,Z'), with independent standard Gaussians. Let Sign apply sign to all 2N coordinates. The Gaussian-sign Forrelation law is P_sign=Sign_* P_real, and the independent-uniform-sign law is U_sign=Sign_* U_real.

Claim: Every randomized adaptive Boolean decision tree making at most q coordinate queries that distinguishes P_sign versus U_sign with success at least 2/3 gives a randomized real-query decision tree making at most q Gaussian coordinate queries with EXACTLY THE SAME output distribution under the two respective hypotheses.

Proof: Simulate each Boolean input query by querying the corresponding real coordinate and returning its sign. Feed it back into the Boolean tree. The transcript, next-query choice and output are pointwise identical under the deterministic Sign coupling. Private random bits can be shared. Every Boolean query takes exactly one real query. No approximation, independence-at-posterior, union bound, or restriction to nonadaptive trees is used.

Consequently, by AA Theorem 11, for standard N=2^n normalized Walsh–Hadamard:

    R_(1/3)(P_sign,U_sign) = Omega(sqrt(N)/log N),

for adaptive randomized Boolean coordinate-query distributional distinguishing.

## Quantum witness and mixture lower bound from the simulator

Set S(F,G)=F^T H^T G/N, with |S|<=1. The standard one-query Forrelation phase-oracle algorithm yields Bernoulli acceptance with mean f_C(F,G)=(1+S)/2 up to relabeling the accepting outcome. E_{U_sign} S=0, while E_{P_sign} S=a_N=(2 sqrt(N)/pi)asin(1/sqrt(N)) >= 2/pi, by the Gaussian sign-correlation identity. Thus c=E_{P_sign} f_C-E_{U_sign} f_C = a_N/2 >= 1/pi.

If P_sign is an M-component **full coordinate** product mixture, then Q=(P_sign+U_sign)/2 has at most M+1 components. Apply the already pinned and successful (#877 run 44462691113, still unmerged) normalized quantum-circuit-to-Jensen-mixture simulator to f_C, setting epsilon=delta=c/16. It returns a deterministic estimate with failure probability at most delta under Q; the failure under each P_sign, U_sign individually is at most 2delta. Clip estimator into [0,1] and use it as randomized acceptance probability. For each distribution, the change in mean acceptance is at most epsilon+2delta. Therefore the classical distinguisher's acceptance gap is at least

    c - 2 epsilon - 4 delta = 5c/8.

This is a fixed positive constant. The classical query bound is

    O(T^6 (M+1) c^(-11/2) + T^4 (M+1)^4 c^(-10)), T=1.

Using AA's adaptive q lower bound then gives

    M+1 = Omega(min(q c^(11/2), (q c^10)^(1/4)))
        = Omega(N^(1/8)/(log N)^(1/4)),

weaker than the direct exponential information-theoretic mixture-rank bound. It is still a nontrivial illustration of the simulator.

## Scope, provenance and remaining checks

- Exact distribution pair: unconditioned Gaussian-sign P versus independent uniform Rademacher U.
- NO claim for separately promise-conditioned yes/no Forrelation distributions; conditioning alters the law and needs a different proof.
- NO original contribution claim for the adaptive Gaussian lower bound (Aaronson–Ambainis).
- Query models: Boolean symbol read versus Gaussian-real value read. The latter can implement the former with one query by sign postprocessing.
- External theorem NOT Lean-certified here; this paper-level corollary is a direct reduction.
- Before replacing v2's provisional wording, independent referee should check circuit acceptance normalization, AA Theorem 11 quantifier for adaptive randomized q, success criterion and sign-law alignment.
- The Jensen circuit-to-mixture certificate in PR #877 is a passing pinned exact-head proof, not an integrated merged Lake theorem.

Suggested manuscript sentence: "For the unconditioned Gaussian-sign law P_sign and the independent-uniform-sign law U_sign, Aaronson–Ambainis's adaptive Gaussian Distinguishing Theorem 11 implies R_(1/3)(P_sign,U_sign)=Omega(sqrt(N)/log N): any adaptive Boolean sign-query distinguisher can be simulated by a real-query distinguisher using one Gaussian query per sign. Applying Corollary 4 to their equal mixture yields M+1=Omega(N^(1/8)/(log N)^(1/4)) for an exact full-coordinate product mixture representation of P_sign, a weaker corollary than the companion paper's exponential information-theoretic bound."

Status: paper-level source-aligned deduction, not Lean or independent human reviewed.
