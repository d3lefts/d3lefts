"""Entry point: python -m artifactgraph ROOT TARGET [TARGET ...]"""
import json
import sys

from . import Builder, GraphError


def main():
    if len(sys.argv) < 3:
        raise SystemExit("usage: python -m artifactgraph ROOT TARGET [TARGET ...]")
    try:
        r = Builder(sys.argv[1]).build(sys.argv[2:])
    except GraphError as exc:
        print(f"build failed: {exc}", file=sys.stderr)
        raise SystemExit(2) from exc
    print(json.dumps({"built": r.built, "reused": r.reused,
                      "outputs": r.outputs}, sort_keys=True))


if __name__ == "__main__":
    main()
