# Evidence-Cut Composition for Evolving Digital Twins (NIGHTFALL v0.4)
**Research date:** 2026-11-13 · **Research lead:** Devin J. Wright; human-led, substantially AI-assisted.
**Status:** finite exact checked, classical analytic transfer; NO novel universal theorem, physical deployment, external proof/priority review, or end-to-end Lean certificate.
**Scope:** trusted source/model contracts, mission and change-scope metadata, deterministic contractive external subsystem and an optional separately specified noisy port oracle.

## Objective and compared interfaces
Determine when interconnected physical twins can reuse safety evidence for an unchanged subsystem using only an authenticated boundary observation. Account separately for physical sensor acquisition, provenance/manifest checking, model-contract checking, numerical computation and certificate verification. A reduction in the **number of claims requiring new evidence** is not automatically a reduction in total lifecycle cost.

## Theorem A: boundary-condition evidence reuse (analytic, classical mechanism)
Let E be the unchanged external subsystem and Γ its interface to the updated subsystem U. Suppose the old and new steady states obey e=F_E(e,a), e'=F_E(e',a'), with externally authenticated unchanged function F_E and:
- `|F_E(e,a)-F_E(e',a')| <= B |e-e'| + C |a-a'|` componentwise for nonnegative B,C,
- spectral radius ρ(B)<1 (our exact finite generator uses the stricter row-sum<1),
- trusted interface evidence `|a-a'|<=z`, z>=0.
Then `|e-e'| <= q* := (I-B)^(-1) C z`. Nonnegative `q` with `q>=Bq+Cz` is a finitely checkable sound certificate; checking its inequality is O(nnz(B)+nnz(C)+|E|). If safety of component i was certified with margin m_i and the relevant safety functional is L_i-Lipschitz, retaining that claim is sound when `L_i q_i <= m_i`. Source validity, authenticated unchanged external dynamics, calibration and any cost of verifying them are *assumptions external to the checker*.
The componentwise universal envelope is sharp for the permitted model-information class: affine maps `F_E(e,a)=B e+C a` with a nonnegative boundary perturbation z attain equality. **No universal claim of optimal overall algorithmic, proof-size, or acquisition cost is made.**

### Proof
Subtract the fixed-point relations and use the assumed componentwise Lipschitz inequality: `d=|e'-e|<=B d+Cz`. Since B>=0 and ρ(B)<1, iterate to obtain `d<=sum_{k>=0}B^k Cz=(I-B)^(-1)Cz`. Conversely any nonnegative super-solution q of `q>=Bq+Cz` dominates the least fixed point by monotonicity and convergence. Affine equality furnishes sharpness of this information-only bound. The prior safety-margin test follows by the Lipschitz condition. This proof does not verify the premises against the physical world.

## Checked construction: strongly connected 128-site ring
With β=1/4, the changed interface is site 0 and `z=1/(1-β^128)`. The exact exterior perturbation at distance i is `β^i z`, i=1,...,127. At margin 1/4096, six external sites are unresolved and 121 external claims survive. Every site is reachable in the physical dependency cycle; a reachability-only change filter would conservatively include the entire cycle. This demonstrates claim reuse, *not* an oracle-matched speedup over every FASE implementation.
The generator checks 112 seeded rational B,C,z configurations (n=1,...,8; 14 per n) via exact Gauss–Jordan; the separate checker imports neither generator functions nor their solver and verifies the super-solution inequality, 80 independent positive lower iterations, cycle arithmetic and exact binomial tails. An extra failure witness removes source authentication; another removes contraction. These are model-scope counterexamples, not adversarial physical tests.

## Theorem B: noisy mission–configuration complementarity (restricted oracle transfer)
Let T,A be independent uniform elements of Z_r, with safety port `K=(T+A) mod r`. Then `I(K;T)=I(K;A)=0`, while `I(K;(T,A))=log_2 r`. With one trusted perfect read per port and an advance revelation protocol (unsupplied metadata revealed *after* all sensing), exact safe-world read complexity is r if either input is missing and 1 if both are known.
For a **separately defined independent BSC sensor** returning the true sign with probability (1+β)/2, 0<β<1, where each port is a binary independent latent sign, every required port must be accepted with false authorization <=δ for any unsafe world and safe-world acceptance >=1-δ. Put `d=β log((1+β)/(1-β))` and `Dδ=(1-2δ) log((1-δ)/δ)`. A stopped KL/data-processing argument gives all-safe expected trusted query lower bound `r Dδ/d` if one input is withheld until sensing finishes versus `Dδ/d` when K is supplied beforehand. As δ→0, per-port SPRT attains matching leading `log(1/δ)` cost for fixed r; metadata attestation cost is not included. In a simple fixed-budget audit using 64 samples/required port and positive cutoff >=40 for β=1/2, exact binomial tails verify safe acceptance >=8/9 for r=2,3,4,8 and worst unsafe authorization <=1/9. This is classical information theory transferred to a typed observation interface. It is **not an empirical proof** of human–AI Shannon synergy.
The deterministic mission×change r²:r:r:1 separation and original finite checker are archived in `COUPLED_MISSION_CHANGE_v02.md` and `coupled_assurance_checker_v02.py`; the earlier perturbation envelope and stronger 132-case locality check in `independent_certificate_audit_v03.py`.

## Three mandatory prior-art baselines
1. Liu, Tyszberowicz & Beckert, *Analyses as First-Class Citizens in Model-Driven Development*, FASE 2026, doi:10.1007/978-3-032-22774-4_10 — dependency-directed incremental re-execution and analysis slicing; our criterion introduces quantitative physical effect bounds, but may be implemented as a FASE analysis trigger.
2. Zaker, Nejati & Lavaei, *Data-Driven Safety Certificates of Infinite Networks with Unknown Models and Interconnection Topologies*, 2025 preprint / Automatica 2026, https://arxiv.org/abs/2507.10979 — compositional data-driven safety; our scoped change/version reuse does not supersede their general network-safety theory.
3. Zhang & Xu, *Certified Task-Conditioned Active Observability*, 2026 preprint, https://arxiv.org/abs/2609.28520 — task-conditioned observation and certificate selection; our cost interface must be matched before any improvement claim.
Classical comparators: Banach monotone contraction, Dobrushin-type stability, weighted fractional set cover, KL sequential tests, existing change-impact verification.

## Replay from repository root
```bash
cd research/nightfall/2026-11-digital-twin-evidence-cut
python3 propose_certificate.py
python3 independent_checker.py
python3 coupled_assurance_checker_v02.py
python3 independent_certificate_audit_v03.py
```
All use Python standard library. `candidate_fixtures.json` and any result files are generated local outputs; the CI workflow recreates them fresh from committed source. Hash provenance: original v0.4 candidate generator SHA256 `de0bac78e6b39c89af5ada186e65335c9744c90a04f6a9def31df5c815a36b9d`, independent checker `19461add23c24c38696773dcc30aba240a90dcb43afbe2fb4eaab1abc1e72bc8`. Original PDF/TeX/ZIP remain in the conversation evidence archive rather than being falsely described as committed binaries. No source hash here implies external review.

## Open theorem and decisive test
Seek a **source-matched total lifecycle-cost separation** for time-varying bounded-interface networks with authenticated but priced provenance, noisy interface reads, certificate compression, and repeated version changes. Require constructive upper and matched lower bounds for source acquisition, model computation, checking and repair; compare against implementations of all three baselines with the same oracles. Evaluate whether old observed data survives adaptive/adversarial changes or whether error budgets accumulate. If a known compositional safety or active-sensing theorem already implies the claimed bound, label it as an application/transfer rather than novelty. No public priority, award, university submission, or safety certification is asserted here.
