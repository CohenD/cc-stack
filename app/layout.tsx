import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "cc-stack",
  description:
    "Pre-wired Claude Code workspace: Next.js 16 + AI SDK 7 + shadcn/ui + Tailwind v4 + DuckDB.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-background text-foreground antialiased">
        {children}
      </body>
    </html>
  );
}
