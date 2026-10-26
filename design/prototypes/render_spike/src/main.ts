import { mount } from "svelte";
// Svelte Flow's stylesheet, here because the build drops it from the canvas's lazy chunk.
import "@xyflow/svelte/dist/style.css";
import App from "./App.svelte";
export default mount(App, { target: document.getElementById("app")! });
