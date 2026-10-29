#!/usr/bin/env python3
"""Download and verify the two approved PUBLIC release assets without credentials."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path
import tempfile
from urllib.request import Request, urlopen

from verify_nightfall_curated_assets import EXPECTED, verify

BASE = ('https://github.com/d3lefts/d3lefts/releases/download/'
        'nightfall-research-2026-10-28/')
WITNESS_MEMBER = 'programs/erdos-overlap/frozen-witness/heights_u70.txt'
WITNESS_SHA256 = 'a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e'


def main(directory):
    directory.mkdir(parents=True, exist_ok=True)
    results = []
    # No token, cookie, authenticated client or private source URL is used.
    with tempfile.TemporaryDirectory(prefix='nightfall-public-') as temp:
        for name, (_, size, _, _) in EXPECTED.items():
            request = Request(BASE + name, headers={'User-Agent': 'NIGHTFALL-public-replay'})
            with urlopen(request, timeout=60) as response:
                payload = response.read(size + 1)
            candidate = Path(temp) / name
            candidate.write_bytes(payload)
            result = verify(candidate)
            (directory / name).write_bytes(payload)
            # Export only the explicitly approved overlap witness by its fixed member
            # name, and authenticate it independently before the referee replay.
            if name.startswith('NIGHTFALL_Curated_Math_Evidence_'):
                with zipfile.ZipFile(candidate) as archive:
                    witness = archive.read(WITNESS_MEMBER)
                digest = hashlib.sha256(witness).hexdigest()
                if digest != WITNESS_SHA256:
                    raise ValueError(f'Overlap witness SHA-256 mismatch: {digest}')
                (directory / 'heights_u70.txt').write_bytes(witness)
            results.append({**result, 'download_url': BASE + name,
                            'anonymous_download': True})
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    main(parser.parse_args().directory)
