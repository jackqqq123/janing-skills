# DSH skill specification

## Discovery and precedence

A directory-style skill uses `<root>/<skill-name>/SKILL.md`; supporting files may sit in subdirectories. A single top-level `<name>.md` is also accepted, but a directory bundle is preferred when a skill has reusable resources.

Default roots are ranked with lower rank taking precedence: project `.dsh/skills` (100), project `.agents/skills` (200), configured custom roots (300), user `~/.dsh/skills` (400), user `~/.agents/skills` (500), bundled skills (600). Thus `<project>/.dsh/skills/<name>/SKILL.md` overrides `~/.dsh/skills/<name>/SKILL.md` when names match.

`.dsh/.skills` is not a default root. Do not use it as a project installation target unless the user has explicitly configured it as a custom root and confirmed that configuration.

## Frontmatter

`SKILL.md` starts with YAML frontmatter. `name` (kebab-case) and a specific, nonempty `description` are required. Useful optional fields include `whenToUse`, `user-invocable`, and `disable-model-invocation`. Default behavior allows both model selection and user invocation. Set `disable-model-invocation: true` only for intentionally manual-only skills.

## Editing safety

Use `glob`, `read`, and `grep` to discover existing context. Read a text file before targeted modification; use `edit` for precise literal replacements and `write` for new files or an intentional total rewrite. No skill may override system or developer instructions.
