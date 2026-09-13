---
name: skill-creator-dsh
description: Create, improve, review, install, and evaluate DeepSeek Harness skills. Use when the user wants a reusable DSH skill, a Claude Code skill migration, DSH skill installation guidance, or a rigorous skill assessment; do not use for ordinary implementation tasks that do not create or change a reusable skill.
whenToUse: DeepSeek Harness (DSH)-specific variant tuned for DSH tooling. Use only for DSH skill authoring, migration, review, installation, and evaluation; other tools should use the generic skill-creator.
user-invocable: true
---

# DeepSeek Harness Skill Creator

Create DSH-native skills that are clear, safe, testable, and correctly installed. Follow the user's language for explanations and generated prose. Keep YAML keys, tool names, and filesystem conventions in their canonical English form.

## Select the working mode

State the mode before acting:

1. **Create** a reusable skill.
2. **Improve** an existing skill after reading it.
3. **Review** an existing skill without altering it unless asked.
4. **Evaluate** a skill with the full evaluation protocol.
5. **Quick** only when the user explicitly accepts skipping the full evaluation.

Use `todo_write` for multi-step work. Use `create_goal` only for a genuine long-running user objective. Use `ralph` only if the user expressly requests a Ralph loop.

## Resolve installation before any write

Inspect the target using `glob` and `read` before changing existing files, then state the final absolute path.

| Scope | Default target |
|---|---|
| User/global | `~/.dsh/skills/<skill-name>/` |
| Project | `<project-root>/.agents/skills/<skill-name>/` |

- A same-name project skill overrides a user/global skill.
- `.dsh/.skills` is **not** a default DSH discovery path. Correct it to `.agents/skills`; do not silently create the nonstandard directory.
- Project root is the nearest ancestor containing `.git`. If it cannot be established, ask the user for the project root.
- Read existing text before targeted modification. Use `edit` for precise replacements; use `write` for new files or deliberate full replacements. Ask for explicit confirmation before any deletion, overwrite, or migration of a skill or its files, regardless of whether user data would otherwise be discarded.

Read `references/dsh-skill-spec.md` for format and path rules. When migrating a Claude skill, first read `references/tool-mapping.md`.

## Discover only what is missing

Use information already in the conversation. If material details are absent, the **main agent** uses `ask_user_question` to ask about task and users, trigger and close non-trigger prompts, inputs/outputs/failure behavior, installation scope, success criteria, and dependencies such as network, file writes, commands, or subagents.

Subagents may research, implement, or review. They must not replace the main agent for human confirmation.

## Author the skill bundle

Create a directory bundle whose root file is `SKILL.md`. Frontmatter must contain a unique kebab-case `name` and a specific `description` that says what the skill does, when it should run, and relevant boundaries. Preserve automatic invocation and `/skill-name` invocation by default; do not set `disable-model-invocation: true` unless the user explicitly requests manual-only operation.

Write an executable workflow around decisions and reasons rather than unexplained command lists. Keep `SKILL.md` normally below 500 lines. Put large domain knowledge in `references/`; reserve `scripts/` for deterministic, local, repeatable work. A skill must defer to system and developer instructions and must not claim permissions it does not have.

Translate all Claude Code-specific instructions via `references/tool-mapping.md`. Do not leave Claude-only calls such as `claude -p`, Bash syntax, or Claude packaging assumptions.

## Run a full evaluation by default

Unless quick mode was explicitly approved, follow `references/eval-protocol.md`. Create `<target-skill>/evals/` containing:

- `cases.json`, at least three cases: intended success, boundary, and close non-trigger/refusal;
- `baseline/`, records from comparable runs without the target skill;
- `with-skill/`, records from comparable runs with the target skill;
- `results.json`, evidence, assertions, reviewer verdicts, and limitations;
- `report.html`, an offline static comparison report.

Use DSH `subagent` or `subagent_fork` for independent execution and review. Keep prompts, model configuration, and available context as equivalent as possible between baseline and with-skill runs; the intended difference is target-skill injection. Prefer observable assertions. Send subjective assessment to an independent reviewer subagent and retain its rationale. Disclose sample size, stochasticity, and environment limits; do not claim statistical significance.

The included renderer only converts existing local JSON to HTML. DSH has no confirmed equivalent to scripted `claude -p` invocation. **Never invent a CLI runner, external service, temporary workaround, or new tool.** If a required DSH capability is missing, stop and have the main agent obtain the user's technical confirmation.

## Resources and dependencies

- Read `references/dsh-skill-spec.md` for DSH frontmatter, discovery roots, and precedence; read `references/tool-mapping.md` before migrating a Claude Code skill; read `references/eval-protocol.md` for the evaluation layout.
- `scripts/render-eval-report.ps1` requires Windows PowerShell (`powershell.exe`) and performs only local file I/O: it reads a local `results.json` plus `templates/eval-report.html` and writes a static HTML report. It never calls a model or the network.
- `templates/` holds JSON Schemas, the report template, and sample fixtures used by the evaluation protocol.

## Validate and close

Before claiming completion:

1. Validate frontmatter, kebab-case name, nonempty description, referenced paths, and file structure.
2. Exercise representative prompts; in full mode persist evaluation records and render the report.
3. Delegate an independent subagent review of DSH compatibility, install precedence, tool mapping, safety, and evaluation artifacts.
4. Repair confirmed findings and recheck them.
5. Report actual changed files, final scope/path, invocation examples, evaluation result, and limitations.
