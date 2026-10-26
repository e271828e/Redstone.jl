<script lang="ts">
  import { untrack } from "svelte";
  import type { Level } from "./descriptor";
  import { type Geometry, pathD, rerouteTouching, FONT, BOLD, SMALL } from "./layout";
  import { fill, stroke } from "./style";

  let { level, geometry }: { level: Level; geometry: Geometry } = $props();
  // Mounted once per page load; the geometry is the canvas's own from here, drags included.
  let g = $state(untrack(() => geometry));

  let drag: { id: string; x0: number; y0: number; bx: number; by: number; moved: boolean } | null = null;

  function down(e: PointerEvent, id: string) {
    const box = g.boxes[id];
    drag = { id, x0: e.clientX, y0: e.clientY, bx: box.x, by: box.y, moved: false };
    (e.currentTarget as Element).setPointerCapture(e.pointerId);
  }
  function move(e: PointerEvent) {
    if (!drag) return;
    const dx = e.clientX - drag.x0, dy = e.clientY - drag.y0;
    if (!drag.moved && Math.hypot(dx, dy) < 3) return;
    drag.moved = true;
    g.boxes[drag.id].x = drag.bx + dx;
    g.boxes[drag.id].y = drag.by + dy;
    rerouteTouching(g, level, drag.id);
  }
  function up(id: string) {
    if (drag && !drag.moved) console.log(level.blocks.find((b) => b.id === id)?.node ?? id);
    drag = null;
  }
</script>

<div class="scroll">
  <svg width={g.width + 200} height={g.height + 200} data-canvas="svg">
    <defs>
      <marker id="arrow" viewBox="0 0 8 8" refX="8" refY="4" markerWidth="7" markerHeight="7" orient="auto">
        <path d="M0,0 L8,4 L0,8 z" fill="#444" />
      </marker>
    </defs>
    {#each level.wires as w (w.id)}
      {#if g.routes[w.id]}
        <path class="wire" data-wire={w.id} d={pathD(g.routes[w.id])} marker-end="url(#arrow)" />
      {/if}
    {/each}
    {#each level.blocks as b (b.id)}
      {@const box = g.boxes[b.id]}
      <g
        class="block" data-id={b.id} transform="translate({box.x},{box.y})" role="button" tabindex="-1"
        onpointerdown={(e) => down(e, b.id)} onpointermove={move} onpointerup={() => up(b.id)}
      >
        <rect width={box.w} height={box.h} rx={b.role === "in" || b.role === "out" ? 11 : 3}
              fill={fill(b)} stroke={stroke(b)} stroke-width={b.role === "assembly" ? 2.5 : 1} />
        {#if b.role === "in" || b.role === "out"}
          <text x={box.w / 2} y={15} text-anchor="middle" style="font:{FONT}">{b.label}</text>
        {:else}
          <text x={8} y={15} style="font:{BOLD}">{b.label}</text>
          <text x={8} y={29} style="font:{SMALL}" fill="#555">{b.typeLabel}</text>
          {#each box.inPorts as p (p.name)}
            <rect x={-3} y={p.y - 3} width="6" height="6" fill="#333" />
            <text x={6} y={p.y + 4} style="font:{SMALL}">{p.name}</text>
          {/each}
          {#each box.outPorts as p (p.name)}
            <rect x={box.w - 3} y={p.y - 3} width="6" height="6" fill="#333" />
            <text x={box.w - 6} y={p.y + 4} text-anchor="end" style="font:{SMALL}">{p.name}</text>
          {/each}
        {/if}
      </g>
    {/each}
  </svg>
</div>

<style>
  .scroll { overflow: auto; width: 100%; height: 100%; }
  .wire { fill: none; stroke: #444; stroke-width: 1; }
  .block { cursor: grab; }
  text { user-select: none; pointer-events: none; }
</style>
