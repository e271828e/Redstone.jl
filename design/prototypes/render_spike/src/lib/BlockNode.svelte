<script lang="ts">
  import { Handle, Position, type NodeProps } from "@xyflow/svelte";
  import type { Block } from "./descriptor";
  import type { Box } from "./layout";
  import { portId } from "./layout";
  import { fill, stroke } from "./style";

  let { data }: NodeProps & { data: { block: Block; box: Box } } = $props();
  const b = $derived(data.block), box = $derived(data.box);
  const boundary = $derived(b.role === "in" || b.role === "out");
</script>

<div
  class="block" class:boundary class:assembly={b.role === "assembly"}
  style="width:{box.w}px;height:{box.h}px;background:{fill(b)};border-color:{stroke(b)}"
>
  {#if boundary}
    <div class="name center">{b.label}</div>
  {:else}
    <div class="name">{b.label}</div>
    <div class="type">{b.typeLabel}</div>
    {#each box.inPorts as p (p.name)}
      <span class="plabel" style="top:{p.y - 7}px;left:6px">{p.name}</span>
    {/each}
    {#each box.outPorts as p (p.name)}
      <span class="plabel" style="top:{p.y - 7}px;right:6px">{p.name}</span>
    {/each}
  {/if}
  {#each box.inPorts as p (p.name)}
    <Handle type="target" position={Position.Left} id={portId(b.id, "in", p.name)} style="top:{p.y}px" isConnectable={false} />
  {/each}
  {#each box.outPorts as p (p.name)}
    <Handle type="source" position={Position.Right} id={portId(b.id, "out", p.name)} style="top:{p.y}px" isConnectable={false} />
  {/each}
</div>

<style>
  .block { position: relative; box-sizing: border-box; border: 1px solid; border-radius: 3px; font: 12px system-ui, sans-serif; }
  .assembly { border-width: 2.5px; }
  .boundary { border-radius: 11px; }
  .name { font-weight: 600; padding: 3px 7px 0; white-space: nowrap; }
  .center { text-align: center; padding-top: 3px; font-weight: 400; }
  .type { font-size: 11px; color: #555; padding: 0 7px; white-space: nowrap; }
  .plabel { position: absolute; font-size: 11px; line-height: 14px; white-space: nowrap; }
  :global(.svelte-flow__handle) { width: 6px; height: 6px; min-width: 0; min-height: 0; border-radius: 0; background: #333; border: none; }
</style>
