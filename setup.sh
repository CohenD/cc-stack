#!/usr/bin/env bash
# cc-stack bootstrap — gets a fresh clone ready for a Claude Code job.
set -euo pipefail

cd "$(dirname "$0")"

bold() { printf "\n\033[1m%s\033[0m\n" "$1"; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn() { printf "  \033[33m!\033[0m %s\n" "$1"; }

# Ensure uv/uvx is available — it runs the DuckDB MCP server (mcp-server-motherduck,
# a Python package). uvx then auto-installs the server's Python deps on first run.
ensure_uv() {
  if command -v uvx >/dev/null 2>&1; then
    ok "uv present ($(uv --version 2>/dev/null || echo installed))"
    return 0
  fi
  warn "uv not found — installing it (needed for the duckdb MCP server)"
  if command -v brew >/dev/null 2>&1; then
    brew install uv >/dev/null 2>&1 || true
  fi
  if ! command -v uvx >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
      curl -LsSf https://astral.sh/uv/install.sh | sh
    elif command -v wget >/dev/null 2>&1; then
      wget -qO- https://astral.sh/uv/install.sh | sh
    else
      warn "no curl/wget available — install uv manually, then re-run:"
      warn "  https://docs.astral.sh/uv/getting-started/installation/"
      return 0
    fi
    # uv's standalone installer drops binaries here — make them visible now.
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  fi
  if command -v uvx >/dev/null 2>&1; then
    ok "uv installed ($(uv --version 2>/dev/null))"
  else
    warn "uv installed but not yet on PATH — open a new shell (or add ~/.local/bin to PATH)"
  fi
}

bold "cc-stack setup"

# 1. Tooling check ----------------------------------------------------------
bold "Checking tools"
command -v node   >/dev/null && ok "node $(node -v)"       || { warn "node not found — install Node 20+"; exit 1; }
command -v npx    >/dev/null && ok "npx available"          || { warn "npx not found"; exit 1; }
command -v claude >/dev/null && ok "claude CLI available"   || warn "claude CLI not found — install Claude Code to use the wiring"

# 2. uv (DuckDB MCP dependency) ---------------------------------------------
bold "DuckDB MCP dependency (uv)"
ensure_uv

# 3. Node dependencies ------------------------------------------------------
bold "Installing npm dependencies"
npm install
ok "node_modules ready"

# 4. Skills -----------------------------------------------------------------
bold "Verifying skills (vendored in repo; restoring from skills-lock.json)"
npx -y skills experimental_install </dev/null 2>/dev/null || warn "lockfile restore skipped — skills are already vendored in the repo"
ok "skills ready"

# 5. DuckDB: data dir + pre-fetch server ------------------------------------
bold "DuckDB workspace"
mkdir -p data
ok "data/ ready for DuckDB files (default: ./data/dev.duckdb)"
if command -v uvx >/dev/null 2>&1; then
  printf "  … pre-fetching mcp-server-motherduck (first run only)\n"
  if uvx mcp-server-motherduck --help >/dev/null 2>&1; then
    ok "DuckDB MCP server cached — starts instantly in Claude Code"
  else
    warn "could not pre-fetch the DuckDB server now; it'll download on first use"
  fi
else
  warn "skipping DuckDB pre-fetch (uv not on PATH yet)"
fi

# 6. Env --------------------------------------------------------------------
bold "Local config"
if [ ! -f .env.local ]; then
  cp .env.example .env.local
  ok "created .env.local (add ANTHROPIC_API_KEY if you build AI features)"
else
  ok ".env.local already exists"
fi

# 7. Done -------------------------------------------------------------------
bold "Done."
echo
echo "  Next:"
echo "    1. (optional) edit .env.local to add your API keys"
echo "    2. npm run cc      # launch Claude Code with everything wired"
echo "    3. npm run dev     # run the app (also powers the next-devtools MCP)"
