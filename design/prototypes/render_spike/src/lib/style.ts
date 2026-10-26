import type { Block } from "./descriptor";
export function fill(b: Block): string {
  if (b.role === "leaf") return b.tier === "discrete" ? "#fde7c8" : "#d6e6fb";
  if (b.role === "assembly") return "#e4e4e4";
  return "#ffffff";
}
export const stroke = (b: Block) => (b.role === "leaf" && b.tier === "discrete" ? "#b86e00" : b.role === "leaf" ? "#2f62a8" : "#555");
