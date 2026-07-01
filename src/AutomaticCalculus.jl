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
Base.@constprop :aggressive onehot(k, N) = SVector(ntuple(i -> k == i ? 1 : 0, N))
tuple_range(n) = ntuple(identity, n)
index_tuple(x) = tuple_range(length(x))

"""
    δ(i, j)

Kronecker delta. Returns `1` when `i == j` and `0` otherwise.
"""
δ(i, j) = i == j ? 1 : 0

"""
    e(u, i, x)
    e(u, i)

Return the `i`th component of the vector-valued function `u` at `x`.
The two-argument form returns a function of `x`.
"""
e(u, i, x) = u(x)[i]
e(u, i) = x -> e(u, i, x)

"""
    ∂(f, d::AbstractArray, x)
    ∂(f, i::Int, x)
    ∂(f, d::AbstractArray)
    ∂(f, i::Int)

Directional derivative of `f` at `x` along direction `d`, or partial
derivative with respect to coordinate `i`.

The curried forms return a function of `x`.
"""
∂(f, d::AbstractArray, x) = ForwardDiff.derivative(s -> f(x + s * d), 0)
∂(f, d::AbstractArray) = x -> ∂(f, d, x)

∂(f, i::Int, x) = ∂(f, onehot(i, length(x)), x)
∂(f, i::Int) = x -> ∂(f, i, x)

"""
    ∂∂(f, i, j, x)
    ∂∂(f, i, j)
    ∂∂(f, i, σ, j, x)
    ∂∂(f, i, σ, j)

Second partial derivatives of `f`.

The weighted form computes the derivative of `σ(x) * ∂(f, j, x)` with respect
to coordinate `i`.
"""
∂∂(f, i, j, x::AbstractArray) = ∂(∂(f, j), i, x)
∂∂(f, i, j) = x -> ∂∂(f, i, j, x::AbstractArray)

∂∂(f, i, σ, j, x::AbstractArray) = ∂(x -> σ(x) * ∂(f, j, x), i, x)
∂∂(f, i, σ, j) = x -> ∂∂(f, i, σ, j, x::AbstractArray)

"""
    Δ(f, σ, x)
    Δ(f, σ)

Weighted Laplacian-style sum over the coordinates of `x`.
"""
Δ(f, σ, x) = sum(k -> ∂∂(f, k, σ, k, x), index_tuple(x))
Δ(f, σ) = x -> Δ(f, σ, x)

"""
    ∇(f, x)
    ∇(f)

Gradient of `f` with respect to the coordinates of `x`.
The curried form returns a function of `x`.
"""
∇(f, x) = map(i -> ∂(f, i, x), index_tuple(x))
∇(f) = x -> ∇(f, x)

"""
    divergence(f, x)
    divergence(f)

Divergence of a vector-valued function `f`.
The curried form returns a function of `x`.
"""
divergence(f, x::AbstractArray) = sum(k -> ∂(e(f, k), k, x), index_tuple(x))
divergence(f::Function) = x -> divergence(f, x)

"""
    ⋅(::typeof(∇), t::Tuple)

Convenience overload for `∇ ⋅ (u, x)`, which calls `divergence(u, x)`.
"""
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
