#!/usr/bin/env python3
"""Pure offline, fail-closed authorization boundary prototype for ASUA.

The trusted runner, NOT the LLM, supplies the user-authored exact grants.
Tool content and agent proposals are untrusted and cannot create grants.
This module makes no provider calls and executes no external actions.

Full AgentDojo integration, task grant parsing, utility and ASR remain open.
"""
from dataclasses import dataclass
from typing import Mapping


@dataclass(frozen=True)
class Grant:
    tool: str
    operation: str
    parameters_fingerprint: str


@dataclass(frozen=True)
class Proposal:
    tool: str
    operation: str
    parameters_fingerprint: str
    requested_by: str  # e.g. "tool_result", "assistant", "user"


@dataclass(frozen=True)
class Decision:
    allowed: bool
    reason: str


VALID_ORIGINS = frozenset({"tool_result", "assistant", "user"})
# No untrusted source can change this policy.
SENSITIVE_OPERATIONS = frozenset({"send", "write", "delete", "transfer",
                                  "share", "change_permission", "purchase"})


def decide(grants: tuple[Grant, ...], proposal: Proposal,
           *, read_only: frozenset[str] = frozenset()) -> Decision:
    """Approve only an exact trusted user grant or an explicitly safe read op.

    The parameters_fingerprint MUST be a digest of the validated *complete*
    tool arguments, produced by the trusted runner. No omissions, wildcards,
    LLM-provided hashes, semantic matching, or loose recipient matching.
    """
    if type(proposal) is not Proposal:
        return Decision(False, "invalid_proposal")
    fields = (proposal.tool, proposal.operation,
              proposal.parameters_fingerprint, proposal.requested_by)
    if any(type(s) is not str or not s.strip() for s in fields):
        return Decision(False, "malformed_metadata")
    if proposal.requested_by not in VALID_ORIGINS:
        return Decision(False, "untrusted_claimed_origin")
    if not isinstance(grants, tuple) or any(type(g) is not Grant for g in grants):
        return Decision(False, "untrusted_grant_table")
    for grant in grants:
        if (grant.tool == proposal.tool
            and grant.operation == proposal.operation
            and grant.parameters_fingerprint == proposal.parameters_fingerprint):
            return Decision(True, "exact_trusted_user_authorization")
    if (proposal.operation == "read"
        and proposal.tool in read_only
        and proposal.requested_by in VALID_ORIGINS):
        return Decision(True, "explicit_runner_read_allowlist")
    return Decision(False, ("sensitive_action_without_exact_grant"
                            if proposal.operation in SENSITIVE_OPERATIONS
                            else "no_exact_runner_grant"))


def canonical_fingerprint(args: Mapping) -> str:
    """Create a canonical argument fingerprint outside any tool-result content.

    Caller must validate schema, normalize URLs/addresses, block duplicate keys,
    and confirm the represented parameters are complete *before* using this.
    """
    import hashlib
    import json
    if type(args) is not dict:
        raise TypeError("trusted runner must pass a dict")
    encoded = json.dumps(args, sort_keys=True, separators=(",", ":"),
                         allow_nan=False, ensure_ascii=True).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()
