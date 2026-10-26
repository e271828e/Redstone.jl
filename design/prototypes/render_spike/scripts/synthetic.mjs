// Generates one flat level of 150 blocks and about 300 wires in the schema's
// node shape: 140 leaves and 10 child assemblies of two leaves each, drawn closed.
import { writeFileSync } from "node:fs";

let seed = 20261026;
const rand = () => { seed = (seed + 0x6d2b79f5) | 0; let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
const pick = (n) => Math.floor(rand() * n);

const N = 150, ASSEMBLIES = 10, WIRES = 300;
const F = { kind: "float" };
const face = (name) => ({ name, type: "Float64", kind: F, pinned: false });
const names = (p, n) => Array.from({ length: n }, (_, i) => `${p}${i + 1}`);
const leaf = (path, field, key, tier, nin, nout, anchor) => ({
  path, field, ...(key === undefined ? {} : { key }), class: "leaf", tier,
  timing: { anchor: tier === "discrete" ? anchor : 0, m: 1, c: 0 },
  type: `Synthetic.Block${nin}x${nout}`, signature: `Synthetic.Block${nin}x${nout}{Float64}`,
  inputs: names("in", nin).map(face), outputs: names("out", nout).map(face),
  parameters: [{ name: "gain", value: (rand() * 10).toFixed(3) }],
});
const ep = (path, port) => ({ path, port });

const rootIn = names("u", 4), rootOut = names("y", 2);
const children = [], nested = [], anchors = [];
for (let i = 0; i < N; i++) {
  const name = `b${String(i + 1).padStart(3, "0")}`;
  if (i % 15 === 7 && children.filter((c) => c.class === "assembly").length < ASSEMBLIES) {
    // a child assembly: two leaves in series, one input and one output
    const a = leaf(`${name}/a`, "a", undefined, "continuous", 1, 1, 0);
    const b = leaf(`${name}/b`, "b", undefined, "continuous", 1, 1, 0);
    children.push({ path: name, field: "children", key: name, class: "assembly", type: "Synthetic.Sub",
      signature: "Synthetic.Sub{…}", inputs: [{ name: "in1" }], outputs: [{ name: "out1" }],
      wires: [{ from: ep(a.path, "out1"), to: ep(b.path, "in1") }, { from: ep(name, "in1"), to: ep(a.path, "in1") },
              { from: ep(b.path, "out1"), to: ep(name, "out1") }],
      parameters: [] });
    nested.push([name, [a, b]]);
  } else {
    const discrete = rand() < 0.3;
    if (discrete) anchors.push({ T: { num: 1, den: 50 }, tau: { num: 0, den: 1 }, scope: "", key: name });
    children.push(leaf(name, "children", name, discrete ? "discrete" : "continuous", 1 + pick(4), 1 + pick(3), anchors.length));
  }
}

// Wires: each consumer port takes one producer, mostly from the few blocks
// before it, about a tenth fed back from a later block.
const local = [], inputW = [], outputW = [];
const free = children.flatMap((c, i) => c.inputs.map((f) => [i, f.name]));
for (let k = free.length - 1; k > 0; k--) { const j = pick(k + 1); [free[k], free[j]] = [free[j], free[k]]; }
const targets = free.slice(0, WIRES - rootOut.length).sort((x, y) => x[0] - y[0]);
for (const [i, port] of targets) {
  if (i < 6 && rand() < 0.6) { inputW.push({ from: ep("", rootIn[pick(rootIn.length)]), to: ep(children[i].path, port) }); continue; }
  const back = rand() < 0.1 && i < N - 1;
  let j = back ? i + 1 + pick(Math.min(8, N - i - 1)) : Math.max(0, i - 1 - pick(Math.min(i, 8)));
  if (j === i) j = Math.max(0, i - 1);
  const src = children[j];
  local.push({ from: ep(src.path, src.outputs[pick(src.outputs.length)].name), to: ep(children[i].path, port) });
}
rootOut.forEach((y, k) => { const src = children[N - 1 - k]; outputW.push({ from: ep(src.path, src.outputs[0].name), to: ep("", y) }); });

const rootNode = { path: "", class: "assembly", type: "Synthetic.Big", signature: "Synthetic.Big{…}",
  inputs: rootIn.map((name) => ({ name })), outputs: rootOut.map((name) => ({ name })),
  wires: [...local, ...inputW, ...outputW], parameters: [] };
const nodes = [rootNode];
for (const c of children) { nodes.push(c); const n = nested.find(([p]) => p === c.path); if (n) nodes.push(...n[1]); }
const leaves = nodes.filter((n) => n.class === "leaf");
const typeNames = [...new Set(nodes.map((n) => n.type))];
const desc = {
  format_version: { major: 1, minor: 0 }, redstone_version: "0.3.1", kind: "build",
  build: {
    structure: { nodes, root_inputs: rootIn.map(face), anchors, scopes: [],
      types: typeNames.map((name) => ({ name, locations: [] })) },
    outputs: { order: leaves.map((n) => n.path),
      components: leaves.map((n) => ({ path: n.path, stage1: n.outputs.map((f) => f.name), stage2: [] })) },
  },
};
writeFileSync(new URL("../fixtures/synthetic_150.json", import.meta.url), JSON.stringify(desc, null, 1) + "\n");
console.log(`synthetic: ${children.length} blocks at the root level (${nested.length} assemblies), ${rootNode.wires.length} wires, ${nodes.length} nodes`);
