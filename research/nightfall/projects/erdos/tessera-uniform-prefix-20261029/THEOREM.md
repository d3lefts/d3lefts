# TESSERA / finite Sidon-prefix grafting theorem candidate (2026-10-29)

**Status:** internally proved quantitative extension; exact finite adversarial tests passed; external proof referee and novelty review PENDING. Erdős #44 and #329 remain OPEN. This gives arbitrarily large finite extensions, NOT nested extensions at a fixed improved coefficient.

## Theorem

For any fixed integer Sidon set A in [1,N], m=|A|>=1, arbitrarily large finite Sidon extensions C containing A exist with

    |C| / sqrt(max C) >= c_m - o_A(1),
    c_m = (1 - 1/(216m)) / sqrt(2 - 1/(32m)) > 1/sqrt(2).

At m=5 the lower coefficient is approximately 0.707558477878, versus 0.707106781187. No improvement in the known INFINITE-sequence bound follows, because c_m decreases to 1/sqrt(2) as m grows.

## Exact finite lemma and complete proof

Let D ⊂ Z/vZ be a modular Sidon set of K elements (every ordered nonzero modular difference unique). Let A be as above, v-h>2N, h<v/4 and 2(h+N+1)<v. Put

    L=h+N+1; t=floor(h/2)+1; R=2KL/v;
    E=(m/t)*((2/27)*R^3+(1/8)*R^2).

There is a cyclic rotation D_c, a translation T in [v-h,v-ceil(h/2)], and a subset D' ⊆ D_c with at most binom(m,2)+floor(E) deletions, for which A ∪ (T+D') is Sidon, contained in [1,2v-ceil(h/2)-1].

**Proof.** The two disjoint boundary intervals [0,L-1] and [v-L,v-1] contain an expected total R members of a uniformly randomly rotated D. Choose a rotation with lower and upper counts u,w satisfying u+w≤R. An equality a+(T+z)=(T+x)+(T+y) forces T=a+z-x-y. For admissible T this forces x+y≤h+N-1 (so x,y are in the lower interval) and z≥v-h-N (so z lies in the upper interval). Each old mark a, unordered pair {x,y}, and z determine at most one T, hence across all t translations the total number of such mixed collisions is at most m*u(u+1)*w/2. Since u²w≤4(u+w)³/27 and uw≤(u+w)²/4, some T has at most floor(E) mixed collisions. All old-old and new-new sums are individually distinct, and the old-old range lies strictly below the others. A collision between two different old-new representations forces x-y=a_j-a_i, which has at most one source pair for each unordered distinct old pair by modular Sidon uniqueness; at most binom(m,2) such collisions occur. Delete one participating new source point per collision. No new equalities arise from deletion; all old points remain. The size and endpoint follow.

Now use Singer cyclic (v,K,1) difference sets with v=q²+q+1, K=q+1, along unbounded primes q. For any FIXED m,N and FIXED 0<epsilon<1/4 choose h=floor(epsilon v). Then R=(2epsilon+o(1))K, t=(epsilon/2+o(1))v, E/K=(32/27)m epsilon²+o(1), and max(C)≤(2-epsilon/2+o(1))v. Therefore the finite-extension coefficient is at least

    [1 - (32/27)m epsilon²] / sqrt(2-epsilon/2).

Choosing epsilon=1/(16m) yields c_m. Strict superiority over 1/sqrt(2) follows EXACTLY from

    (1-1/(216m))²-(1-1/(64m))
      =11/(1728m)+1/(46656m²)>0.

## Verification, scope, and sources

Complete reproducibility archive: NIGHTFALL_Tessera_Uniform_Prefix_Extension_20261029.zip (originating conversation). Standard-library independent checker reconstructs the q=1009 Singer source, verifies all 1,019,090 nonzero modular differences, all rotations' boundary counts, two independent integer-collision oracles, and the 1005-mark repaired set with 505,515 distinct pair sums. A separate exhaustive checker passes 551 small-case variations with exact rational bounds. A coding error treating projective order as multiplicative identity was detected, corrected and replayed.

**Open gates:** Non-author proof audit, dated comprehensive prior-art search, independent originality evaluation. Singer's construction and the boundary averaging facts are classical; any priority claim is restricted to the quantitative grafting lemma and requires outside review. The stronger |A|=3 perfect-difference-set embedding is known from Will Sawin.

Sources: https://www.erdosproblems.com/44 ; https://www.erdosproblems.com/329 ; https://mathoverflow.net/questions/501983/can-every-sidon-set-of-size-3-be-extended-to-a-finite-perfect-difference-set

**Next mathematical gate:** establish a uniform repair law avoiding the factor m in O(m epsilon² K) for growing prefixes. Until then, no asymptotic #329 record claim.
