#!/usr/bin/env node
// scripts/seed-mcps.js
// Usage:
// ADMIN_API_URL="http://localhost:12008/api/admin/mcp-servers" \
// ADMIN_API_TOKEN="sk_mt_xxx" \
// SEED_FILE="examples/seeds/mcps.json" \
// node scripts/seed-mcps.js

import fs from "fs";
import path from "path";
import process from "process";

const adminUrl = process.env.ADMIN_API_URL;
const token = process.env.ADMIN_API_TOKEN;
const seedFile = process.env.SEED_FILE || path.resolve("examples", "seeds", "mcps.json");
const RETRIES = Number(process.env.SEED_RETRIES || 5);
const RETRY_DELAY_MS = Number(process.env.SEED_RETRY_DELAY_MS || 2000);

if (!adminUrl) {
  console.error("ERROR: ADMIN_API_URL env var is required.");
  process.exit(2);
}
if (!token) {
  console.error("ERROR: ADMIN_API_TOKEN env var is required.");
  process.exit(2);
}
if (!fs.existsSync(seedFile)) {
  console.error("ERROR: seed file not found:", seedFile);
  process.exit(2);
}

const body = JSON.parse(fs.readFileSync(seedFile, "utf-8"));

async function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function postOne(mcp) {
  for (let attempt = 1; attempt <= RETRIES; attempt++) {
    try {
      const res = await fetch(adminUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify(mcp)
      });
      if (res.ok) {
        const data = await res.json().catch(() => null);
        console.log("Created/ok:", mcp.name, res.status, data ?? "");
        return;
      } else if (res.status === 409) {
        console.log("Already exists (409):", mcp.name);
        return;
      } else {
        const text = await res.text();
        throw new Error(`status ${res.status}: ${text}`);
      }
    } catch (err) {
      console.error(`Attempt ${attempt} failed for ${mcp.name}:`, err.message ?? err);
      if (attempt < RETRIES) {
        await sleep(RETRY_DELAY_MS);
      } else {
        throw err;
      }
    }
  }
}

(async () => {
  for (const mcp of body) {
    try {
      await postOne(mcp);
    } catch (err) {
      console.error("Failed to seed:", mcp.name, err.message ?? err);
    }
  }
  console.log("Done seeding.");
})();
