# NIGHTFALL — Werner bounds reconciliation and finite-copy transition

**Checkpoint 2026-10-28.** Parameter `t=-alpha`; qutrit NPT interval `t>1/3`. Theorems using a published source are conditional only on the explicitly named source inequalities; upstream computational/SDP margins from rounded displays have separate conditional status. The exact-rational 22–24 downstream archive verifier is rerun here. Human mathematical referee and novelty audit pending.

## Valid new deduction: the k=24 spectral-gap reset

Let `A(t)=I-t|Omega_3><Omega_3|` under vectorization and `T=T_3` be traceless projection. For each rank<=2 C, the archived source-conditional 24-copy certificate yields `Q_24(17/50,C)>=m ||C||_F^2` with **exact m** stored in `certificate_k24_t0.34000.json` and `m ≈ 9.7950400300141488e-07`.

**Downward copy reduction.** Tensor an arbitrary rank<=2 witness on j sites with (24-j) normalized traceless rank-one local matrices. This preserves rank<=2, norm, and quadratic form. Hence the same positive m holds for Q_j(17/50) for every 0<=j<=24.

**Parameter transfer.** For `s=1/3` and `u=17/50`, with `lambda=s/u=50/51`, the identity `A(s)=lambda A(u)+(1-lambda)I` expresses `A(s)^tensor24` as a convex combination over subsets. Each j-site term has quadratic form >= m*||C||^2 by the downward reduction, with identity spectators. Therefore `||T^tensor24(C)||_F^2 >= m||C||_F^2` on every rank<=2 C. This improves the previous 21-seed double-exponential bridge by re-seeding coercivity at copy 24.

**Block rank-two recurrence.** For positive b_r<=1 with `||T^tensor r(C)||^2 >= b_r ||C||^2` for rank<=2 C, partition a rank<=2 matrix into 3x3 blocks. With `eps=||T^tensor(r+1)(C)||`, all offdiagonal blocks have Frobenius norm total at most `eps/sqrt(b_r)`. Remove them, obtaining a block diagonal matrix within this distance of a rank-two matrix. At least one diagonal block has operator norm <=`eps/sqrt(b_r)`, because the third singular value of the block diagonal matrix has that bound. That block has Frobenius norm <=`sqrt(2)*eps/sqrt(b_r)`. Traceless-projected differences of any two diagonal blocks have norm <=`sqrt(2)*eps`. Using the r-site lower bound separately on each rank<=2 diagonal block and summing gives `||C|| <= (2 sqrt(6)+1) eps/b_r < 6 eps/b_r`. Thus `b_(r+1)=b_r^2/36` is valid.

**NPT perturbation.** For t=1/3+delta in [1/3,2/3], `||A(t)||<=1` and `||A(t)^tensor k-A(1/3)^tensor k||<=3k delta`. Hence `Q_k(t,C)>= (b_k-3k delta)||C||^2`. Taking `delta=b_k/(6k)` proves positive margin `b_k/2`.

Consequently, for every integer k>=24, put

`b_k = 36*(m/36)^(2^(k-24))`, and `t_k = 1/3 + b_k/(6k)`.

These are explicit rational guarantees, interpreted symbolically for large k. At k=25, the exact increment is `m^2/5400`, about `1.7767186886959183e-16`. At 26 it is about `1.2647152639268201e-31`. They improve the prior 21-seed analytic guarantees by many decades while remaining far below a competitive numerical threshold. In particular they **do not** imply a fixed NPT t valid simultaneously for all k.

## Small independent implication at k=21

A 22-copy bound `t=0.36110` implies the identical t for 21 copies, because adding one normalized traceless rank-one matrix preserves a witness's rank, norm and `Q`. This improves the previously frozen k=21 value `0.36108` by exactly `0.00002`, with inherited positive margin `m22`.

## Finite-copy status inventory

* Published rigorous: k=1..3, t=0.5; universal k4=0.49375, k5=0.45, and Tomar's many-copy bounds; qutrit k4=0.4979, k5=0.47.
* Stronger exact downstream identities **conditional on quantitatively unverified source SDP margins**: qutrit k4=0.49791, k5=0.47189, k6=0.44876, k7=0.43228, k8=0.41990, k9=0.40960, k10=0.40148, k11=0.39500, k12=0.38980, k13=0.38540, k14=0.38160, k15=0.37849, k16=0.37564, k17=0.37313, k18=0.37089, k19=0.36812, k20=0.36636. Exact downstream checking validates implications conditional on these extra assumptions, never the assumptions themselves.
* Strong source-theorem-only exact downstream identities: qutrit k21 now >=0.36110 by source k22; k22=0.36110, k23=0.35100, k24=0.34000. Published low-copy theorems are the only external mathematical source assumptions, subject to checking correct applicability.
* Dimension-uniform archive: k8=0.27973, k9=0.24932, k10=0.22472, k11=0.20441, k12=0.18744, k13=0.17304, k14=0.16067, k15=0.14996, k16=0.14059; correct source-contract versions passed exact verification, external referee pending.

## Falsified numerical candidate and audit

25-copy LP at t=0.334 returned a floating solution; exact 26x26 rational reconstruction gave eight nonpositive coefficients. Therefore t=0.334 is a **rejected candidate**. It must never appear as a theorem. A separate independent `TRANSITION_CHECK.py` verifies the new rational recurrence algebra and replays the archived 22–24 checkers. The analytic block lemma is written here for referee review. Source limitations, copy counts, and PPT-vs-NPT dimensions remain explicit.

Run `python TRANSITION_CHECK.py`. `python verify24_independent.py` checks the longest direct source identity. Additional source artifacts are retained in the prior NIGHTFALL archives; this package freezes the 22–24 input certificates plus the checked transfer.
