#!/usr/bin/env bash
set -euo pipefail

API_KEY="${API_KEY:-sk-xxxx}"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[\/&|\\]/\\&/g'
}

git config --global user.email "chthollyboss@qq.com"
git config --global user.name "chtholly"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required but was not found in PATH." >&2
  exit 1
fi

npm i -g @openai/codex @anthropic-ai/claude-code
claude update

mkdir -p "$HOME/.codex" "$HOME/.claude"
cp -R "$REPO_DIR/.codex/." "$HOME/.codex/"
cp -R "$REPO_DIR/.claude/." "$HOME/.claude/"

escaped_api_key="$(escape_sed_replacement "$API_KEY")"
sed -i -E "s|(\"OPENAI_API_KEY\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")|\1${escaped_api_key}\2|" "$HOME/.codex/auth.json"
sed -i -E "s|(\"ANTHROPIC_AUTH_TOKEN\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")|\1${escaped_api_key}\2|" "$HOME/.claude/settings.json"
