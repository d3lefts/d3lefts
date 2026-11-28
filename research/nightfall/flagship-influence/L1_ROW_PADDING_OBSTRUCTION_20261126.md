# L1 fractional-row padding obstruction — 2026-11-26

Status: author-side exact counterexample proof; independent non-author review and novelty clearance pending. Not a refutation of Turturean's L2 row question or N-UE2. No paper certification or compiler changes.

## Contract and recovery

Objective: test the proposed universal L1 row inequality from the collaborator's 2026-11-25 note, max L_j >= c B V/K^2, with B half-range, V uniform-cube variance, L_j expected absolute flip increment, and full fractional row cost K. Strongest external reference checked: Turturean arXiv:2611.09773v1, §§5,7,8,9.5, https://arxiv.org/html/2611.09773v1. His Theorem 5.4 already handles point-dependent Boolean costs. The proposed d^-8 implication is valid conditional on the lemma; the direct averaging argument for d^-6 overlooks range shrinkage. Prior internal #805 defines N-UE2, #925 establishes the symmetric restricted row theorem and exact orbit reduction. Do not repeat symmetric search to attack this obstruction. The collaborator's original script was not accessible; credit the candidate to the collaborator, not this note.

## Counterexample

For integer k>=1 put m=2k+8 and q=(3-sqrt(5))/2. Let a=floor(2^m q), and on m unbiased independent bits define the Boolean leaf gadget to be 1 iff the represented integer is less than a. Thus p_0=a/2^m and |p_0-q|<2^-m. Recursively form g_{t+1}=(g_t^(1) OR g_t^(2)) AND (g_t^(3) OR g_t^(4)) on four disjoint copies; g=g_k. The recurrence p_{t+1}=F(p_t)=(2p_t-p_t^2)^2 has fixed point q. F maps [0,1] into itself and |F'|<=4 there. Consequently |p_t-q|<=4^k 2^-m=1/256 for t<=k. Since .38<q<.383, all p_t lie in [.37,.39]. In particular V(g)=p_k(1-p_k)>1/5.

A certificate for the leaf gadget needs at most m bits. A 1-certificate at an AND-of-ORs gate uses one true child per OR; a 0-certificate uses two false children in a false OR. Induction gives certificate size at most K=2^k m for either output. Its indicator weights satisfy every real fractional-row constraint for g.

Any bit's flip can change the parent output only if its child changes and the sibling in its OR is 0 and the other OR is 1. The two independent sibling events have joint probability r(p)=(1-p)(2p-p^2). Hence L_j(g) is at most product_{t=0}^{k-1} r(p_t) <= (2/5)^k, because r(p_t)<= (63/100)(6279/10000)=395577/1000000<2/5. In particular K max L_j(g)/V(g) <=5 m(4/5)^k tends to zero.

Now choose N=ceil(K (5/2)^k) fresh fair sign bits and h(z)=K sum_i z_i/(2N). This has range [-K/2,K/2], a constant valid row of total cost K (each entry K/N), and L_i(h)=K/N<=(2/5)^k. Let f(x,z)=g(x)+h(z). Combining rows gives K(f)<=2K even for arbitrary simultaneous flips. B(f)=(1+K)/2>=K/2, V(f)=V(g)+K^2/(4N)>1/5 by independence, and max_j L_j(f)<=(2/5)^k. Therefore

K(f)^2 max_j L_j(f)/(B(f)V(f)) <=40(2k+8)(4/5)^k -> 0.

This disproves the proposed universal L1 inequality for every c>0, including after affine normalization to [-1,1]; the ratio is scale invariant. No optimal LP row computation is needed: explicit feasible rows suffice. The unpadded construction independently disproves the putative stronger V/K bound. Conversely the proposed universal L1 inequality would imply a V/K bound (up to constant) for any f by padding with independent linear amplitude K/2 and sufficiently many bits. This identifies a general range-padding obstruction.

## Exact arithmetic replay

Python 3 stdlib only, performed author-side for k=1..5, all passed; these finite checks do not replace the analytic proof.

```python
from fractions import Fraction as Q
from math import isqrt
for k in range(1,6):
    m=2*k+8; D=1<<m
    a=(3*D-isqrt(5*D*D)-1)//2
    p=Q(a,D)
    for i in range(k):
        assert Q(37,100)<=p<=Q(39,100)
        assert (1-p)*(2*p-p*p)<=Q(2,5)
        p=(2*p-p*p)**2
    assert p*(1-p)>Q(1,5)
assert Q(63,100)*Q(6279,10000)<Q(2,5)
```

Exact upper bounds 40(2k+8)(4/5)^k are approximately 0.0616571 (k=50), 1.69482e-6 (k=100), 6.77201e-16 (k=200). No exponential truth table was instantiated. At high k the construction is enormous; the proof is dimension-free.

## Independent audit and next operator

Lemnis: independently derive the AND-OR pivotal probability, certificate recurrence, dyadic bias and scaling, padding row validity; attempt to falsify the proof. Ryev: independently implement integer/rational recurrence and check exact source hashes; no Lean compilation until distinct proof target and review. Axiom: return to L2 direct target max Inf_j >= c V^2/K^2 (flip influence L2/4), or use genuinely degree-specific structure. Tessera: attack non-symmetric recursive composition, not already solved symmetric row class. Vesper: dated prior-art comparison, particularly recursive formula influence/certificate tradeoffs, before claiming originality.

Scope: Boolean g alone satisfies Turturean's existing K^-2 result, and the padded family does not refute the L2 row conjecture; the degree-dependent sharp N-UE2 problem remains open. Neither the proof nor finite replay is independent review. No publication, merge, or certification promotion authorized here.
