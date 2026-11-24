# AI-work-station-setup

My Claude Code + Zed setup: my own skills plus a curated list of third-party plugins. Clone it on a new machine, run one script, done.

## What's in here

```
skills/                 Claude Code skills, mine plus selected third-party ones (one folder per skill, each with a SKILL.md)
claude/settings.json    Claude Code settings (model, tui, theme) and curated plugins, merged into ~/.claude/settings.json
zed/settings.*.json     Zed editor settings (Git Bash terminal on Windows)
install.ps1             Installer for Windows (PowerShell)
install.sh              Installer for macOS / Linux / WSL
```

## Set up a new workstation

First install Claude Code: `irm https://claude.ai/install.ps1 | iex` (Windows PowerShell) or `curl -fsSL https://claude.ai/install.sh | bash` (macOS / Linux / WSL). See https://docs.claude.com/en/docs/claude-code/setup.

**Windows (PowerShell):**

```powershell
git clone https://github.com/AlexGreau/AI-work-station-setup.git AI-work-station-setup
cd AI-work-station-setup
.\install.ps1
```

If PowerShell blocks the script, run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once.

**macOS / Linux / WSL:**

```bash
git clone https://github.com/AlexGreau/AI-work-station-setup.git AI-work-station-setup
cd AI-work-station-setup
./install.sh
```

Then restart Zed, open a Claude Agent thread (agent panel → `+` → Claude Agent), and run `/login` once to sign in with your Claude subscription.

### Options

| Want to…                                   | Windows                          | macOS / Linux                    |
| ------------------------------------------ | -------------------------------- | -------------------------------- |
| Install skills into one project only        | `.\install.ps1 -Project C:\path` | `./install.sh --project ~/path`  |
| Leave Zed settings alone                    | `.\install.ps1 -SkipZed`         | `./install.sh --skip-zed`        |

By default skills go to `~/.claude/skills/` (available in every project). With the project option they go to `<project>/.claude/skills/` and exist only there.

The installer backs up `~/.claude/settings.json` before adding plugins (your other settings are kept), and backs up any existing Zed `settings.json` before replacing it (`settings.json.bak-<timestamp>`).

## Add a skill

1. Create `skills/<skill-name>/SKILL.md` (plus any scripts or reference files the skill uses).
2. Commit and push.
3. On each machine: `git pull`, then re-run the installer.

To grab a skill from GitHub, use its *raw* URL:

```bash
mkdir -p skills/<skill-name>
curl -L -o skills/<skill-name>/SKILL.md https://raw.githubusercontent.com/<owner>/<repo>/main/<path>/SKILL.md
```

## Update

```bash
git pull
./install.sh        # or .\install.ps1 on Windows
```

## Skills included

| Skill | Invoke with | Source |
| ----- | ----------- | ------ |
| commit-style | Model-invoked on every commit: `feat/fix/chore/docs/style: <≤10 words>`, no AI attribution | mine |
| grill-me | /grill-me | [mattpocock/skills](https://github.com/mattpocock/skills) |
| grilling | Model-invoked, called by grill-me | [mattpocock/skills](https://github.com/mattpocock/skills) |
| doubt-driven-development | Model-invoked, for non-trivial decisions | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |

## Curated plugins

Listed in `claude/settings.json`. Claude Code installs them the next time it starts. To add one, put its marketplace under `extraKnownMarketplaces` and `"<plugin>@<marketplace>": true` under `enabledPlugins`, then re-run the installer. On macOS/Linux the merge needs `jq`.

| Plugin | What it does | Source |
| ------ | ------------ | ------ |
| ponytail | Lazy senior dev mode: smallest complete change, plus review/audit skills | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| pstack | poteto's (Lauren Tan) pstack ported to Claude Code: architect, interrogate, swarm, tdd, principles… | [michael-denyer/pstack-claude](https://github.com/michael-denyer/pstack-claude) |
| modern-web-guidance | Google Chrome's guidance toward current web platform APIs (preview) | [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance) |
| frontend-design | Distinctive UI design guidance | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) |
| skill-creator | Create and evaluate skills | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) |

Manual equivalent, inside Claude Code:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
/plugin marketplace add michael-denyer/pstack-claude
/plugin install pstack@pstack-claude
/plugin marketplace add GoogleChrome/modern-web-guidance
/plugin install modern-web-guidance@googlechrome
```

## Not covered by this repo

- **Claude login**: per machine, run `/login` in a Claude Agent thread.
- **Git for Windows**: needed for the Git Bash terminal setting. Install from https://git-scm.com.
- **Project-specific config** (`CLAUDE.md`, `.claude/settings.json` permissions): keep those in each project's own repo.
