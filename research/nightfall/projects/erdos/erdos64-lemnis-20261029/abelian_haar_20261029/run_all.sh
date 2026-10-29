#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 verify_abelian_haar_symbolic.py
python3 verify_haar_graphs_independent.py
python3 verify_sidon_prefix_independent.py
python3 verify_sidon_repair_noncyl.py
g++ -std=c++20 -O3 cayley_scan.cpp -o /tmp/lemnis_cayley_scan_20261029
/tmp/lemnis_cayley_scan_20261029 120
g++ -std=c++20 -O3 voltage_scan.cpp -o /tmp/lemnis_voltage_scan_20261029
/tmp/lemnis_voltage_scan_20261029 400 259831 0
/tmp/lemnis_voltage_scan_20261029 1000 259831 1
