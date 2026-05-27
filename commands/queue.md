---
description: Queue a task to fire automatically after the current turn fully completes
argument-hint: <task> | --list | --clear | --pop
allowed-tools: Bash
---

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/queue.sh" "$ARGUMENTS"`

Print the script output verbatim. No commentary unless the user asked a question.
