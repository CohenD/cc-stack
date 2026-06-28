import Link from "next/link";

export default function NotFound() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 px-6 text-center">
      <p className="text-sm font-medium tracking-widest text-muted-foreground uppercase">
        404
      </p>
      <h1 className="text-3xl font-semibold tracking-tight">Page not found</h1>
      <p className="max-w-sm text-muted-foreground">
        That page doesn&rsquo;t exist. Check the URL, or head back home.
      </p>
      <Link
        href="/"
        className="mt-2 text-sm font-medium underline underline-offset-4 hover:text-muted-foreground"
      >
        Return home
      </Link>
    </main>
  );
}
