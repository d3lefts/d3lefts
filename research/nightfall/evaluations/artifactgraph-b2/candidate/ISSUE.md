# ArtifactGraph-B2: repair incremental build correctness

You are maintaining a Python package that compiles a manifest of source files and
ordered dependencies into durable, content-addressed artifacts. The project
passes its public smoke tests but has reported incidents involving stale output,
invalid dependency graphs, unsafe paths, and half-published builds.

Repair the implementation while preserving the public API in `artifactgraph`.
Do not replace the library with an external build tool, introduce runtime
network calls, or modify the public tests. Use Python 3.10+ and its standard
library only.

## Reproduce

From the `candidate/` directory:

```bash
python -m unittest discover -s tests -v
python -m artifactgraph /path/to/workspace top
```

A workspace contains `graph.json` and `src/`:

```json
{
  "version": 1,
  "nodes": {
    "core": {"source": "core.txt", "deps": []},
    "api": {"source": "api.txt", "deps": ["core"]}
  }
}
```

## Required contract

1. **Graph validation.** The manifest is JSON with exactly `version: 1` and
   an object `nodes`. Each name matches `[A-Za-z][A-Za-z0-9_-]{0,63}`; every
   node has string `source` and ordered list `deps` and no other fields.
   Reject missing/duplicate dependency names and cycles anywhere in the graph,
   including nodes unreachable from the requested targets, with `GraphError`.
2. **Targets and planning.** `Builder(root).build(targets)` accepts a list or
   tuple of target names. Unknown targets raise `GraphError`. Traverse each
   dependency before its consumer in the manifest's dependency order; honor
   first occurrence of each requested target; visit shared dependencies only
   once. An empty target sequence is a no-op. Return a `BuildReport` with
   tuple fields `built`, `reused`, and mapping `outputs` (node -> SHA-256).
3. **Content-based invalidation.** A cached node may be reused if and only if
   its node identity, exact source *bytes*, ordered dependency list and
   dependency artifact digests agree with the stored build key, and the
   referenced artifact still exists and passes SHA-256 verification. Metadata
   timestamps are not source identity. Unrelated nodes and unchanged bytes
   must not trigger spurious rebuilds. If a cached object is missing or
   corrupted, regenerate it instead of trusting it.
4. **Filesystem boundary.** Sources are relative to `workspace/src`; nested
   paths are allowed. Reject absolute paths, parent traversal, sources that
   resolve through symlinks outside `src`, missing files and directories as
   `GraphError`. Source files contain arbitrary bytes, not necessarily UTF-8.
   No adversarial concurrent symlink swap is in scope.
5. **Publication.** Durable state is under `.artifactgraph/`, with an index
   describing the committed artifacts and a content-addressed object store.
   When an expected graph/source validation error occurs, do not publish a
   partial new index. Use atomic index replacement. Durable objects not
   referenced by a committed index may remain as harmless orphans. Malformed
   index JSON, wrong version, malformed entry structure and unsafe digests
   must raise `GraphError`; do not silently overwrite corrupt index state.
6. **Integrity and persistence.** A new `Builder` instance must reuse the same
   valid cache. `Builder.read_output(name)` returns last committed artifact
   bytes and raises `GraphError` for unknown, missing or corrupt outputs.
   The CLI `python -m artifactgraph ROOT TARGET [TARGET ...]` emits a JSON
   report on stdout and uses nonzero exit status on a graph error.
7. **Determinism.** Unchanged manifest and source bytes produce identical
   output digests on a clean rebuild. Artifact bytes must faithfully encode
   the source content and ordered dependency output identities. You may
   change the serialization format, provided it remains unambiguous,
   deterministic and stable for the same inputs.

## Expected deliverable

A complete source repair, tests for regression-prone edge cases, and a short
explanation of the root causes. Preserve `Builder`, `BuildReport`, `GraphError`,
`Builder.build`, `Builder.read_output`, and the CLI contract. Multi-process
simultaneous writes, forced process termination, concurrent source mutation,
and distributed caches are **outside** this version's scope.

This is an independently runnable NIGHTFALL research-engineering evaluation
candidate, not an official Google/DeepMind/Polaris benchmark.
