// Measures ELK layout and first render per canvas and fixture in Chrome,
// over the production build served by `vite preview`. Five fresh page loads
// per cell; each load lays out once cold, then five times warm.
// Usage: npm run build && npm run measure
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { chromium } from "playwright";

const PORT = 4318, LOADS = 5, WARM = 5;
const here = new URL("..", import.meta.url).pathname;
const server = spawn("npx", ["vite", "preview", "--port", String(PORT), "--strictPort"], { cwd: here, stdio: "ignore" });
const url = `http://localhost:${PORT}/`;
for (let i = 0; ; i++) {
  try { await fetch(url); break; } catch { if (i > 100) throw new Error("preview server did not start"); await new Promise((r) => setTimeout(r, 100)); }
}

const median = (xs) => { const s = [...xs].sort((a, b) => a - b); return s[Math.floor(s.length / 2)]; };
const browser = await chromium.launch({ channel: "chrome", headless: true });
const version = browser.version();
const ctx = await browser.newContext({ viewport: { width: 1600, height: 1000 } });
mkdirSync(new URL("../screenshots/", import.meta.url), { recursive: true });

const rows = [];
try {
  for (const fixture of ["descent", "closed_loop", "synthetic_150"]) {
    for (const canvas of ["svg", "flow"]) {
      const runs = [];
      for (let k = 0; k < LOADS; k++) {
        const page = await ctx.newPage();
        page.on("pageerror", (e) => console.error(`${fixture}/${canvas}: ${e}`));
        await page.goto(`${url}?fixture=${fixture}&canvas=${canvas}&warm=${WARM}`);
        await page.waitForFunction(() => window.__spike, null, { timeout: 60000 });
        const r = await page.evaluate(() => window.__spike);
        if (r.error) throw new Error(`${fixture}/${canvas}: ${r.error}`);
        runs.push(r);
        if (k === 0) await page.screenshot({ path: new URL(`../screenshots/${fixture}_${canvas}.png`, import.meta.url).pathname });
        await page.close();
      }
      const row = {
        fixture, canvas, blocks: runs[0].blocks, wires: runs[0].wires,
        layoutColdMs: median(runs.map((r) => r.layoutMs)),
        layoutWarmMs: median(runs.flatMap((r) => r.warmLayoutMs)),
        sizeMs: median(runs.map((r) => r.sizeMs)),
        domMs: median(runs.map((r) => r.domMs)),
        renderMs: median(runs.map((r) => r.renderMs)),
        renderMaxMs: Math.max(...runs.map((r) => r.renderMs)),
      };
      rows.push(row);
      console.log(JSON.stringify(row));
    }
  }
} finally {
  await browser.close();
  server.kill();
}
writeFileSync(new URL("../measurements.json", import.meta.url),
  JSON.stringify({ browser: `Chrome ${version} (headless, Playwright)`, loads: LOADS, warm: WARM, rows }, null, 1) + "\n");
