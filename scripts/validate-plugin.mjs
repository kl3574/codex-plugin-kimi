#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const manifestPath = path.join(root, ".codex-plugin", "plugin.json");
const marketplaceName = "kimi-review";
const errors = [];

function exists(rel) {
  return fs.existsSync(path.join(root, rel));
}

function isExecutable(rel) {
  try {
    return Boolean(fs.statSync(path.join(root, rel)).mode & 0o111);
  } catch {
    return false;
  }
}

function readIfExists(rel) {
  const full = path.join(root, rel);
  return fs.existsSync(full) ? fs.readFileSync(full, "utf8") : "";
}

if (!exists(".codex-plugin/plugin.json")) errors.push("missing .codex-plugin/plugin.json");
if (!exists(".agents/plugins/marketplace.json")) errors.push("missing local marketplace file");
if (exists("kimi.plugin.json")) errors.push("active Codex plugin must not contain kimi.plugin.json");

let manifest = null;
try {
  manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
} catch (error) {
  errors.push(`manifest JSON failed to parse: ${error.message}`);
}

if (manifest) {
  if (manifest.name !== "codex-plugin-kimi") errors.push("manifest name must be codex-plugin-kimi");
  if (!/^\d+\.\d+\.\d+/.test(manifest.version ?? "")) errors.push("manifest version must be semver-like");
  if (manifest.skills && !String(manifest.skills).startsWith("./")) errors.push("manifest skills path must start with ./");
  if (!manifest.interface?.displayName) errors.push("manifest interface.displayName is required");
}

try {
  const marketplace = JSON.parse(fs.readFileSync(path.join(root, ".agents", "plugins", "marketplace.json"), "utf8"));
  const plugin = marketplace.plugins?.find((item) => item.name === "codex-plugin-kimi");
  if (marketplace.name !== marketplaceName) errors.push(`marketplace name must be ${marketplaceName}`);
  if (!plugin) errors.push("marketplace must list codex-plugin-kimi");
  if (plugin?.source?.source !== "local" || plugin?.source?.path !== "./") errors.push("marketplace source must be local ./");
} catch (error) {
  errors.push(`marketplace JSON failed to parse: ${error.message}`);
}

for (const command of ["setup", "doctor", "install-bin", "enable", "review", "adversarial-review", "elite-review", "deep-review", "security-review", "folder", "status", "result", "cancel"]) {
  if (!exists(`commands/${command}.md`)) errors.push(`missing command ${command}`);
}

for (const skill of ["using-codex-plugin-kimi", "codex-kimi-review", "codex-kimi-setup", "codex-kimi-jobs"]) {
  if (!exists(`skills/${skill}/SKILL.md`)) errors.push(`missing skill ${skill}`);
}

if (!exists("scripts/codex-kimi-review.mjs")) errors.push("missing helper script");
else if (!isExecutable("scripts/codex-kimi-review.mjs")) errors.push("helper script must be executable for package.json bin/PATH alias use");

const docsToCheck = [
  "README.md",
  ...fs.readdirSync(path.join(root, "commands")).map((file) => `commands/${file}`),
  ...fs.readdirSync(path.join(root, "skills")).map((dir) => `skills/${dir}/SKILL.md`)
];
for (const rel of docsToCheck) {
  if (readIfExists(rel).includes("/home/lkx/codex-plugin-kimi/scripts/codex-kimi-review.mjs")) {
    errors.push(`${rel} must not hardcode the local checkout helper path`);
  }
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}

console.log("plugin validation ok");
