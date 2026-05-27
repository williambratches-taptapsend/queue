---
description: Queue a task to fire automatically after the current turn fully completes
argument-hint: <task> | --list | --clear | --pop
allowed-tools: Bash
---

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/queue.sh" $ARGUMENTS`

Print the script output to the user verbatim. No commentary unless they asked a question.
