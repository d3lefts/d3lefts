#!/usr/bin/env python3
"""Audit actual Lean named axiom outputs; not a manuscript coverage checker."""
import re
import sys
from pathlib import Path
import json

def audit(text, allowed, expected=None):
    if "sorryAx" in text or re.search(r"\berror(?:\([^)]*\))?:",text):
        raise ValueError("Lean error or admitted axiom in audit log")
    names={}
    for name, payload in re.findall(r"'([^']+)' depends on axioms:\s*\[([^\]]*)\]", text, re.S):
        axioms={x.strip() for x in payload.split(",") if x.strip()}
        if not axioms <= allowed:
            raise ValueError(f"Forbidden axiom in {name}: {sorted(axioms-allowed)}")
        if name in names and names[name]!=sorted(axioms):
            raise ValueError(f"Conflicting audits for {name}")
        names[name]=sorted(axioms)
    for name in re.findall(r"'([^']+)' does not depend on any axioms",text):
        if name in names and names[name]:
            raise ValueError(f"Conflicting audits for {name}")
        names[name]=[]
    if not names or (expected is not None and set(names)!=set(expected)):
        raise ValueError("Named axiom audit missing or incomplete")
    return names

def main():
    lock=json.loads(Path("docs/lean-compiler-lock.json").read_text())
    expected=[
      "Nightfall.InfiniteFieldPhase.Terminal.infinite_field_phase_retrieval_causal_terminal",
      "Nightfall.ContinuousPhaseObstruction.no_continuous_final_row_all_dimensions",
      "Nightfall.GenuinePrefixPhase.causal_collision_of_genuine_prefix_zeros",
      "Nightfall.ProductSphereCausal.no_continuous_causal_exact_recovery_below",
      "Nightfall.AnnularBalancedDecode.balanced_code_injective",
      "Nightfall.AnnularBalancedDecode.balanced_residual_injective",
      "Nightfall.CausalNoise.cancellingNoise_bound",
      "Nightfall.CausalNoise.decoder_noise_floor",
      "Nightfall.EnvelopeErasure.envelope_erasure",
      "Nightfall.ProductBUDecoderRiskFloor.causal_decoder_risk_floor_of_product_sphere_zero",
      "Nightfall.ProductBUMixedRadius.known_radius_risk_of_mixed_product_sphere_zero",
      "Nightfall.ProductBUCausalScaling.causal_transcript_scaling",
    ]
    result=audit(Path(sys.argv[1]).read_text(),set(lock["allowed_axioms"]),expected)
    print(json.dumps({"scope":"implemented declarations only","named_axioms":result},indent=2))
if __name__=="__main__":
    main()
