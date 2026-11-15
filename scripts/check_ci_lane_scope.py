#!/usr/bin/env python3
"""Audit split CI lanes without depending on PyYAML.

Exact positive and negative controls ensure proof-only changes do not trigger
site browser tests and that frozen original-source regression steps were moved
rather than silently discarded. This is CI routing, not a mathematical proof.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = Path(".github/workflows/verify-site.yml")
FROZEN = Path(".github/workflows/nightfall-frozen-research-replay.yml")
RESEARCH_NAMES = {
    "Reject signed-overlap boundary and zero-extension regressions",
    "Verify PAS v2 finite DAG proof identities (integer-exact)",
    "Discovery Engine external worker acceptance and tamper tests",
    "Check adaptive granularity study with exact adversarial tests",
    "Run frozen paired held-out granularity benchmark",
    "Archive bounded synthetic study receipt",
    "Self-test offline publication-scope scanner",
    "Compile verification scripts and check machine-readable task ledger",
    "Compile exact conditional lower-envelope verifier",
    "Self-test independent exact convolution against direct arithmetic",
    "Check agent GMP source, exact-rational geometry and JSON receipt",
    "Independently audit adaptive finite-field decoder and sparse phase separator",
    "Verify extension-degree packing, exact optimality and nonadaptive obstruction",
    "Independently verify characteristic-three cancellation packing and one-query sharpness",
    "Verify projective phase-alphabet criterion and finite-subgroup shift covers",
    "Machine-replay frozen Sidon witness with two distinct exact algorithms",
    "Certify universal factor-network equality quotient",
    "Verify nonabelian involution-shadow theorem instance and universal erasure allocation",
    "Verify heterogeneous erasure reliability and full two-label Pareto frontier",
}
BROWSER_STEPS = (
    "Install browser test dependencies",
    "Verify ethereal theme across 26 pages and capture previews",
    "Browser smoke test (mobile, tablet, desktop)",
)
SITE_STEPS = (
    "Validate static pages, source links, anchors, and fallback catalogue",
    "Audit the public page contracts against a local static server",
    "Verify claim graph and report directly affected evidence",
    "Verify the product-space dossier visual and scientific-scope contract",
)
RESEARCH_GLOBS = (
    "research/nightfall/projects/**",
    "research/nightfall/discovery-engine/**",
    "research/nightfall/agent-reports/**",
)

def demand(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)

def names(wf: str) -> set[str]:
    return set(re.findall(r"(?m)^      - name: (.+)$", wf))

def event_block(wf: str) -> str:
    start = wf.find("\non:\n")
    demand(start >= 0, "Missing workflow event definition")
    rem = wf[start+1:]
    end = re.search(r"(?m)^[A-Za-z_][A-Za-z_-]*:", rem[3:])
    return rem if end is None else rem[:3+end.start()]

def audit(site: str, frozen: str) -> dict:
    sn, rn = names(site), names(frozen)
    demand(not (sn & RESEARCH_NAMES), "Research verifier still duplicates browser lane")
    demand(RESEARCH_NAMES.issubset(rn), f"Research steps lost: {sorted(RESEARCH_NAMES-rn)}")
    demand(all(x in sn and x not in rn for x in BROWSER_STEPS + SITE_STEPS),
           "Site/browser verifier moved or mixed into research lane")
    sev = event_block(site)
    rev = event_block(frozen)
    demand('"docs/**"' in sev and '"scripts/**"' in sev,
           "Site code and docs triggers lost")
    demand('research/nightfall/**' not in sev,
           "Broad proof-only source changes still trigger browser suite")
    demand('"research/nightfall/**"' not in site,
           "Accidental broad research site trigger")
    demand(all(x in rev for x in RESEARCH_GLOBS),
           "Focused frozen research triggers missing")
    demand("workflow_dispatch:" in sev and "workflow_dispatch:" in rev,
           "Manual diagnostic capability lost")
    demand("cancel-in-progress: true" in site and "cancel-in-progress: true" in frozen,
           "Stale-run cancellation missing")
    demand("retention-days: 90" in frozen and
           "name: nightfall-granularity-study" in frozen,
           "Frozen reproducibility artifact lost")
    demand("research/nightfall/formalization/**" not in rev,
           "Unrelated Q2 experiments would retrigger frozen site-era checks")
    return {"status":"PASS","site_named_steps":len(sn),
            "focused_research_named_steps":len(rn),
            "migrated_research_steps":len(RESEARCH_NAMES),
            "mathematical_theorem_certification":False}

def negative_controls(site: str, frozen: str) -> int:
    pairs = [
        ("unwanted wide research trigger",
         site.replace('      - "docs/**"\n',
                      '      - "docs/**"\n      - "research/nightfall/**"\n',1),
         frozen),
        ("removed original proof replay",site,
         frozen.replace("      - name: Compile exact conditional lower-envelope verifier",
                        "      - name: MISSING exact conditional lower-envelope verifier",1)),
        ("mixed site into research",site,
         frozen.replace("      - name: Verify PAS v2 finite DAG proof identities (integer-exact)",
                        "      - name: Browser smoke test (mobile, tablet, desktop)",1)),
        ("uncancelled browser run",site.replace("cancel-in-progress: true","cancel-in-progress: false",1),frozen),
        ("no frozen artifact",site,frozen.replace("retention-days: 90","retention-days: 0",1)),
        ("lost public docs trigger",site.replace('      - "docs/**"\n','',1),frozen),
        ("over-broad Q2 frozen replay",site,frozen.replace("      - 'research/nightfall/projects/**'",
                                           "      - 'research/nightfall/formalization/**'",1))
    ]
    for name, changed_site, changed_frozen in pairs:
        try:
            audit(changed_site, changed_frozen)
        except ValueError:
            continue
        raise ValueError(f"Fail-open CI routing mutation: {name}")
    return len(pairs)

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--self-test",action="store_true")
    args=p.parse_args()
    site=(ROOT/SITE).read_text()
    frozen=(ROOT/FROZEN).read_text()
    print(audit(site,frozen))
    if args.self_test:
        print(f"PASS: {negative_controls(site,frozen)} CI routing negative controls")
