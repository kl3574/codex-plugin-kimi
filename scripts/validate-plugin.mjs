#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const manifestPath = path.join(root, "kimi.plugin.json");
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));

const errors = [];
if (manifest.name !== "codex-plugin-kimi") errors.push("manifest name must be codex-plugin-kimi");
for (const key of ["skills", "commands"]) {
  const value = manifest[key];
  if (!value || !String(value).startsWith("./")) errors.push(`${key} must be a ./ path`);
  else if (!fs.existsSync(path.join(root, value))) errors.push(`${key} path missing: ${value}`);
}
for (const command of ["setup", "doctor", "review", "adversarial-review", "elite-review", "deep-review", "security-review", "folder", "status", "result", "cancel"]) {
  const file = path.join(root, "commands", `${command}.md`);
  if (!fs.existsSync(file)) errors.push(`missing command ${command}`);
}
for (const skill of ["using-codex-plugin-kimi", "codex-kimi-review", "codex-kimi-setup", "codex-kimi-jobs"]) {
  const file = path.join(root, "skills", skill, "SKILL.md");
  if (!fs.existsSync(file)) errors.push(`missing skill ${skill}`);
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}
console.log("plugin validation ok");
