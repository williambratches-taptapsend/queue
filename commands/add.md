---
description: Add a task to the queue (fires after the current turn completes)
argument-hint: <task description>
allowed-tools: Bash
---

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/queue.sh" "$ARGUMENTS"`

Print the script output verbatim. No commentary.
