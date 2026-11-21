# Design: §14.10, D-475.
# The labeled form of a `Linearization`: its arrays as component arrays over
# axes built from the label tuples, by position. ComponentArrays leaves plain an
# array whose tap lists are all empty. The data is unwrapped first, so a value
# labeled already is labeled again over the same axes.
module RedstoneComponentArraysExt

import Redstone
using Redstone: Linearization
using ComponentArrays: Axis, ComponentArray, ComponentMatrix, ComponentVector, getdata

_data(array::ComponentArray) = getdata(array)
_data(array::AbstractArray) = array

function Redstone.labeled(linearization::Linearization)
    (; ẋ₀, x₀, u₀, y₀, A, B, C, D, x_labels, u_labels, y_labels) = linearization
    x, u, y = Axis(x_labels), Axis(u_labels), Axis(y_labels)
    Linearization(ComponentVector(_data(ẋ₀), x), ComponentVector(_data(x₀), x),
                  ComponentVector(_data(u₀), u), ComponentVector(_data(y₀), y),
                  ComponentMatrix(_data(A), x, x), ComponentMatrix(_data(B), x, u),
                  ComponentMatrix(_data(C), y, x), ComponentMatrix(_data(D), y, u),
                  x_labels, u_labels, y_labels)
end

end # module RedstoneComponentArraysExt
