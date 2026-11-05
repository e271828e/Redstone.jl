module P7
using Test
include("test/repl.jl")
include("test/utils.jl")
include("design/reports/20261105_docstring_audit/probes/A1/common.jl")
struct PE <: AbstractComponent end
x_init(::PE)=nothing
u_types(::PE)=Pinned{Float64}
y_types(::PE)=(o=Float64,)
y_direct(::PE,(;u))=(o=u,)
const Nested = ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1}
print("walking into Pinned no freeze: "); show_err(()->build(Group((; i=Integrator(), e=PE()); local_wires=("i/y"=>"e/u",), input_wires=("τ"=>"i/u",)); activations=(Float64,LinearizeDual)))
print("with freeze: "); show_err(()->typeof(build(Group((; i=Integrator(), f=Freeze{Float64}(), e=PE()); local_wires=("i/y"=>"f/u","f/y"=>"e/u"), input_wires=("τ"=>"i/u",)); activations=(Float64,LinearizeDual))))
print("freeze at nested activation: "); show_err(()->build(Group((; i=Integrator(), f=Freeze{Float64}()); local_wires=("i/y"=>"f/u",), input_wires=("τ"=>"i/u",)); activations=(Float64,Nested)))
print("Model nested, freeze: "); show_err(()->begin b=build(Group((; i=Integrator(), f=Freeze{Float64}()); local_wires=("i/y"=>"f/u",), input_wires=("τ"=>"i/u",))); typeof(Model(Deployment(b;h=1//10),Nested)).name.name end)
end
