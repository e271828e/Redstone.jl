<script lang="ts">
  import { untrack } from "svelte";
  import { SvelteFlow, MarkerType, type Node, type Edge } from "@xyflow/svelte";
  import type { Level } from "./descriptor";
  import { type Geometry, portId } from "./layout";
  import BlockNode from "./BlockNode.svelte";
  import ElkEdge from "./ElkEdge.svelte";

  let { level, geometry }: { level: Level; geometry: Geometry } = $props();

  const nodeTypes = { block: BlockNode };
  const edgeTypes = { elk: ElkEdge };

  // Mounted once per page load, so the props are read once.
  const { level: lv, geometry: g } = untrack(() => ({ level, geometry }));
  let nodes = $state.raw<Node[]>(lv.blocks.map((b) => {
    const box = g.boxes[b.id];
    return { id: b.id, type: "block", position: { x: box.x, y: box.y }, width: box.w, height: box.h, data: { block: b, box } };
  }));
  let edges = $state.raw<Edge[]>(lv.wires.map((w) => ({
    id: w.id, type: "elk", source: w.from.block, target: w.to.block,
    sourceHandle: portId(w.from.block, "out", w.from.port), targetHandle: portId(w.to.block, "in", w.to.port),
    data: { points: g.routes[w.id] }, markerEnd: { type: MarkerType.ArrowClosed, width: 14, height: 14, color: "#444" },
  })));
</script>

<div class="flow" data-canvas="flow">
  <SvelteFlow
    bind:nodes bind:edges {nodeTypes} {edgeTypes} fitView minZoom={0.05}
    nodesConnectable={false} elementsSelectable={true}
    onnodeclick={({ node }) => console.log((node.data as { block: { node?: unknown } }).block.node ?? node.id)}
  />
</div>

<style>
  .flow { width: 100%; height: 100%; }
</style>
