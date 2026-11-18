"""Audit entrypoint; no automatic source rewriting or certificate promotion."""
import argparse
import json
from pathlib import Path
from .audit import AuditError, verify_checkout

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('root', type=Path)
    ap.add_argument('--receipts', type=Path, required=True)
    ap.add_argument('--key-file', type=Path, required=True)
    args = ap.parse_args()
    try:
        result = verify_checkout(args.root, args.receipts, args.key_file.read_bytes())
    except (AuditError, ValueError, KeyError, TypeError, OSError) as exc:
        print(json.dumps({'ok': False, 'error': type(exc).__name__}))
        return 1
    print(json.dumps({'ok': True, 'report': result}, sort_keys=True))
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
