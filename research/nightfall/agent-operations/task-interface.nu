#!/usr/bin/env nu
# Preferred structured-data interface over the shell-independent Python contract.
# Each external call checks its *actual* exit code. Never self-certifies proofs.
export def task-list [] {
  let result = (^python3 scripts/nightfall_agent_tasks.py list | complete)
  if $result.exit_code != 0 {
    error make {msg: $"Agent catalogue failed (exit ($result.exit_code)): ($result.stderr)"}
  }
  let data = ($result.stdout | from json)
  if $data.schema != "nightfall.agent-task-catalogue.v1" {
    error make {msg: "Unexpected agent catalogue schema"}
  }
  $data
}

export def task-run [name: string, --problem: string = "NIGHTFALL-PROGRAM", --role: string = "coordinator"] {
  let result = (^python3 scripts/nightfall_agent_tasks.py run $name --problem $problem --role $role | complete)
  if $result.exit_code != 0 {
    error make {msg: $"Agent task ($name) failed (exit ($result.exit_code)): ($result.stdout) ($result.stderr)"}
  }
  let data = ($result.stdout | from json)
  if $data.schema != "nightfall.agent-task-receipt.v1" or $data.execution.status != "PASS" {
    error make {msg: "Missing or invalid successful agent task receipt"}
  }
  if $data.certification.mathematical_theorem != false {
    error make {msg: "Agent dispatcher claimed mathematical certification"}
  }
  $data
}

export def task-verify [receipt: string] {
  let result = (^python3 scripts/nightfall_agent_tasks.py replay $receipt | complete)
  if $result.exit_code != 0 {
    error make {msg: $"Agent receipt rejected (exit ($result.exit_code)): ($result.stderr)"}
  }
  let data = ($result.stdout | from json)
  if $data.valid_structure != true or $data.replay_bound_to_this_checkout != true or $data.mathematical_certification != false or $data.independent_math_audit != false {
    error make {msg: "Receipt replay did not establish scoped same-checker source and output binding"}
  }
  $data
}

# Structural-only inspection of archival receipts. Never authenticates output bytes.
export def task-structure [receipt: string] {
  let result = (^python3 scripts/nightfall_agent_tasks.py verify $receipt | complete)
  if $result.exit_code != 0 {
    error make {msg: $"Receipt structure rejected (exit ($result.exit_code)): ($result.stderr)"}
  }
  let data = ($result.stdout | from json)
  if $data.valid_structure != true or $data.mathematical_certification != false {
    error make {msg: "Receipt structure unexpectedly claims mathematical certification"}
  }
  $data
}
