<script lang="ts">
  import { BaseEdge, type EdgeProps } from "@xyflow/svelte";
  import { orthoRoute, pathD, type Point } from "./layout";

  let { id, sourceX, sourceY, targetX, targetY, data, markerEnd }: EdgeProps = $props();

  // ELK's route while both ends sit where ELK put them; a fresh right-angle route once a drag moved one.
  const path = $derived.by(() => {
    const pts = (data as { points: Point[] }).points, a = pts[0], z = pts[pts.length - 1];
    const near = (p: Point, x: number, y: number) => Math.abs(p.x - x) < 6 && Math.abs(p.y - y) < 1.5;
    if (near(a, sourceX, sourceY) && near(z, targetX, targetY))
      return pathD([{ x: sourceX, y: sourceY }, ...pts.slice(1, -1), { x: targetX, y: targetY }]);
    return pathD(orthoRoute({ x: sourceX, y: sourceY }, { x: targetX, y: targetY }));
  });
</script>

<BaseEdge {id} {path} {markerEnd} style="stroke:#444;stroke-width:1" />
