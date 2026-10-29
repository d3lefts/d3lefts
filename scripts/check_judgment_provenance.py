#!/usr/bin/env python3
"""JP-01 descriptive influence checker. Python 3 stdlib only; not a causal-validity certificate."""
import argparse
import csv
import json
import math
import sys
from collections import defaultdict

ARMS = ("ordinary", "adversary", "blind")
DECISIONS = (1, 2, 3, 4)
REQUIRED = {"participant_id", "arm", "decision_id", "lean", "choice"}


class ContractError(ValueError):
    pass


def require(predicate, message):
    if not predicate:
        raise ContractError(message)


def analyze(rows, min_cell=2):
    require(isinstance(rows, list) and len(rows) > 0, "No observations")
    subjects = {}
    for i, row in enumerate(rows, 1):
        require(REQUIRED.issubset(row), "Missing CSV fields in row %d" % i)
        pid = str(row["participant_id"]).strip()
        arm = str(row["arm"]).strip()
        require(pid and pid.lower() not in {"nan", "none"}, "Empty participant ID")
        require(arm in ARMS, "Unknown arm in row %d" % i)
        d, z, y = (str(row[k]).strip() for k in ("decision_id", "lean", "choice"))
        require(d in {"1", "2", "3", "4"}, "Invalid decision_id in row %d" % i)
        require(z in {"0", "1"} and y in {"0", "1"}, "Lean/choice must be 0 or 1 in row %d" % i)
        d, z, y = int(d), int(z), int(y)
        if pid not in subjects:
            subjects[pid] = {"arm": arm, "records": {}}
        s = subjects[pid]
        require(s["arm"] == arm, "Participant changes arm: %s" % pid)
        require(d not in s["records"], "Duplicate participant-decision: %s/%d" % (pid, d))
        s["records"][d] = (z, y)
    for pid, s in subjects.items():
        require(set(s["records"]) == set(DECISIONS), "Incomplete decision set for %s" % pid)

    output = {}
    for arm in ARMS:
        part = [s for s in subjects.values() if s["arm"] == arm]
        require(len(part) >= 2 * min_cell, "Arm %s has too few independent participants" % arm)
        decision = {}
        for d in DECISIONS:
            grp = {z: [s["records"][d][1] for s in part if s["records"][d][0] == z] for z in (0, 1)}
            require(all(len(grp[z]) >= min_cell for z in (0, 1)),
                    "Sparse lean cell, arm %s decision %d" % (arm, d))
            mu0 = sum(grp[0]) / len(grp[0])
            mu1 = sum(grp[1]) / len(grp[1])
            decision[d] = {"n_lean0": len(grp[0]), "n_lean1": len(grp[1]),
                           "p_chooseA_lean0": mu0, "p_chooseA_lean1": mu1,
                           "lean_effect": mu1 - mu0}
        f = sum(decision[d]["lean_effect"] for d in DECISIONS) / len(DECISIONS)
        # Cluster sandwich influence, summing all four correlated decisions per reviewer.
        n = len(part)
        influences = []
        for s in part:
            val = 0.0
            for d in DECISIONS:
                z, y = s["records"][d]
                cell = decision[d]
                denom = cell["n_lean1"] if z else cell["n_lean0"]
                mu = cell["p_chooseA_lean1"] if z else cell["p_chooseA_lean0"]
                val += (1 if z else -1) * (y - mu) / denom / len(DECISIONS)
            influences.append(val)
        var = n / (n - 1) * sum(v * v for v in influences)
        se = math.sqrt(max(0.0, var))
        output[arm] = {"participants": n, "pooled_lean_effect": f,
                       "cluster_se": se, "ci95_normal": [f - 1.96 * se, f + 1.96 * se],
                       "decision_effects": {str(d): decision[d] for d in DECISIONS}}
    contrasts = {}
    for name, a, b in (("primary_ordinary_minus_blind", "ordinary", "blind"),
                       ("exploratory_ordinary_minus_adversary", "ordinary", "adversary")):
        delta = output[a]["pooled_lean_effect"] - output[b]["pooled_lean_effect"]
        se = math.hypot(output[a]["cluster_se"], output[b]["cluster_se"])
        contrasts[name] = {"estimate": delta, "cluster_se": se,
                           "ci95_normal": [delta - 1.96 * se, delta + 1.96 * se]}
    return {"format": "nightfall-judgment-provenance-v0.1",
            "status": "ANALYSIS_ONLY_NOT_EXPERIMENTALLY_VALIDATED",
            "participant_count": len(subjects),
            "unit_of_cluster": "participant_id",
            "primary_estimand": "equally weighted difference in A-choice probability by randomized lean",
            "arms": output, "contrasts": contrasts,
            "limitations": [
                "No proof of randomized allocation or source-blindness from CSV",
                "Normal cluster-sandwich intervals are descriptive, potentially unreliable in small samples",
                "Quality preservation, abstentions, consent, randomization, attrition and leakage are separately audited",
                "Synthetic self-tests are not participant data or effectiveness evidence"
            ]}


def synthetic_rows():
    result = []
    for arm in ARMS:
        for j in range(12):
            for d in DECISIONS:
                z = (j + d) % 2
                y = z if arm == "ordinary" else (z if arm == "adversary" and d <= 2 else 0)
                result.append({"participant_id": arm + "-" + str(j), "arm": arm,
                               "decision_id": str(d), "lean": str(z), "choice": str(y)})
    return result


def selftest():
    rows = synthetic_rows()
    result = analyze(rows)
    for arm, expected in (("ordinary", 1), ("adversary", 0.5), ("blind", 0)):
        assert math.isclose(result["arms"][arm]["pooled_lean_effect"], expected, abs_tol=1e-12)
    assert math.isclose(result["contrasts"]["primary_ordinary_minus_blind"]["estimate"], 1, abs_tol=1e-12)
    assert result["participant_count"] == 36
    mutations = [
        rows + [dict(rows[0])],
        rows[:-1],
        [dict(r, lean="2") if i == 0 else r for i, r in enumerate(rows)],
        [dict(r, arm="blind") if i == 0 else r for i, r in enumerate(rows)],
    ]
    for index, bad in enumerate(mutations):
        try:
            analyze(bad)
        except ContractError:
            continue
        raise AssertionError("Contract rejection failed for mutation %d" % index)
    # All output must be serializable without nonfinite floats.
    assert '"NaN"' not in json.dumps(result, allow_nan=False)
    print("JP-01 SYNTHETIC_FIXTURE: 36 pseudo-subjects, exact F=(1,0.5,0); 4 negative controls PASS")
    print("STATUS: schema and arithmetic self-test only; no humans, model trials or empirical finding")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("csv_path", nargs="?", help="CSV with participant_id,arm,decision_id,lean,choice")
    ap.add_argument("--self-test", action="store_true", help="Execute synthetic controls; no participant data")
    args = ap.parse_args()
    if args.self_test:
        selftest()
        return
    if not args.csv_path:
        ap.error("csv_path is required except in --self-test mode")
    try:
        with open(args.csv_path, newline="", encoding="utf-8-sig") as handle:
            reader = csv.DictReader(handle)
            require(reader.fieldnames is not None and REQUIRED.issubset(reader.fieldnames),
                    "Missing CSV header fields")
            result = analyze(list(reader))
        print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    except (ContractError, OSError) as exc:
        print("JP-01 REJECTED: %s" % exc, file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
