// Validates every fixture against the frozen schema copy with ajv, then checks
// answer 16's content assertions: endpoints resolve, every type has a row.
import { readFileSync, readdirSync } from "node:fs";
import Ajv from "ajv";

const dir = new URL("../fixtures/", import.meta.url);
const schema = JSON.parse(readFileSync(new URL("../schema.json", import.meta.url), "utf8"));
// Default strictness: strict mode's strictRequired trips on the envelope's oneOf.
const validate = new Ajv({ allErrors: true }).compile(schema);

let failed = false;
for (const file of readdirSync(dir).filter((f) => f.endsWith(".json")).sort()) {
  const d = JSON.parse(readFileSync(new URL(file, dir), "utf8"));
  const errors = [];
  if (!validate(d)) errors.push(...validate.errors.map((e) => `schema: ${e.instancePath} ${e.message}`));
  const s = (d.build ?? d.deployment.build).structure;
  const byPath = new Map(s.nodes.map((n) => [n.path, n]));
  const typeRows = new Set(s.types.map((t) => t.name));
  for (const n of s.nodes) {
    if (!typeRows.has(n.type)) errors.push(`no types row for ${n.type}`);
    for (const w of n.wires ?? []) {
      for (const [end, side] of [[w.from, "outputs"], [w.to, "inputs"]]) {
        const own = end.path === n.path;           // a boundary face of the level
        const target = byPath.get(end.path);
        const faces = own ? n[side === "outputs" ? "inputs" : "outputs"] : target?.[side];
        if (!faces?.some((f) => f.name === end.port)) errors.push(`level "${n.path}": unresolved ${JSON.stringify(end)}`);
      }
    }
  }
  console.log(`${file}: ${errors.length ? "FAIL" : "ok"} (${s.nodes.length} nodes)`);
  errors.slice(0, 20).forEach((e) => console.log("  " + e));
  failed ||= errors.length > 0;
}
process.exit(failed ? 1 : 0);
