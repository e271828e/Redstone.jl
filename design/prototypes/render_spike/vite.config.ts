import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
// One stylesheet: the build did not load the lazy Svelte Flow chunk's CSS.
export default defineConfig({ plugins: [svelte()], build: { cssCodeSplit: false } });
