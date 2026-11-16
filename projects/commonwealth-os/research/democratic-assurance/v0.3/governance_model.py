"""COMMONWEALTH 2030: bounded, closed-world authority-guard model.
Not an election system, cryptographic implementation, or deployment proof.
"""
from dataclasses import dataclass, replace
from typing import FrozenSet

@dataclass(frozen=True)
class Authorization:
    jurisdiction: str
    ordinance_id: str
    digest: str
    version: int
    source_epoch: int
    law_epoch: int
    human_adopted: bool
    quorum_verified: bool
    legal_reviewed: bool
    appropriation_valid: bool
    stayed: bool
    revoked: bool
    permitted_kinds: FrozenSet[str]
    ceiling: int

@dataclass(frozen=True)
class Environment:
    jurisdiction: str
    ordinance_id: str
    digest: str
    version: int
    source_epoch: int
    law_epoch: int

@dataclass(frozen=True)
class Effect:
    jurisdiction: str
    ordinance_id: str
    kind: str
    amount: int


def guard(cert: Authorization, env: Environment, effect: Effect) -> bool:
    """Allows an effect only with matching valid authority and state."""
    return (
        cert.jurisdiction == env.jurisdiction == effect.jurisdiction
        and cert.ordinance_id == env.ordinance_id == effect.ordinance_id
        and cert.digest == env.digest
        and cert.version == env.version
        and cert.source_epoch == env.source_epoch
        and cert.law_epoch == env.law_epoch
        and cert.human_adopted
        and cert.quorum_verified
        and cert.legal_reviewed
        and cert.appropriation_valid
        and not cert.stayed
        and not cert.revoked
        and effect.kind in cert.permitted_kinds
        and 0 <= effect.amount <= cert.ceiling
    )


def change_text(env: Environment, new_digest: str) -> Environment:
    return replace(env, digest=new_digest, version=env.version + 1)


def change_source(env: Environment) -> Environment:
    return replace(env, source_epoch=env.source_epoch + 1)


def change_law(env: Environment) -> Environment:
    return replace(env, law_epoch=env.law_epoch + 1)


class GuardedSink:
    """Trusted sink in this toy model: caller cannot alter effects without guard."""
    def __init__(self):
        self.committed = []

    def commit(self, cert: Authorization, env: Environment, effect: Effect):
        if not guard(cert, env, effect):
            return False
        self.committed.append(effect)
        return True
