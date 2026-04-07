# Return Contract

Return metadata, not long bodies.

Preferred fields:
- `status`
- `primary_path`
- `secondary_paths`
- `summary`
- `metrics`
- `needs_main_agent_decision`
- `memory_candidates`
- `doc_gap_candidates`

Common statuses in this pack:
- `done`
- `pass` / `fail`
- `blocked`
- `needs_context`
- `done_with_concerns`
- `no_design`
- `sparse_context`
- `no_memory_update`
- `no_lesson`

When a heavy artifact exists, save it to a file and return the path.
