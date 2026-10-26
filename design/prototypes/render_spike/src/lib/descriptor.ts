// The descriptor's shape, written by hand from schema.json (axis 7 will
// generate it), and the one-level view the canvas draws.

export interface KindMarker { kind: string; values?: string[]; shape?: number[]; element?: KindMarker; fields?: string[] }
export interface LeafFace { name: string; type: string; kind: KindMarker; pinned: boolean }
export interface AssemblyFace { name: string }
export interface Endpoint { path: string; port: string }
export interface Wire { from: Endpoint; to: Endpoint }
export interface Timing { anchor: number; m: number; c: number }
interface NodeBase {
  path: string; field?: string; key?: string; type: string; signature: string;
  parameters: { name: string; value: string }[];
}
export interface LeafNode extends NodeBase {
  class: "leaf"; tier: "continuous" | "discrete"; timing: Timing; inputs: LeafFace[]; outputs: LeafFace[];
}
export interface AssemblyNode extends NodeBase {
  class: "assembly"; inputs: AssemblyFace[]; outputs: AssemblyFace[]; wires: Wire[];
}
export type DNode = LeafNode | AssemblyNode;
export interface Structure { nodes: DNode[]; root_inputs: LeafFace[]; anchors: unknown[]; scopes: unknown[]; types: unknown[] }
export interface BuildBody { structure: Structure; outputs: unknown }
export interface Descriptor {
  format_version: { major: number; minor: number }; redstone_version: string;
  kind: "build" | "deployment"; build?: BuildBody; deployment?: { build: BuildBody };
}

/** A box on the canvas: a child node, or a boundary face of the level. */
export interface Block {
  id: string;
  role: "leaf" | "assembly" | "in" | "out";
  label: string;
  typeLabel: string;
  tier?: "continuous" | "discrete";
  inputs: string[];
  outputs: string[];
  node?: DNode;
}
export interface LevelWire { id: string; from: { block: string; port: string }; to: { block: string; port: string } }
export interface Level { path: string; blocks: Block[]; wires: LevelWire[] }

export const structureOf = (d: Descriptor): Structure => (d.build ?? d.deployment!.build).structure;

/** The parent rule: the longest node path that is a proper prefix, segment-aligned. */
export function parentOf(path: string, paths: Set<string>): string | undefined {
  if (path === "") return undefined;
  let p = path;
  for (let i = p.lastIndexOf("/"); i >= 0; i = p.lastIndexOf("/")) {
    p = p.slice(0, i);
    if (paths.has(p)) return p;
  }
  return "";
}

export const assemblies = (d: Descriptor): AssemblyNode[] =>
  structureOf(d).nodes.filter((n): n is AssemblyNode => n.class === "assembly");

const IN = "⟨in⟩", OUT = "⟨out⟩";

/** One level: the assembly's children in walk order, its boundary faces, its wires. */
export function levelOf(d: Descriptor, path: string): Level {
  const nodes = structureOf(d).nodes;
  const paths = new Set(nodes.map((n) => n.path));
  const self = nodes.find((n) => n.path === path);
  if (!self || self.class !== "assembly") throw new Error(`no assembly at "${path}"`);
  const blocks: Block[] = [];
  for (const f of self.inputs) blocks.push({ id: IN + f.name, role: "in", label: f.name, typeLabel: "", inputs: [], outputs: [f.name] });
  for (const n of nodes) {
    if (parentOf(n.path, paths) !== path) continue;
    blocks.push({
      id: n.path, role: n.class, node: n,
      label: path === "" ? n.path : n.path.slice(path.length + 1),
      typeLabel: n.type.slice(n.type.lastIndexOf(".") + 1),
      tier: n.class === "leaf" ? n.tier : undefined,
      inputs: n.inputs.map((f) => f.name), outputs: n.outputs.map((f) => f.name),
    });
  }
  for (const f of self.outputs) blocks.push({ id: OUT + f.name, role: "out", label: f.name, typeLabel: "", inputs: [f.name], outputs: [] });
  const wires = self.wires.map((w, i): LevelWire => ({
    id: `w${i}`,
    from: { block: w.from.path === path ? IN + w.from.port : w.from.path, port: w.from.port },
    to: { block: w.to.path === path ? OUT + w.to.port : w.to.path, port: w.to.port },
  }));
  return { path, blocks, wires };
}
