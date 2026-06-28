# cc-stack — agent guide

This repo is a **pre-wired Claude Code workspace**. On clone, you (Claude) have a
fixed set of Skills and MCP servers available. Use them — don't work from memory
when a live source exists.

## Stack

Next.js 16 · Vercel AI SDK 7 · shadcn/ui · Tailwind v4 (OKLCH) · Zod 4 · DuckDB

## Skills (vendored in `.agents/skills/`, tracked by `skills-lock.json`)

| Skill | Use it when |
| --- | --- |
| `ai-sdk` | Building anything with the Vercel AI SDK — `generateText`, `streamText`, agents, tools, `useChat`, structured output, embeddings. |
| `migrate-ai-sdk-v6-to-v7` | Upgrading AI SDK code from v6 → v7 (breaking changes, `system`→`instructions`, telemetry, tool context). |
| `shadcn` | Adding/searching/styling shadcn components, working with `components.json`, registries, or `--preset` codes. |
| `zod` | Writing or debugging Zod **v4** schemas — `.refine()`, `.transform()`, `z.codec()`, type inference, `z.toJSONSchema()`, error handling, or v3→v4 migration. Has references for advanced patterns, type-inference, and a migration guide. |

## MCP servers (`.mcp.json`, auto-approved via `.claude/settings.json`)

| Server | What it gives you |
| --- | --- |
| `next-devtools` | Connects to the running `next dev` server for live runtime errors, route trees, server logs, and a `nextjs_docs` gateway that reads local `node_modules/next/dist/docs/`. **Run `npm run dev` first** for the live-error tools. |
| `shadcn` | Live registry: search/browse/view/install across the shadcn ecosystem (`shadcn:search_items_in_registries`, `shadcn:view_items_in_registries`, `shadcn:get_add_command_for_items`). Needs `components.json` (present). |
| `duckdb` | SQL over the local DuckDB file (`${DUCKDB_PATH:-./data/dev.duckdb}`), **read-write** — can create/drop tables while prototyping. |

## Conventions

- **Styling:** Tailwind v4 with shadcn semantic tokens. Use utility classes like
  `bg-background`, `text-muted-foreground`, `border-border`. **Never hard-code hex
  colors** — colors live as OKLCH CSS variables in `app/globals.css`. Register new
  colors via `@theme inline` (Tailwind v4), never a new CSS file.
- **Components:** Prefer the `shadcn` MCP to find/install components over writing
  primitives by hand. Merge classes with `cn()` from `@/lib/utils`.
- **AI features:** Use the `ai-sdk` skill; default to the latest Claude models via
  `@ai-sdk/anthropic`.
- **Next.js runtime issues:** Use `next-devtools` MCP to read real errors and the
  local Next docs gateway rather than guessing API shapes.
- **Validation:** Zod 4. Use the `zod` skill (it targets v4: `z.codec`,
  `z.toJSONSchema`, `z.treeifyError`, unified `error` param). There is **no Zod
  MCP server** (none exists on npm), so the skill is the source of truth — prefer
  it over memory, especially for v4-only APIs and v3→v4 migration.

## Path aliases

`@/*` → repo root (e.g. `@/lib/utils`, `@/components/ui/button`).
