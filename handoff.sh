#!/usr/bin/env bash
# Bootstrap the HANDOFF workflow in the current repository.
# Usage: ./bootstrap-handoff.sh [--force] [--lang LANGUAGE]

set -euo pipefail

force=""
lang="English"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force="--force"
      shift
      ;;
    --lang)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --lang" >&2
        exit 1
      fi
      lang="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 [--force] [--lang LANGUAGE]" >&2
      exit 1
      ;;
  esac
done

write_file() {
  local path="$1"
  local content="$2"

  if [[ -e "$path" && "$force" != "--force" ]]; then
    echo "[bootstrap] skip existing $path"
    return
  fi

  mkdir -p "$(dirname "$path")"
  printf "%s" "$content" > "$path"
  echo "[bootstrap] wrote $path"
}

# -------------------------------------------------------------------
# AGENTS.md + CLAUDE.md
# -------------------------------------------------------------------

agents_body=$'# AGENTS.md — AI Collaboration Entry / Constitution\n\nThis repository uses a spec-driven, CI-guarded workflow called HANDOFF.\n\nGoals:\n- Every core change is backed by specs, tasks, and session logs.\n- Any agent can safely pause work and hand it off to someone else.\n\n---\n\n## 0. First agent checklist\n\n1. Fill in `specs/overview.md` with project background and goals.\n2. Copy `specs/features/F-000-template.md` to at least one real feature spec.\n3. Initialize `SESSION_LOG.md` with the first real session.\n4. Turn the demo entry in `tasks/backlog.yaml` into a real task, or add new ones.\n5. Configure `CORE_PREFIXES` in:\n   - `scripts/check_docs_sync.py`\n   - `scripts/check_task_sync.py`\n   so that CI knows which paths are considered \"core\".\n\nUntil `CORE_PREFIXES` is configured, the guards only print warnings and do not fail the build.\n\n---\n\n## 1. Recommended flow for core changes\n\nThis flow can be spread across multiple PRs / sessions:\n\n1. Clarify  \n   Read existing specs, tasks, and logs. If something is unclear, record questions in `specs/notes/` or `SESSION_LOG.md`.\n\n2. Specify (what & why)  \n   Update the relevant feature spec under `specs/features/` with context, user stories, acceptance criteria (they can start as TODOs).\n\n3. Plan (how)  \n   Add or update a \"Technical Plan\" section in the feature spec, or create a file under `specs/plans/`.\n\n4. Tasks  \n   Create or update tasks in `tasks/backlog.yaml`, linking them to feature IDs and (optionally) assignees.\n\n5. Implement  \n   Change code under `CORE_PREFIXES`. The CI guards will require spec/log and task updates for these changes.\n\n6. Log & handoff  \n   Append a session entry to `SESSION_LOG.md`. If you are not finishing the work, create/update an appropriate file under `tasks/handoff/` describing current status and next steps.\n\n---\n\n## 2. Directory conventions\n\n- `specs/`\n  - `overview.md` — project background and goals\n  - `features/` — feature-level specs (`F-XXX-*.md`)\n  - `plans/` — larger technical plans\n  - `adr/` — architecture decision records\n  - `notes/` — ad-hoc notes and questions\n\n- `SESSION_LOG.md` — chronological sessions and plans\n\n- `tasks/`\n  - `backlog.yaml` — tasks and their status\n  - `handoff/` — handoff notes such as `T-001.md`\n\n---\n\n## 3. Handoff rules\n\nWhen you pause or stop working on something:\n\n- Update relevant tasks in `tasks/backlog.yaml`.\n- Create or update a file under `tasks/handoff/` explaining:\n  - context\n  - what is done\n  - what is not done\n  - recommendations for the next agent\n\nAt the end of every session, update `SESSION_LOG.md` with:\n- what was achieved\n- open questions\n- suggested next steps\n'

agents_path="AGENTS.md"
if [[ -e "$agents_path" && "$force" != "--force" ]]; then
  echo "[bootstrap] skip existing $agents_path"
else
  {
    printf "always reply in %s\n\n" "$lang"
    printf "%s" "$agents_body"
  } > "$agents_path"
  echo "[bootstrap] wrote $agents_path"
fi

# CLAUDE symlink
if [[ -L "CLAUDE.md" ]]; then
  echo "[bootstrap] skip existing symlink CLAUDE.md"
elif [[ -e "CLAUDE.md" ]]; then
  echo "[bootstrap] WARNING: CLAUDE.md exists and is not a symlink, not touching it."
else
  ln -s "AGENTS.md" "CLAUDE.md"
  echo "[bootstrap] linked CLAUDE.md -> AGENTS.md"
fi

# -------------------------------------------------------------------
# specs / SESSION_LOG / tasks
# -------------------------------------------------------------------

mkdir -p specs/features specs/plans specs/adr specs/notes
echo "[bootstrap] ensured specs/ directory structure"

overview=$'# Project Overview\n\nThis file should be filled by the first real human or AI maintainer.\n\n## 1. Background and motivation\n\n- What problem does this project solve?\n- Who are the users?\n- What is the context?\n\n## 2. Goals / Non-goals\n\n- Goals:\n- Non-goals:\n\n## 3. Constraints\n\n- Tech stack:\n- Runtime environment:\n- Performance / compliance / security constraints:\n\n## 4. High-level architecture (can be refined over time)\n\n- Main components:\n- External dependencies:\n- Brief data and control flow:\n\n## 5. Roadmap\n\n- Short term:\n- Mid/long term:\n'
write_file "specs/overview.md" "$overview"

feature_template=$'# F-000: Feature Spec Template\n\n> Copy this file as `specs/features/F-XXX-meaningful-name.md` and refine it over time.\n\n## 1. Context / Problem\n\n- Background and motivation:\n- Current pain points:\n- Why now:\n\n## 2. User stories / scenarios\n\n- [ ] US-1: As a <role>, I want <capability>, so that <value>.\n- [ ] US-2:\n- [ ] US-3:\n\n## 3. Acceptance criteria\n\n- [ ] In scenario A, when input X is provided, the system should...\n- [ ] Error / edge cases:\n- [ ] Monitoring / logging / audit requirements (if any):\n\n## 4. Technical plan\n\n- Components and responsibilities:\n- Key interfaces / APIs:\n- Data structures / storage:\n- Performance / scalability considerations:\n- Risks and alternatives:\n\n## 5. Open questions\n\n- [ ] Question 1\n- [ ] Question 2\n\n## 6. Links\n\n- Related tasks: T-XXX\n- Related PRs:\n- Related docs:\n'
write_file "specs/features/F-000-template.md" "$feature_template"

adr_template=$'# ADR-000: Architecture Decision Record Template\n\n- Status: proposed | accepted | superseded\n- Date: YYYY-MM-DD\n- Deciders: people or agents\n- Related: F-XXX / PR-XXX / Issue-XXX\n\n## Context\n\n- What situation led to this decision?\n- What constraints matter?\n\n## Decision\n\n- The decision we made:\n- Summary:\n\n## Consequences\n\n- Positive consequences:\n- Negative consequences / risks:\n- Possible future changes:\n'
write_file "specs/adr/ADR-000-template.md" "$adr_template"

session_log=$'# SESSION_LOG.md — Sessions and plans\n\n> Append a new section at the end of this file after each session (human or AI).\n\n## 2025-01-01 00:00 bootstrap session (example, feel free to edit)\n\n- Participants: bootstrap script\n- Goals:\n  - Initialize AGENTS / specs / tasks / CI guards\n- Done:\n  - Created the initial structure and templates\n- Next steps:\n  - First real agent fills in `specs/overview.md` and creates the first feature spec\n  - Configure `CORE_PREFIXES`\n'
write_file "SESSION_LOG.md" "$session_log"

mkdir -p tasks tasks/handoff
echo "[bootstrap] ensured tasks/ directory structure"

backlog=$'# tasks/backlog.yaml — Task list (YAML)\n\n# Example structure:\n# - id: T-001\n#   title: "Set up basic specs and first feature"\n#   status: todo | in-progress | done\n#   feature: F-001\n#   assignee: agent-name-or-model\n#   description: >\n#     Short description of what this task is about.\n#   links:\n#     - specs/features/F-001-xxx.md\n#     - PR-1\n#   notes: |\n#     Any extra notes.\n\n- id: T-000\n  title: "Example task: replace or remove me"\n  status: todo\n  feature: F-000\n  assignee: unassigned\n  description: >\n    Demo task created by the bootstrap script. Replace with real tasks.\n  links: []\n  notes: |\n    You can turn T-000 into a real task or delete it once you have real work.\n'
write_file "tasks/backlog.yaml" "$backlog"

# -------------------------------------------------------------------
# CI workflows + guard scripts
# -------------------------------------------------------------------

mkdir -p .github/workflows scripts

docs_guard=$'name: docs-guard\non:\n  pull_request:\n  push:\n    branches: [main]\n\njobs:\n  check-doc-updates:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n        with:\n          fetch-depth: 0\n      - name: Determine diff base\n        run: |\n          if [ "${{ github.event_name }}" = "pull_request" ]; then\n            echo "DOCS_GUARD_BASE=${{ github.event.pull_request.base.sha }}" >> "$GITHUB_ENV"\n            if [ "${{ github.event.pull_request.base.sha }}" != "0000000000000000000000000000000000000000" ]; then\n              git fetch origin "${{ github.event.pull_request.base.sha }}" || true\n            fi\n          else\n            echo "DOCS_GUARD_BASE=${{ github.event.before }}" >> "$GITHUB_ENV"\n            if [ "${{ github.event.before }}" != "0000000000000000000000000000000000000000" ]; then\n              git fetch origin "${{ github.event.before }}" || true\n            fi\n          fi\n      - name: Enforce spec/log updates\n        run: scripts/check_docs_sync.py\n'
write_file ".github/workflows/docs-guard.yml" "$docs_guard"

docs_script=$'#!/usr/bin/env python3\nimport os\nimport pathlib\nimport subprocess\nimport sys\n\nROOT = pathlib.Path(__file__).resolve().parents[1]\n\n# TODO: set these to your project-specific core paths, e.g. ["src/", "services/", "api/"]\nCORE_PREFIXES = []\n\nDOC_PREFIXES = ["specs/", "docs/"]\nDOC_FILES = ["SESSION_LOG.md", "AGENTS.md"]\n\ndef ensure_base(ref):\n    return ref or "HEAD~1"\n\ndef git_diff(base):\n    base = ensure_base(base)\n    result = subprocess.run(\n        ["git", "diff", "--name-only", f"{base}...HEAD"],\n        cwd=ROOT,\n        capture_output=True,\n        text=True,\n        check=False,\n    )\n    if result.returncode not in (0, 1):\n        print(f"[docs-guard] git diff failed: {result.stderr.strip()}", file=sys.stderr)\n        sys.exit(2)\n    return [line.strip() for line in result.stdout.splitlines() if line.strip()]\n\ndef matches(path, prefixes):\n    return any(path == p or path.startswith(p) for p in prefixes)\n\ndef needs_docs(changed):\n    return bool(CORE_PREFIXES) and any(matches(path, CORE_PREFIXES) for path in changed)\n\ndef has_docs(changed):\n    return any(\n        matches(path, DOC_PREFIXES) or path in DOC_FILES\n        for path in changed\n    )\n\ndef main():\n    base = os.environ.get("DOCS_GUARD_BASE")\n    changed = git_diff(base)\n    if not changed:\n        print(f"[docs-guard] No changes vs {base or \'HEAD~1\'}. Nothing to check.")\n        return 0\n\n    print("[docs-guard] Changed files:\\n" + "\\n".join(f"  - {p}" for p in changed))\n\n    if not needs_docs(changed):\n        if not CORE_PREFIXES:\n            print("[docs-guard] CORE_PREFIXES is empty. Configure it to enforce spec/log updates.")\n        else:\n            print("[docs-guard] No core prefixes touched. Skipping spec/log requirement.")\n        return 0\n\n    if has_docs(changed):\n        print("[docs-guard] Detected spec/log updates. OK.")\n        return 0\n\n    print("[docs-guard] Core change detected without documentation updates.")\n    return 1\n\nif __name__ == "__main__":\n    raise SystemExit(main())\n'
write_file "scripts/check_docs_sync.py" "$docs_script"
chmod +x scripts/check_docs_sync.py

tasks_guard=$'name: tasks-guard\non:\n  pull_request:\n  push:\n    branches: [main]\n\njobs:\n  check-task-updates:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n        with:\n          fetch-depth: 0\n      - name: Determine diff base\n        run: |\n          if [ "${{ github.event_name }}" = "pull_request" ]; then\n            echo "TASKS_GUARD_BASE=${{ github.event.pull_request.base.sha }}" >> "$GITHUB_ENV"\n            if [ "${{ github.event.pull_request.base.sha }}" != "0000000000000000000000000000000000000000" ]; then\n              git fetch origin "${{ github.event.pull_request.base.sha }}" || true\n            fi\n          else\n            echo "TASKS_GUARD_BASE=${{ github.event.before }}" >> "$GITHUB_ENV"\n            if [ "${{ github.event.before }}" != "0000000000000000000000000000000000000000" ]; then\n              git fetch origin "${{ github.event.before }}" || true\n            fi\n          fi\n      - name: Enforce backlog/handoff updates\n        run: scripts/check_task_sync.py\n'
write_file ".github/workflows/tasks-guard.yml" "$tasks_guard"

tasks_script=$'#!/usr/bin/env python3\nimport os\nimport pathlib\nimport subprocess\nimport sys\n\nROOT = pathlib.Path(__file__).resolve().parents[1]\n\n# TODO: keep in sync with check_docs_sync.py\nCORE_PREFIXES = []\n\ndef ensure_base(ref):\n    return ref or "HEAD~1"\n\ndef git_diff(base):\n    base = ensure_base(base)\n    result = subprocess.run(\n        ["git", "diff", "--name-only", f"{base}...HEAD"],\n        cwd=ROOT,\n        capture_output=True,\n        text=True,\n        check=False,\n    )\n    if result.returncode not in (0, 1):\n        print(f"[tasks-guard] git diff failed: {result.stderr.strip()}", file=sys.stderr)\n        sys.exit(2)\n    return [line.strip() for line in result.stdout.splitlines() if line.strip()]\n\ndef matches_core(path):\n    return any(path == p or path.startswith(p) for p in CORE_PREFIXES)\n\ndef needs_tasks(changed):\n    return bool(CORE_PREFIXES) and any(matches_core(path) for path in changed)\n\ndef has_tasks(changed):\n    return any(path.startswith("tasks/") for path in changed)\n\ndef main():\n    base = os.environ.get("TASKS_GUARD_BASE")\n    changed = git_diff(base)\n    if not changed:\n        print("[tasks-guard] No changes detected.")\n        return 0\n\n    print("[tasks-guard] Changed files:\\n" + "\\n".join(f"  - {p}" for p in changed))\n\n    if not needs_tasks(changed):\n        if not CORE_PREFIXES:\n            print("[tasks-guard] CORE_PREFIXES is empty. Configure it to enforce backlog/handoff updates.")\n        else:\n            print("[tasks-guard] No core prefixes touched. Skipping tasks requirement.")\n        return 0\n\n    if has_tasks(changed):\n        print("[tasks-guard] Detected tasks/backlog updates. OK.")\n        return 0\n\n    print("[tasks-guard] Core change detected without tasks/backlog updates.")\n    return 1\n\nif __name__ == "__main__":\n    raise SystemExit(main())\n'
write_file "scripts/check_task_sync.py" "$tasks_script"
chmod +x scripts/check_task_sync.py

echo
echo "[bootstrap] HANDOFF bootstrap complete."
echo "[bootstrap] Next steps:"
echo "  1) Fill in specs/overview.md and create your first real feature spec."
echo "  2) Configure CORE_PREFIXES in scripts/check_docs_sync.py and scripts/check_task_sync.py."
echo "  3) Update tasks/backlog.yaml and SESSION_LOG.md with real project information."
