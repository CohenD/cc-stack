# cc-stack — agent guide

Pre-wired Claude Code workspace: **Next.js 16 · AI SDK 7 · shadcn/ui · Tailwind v4 (OKLCH) · Zod 4 · DuckDB.** Skills live in `.claude/skills/`, MCP servers in `.mcp.json` — prefer these live sources over working from memory.

## Reach for

- **UI (so it doesn't look AI-generated):** invoke `frontend-design` to set an aesthetic direction *before* building; pull components from the `shadcn` MCP/skill instead of hand-rolling primitives — but give them a point of view, not default-shadcn-everywhere.
- **AI features:** `ai-sdk` skill; default to the latest Claude via `@ai-sdk/anthropic`. v6→v7 upgrades: `migrate-ai-sdk-v6-to-v7`.
- **Validation:** `zod` skill (v4 — `z.codec`, `z.toJSONSchema`, unified `error`). There is **no Zod MCP**, so the skill is the source of truth.
- **Next.js runtime/docs:** `next-devtools` MCP — run `npm run dev` first for live errors.
- **Data:** `duckdb` MCP — read-write SQL over `${DUCKDB_PATH:-./data/dev.duckdb}`.

## Rules

- **Never hard-code hex.** Colors are OKLCH CSS vars in `app/globals.css`; register new ones via `@theme inline` (Tailwind v4), never a new CSS file. Style with semantic tokens (`bg-background`, `text-muted-foreground`, `border-border`).
- Merge classes with `cn()` from `@/lib/utils`. Path alias `@/*` → repo root.
