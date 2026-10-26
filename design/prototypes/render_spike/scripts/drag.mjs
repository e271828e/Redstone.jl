// Drags one block in each canvas and checks that exactly its wires re-route,
// recording frame times during the drag. Usage: npm run build && node scripts/drag.mjs
import { spawn } from "node:child_process";
import { chromium } from "playwright";

const PORT = 4320;
const here = new URL("..", import.meta.url).pathname;
const server = spawn("npx", ["vite", "preview", "--port", String(PORT), "--strictPort"], { cwd: here, stdio: "ignore" });
for (let i = 0; ; i++) {
  try { await fetch(`http://localhost:${PORT}/`); break; } catch { if (i > 100) throw new Error("no server"); await new Promise((r) => setTimeout(r, 100)); }
}
const browser = await chromium.launch({ channel: "chrome", headless: true });
const cases = [["closed_loop", "plant"], ["synthetic_150", "b050"]];
try {
  for (const [fixture, block] of cases) {
    for (const canvas of ["svg", "flow"]) {
      const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
      const logs = [];
      page.on("console", (m) => logs.push(m.text()));
      await page.goto(`http://localhost:${PORT}/?fixture=${fixture}&canvas=${canvas}`);
      await page.waitForFunction(() => window.__spike);
      await page.waitForTimeout(300);
      const sel = canvas === "svg" ? `g.block[data-id="${block}"]` : `.svelte-flow__node[data-id="${block}"]`;
      const wireSel = canvas === "svg" ? "path.wire" : ".svelte-flow__edge path.svelte-flow__edge-path";
      const routes = () => page.$$eval(wireSel, (ps) => ps.map((p) => p.getAttribute("d")));
      const before = await routes();
      const el = await page.$(sel);
      await el.scrollIntoViewIfNeeded();
      const box = await el.boundingBox();
      // a click logs the node
      await page.mouse.click(box.x + box.width / 2, box.y + 8);
      await page.evaluate(() => { window.__frames = []; let last = performance.now();
        const loop = (t) => { window.__frames.push(t - last); last = t; if (!window.__stop) requestAnimationFrame(loop); };
        requestAnimationFrame(loop); });
      await page.mouse.move(box.x + box.width / 2, box.y + 8);
      await page.mouse.down();
      await page.mouse.move(box.x + box.width / 2 + 160, box.y + 8 + 220, { steps: 40 });
      await page.mouse.up();
      await page.waitForTimeout(200);
      const frames = await page.evaluate(() => { window.__stop = true; return window.__frames.slice(1); });
      const after = await routes();
      const changed = after.filter((d, i) => d !== before[i]).length;
      await page.screenshot({ path: new URL(`../screenshots/${fixture}_${canvas}_dragged.png`, import.meta.url).pathname });
      const mean = frames.reduce((a, b) => a + b, 0) / frames.length;
      console.log(JSON.stringify({ fixture, canvas, block, wiresRerouted: changed, wiresTotal: after.length,
        frames: frames.length, meanFrameMs: +mean.toFixed(1), maxFrameMs: +Math.max(...frames).toFixed(1),
        clickLogged: logs.some((l) => l.includes("Object") || l.includes(block)) }));
      await page.close();
    }
  }
} finally { await browser.close(); server.kill(); }
