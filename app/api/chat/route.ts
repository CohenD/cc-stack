import { anthropic } from "@ai-sdk/anthropic";
import { convertToModelMessages, streamText, type UIMessage } from "ai";

// Allow streaming responses up to 30 seconds.
export const maxDuration = 30;

// Minimal AI SDK v7 chat endpoint. Pair with `useChat` from "@ai-sdk/react" on
// the client. Requires ANTHROPIC_API_KEY in the environment (see .env.example).
export async function POST(req: Request) {
  const { messages }: { messages: UIMessage[] } = await req.json();

  const result = streamText({
    // Swap to "claude-sonnet-4-6" or "claude-haiku-4-5" to trade capability for cost/speed.
    model: anthropic("claude-opus-4-8"),
    messages: await convertToModelMessages(messages),
  });

  return result.toUIMessageStreamResponse();
}
