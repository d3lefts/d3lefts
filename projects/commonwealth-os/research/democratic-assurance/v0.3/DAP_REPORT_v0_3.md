# NIGHTFALL / COMMONWEALTH 2030 — Democratic Assurance Research Report v0.3

**Date:** 2026-11-15  
**Dissertation:** *The Constitution of Computational Commonwealths: A Blueprint for Human-Sovereign Governance in the Age of Synthetic Autonomy*  
**Research focus:** Joint informed agency, political equality, legal authorization, and operational assurance, with binding in-platform organizational voting pilots where authorized.

## Decision brief

The v0.2 Democratic Assurance Passport had a correct, limited effect-time guard invariant but conservatively rejected every relevant rule-version mismatch. The v0.3 addendum establishes a **strictly stronger finite-model semantic reuse theorem**: existing authenticated election evidence can be safely reinterpreted under a lawfully applicable changed rule *if and only if* the rule's resulting authorization vector is constant on every evidence-equivalence class. Otherwise, a minimum-cost supplemental query portfolio is characterized exactly by covering all observationally indistinguishable, opposite-authority pairs. A group-invariance restriction exposes when desired anonymity and public authorization cannot simultaneously be met from available evidence.

This is a proven conditional extension of the DAP specification, but not a peer-reviewed or globally novel theorem. It uses classical sufficiency, set cover, and permutation invariance. It **does not** prove informed agency or effective political equality, which require independently designed empirical and institutional research.

## Main results and proof passports

1. **DAP-CR1: Universal semantic rule-change reuse, iff.** `T(b)=T(b') => F_new(b)=F_new(b')` for every admissible pair. Necessary and sufficient by constructive factorization. Allows no additional ballot query when, for example, a new threshold remains a function of the retained certified tally, *provided the changed law lawfully applies*.
2. **DAP-CR2: Exact joint nonadaptive supplemental acquisition cost.** Choose the least costly lawful truthful query set that separates all same-transcript, opposite-authorization pairs. Gives an exact weighted-cover cost or infeasibility certificate for the multi-action vector.
3. **DAP-CR3: Anonymity compatibility.** If every public observable is invariant under the stated lawful voter-swap group, then any publicly verifiable authorization outcome must also be group-invariant; otherwise perfect correctness and that invariance cannot coexist.
4. **DAP-CR4: Marginal privacy composition failure.** Two separately ballot-independent logs can jointly reveal the private ballot (`M1=r`, `M2=r XOR b`). Every actual deployment needs a **joint** cryptographic privacy assessment.
5. **DAP-S1 composition (inherited).** Correct current authorization plus a truly complete, linearizable, atomic effect guard implies that every modeled committed action had current authority when committed. Physical enforcement coverage and legal truth remain separate premises.

All formal statements, assumptions and proofs are in `COMPOSITION_THEOREM_v0_3.md`.

## Independent finite checks

There are 16 possible four-voter configurations; six query types with exact synthetic costs. A primary pair-cover program and an independent observational-partition algorithm agree on 165 rule/group instances. Under within-group permutation invariance, a changed overall tally threshold needs **0** additional ballot-query units; the group-A-any and group-A-all predicates cost **3** each; certifying them together costs **4**, a **33.33%** reduction relative to independent cheapest acquisitions. Under full-voter permutation invariance, a group-specific rule cannot be resolved using the allowed public queries. A four-world mask example also confirms that marginal privacy need not compose.

These are synthetic costs and exact model outcomes, not municipal financial estimates, legal opinions, empirically demonstrated political equality, or certified election-protocol security.

## What changes in the Democratic Assurance Passport

Previously: reject on any changed relevant epoch, request complete renewal.

Now: authenticate the new rule and its legal applicability; find the retained evidence's indistinguishable election states; test whether the new authorization is constant across each retained evidence class. If yes, reuse election evidence and renew only applicable legal/guard certificates. If no, obtain the minimum lawful privacy-compatible extra evidence, or mark the decision `INDETERMINATE` and prohibit effects. The current authority state, revocation/stay and action identity must still be guarded atomically.

## Non-claims and stop rule

No federal election law transition is proved. No real-world authorization sink is shown complete. No cryptographic ballot secrecy, coercion resistance, or citizen autonomy is proved. No human-refereed or globally original mathematical discovery is claimed. OS implementation is the next step, beginning with versioned ordinance/organization rules, a pluggable externally reviewed election proof interface, the semantic reuse evaluator, a typed proof passport, and a sandbox-only effect guard. Any live binding vote requires governing-institution authorization and independent election-security and legal review.

## Sources

See `COMPOSITION_THEOREM_v0_3.md` section 8 and the complete v0.2 report `DAP_REPORT_v0_2.md`. Primary updated references include EAC/NIST 2025 E2E protocol process, the National Academies 2018 election-security assessment, Cornell's logical attestation framework and the 2026 individual IETF finality-bound revocation draft. NIGHTFALL's earlier compositional-recertification findings are explicitly credited and distinguished.
