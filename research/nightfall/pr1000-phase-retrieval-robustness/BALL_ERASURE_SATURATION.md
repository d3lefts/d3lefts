# Whole-ball erasure and exact high-noise saturation for causal intensity sensing

NIGHTFALL paper-level research result v1 (2026-11-22), companion to PR #1000, developed on draft #1001. Not novelty-certified, externally refereed or fully Lean-certified. The Lean source NoisyCausalCollision.lean targets the erasure core; geometry and the terminal exact minimax theorem are separate gates.

## Model

E=R^n, n>=2, 0<=r<=R, R>0. At each step j the policy selects a row a_j(h) with Euclidean norm <=1 from the *observed corrupted* history h, and observes <a_j(h),x>^2+e_j, with |e_j|<=sigma. The decoder returns a sign class, with distance d_pm(x,y)=min(||x-y||,||x+y||). Denote by E_m(n,r,R;sigma) the infimum worst-case error over all length-m policies and decoders for inputs in the radius annulus. Selector continuity is not needed for these lower bounds; they apply a fortiori to continuous selectors. Row normalization is essential.

## Theorem 1 — complete low-amplitude erasure

For sigma>=0 and rho^2<=2 sigma, **every** signal x of norm <=rho can be forced to follow the same length-m observed transcript (sigma,...,sigma), for **any finite causal policy**, even if rows are selected discontinuously from histories.

Proof. Predefine common prefixes h_j=(sigma,...,sigma). At each stage select the actual row a_j(h_(j-1)) and set e_j(x)=sigma-<a_j(h_(j-1)),x>^2. The row norm yields 0<=<a_j(h),x>^2<=||x||^2<=rho^2<=2sigma. Thus -sigma<=e_j(x)<=sigma. The actual observation equals sigma, so induction proves the common corrupted prefix. This is not a virtual-history or topology argument.

The constant 2 is the exact threshold for this uniform constant-transcript construction: all possible intensities in [0,rho^2] fit into a shared noise interval of width 2sigma iff rho^2<=2sigma. This does not establish optimality over every other possible indistinguishability construction.

## Lemma — sign-quotient Chebyshev radius of a ball

For n>=2, inf_z sup_(||x||<=rho) d_pm(z,x)=rho. Output z=0 is an upper witness. For any z, choose x perpendicular to z with ||x||=rho; then d_pm(z,x)=sqrt(||z||^2+rho^2)>=rho. Note the essential n>=2 hypothesis; in n=1 the radius of the sign-quotient interval is rho/2.

## Corollary A — exact universal floor

For n>=2, all finite m, and ball domain r=0,

    E_m(n,0,R;sigma) >= min(R,sqrt(2sigma)).

For annulus r>0, the same bound follows whenever 2sigma>=r^2, since the erased set includes the entire sphere at rho=min(R,sqrt(2sigma)). Do not assert this bound for 2sigma<r^2 without a separate proof.

## Corollary B — exact high-noise saturation

For n>=2, 0<=r<=R and sigma>=R^2/2,

    E_m(n,r,R;sigma) = R.

The whole annulus is erased to one transcript, and the sphere of radius R forces worst-case error >=R by the perpendicular-vector argument. The zero decoder attains R. Hence **no finite number of adaptive or fixed normalized intensity measurements improves over no measurements** at this noise level.

If the signal domain and decoder outputs are both constrained to the radius-R sphere, the exact value is instead sqrt(2) R, under the same hypotheses. Any sphere-valued output has a perpendicular radius-R input giving loss sqrt(2)R; any two sign classes on that sphere are at distance <=sqrt(2)R.

These results **do not** claim R^2/2 is the earliest saturation threshold for each fixed m. For m=0, saturation already occurs at zero noise. The lower-noise sharp tradeoff and n=2 adaptive/fixed comparison remain open.

## Mechanism transfer

This argument uses only 0<=measurement-response<=||x||^2 at every observed prefix. It transfers to history-dependent positive quadratic block readings ||B_j(h)x||^2 with operator norm <=1, regardless of block rank. It does *not* automatically extend to arbitrary even nonlinear responses from PR #1000, where such an envelope may fail. It is also distinct from PR #1000's rank-budget topological obstruction.

## Reproduction / falsification / certification

- Exact rational test: form e_j(x) from the shared sigma-prefix and independently replay actual noisy histories, including m=0, sigma=R^2/2, degenerate rows and different x in the ball.
- Geometry: independent proof of perpendicular-sphere Chebyshev radius for all n>=2, and a n=1 countercheck.
- Lean: compile the erasure construction and bound with current repo Lean/Mathlib pins, print the named theorem and axioms; independently formalize orthogonal-witness existence, the metric minimum and the terminal minimax theorem. A conditional theorem with a supplied BallErasure axiom is not a complete certificate.
- Prior art: dated same-model search for high-noise/adversarial phaseless sensing floors. This theorem has a short proof; that does not imply worldwide novelty.
- Sources: PR #995 (continuous causality), #997 (exact norm threshold), #999 (noiseless minimax and adaptive attainment), #1000 (independent audit), #1001 (noise charter), issue #1006 (Lean implementation).

Status: explicit paper proof, independent finite checker and Lean erasure candidate under CI; no external proof or novelty promotion.
