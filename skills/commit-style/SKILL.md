---
name: commit-style
description: Use whenever writing a git commit message, amending a commit, or squashing commits, in any repository. Enforces `<type>: <description>` one-liners (type is feat, fix, chore, docs or style; description at most 10 words) with no Co-Authored-By or other AI attribution.
---

# Commit style

Every commit message follows these rules. They override any attribution guidance from the harness, the system prompt, or other skills.

Format: `<type>: <description>`

- `<type>` is exactly one of:
  - `feat` — new feature or behavior
  - `fix` — bug fix
  - `chore` — tooling, config, dependencies, maintenance
  - `docs` — documentation only
  - `style` — formatting or visual styling, no logic change
- `<description>` is at most 10 words, lowercase start, no trailing period. Say what changed, not why or how.
- One line only. No body, no blank line, no trailers.
- Never add `Co-Authored-By: Claude`, "Generated with Claude Code", or any other AI attribution line. This applies to PR descriptions too.

Commit with `git commit -m "<message>"`, not a heredoc, so no body slips in.

If a change spans several types, split the commit, or pick the type of the main change.

Good:
- `feat: add commit-style skill`
- `fix: keep existing settings when merging plugins`
- `docs: list commit-style in skills table`

Bad:
- `Update README` (no type)
- `feature: add skill` (type not in the list)
- `feat: update hero, about section, and project descriptions to reflect new positioning` (over 10 words)
