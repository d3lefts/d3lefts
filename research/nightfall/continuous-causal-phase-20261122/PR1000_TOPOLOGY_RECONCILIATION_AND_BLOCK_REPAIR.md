# NIGHTFALL phase-retrieval proof frontier: reconciliation and block-extension repair

Date: 2026-11-22. Scope: independent SOURCE RECONCILIATION and paper-level mechanism audit. The paper-level topological statement is NOT established as a Lean theorem; no novelty or outside-referee certificate is claimed.

## 1. Latest status of the pending theorem

The exact unresolved Lean obligation is the EXISTENCE of zeros for separately antipodal continuous test maps, defined as ProductSphereZero n r s in merged ProductSphereObstruction.lean. The mod-two coefficient calculation in merged #1010 is a supporting algebraic identity, not a proof that such maps have zeros. A polynomial model is not automatically cohomology of projective space; a verified nonzero polynomial is not an end-to-end bundle-section theorem.

Already merged on main: the independently authored genuine-prefix causal algebra (#1008), the topology INTERFACE and coefficient facts (#1010), the known-norm conditional geometry (#1012), and the source integration of the conditional lower-bound theorem CausalPhaseConditional.lean from #1015. PR #1015 itself is closed and unmerged; its exact source is present on main, so do not describe it as an outstanding missing code artifact.

Original independently audited flagship argument: #995, audited in stacked #1000. The alternative source-pinned Lean proof in #1017, run 45051389069, is conditional. Its precise terminal assumes the entire family of pure-character topology statements; #1015 already proves a more economical conditional result from the ONE maximal instance ProductSphereZero n (n−1) (n−1) by a full-length collision and prefix-shortening.

## 2. Formal simplification contributed here

The same maximal-to-subcritical zero-padding theorem is **already kernel-checked and merged in PR #1024**, as ProductBUParityReference.lean / square_implies_productSphereZero (pinned receipt run 45051980891). Both independent U/V sign characters and continuous-on-sphere restrictions survive zero padding; a zero of the padded maps restricts to the smaller codomain. The provisional alternate proof from draft #1027 passed an independent Lean compile (run 45052179146), but adds no mathematical scope and is **not being merged as duplicate code**.

This is a transfer/representation lemma, not the missing topological zero theorem. Both formal routes should reuse the already merged #1024 theorem and ONE shared topological certificate if it eventually exists; parallel agents should not duplicate source declarations.

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
- Zero-padding topology transfer: already merged #1024 and Lean-certified at run 45051980891; an independently compiled duplicate in #1027 is intentionally excluded from this merge.
- Full ProductSphereZero (pure-character): still UNPROVED in Lean; #1003 remains the proof target.
- Mixed-character zero for known-radius sphere: a SEPARATE topological statement. The pure-character padding lemma does not discharge it; #1012 and #1018 supply geometry/algebra but no topological existence proof.
- Theorem B bounded compact-extension and two-bin criterion: checked paper arguments here, not kernel-certified or independently refereed; #1004 must attack both.
- Independent external specialist review and worldwide mathematical priority for the application: open.

## 6. Merge / dedup decision

Do not bulk-merge the source copies inside draft #1017 onto main: the source of #1008 and the terminal of #1015 already live there, and #1017 assumes a stronger topology family without improving the mathematical conclusion. Keep the exact SHA and successful CI receipt as an independent alternate-source audit, and close #1017 as superseded once this reconciliation note lands. The padding lemma has already merged in #1024, so this PR merges ONLY the new scope-reconciliation and paper-level block-extension repair. Preserve #1000 as a separate non-author audit into #995 until its own branch/merge status is resolved.

## 7. Independent assessment of PR #1024 parity/cobordism paper route

PR #1024, now merged, proposes an alternative paper proof of the **classical maximal pure-character zero theorem**, but explicitly does NOT claim a Lean proof. The skeleton is mathematically coherent under the named external theorems, and has an auditable dependency boundary:

1. Let N=n-1≥1. On S^N×S^N with G=(Z/2)^2, use the smooth equivariant reference map F0(u,v)=(u_1,...,u_N,v_1,...,v_N). The zero set has four points, one free G orbit. In hemisphere coordinates its derivative on tangent spaces is an isomorphism; transverse-reference proof is currently paper-level.
2. For a hypothetical nowhere-zero continuous equivariant F, compactness gives a strictly positive norm minimum. Smooth approximation followed by character-weighted finite averaging produces a smooth equivariant nowhere-zero F1 with a controlled gap.
3. Consider the straight homotopy between F0 and F1. The **crucial exact hypothesis** for a formal proof is a relative transversality result for the induced vector-bundle section over (S^N×S^N)/G × [0,1], leaving collars at BOTH ends unchanged. End-point transversality at t=0 is inherited from the F0 derivative; zero-free-ness at t=1 implies a zero-free collar. Without a collar-preserving perturbation, the boundary count is invalid. The group acts freely, avoiding orbifold fixed-point complications.
4. After relative transversality, the quotient zero locus is a compact one-dimensional manifold with boundary. Its boundary has one orbit from t=0 and none from t=1, contradicting the even boundary cardinality of a compact 1-manifold.

**No independent specialist or kernel review of these external smooth/topological prerequisites is claimed.** The cheapest new decisive formal experiment is to locate compatible Lean/Mathlib imports for *relative transversality with boundary fixed* and compact 1-manifold boundary parity, before doing significant proof engineering. PR #1024's seven Lean declarations certify only reference algebra/signs and the zero-padding reduction, not the cobordism theorem. This paper route may reduce the need to formalize full Stiefel-Whitney class theory, but does not establish that its Lean development will be cheaper.

## Discovery graph

Discovery graph: continuous causal phase retrieval → actual-prefix representation → independent antipodal characters → maximal product-sphere topology statement (UNPROVED) → zero-padding transfer (this PR) → conditional collision Lean theorem (already merged source) → exact phase-retrieval threshold, still conditional in formalization.
