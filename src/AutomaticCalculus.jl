module AutomaticCalculus

using ForwardDiff
using StaticArrays

import LinearAlgebra: ⋅

export δ
export e
export ∂
export ∂∂
export Δ
export divergence
export ∇
export ⋅

## Automatic differentiation
onehot(k, N) = SVector(ntuple(i -> k == i ? 1 : 0, N))
tuple_range(n) = ntuple(identity, n)
index_tuple(x) = tuple_range(length(x))

δ(i, j) = i == j ? 1 : 0

e(u, i, x) = u(x)[i]
e(u, i) = x -> e(u, i, x)

∂(f, d::AbstractArray, x) = ForwardDiff.derivative(s -> f(x + s * d), 0)
∂(f, d::AbstractArray) = x -> ∂(f, d, x)

∂(f, i::Int, x) = ∂(f, onehot(i, length(x)), x)
∂(f, i::Int) = x -> ∂(f, i, x)

∂∂(f, i, j, x::AbstractArray) = ∂(∂(f, j), i, x)
∂∂(f, i, j) = x -> ∂∂(f, i, j, x::AbstractArray)

∂∂(f, i, σ, j, x::AbstractArray) = ∂(x -> σ(x) * ∂(f, j, x), i, x)
∂∂(f, i, σ, j) = x -> ∂∂(f, i, σ, j, x::AbstractArray)

Δ(f, σ, x) = sum(k -> ∂∂(f, k, σ, k, x), index_tuple(x))
Δ(f, σ) = x -> Δ(f, σ, x)

∇(f, x) = map(i -> ∂(f, i, x), index_tuple(x))
∇(f) = x -> ∇(f, x)

divergence(f, x::AbstractArray) = sum(k -> ∂(e(f, k), k, x), index_tuple(x))
divergence(f::Function) = x -> divergence(f, x)

⋅(::typeof(∇), t::Tuple) = divergence(t...)

# function J(f, x)
#     n = length(f(zero(x)))
#     m = length(x)
#
#     _smatrix(n,m) do i,j
#         @inline
#         ∂(e(f,i),j,x)
#     end
# end
# TBD: Can the above be made type-stable?

## Helpers
function _smatrix(f, n, m)
    map(ntuple(k -> (mod1(k, n), fld1(k, n)), n * m)) do (i, j)
        @inline
        f(i, j)
    end |> SMatrix{n, m}
end

end
