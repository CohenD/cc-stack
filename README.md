# cc-stack

A **pre-wired Claude Code workspace**. Clone it, run one command, and Claude Code
boots with a curated set of Skills and MCP servers already connected — no manual
`claude mcp add` / `skills add` dance.

**Stack:** Next.js 16 · Vercel AI SDK 7 · shadcn/ui · Tailwind v4 (OKLCH) · Zod 4 · DuckDB

---

## Prerequisites

- **Node 20.9+** (the repo pins Node 22 via `.nvmrc`; `nvm use` picks it up)
- The **[Claude Code](https://claude.com/claude-code) CLI** (`claude`) — this is what consumes the wiring
- **macOS or Linux** (or **Windows via WSL** — `setup.sh` is a bash script)
- `setup.sh` installs **[uv](https://docs.astral.sh/uv/)** for you if it's missing (it runs the DuckDB MCP server)

---

## Quick start

```bash
git clone https://github.com/CohenD/cc-stack.git
cd cc-stack
./setup.sh            # installs uv + deps, caches the DuckDB MCP, seeds .env.local + data/
npm run cc            # loads .env.local and launches Claude Code, fully wired
```

`npm run cc` is the "single tap": [`scripts/cc.sh`](./scripts/cc.sh) safely loads
`.env.local` (parsing it, never executing it) and ensures `uv` is on `PATH`, then
runs `claude`. You can also just run `claude` directly — no MCP server requires a
key out of the box.

To run the app itself:

```bash
npm run dev           # http://localhost:3000  (also powers the next-devtools MCP)
```

> **Windows:** run the commands inside **WSL**. `setup.sh` and `scripts/cc.sh`
> are POSIX shell scripts; native PowerShell/CMD won't run them.

---

## What's wired

### Skills — vendored as plain files in `.claude/skills/`

These ship **in the repo**, so Claude Code discovers them the moment you clone —
nothing to install, no network needed.

| Skill | Source | Purpose |
| --- | --- | --- |
| `ai-sdk` | `vercel/ai` | Build with the Vercel AI SDK (generateText/streamText/agents/tools/useChat). |
| `migrate-ai-sdk-v6-to-v7` | `vercel/ai` | Upgrade AI SDK code from v6 → v7. |
| `shadcn` | `shadcn/ui` | Add/search/style shadcn components; understands your `components.json`. |
| `frontend-design` | `anthropics/skills` | Distinctive, intentional UI design — typography, palette, signature element — so output doesn't read as templated AI defaults. Pairs with `shadcn` + Tailwind v4. |
| `zod` | `secondsky/claude-skills` | Zod **v4** expert: type inference, `.refine()`/`.transform()`, `z.codec()`, JSON-Schema, error handling, v3→v4 migration. |

### MCP servers — [`.mcp.json`](./.mcp.json), allow-listed by [`.claude/settings.json`](./.claude/settings.json)

| Server | Transport | Command | Needs |
| --- | --- | --- | --- |
| `next-devtools` | stdio | `npx -y next-devtools-mcp@0.4.0` | a running `npm run dev` for live errors |
| `shadcn` | stdio | `npx -y shadcn@latest mcp` | `components.json` (included) |
| `duckdb` | stdio | `uvx mcp-server-motherduck@1.0.7 --db-path … --read-write` | [`uv`](https://docs.astral.sh/uv/) (auto-installed by `setup.sh`) |

`.claude/settings.json` names these three under `enabledMcpjsonServers`, so they
start **without a per-server trust prompt** when you open Claude Code here — and
nothing *else* is auto-trusted. (`next-devtools` and `shadcn` are pinned through
this list but float to the latest CLI on launch; the DuckDB server is version-
pinned for reproducibility.)

---

## Environment

Copy `.env.example` → `.env.local` (the `setup.sh` does this for you) and fill in
what you want:

| Var | Used by | Required? |
| --- | --- | --- |
| `DUCKDB_PATH` | `duckdb` MCP | Optional (defaults to `./data/dev.duckdb`) |
| `ANTHROPIC_API_KEY` | the app's AI SDK code (`app/api/chat`) | Only if you build/run AI features |

> `npm run cc` loads `.env.local` for you. If you launch `claude` yourself,
> `export` the vars first — Claude Code expands `${VAR}` in `.mcp.json` from the
> launching shell's environment, not from `.env.local`.

---

## What's in the box

A minimal, idiomatic Next.js 16 app so the MCP servers (and you) have something
real to build on:

- **App Router** scaffold — `app/layout.tsx`, `app/page.tsx`, `app/not-found.tsx`, `app/icon.svg`
- **Tailwind v4 + shadcn/ui** (new-york, OKLCH tokens in `app/globals.css`, `components.json`) with `next-themes` dark mode wired via `components/theme-provider.tsx` and a sample `components/ui/button.tsx`
- **AI SDK 7** example route at `app/api/chat/route.ts` (`streamText` + `@ai-sdk/anthropic`)
- **ESLint** flat config (`eslint.config.mjs`, `next/core-web-vitals` + `next/typescript`) — `npm run lint`
- A committed `package-lock.json`; `setup.sh`/CI use `npm ci` for reproducible installs

---

## Notes & deviations from the original brief

I verified every package/endpoint while building this. A few notes:

- **shadcn MCP** → the working command is `npx shadcn@latest mcp` (the MCP server
  ships inside the `shadcn` CLI). There is no `@shadcn/mcp-server` package on npm.
- **Zod** → covered by a **skill, not an MCP.** No official Zod MCP server exists
  on npm, so a vendored **Zod v4 skill** (`secondsky/claude-skills`) gives Claude
  expert coverage offline.
- **Google GenAI / Developer Knowledge MCP** → **removed for now.** To add it
  back, restore a `google-docs` SSE block in `.mcp.json`
  (`https://developerknowledge.googleapis.com/mcp`, header
  `X-Goog-Api-Key: ${GOOGLE_API_KEY}`), add it to `enabledMcpjsonServers`, and set
  `GOOGLE_API_KEY` in `.env.local`.

---

## Security note

`enabledMcpjsonServers` in `.claude/settings.json` auto-starts exactly the three
named MCP servers with your local permissions when you open this workspace —
that's the frictionless wiring. It does **not** bless any server you add later.
Still: **only open a workspace in Claude Code if you trust its contents.** To
approve servers interactively instead, delete that key from
`.claude/settings.json`.

---

## Layout

```
.
├── .mcp.json                  # MCP server definitions (project scope)
├── .claude/
│   ├── settings.json          # allow-lists the project MCP servers
│   └── skills/                # vendored skills (ai-sdk, migrate…, shadcn, zod)
├── .github/workflows/ci.yml   # lint + build on push/PR
├── CLAUDE.md                  # in-repo guide Claude reads on entry
├── setup.sh                   # one-shot bootstrap (uv + deps + data/ + .env.local)
├── scripts/cc.sh              # `npm run cc` launcher (loads .env.local safely)
├── components.json            # shadcn config (new-york, Tailwind v4, OKLCH)
├── eslint.config.mjs          # ESLint flat config (next/core-web-vitals)
├── app/                       # Next 16 app: layout · page · not-found · icon · api/chat
├── components/                # theme-provider + ui/ (shadcn components)
├── lib/utils.ts               # cn() helper
└── data/                      # local DuckDB files live here (gitignored)
```

---

## Credits

Vendored Agent Skills retain their upstream licenses (see [`LICENSE`](./LICENSE)):
`vercel/ai` (Apache-2.0), `shadcn/ui` (MIT), `secondsky/claude-skills` (MIT).
This repo is MIT-licensed.
