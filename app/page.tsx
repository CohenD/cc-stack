import { Button } from "@/components/ui/button";

const skills = [
  { name: "ai-sdk", desc: "Vercel AI SDK 7 — agents, streaming, tools" },
  { name: "migrate-ai-sdk-v6-to-v7", desc: "AI SDK v6 → v7 upgrades" },
  { name: "shadcn", desc: "Component registry + theming" },
  { name: "zod", desc: "Zod v4 schemas, inference, codecs" },
];

const servers = [
  { name: "next-devtools", desc: "Live Next.js errors, routes, logs + docs gateway" },
  { name: "shadcn", desc: "Search / view / install UI from the registry" },
  { name: "duckdb", desc: "SQL over a local DuckDB file (read-write)" },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-3xl flex-col justify-center gap-12 px-6 py-24">
      <header className="space-y-3">
        <p className="text-sm font-medium tracking-widest text-muted-foreground uppercase">
          Claude Code workspace
        </p>
        <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">
          cc-stack
        </h1>
        <p className="max-w-xl text-lg text-muted-foreground">
          Next.js 16 · AI SDK 7 · shadcn/ui · Tailwind v4 · Zod 4 · DuckDB —
          with Skills and MCP servers wired up on clone.
        </p>
      </header>

      <section className="grid gap-8 sm:grid-cols-2">
        <div className="space-y-4">
          <h2 className="text-sm font-medium tracking-widest text-muted-foreground uppercase">
            Skills
          </h2>
          <ul className="space-y-3">
            {skills.map((s) => (
              <li key={s.name} className="rounded-lg border border-border p-4">
                <p className="font-mono text-sm font-medium">{s.name}</p>
                <p className="mt-1 text-sm text-muted-foreground">{s.desc}</p>
              </li>
            ))}
          </ul>
        </div>

        <div className="space-y-4">
          <h2 className="text-sm font-medium tracking-widest text-muted-foreground uppercase">
            MCP servers
          </h2>
          <ul className="space-y-3">
            {servers.map((s) => (
              <li key={s.name} className="rounded-lg border border-border p-4">
                <p className="font-mono text-sm font-medium">{s.name}</p>
                <p className="mt-1 text-sm text-muted-foreground">{s.desc}</p>
              </li>
            ))}
          </ul>
        </div>
      </section>

      <footer className="flex flex-col items-start gap-4 text-sm text-muted-foreground">
        <p>
          Edit{" "}
          <code className="rounded bg-muted px-1.5 py-0.5 font-mono">
            app/page.tsx
          </code>{" "}
          to get started, or ask Claude to build a feature.
        </p>
        <Button asChild>
          <a href="https://github.com/CohenD/cc-stack">View the repo</a>
        </Button>
      </footer>
    </main>
  );
}
