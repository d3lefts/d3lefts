"""Offline-only, allowlisted adapters for fictional legislative source snapshots."""
from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIXTURES = HERE / 'fixtures'
ALLOWLIST = {
    'house': ('house.json', 'SYNTH_HOUSE', 'HOUSE'),
    'senate': ('senate.json', 'SYNTH_SENATE', 'SENATE'),
    'municipal': ('municipal.json', 'SYNTH_MUNICIPAL', 'MUNICIPAL'),
    'issues': ('issues.json', 'SYNTH_ISSUES', 'ISSUES'),
}


class SyntheticOnlyError(ValueError):
    """Import violates the hard synthetic-data boundary."""


@dataclass(frozen=True)
class SourceSnapshot:
    source_id: str
    system: str
    chamber: str
    jurisdiction: str
    digest: str
    payload: dict


class FixtureAdapter:
    """Adapter accepts exactly one shipped fixture and NEVER fetches URLs."""
    def __init__(self, key: str):
        if key not in ALLOWLIST:
            raise SyntheticOnlyError('Source adapter not allowlisted')
        self.key = key

    def load(self) -> SourceSnapshot:
        filename, system, chamber = ALLOWLIST[self.key]
        raw = (FIXTURES / filename).read_bytes()
        data = json.loads(raw)
        if (data.get('schema_version') != 1 or data.get('synthetic') is not True
                or data.get('source_system') != system or data.get('chamber') != chamber
                or data.get('source_id') != f'fixture://commonwealth/{self.key}/v1'
                or not str(data.get('jurisdiction', '')).startswith('fictional-')):
            raise SyntheticOnlyError('Fixture header is not a supported synthetic source')
        if chamber == 'ISSUES':
            if set(data) != {'schema_version', 'synthetic', 'source_system', 'chamber',
                             'source_id', 'jurisdiction', 'issues', 'correspondence'}:
                raise SyntheticOnlyError('Unexpected issue source fields')
        elif set(data) != {'schema_version', 'synthetic', 'source_system', 'chamber',
                            'source_id', 'jurisdiction', 'people', 'tenures', 'questions', 'votes'}:
            raise SyntheticOnlyError('Unexpected legislative source fields')
        return SourceSnapshot(data['source_id'], system, chamber, data['jurisdiction'],
                              sha256(raw).hexdigest(), data)


def load_all() -> list[SourceSnapshot]:
    return [FixtureAdapter(key).load() for key in ALLOWLIST]
