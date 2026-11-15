# NIGHTFALL — The Price of Permission
## The Economical Limits of Mediating Superautonomy

**Research checkpoint:** November 15, 2026. **Status:** finite-model analytic construction and reproducible exact checks; not Lean-certified, independently refereed, or globally novel. **Research issue:** [#589](https://github.com/d3lefts/d3lefts/issues/589). **Priority:** permission costs, not monitor-only optimization.

## 0. Research contract

**Objective.** Exhibit a formal feasible-region separation between a monitor-only *average-cost* benchmark and real-world permissions requiring an individually scoped deep inspection, version-current evidence, an effect-time reference monitor, and a hard execution deadline. Derive a matching resource and lifecycle-cost lower bound for a nontrivial model.

**Explicit feasible set.** Finite batch of N distinguishable actions, all arriving just before slot 1, with common execution deadline T (integer slots). Each action may be either safe or unsafe. There exists a potential unsafe alternative with the same cheap-monitor transcript as each safe action, so the cheap monitor cannot justify a zero-error authorization. An expensive inspection of action i is a perfect, unforgeable and scoped safety oracle that occupies one monitor worker for its slot and returns a certificate only at the end of that slot. Each complete and unbypassable effect-time guard consumes one guard worker for one slot and permits effect only if it holds an action-scoped *current* safety certificate. A fresh certificate produced in slot t cannot be used by a guard until slot t+1. At most m deep inspections and g guarded effects per slot. Each action can be effected at most once. There are K0 authenticated pre-existing action certificates; an adversary may invalidate up to B of them **before** slot 1; the guard rejects revoked certificates. There is no further source or version change during the T-slot execution window. On an all-safe batch, at least A=ceil(alpha N) effects must complete by the deadline. Unsafe effects forbidden for every feasible world (zero-error / adversarial safety). The above are assumptions, not established operational facts.

**External comparison.** Hua et al., NeurIPS 2025 *Combining Cost Constrained Runtime Monitors for AI Safety* optimize expected monitor/intervention cost; Anthropic's cheap probe results show large savings on evaluated non-adaptive tasks; deadline-constrained real-time scheduling, flow, and complete mediation are classical. This note is a constrained engineering benchmark, **not a new queueing theorem**.

**Certificate/checker.** `permission_capacity.py` implements exact analytical capacity and a feasible witness schedule; independent `audit_independent.py` enumerates *every* schedule choice for tiny instances and all before-start cache invalidation subsets; `monitor_mixing.py` independently solves the probabilistic subproblem by exact rational LP-vertex enumeration. SHA-256 digest over ordered cases in `AUDIT.md`.

**Novelty threshold.** The benchmark must demonstrate a strict feasibility separation at identical monitor cost and inspection quality. World priority for the composition requires a later dated paper-by-paper nonimplication audit and external review. **Stop rule:** do not claim a universal impossibility theorem for all monitors or an actual deployment certificate.

## 1. Exact permission-capacity theorem (zero adversarial error, hard deadline)

Let `N>=0, T>=2, m,g>=0, 0<=B<=K0<=N` be integers. Set the worst-case number of remaining valid cached certificates `K = K0-B`. Define

\[
\boxed{M_T(K,m,g;N)=\min\{N,\;gT,\;K+g(T-1),\;K+m(T-1)\}.} \tag{1}
\]

**Theorem 1 (sharp capacity).** In the stated model, the maximum number of safe actions that can be committed by the common deadline, uniformly over every cache-invalidating change of size at most B, is exactly `M_T(K,m,g;N)`. Thus nontrivial legitimate-action availability `A` and zero unsafe effects are feasible **if and only if**

\[
\boxed{A\le M_T(K,m,g;N).}\tag{2}
\]

For `T=1`, only cached certificates can be executed and the formula is `min(N,K,g)`.

**Safety lower bound.** Any committed action whose exact scoped evidence was neither validly cached nor freshly deeply inspected has an unsafe alternative with the *same observed cheap-monitor and guard version transcripts*. Consequently a zero-error reference monitor may not commit it. Each fresh inspection occupies one deep-worker slot before its guard; at most `m(T-1)` fresh inspections can be useful by deadline. At most `gT` effects can be guarded. In slot 1 only K cached actions may commit; in slots 2..T at most `g(T-1)` additional effects can commit. These supply three separate upper bounds in (1); N is the fourth. Revoking B distinct cached items reduces the usable supply to K, attaining the worst case.

**Matching construction and certificate.** At each slot, commit `min(g,ready)` previously certified safe actions. In each nonfinal slot, deeply inspect up to m remaining actions, which become ready at the next slot. On an all-safe batch, all inspected actions pass. For `C_t` completed actions after t slots, the recurrence is

\[
C_1=\min(g,K,N),\quad
C_t=\min\bigl\{N,\;C_{t-1}+g,\;K+m(t-1)\bigr\}\quad (t\ge2).
\]

Inductively unrolling it yields

\[
C_T=\min\{N,gT,K+g(T-1),\min_{2\le j\le T}[K+m(j-1)+g(T-j)]\}.
\]

The last expression is affine in j inside the inner minimum, which therefore occurs at an endpoint; its endpoint values include `K+g(T-1)` or `K+m(T-1)`. Hence exactly (1) is achieved. This proof is for the all-safe legitimate-throughput case; unsafe deep results are rejected and cannot produce unsafe effects.

**Minimum installed worker capacity.** For A successful effects and T>=2 define D=(A-K)_+ . The componentwise minimum feasible deep-monitor and guard worker capacities are exactly

\[
\boxed{m_{\min}=\left\lceil\frac{D}{T-1}\right\rceil,\qquad
 g_{\min}=\max\left\{\left\lceil\frac{A}{T}\right\rceil,
\left\lceil\frac{D}{T-1}\right\rceil\right\}.} \tag{3}
\]

Each lower bound follows from (1), and the pair attains all four constraints. This supplies a **matching resource lower bound**; it is not a claim of novelty over scheduling theory.

**Exact batch permission price (restricted cost model).** If each new inspection costs `c_d`, each effect guard `c_g`, and installation of each constant-capacity worker costs `F_d` and `F_g`, all nonnegative, then for exactly A successful all-safe effects the optimal cost per effect is

\[
\boxed{\mathcal P_{\mathrm{batch}}(A)=c_g+
   c_d\frac{(A-K)_+}{A}+
   \frac{F_dm_{\min}+F_gg_{\min}}{A}.}\tag{4}
\]

If there are already m0/g0 installed workers and setup is charged only for additions, replace installation terms by `F_d(m_min-m0)_+ + F_g(g_min-g0)_+`. The model excludes paid cheap screening, delay penalties, denial penalties, incident repair, and monitor errors (none are required for this all-safe zero-error subcase); hence (4) is a *scoped component* of the original lifecycle Price of Permission objective, **not its universal value**. If installed capacities are held fixed and A>M_T, price is `+∞` under the hard feasibility constraints.

## 2. Exact probabilistic discrimination tax (calibrated noisy-cost subproblem)

Consider a separate **single-action** stochastic model with prior unsafe probability `0<p<1`, one uninformative cheap-monitor transcript (safe/unsafe have identical cheap observations), and a perfect deep inspection. The policy may (a) commit immediately with probability a, (b) deeply inspect with probability v, committing only if safe, or (c) deny. Here `a,v>=0`, `a+v<=1`. The effect-time guard is perfect for scope/version validity but does not itself test action safety. Requirements:

\[
\Pr(\mathrm{commit}\mid\mathrm{safe})=a+v\ge\alpha,
\quad \Pr(\mathrm{commit}\mid\mathrm{unsafe})=a\le\eta,
\]
\[
\Pr(\mathrm{unsafe}\mid\mathrm{commit})=
\frac{pa}{pa+(1-p)(a+v)}\le\delta.
\]

The terminal risk is only defined for positive commit probability; when `alpha>0`, the denominator is positive. Introduce

\[
\kappa=\frac{\delta(1-p)}{p(1-\delta)}.
\]

**Theorem 2 (sharp discrimination tax).** For `0<alpha<=1` and `0<=delta<1`, `0<=eta<=1`, the minimum expected deep-monitor use per attempted action is exactly

\[
\boxed{v_*=\alpha-\min\{\alpha,\eta,\kappa\alpha\}.}\tag{5}
\]

It is attained by `a*=min(alpha,eta,kappa alpha)`, `v*=alpha-a*`, and denial probability `1-alpha`. The proof is the LP with inequalities `a+v>=alpha`, `a<=eta`, `(p-delta)a<=delta(1-p)v`, `a,v>=0`, `a+v<=1`: both `v>=alpha-eta` and `v>=alpha(1-kappa)` follow, and the displayed policy saturates the tightest one. Independent exact vertex enumeration confirms the analytic formula on 500 rational parameter sets.

**Under robust probability shift** `p∈[p_-,p_+]` with no change to the conditional observation mechanism and the same constraints for all p, (5) uses `p_+`; the conditional postselection risk increases monotonically with p. This is a small *calibrated risk* model. It is NOT interchangeable with Theorem 1's **all-world zero-error burst guarantee**; blending their mean and worst-case quantities without a new coupling theorem would be invalid.

## 3. Registered decisive baseline separation

Take **N=3 all-safe actions, common deadline T=2 slots, deep-monitor capacity m=2 per slot, trusted guard capacity g=3, one previously certified valid action K0=1, and adversarial pre-batch invalidation budget B=1**. Set alpha=1, delta=eta=0. Cheap classification has a formally demonstrated unsafe alternative for every action, so all executable effects require an actual fresh or cached perfect check.

- An average-only monitor budget of 3 inspection units pays for all three perfect checks. Nothing in the monitor-only average-cost constraint rules out that routing decision.
- **If no cache is invalidated**, K=1 and `M=min(3,6,1+3,1+2)=3`: commit cached action in slot 1, inspect two more then guard them in slot 2. Feasible.
- **If the cached item is invalidated before the burst**, K=0 and `M=min(3,6,3,2)=2`: one safe action misses its deadline. The baseline is *inadmissible* despite enough aggregate monitoring dollars.
- Raising deep capacity to m=3 yields `M=3` and exactly restores all three timely, safe commits. Equation (3) proves no smaller deep capacity can do so.
- If the additional monitoring lane costs 4 budget units and existing guard capacity is sunk, the cheapest no-churn K=0 fix costs 4 extra installation units plus 3 deep inspections and 3 guarded commits at unit variable cost 1 each: total cost 10, price `10/3` per safe effect. Treat these as **illustrative arbitrary units**, not Anthropic/OpenAI empirical measurements.

This is a **strict finite feasibility separation** between an average-budget routing model and a jointly constrained permission architecture. It is not a comparison against an actually retrained NeurIPS 2025 implementation nor a source-matched external benchmark.

## 4. Explicit blocker and negative controls

1. **No known complete mediation => no safety theorem.** Signature validation and an API façade cannot prove every real-world side effect traverses a guard. The theorem conditions on complete and unbypassable mediation at effect time, independently of cheap classifier outputs.
2. **Change during execution invalidates the formula.** If an adversary can invalidate every freshly completed certificate before its atomic guard check, an all-safe batch can have zero guaranteed timely commits even with ample nominal monitor capacity. A change-rate/freshness bound, quiescence window, or protected transaction is essential for positive worst-case availability.
3. **Actual model discrimination:** Theorem 1 has a genuine cheap-monitor blind spot. Better certified cheap monitors shrink the class requiring deep inspection; it would be incorrect to require deep inspection universally.
4. **Unsafe-action flooding:** A guarantee of safe-action availability requires arrival/adversary restrictions or reserved inspection capacity; an unbounded attacker can saturate any finite monitor queue.
5. **False-positive/false-negative calibration:** Theorem 2 uses a known p and a perfect deep verifier. OpenAI's 2026 monitorability proxies and Anthropic monitor coverage measurements cannot be inserted as trustworthy error probabilities without labeled, task-matched outcomes.
6. **No simultaneous risk/capacity optimality for stochastic service yet.** A full finite robust queueing-control model with deadline distributions, changing monitor accuracy, and retries is the next theorem; its exact finite LP/DP optimum would still need a nonimplication prior-art test to count as mathematical novelty.

## 5. Dissertation connection and next decisive experiment

The **minimum cost of legitimate permission** is the cost of maintaining both (i) sufficient verified information and (ii) adequate real-time capacity to transform that information into an authorized effect without stale-evidence or postselection failure. Theorem 1 pins the service and cache invalidation cost; Theorem 2 pins the cheap-monitor discrimination tax for a calibrated ambiguity class; PR #588 provides effect-time risk/postselection constraints, PR #576 supplies exact observation/version guard transversals, PR #585 conditional evidence reuse, and PR #586 robust change-region tests. Their combined *operational* proof remains future work.

**Next test:** Replace arbitrary service units with source-matched monitor score vectors and timestamps, keep synthetic fully controlled sandbox effects and a side-effect inventory, implement a trusted version-aware gate, verify all bypass routes and retries, and measure true effect commits and deadline misses. Compare cheap-only, deep-only, 2025-style average-budget routing, static deep + guard, full recertification, and joint reserved-capacity + change-aware controller, at identical safety and availability constraints. Independently compute a time-window capacity certificate (cut or exact DP). If two source-matched settings show no new strict gap, archive negative evidence and change operator family.

## Sources and priority caveats

- Hua et al., *Combining Cost Constrained Runtime Monitors for AI Safety*, NeurIPS 2025. https://proceedings.neurips.cc/paper_files/paper/2025/hash/ed56a654ddb681841fdb2184463c253e-Abstract-Conference.html
- Cunningham et al., *Cost-Effective Constitutional Classifiers via Representation Re-use*, Anthropic 2025. https://alignment.anthropic.com/2025/cheap-monitors/
- Anthropic, *Measurements for understanding the pace of AI development inside frontier labs*, August 2026 snapshot. https://www.anthropic.com/institute/measuring-pace-of-ai-development
- OpenAI, *What affects chain-of-thought monitorability across the model lifecycle?*, November 10, 2026. https://alignment.openai.com/cot-monitorability-model-lifecycle
- Saltzer and Schroeder (1975), reference monitor/complete mediation. Existing real-time feasibility and job scheduling capacity inequalities are antecedents; no originality claimed for simple batch formulas.

**Status label:** analytic theorem (restricted), exact finite numerical audit, operational assumptions unverified, Lean uncertified, no human review, no worldwide priority claim. Research directed by Devin J. Wright with AI-assisted construction and checking.
