"""Scoped FSx property guard ONLY, not a complete mission verifier.

Used to test real local end-to-end enforcement economics and distinguish
the protected-property check from full permission. A template with another
unauthorized resource may pass this guard; negative control MUST demonstrate
that. NEVER deploy as an authority policy.
"""
from independent_effect_verifier import _check_fsx, check_baseline, EffectViolation

def _one_fsx(t):
    found = [r.get("Properties", {}) for r in t["Resources"].values()
             if r.get("Type") == "AWS::Organizations::Policy"
             and r.get("Properties", {}).get("Name") == "Deny-FSx-Exports"]
    if len(found) != 1:
        raise EffectViolation("missing or ambiguous protected policy")
    return found[0]

def check_promotion(baseline, candidate, mission_policy):
    if not isinstance(candidate, dict) or not isinstance(mission_policy, dict):
        raise EffectViolation("invalid scoped verifier inputs")
    _check_fsx(candidate["Resources"])
    if _one_fsx(baseline).get("Content") != _one_fsx(candidate).get("Content"):
        raise EffectViolation("protected policy content changed")
    return {"scope": "FSx protected policy content only",
            "complete_mission_verifier": False}
