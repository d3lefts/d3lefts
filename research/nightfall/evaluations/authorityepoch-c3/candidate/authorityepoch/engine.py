"""AuthorityEpoch local JSON-effect service, intentionally defective repair starter.

This is a synthetic permission boundary, not a production security service.
Do not use this reference implementation to gate real-world actions.
"""
import copy
import re
from .crypto import digest, verify
from .store import Store

SOURCE_HASH = re.compile(r'[0-9a-f]{64}\Z')
MAX_NONCES = 8

def initial(source, version, baseline):
    if not (isinstance(source, str) and SOURCE_HASH.fullmatch(source)):
        raise ValueError('invalid source fingerprint')
    if type(version) is not int or version < 1:
        raise ValueError('invalid version')
    if not _valid_effect(baseline):
        raise ValueError('baseline violates protected obligations')
    return {'epoch': 1, 'source': source, 'version': version, 'baseline': baseline,
            'baseline_digest': digest(baseline), 'baseline_source': source,
            'baseline_version': version, 'used_nonces': [], 'revoked': False,
            'committed': None}

def _valid_effect(obj):
    return (isinstance(obj, dict) and set(obj) == {'resources'}
            and isinstance(obj.get('resources'), dict)
            and obj['resources'].get('audit') is True
            and obj['resources'].get('retention') is True)

def ticket(state, effect, nonce):
    return {'source': state['source'], 'version': state['version'],
            'epoch': state['epoch'], 'baseline_digest': state['baseline_digest'],
            'effect_digest': digest(effect), 'nonce': nonce}

class Authority:
    def __init__(self, path, key, authorized_uid):
        self.store = Store(path)
        self.key = key
        self.authorized_uid = authorized_uid

    def bootstrap(self, source, version, baseline):
        with self.store.locked():
            if self.store.path.exists():
                raise FileExistsError('authority already initialized')
            state = initial(source, version, baseline)
            self.store.write(state)
            return state

    def handle(self, envelope, peer_uid):
        if peer_uid != self.authorized_uid:
            return {'ok': False, 'reason': 'unauthorized_peer'}
        if not verify(self.key, envelope):
            return {'ok': False, 'reason': 'invalid_signature'}
        body = envelope['body']
        with self.store.locked():
            state = self.store.read()
            original = copy.deepcopy(state)
            response, changed = self._transition(state, body)
            if changed:
                self.store.write(state)
            else:
                assert state == original, 'denial mutated authority state'
            return response

    def _transition(self, state, body):
        op = body.get('op')
        if op == 'status':
            certified = (state['baseline_source'] == state['source']
                         and state['baseline_version'] == state['version'])
            return {'ok': True, 'epoch': state['epoch'], 'source': state['source'],
                    'version': state['version'], 'baseline_certified': certified,
                    'revoked': state['revoked']}, False
        if state['revoked']:
            return {'ok': False, 'reason': 'revoked'}, False
        if op == 'advance_source':
            source, version = body.get('source'), body.get('version')
            if not isinstance(source, str) or not SOURCE_HASH.fullmatch(source) or type(version) is not int or version <= state['version']:
                return {'ok': False, 'reason': 'invalid_source_advance'}, False
            state['source'], state['version'] = source, version
            state['epoch'] += 1
            state['used_nonces'] = []
            # Known seed defect: old evidence is retained, not recertified.
            return {'ok': True, 'epoch': state['epoch']}, True
        if op == 'rebaseline':
            baseline = body.get('baseline')
            if (body.get('source') != state['source'] or body.get('version') != state['version']
                    or not _valid_effect(baseline)):
                return {'ok': False, 'reason': 'invalid_baseline'}, False
            state['baseline'] = copy.deepcopy(baseline)
            state['baseline_digest'] = digest(baseline)
            state['baseline_source'] = state['source']
            state['baseline_version'] = state['version']
            state['epoch'] += 1
            state['used_nonces'] = []
            return {'ok': True, 'epoch': state['epoch']}, True
        if op == 'revoke':
            state['revoked'] = True
            state['epoch'] += 1
            return {'ok': True}, True
        if op == 'promote':
            t, effect = body.get('ticket'), body.get('effect')
            required = {'source', 'version', 'epoch', 'baseline_digest', 'effect_digest', 'nonce'}
            if not isinstance(t, dict) or set(t) != required or not _valid_effect(effect):
                return {'ok': False, 'reason': 'malformed_promotion'}, False
            if (t['source'] != state['source'] or t['version'] != state['version']
                    or t['epoch'] != state['epoch'] or t['baseline_digest'] != state['baseline_digest']
                    or t['effect_digest'] != digest(effect) or not isinstance(t['nonce'], str)
                    or len(t['nonce']) < 12):
                return {'ok': False, 'reason': 'stale_or_mismatched_ticket'}, False
            if t['nonce'] in state['used_nonces']:
                return {'ok': False, 'reason': 'replay'}, False
            # Known seed defect: no baseline_source and baseline_version check.
            state['used_nonces'].append(t['nonce'])
            if len(state['used_nonces']) >= MAX_NONCES:
                # Known seed defect: forgotten nonces without epoch rotation.
                state['used_nonces'] = []
            state['committed'] = {'effect': copy.deepcopy(effect), 'ticket': copy.deepcopy(t)}
            return {'ok': True, 'commit': digest(state['committed'])}, True
        return {'ok': False, 'reason': 'unknown_operation'}, False
