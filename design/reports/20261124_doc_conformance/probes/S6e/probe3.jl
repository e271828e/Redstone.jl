using Redstone, StaticArrays
import Redstone: Group; import Redstone.Library: SumJunction, Fn
try
    b = Redstone.build(Group((; s=SumJunction{Float64,0}(), t=Fn{Float64}(identity)); local_wires=("s/y"=>"t/u")))
    println("zero-arity junction builds: ", b)
catch e
    println("zero arity: ", e isa Redstone.DiagnosticError ? typeof(e.carried) : sprint(showerror, e))
end
