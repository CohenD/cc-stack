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
./setup.sh            # installs deps, syncs skills, seeds .env.local + data/
npm run cc            # loads .env.local and launches Claude Code, fully wired
```

`npm run cc` is the "single tap": it sources `.env.local` (so the MCP servers can
read your keys) and then runs `claude`. You can also just run `claude` directly if
you've exported the env vars yourself, or if you don't need the Google docs server.

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

Re-sync at any time with `npx skills install`.

### MCP servers — [`.mcp.json`](./.mcp.json), auto-approved by [`.claude/settings.json`](./.claude/settings.json)

| Server | Transport | Command / URL | Needs |
| --- | --- | --- | --- |
| `next-devtools` | stdio | `npx -y next-devtools-mcp@latest` | a running `npm run dev` for live errors |
| `shadcn` | stdio | `npx -y shadcn@latest mcp` | `components.json` (included) |
| `duckdb` | stdio | `uvx mcp-server-motherduck --db-path … --read-write` | [`uv`](https://docs.astral.sh/uv/) installed |
| `google-docs` | sse | `https://developerknowledge.googleapis.com/mcp` | `GOOGLE_API_KEY` |

`enableAllProjectMcpServers: true` in `.claude/settings.json` means these start
**without a per-server trust prompt** when you open Claude Code here.

---

## Environment

Copy `.env.example` → `.env.local` and fill in what you want:

| Var | Used by | Required? |
| --- | --- | --- |
| `GOOGLE_API_KEY` | `google-docs` MCP | Only to enable that server |
| `DUCKDB_PATH` | `duckdb` MCP | Optional (defaults to `./data/dev.duckdb`) |
| `ANTHROPIC_API_KEY` | the app's AI SDK code | Only if you build AI features |

> Claude Code expands `${VAR}` in `.mcp.json` from the **launching shell's**
> environment — it does not read `.env.local` on its own. `npm run cc` handles the
> sourcing for you; otherwise `export` the vars before running `claude`.

---

## Notes & deviations from the original brief

I verified every package/endpoint while building this. Two corrections:

- **shadcn MCP** → the working command is `npx shadcn@latest mcp` (the MCP server
  ships inside the `shadcn` CLI). There is no `@shadcn/mcp-server` package on npm.
- **Zod MCP** → **omitted.** No official Zod MCP server exists on npm
  (`@zod/mcp-server`, `zod-mcp`, `@zod/mcp` all 404; the only hit is an unrelated
  third-party tool). Adding a non-existent server would just fail at launch, so
  Zod is left out and Claude relies on its Zod 4 knowledge. If an official one
  ships later, add it to `.mcp.json`.

Everything else (`next-devtools-mcp@latest`, `mcp-server-motherduck` on PyPI, the
Google Developer Knowledge endpoint) was confirmed live.

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
├── .agents/skills/        # vendored skills (ai-sdk, migrate…, shadcn)
├── skills-lock.json       # skill provenance + hashes
├── CLAUDE.md              # in-repo guide Claude reads on entry
├── setup.sh               # one-shot bootstrap
├── components.json        # shadcn config (new-york, Tailwind v4, OKLCH)
├── app/                   # minimal Next 16 app (so the MCPs have a target)
│   ├── layout.tsx · page.tsx · globals.css
├── lib/utils.ts           # cn() helper
└── data/                  # local DuckDB files live here (gitignored)
```
