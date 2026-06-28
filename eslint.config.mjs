import next from "eslint-config-next";

// eslint-config-next@16 ships a native ESLint flat config (an array of
// Linter.Config). Spread it directly — no FlatCompat / @eslint/eslintrc needed.
const eslintConfig = [
  {
    ignores: [
      ".next/**",
      "out/**",
      "build/**",
      "node_modules/**",
      "next-env.d.ts",
      ".claude/**", // vendored skills + their reference files are not project source
    ],
  },
  ...next,
];

export default eslintConfig;
