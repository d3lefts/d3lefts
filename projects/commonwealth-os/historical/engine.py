"""Append-only fictional rollcall store, exact tenure resolution and audited links."""
from __future__ import annotations

from datetime import date
from hashlib import sha256
import json
import re
import sqlite3
from pathlib import Path

from .adapters import SourceSnapshot, SyntheticOnlyError, load_all

CHOICES = {'YEA', 'NAY', 'PRESENT', 'NOT_VOTING'}
KINDS = {'FINAL_PASSAGE', 'AMENDMENT', 'CLOTURE', 'MOTION', 'NOMINATION', 'TABLING'}
RELATIONS = {'EXACT_QUESTION', 'SUBSTANTIVE_REVIEWED', 'TOPIC_ONLY', 'UNREVIEWED'}
CHAMBERS = {'HOUSE', 'SENATE', 'MUNICIPAL'}
ID = re.compile(r'^fx-[a-z0-9-]{2,100}$')
DATE_END = '9999-12-31'


def canonical(value: object) -> str:
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(',', ':'))


def digest(value: object) -> str:
    return sha256(canonical(value).encode('utf-8')).hexdigest()


def valid_date(value: str) -> str:
    try:
        parsed = date.fromisoformat(value)
    except (ValueError, TypeError) as exc:
        raise SyntheticOnlyError(f'Bad ISO date: {value}') from exc
    if parsed.isoformat() != value:
        raise SyntheticOnlyError(f'Noncanonical date: {value}')
    return value


def fixture_id(value: str) -> str:
    if not isinstance(value, str) or not ID.fullmatch(value):
        raise SyntheticOnlyError(f'Nonfictional or invalid identifier: {value}')
    return value


def connect(path: str) -> sqlite3.Connection:
    connection = sqlite3.connect(path, timeout=10, isolation_level=None)
    connection.row_factory = sqlite3.Row
    connection.execute('PRAGMA foreign_keys=ON')
    connection.execute('PRAGMA busy_timeout=10000')
    return connection


def initialize(path: str) -> None:
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    with connect(path) as conn:
        conn.executescript('''
        CREATE TABLE IF NOT EXISTS sources (
          source_id TEXT PRIMARY KEY, system TEXT NOT NULL, chamber TEXT NOT NULL,
          jurisdiction TEXT NOT NULL, digest TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS people (
          person_id TEXT PRIMARY KEY, name TEXT NOT NULL, source_id TEXT NOT NULL REFERENCES sources(source_id));
        CREATE TABLE IF NOT EXISTS tenures (
          tenure_id TEXT PRIMARY KEY, person_id TEXT NOT NULL REFERENCES people(person_id),
          chamber TEXT NOT NULL, jurisdiction TEXT NOT NULL, seat TEXT NOT NULL,
          district TEXT NOT NULL, valid_from TEXT NOT NULL, valid_to TEXT NOT NULL,
          source_id TEXT NOT NULL REFERENCES sources(source_id), digest TEXT NOT NULL,
          CHECK(valid_from < valid_to));
        CREATE TABLE IF NOT EXISTS questions (
          question_id TEXT PRIMARY KEY, chamber TEXT NOT NULL, jurisdiction TEXT NOT NULL,
          held_on TEXT NOT NULL, kind TEXT NOT NULL, rollcall_type TEXT NOT NULL,
          title TEXT NOT NULL, proposition TEXT NOT NULL, result TEXT NOT NULL,
          source_id TEXT NOT NULL REFERENCES sources(source_id), digest TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS votes (
          record_id TEXT PRIMARY KEY, question_id TEXT NOT NULL REFERENCES questions(question_id),
          person_id TEXT NOT NULL REFERENCES people(person_id), choice TEXT NOT NULL,
          supersedes TEXT REFERENCES votes(record_id), source_id TEXT NOT NULL REFERENCES sources(source_id),
          digest TEXT NOT NULL);
        CREATE UNIQUE INDEX IF NOT EXISTS one_superseder ON votes(supersedes) WHERE supersedes IS NOT NULL;
        CREATE TABLE IF NOT EXISTS issues (
          issue_id TEXT PRIMARY KEY, title TEXT NOT NULL, proposition TEXT NOT NULL,
          source_id TEXT NOT NULL REFERENCES sources(source_id));
        CREATE TABLE IF NOT EXISTS correspondence (
          link_id TEXT PRIMARY KEY, issue_id TEXT NOT NULL REFERENCES issues(issue_id),
          question_id TEXT NOT NULL REFERENCES questions(question_id),
          relation TEXT NOT NULL, reviewer TEXT NOT NULL, rationale TEXT NOT NULL,
          source_id TEXT NOT NULL REFERENCES sources(source_id), digest TEXT NOT NULL,
          UNIQUE(issue_id, question_id));
        ''')
        for table in ('sources', 'people', 'tenures', 'questions', 'votes', 'issues', 'correspondence'):
            for action in ('UPDATE', 'DELETE'):
                conn.execute(f'''CREATE TRIGGER IF NOT EXISTS immutable_{table}_{action.lower()}
                  BEFORE {action} ON {table} BEGIN SELECT RAISE(ABORT, 'immutable historical record'); END''')


def _row(conn: sqlite3.Connection, table: str, key: str, value: str):
    return conn.execute(f'SELECT * FROM {table} WHERE {key}=?', (value,)).fetchone()


def _assert_new(conn: sqlite3.Connection, table: str, key: str, value: str):
    if _row(conn, table, key, value):
        raise SyntheticOnlyError(f'Conflicting or reused immutable {table} id: {value}')


def ingest(conn: sqlite3.Connection, snapshots: list[SourceSnapshot]) -> dict:
    """All sources, people, tenures, votes and links commit together or not at all.

    Replaying identical frozen source digests is idempotent; a changed digest
    for an existing source ID fails closed. There is no network import path.
    """
    conn.execute('BEGIN IMMEDIATE')
    try:
        existing = {r['source_id']: r['digest'] for r in conn.execute('SELECT source_id,digest FROM sources')}
        supplied = {s.source_id: s.digest for s in snapshots}
        if len(supplied) != len(snapshots) or set(supplied) != {
            f'fixture://commonwealth/{key}/v1' for key in ('house', 'senate', 'municipal', 'issues')
        }:
            raise SyntheticOnlyError('Exactly four allowlisted fixture snapshots required')
        if any(s.source_id in existing and existing[s.source_id] != s.digest for s in snapshots):
            raise SyntheticOnlyError('Frozen source changed: new version and review required')
        if all(s.source_id in existing for s in snapshots):
            conn.commit()
            return {'status': 'UNCHANGED', 'source_count': len(existing)}
        if any(s.source_id in existing for s in snapshots):
            raise SyntheticOnlyError('Partial historical corpus is not admissible')
        for s in snapshots:
            conn.execute('INSERT INTO sources VALUES(?,?,?,?,?)',
                         (s.source_id, s.system, s.chamber, s.jurisdiction, s.digest))
        for s in snapshots:
            if s.chamber == 'ISSUES':
                continue
            for p in s.payload['people']:
                fixture_id(p['person_id'])
                _assert_new(conn, 'people', 'person_id', p['person_id'])
                conn.execute('INSERT INTO people VALUES(?,?,?)',
                             (p['person_id'], p['name'], s.source_id))
            for t in s.payload['tenures']:
                fixture_id(t['tenure_id']); fixture_id(t['person_id'])
                start, end = valid_date(t['from']), valid_date(t['to'])
                if not start < end:
                    raise SyntheticOnlyError('Invalid tenure interval')
                if not _row(conn, 'people', 'person_id', t['person_id']):
                    raise SyntheticOnlyError('Unknown person in tenure')
                if conn.execute('''SELECT 1 FROM tenures WHERE chamber=? AND jurisdiction=? AND seat=?
                      AND valid_from<? AND valid_to>?''',
                      (s.chamber, s.jurisdiction, t['seat'], end, start)).fetchone():
                    raise SyntheticOnlyError('Overlapping tenure for same seat')
                conn.execute('INSERT INTO tenures VALUES(?,?,?,?,?,?,?,?,?,?)',
                             (t['tenure_id'], t['person_id'], s.chamber, s.jurisdiction,
                              t['seat'], t['district'], start, end, s.source_id, digest(t)))
            for q in s.payload['questions']:
                fixture_id(q['question_id']); valid_date(q['date'])
                if q['kind'] not in KINDS or q['rollcall_type'] not in ('RECORDED', 'VOICE'):
                    raise SyntheticOnlyError('Invalid question procedure or rollcall type')
                conn.execute('INSERT INTO questions VALUES(?,?,?,?,?,?,?,?,?,?,?)',
                             (q['question_id'], s.chamber, s.jurisdiction, q['date'],
                              q['kind'], q['rollcall_type'], q['title'], q['proposition'],
                              q['result'], s.source_id, digest(q)))
            for v in s.payload['votes']:
                fixture_id(v['record_id']); fixture_id(v['person_id']); fixture_id(v['question_id'])
                if v['choice'] not in CHOICES:
                    raise SyntheticOnlyError('Invalid recorded position')
                question = _row(conn, 'questions', 'question_id', v['question_id'])
                if not question or question['source_id'] != s.source_id or question['rollcall_type'] != 'RECORDED':
                    raise SyntheticOnlyError('Vote does not refer to a recorded question from same source')
                if not conn.execute('''SELECT 1 FROM tenures WHERE person_id=? AND chamber=?
                    AND jurisdiction=? AND valid_from<=? AND valid_to>?''',
                    (v['person_id'], s.chamber, s.jurisdiction, question['held_on'], question['held_on'])).fetchone():
                    raise SyntheticOnlyError('Member not in office at vote date')
                prior = v.get('supersedes')
                if prior is not None:
                    fixture_id(prior)
                    old = _row(conn, 'votes', 'record_id', prior)
                    if not old or old['question_id'] != v['question_id'] or old['person_id'] != v['person_id']:
                        raise SyntheticOnlyError('Invalid correction/supersession link')
                elif conn.execute('''SELECT 1 FROM votes WHERE person_id=? AND question_id=?''',
                                  (v['person_id'], v['question_id'])).fetchone():
                    raise SyntheticOnlyError('Duplicate member position without correction')
                conn.execute('INSERT INTO votes VALUES(?,?,?,?,?,?,?)',
                             (v['record_id'], v['question_id'], v['person_id'],
                              v['choice'], prior, s.source_id, digest(v)))
        issue_snapshot = next(s for s in snapshots if s.chamber == 'ISSUES')
        for item in issue_snapshot.payload['issues']:
            fixture_id(item['issue_id'])
            conn.execute('INSERT INTO issues VALUES(?,?,?,?)',
                         (item['issue_id'], item['title'], item['proposition'], issue_snapshot.source_id))
        for link in issue_snapshot.payload['correspondence']:
            fixture_id(link['link_id']); fixture_id(link['issue_id']); fixture_id(link['question_id'])
            if link['relation'] not in RELATIONS or not link['reviewer'].startswith('fictional-') or not link['rationale']:
                raise SyntheticOnlyError('Unreviewed or malformed correspondence provenance')
            issue = _row(conn, 'issues', 'issue_id', link['issue_id'])
            question = _row(conn, 'questions', 'question_id', link['question_id'])
            if not issue or not question:
                raise SyntheticOnlyError('Correspondence references missing issue/question')
            if link['relation'] == 'EXACT_QUESTION' and (
                    issue['proposition'] != question['proposition'] or
                    question['kind'] not in ('FINAL_PASSAGE', 'MOTION')):
                raise SyntheticOnlyError('EXACT_QUESTION must match proposition and direct decision procedure')
            conn.execute('INSERT INTO correspondence VALUES(?,?,?,?,?,?,?,?)',
                         (link['link_id'], link['issue_id'], link['question_id'],
                          link['relation'], link['reviewer'], link['rationale'],
                          issue_snapshot.source_id, digest(link)))
        conn.commit()
        return {'status': 'IMPORTED', 'source_count': len(snapshots)}
    except Exception:
        conn.rollback()
        raise


class HistoricalEngine:
    def __init__(self, path: str, snapshots: list[SourceSnapshot] | None = None):
        self.path = path
        initialize(path)
        with connect(path) as conn:
            ingest(conn, load_all() if snapshots is None else snapshots)

    def sources(self) -> list[dict]:
        with connect(self.path) as conn:
            return [dict(r) for r in conn.execute('SELECT * FROM sources ORDER BY chamber')]

    def issues(self) -> list[dict]:
        with connect(self.path) as conn:
            return [dict(r) for r in conn.execute('SELECT issue_id,title,proposition FROM issues ORDER BY issue_id')]

    def representative_history(self, chamber: str, district: str, as_of: str) -> list[dict]:
        if chamber not in CHAMBERS:
            raise ValueError('Unsupported chamber')
        valid_date(as_of)
        jurisdiction = 'fictional-river-city' if chamber == 'MUNICIPAL' else 'fictional-union'
        with connect(self.path) as conn:
            return [dict(r) for r in conn.execute('''
                SELECT t.tenure_id, t.person_id, p.name, t.chamber, t.jurisdiction,
                       t.seat, t.district, t.valid_from, t.valid_to, t.digest
                FROM tenures t JOIN people p USING(person_id)
                WHERE t.chamber=? AND t.jurisdiction=? AND t.district=?
                  AND t.valid_from<=? AND t.valid_to>?
                ORDER BY t.seat''', (chamber, jurisdiction, district, as_of, as_of))]

    def record(self, record_id: str) -> dict | None:
        with connect(self.path) as conn:
            r = conn.execute('''SELECT v.*, q.held_on, q.title, s.digest AS source_digest
                FROM votes v JOIN questions q USING(question_id)
                JOIN sources s ON s.source_id=v.source_id WHERE record_id=?''', (record_id,)).fetchone()
            return dict(r) if r else None

    def dashboard(self, *, issue_id: str | None, house_district: str,
                  municipal_ward: str, as_of: str, limit: int, offset: int,
                  chamber: str | None = None) -> dict:
        valid_date(as_of)
        if chamber is not None and chamber not in CHAMBERS:
            raise ValueError('Unsupported chamber filter')
        if not (1 <= limit <= 100 and 0 <= offset <= 100000):
            raise ValueError('Pagination outside supported bounds')
        if not house_district.isdigit() or not municipal_ward.isdigit():
            raise ValueError('Fixture district must be numeric')
        with connect(self.path) as conn:
            if issue_id and not _row(conn, 'issues', 'issue_id', issue_id):
                raise KeyError('Issue not in synthetic corpus')
            args = [as_of]
            condition = ''
            if issue_id:
                condition += ' AND c.issue_id=?'
                args.append(issue_id)
            if chamber:
                condition += ' AND q.chamber=?'
                args.append(chamber)
            common = '''FROM correspondence c
                JOIN questions q USING(question_id) JOIN issues i USING(issue_id)
                JOIN sources s ON s.source_id=q.source_id
                WHERE q.held_on<=?''' + condition
            total = conn.execute('SELECT count(*) ' + common, args).fetchone()[0]
            rows = conn.execute('''SELECT c.link_id,c.issue_id,i.title AS issue_title,
                    c.relation,c.reviewer,c.rationale,c.digest AS correspondence_digest,
                    q.question_id,q.held_on,q.chamber,q.jurisdiction,q.kind,q.rollcall_type,
                    q.title,q.proposition,q.result,q.digest AS question_digest,
                    s.source_id,s.digest AS source_digest ''' + common +
                    ' ORDER BY q.held_on DESC, q.question_id LIMIT ? OFFSET ?',
                    args + [limit, offset]).fetchall()
            entries = []
            for row in rows:
                data = dict(row)
                district = ('ALL' if row['chamber'] == 'SENATE' else
                            house_district if row['chamber'] == 'HOUSE' else municipal_ward)
                reps = conn.execute('''SELECT t.tenure_id, t.person_id,p.name,t.seat,
                        t.district,t.valid_from,t.valid_to FROM tenures t
                        JOIN people p USING(person_id)
                        WHERE t.chamber=? AND t.jurisdiction=? AND t.district=?
                        AND t.valid_from<=? AND t.valid_to>?
                        ORDER BY t.seat''', (row['chamber'], row['jurisdiction'], district,
                                            row['held_on'], row['held_on'])).fetchall()
                positions = []
                for rep in reps:
                    r = conn.execute('''SELECT v.record_id,v.choice,v.digest,v.supersedes
                        FROM votes v WHERE v.question_id=? AND v.person_id=?
                        AND NOT EXISTS(SELECT 1 FROM votes newer WHERE newer.supersedes=v.record_id)''',
                        (row['question_id'], rep['person_id'])).fetchone()
                    status = ('VOICE_VOTE_NO_NAMED_POSITION' if row['rollcall_type'] == 'VOICE'
                              else r['choice'] if r else 'NO_RECORDED_POSITION')
                    positions.append({**dict(rep), 'position': status,
                                      'vote_record_id': r['record_id'] if r else None,
                                      'vote_digest': r['digest'] if r else None,
                                      'direct_vote_comparison_permitted': (
                                          row['relation'] == 'EXACT_QUESTION' and
                                          row['rollcall_type'] == 'RECORDED' and r is not None)})
                if not reps:
                    positions.append({'person_id': None, 'position': 'NO_MATCHING_TENURE',
                                      'seat': None, 'vote_record_id': None,
                                      'direct_vote_comparison_permitted': False})
                data['representatives_at_vote_date'] = positions
                data['direct_vote_comparison_permitted'] = any(
                    p['direct_vote_comparison_permitted'] for p in positions)
                data['source_completeness'] = 'CURATED_SYNTHETIC_SUBSET_NOT_COMPLETE'
                entries.append(data)
        return {
            'mode': 'SYNTHETIC_ONLY', 'official_data_connected': False,
            'historical_votes_are_user_ballots': False,
            'coverage': {'corpus': 'four frozen fictional fixture sources',
                         'complete_legislative_history': False,
                         'sampling': 'curated examples; absence is not evidence of no vote'},
            'filters': {'issue_id': issue_id, 'chamber': chamber,
                        'house_district': house_district,
                        'municipal_ward': municipal_ward, 'as_of': as_of},
            'total': total, 'limit': limit, 'offset': offset,
            'next_offset': offset + limit if offset + limit < total else None,
            'entries': entries,
        }
