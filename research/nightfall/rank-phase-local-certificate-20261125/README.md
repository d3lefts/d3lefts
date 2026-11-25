# Paper IV — local end-to-end rank–phase certificate (2026-11-25)

The exact adaptive optimal-depth identity A(K,d,n+1)=(n+1)+S(K,d,n) and the feasible-budget equivalence passed on the installed pinned local Lean workbench. All three project modules compiled locally, including the actual lower and calibration upper compilers and constructed finite packing witness. Independent fresh-kernel replay of the dependency-closed export returned exit 0 in 3.95 seconds (149444 KiB peak RSS). The only reported axioms are propext, Classical.choice and Quot.sound.

Recovered #1206 at df39c2677e9fcef8a212aab13361ebf5cd975ac3 via source-only export 45656954822 (artifact 15042692306). The previous terminal failure was missing DecidablePred at theorem statement elaboration. Classical Nat.find definitions repair that without altering the optimization problem. Narrow imports avoid the local 4 GiB memory limit. No remote Lean build performed.

## Reproduce
Copy the three source files into the existing pinned local workbench src/ directory. Run:
```sh
for m in RankPhasePivot RankPhaseAdaptiveTree RankPhaseIdentity; do
  LEAN_NUM_THREADS=1 ./lean-run -o build/$m.olean src/$m.lean
done
./lean-env leanexport RankPhaseIdentity -- Nightfall.FiniteField.RankPhaseAdaptiveTree.exact_rank_phase_identity Nightfall.FiniteField.RankPhaseAdaptiveTree.rank_phase_budget_iff > rankphase.ndjson
./lean-env leanchecker --from-export rankphase.ndjson
```
Check source and object digests, named standard-axiom output, exact export and kernel log hashes against CERTIFICATE.json. Scope is the actual powered-linear / normalized phase tree model, not every Paper IV secondary theorem. Local proof closure has been checked; no claim of human non-author review, priority, or repository CI promotion. Pending-source custody classification is preserved until review.
