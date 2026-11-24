#!/usr/bin/env bash
# Workstation setup for Claude Code / Zed on macOS, Linux or WSL.
#
# Usage (from the repo folder):
#   ./install.sh                        # install skills for all projects (~/.claude/skills)
#   ./install.sh --project ~/code/repo  # install skills into one project only
#   ./install.sh --skip-zed             # don't touch Zed settings

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT=""
SKIP_ZED=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --skip-zed) SKIP_ZED=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --- Skills ---------------------------------------------------------------
if [[ -n "$PROJECT" ]]; then
  SKILLS_TARGET="$(cd "$PROJECT" && pwd)/.claude/skills"
else
  SKILLS_TARGET="$HOME/.claude/skills"
fi
mkdir -p "$SKILLS_TARGET"

for skill in "$REPO_DIR"/skills/*/; do
  [[ -d "$skill" ]] || continue  # no skills yet: the glob stays literal
  name="$(basename "$skill")"
  rm -rf "${SKILLS_TARGET:?}/$name"
  cp -R "$skill" "$SKILLS_TARGET/$name"
  echo "  skill: $name"
done
echo "Skills installed to $SKILLS_TARGET"

# --- Settings + plugins (merged into ~/.claude/settings.json; Claude installs plugins on next start) ---
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if command -v jq >/dev/null; then
  mkdir -p "$HOME/.claude"
  [[ -f "$CLAUDE_SETTINGS" ]] || echo '{}' > "$CLAUDE_SETTINGS"
  cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
  jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" "$REPO_DIR/claude/settings.json" > "$CLAUDE_SETTINGS.tmp"
  mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
  echo "Settings and plugins merged into $CLAUDE_SETTINGS"
else
  echo "jq not found: skipped settings and plugins. Install jq and re-run, or add them by hand (see README)." >&2
fi

# --- Zed settings ---------------------------------------------------------
if [[ $SKIP_ZED -eq 0 ]]; then
  ZED_DIR="$HOME/.config/zed"
  ZED_SETTINGS="$ZED_DIR/settings.json"
  mkdir -p "$ZED_DIR"
  if [[ -f "$ZED_SETTINGS" ]]; then
    backup="$ZED_SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$ZED_SETTINGS" "$backup"
    echo "Backed up existing Zed settings to $backup"
  fi
  cp "$REPO_DIR/zed/settings.unix.json" "$ZED_SETTINGS"
  echo "Zed settings installed to $ZED_SETTINGS"
fi

echo
echo "Done. Restart Zed, start a Claude Agent thread, and run /login once on this machine."
