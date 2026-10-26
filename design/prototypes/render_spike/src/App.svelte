<script lang="ts">
  import { tick, type Component } from "svelte";
  import { type Descriptor, type Level, assemblies, levelOf } from "./lib/descriptor";
  import { type Geometry, layoutLevel } from "./lib/layout";

  const fixtures = import.meta.glob<Descriptor>("../fixtures/*.json", { import: "default" });
  const names = Object.keys(fixtures).map((k) => k.replace(/^.*\/(.*)\.json$/, "$1")).sort();

  const q = new URLSearchParams(location.search);
  const fixture = q.get("fixture") ?? "closed_loop";
  const canvas = q.get("canvas") === "flow" ? "flow" : "svg";
  const levelPath = q.get("level") ?? "";
  const warm = Number(q.get("warm") ?? 0);   // extra layouts after the first, for warm timings

  let descriptor = $state.raw<Descriptor | null>(null);
  let level = $state.raw<Level | null>(null);
  let geometry = $state.raw<Geometry | null>(null);
  let status = $state("loading");
  let Canvas = $state.raw<Component<{ level: Level; geometry: Geometry }> | null>(null);

  const frame = () => new Promise<void>((r) => requestAnimationFrame(() => setTimeout(r, 0)));

  async function rendered(expectedWires: number) {
    // Svelte Flow draws edges only once it has measured the handles.
    for (let i = 0; i < 600; i++) {
      await frame();
      const root = document.querySelector("[data-canvas]");
      const drawn = canvas === "flow" ? root?.querySelectorAll(".svelte-flow__edge path.svelte-flow__edge-path").length
                                      : root?.querySelectorAll("path.wire").length;
      if ((drawn ?? 0) >= expectedWires) return;
    }
    throw new Error("wires never drew");
  }

  async function run() {
    // Each canvas is its own chunk, so the build reports what each one weighs.
    const [d, mod] = await Promise.all([fixtures[`../fixtures/${fixture}.json`](),
      canvas === "flow" ? import("./lib/FlowCanvas.svelte") : import("./lib/SvgCanvas.svelte")]);
    Canvas = mod.default;
    descriptor = d;
    const lv = levelOf(d, levelPath);
    const first = await layoutLevel(lv);
    const warmMs: number[] = [];
    for (let i = 0; i < warm; i++) warmMs.push((await layoutLevel(lv)).ms);
    const t0 = performance.now();
    level = lv; geometry = first.geometry;
    await tick();
    const domMs = performance.now() - t0;          // the canvas's DOM built, before any frame
    await rendered(lv.wires.length);
    const renderMs = performance.now() - t0;       // every wire drawn, one frame after

    const result = { fixture, canvas, level: levelPath, blocks: lv.blocks.length, wires: lv.wires.length,
                     layoutMs: first.ms, sizeMs: first.sizeMs, warmLayoutMs: warmMs, domMs, renderMs };
    (window as unknown as { __spike: unknown }).__spike = result;
    status = `${lv.blocks.length} blocks, ${lv.wires.length} wires · ELK ${first.ms.toFixed(1)} ms · first render ${renderMs.toFixed(1)} ms`;
  }
  run().catch((e) => { status = String(e); (window as unknown as { __spike: unknown }).__spike = { error: String(e) }; });

  const go = (k: string, v: string) => { const p = new URLSearchParams(location.search); p.set(k, v); if (k === "fixture") p.delete("level"); location.search = p.toString(); };
</script>

<header>
  <label>fixture
    <select value={fixture} onchange={(e) => go("fixture", e.currentTarget.value)}>
      {#each names as n (n)}<option value={n}>{n}</option>{/each}
    </select>
  </label>
  <label>canvas
    <select value={canvas} onchange={(e) => go("canvas", e.currentTarget.value)}>
      <option value="svg">hand-rolled SVG</option><option value="flow">Svelte Flow</option>
    </select>
  </label>
  {#if descriptor}
    <label>level
      <select value={levelPath} onchange={(e) => go("level", e.currentTarget.value)}>
        {#each assemblies(descriptor) as a (a.path)}<option value={a.path}>{a.path === "" ? "(root)" : a.path}</option>{/each}
      </select>
    </label>
  {/if}
  <span class="status">{status}</span>
</header>
<main>
  {#if level && geometry && Canvas}
    <Canvas {level} {geometry} />
  {/if}
</main>

<style>
  :global(html, body, #app) { margin: 0; height: 100%; font: 13px system-ui, sans-serif; background: #fafafa; color: #222; }
  :global(#app) { display: flex; flex-direction: column; }
  header { display: flex; gap: 16px; align-items: center; padding: 6px 12px; border-bottom: 1px solid #ddd; background: #fff; flex-wrap: wrap; }
  .status { color: #555; }
  main { flex: 1; min-height: 0; }
</style>
