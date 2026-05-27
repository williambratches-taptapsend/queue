#!/usr/bin/env bash
# Stop hook: when Claude finishes a turn, pop next queued task and inject it
# as a continuation. Designed to fail-safe — any error exits 0 silently so a
# bug here can never prevent Claude from stopping normally.

input=$(cat 2>/dev/null) || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null) || exit 0
[[ -z "$cwd" ]] && exit 0

queue_dir="$HOME/.claude/queue"
hash=$(printf '%s' "$cwd" | shasum 2>/dev/null | cut -c1-16) || exit 0
queue_file="$queue_dir/$hash.jsonl"

[[ -s "$queue_file" ]] || exit 0

next_line=$(head -n 1 "$queue_file" 2>/dev/null) || exit 0
task=$(printf '%s' "$next_line" | jq -r '.task // empty' 2>/dev/null) || exit 0
[[ -z "$task" ]] && exit 0

tail -n +2 "$queue_file" > "$queue_file.tmp" 2>/dev/null && mv "$queue_file.tmp" "$queue_file" 2>/dev/null

remaining=$(wc -l < "$queue_file" 2>/dev/null | tr -d ' ')
[[ -z "$remaining" ]] && remaining=0

reason="[queue] firing next queued task ($remaining still queued): $task"

jq -n --arg reason "$reason" '{decision: "block", reason: $reason}' 2>/dev/null || exit 0
