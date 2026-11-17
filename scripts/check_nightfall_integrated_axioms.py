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
]


def audit(log: str) -> None:
    for target in TARGETS:
        pattern = re.compile(
            re.escape("'" + target + "'") +
            r" depends on axioms: \[([^\]]*)\]"
        )
        matches = pattern.findall(log)
        no_axioms = f"'{target}' does not depend on any axioms" in log
        if len(matches) + int(no_axioms) != 1:
            raise ValueError(f"Missing or ambiguous axiom audit: {target}")
        if matches:
            actual = {a.strip() for a in matches[0].split(",") if a.strip()}
            unexpected = actual - ALLOWED
            if unexpected:
                raise ValueError(f"{target}: unexpected axioms {sorted(unexpected)}")
        print(f"PASS named axiom audit: {target}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: check_nightfall_integrated_axioms.py BUILD_LOG")
    audit(Path(sys.argv[1]).read_text(encoding="utf-8"))
