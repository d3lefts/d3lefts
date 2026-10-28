#!/usr/bin/env python3
"""Independent exact arithmetic verifier for the 131072-cell NIGHTFALL overlap witness.

Uses Python packed-integer multiplication, not the authors' six-prime NTT/CRT
implementation, its spectrum cache, or its recorded maximum. The original
archive input hash and expected rational are fixed before the run.
"""
from __future__ import annotations
import hashlib
import random
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

def packed_convolution(values: list[int], scale: int, width: int) -> list[int]:
    """Convolve x with reverse(scale-x) using carry-free packed integers."""
    n = len(values)
    if n * scale * scale >= (1 << (8 * width)):
        raise ValueError("Packing base too small")
    a = int.from_bytes(
        b"".join(x.to_bytes(width, "little") for x in values), "little"
    )
    b = int.from_bytes(
        b"".join((scale - x).to_bytes(width, "little") for x in reversed(values)),
        "little",
    )
    raw = (a * b).to_bytes((2 * n - 1) * width, "little")
    return [
        int.from_bytes(raw[i * width:(i + 1) * width], "little")
        for i in range(2 * n - 1)
    ]


def self_test() -> None:
    """Independent small direct-sum comparison for every signed shift."""
    random_gen = random.Random(0x36E)
    for n in (1, 2, 3, 5, 9, 19):
        scale = 1 << 5
        for _ in range(20):
            heights = [random_gen.randrange(scale + 1) for _ in range(n)]
            packed = packed_convolution(heights, scale, 3)
            direct = [
                sum(
                    heights[i] * (scale - heights[i - lag])
                    for i in range(n)
                    if 0 <= i - lag < n
                )
                for lag in range(-n + 1, n)
            ]
            if packed != direct:
                raise ValueError("Packed convolution differs from direct sum")
    print("PASS packed convolution compared with all signed direct sums")


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
    # Big-integer multiplication is an independent convolution algorithm.
    correlations = packed_convolution(values, D, WIDTH)
    peak = -1
    maximizing_shifts: list[int] = []
    for i, coefficient in enumerate(correlations):
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
    if len(sys.argv) == 2 and sys.argv[1] == "--self-test":
        self_test()
    elif len(sys.argv) == 2:
        print(json.dumps(verify(Path(sys.argv[1])), indent=2))
    else:
        raise SystemExit("Usage: verify_erdos_independent.py --self-test | PATH_TO_heights_u70.txt")
