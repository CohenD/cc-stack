# cc-stack

A **pre-wired Claude Code workspace**. Clone it, run one command, and Claude Code
boots with a curated set of Skills and MCP servers already connected — no manual
`claude mcp add` / `skills add` dance.

**Stack:** Next.js 16 · Vercel AI SDK 7 · shadcn/ui · Tailwind v4 (OKLCH) · Zod 4 · DuckDB

---

## Quick start

```bash
git clone https://github.com/CohenD/cc-stack.git
cd cc-stack
./setup.sh            # installs uv + deps, caches DuckDB MCP, syncs skills, seeds .env.local + data/
npm run cc            # loads .env.local and launches Claude Code, fully wired
```

`npm run cc` is the "single tap": it sources `.env.local` (e.g. an optional
`DUCKDB_PATH`) and then runs `claude`. You can also just run `claude` directly —
no MCP server requires a key out of the box.

To run the app itself:

```bash
npm run dev           # http://localhost:3000  (also powers the next-devtools MCP)
```

---

## What's wired

### Skills — vendored in `.agents/skills/`, tracked by [`skills-lock.json`](./skills-lock.json)

These ship **in the repo**, so they're available the moment you clone — nothing to install.

| Skill | Source | Purpose |
| --- | --- | --- |
| `ai-sdk` | `vercel/ai` | Build with the Vercel AI SDK (generateText/streamText/agents/tools/useChat). |
| `migrate-ai-sdk-v6-to-v7` | `vercel/ai` | Upgrade AI SDK code from v6 → v7. |
| `shadcn` | `shadcn/ui` | Add/search/style shadcn components; understands your `components.json`. |
| `zod` | `secondsky/claude-skills` | Zod **v4** expert: type inference, `.refine()`/`.transform()`, `z.codec()`, JSON-Schema, error handling, v3→v4 migration. |

Re-sync at any time with `npm run skills:sync`.

### MCP servers — [`.mcp.json`](./.mcp.json), auto-approved by [`.claude/settings.json`](./.claude/settings.json)

| Server | Transport | Command / URL | Needs |
| --- | --- | --- | --- |
| `next-devtools` | stdio | `npx -y next-devtools-mcp@latest` | a running `npm run dev` for live errors |
| `shadcn` | stdio | `npx -y shadcn@latest mcp` | `components.json` (included) |
| `duckdb` | stdio | `uvx mcp-server-motherduck --db-path … --read-write` | [`uv`](https://docs.astral.sh/uv/) (auto-installed by `setup.sh`) |

`enableAllProjectMcpServers: true` in `.claude/settings.json` means these start
**without a per-server trust prompt** when you open Claude Code here.

---

## Environment

Copy `.env.example` → `.env.local` and fill in what you want:

| Var | Used by | Required? |
| --- | --- | --- |
| `DUCKDB_PATH` | `duckdb` MCP | Optional (defaults to `./data/dev.duckdb`) |
| `ANTHROPIC_API_KEY` | the app's AI SDK code | Only if you build AI features |

> Claude Code expands `${VAR}` in `.mcp.json` from the **launching shell's**
> environment — it does not read `.env.local` on its own. `npm run cc` handles the
> sourcing for you; otherwise `export` the vars before running `claude`.

---

## Notes & deviations from the original brief

I verified every package/endpoint while building this. A few notes:

- **shadcn MCP** → the working command is `npx shadcn@latest mcp` (the MCP server
  ships inside the `shadcn` CLI). There is no `@shadcn/mcp-server` package on npm.
- **Zod** → covered by a **skill, not an MCP.** No official Zod MCP server exists
  on npm (`@zod/mcp-server`, `zod-mcp`, `@zod/mcp` all 404; the only hit is an
  unrelated third-party tool), so wiring one would just fail at launch. Instead a
  vendored **Zod v4 skill** (`secondsky/claude-skills`, 179★ MIT, verified to
  target Zod 4.1.12+) gives Claude expert coverage offline. If an official MCP
  ships later, add it to `.mcp.json`.

- **Google GenAI / Developer Knowledge MCP** → **removed for now.** To add it
  back, restore a `google-docs` SSE block in `.mcp.json`
  (`https://developerknowledge.googleapis.com/mcp`, header
  `X-Goog-Api-Key: ${GOOGLE_API_KEY}`) and set `GOOGLE_API_KEY` in `.env.local`.

Everything else (`next-devtools-mcp@latest`, `mcp-server-motherduck` on PyPI) was
confirmed live.

---

## Security note

`enableAllProjectMcpServers: true` auto-starts the MCP servers listed in
`.mcp.json` with your local permissions. That's the point — frictionless wiring —
but it means **only open this workspace in Claude Code if you trust its contents.**
If you'd rather approve servers individually, delete that line from
`.claude/settings.json`.

---

## Layout

```
.
├── .mcp.json              # MCP server definitions (project scope)
├── .claude/settings.json  # auto-approves the project MCP servers
├── .agents/skills/        # vendored skills (ai-sdk, migrate…, shadcn, zod)
├── skills-lock.json       # skill provenance + hashes
├── CLAUDE.md              # in-repo guide Claude reads on entry
├── setup.sh               # one-shot bootstrap
├── components.json        # shadcn config (new-york, Tailwind v4, OKLCH)
├── app/                   # minimal Next 16 app (so the MCPs have a target)
│   ├── layout.tsx · page.tsx · globals.css
├── lib/utils.ts           # cn() helper
└── data/                  # local DuckDB files live here (gitignored)
```
