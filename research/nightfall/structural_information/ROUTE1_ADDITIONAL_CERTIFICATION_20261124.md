# Route 1 additional derivations: formalization checkpoint, 2026-11-24

The site owner confirms that the new derivations have received review. This is recorded as owner-reported review, not a fabricated review transcript or a Lean receipt. Preserve the review source and exact theorem version when supplied. No publication or merge is requested here.

## Exact static obstruction

For an injectively recoverable b-local map into a code of minimum distance D, every nonconstant axis of a code-supported product rectangle must influence at least D output positions. Counting incidences gives at most bn/D nonconstant axes. A latent value recoverable by depth-r binary queries has at most 2^r values on the support. Conditional entropy is at most (bnr/D) ln 2; subtract from k ln 2 and minimize over product decompositions. With k,D linear in n the optimized br(1+C_W) is linear in n. The low-degree simulation side imports the exact moment risk transfer (#988) and #970. The new Lean file formalizes the actual finite geometry, not just the last scalar inequality. Remaining source links are the recovery range bound, entropy on product rectangles, the finite/general Wyner infimum, and the high-dual-distance simulation composition.

## Robust extension: explicit proof target

Let Q=Phi_*mu approximate the uniform code law P in TV at most zeta<1/2. Let E be the code-membership event, p=Q(E)>=1-zeta. Recoverability makes Phi injective on the source support. Let d_j denote dependency footprint sizes, so sum d_j<=bn. Partition latent axes of positive footprint into singleton heavy groups (d_j>=D) and light groups of total footprint incidence <D, using greedy maximal bins. The number of all groups is O(1+bn/D): adjacent light bins have combined load >=D, so there are at most 2bn/D+1 light bins. Zero-footprint coordinates are constant on the recoverable support and may be ignored.

Conditional on W=w, the latent law is a product. On E, for every light group, fixing its complement leaves at most one supported assignment to that group: two would encode distinct codewords differing on <D outputs. For q_w=Pr(E|W=w)>0, the conditioned latent law R_w has KL divergence log(1/q_w) from its original product law. Hence its total correlation across groups is at most log(1/q_w), by the KL chain rule. For each light group G, H_Rw(G|complement)=0, so H_Rw(G)=I_Rw(G;complement)<=total correlation<=log(1/q_w). Heavy singleton entropies are <=r ln 2 by recovery. Consequently H(Z|W,E) <= (#heavy) r ln 2 + (#light) E[log(1/q_W)|E]. The last conditional expectation is <= log(1/p), by concavity of -q log q. The resulting upper bound is O((1+bn/D)(r+log(1/p))). For D linear, b,r>=1, this is O(br).

The overlap identity for total variation shows TV(Q(.|E),P)<=zeta, since Q(.|E)>=Q pointwise on the code. Entropy continuity gives H(X|E)>=(1-zeta)k ln 2-h_2(zeta). Since E is a deterministic function of X and Phi is injective, I(W;Z)=I(W;X)>=p I(W;X|E). Thus C_W(mu)>=p[(1-zeta)k ln 2-h_2(zeta)-O(br)]. This establishes the stated linear lower bound on the optimized static score for fixed zeta. The proof target requires the entropy/KL composition and is not certified by the new finite geometry module.

## Forrelation common information

For a fully coordinate-product latent W, let A=E||E(F|W)||^2 and B=E||E(G|W)||^2. Orthogonality and Cauchy-Schwarz give A+B>=2Nc, with c=E[F^T H^T G]/N. Fair independent unconditional blocks give I(W;F)=sum_i E phi(a_i), and similarly for G. The scalar function psi(s)=phi(sqrt(s)) is increasing convex by its nonnegative power series. Jensen gives C_W>=N psi(c). TV perturbations preserve c up to 2 eta, while marginal entropy drops by at most eta N ln2+h_2(eta). Exact coefficients: 0.36574635568849334 (Gaussian-sign), 0.16890334191884548 (balanced distinguishing law), 0.34522549775419215 N-0.05600153435484734 at eta=0.01. The Gaussian sign specialization and classical query lower bound are distinct dependencies. Use #970 finite/general equality; #886/#887 for companion argument and #891 for adaptive lower-bound reduction. Do not conflate log mixture count with C_W.

## Proof gates

Named strict Lean + mandatory leanchecker + standard axiom report + source hash. No claim that all derivations are kernel-verified merely from passing their finite subtheorems. Reuse exact-head #1183/#1184 certificates and #1167 support rigidity. The owner has requested certification; the new source and review are not a submission to a publication venue.
