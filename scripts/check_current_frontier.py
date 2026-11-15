#!/usr/bin/env python3
"""Fail-closed curated NIGHTFALL frontier: proof status is not PR popularity.

Checks that claims retain the intended scoped statement, source Git blob SHA,
named declaration and *historical* strict-compiler receipt. Does NOT run Lean,
verify remote CI online, establish physical source completeness, or prove novelty.

Current frontiers are intentionally NOT inferred from which open PR reports
the smallest coefficient.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path("research/catalogue/CURRENT_FRONTIER.json")
ALLOWED_PIN = "leanprover/lean4:v4.36.0-rc2"

# Dated, previously checked at each original head. A claim's canonical source
# still must match these immutable blobs; this is not a current-head Lean build.
ANCHORS = {
    "q2-unrestricted-364": (
        "kernel_proved_domain",
        "research/nightfall/formalization/observability/ActualSourceQ2364Terminal.lean",
        "5263d9da1ec2f12fbc8986c3698859faedb390a3",
        "Nightfall.Observability.ActualSourceQ2364Terminal.actual_source_q2_364_unconditional",
        43644790107, "a558a4dd7a2f2c7db521658c6d59d204758eb934",
    ),
    "q2-unrestricted-105": (
        "kernel_proved_domain",
        "research/nightfall/formalization/observability/ActualSourceQ2105Terminal.lean",
        "ed945639f7cbe26ba8fdb50d691127c01cdf863f",
        "Nightfall.Observability.ActualSourceQ2105Terminal.actual_source_q2_105_unconditional",
        43671321904, "ae8ebec96d6c3ce4a25fb42bc7ae6ba170ca9103",
    ),
    "q2-unrestricted-107": (
        "kernel_proved_domain",
        "research/nightfall/formalization/observability/ActualSourceQ2107Terminal.lean",
        "a1e81b41d6c14c7da3c7f8d1ecc376027a70059f",
        "Nightfall.Observability.ActualSourceQ2107Terminal.actual_source_q2_107_unconditional",
        43666215780, "e01039b24996befc3a3f7f32225362db8d1f8b42",
    ),
    "q2-unrestricted-96-six-cover-conditional": (
        "kernel_proved_implication_only",
        "research/nightfall/formalization/observability/ActualSourceQ296SixCover.lean",
        "8de1ad77a9f218d0df3673d8574ddd6592556865",
        "Nightfall.Observability.ActualSourceQ296SixCover.actual_source_q2_96_given_six_cover",
        43676624010, "6ec3d1541f521f40cf90c064e4b736279e7cfdc2",
    ),
    "q2-unrestricted-353-conditional": (
        "kernel_proved_implication_only",
        "research/archive/historical-proof-sources/ActualSourceQ2353Terminal_43644790107.lean",
        "342d872eb156998734dc7ce8223a2f482f865c42",
        "Nightfall.Observability.ActualSourceQ2353Terminal.actual_source_q2_353_given_sharp_section_budget",
        43644790107, "a558a4dd7a2f2c7db521658c6d59d204758eb934",
    ),
    "q2-shifted-107-conditional": (
        "kernel_proved_implication_only",
        "research/nightfall/formalization/q2_shifted/Q2ShiftedConditionalTargets.lean",
        "c91d0e9977ba93f3450dc6adf4367405d2af8e87",
        "Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_107",
        43650036932, "ea919d9455dcfaec6dc9bedea7a2324db15132b8",
    ),
    "q2-shifted-99-conditional": (
        "kernel_proved_implication_only",
        "research/nightfall/formalization/q2_shifted/Q2ShiftedConditionalTargets.lean",
        "c91d0e9977ba93f3450dc6adf4367405d2af8e87",
        "Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_99",
        43650036932, "ea919d9455dcfaec6dc9bedea7a2324db15132b8",
    ),
    "conditional-adversarial-agent-safety": (
        "kernel_proved_implication_only",
        "research/nightfall/formalization/agent_safety/ArbitraryAgentSafety.lean",
        "c0e42b193a383f7e4f7ec43728806483f9b3bf68",
        "Nightfall.AgentSafety.arbitrary_agent_all_horizons_safe",
        43639554615, "143b40513c25fd1849e7986c4809baa0402e1a7f",
    ),
    "semantic-fencing-v0.3": (
        "finite_checked_not_kernel",
        "research/nightfall/assurance/semantic-fencing-v0.3/README.md",
        "78b24296d35ba8cbb4c261914e23540498fc33ee",
        None,
        43648303705, "842341bdc8fe7a414cea399c2b5e53f480a78638",
    ),
}
COEFFICIENTS = {
    "q2-unrestricted-105": 105.741756923658,
    "q2-unrestricted-96-six-cover-conditional": 96.10039906698208,
    "q2-unrestricted-364": 364.5526832774,
    "q2-unrestricted-107": 107.3934498997707,
    "q2-unrestricted-353-conditional": 353.2929930769,
    "q2-shifted-107-conditional": 107.393,
    "q2-shifted-99-conditional": 99.2629850192,
}
REQUIRED_PREMISE_PARTS = {
    "q2-unrestricted-96-six-cover-conditional": ["cover"],
    "q2-unrestricted-353-conditional": ["section"],
    "q2-shifted-107-conditional": ["hilbert", "section"],
    "q2-shifted-99-conditional": ["hilbert", "section"],
    "conditional-adversarial-agent-safety": ["mediation", "environment", "atomic"],
    "semantic-fencing-v0.3": ["source", "atomic", "effect"],
}

def insist(ok: bool, reason: str) -> None:
    if not ok:
        raise ValueError(reason)

def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()

def audit(data: dict, root: Path = ROOT) -> dict:
    insist(data.get("schema") == "nightfall.frontier-evidence.v1", "Schema drift")
    insist(data.get("best_unrestricted_source_q2_certified") == "q2-unrestricted-105",
           "Best unconditional original-source Q2 falsely promoted")
    insist(data.get("unrestricted_sub100_unconditional") == "not_proved",
           "Unrestricted sub-100 proof falsely promoted")
    insist(data.get("operational_agent_boundary") == "not_verified",
           "Operational safety falsely promoted")
    insist(data.get("all_originality_claims") == "not_reviewed",
           "Novelty falsely promoted")
    claims = data.get("claims")
    insist(isinstance(claims, list), "Missing claims")
    ids = [x.get("id") for x in claims]
    insist(len(ids) == len(set(ids)) and set(ids) == set(ANCHORS),
           "Missing, duplicated, or unexpected frontier claim")
    for entry in claims:
        cid = entry["id"]
        status, source, sha, decl, run, head = ANCHORS[cid]
        insist(entry.get("status") == status, f"{cid}: proof status inflation")
        insist(entry.get("source") == source and entry.get("source_git_blob") == sha,
               f"{cid}: source custody drift")
        insist(entry.get("declaration") == decl, f"{cid}: named theorem changed")
        insist(entry.get("priority") == "unreviewed" and
               entry.get("external_referee") == "none" and
               entry.get("novel_record_status") == "not_assessed",
               f"{cid}: fabricated novelty or external review")
        insist(entry.get("physical_system_certificate") is False,
               f"{cid}: false physical assurance claim")
        receipt = entry.get("receipt", {})
        insist(receipt.get("run") == run and receipt.get("head") == head and
               receipt.get("outcome") == "success",
               f"{cid}: historical CI receipt misidentified")
        if status.startswith("kernel_"):
            insist(receipt.get("pin") == ALLOWED_PIN,
                   f"{cid}: wrong pinned Lean compiler")
        else:
            insist("NOT Lean" in receipt.get("scope", ""),
                   f"{cid}: finite evidence presented as Lean")
        limitations = entry.get("domain_limitations", [])
        insist(isinstance(limitations, list) and limitations,
               f"{cid}: source scope unspecified")
        added = entry.get("added_unproved_premises")
        insist(isinstance(added, list), f"{cid}: missing explicit premise list")
        if status == "kernel_proved_domain":
            insist(not added, f"{cid}: new premise in unconditional theorem")
        else:
            insist(len(added) > 0, f"{cid}: conditional status missing premises")
            joined = " ".join(added).lower()
            for part in REQUIRED_PREMISE_PARTS.get(cid, []):
                insist(part in joined, f"{cid}: missing unresolved condition: {part}")
        if cid in COEFFICIENTS:
            value = entry.get("coefficient_approx")
            insist(type(value) in (float, int) and abs(value - COEFFICIENTS[cid]) < 1e-8,
                   f"{cid}: coefficient or restriction changed")
        else:
            insist("coefficient_approx" not in entry,
                   f"{cid}: not a numerical influence bound")
        p = Path(source)
        insist(not p.is_absolute() and ".." not in p.parts, f"{cid}: unsafe path")
        full = root / p
        insist(full.is_file(), f"{cid}: source not found: {source}")
        content = full.read_bytes()
        insist(git_blob(content) == sha, f"{cid}: source bytes do not match original receipt")
        if decl is not None:
            short = decl.split(".")[-1]
            insist(re.search(r"\btheorem\s+" + re.escape(short) + r"\b",
                             content.decode("utf-8")) is not None,
                   f"{cid}: missing exact theorem declaration")
    return {"status": "PASS", "claims": len(claims),
            "best_unrestricted_q2": "105.741756923658, finite product, scoped",
            "unrestricted_sub100": "NOT PROVED",
            "physical_boundary": "NOT VERIFIED",
            "verification": "source and original PR-head receipt custody only (no Lean rerun)"}

def negative_controls(data: dict) -> int:
    def check_mutation(name: str, mutate) -> None:
        changed = copy.deepcopy(data)
        mutate(changed)
        try:
            audit(changed)
        except ValueError:
            return
        raise AssertionError(f"Failed negative control: {name}")
    def q(d, cid):
        return next(x for x in d["claims"] if x["id"] == cid)
    mutations = [
        ("source SHA forgery", lambda d: q(d, "q2-unrestricted-364").update(source_git_blob="0"*40)),
        ("fake successful run", lambda d: q(d, "q2-unrestricted-364")["receipt"].update(run=1)),
        ("unproved 99 promoted", lambda d: q(d, "q2-shifted-99-conditional").update(status="kernel_proved_domain")),
        ("unproved source hypotheses removed", lambda d: q(d, "q2-shifted-99-conditional").update(added_unproved_premises=[])),
        ("wrong source theorem", lambda d: q(d, "q2-unrestricted-364").update(declaration="Bad.fake")),
        ("C105 source SHA forgery", lambda d: q(d, "q2-unrestricted-105").update(source_git_blob="0"*40)),
        ("C96 conditional falsely promoted", lambda d: q(d, "q2-unrestricted-96-six-cover-conditional").update(status="kernel_proved_domain")),
        ("wrong best source", lambda d: q(d, "q2-unrestricted-107").update(source_git_blob="0"*40)),
        ("false certified frontier", lambda d: d.update(best_unrestricted_source_q2_certified="q2-shifted-99-conditional")),
        ("physical enforcement invented", lambda d: d.update(operational_agent_boundary="verified")),
        ("human originality invented", lambda d: q(d, "q2-unrestricted-364").update(priority="first-in-literature")),
        ("duplicate claim", lambda d: d["claims"].append(copy.deepcopy(d["claims"][0]))),
        ("wrong Lean compiler", lambda d: q(d, "q2-unrestricted-364")["receipt"].update(pin="Lean 4.35")),
        ("bad finite-as-Lean scope", lambda d: q(d, "semantic-fencing-v0.3")["receipt"].update(scope="strict Lean source")),
    ]
    for name, mutation in mutations:
        check_mutation(name, mutation)
    return len(mutations)

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    data = json.loads((ROOT / MANIFEST).read_text(encoding="utf-8"))
    print(json.dumps(audit(data), sort_keys=True))
    if args.self_test:
        print(f"PASS: {negative_controls(data)} adversarial frontier-status negative controls")

if __name__ == "__main__":
    main()
