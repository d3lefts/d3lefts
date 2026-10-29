#!/usr/bin/env python3
"""Offline byte/ZIP/member/nested-manifest checker for approved NIGHTFALL v2 assets.

Checksums authenticate bytes, not research originality or mathematical correctness.
"""
import argparse
import hashlib
import io
import json
import pathlib
import sys
import zipfile

EXPECTED = {
    'NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip':
        ('f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23', 11882806, 88, 0),
    'NIGHTFALL_Curated_Supplementary_Certificates_CANDIDATE_v2_20261029.zip':
        ('7c3769047fa247a0abd922bbfafd3a8ab885af62d1cd2c949828805559bb2665', 1046556, 16, 78),
}
META = {'NOTICE_AND_PROOF_STATUS.txt', 'CURATED_MEMBER_MANIFEST.json',
        'EXPLICIT_EXCLUSIONS.json', 'NESTED_MEMBER_MANIFEST.json'}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def safe_names(names):
    assert len(names) == len(set(names)), 'duplicate ZIP member'
    for name in names:
        normalized = name.replace('\\', '/')
        parts = normalized.split('/')
        assert normalized and not normalized.startswith('/') and '..' not in parts, f'unsafe ZIP path: {name}'
        assert not (parts[0].endswith(':') or '\x00' in normalized), f'unsafe ZIP path: {name}'
        lower = [part.lower() for part in parts]
        assert not any(x in ('xi', 'critical-line', 'prime-frequency') for x in lower), f'restricted path: {name}'
        assert parts[-1].lower() != 'phaseshift_quantum_interference_referee_draft_20261027.pdf', f'restricted PDF: {name}'


def verify(path):
    if not __debug__:
        raise RuntimeError("Run without -O: verification assertions must be enabled")
    assert path.name in EXPECTED, f'unapproved asset name {path.name}'
    expected_sha, size, count, nested_count = EXPECTED[path.name]
    payload = path.read_bytes()
    assert len(payload) == size, f'{path.name}: byte-count mismatch'
    assert sha(payload) == expected_sha, f'{path.name}: SHA-256 mismatch'
    with zipfile.ZipFile(io.BytesIO(payload)) as z:
        infos = z.infolist()
        names = [i.filename for i in infos]
        safe_names(names)
        assert len(infos) == count, f'{path.name}: member-count mismatch'
        assert z.testzip() is None, f'{path.name}: outer ZIP CRC failure'
        assert META <= set(names), f'{path.name}: missing provenance metadata'
        manifest = json.loads(z.read('CURATED_MEMBER_MANIFEST.json'))
        entries = manifest['members']
        by_path = {item['published_path']: item for item in entries}
        assert len(by_path) == len(entries), f'{path.name}: repeated manifest path'
        assert set(names) == set(by_path) | META, f'{path.name}: unmanifested ZIP member'
        exclusions = json.loads(z.read('EXPLICIT_EXCLUSIONS.json'))
        forbidden = {(x['original_archive'], x['member']) for x in exclusions.get('excluded_original_members', [])}
        source_pairs = {(x['source_archive'], x['source_member']) for x in entries}
        assert source_pairs.isdisjoint(forbidden), f'{path.name}: excluded source member included'
        nested = json.loads(z.read('NESTED_MEMBER_MANIFEST.json'))
        assert isinstance(nested, list) and len(nested) == nested_count, f'{path.name}: nested manifest count mismatch'
        by_nested_path = {x['nested_path']: x for x in nested}
        assert len(by_nested_path) == len(nested), f'{path.name}: repeated nested path'
        actual_nested = set()
        for n in names:
            if n in META:
                continue
            data = z.read(n)
            item = by_path[n]
            assert len(data) == item['size'] and sha(data) == item['sha256'], f'{path.name}::{n}: member identity mismatch'
            if n.lower().endswith('.zip'):
                with zipfile.ZipFile(io.BytesIO(data)) as inner:
                    inner_names = inner.namelist()
                    safe_names(inner_names)
                    assert inner.testzip() is None, f'{path.name}::{n}: nested ZIP CRC failure'
                    for inside in inner_names:
                        if inside.endswith('/'):
                            continue
                        label = f'{n}::{inside}'
                        actual_nested.add(label)
                        assert label in by_nested_path, f'{path.name}: unmanifested nested member {label}'
                        content = inner.read(inside)
                        evidence = by_nested_path[label]
                        assert len(content) == evidence['bytes'] and sha(content) == evidence['sha256'], f'{path.name}::{label}: nested mismatch'
        assert actual_nested == set(by_nested_path), f'{path.name}: nested manifest incomplete'
    return {'asset': path.name, 'status': 'PASS', 'bytes': size,
            'sha256': expected_sha, 'members': count, 'nested_members': nested_count}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('assets', type=pathlib.Path, nargs='+', help='Approved v2 release ZIP file(s)')
    args = p.parse_args()
    assert len(args.assets) == len(EXPECTED) and {x.name for x in args.assets} == set(EXPECTED), 'provide both exact approved v2 archives'
    print(json.dumps([verify(path) for path in args.assets], indent=2))


if __name__ == '__main__':
    try:
        main()
    except (AssertionError, ValueError, OSError, RuntimeError, zipfile.BadZipFile, KeyError) as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
