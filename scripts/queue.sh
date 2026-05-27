#!/usr/bin/env bash
# /queue <task> | --list | --clear | --pop
# Per-cwd task queue. Tasks fire as new turns via the Stop hook.
set -euo pipefail

queue_dir="$HOME/.claude/queue"
mkdir -p "$queue_dir"
hash=$(printf '%s' "$PWD" | shasum | cut -c1-16)
queue_file="$queue_dir/$hash.jsonl"

case "${1:-}" in
  --list|-l|list)
    if [[ ! -s "$queue_file" ]]; then
      echo "[queue] empty ($PWD)"
      exit 0
    fi
    count=$(wc -l < "$queue_file" | tr -d ' ')
    echo "[queue] $count pending in $PWD"
    i=0
    while IFS= read -r line; do
      i=$((i+1))
      task=$(printf '%s' "$line" | jq -r '.task')
      printf "  %s. %s\n" "$i" "$task"
    done < "$queue_file"
    ;;
  --clear|-c|clear)
    if [[ -f "$queue_file" ]]; then
      count=$(wc -l < "$queue_file" | tr -d ' ')
      rm "$queue_file"
      echo "[queue] cleared $count task(s)"
    else
      echo "[queue] already empty"
    fi
    ;;
  --pop|pop)
    if [[ ! -s "$queue_file" ]]; then
      echo "[queue] empty"
      exit 0
    fi
    task=$(head -n 1 "$queue_file" | jq -r '.task')
    tail -n +2 "$queue_file" > "$queue_file.tmp" && mv "$queue_file.tmp" "$queue_file"
    echo "[queue] popped: $task"
    ;;
  "")
    echo "[queue] usage: /queue <task> | --list | --clear | --pop" >&2
    exit 1
    ;;
  *)
    task="$*"
    jq -cn --arg task "$task" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '{task: $task, queued_at: $ts}' >> "$queue_file"
    count=$(wc -l < "$queue_file" | tr -d ' ')
    echo "[queue] queued ($count pending) → $task"
    ;;
esac
