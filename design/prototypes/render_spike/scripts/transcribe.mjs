// Transcribes closed_loop and descent from examples/src/longitudinal.jl and the
// Build renderings beside this directory into build descriptors, by hand.
// Kind markers, types, signatures, parameters and locations are approximate.
import { writeFileSync } from "node:fs";

const SRC = "/Users/miguel/.julia/dev/Redstone.jl/src/blocks.jl";
const EX = "/Users/miguel/.julia/dev/Redstone.jl/examples/src/longitudinal.jl";
const B = "Redstone.Blocks.";

// --- kind markers and faces ---
const F = { kind: "float" }, BOOL = { kind: "boolean" }, I8 = { kind: "integer" };
const vec = (n, element) => ({ kind: "vector", shape: [n], element });
const STOPFLAG = { kind: "enum", values: ["NO_STOP", "STOP_REQUESTED"] };
const face = (name, type = "Float64", kind = F, pinned = false) => ({ name, type, kind, pinned });
const floats = (...names) => names.map((n) => face(n));

// --- one row per type: the faces a leaf of that type declares ---
const pidIn = [face("r"), face("y"), face("saturation", "Int8", I8), face("engaged", "Bool", BOOL), face("v")];
const pidOut = [face("u"), face("u_raw"), face("saturated", "Int8", I8)];
const sv = (n, t = "Float64") => `StaticArraysCore.SVector{${n}, ${t}}`;
const trackerIn = [
  face("x", sv(5), vec(5, F)), face("z", sv(2), vec(2, F)), face("z_ref", sv(2), vec(2, F)),
  face("saturation", sv(2, "Int8"), vec(2, I8)), face("engaged", sv(2, "Bool"), vec(2, BOOL)),
  face("v", sv(2), vec(2, F)),
];
const trackerOut = [face("u", sv(2), vec(2, F)), face("u_raw", sv(2), vec(2, F)),
  face("saturated", sv(2, "Int8"), vec(2, I8))];

const loc = (fn, line, file = SRC) => ({ function: fn, file, line });
const TYPES = {
  [B + "Step"]: { doc: "    Step(; t_step, before = 0.0, after = 1.0, localized = true)\n\nA step from `before` to `after` at `t_step`.",
    locations: [loc("x_init", 826), loc("m_init", 827), loc("y_types", 828)] },
  [B + "Constant"]: { doc: "    Constant(value)\n\nA constant output, pinned.", locations: [loc("x_init", 137), loc("y_types", 138)] },
  [B + "Source"]: { doc: "    Source{V}(f)\n\nThe output `f(t)`, pinned.", locations: [loc("x_init", 406), loc("y_types", 407)] },
  ["RedstoneExamples.Longitudinal"]: { doc: "A rigid aircraft in its plane of symmetry, with three degrees of freedom.",
    locations: [loc("u_types", 45, EX), loc("y_types", 46, EX), loc("x_init", 44, EX)] },
  ["RedstoneExamples.GroundContact"]: { doc: "The ground under the aircraft.",
    locations: [loc("u_types", 92, EX), loc("y_types", 93, EX), loc("x_init", 90, EX), loc("m_init", 91, EX)] },
  [B + "GaussianWhiteNoise"]: { doc: "    GaussianWhiteNoise(; seed, μ, σ, psd)\n\nDiscrete white noise.",
    locations: [loc("y_types", 378), loc("s_init", 377)] },
  [B + "Junction"]: { doc: "    Junction{In, Out, N}(f)\n\nA memoryless fold of `N` inputs.",
    locations: [loc("u_types", 78), loc("y_types", 80), loc("x_init", 77)] },
  [B + "DiscretePID"]: { doc: "    DiscretePID(; Kp, Ki, Kd, τd, Tt, u_min, u_max, b, c, hold, tracking)\n\nThe discrete PID.",
    locations: [loc("u_types", 1103), loc("y_types", 1300), loc("s_init", 1299)] },
  [B + "DiscreteLQRTracker"]: { doc: "    DiscreteLQRTracker(; K_fbk, K_fwd, K_int, …)\n\nThe discrete LQR tracker.",
    locations: [loc("u_types", 1348), loc("y_types", 1557), loc("s_init", 1555)] },
  [B + "Unpack"]: { doc: "    Unpack{V, N}()\n\nThe inverse of `Pack`.", locations: [loc("u_types", 97), loc("y_types", 98), loc("x_init", 96)] },
  [B + "Switch"]: { doc: "    Switch{V}()\n\nSelects `in1` while `select` holds.", locations: [loc("u_types", 117), loc("y_types", 118), loc("x_init", 116)] },
  [B + "UnitDelay"]: { doc: "    UnitDelay(v0)\n\nOne tick of delay.", locations: [loc("u_types", 156), loc("y_types", 157), loc("s_init", 155)] },
  [B + "RateLimiter"]: { doc: "    RateLimiter(; rising, falling, s0)\n\nA discrete rate limiter.", locations: [loc("u_types", 316), loc("y_types", 317), loc("s_init", 315)] },
  [B + "FirstOrderLag"]: { doc: "    FirstOrderLag(; τ, x0)\n\nA first-order lag.", locations: [loc("u_types", 450), loc("y_types", 451), loc("x_init", 449)] },
  [B + "StopRequest"]: { doc: "    StopRequest(; reason = \"\")\n\nRequests a stop when `request` holds.",
    locations: [loc("u_types", 193), loc("y_types", 194), loc("x_init", 192), loc("stop_reason", 196)] },
  [B + "Group"]: { doc: "    Group(children; local_wires, input_wires, output_wires, sample_times)\n\nThe ad-hoc assembly.",
    locations: [loc("sample_times", 1620), loc("local_wires", 1617), loc("input_wires", 1618), loc("output_wires", 1619), loc("transparent_container", 1621)] },
};

const cut = (s) => (s.length > 80 ? s.slice(0, 79) + "…" : s);
const params = (obj) => Object.entries(obj).map(([name, value]) => ({ name, value: cut(value) }));
const T0 = { anchor: 0, m: 1, c: 0 };

function leaf(path, tier, type, signature, inputs, outputs, parameters, timing = T0) {
  return { path, field: "children", key: path, class: "leaf", tier, timing, type: type, signature,
           inputs, outputs, parameters: params(parameters) };
}
function root(type, signature, inputs, outputs, wires, parameters) {
  return { path: "", class: "assembly", type, signature, inputs: inputs.map((name) => ({ name })),
           outputs: outputs.map((name) => ({ name })), wires, parameters: params(parameters) };
}
// "a/x" => "b/y" as endpoints at the root level; a bare name is a root boundary face.
function wire(from, to) {
  const ep = (s) => { const i = s.lastIndexOf("/"); return i < 0 ? { path: "", port: s } : { path: s.slice(0, i), port: s.slice(i + 1) }; };
  return { from: ep(from), to: ep(to) };
}
function envelope(nodes, rootInputs, anchors, outputs) {
  const used = [...new Set(nodes.map((n) => n.type))];
  const types = used.map((name) => {
    const t = TYPES[name];
    return { name, docstring: t.doc, locations: t.locations };
  });
  return {
    format_version: { major: 1, minor: 0 }, redstone_version: "0.3.1", kind: "build",
    build: { structure: { nodes, root_inputs: rootInputs, anchors, scopes: [], types }, outputs },
  };
}
function outputsSection(rows) {
  const components = rows.map(([path, s1, s2]) => ({ path, stage1: s1, stage2: s2 }));
  return { order: components.map((c) => c.path), components };
}

// ---------------------------------------------------------------- closed_loop
// Trim values are placeholders; the fixture exercises the drawing, not the trim.
const θ = "0.0436", δe = "-0.0262", δt = "0.2481";
const pidSig = `${B}DiscretePID{Float64, true, true, @NamedTuple{Kp::Float64, Ki::Float64, Kd::Float64, τd::Float64, Tt::Float64, u_min::Float64, u_max::Float64, b::Float64, c::Float64}}`;
const pid = (path, a, Kp, Ki, umin, umax) =>
  leaf(path, "discrete", B + "DiscretePID", pidSig, pidIn, pidOut,
       { fixed: `(Kp = ${Kp}, Ki = ${Ki}, Kd = 0.0, τd = 0.1, Tt = 0.02, u_min = ${umin}, u_max = ${umax}, b = 1.0, c = 0.0)` },
       a);
const packSig = (n) => `${B}Junction{Float64, ${sv(n)}, ${n}, typeof(Redstone.Blocks.pack)}`;
const pack = (path, n) => leaf(path, "continuous", B + "Junction", packSig(n),
  floats(...Array.from({ length: n }, (_, i) => `in${i + 1}`)), [face("out", sv(n), vec(n, F))], { f: "pack" });
const longitudinalParams = { m: "1000.0", S: "16.0", c̄: "1.5", Iyy: "1800.0", T_max: "2500.0", ρ: "1.225", CL0: "0.3",
  CLα: "5.0", CD0: "0.03", k: "0.05", Cm0: "0.05", Cmα: "-1.0", Cmq: "-12.0", Cmδe: "-1.2" };
const plant = () => leaf("plant", "continuous", "RedstoneExamples.Longitudinal", "RedstoneExamples.Longitudinal",
  floats("δe", "δt"), floats("V", "γ", "θ", "q", "h", "α"), longitudinalParams);

const clWires = [
  ["h_ref/out", "z_ref_pack/in1"], ["V_ref/out", "z_ref_pack/in2"],
  ["plant/h", "h_meas/in1"], ["noise/out", "h_meas/in2"],
  ["h_ref/out", "h_ctl/r"], ["h_meas/out", "h_ctl/y"], ["plant/θ", "h_ctl/v"],
  ["θ_ctl/saturated", "h_ctl/saturation"], ["mode/out", "h_ctl/engaged"],
  ["h_ctl/u", "θ_ctl/r"], ["plant/θ", "θ_ctl/y"], ["plant/q", "θ_ctl/v"],
  ["q_ctl/saturated", "θ_ctl/saturation"], ["mode/out", "θ_ctl/engaged"],
  ["θ_ctl/u", "q_ctl/r"], ["plant/q", "q_ctl/y"], ["command_δe/out", "q_ctl/v"],
  ["free/out", "q_ctl/saturation"], ["mode/out", "q_ctl/engaged"],
  ["V_ref/out", "V_ctl/r"], ["plant/V", "V_ctl/y"], ["command_δt/out", "V_ctl/v"],
  ["free/out", "V_ctl/saturation"], ["mode/out", "V_ctl/engaged"],
  ["plant/V", "state_pack/in1"], ["plant/γ", "state_pack/in2"], ["plant/θ", "state_pack/in3"],
  ["plant/q", "state_pack/in4"], ["plant/h", "state_pack/in5"], ["state_pack/out", "tracker/x"],
  ["h_meas/out", "z_pack/in1"], ["plant/V", "z_pack/in2"], ["z_pack/out", "tracker/z"],
  ["z_ref_pack/out", "tracker/z_ref"],
  ["command_δe/out", "command_pack/in1"], ["command_δt/out", "command_pack/in2"],
  ["command_pack/out", "tracker/v"], ["free_pair/out", "tracker/saturation"],
  ["mode/out", "tracker_engaged/in1"], ["tracker_engaged/out", "tracker/engaged"],
  ["tracker/u", "tracker_u/in"],
  ["q_ctl/u", "select_δe/in1"], ["tracker_u/out1", "select_δe/in2"], ["mode/out", "select_δe/select"],
  ["V_ctl/u", "select_δt/in1"], ["tracker_u/out2", "select_δt/in2"], ["mode/out", "select_δt/select"],
  ["select_δe/out", "command_δe/in"], ["select_δt/out", "command_δt/in"],
  ["select_δe/out", "δe_limiter/in"], ["δe_limiter/out", "δe_lag/in"], ["δe_lag/out", "plant/δe"],
  ["select_δt/out", "δt_limiter/in"], ["δt_limiter/out", "δt_lag/in"], ["δt_lag/out", "plant/δt"],
].map(([a, b]) => wire(a, b));

const anchored = ["noise", "h_ctl", "θ_ctl", "q_ctl", "V_ctl", "tracker", "command_δe", "command_δt", "δe_limiter", "δt_limiter"];
const A = (name) => ({ anchor: anchored.indexOf(name) + 1, m: 1, c: 0 });
const groupSig = (names) => `${B}Group{@NamedTuple{${names.join(", ")}}, …}`;
const clNames = ["h_ref", "V_ref", "mode", "plant", "noise", "h_meas", "h_ctl", "θ_ctl", "q_ctl", "V_ctl", "tracker",
  "state_pack", "z_pack", "z_ref_pack", "tracker_u", "select_δe", "select_δt", "command_δe", "command_δt",
  "command_pack", "tracker_engaged", "free", "free_pair", "δe_limiter", "δe_lag", "δt_limiter", "δt_lag"];

const clNodes = [
  root(B + "Group", groupSig(clNames), [], [], clWires, {
    local_wires: `("h_ref/out" => "z_ref_pack/in1", "V_ref/out" => "z_ref_pack/in2", "plant/h" => "h_meas/in1", …)`,
    input_wires: "()", output_wires: "()",
    sample_times: "(noise = Absolute(1//50, 0//1), h_ctl = Absolute(1//50, 0//1), θ_ctl = Absolute(1//50, 0//1), …)" }),
  leaf("h_ref", "continuous", B + "Step", `${B}Step{Float64, true}`, [], [face("out", "Float64", F, true)],
       { before: "1000.0", after: "1050.0", t_step: "5.0" }),
  leaf("V_ref", "continuous", B + "Constant", `${B}Constant{Float64}`, [], [face("out", "Float64", F, true)], { value: "50.0" }),
  leaf("mode", "continuous", B + "Source", `${B}Source{Bool, RedstoneExamples.var\"#closed_loop##0#closed_loop##1\"}`, [],
       [face("out", "Bool", BOOL, true)], { f: "#closed_loop##0" }),
  plant(),
  leaf("noise", "discrete", B + "GaussianWhiteNoise", `${B}GaussianWhiteNoise{Float64}`, [], [face("out")],
       { seed: "0x0000000000000007", μ: "0.0", σ: "0.3", density: "false" }, A("noise")),
  leaf("h_meas", "continuous", B + "Junction", `${B}Junction{Float64, Float64, 2, typeof(+)}`, floats("in1", "in2"),
       [face("out")], { f: "+" }),
  pid("h_ctl", A("h_ctl"), "0.01", "0.001", "-0.26", "0.26"),
  pid("θ_ctl", A("θ_ctl"), "2.0", "0.5", "-0.5", "0.5"),
  pid("q_ctl", A("q_ctl"), "-0.2", "-0.4", "-0.5", "0.5"),
  pid("V_ctl", A("V_ctl"), "0.2", "0.05", "0.0", "1.0"),
  leaf("tracker", "discrete", B + "DiscreteLQRTracker", `${B}DiscreteLQRTracker{5, 2, 2, true, true, @NamedTuple{K_fbk::StaticArraysCore.SMatrix{2, 5, Float64, 10}, …}}`,
       trackerIn, trackerOut,
       { fixed: "(K_fbk = [0.0123 -1.97 2.41 0.613 -0.0101; 0.0612 0.0745 -0.0212 -0.00311 0.00205], K_fwd = …)" }, A("tracker")),
  pack("state_pack", 5), pack("z_pack", 2), pack("z_ref_pack", 2),
  leaf("tracker_u", "continuous", B + "Unpack", `${B}Unpack{Float64, 2}`, [face("in", sv(2), vec(2, F))], floats("out1", "out2"), {}),
  leaf("select_δe", "continuous", B + "Switch", `${B}Switch{Float64}`, [face("in1"), face("in2"), face("select", "Bool", BOOL)], [face("out")], {}),
  leaf("select_δt", "continuous", B + "Switch", `${B}Switch{Float64}`, [face("in1"), face("in2"), face("select", "Bool", BOOL)], [face("out")], {}),
  leaf("command_δe", "discrete", B + "UnitDelay", `${B}UnitDelay{Float64}`, floats("in"), floats("out"), { v0: δe }, A("command_δe")),
  leaf("command_δt", "discrete", B + "UnitDelay", `${B}UnitDelay{Float64}`, floats("in"), floats("out"), { v0: δt }, A("command_δt")),
  pack("command_pack", 2),
  leaf("tracker_engaged", "continuous", B + "Junction", `${B}Junction{Bool, ${sv(2, "Bool")}, 1, RedstoneExamples.var"#closed_loop##2#closed_loop##3"}`,
       [face("in1", "Bool", BOOL)], [face("out", sv(2, "Bool"), vec(2, BOOL))], { f: "#closed_loop##2" }),
  leaf("free", "continuous", B + "Constant", `${B}Constant{Int8}`, [], [face("out", "Int8", I8, true)], { value: "0" }),
  leaf("free_pair", "continuous", B + "Constant", `${B}Constant{${sv(2, "Int8")}}`, [],
       [face("out", sv(2, "Int8"), vec(2, I8), true)], { value: "Int8[0, 0]" }),
  leaf("δe_limiter", "discrete", B + "RateLimiter", `${B}RateLimiter{Float64}`, floats("in"), floats("out"),
       { rising: "1.0", falling: "-1.0", s0: δe }, A("δe_limiter")),
  leaf("δe_lag", "continuous", B + "FirstOrderLag", `${B}FirstOrderLag{Float64}`, floats("in"), floats("out"), { x0: δe, τ: "0.05" }),
  leaf("δt_limiter", "discrete", B + "RateLimiter", `${B}RateLimiter{Float64}`, floats("in"), floats("out"),
       { rising: "0.5", falling: "-0.5", s0: δt }, A("δt_limiter")),
  leaf("δt_lag", "continuous", B + "FirstOrderLag", `${B}FirstOrderLag{Float64}`, floats("in"), floats("out"), { x0: δt, τ: "0.5" }),
];
const clAnchors = anchored.map((key) => ({ T: { num: 1, den: 50 }, tau: { num: 0, den: 1 }, scope: "", key }));
const clOutputs = outputsSection([
  ["h_ref", ["out"], []], ["V_ref", ["out"], []], ["mode", ["out"], []], ["plant", ["V", "γ", "θ", "q", "h", "α"], []],
  ["noise", ["out"], []], ["h_meas", [], ["out"]], ["V_ctl", ["saturated"], ["u", "u_raw"]], ["state_pack", [], ["out"]],
  ["z_ref_pack", [], ["out"]], ["command_δe", ["out"], []], ["command_δt", ["out"], []], ["command_pack", [], ["out"]],
  ["tracker_engaged", [], ["out"]], ["free", ["out"], []], ["free_pair", ["out"], []], ["δe_lag", ["out"], []],
  ["δt_lag", ["out"], []], ["z_pack", [], ["out"]], ["h_ctl", ["saturated"], ["u", "u_raw"]],
  ["tracker", ["saturated"], ["u", "u_raw"]], ["θ_ctl", ["saturated"], ["u", "u_raw"]], ["tracker_u", [], ["out1", "out2"]],
  ["q_ctl", ["saturated"], ["u", "u_raw"]], ["select_δt", [], ["out"]], ["select_δe", [], ["out"]],
  ["δt_limiter", [], ["out"]], ["δe_limiter", [], ["out"]],
]);
writeFileSync(new URL("../fixtures/closed_loop.json", import.meta.url),
  JSON.stringify(envelope(clNodes, [], clAnchors, clOutputs), null, 1) + "\n");

// -------------------------------------------------------------------- descent
const dNames = ["plant", "gear", "stop"];
const dWires = [["plant/h", "gear/h"], ["gear/contact", "stop/request"], ["δe", "plant/δe"], ["δt", "plant/δt"]]
  .map(([a, b]) => wire(a, b));
const dNodes = [
  root(B + "Group", groupSig(dNames), ["δe", "δt"], [], dWires, {
    local_wires: `("plant/h" => "gear/h", "gear/contact" => "stop/request")`,
    input_wires: `("δe" => "plant/δe", "δt" => "plant/δt")`, output_wires: "()", sample_times: "(;)" }),
  plant(),
  leaf("gear", "continuous", "RedstoneExamples.GroundContact", "RedstoneExamples.GroundContact", floats("h"),
       [face("contact", "Bool", BOOL)], { h_ground: "0.0" }),
  leaf("stop", "continuous", B + "StopRequest", `${B}StopRequest`, [face("request", "Bool", BOOL)],
       [face("flag", "Redstone.StopFlag", STOPFLAG)], { reason: `"touchdown"` }),
];
const dOutputs = outputsSection([["plant", ["V", "γ", "θ", "q", "h", "α"], []], ["gear", ["contact"], []], ["stop", [], ["flag"]]]);
writeFileSync(new URL("../fixtures/descent.json", import.meta.url),
  JSON.stringify(envelope(dNodes, floats("δe", "δt"), [], dOutputs), null, 1) + "\n");
console.log(`closed_loop: ${clNodes.length} nodes, ${clWires.length} wires; descent: ${dNodes.length} nodes, ${dWires.length} wires`);
