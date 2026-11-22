#!/usr/bin/env python3
"""Recreate the October 22 PhaseShift V3 upper witness from the public C-10 witness.

The source file and reconstructed file are SHA-256 pinned. The 719-site signed
integer patch is archived in compressed Base85 form; it cannot silently mutate
the original C-10 proof object's hash or claim identity.

Run without network when --base-heights points to an existing verified file.
Otherwise fetch only the fixed, publicly released October 29 curated archive.
"""
import argparse
import base64
import hashlib
import io
import urllib.request
import zipfile
import zlib
from pathlib import Path

N = 131_072
D = 1 << 70
H = N // 2
BASE_SHA = "a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e"
TARGET_SHA = "46ba45724bb7ff98f6b28b4b7ef3bcf2390f747db8ca290ae0f2f0eaba63c59c"
ZIP_SHA = "f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23"
URL = (
    "https://github.com/d3lefts/d3lefts/releases/download/"
    "nightfall-research-2026-10-28/"
    "NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip"
)
MEMBER = "programs/erdos-overlap/frozen-witness/heights_u70.txt"


def verified_raw_base(path):
    if path is not None:
        raw = Path(path).read_bytes()
    else:
        with urllib.request.urlopen(URL, timeout=180) as response:
            archive = response.read()
        assert hashlib.sha256(archive).hexdigest() == ZIP_SHA, "public archive SHA-256 mismatch"
        with zipfile.ZipFile(io.BytesIO(archive)) as z:
            assert z.testzip() is None, "public archive CRC mismatch"
            raw = z.read(MEMBER)
    assert len(raw) == 2_156_159, "public witness size mismatch"
    assert hashlib.sha256(raw).hexdigest() == BASE_SHA, "public witness SHA-256 mismatch"
    return raw


def reconstruct(raw, patch_path):
    values = [int(x) for x in raw.split()]
    assert len(values) == N
    assert sum(values) == H * D and all(0 <= x <= D for x in values)
    encoded = "".join(Path(patch_path).read_text(encoding="ascii").split()).encode("ascii")
    edits = zlib.decompress(base64.b85decode(encoded)).decode("ascii").splitlines()
    assert len(edits) == 719, "patch length mismatch"
    seen = set()
    delta_sum = 0
    for entry in edits:
        index, delta = (int(x) for x in entry.split())
        assert 0 <= index < N and index not in seen and delta != 0
        values[index] += delta
        delta_sum += delta
        seen.add(index)
    assert delta_sum == 0, "mass-changing patch"
    assert all(0 <= x <= D for x in values), "box constraint"
    assert sum(values) == H * D, "total mass"
    output = ("\n".join(map(str, values)) + "\n").encode("ascii")
    assert len(output) == 2_156_159
    assert hashlib.sha256(output).hexdigest() == TARGET_SHA, "target witness mismatch"
    return output


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-heights", type=Path, default=None)
    parser.add_argument("--out", type=Path, default=Path("phase_v3_heights_u70.txt"))
    args = parser.parse_args()
    patch = Path(__file__).with_name("phase_v3_delta.b85")
    result = reconstruct(verified_raw_base(args.base_heights), patch)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_bytes(result)
    print("PASS reconstructed 131072 heights, 719 exact changes, mass, box, SHA-256")
    print(TARGET_SHA, args.out)


if __name__ == "__main__":
    main()
