# Independent closure attempt: dyadic fixed point and weighted mixture tournament
Date: 2026-11-19. Status: **author-side mathematical proofs, not independent non-author review or Lean certification.**

This file upgrades the explicit mathematical accounting for the two gaps identified in
`INDEPENDENT_AUDIT_20261119.md`. Its conclusions are conditional on the
stated BDST strong simulator and standard coherent finite-alphabet query model.

## Proposition A: explicit dyadic block length

Fix t>=1, quantum round count d>=1, 0<eps<=1/2, 0<eta<1/2,
product atom margin 0<c<=1, and k as in the binomial failure-event
approximator. Suppose BDST's theorem, applied after an m-bit Boolean
pullback, supplies a depth D(m) satisfying

    D(m) <= C_d * (m Z)^B,
    Z := max(1, 2t * max(1, log(1/eta)) / eps),
    C_d >= 1, B >= 1 integer,

with C_d=2^{O(d^2)} and B=O(d) (here the round parameter in BDST is
2d, absorbed into these constants). Define

    H := 2k * (2t + C_d * Z^B)
    A := max(0, log_2(H/(c*eta)))
    m := ceil( max(1, log_2(2/c), 2*A, 4*B*log_2(4*B)) ).

**Conclusion:**

    2^(-m) <= min(c/2, c*eta / ( 2k*(2t+D(m)) )).

**Proof.** Because m>=1, D(m)<=C_d*m^B*Z^B and 2t<=2t*m^B,
so h(m):=2k(2t+D(m))<=H*m^B. For B>=1 let
m0=4B log_2(4B). At m0 one has

    B log_2(m0) <= 2B log_2(4B) = m0/2

since log_2(log_2(4B))<=log_2(4B). The function
x/2 - B log_2(x) has positive derivative for x>=m0, so
B log_2(m)<=m/2. The chosen m>=2A gives
m-B log_2 m >= A. Therefore

    h(m) 2^(-m) <= H 2^(-m+B log_2 m)
                  <= H 2^(-A) <= c*eta.

The other bound follows from m>=log_2(2/c). QED.

Thus, without hiding a circular definition,

    m = O(d^2 + d*log(t*log(1/eta)/eps) +
          log(1/(c*eta)) + log(1/eps) + d*log d)

under BDST's stated asymptotics. For fixed d, `m` grows logarithmically
in 1/c and 1/eta (up to nested logarithms). Substitution into D(m) gives
the broad claimed form `2^{O(d^2)}(t log(1/(c eps eta))/eps)^{O(d)}`,
with constants absorbed by the O(d) exponent; a reviewer should audit
the exact source statement of BDST and any dependence hidden in its
constants before journal submission.

## Proposition B: weighted conditional component duel

Let `T_1,...,T_M` be deterministic whole-symbol trees, each of worst-case
depth `D`, such that for each product law `P_i`,

    Pr_(P_i)(|f-T_i|>eps) <= eta.

Run all `T_i` on the same input and let `ell` denote the entire
joint preliminary transcript. Let `p_i(ell)` be its probability under
P_i, `a_i(ell)` the output of T_i at the transcript, and
`alpha_i(ell)=Pr_(P_i)(|f-a_i(ell)|>eps | ell)`.
The unused coordinates retain independent original marginals. Therefore

    sum_ell p_i(ell)*alpha_i(ell) <= eta.

Fix a pair i,j. On transcripts with
`|a_i(ell)-a_j(ell)|>=4eps`, the restricted function is of
coordinate degree <=2t, the concentration centers are in [0,1] after
clipping, and the Step-3 separation margin satisfies
`Delta(ell)>=eps`. Split the unqueried coordinates into
`L(ell)` with bias gaps at least
`gamma0=4eps*c/(pi*2t)`, versus its complement. Put

    K=ceil(pi^2*(2t)^2*log(1/eta)/(8*eps^2*c^2)).

For |L(ell)|<=K, use a weighted likelihood-ratio test based on the
L-coordinates, with weights p_i(ell),p_j(ell). Its joint conditional
Bayes risk obeys

    e_ij(ell)
      <= min(p_i(ell),p_j(ell)) *
         sum_x min(P_i(x_L|ell),P_j(x_L|ell))
      <= [p_i(ell)*alpha_i(ell)
          +p_j(ell)*alpha_j(ell)] / eps.

The second inequality follows from Lemma 1's weighted pointwise
failure-mass argument and Delta>=eps.

For |L(ell)|>K, choose any K of the large-gap coordinates.
By the product Hellinger affinity bound the conditional Bhattacharyya
coefficient is at most eta. The same weighted likelihood-ratio test
then satisfies

    e_ij(ell) <= eta * sqrt(p_i(ell)*p_j(ell)).

The pair-specific queries are chosen *after* the preliminary T_i
transcripts, but *before* and independently of all other duel outcomes.
Summing over all preliminary transcripts and applying Cauchy-Schwarz,

    Pr_(P_i)(test outputs j on a decisive transcript)
      + Pr_(P_j)(test outputs i on a decisive transcript)
      <= (eta+eta)/eps + eta*sum_ell sqrt(p_i(ell)*p_j(ell))
      <= eta * (1+2/eps).

No bound on conditional failure at a single rare transcript is needed.
For a true component theta, its simulator is eps-accurate except with
probability eta. Conditioned on its accuracy and on winning every
decisive pair involving theta, theta is undefeated and every undefeated
component has predicted value within 4eps of a_theta. Thus any
undefeated candidate predicts within 5eps of f. A union bound under
the mixture `nu=sum_theta w_theta P_theta` gives failure at most

    eta + (M-1)*eta*(1+2/eps).

This is ≤delta by choosing, for instance,

    eta <= delta / (2*M*(1+2/eps)).

The looser paper choice `eta=eps*delta/(4M^2)` is also safe for
M>=1 and 0<eps<=1/2. It is not necessary to identify the true latent
component on every input: components predicting nearby outputs are
intentionally left unresolved.

**Query bound:** at most MD + `binom(M,2)K` whole-symbol queries.
The pairs can be processed sequentially for query counting while
precomputing their test-selection rules from the same preliminary
transcript, so previous duel outcomes never bias the pair analysis.

## Remaining independent-certification gates

1. Recheck BDST's quantitative constants and precise d-round query model;
   the `C_d,B` domination is an abstraction of its theorem, not a
   separately machine-checked bound.
2. Formalize the Bernstein interpolation and the product-affinity
   tensorization *from actual product laws*, not just their abstract
   scalar hypotheses.
3. Reconstruct the coherent quantum block pullback formally for
   heterogeneous finite alphabets (and the fixed-seed decoded tree).
4. Have a researcher other than the proof's author critically review
   Propositions A and B and cross-check the novelty search.
5. Rebuild the manuscript/PDF only after technical corrections are
   integrated and all claims visibly labeled with their real status.
