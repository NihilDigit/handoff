#!/usr/bin/env fish
# Bootstrap the HANDOFF workflow in the current repository.
# Usage: ./bootstrap-handoff.fish [--force] [--lang LANGUAGE]

function write_file
    set path $argv[1]
    set content $argv[2]
    set force $argv[3]

    if test -e "$path"; and test "$force" != "--force"
        echo "[bootstrap] skip existing $path"
        return
    end

    set dir (dirname "$path")
    mkdir -p "$dir"
    printf "%s" "$content" > "$path"
    echo "[bootstrap] wrote $path"
end

function ensure_symlink
    set target $argv[1]
    set link $argv[2]

    if test -L "$link"
        echo "[bootstrap] skip existing symlink $link"
        return
    else if test -e "$link"
        echo "[bootstrap] WARNING: $link exists and is not a symlink, not touching it."
        return
    end

    ln -s "$target" "$link"
    echo "[bootstrap] linked $link -> $target"
end

set force ""
set lang "English"

set i 1
set argc (count $argv)
while test $i -le $argc
    set arg $argv[$i]
    switch $arg
        case "--force"
            set force "--force"
        case "--lang"
            set i (math $i + 1)
            if test $i -le $argc
                set lang $argv[$i]
            else
                echo "Missing value for --lang"
                exit 1
            end
        case "*"
            echo "Usage: (basename $argv[0]) [--force] [--lang LANGUAGE]"
            exit 1
    end
    set i (math $i + 1)
end

# -------------------------------------------------------------------
# AGENTS.md + CLAUDE.md
# -------------------------------------------------------------------

set agents_body "# AGENTS.md — AI Collaboration Entry / Constitution

This repository uses a spec-driven, CI-guarded workflow called HANDOFF.

Goals:
- Every core change is backed by specs, tasks, and session logs.
- Any agent can safely pause work and hand it off to someone else.

---

## 0. First agent checklist

1. Fill in `specs/overview.md` with project background and goals.
2. Copy `specs/features/F-000-template.md` to at least one real feature spec.
3. Initialize `SESSION_LOG.md` with the first real session.
4. Turn the demo entry in `tasks/backlog.yaml` into a real task, or add new ones.
5. Configure `CORE_PREFIXES` in:
   - `scripts/check_docs_sync.py`
   - `scripts/check_task_sync.py`
   so that CI knows which paths are considered \"core\".

Until `CORE_PREFIXES` is configured, the guards only print warnings and do not fail the build.

---

## 1. Recommended flow for core changes

This flow can be spread across multiple PRs / sessions:

1. Clarify  
   Read existing specs, tasks, and logs. If something is unclear, record questions in `specs/notes/` or `SESSION_LOG.md`.

2. Specify (what & why)  
   Update the relevant feature spec under `specs/features/` with context, user stories, acceptance criteria (they can start as TODOs).

3. Plan (how)  
   Add or update a \"Technical Plan\" section in the feature spec, or create a file under `specs/plans/`.

4. Tasks  
   Create or update tasks in `tasks/backlog.yaml`, linking them to feature IDs and (optionally) assignees.

5. Implement  
   Change code under `CORE_PREFIXES`. The CI guards will require spec/log and task updates for these changes.

6. Log & handoff  
   Append a session entry to `SESSION_LOG.md`. If you are not finishing the work, create/update an appropriate file under `tasks/handoff/` describing current status and next steps.

---

## 2. Directory conventions

- `specs/`
  - `overview.md` — project background and goals
  - `features/` — feature-level specs (`F-XXX-*.md`)
  - `plans/` — larger technical plans
  - `adr/` — architecture decision records
  - `notes/` — ad-hoc notes and questions

- `SESSION_LOG.md` — chronological sessions and plans

- `tasks/`
  - `backlog.yaml` — tasks and their status
  - `handoff/` — handoff notes such as `T-001.md`

---

## 3. Handoff rules

When you pause or stop working on something:

- Update relevant tasks in `tasks/backlog.yaml`.
- Create or update a file under `tasks/handoff/` explaining:
  - context
  - what is done
  - what is not done
  - recommendations for the next agent

At the end of every session, update `SESSION_LOG.md` with:
- what was achieved
- open questions
- suggested next steps
"

set agents_path "AGENTS.md"
if test -e "$agents_path"; and test "$force" != "--force"
    echo "[bootstrap] skip existing $agents_path"
else
    set header (string join "" "always reply in " $lang "\n\n")
    set full (string join "" $header $agents_body)
    write_file "$agents_path" "$full" "$force"
end

ensure_symlink "AGENTS.md" "CLAUDE.md"

# -------------------------------------------------------------------
# specs / SESSION_LOG / tasks
# -------------------------------------------------------------------

mkdir -p specs/features specs/plans specs/adr specs/notes
echo "[bootstrap] ensured specs/ directory structure"

set overview "# Project Overview

This file should be filled by the first real human or AI maintainer.

## 1. Background and motivation

- What problem does this project solve?
- Who are the users?
- What is the context?

## 2. Goals / Non-goals

- Goals:
- Non-goals:

## 3. Constraints

- Tech stack:
- Runtime environment:
- Performance / compliance / security constraints:

## 4. High-level architecture (can be refined over time)

- Main components:
- External dependencies:
- Brief data and control flow:

## 5. Roadmap

- Short term:
- Mid/long term:
"
write_file "specs/overview.md" "$overview" "$force"

set feature_template "# F-000: Feature Spec Template

> Copy this file as `specs/features/F-XXX-meaningful-name.md` and refine it over time.

## 1. Context / Problem

- Background and motivation:
- Current pain points:
- Why now:

## 2. User stories / scenarios

- [ ] US-1: As a <role>, I want <capability>, so that <value>.
- [ ] US-2:
- [ ] US-3:

## 3. Acceptance criteria

- [ ] In scenario A, when input X is provided, the system should...
- [ ] Error / edge cases:
- [ ] Monitoring / logging / audit requirements (if any):

## 4. Technical plan

- Components and responsibilities:
- Key interfaces / APIs:
- Data structures / storage:
- Performance / scalability considerations:
- Risks and alternatives:

## 5. Open questions

- [ ] Question 1
- [ ] Question 2

## 6. Links

- Related tasks: T-XXX
- Related PRs:
- Related docs:
"
write_file "specs/features/F-000-template.md" "$feature_template" "$force"

set adr_template "# ADR-000: Architecture Decision Record Template

- Status: proposed | accepted | superseded
- Date: YYYY-MM-DD
- Deciders: people or agents
- Related: F-XXX / PR-XXX / Issue-XXX

## Context

- What situation led to this decision?
- What constraints matter?

## Decision

- The decision we made:
- Summary:

## Consequences

- Positive consequences:
- Negative consequences / risks:
- Possible future changes:
"
write_file "specs/adr/ADR-000-template.md" "$adr_template" "$force"

set session_log "# SESSION_LOG.md — Sessions and plans

> Append a new section at the end of this file after each session (human or AI).

## 2025-01-01 00:00 bootstrap session (example, feel free to edit)

- Participants: bootstrap script
- Goals:
  - Initialize AGENTS / specs / tasks / CI guards
- Done:
  - Created the initial structure and templates
- Next steps:
  - First real agent fills in `specs/overview.md` and creates the first feature spec
  - Configure `CORE_PREFIXES`
"
write_file "SESSION_LOG.md" "$session_log" "$force"

mkdir -p tasks tasks/handoff
echo "[bootstrap] ensured tasks/ directory structure"

set backlog "# tasks/backlog.yaml — Task list (YAML)

# Example structure:
# - id: T-001
#   title: \"Set up basic specs and first feature\"
#   status: todo | in-progress | done
#   feature: F-001
#   assignee: agent-name-or-model
#   description: >
#     Short description of what this task is about.
#   links:
#     - specs/features/F-001-xxx.md
#     - PR-1
#   notes: |
#     Any extra notes.

- id: T-000
  title: \"Example task: replace or remove me\"
  status: todo
  feature: F-000
  assignee: unassigned
  description: >
    Demo task created by the bootstrap script. Replace with real tasks.
  links: []
  notes: |
    You can turn T-000 into a real task or delete it once you have real work.
"
write_file "tasks/backlog.yaml" "$backlog" "$force"

# -------------------------------------------------------------------
# CI workflows + guard scripts
# -------------------------------------------------------------------

mkdir -p .github/workflows scripts

set docs_guard "name: docs-guard
on:
  pull_request:
  push:
    branches: [main]

jobs:
  check-doc-updates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Determine diff base
        run: |
          if [ \"\${{ github.event_name }}\" = \"pull_request\" ]; then
            echo \"DOCS_GUARD_BASE=\${{ github.event.pull_request.base.sha }}\" >> \"\$GITHUB_ENV\"
            if [ \"\${{ github.event.pull_request.base.sha }}\" != \"0000000000000000000000000000000000000000\" ]; then
              git fetch origin \"\${{ github.event.pull_request.base.sha }}\" || true
            fi
          else
            echo \"DOCS_GUARD_BASE=\${{ github.event.before }}\" >> \"\$GITHUB_ENV\"
            if [ \"\${{ github.event.before }}\" != \"0000000000000000000000000000000000000000\" ]; then
              git fetch origin \"\${{ github.event.before }}\" || true
            fi
          fi
      - name: Enforce spec/log updates
        run: scripts/check_docs_sync.py
"
write_file ".github/workflows/docs-guard.yml" "$docs_guard" "$force"

set docs_script "#!/usr/bin/env python3
import os
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]

# TODO: set these to your project-specific core paths, e.g. [\"src/\", \"services/\", \"api/\"]
CORE_PREFIXES = []

DOC_PREFIXES = [\"specs/\", \"docs/\"]
DOC_FILES = [\"SESSION_LOG.md\", \"AGENTS.md\"]

def ensure_base(ref):
    return ref or \"HEAD~1\"

def git_diff(base):
    base = ensure_base(base)
    result = subprocess.run(
        [\"git\", \"diff\", \"--name-only\", f\"{base}...HEAD\"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode not in (0, 1):
        print(f\"[docs-guard] git diff failed: {result.stderr.strip()}\", file=sys.stderr)
        sys.exit(2)
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

def matches(path, prefixes):
    return any(path == p or path.startswith(p) for p in prefixes)

def needs_docs(changed):
    return bool(CORE_PREFIXES) and any(matches(path, CORE_PREFIXES) for path in changed)

def has_docs(changed):
    return any(
        matches(path, DOC_PREFIXES) or path in DOC_FILES
        for path in changed
    )

def main():
    base = os.environ.get(\"DOCS_GUARD_BASE\")
    changed = git_diff(base)
    if not changed:
        print(f\"[docs-guard] No changes vs {base or 'HEAD~1'}. Nothing to check.\")
        return 0

    print(\"[docs-guard] Changed files:\\n\" + \"\\n\".join(f\"  - {p}\" for p in changed))

    if not needs_docs(changed):
        if not CORE_PREFIXES:
            print(\"[docs-guard] CORE_PREFIXES is empty. Configure it to enforce spec/log updates.\")
        else:
            print(\"[docs-guard] No core prefixes touched. Skipping spec/log requirement.\")
        return 0

    if has_docs(changed):
        print(\"[docs-guard] Detected spec/log updates. OK.\")
        return 0

    print(\"[docs-guard] Core change detected without documentation updates.\")
    return 1

if __name__ == \"__main__\":
    raise SystemExit(main())
"
write_file "scripts/check_docs_sync.py" "$docs_script" "$force"
chmod +x scripts/check_docs_sync.py

set tasks_guard "name: tasks-guard
on:
  pull_request:
  push:
    branches: [main]

jobs:
  check-task-updates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Determine diff base
        run: |
          if [ \"\${{ github.event_name }}\" = \"pull_request\" ]; then
            echo \"TASKS_GUARD_BASE=\${{ github.event.pull_request.base.sha }}\" >> \"\$GITHUB_ENV\"
            if [ \"\${{ github.event.pull_request.base.sha }}\" != \"0000000000000000000000000000000000000000\" ]; then
              git fetch origin \"\${{ github.event.pull_request.base.sha }}\" || true
            fi
          else
            echo \"TASKS_GUARD_BASE=\${{ github.event.before }}\" >> \"\$GITHUB_ENV\"
            if [ \"\${{ github.event.before }}\" != \"0000000000000000000000000000000000000000\" ]; then
              git fetch origin \"\${{ github.event.before }}\" || true
            fi
          fi
      - name: Enforce backlog/handoff updates
        run: scripts/check_task_sync.py
"
write_file ".github/workflows/tasks-guard.yml" "$tasks_guard" "$force"

set tasks_script "#!/usr/bin/env python3
import os
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]

# TODO: keep in sync with check_docs_sync.py
CORE_PREFIXES = []

def ensure_base(ref):
    return ref or \"HEAD~1\"

def git_diff(base):
    base = ensure_base(base)
    result = subprocess.run(
        [\"git\", \"diff\", \"--name-only\", f\"{base}...HEAD\"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode not in (0, 1):
        print(f\"[tasks-guard] git diff failed: {result.stderr.strip()}\", file=sys.stderr)
        sys.exit(2)
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

def matches_core(path):
    return any(path == p or path.startswith(p) for p in CORE_PREFIXES)

def needs_tasks(changed):
    return bool(CORE_PREFIXES) and any(matches_core(path) for path in changed)

def has_tasks(changed):
    return any(path.startswith(\"tasks/\") for path in changed)

def main():
    base = os.environ.get(\"TASKS_GUARD_BASE\")
    changed = git_diff(base)
    if not changed:
        print(\"[tasks-guard] No changes detected.\")
        return 0

    print(\"[tasks-guard] Changed files:\\n\" + \"\\n\".join(f\"  - {p}\" for p in changed))

    if not needs_tasks(changed):
        if not CORE_PREFIXES:
            print(\"[tasks-guard] CORE_PREFIXES is empty. Configure it to enforce backlog/handoff updates.\")
        else:
            print(\"[tasks-guard] No core prefixes touched. Skipping tasks requirement.\")
        return 0

    if has_tasks(changed):
        print(\"[tasks-guard] Detected tasks/backlog updates. OK.\")
        return 0

    print(\"[tasks-guard] Core change detected without tasks/backlog updates.\")
    return 1

if __name__ == \"__main__\":
    raise SystemExit(main())
"
write_file "scripts/check_task_sync.py" "$tasks_script" "$force"
chmod +x scripts/check_task_sync.py

echo
echo "[bootstrap] HANDOFF bootstrap complete."
echo "[bootstrap] Next steps:"
echo "  1) Fill in specs/overview.md and create your first real feature spec."
echo "  2) Configure CORE_PREFIXES in scripts/check_docs_sync.py and scripts/check_task_sync.py."
echo "  3) Update tasks/backlog.yaml and SESSION_LOG.md with real project information."
