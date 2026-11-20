# Roll out split fulfillment while v1 workers stay online

A retail order always has a primary fulfillment. A second warehouse may register more parts later. Old workers can only mark the primary shipped. Their dashboard must report pending when no part has shipped, partial when some have shipped, and shipped when every currently known part has shipped. Adding a new pending part may therefore change shipped to partial.

Repair rollout.py in Python 3.10+ with stdlib SQLite. Preserve legacy.py byte-for-byte and the public function signatures. Production runs its SQL directly. Start from the database created by legacy.bootstrap. Orders may be inserted before or after rollout. Inputs are existing order IDs, nonempty part IDs, Boolean shipped flags and positive integer limits. Writers run in caller-managed serialized transactions over one database. Simultaneous writes, invalid inputs and downgrades are outside this task.

* install may be rerun. Make both APIs immediately consistent without copying all legacy shipments at installation. The primary exists logically even without a physical row.
* write registers or updates a part. Shipped is monotone, including across both writer versions. Replays are idempotent. read returns a mapping from every known part ID to its shipped flag (Boolean or integer 0/1).
* backfill materializes up to limit previously unmaterialized legacy primary shipments, returning the count newly copied. Once materialized, an item consumes no further budget. Repeated calls must drain any finite backlog, including late arrivals whose IDs sort before earlier batches. New writes must remain visible throughout.
* All operations participate in the caller's transaction, including migration progress. After rollback and reopen the same logical work must remain. Preserve committed data across restart.

Run python -m unittest discover -v from this directory. Public smoke covers only the new writer. The calibration rubric awards 20 points each for compatibility before copying, the legacy dashboard, monotone replay, bounded backfill with late arrivals, and transaction recovery. Submit a repair, regression tests and a short account of one mixed-version history.
