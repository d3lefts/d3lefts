#!/usr/bin/env python3
"""Fail closed on a Lake build log lacking clean named theorem axiom audits."""
from pathlib import Path
import re
import sys

ALLOWED = {"propext", "Classical.choice", "Quot.sound"}
TARGETS = [
    "Nightfall.Observability.ActualSourceQ2107Terminal.actual_source_q2_107_unconditional",
    "Nightfall.InfinitePiQ2Limit.source_q2_quadratic_limit",
    "Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_107",
    "Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_99",
    "Nightfall.InfinitePiQ2OriginalIndependence.source_coordinate_other_indepFun",
    "Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_test",
    "Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_mul_other",
    "Nightfall.InfinitePiQ2SourceHilbertTensor.sourceOtherProjection_tensor_ae",
    "Nightfall.InfinitePiQ2AllL2LabelIntertwining.sourceOtherProjectionCLM_intertwines_all_L2",
    "Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_commutes",
    "Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_triple_zero",
]


def audit(log: str) -> None:
    for target in TARGETS:
        pattern = re.compile(
            re.escape("'" + target + "'") +
            r" depends on axioms: \[([^\]]*)\]"
        )
        matches = pattern.findall(log)
        no_axioms = f"'{target}' does not depend on any axioms" in log
        if not matches and not no_axioms:
            raise ValueError(f"Missing named axiom audit: {target}")
        # The same declaration is printed by its original source and then
        # again by Nightfall/Main.lean during the single Lake dependency build.
        # Repetition is expected; contradictory or nonstandard reports fail.
        sets = [
            {a.strip() for a in receipt.split(",") if a.strip()}
            for receipt in matches
        ]
        if no_axioms:
            sets.append(set())
        if len(set(map(frozenset, sets))) != 1:
            raise ValueError(f"Inconsistent axiom reports for {target}: {sets}")
        actual = sets[0]
        unexpected = actual - ALLOWED
        if unexpected:
            raise ValueError(f"{target}: unexpected axioms {sorted(unexpected)}")
        # This is an INTEGRATED build receipt: every target must be audited
        # from the common Nightfall/Main.lean import as well as any source.
        integrated = re.compile(
            r"info: Nightfall/Main\.lean:\d+:\d+: " +
            re.escape("'" + target + "'") +
            r" depends on axioms: \[([^\]]*)\]"
        )
        if not integrated.search(log) and not re.search(
            r"info: Nightfall/Main\.lean:\d+:\d+: " +
            re.escape("'" + target + "'") +
            r" does not depend on any axioms", log
        ):
            raise ValueError(f"Missing shared Nightfall/Main axiom receipt: {target}")
        print(f"PASS named integrated axiom audit: {target} ({len(sets)} congruent receipts)")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: check_nightfall_integrated_axioms.py BUILD_LOG")
    audit(Path(sys.argv[1]).read_text(encoding="utf-8"))
