"""Finite Commonwealth proof-passport semantics; research checker, NOT voting software.

Only claims soundness relative to supplied authenticated, truthful facts and an
atomic fully mediated transition. No cryptography, legal interpretation, or identity
proofing is performed here. Python 3.11+; no external dependencies.
"""
from dataclasses import dataclass
from itertools import combinations
from typing import Callable, Hashable, Mapping, Sequence

World = Mapping[str, Hashable]


@dataclass(frozen=True)
class Observation:
    name: str
    cost: int
    read: Callable[[World], Hashable]

    def __post_init__(self):
        if self.cost <= 0:
            raise ValueError('Observation costs must be positive integers')


def consistent_worlds(worlds: Sequence[World], answers: Mapping[str, Hashable],
                      queries: Sequence[Observation]) -> list[World]:
    by_name = {q.name: q for q in queries}
    if len(by_name) != len(queries):
        raise ValueError('Query names must be unique')
    if not set(answers).issubset(by_name):
        raise ValueError('Unknown query name')
    return [w for w in worlds if all(by_name[n].read(w) == v for n, v in answers.items())]


def robustly_authorized(worlds: Sequence[World], answers: Mapping[str, Hashable],
                        queries: Sequence[Observation], authorized: Callable[[World], bool]) -> bool:
    """Fail closed: a nonempty consistent world class must ALL be authorized."""
    remaining = consistent_worlds(worlds, answers, queries)
    return bool(remaining) and all(authorized(w) for w in remaining)


def minimum_nominal_certificate(worlds: Sequence[World], nominal: World,
                                queries: Sequence[Observation],
                                authorized: Callable[[World], bool]) -> tuple[int, tuple[str, ...]] | None:
    """Exact minimum COST along one nominal authorized world's transcript.

    Static, finite, zero-error, deterministic named observations. Adaptive policies
    cannot improve nominal-path cost: that path itself is a query subset hitting
    each unauthorized world's difference support.
    """
    if not authorized(nominal) or nominal not in worlds:
        raise ValueError('Nominal world must belong to W and be authorized')
    if len({q.name for q in queries}) != len(queries):
        raise ValueError('Query names must be unique')
    bad = [w for w in worlds if not authorized(w)]
    supports = [frozenset(q.name for q in queries if q.read(w) != q.read(nominal)) for w in bad]
    if any(not s for s in supports):
        return None  # indistinguishable unauthorized world
    best: tuple[int, tuple[str, ...]] | None = None
    for k in range(len(queries) + 1):
        for selected in combinations(queries, k):
            selected_names = frozenset(q.name for q in selected)
            if all(selected_names & s for s in supports):
                candidate = (sum(q.cost for q in selected), tuple(q.name for q in selected))
                if best is None or candidate < best:
                    best = candidate
    return best


@dataclass(frozen=True)
class Epoch:
    rule: int
    electorate: int
    legal: int
    budget: int
    appeals: int


@dataclass(frozen=True)
class Passport:
    tenant: str
    decision_id: str
    proposal_digest: str
    rule_digest: str
    epoch: Epoch
    effect_kind: str
    amount_ceiling: int
    expires_at: int
    # Assumed trusted attestations; no validation of underlying protocols here.
    authenticated: bool
    vote_valid_attested: bool
    procedure_valid_attested: bool
    legal_authority_attested: bool
    rights_valid_attested: bool


@dataclass(frozen=True)
class CurrentState:
    tenant: str
    decision_id: str
    proposal_digest: str
    rule_digest: str
    epoch: Epoch
    now: int
    legal_authority_current: bool
    rights_current: bool
    budget_current: bool
    stayed: bool
    revoked: bool


@dataclass(frozen=True)
class Effect:
    effect_id: str
    tenant: str
    decision_id: str
    kind: str
    amount: int


def permit(p: Passport, s: CurrentState, x: Effect) -> bool:
    """Pure reference predicate; external attestation truth is an assumption."""
    return (
        p.authenticated and p.vote_valid_attested
        and p.procedure_valid_attested and p.legal_authority_attested
        and p.rights_valid_attested
        and p.tenant == s.tenant == x.tenant
        and p.decision_id == s.decision_id == x.decision_id
        and p.proposal_digest == s.proposal_digest
        and p.rule_digest == s.rule_digest
        and p.epoch == s.epoch
        and s.legal_authority_current and s.rights_current and s.budget_current
        and not s.stayed and not s.revoked
        and 0 <= s.now <= p.expires_at
        and x.kind == p.effect_kind
        and 0 <= x.amount <= p.amount_ceiling
    )


class AtomicSink:
    """Sequential abstraction of atomic inspect-and-commit; not a DB implementation.

    Caller must supply the actual state at the transaction linearization point.
    Assumes all effects of modeled kind go exclusively through this sink.
    """
    def __init__(self) -> None:
        self.used: set[str] = set()
        self.commits: list[tuple[Effect, CurrentState, Passport]] = []

    def try_commit(self, p: Passport, state_at_commit: CurrentState, x: Effect) -> bool:
        if x.effect_id in self.used or not permit(p, state_at_commit, x):
            return False
        self.used.add(x.effect_id)
        self.commits.append((x, state_at_commit, p))
        return True

    def invariant(self) -> bool:
        ids = [x.effect_id for x, _, _ in self.commits]
        return len(ids) == len(set(ids)) and all(permit(p, s, x) for x, s, p in self.commits)
