#!/usr/bin/env sh
# Launch Claude Code with this project's environment loaded.
#
# Why a script instead of an inline npm command: this parses .env.local line by
# line and exports each KEY=value literally. It does NOT dot-source the file, so
# a value containing spaces, '#', or '$(...)' is treated as data — never executed.
# It also prepends uv's default install dir to PATH so the duckdb MCP server is
# reachable in the same terminal that just ran ./setup.sh.
set -e

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if [ -f .env.local ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;   # skip blanks and comments
      *=*) export "$line" ;; # KEY=value — exported verbatim, no expansion
    esac
  done < .env.local
fi

exec claude "$@"
