#!/usr/bin/env python3
"""Agent-first, exact replay of the frozen 131072-cell overlap construction.

Source-independent GMP polynomial multiplication. Run from any working directory.
Requires g++, GMP development headers/libraries, Python 3 standard library.
"""
from __future__ import annotations
from datetime import datetime, timezone
from fractions import Fraction
from hashlib import sha256
from io import BytesIO
from pathlib import Path
import json
import platform
import subprocess
import sys
import tempfile
from zipfile import ZipFile

ROOT_HASH = "77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb"
HEIGHT_HASH = "a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e"
NESTED = "research/nightfall/artifacts/NIGHTFALL_Meta_Paper_v2.0_Source_and_Evidence.zip"
HEIGHT = "release/reproduction/overlap_latest/NIGHTFALL_Erdos_Latest/heights_u70.txt"
EXPECTED_FRACTION = Fraction(
    34788888032212764146872525963225147703298526879,
    91343852333181432387730302044767688728495783936,
)
EXPECTED_SECOND = Fraction(
    34788888032196508685160787678357375369567622621,
    91343852333181432387730302044767688728495783936,
)


def verify(zip_path: Path) -> dict[str, object]:
    root_hash = sha256(zip_path.read_bytes()).hexdigest()
    assert root_hash == ROOT_HASH, f"Master archive SHA-256 mismatch: {root_hash}"
    with ZipFile(zip_path) as master:
        assert master.testzip() is None, "Master ZIP CRC failure"
        assert len(master.infolist()) == 214, "Master archive entry count changed"
        nested_bytes = master.read(NESTED)
    with ZipFile(BytesIO(nested_bytes)) as nested:
        assert nested.testzip() is None, "Nested evidence CRC failure"
        witness = nested.read(HEIGHT)
    witness_hash = sha256(witness).hexdigest()
    assert witness_hash == HEIGHT_HASH, f"Witness SHA-256 mismatch: {witness_hash}"

    source = Path(__file__).with_name("independent_gmp_audit.cpp")
    bridge = Path(__file__).with_name("verify_bridge.py")
    with tempfile.TemporaryDirectory(prefix="nightfall-gmp-") as d:
        workdir = Path(d)
        witness_path = workdir / "heights_u70.txt"
        witness_path.write_bytes(witness)
        exe_path = workdir / "audit"
        compiler = subprocess.run(
            ["g++", "-O3", "-std=c++17", str(source), "-lgmpxx", "-lgmp", "-o", str(exe_path)],
            text=True, capture_output=True, check=True,
        )
        result = subprocess.run([str(exe_path),str(witness_path)],
                                text=True, capture_output=True, check=True)
    parsed=json.loads(result.stdout)
    peak=Fraction(parsed["exact_max_fraction"])
    second=Fraction(parsed["exact_runner_up_fraction"])
    margin=Fraction(parsed["runner_up_margin_fraction"])
    assert peak==EXPECTED_FRACTION
    assert second==EXPECTED_SECOND
    assert peak-second==margin and margin>0
    assert parsed["max_lags"]==[-17280]
    assert parsed["second_lags"]==[36482]
    assert parsed["checked_signed_lags"]==262143
    assert parsed["direct_sum_shift_checks"]==27
    assert parsed["mass_verified"] is True
    geometry=subprocess.run([sys.executable,str(bridge)],text=True,
                            capture_output=True,check=True)
    assert "1720 exact-rational small cases" in geometry.stdout
    return {
        "result":"PASS",
        "scope":"original witness hash, 131072 rational box/mass values, 262143 signed grid shifts, integer maximum and runner-up",
        "real_shift_bridge":"affine interpolation for grid-step densities, proved algebraically in companion report; geometry regression is not a formal proof",
        "timestamp_utc":datetime.now(timezone.utc).isoformat(),
        "input":{"master_zip_sha256":root_hash,"nested_evidence_sha256":sha256(nested_bytes).hexdigest(),
                 "witness_sha256":witness_hash,"witness_bytes":len(witness)},
        "implementation":{"method":"GMP Kronecker packed-integer multiplication, no original NTT residues",
             "source_sha256":sha256(source.read_bytes()).hexdigest(),
             "geometry_test_sha256":sha256(bridge.read_bytes()).hexdigest(),
             "cpp_compiler":subprocess.run(["g++","--version"],capture_output=True,text=True,check=True).stdout.splitlines()[0],
             "gmp_version":parsed["gmp_version"],
             "python":platform.python_version()},
        "verification":{
             "signed_grid_lags":parsed["checked_signed_lags"],
             "independent_direct_sums":parsed["direct_sum_shift_checks"],
             "geometry_small_exact_tests":1720,
             "maximizing_signed_lag":-17280,
             "physical_shift_t":str(Fraction(135,512)),
             "max_fraction":str(peak),
             "second_signed_lag":36482,
             "second_fraction":str(second),
             "grid_runner_up_gap":str(margin),
             "left_neighbor_drop":parsed["left_grid_drop_fraction"],
             "right_neighbor_drop":parsed["right_grid_drop_fraction"],
        },
        "unverified":[
            "No source-SDP theorem audited; irrelevant to this finite witness",
            "Official accepted Arena submission file and cell count remain unresolved",
            "Prior-art global priority and external independent review require separate work",
            "No general lower bound or characterization of the global optimum is claimed",
        ],
    }

if __name__=="__main__":
    if len(sys.argv)!=2:
        raise SystemExit("Usage: python3 replay_erdos_gmp.py NIGHTFALL_GitHub_Release_2026-10-27.zip")
    try:
        print(json.dumps(verify(Path(sys.argv[1])),indent=2,sort_keys=True))
    except Exception as e:
        print(json.dumps({"result":"FAIL","error":str(e)}),file=sys.stderr)
        raise SystemExit(1)
