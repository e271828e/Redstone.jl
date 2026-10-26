// One ELK layout module under both canvases: sizes, ports at fixed positions,
// layered left to right with orthogonal routing, and declaration order as the
// tie-break. Also the local router that re-routes a dragged block's wires.
import ELK from "elkjs/lib/elk.bundled.js";
import type { ElkNode, ElkExtendedEdge } from "elkjs/lib/elk-api";
import type { Block, Level } from "./descriptor";

export interface Point { x: number; y: number }
export interface Port { name: string; side: "in" | "out"; x: number; y: number }  // relative to the block
export interface Box { x: number; y: number; w: number; h: number; inPorts: Port[]; outPorts: Port[] }
export interface Geometry { boxes: Record<string, Box>; routes: Record<string, Point[]>; width: number; height: number }

export const FONT = "12px system-ui, sans-serif";
export const BOLD = "600 12px system-ui, sans-serif";
export const SMALL = "11px system-ui, sans-serif";
const HEADER = 36, ROW = 16, PAD = 8;

let ctx: CanvasRenderingContext2D | null = null;
function textWidth(s: string, font: string): number {
  ctx ??= document.createElement("canvas").getContext("2d");
  if (!ctx) return s.length * 7;
  ctx.font = font;
  return ctx.measureText(s).width;
}

export const portId = (block: string, side: "in" | "out", name: string) => `${block}|${side}|${name}`;

/** The block's size and port positions, from its label, type label and face names. */
export function sizeBlock(b: Block): Box {
  if (b.role === "in" || b.role === "out") {
    const w = Math.ceil(textWidth(b.label, FONT)) + 2 * PAD, h = 22;
    const p: Port = { name: b.label, side: b.role === "in" ? "out" : "in", x: b.role === "in" ? w : 0, y: h / 2 };
    return { x: 0, y: 0, w, h, inPorts: b.role === "out" ? [p] : [], outPorts: b.role === "in" ? [p] : [] };
  }
  const head = Math.max(textWidth(b.label, BOLD), textWidth(b.typeLabel, SMALL));
  const wi = Math.max(0, ...b.inputs.map((n) => textWidth(n, SMALL)));
  const wo = Math.max(0, ...b.outputs.map((n) => textWidth(n, SMALL)));
  const w = Math.ceil(Math.max(60, head + 2 * PAD, wi + wo + 3 * PAD + 8));
  const rows = Math.max(b.inputs.length, b.outputs.length, 1);
  const h = HEADER + rows * ROW;
  const row = (i: number) => HEADER + i * ROW + ROW / 2;
  return {
    x: 0, y: 0, w, h,
    inPorts: b.inputs.map((name, i) => ({ name, side: "in", x: 0, y: row(i) })),
    outPorts: b.outputs.map((name, i) => ({ name, side: "out", x: w, y: row(i) })),
  };
}

const ROOT_OPTIONS = {
  "elk.algorithm": "layered",
  "elk.direction": "RIGHT",
  "elk.edgeRouting": "ORTHOGONAL",
  "elk.layered.considerModelOrder.strategy": "NODES_AND_EDGES",
  "elk.layered.cycleBreaking.strategy": "MODEL_ORDER",
  "elk.spacing.nodeNode": "24",
  "elk.layered.spacing.nodeNodeBetweenLayers": "40",
  "elk.layered.spacing.edgeNodeBetweenLayers": "14",
  "elk.spacing.edgeEdge": "6",
  "elk.padding": "[top=20,left=20,bottom=20,right=20]",
};

export function elkGraph(level: Level, boxes: Record<string, Box>): ElkNode {
  const children: ElkNode[] = level.blocks.map((b) => {
    const box = boxes[b.id];
    const layer: Record<string, string> = b.role === "in" ? { "elk.layered.layering.layerConstraint": "FIRST_SEPARATE" }
      : b.role === "out" ? { "elk.layered.layering.layerConstraint": "LAST_SEPARATE" } : {};
    return {
      id: b.id, width: box.w, height: box.h,
      layoutOptions: { "elk.portConstraints": "FIXED_POS", ...layer },
      ports: [...box.inPorts, ...box.outPorts].map((p) => ({
        id: portId(b.id, p.side, p.name), x: p.x, y: p.y, width: 0, height: 0,
        layoutOptions: { "elk.port.side": p.side === "in" ? "WEST" : "EAST" },
      })),
    };
  });
  const edges: ElkExtendedEdge[] = level.wires.map((w) => ({
    id: w.id, sources: [portId(w.from.block, "out", w.from.port)], targets: [portId(w.to.block, "in", w.to.port)],
  }));
  return { id: "level", layoutOptions: ROOT_OPTIONS, children, edges };
}

const elk = new ELK();

/** Lays out one level; `ms` is ELK's own time, sizing excluded. */
export async function layoutLevel(level: Level): Promise<{ geometry: Geometry; ms: number; sizeMs: number }> {
  const t0 = performance.now();
  const boxes: Record<string, Box> = {};
  for (const b of level.blocks) boxes[b.id] = sizeBlock(b);
  const graph = elkGraph(level, boxes);
  const t1 = performance.now();
  const out = await elk.layout(graph);
  const t2 = performance.now();
  for (const c of out.children ?? []) { boxes[c.id].x = c.x ?? 0; boxes[c.id].y = c.y ?? 0; }
  const routes: Record<string, Point[]> = {};
  for (const e of (out.edges ?? []) as ElkExtendedEdge[]) {
    const s = e.sections?.[0];
    if (s) routes[e.id] = [s.startPoint, ...(s.bendPoints ?? []), s.endPoint].map(({ x, y }) => ({ x, y }));
  }
  return { geometry: { boxes, routes, width: out.width ?? 0, height: out.height ?? 0 }, ms: t2 - t1, sizeMs: t1 - t0 };
}

export function portPoint(g: Geometry, block: string, side: "in" | "out", name: string): Point {
  const b = g.boxes[block];
  const p = (side === "in" ? b.inPorts : b.outPorts).find((q) => q.name === name)!;
  return { x: b.x + p.x, y: b.y + p.y };
}

/** A right-angle route from an east port to a west port, below both boxes when it runs backward. */
export function orthoRoute(a: Point, b: Point, below = Math.max(a.y, b.y)): Point[] {
  const stub = 12;
  if (b.x - a.x >= 2 * stub) {
    const mx = Math.round((a.x + b.x) / 2);
    return [a, { x: mx, y: a.y }, { x: mx, y: b.y }, b];
  }
  const y = below + stub;
  return [a, { x: a.x + stub, y: a.y }, { x: a.x + stub, y }, { x: b.x - stub, y }, { x: b.x - stub, y: b.y }, b];
}

/** Re-routes every wire touching `block` after a drag, leaving ELK's routes elsewhere. */
export function rerouteTouching(g: Geometry, level: Level, block: string): void {
  for (const w of level.wires) {
    if (w.from.block !== block && w.to.block !== block) continue;
    const a = portPoint(g, w.from.block, "out", w.from.port), b = portPoint(g, w.to.block, "in", w.to.port);
    const fa = g.boxes[w.from.block], fb = g.boxes[w.to.block];
    g.routes[w.id] = orthoRoute(a, b, Math.max(fa.y + fa.h, fb.y + fb.h));
  }
}

export const pathD = (pts: Point[]) => pts.map((p, i) => `${i ? "L" : "M"}${p.x},${p.y}`).join(" ");
