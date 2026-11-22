#!/usr/bin/env nu
# Read-only agent preflight: not a proof checker, not a proof passport validator.
# Use after the authoritative Python validator, not instead of it.
def main [manifest: string = "docs/proof-passport-v2.json"] {
  let doc = (open $manifest)
  if $doc.schema != "nightfall.proof-passport-overlay.v2" {
    error make {msg: "Wrong proof-passport schema"}
  }
  if $doc.version != 2 {
    error make {msg: "Wrong proof-passport version"}
  }
  let n = ($doc.records | length)
  let ids = ($doc.records | get id)
  if (($ids | uniq | length) != $n) {
    error make {msg: "Duplicate proof-passport IDs"}
  }
  let counts = (
    $doc.records
    | group-by assertion_status
    | transpose status members
    | each {|row| {status: $row.status, count: ($row.members | length)}}
    | sort-by status
  )
  {
    kind: "nightfall.agent-preflight.v1",
    schema: $doc.schema,
    manifest: $manifest,
    record_count: $n,
    status_counts: $counts,
    mathematical_certification: false,
    semantic_review: false
  } | to json -r
}
