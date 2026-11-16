"""COMMONWEALTH OS v1.1: deterministic, closed-world synthetic effect guard.
No signatures, cryptography, legal interpretation, live effects, or real election security.
"""
from dataclasses import dataclass, field
from threading import Lock
from typing import FrozenSet
from hashlib import sha256
import json


class Blocked(RuntimeError):
    pass


@dataclass(frozen=True)
class Passport:
    tenant_id: str
    jurisdiction_id: str
    decision_id: str
    proposal_digest: str
    rule_digest: str
    election_proof_digest: str
    election_verified: bool
    legal_attested: bool
    authorized_effect_kinds: FrozenSet[str]
    max_per_effect: int
    authority_epoch: int
    challenge_epoch: int
    rule_epoch: int
    expires_at: int


@dataclass(frozen=True)
class Effect:
    tenant_id: str
    jurisdiction_id: str
    decision_id: str
    proposal_digest: str
    rule_digest: str
    kind: str
    amount: int
    effect_id: str


@dataclass
class InstitutionalState:
    tenant_id: str
    jurisdiction_id: str
    decision_id: str
    current_proposal_digest: str
    current_rule_digest: str
    authority_epoch: int = 1
    challenge_epoch: int = 1
    rule_epoch: int = 1
    stayed: bool = False
    revoked: bool = False
    budget_remaining: int = 100
    now: int = 100
    committed: dict = field(default_factory=dict)
    lock: Lock = field(default_factory=Lock, repr=False)


def authorize_and_commit(p: Passport, effect: Effect, state: InstitutionalState) -> dict:
    """A *model* of one atomic snapshot-and-effect transaction; no network I/O."""
    with state.lock:
        def require(predicate, label):
            if not predicate:
                raise Blocked(label)
        require(p.tenant_id == effect.tenant_id == state.tenant_id, "TENANT_MISMATCH")
        require(p.jurisdiction_id == effect.jurisdiction_id == state.jurisdiction_id,
                "JURISDICTION_MISMATCH")
        require(p.decision_id == effect.decision_id == state.decision_id, "DECISION_MISMATCH")
        require(bool(p.election_proof_digest) and p.election_verified, "ELECTION_UNVERIFIED")
        require(p.legal_attested, "LEGAL_AUTHORITY_UNASSESSED")
        require(p.proposal_digest == effect.proposal_digest == state.current_proposal_digest,
                "PROPOSAL_STALE_OR_WRONG")
        require(p.rule_digest == effect.rule_digest == state.current_rule_digest,
                "RULE_STALE_OR_WRONG")
        require(p.authority_epoch == state.authority_epoch and
                p.challenge_epoch == state.challenge_epoch and
                p.rule_epoch == state.rule_epoch, "EPOCH_STALE")
        require(not state.stayed and not state.revoked, "STAY_OR_REVOCATION")
        require(state.now <= p.expires_at, "PASSPORT_EXPIRED")
        require(effect.kind in p.authorized_effect_kinds, "OUTSIDE_EFFECT_SCOPE")
        require(0 <= effect.amount <= p.max_per_effect, "OUTSIDE_APPROVED_AMOUNT")
        require(effect.amount <= state.budget_remaining, "BUDGET_INSUFFICIENT")
        require(bool(effect.effect_id) and effect.effect_id not in state.committed,
                "REPLAYED_EFFECT")
        payload = {"effect_id":effect.effect_id, "decision_id":effect.decision_id,
                   "amount":effect.amount, "kind":effect.kind,
                   "authority_epoch":state.authority_epoch,
                   "challenge_epoch":state.challenge_epoch,
                   "rule_epoch":state.rule_epoch}
        receipt = {"status":"COMMITTED_IN_MODEL", "payload":payload,
                   "receipt_digest":sha256(json.dumps(payload,sort_keys=True).encode()).hexdigest()}
        state.budget_remaining -= effect.amount
        state.committed[effect.effect_id] = receipt
        return receipt


def retains_authorization_information(worlds, transcript, new_decision):
    """Finite DAP-CR1 checker; only tests supplied worlds and functions."""
    observed = {}
    for world in worlds:
        key = transcript(world)
        value = new_decision(world)
        if key in observed and observed[key] != value:
            return False
        observed[key] = value
    return True
