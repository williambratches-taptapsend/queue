# queue

A Claude Code plugin that lets you queue follow-up tasks without interrupting the current turn. Each queued task fires automatically as a new turn after Claude finishes the previous one.

## How it works

- `/queue <task>` appends a task to a per-cwd queue on disk.
- A `Stop` hook runs whenever Claude finishes a turn. If the queue is non-empty, it pops the next task and tells Claude to continue with it.
- Tasks fire sequentially. The current turn is never interrupted — the next task waits until Claude has fully stopped.

## Install

```bash
claude plugin marketplace add williambratches-taptapsend/queue
claude plugin install wb-queue@wb-queue
```

Restart your Claude Code session so the `Stop` hook loads.

## Usage

```
/queue summarize the diff
/queue run the test suite
/queue --list      # show pending tasks
/queue --pop       # drop the next task without running it
/queue --clear     # drop all tasks
```

(Fully qualified form is `/wb-queue:queue`, but the shorter `/queue` resolves automatically as long as no other installed plugin defines a `queue` command.)

Then ask Claude any normal question. When it finishes, you'll see:

```
[queue] firing next queued task (1 still queued): summarize the diff
```

…and Claude continues with that task as a new turn. Repeat until the queue is empty.

## Caveats

- **Tokens still spend.** Each queued task is a fresh turn. The hook fires at full turn completion (no interruption), but it does not save tokens.
- **Per-cwd, not per-session.** Two Claude sessions in the same directory share a queue.
- **Persistent.** Queued tasks survive across sessions. If you queue something and close Claude, it fires next time you open Claude in that cwd and complete a turn.
- **No cancellation mid-fire.** Once a task starts, you can only stop it the normal way (interrupt the turn). Use `/queue --pop` or `/queue --clear` *before* it fires.

## Storage

`~/.claude/queue/<sha1(cwd)>.jsonl` — one JSON object per task, with `task` and `queued_at`.

## Safety

The Stop hook is fail-safe: any internal error path exits silently and lets Claude stop normally. It can never get Claude stuck.

## License

MIT
