"""NIGHTFALL Democratic Assurance Passport: deliberately narrow executable model.

This is NOT a voting protocol, a cryptographic verifier, a legal opinion,
proof of an empirical democratic property, or a deployed effect boundary.
Boolean attestations are EXTERNAL assumptions, not proved by this program.
"""
from dataclasses import dataclass
from typing import FrozenSet, Tuple
from hashlib import sha256

@dataclass(frozen=True)
class Passport:
    institution: str
    resolution_id: str
    proposal_hash: str
    rule_hash: str
    voter_roll_epoch: int
    law_epoch: int
    evidence_epoch: int
    budget_epoch: int
    issued_at: int
    expires_at: int
    electorate_count: int
    ballots_count: int
    yes_count: int
    no_count: int
    abstain_count: int
    quorum_min: int
    yes_fraction_num: int
    yes_fraction_den: int
    # External certified claims, no crypto or legal semantics implemented here:
    election_proof_checked: bool
    eligibility_uniqueness_attested: bool
    human_final_vote_attested: bool
    competent_authority_attested: bool
    procedure_attested: bool
    rights_attested: bool
    lawful_budget_attested: bool
    in_person_alternative_attested: bool
    allowed_kinds: FrozenSet[str]
    ceiling: int

@dataclass(frozen=True)
class World:
    institution: str
    resolution_id: str
    proposal_hash: str
    rule_hash: str
    voter_roll_epoch: int
    law_epoch: int
    evidence_epoch: int
    budget_epoch: int
    now: int
    stayed: bool
    revoked: bool
    # A complete metadata oracle is ASSUMED to report these flags correctly.
    authority_current: bool
    budget_current: bool
    rights_clear: bool

@dataclass(frozen=True)
class Effect:
    institution: str
    resolution_id: str
    effect_id: str
    kind: str
    amount: int


def tally_passed(p: Passport) -> bool:
    """A demonstrative quorum/approval predicate, not a universal legal rule."""
    return (
        p.electorate_count >= 1
        and 0 <= p.ballots_count <= p.electorate_count
        and 0 <= p.yes_count and 0 <= p.no_count and 0 <= p.abstain_count
        and p.yes_count+p.no_count+p.abstain_count == p.ballots_count
        and 0 <= p.quorum_min <= p.electorate_count
        and p.ballots_count >= p.quorum_min
        and 0 < p.yes_fraction_num <= p.yes_fraction_den
        and p.yes_count+p.no_count > 0
        and p.yes_count * p.yes_fraction_den >=
            p.yes_fraction_num * (p.yes_count+p.no_count)
    )


def permit(p: Passport, w: World, e: Effect) -> bool:
    """Closed-world authorization predicate; facts supplied by trusted oracles."""
    identity = (p.institution == w.institution == e.institution and
                p.resolution_id == w.resolution_id == e.resolution_id and
                p.proposal_hash == w.proposal_hash and
                p.rule_hash == w.rule_hash)
    epoch = (p.voter_roll_epoch == w.voter_roll_epoch and
             p.law_epoch == w.law_epoch and
             p.evidence_epoch == w.evidence_epoch and
             p.budget_epoch == w.budget_epoch)
    attested = all((p.election_proof_checked,
                    p.eligibility_uniqueness_attested,
                    p.human_final_vote_attested,
                    p.competent_authority_attested,
                    p.procedure_attested,
                    p.rights_attested,
                    p.lawful_budget_attested))
    # A participation alternative must be assessed but, deliberately, it is not
    # treated as a legal sufficiency rule in this generic voting model.
    return (identity and epoch and attested and tally_passed(p)
            and p.issued_at <= w.now <= p.expires_at
            and not w.stayed and not w.revoked
            and w.authority_current and w.budget_current and w.rights_clear
            and e.kind in p.allowed_kinds
            and 0 <= e.amount <= p.ceiling)


class AtomicGuard:
    """In-memory effect sink; the sole path to effects is ASSUMED in the theorem."""
    def __init__(self):
        self.commits = []
        self.used_ids = set()

    def commit(self, passport: Passport, world: World, effect: Effect) -> Tuple[bool, str]:
        if effect.effect_id in self.used_ids:
            return False, 'duplicate-effect-id'
        if not permit(passport, world, effect):
            return False, 'invalid-current-authority'
        # The snapshot-to-effect atomicity below is modeled by one Python call.
        # Real distributed providers can violate this assumption.
        evidence = '|'.join((passport.institution, passport.resolution_id,
                             passport.proposal_hash, effect.effect_id,
                             str(world.law_epoch), str(world.evidence_epoch)))
        receipt = sha256(evidence.encode('utf8')).hexdigest()
        self.commits.append((effect, receipt, world))
        self.used_ids.add(effect.effect_id)
        return True, receipt
