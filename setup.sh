#!/usr/bin/env bash
# cc-stack bootstrap — gets a fresh clone ready for a Claude Code job.
set -euo pipefail

cd "$(dirname "$0")"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn() { printf "  \033[33m!\033[0m %s\n" "$1"; }

bold "cc-stack setup"

# 1. Tooling check ----------------------------------------------------------
bold "Checking tools"
command -v node >/dev/null && ok "node $(node -v)"        || { warn "node not found — install Node 20+"; exit 1; }
command -v npx  >/dev/null && ok "npx available"           || { warn "npx not found";                     exit 1; }
command -v uvx  >/dev/null && ok "uvx available (DuckDB MCP)" || warn "uvx not found — install uv (https://docs.astral.sh/uv/) for the duckdb MCP server"
command -v claude >/dev/null && ok "claude CLI available"  || warn "claude CLI not found — install Claude Code to use the wiring"

# 2. Dependencies -----------------------------------------------------------
bold "Installing npm dependencies"
npm install
ok "node_modules ready"

# 3. Skills -----------------------------------------------------------------
bold "Syncing skills from skills-lock.json"
npx -y skills install || warn "skills sync skipped (the skills are already vendored in .agents/skills/)"
ok "skills ready"

# 4. Env + data -------------------------------------------------------------
bold "Local config"
if [ ! -f .env.local ]; then
  cp .env.example .env.local
  ok "created .env.local (edit it to add GOOGLE_API_KEY / ANTHROPIC_API_KEY)"
else
  ok ".env.local already exists"
fi
mkdir -p data
ok "data/ ready for DuckDB files"

# 5. Done -------------------------------------------------------------------
bold "Done."
echo
echo "  Next:"
echo "    1. (optional) edit .env.local to add your API keys"
echo "    2. npm run cc      # launch Claude Code with everything wired"
echo "    3. npm run dev     # run the app (also powers the next-devtools MCP)"
