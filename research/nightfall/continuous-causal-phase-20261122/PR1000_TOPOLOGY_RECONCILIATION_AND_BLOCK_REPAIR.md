# NIGHTFALL phase-retrieval proof frontier: reconciliation and block-extension repair

Date: 2026-11-22. Scope: independent SOURCE RECONCILIATION and paper-level mechanism audit. The paper-level topological statement is NOT established as a Lean theorem; no novelty or outside-referee certificate is claimed.

## 1. Latest status of the pending theorem

The exact unresolved Lean obligation is the EXISTENCE of zeros for separately antipodal continuous test maps, defined as ProductSphereZero n r s in merged ProductSphereObstruction.lean. The mod-two coefficient calculation in merged #1010 is a supporting algebraic identity, not a proof that such maps have zeros. A polynomial model is not automatically cohomology of projective space; a verified nonzero polynomial is not an end-to-end bundle-section theorem.

Already merged on main: the independently authored genuine-prefix causal algebra (#1008), the topology INTERFACE and coefficient facts (#1010), the known-norm conditional geometry (#1012), and the source integration of the conditional lower-bound theorem CausalPhaseConditional.lean from #1015. PR #1015 itself is closed and unmerged; its exact source is present on main, so do not describe it as an outstanding missing code artifact.

Original independently audited flagship argument: #995, audited in stacked #1000. The alternative source-pinned Lean proof in #1017, run 45051389069, is conditional. Its precise terminal assumes the entire family of pure-character topology statements; #1015 already proves a more economical conditional result from the ONE maximal instance ProductSphereZero n (n−1) (n−1) by a full-length collision and prefix-shortening.

## 2. Formal simplification contributed here

ProductSpherePadding.lean proves in the pinned kernel that the single maximal proposition implies every subcritical ProductSphereZero n p q, p,q≤n−1, by zero-padding both test maps. Every original sign and continuity requirement survives padding, and the zero of the padded maps restricts to a zero of the unpadded maps. No theorem-shaped topology axiom is introduced.

This is a transfer/representation lemma, not the missing topological zero theorem. Its useful consequence is that both formal routes may refer to ONE shared topology certificate when it eventually exists; parallel agents must not try to certify unrelated zero statements independently.

## 3. Scoped repair of PR #1000 Theorem B's nonlinearity extension

Theorem B in #1000 concerns continuous k_j×n matrix-valued blocks B_j on actual histories, and scalar readings Phi_j(h, B_j(h)x), where Phi_j is continuous and even in its second argument. Its audit text invoked Tietze on H_j^K×R^k and then symmetrized. The standard **bounded** Tietze formulation alone is not sufficient for the unbounded whole-fiber domain. A fully bounded compact-domain construction avoids any ambiguity.

Let K be the closed radius-two ball of inputs. At stage j, original actual prefix h_j(x) is continuous on K, hence H_j^K=h_j(K) is compact and closed in ambient R^j. The restriction of B_j to H_j^K is continuous, and its operator norm has a finite maximum M_j. Coordinatewise bounded Tietze extends B_j from H_j^K to all ambient history vectors; row normalization, when required, can be restored by continuous projection onto the allowed operator-norm ball without altering its values on H_j^K.

Consider the compact symmetric set
    A_j = H_j^K × closedBall(0, 2 M_j)
inside R^j×R^{k_j}. Phi_j|A_j is bounded and continuous. Bounded Tietze extends this scalar function to a continuous F_j on all R^{j+k_j}. Set
    tildePhi_j(h,z) = [F_j(h,z) + F_j(h,-z)]/2.
This is continuous and globally even in z, and equals Phi_j on A_j because the original response is even there. For any x∈K and actual reachable h, B_j(h)x lies in closedBall(0,2M_j), so the extended sensing protocol agrees with the original on K, inductively at every actual stage. The topological collision outputs u±v have norms ≤2; hence the collision transfers back to the actual protocol. The construction also handles k_j=0 and zero blocks.

This is a PAPER proof of a continuity extension, not a Lean certification of Theorem B. The generalized topology and matrix-valued virtual-history induction need their own proof/checker; the rank count is k_j per stage (block output dimension), NOT one per scalar detector output.

## 4. Exact greedy two-bin rank criterion

Let C=n−1, k_1,...,k_m≥0 integers, M=max_j k_j, S=sum_j k_j, and suppose S≤2C+1−M. If S=0, split trivially. Otherwise S≥M, so M≤C. If S≤C, put all blocks in U. Otherwise let L=S−C>0, and take the shortest PREFIX whose total U≥L. The preceding prefix has sum <L, so
    L ≤ U ≤ L+M−1 ≤ C.
The complementary sum V=S−U≤C. Therefore both groups carry at most n−1 block coordinates, and the input ordering need not be permuted. This proves the sufficient split condition used in #1000 §B, including zero-sized blocks. It does not by itself establish the product-sphere zero lemma.

## 5. Explicit status / independent review

- Conditional causal collision and reachable-only continuity: Lean-checkable, already pinned in #1015 and independently via #1017, with no claim of unconditional topology.
- Zero-padding topology transfer: exact Lean source and dedicated CI in #1027; promote only after the exact-head run succeeds.
- Full ProductSphereZero (pure-character): still UNPROVED in Lean; #1003 remains the proof target.
- Mixed-character zero for known-radius sphere: a SEPARATE topological statement. The pure-character padding lemma does not discharge it; #1012 and #1018 supply geometry/algebra but no topological existence proof.
- Theorem B bounded compact-extension and two-bin criterion: checked paper arguments here, not kernel-certified or independently refereed; #1004 must attack both.
- Independent external specialist review and worldwide mathematical priority for the application: open.

## 6. Merge / dedup decision

Do not bulk-merge the source copies inside draft #1017 onto main: the source of #1008 and the terminal of #1015 already live there, and #1017 assumes a stronger topology family without improving the mathematical conclusion. Keep the exact SHA and successful CI receipt as an independent alternate-source audit, and close #1017 as superseded only after reconciling #1027's merge receipt. Merge the small new zero-padding lemma and this evidence note, preserving #1000 as a separate non-author audit into #995 until its own branch/merge status is resolved.

Discovery graph: continuous causal phase retrieval → actual-prefix representation → independent antipodal characters → maximal product-sphere topology statement (UNPROVED) → zero-padding transfer (this PR) → conditional collision Lean theorem (already merged source) → exact phase-retrieval threshold, still conditional in formalization.
