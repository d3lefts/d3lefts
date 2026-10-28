#!/usr/bin/env python3
"""Independent exact arithmetic verifier for the 131072-cell NIGHTFALL overlap witness.

Uses Python packed-integer multiplication, not the authors' six-prime NTT/CRT
implementation, its spectrum cache, or its recorded maximum. The original
archive input hash and expected rational are fixed before the run.
"""
from __future__ import annotations
import hashlib
import sys
from fractions import Fraction
from pathlib import Path

N = 131072
D = 1 << 70
H = N // 2
WIDTH = 20  # 160-bit digit; N*D^2 < 2^157 => zero carry propagation
EXPECTED_HASH = "a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e"
EXPECTED_SCORE = Fraction(
    34788888032212764146872525963225147703298526879,
    91343852333181432387730302044767688728495783936,
)
EXPECTED_LAG = -17280

def verify(path: Path) -> dict[str, str]:
    raw = path.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    if digest != EXPECTED_HASH:
        raise ValueError(f"Witness SHA-256 mismatch: {digest}")
    values = list(map(int, raw.split()))
    if len(values) != N:
        raise ValueError(f"Height count {len(values)}; expected {N}")
    if min(values) < 0 or max(values) > D:
        raise ValueError("Height range violation")
    if sum(values) != H * D:
        raise ValueError("Unit mass violation")
    if N * D * D >= 1 << (8 * WIDTH):
        raise ValueError("Packing width cannot isolate coefficients")
    p = int.from_bytes(b"".join(x.to_bytes(WIDTH, "little") for x in values), "little")
    q = int.from_bytes(
        b"".join((D - x).to_bytes(WIDTH, "little") for x in reversed(values)), "little"
    )
    # Big-integer multiplication is an independent convolution algorithm.
    raw_product = (p * q).to_bytes((2 * N - 1) * WIDTH, "little")
    peak = -1
    maximizing_shifts: list[int] = []
    for i in range(2 * N - 1):
        coefficient = int.from_bytes(
            raw_product[i * WIDTH:(i + 1) * WIDTH], "little"
        )
        lag = i - (N - 1)  # Σ_i A_i (D - A_{i-lag}) with zero extension
        if coefficient > peak:
            peak = coefficient
            maximizing_shifts = [lag]
        elif coefficient == peak:
            maximizing_shifts.append(lag)
    score = Fraction(peak, H * D * D)
    if score != EXPECTED_SCORE or maximizing_shifts != [EXPECTED_LAG]:
        raise ValueError(
            f"Exact mismatch: score={score} shifts={maximizing_shifts}"
        )
    return {
        "result": "PASS",
        "scope": "finite rational heights, mass, all signed grid-lag coefficients",
        "method": "independently authored packed Python big-integer convolution",
        "witness_sha256": digest,
        "height_count": str(N),
        "maximizing_lag": str(EXPECTED_LAG),
        "exact_score": str(score),
    }

if __name__ == "__main__":
    import json
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 scripts/verify_erdos_independent.py PATH_TO_heights_u70.txt")
    print(json.dumps(verify(Path(sys.argv[1])), indent=2))
