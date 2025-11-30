[OpenSpec](https://github.com/Fission-AI/OpenSpec) is much better

---

# HANDOFF

> **HANDOFF = Handoff Assures Notes, Docs, Outcomes For Features.**  
> A spec-driven, CI-guarded workflow bootstrap for humans and AI agents.

HANDOFF turns any Git repository into a **spec-driven, CI-guarded, multi-agent-friendly workflow**.

It does **one main thing**:

> Create a minimal structure and an `AGENTS.md` “constitution” so that an AI agent (or human) can guide you through the rest of the setup.

All the detailed onboarding instructions live in **`AGENTS.md`**, not in this README.

---

## What the bootstrap does

Running one of the scripts will:

- Create `AGENTS.md` and `CLAUDE.md` (symlink or copy)
- Initialize a basic directory layout:

  ```text
  specs/
    overview.md
    features/F-000-template.md
    adr/ADR-000-template.md

  SESSION_LOG.md

  tasks/
    backlog.yaml
    handoff/

  .github/workflows/
    docs-guard.yml
    tasks-guard.yml

  scripts/
    check_docs_sync.py
    check_task_sync.py
  ```

- Configure lightweight CI guards that can later be wired to **“core paths”** (via `CORE_PREFIXES` in the Python scripts).

The actual workflow (how to write specs, how to log sessions, how to hand off work) is explained to the agent in **`AGENTS.md`**.

---

## Language selection (`--lang`)

All bootstrap scripts support a `--lang` flag:

- `--lang <LANG>` controls the **first line** of `AGENTS.md`:

  ```text
  always reply in English
  ```

  or:

  ```text
  always reply in Chinese
  always reply in Japanese
  ...
  ```

You can pass any string you like (language name, locale code, etc.).  
The rest of `AGENTS.md` is in English; the **agent** is expected to use that first line as the language hint.

If you omit `--lang`, the default is:

```text
always reply in English
```

---

## Quickstart

1. **Run the bootstrap script** in an existing or new Git repo:

   ### PowerShell

   ```powershell
   # From the repo root
   .\handoff.ps1
   # or with language + overwrite
   .\handoff.ps1 --lang "Chinese" --force
   ```

   ### Bash

   ```bash
   chmod +x handoff.sh
   ./handoff.sh
   ./handoff.sh --lang "Chinese" --force
   ```

   ### Fish

   ```fish
   chmod +x handoff.fish
   ./handoff.fish
   ./handoff.fish --lang "Chinese" --force
   ```

2. **Commit the generated files** (optional but recommended):

   ```bash
   git add AGENTS.md CLAUDE.md specs SESSION_LOG.md tasks .github scripts
   git commit -m "chore: bootstrap HANDOFF workflow"
   ```

3. **Open your AI agent / copilot on this repo**  
   Then prompt it with something like:

   > “Read `AGENTS.md` and guide me through the HANDOFF onboarding for this repo.”

   The agent should:
   - Read the “constitution” in `AGENTS.md`
   - Help you fill in `specs/overview.md`
   - Create the first feature spec from `specs/features/F-000-template.md`
   - Initialize `tasks/backlog.yaml` and `SESSION_LOG.md`
   - Help you decide and configure `CORE_PREFIXES` in the guard scripts

---

## After onboarding

Once the agent-guided onboarding is done, you should have:

- A real project overview in `specs/overview.md`
- At least one concrete feature spec under `specs/features/`
- Initial entries in `tasks/backlog.yaml`
- The first session recorded in `SESSION_LOG.md`
- `CORE_PREFIXES` configured in:
  - `scripts/check_docs_sync.py`
  - `scripts/check_task_sync.py`

From that point on, the CI guards will start enforcing the HANDOFF rules for your “core” changes.
