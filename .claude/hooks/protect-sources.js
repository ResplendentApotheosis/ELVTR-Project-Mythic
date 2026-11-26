// Blocks Claude from editing the owner-only folders: docs/ (the GDD and reviews),
// research/ (the research pack) and addons/gut/ (the test framework).
// Runs before every Edit/Write; exit code 2 cancels the edit and shows the message to Claude.
// Check it works: ask Claude to "add a line to docs/README.md". It should be refused.

const path = require("path");

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  let filePath = "";
  try {
    const data = JSON.parse(input);
    const t = data.tool_input || {};
    filePath = t.file_path || t.notebook_path || t.path || "";
  } catch {
    process.exit(0); // unreadable input: don't block
  }
  if (!filePath) process.exit(0);

  const root = process.env.CLAUDE_PROJECT_DIR || process.cwd();
  const rel = path.relative(root, path.resolve(root, filePath)).split(path.sep).join("/");
  const protectedDirs = ["docs/", "research/", "addons/gut/"];
  const hit = protectedDirs.find((d) => rel === d.slice(0, -1) || rel.startsWith(d));

  if (hit) {
    process.stderr.write(
      `Blocked: ${rel} is in ${hit}, which only the owner edits. ` +
        `If the GDD or research pack needs a change, write it to spec/open_questions.md and tell the owner.`
    );
    process.exit(2);
  }
  process.exit(0);
});
