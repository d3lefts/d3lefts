#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
g++ -std=c++17 -O2 count_surjection.cpp -o "$TMP/count_surjection"
g++ -std=c++17 -O2 count_inclusion_exclusion.cpp -o "$TMP/count_ie"
: > verifier_surjection.log
: > verifier_ie.log
for h in $(seq 4 2 82); do
  "$TMP/count_surjection" "$h" >> verifier_surjection.log
  "$TMP/count_ie" "$h" >> verifier_ie.log
done
python3 verify_results.py
python3 rigorous_lower.py
sha256sum count_surjection.cpp count_inclusion_exclusion.cpp \
  verify_results.py rigorous_lower.py results.json
