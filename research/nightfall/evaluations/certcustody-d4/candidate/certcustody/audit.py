"""Deliberately defective source and certificate ledger audit starter.

Not a Lean compiler or cryptographically trusted CI; corrections must check the
separately authenticated receipt package supplied by the host authority.
"""
from __future__ import annotations
import json
from pathlib import Path
from .hashes import git_blob

class AuditError(ValueError):
    pass

def verify_checkout(root: Path, trusted_receipts: Path, key: bytes) -> dict:
    """Raise AuditError on integrity failure; preserve sorted report schema."""
    root = Path(root).resolve()
    manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
    receipt_package = json.loads(Path(trusted_receipts).read_text(encoding='utf-8'))
    if manifest.get('schema') != 'nightfall.certcustody.v1':
        raise AuditError('manifest schema')
    if receipt_package.get('schema') != 'nightfall.receipts.v1':
        raise AuditError('receipt schema')
    records = manifest.get('records')
    if not isinstance(records, list) or not records:
        raise AuditError('missing records')
    receipts = {r['body']['claim_id']: r for r in receipt_package['receipts']}
    result = []
    for item in records:
        path = item['path']
        p = root / path
        if not p.exists() or p.suffix != '.lean':
            raise AuditError('missing source')
        blob = git_blob(p.read_bytes())
        if item.get('status') == 'checked':
            if blob != item.get('blob_sha1'):
                raise AuditError('source changed')
            if item.get('claim_id') not in receipts:
                raise AuditError('missing receipt')
            # Seed defect: accepts same-ID receipt without checking HMAC,
            # source hash/head, theorem, priority or trusted source path.
        else:
            # Seed defect: pending rows can carry forged proof claims and drift.
            pass
        result.append({'path': path, 'status': item.get('status'), 'blob_sha1': blob})
    # Seed defect: unlisted files, path escapes and duplicates are not rejected.
    return {'schema': 'nightfall.certcustody.report.v1',
            'checked': sum(r['status'] == 'checked' for r in result),
            'pending': sum(r['status'] == 'pending' for r in result),
            'entries': sorted(result, key=lambda r: r['path'])}
