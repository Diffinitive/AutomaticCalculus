module AutomaticCalculus

using ForwardDiff
using StaticArrays

using LinearAlgebra
import LinearAlgebra: ⋅, ×

export δ
export e
export ∂
export ∂∂
export Δ
export H
export J
export divergence
export rot
export ∇
export ⋅
export ×

## Automatic differentiation
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
∂(f, d::AbstractArray, x) = d⋅∇(f,x)
∂(f, d::AbstractArray) = x -> ∂(f, d, x)

∂(f, i::Int, x) = ∇(f,x)[i]
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
∂∂(f, i, j) = x -> ∂∂(f, i, j, x)

∂∂(f, i, σ, j, x::AbstractArray) = ∂(x -> σ(x) * ∂(f, j, x), i, x)
∂∂(f, i, σ, j) = x -> ∂∂(f, i, σ, j, x)

"""
    Δ(f, x)
    Δ(f)
    Δ(f, σ, x)
    Δ(f, σ)

Laplacian of the scalar-valued function `f`, computed as the trace of the
Hessian of `f` at `x`.

The weighted form computes the sum over the coordinates of `x` of
`∂ᵢ(σ(x) * ∂ᵢf(x))`.

The curried forms return a function of `x`.
"""
Δ(f, x::AbstractArray) = tr(H(f, x))
Δ(f) = x -> Δ(f, x)

Δ(f, σ, x::AbstractArray) = sum(k -> ∂∂(f, k, σ, k, x), index_tuple(x))
Δ(f, σ::Function) = x -> Δ(f, σ, x)

"""
    ∇(f, x)
    ∇(f)

Gradient of `f` with respect to the coordinates of `x`.
The curried form returns a function of `x`.
"""
∇(f, x) = ForwardDiff.gradient(f, x)
∇(f) = x -> ∇(f, x)

"""
    J(f, x)
    J(f)

Jacobian matrix of the vector-valued function `f` at `x`.
Rows correspond to output components and columns to input coordinates.

The one-argument form returns a function of `x`.
"""
J(f, x) = ForwardDiff.jacobian(f, x)
J(f) = x -> J(f, x)

"""
    H(f, x)
    H(f)

Hessian matrix of the scalar-valued function `f` at `x`.

The one-argument form returns a function of `x`.
"""
H(f, x) = ForwardDiff.hessian(f, x)
H(f) = x -> H(f, x)

"""
    divergence(f, x)
    divergence(f)

Divergence of a vector-valued function `f`.
The curried form returns a function of `x`.
"""
divergence(f, x::AbstractArray) = sum(k -> ∂(e(f, k), k, x), index_tuple(x))
divergence(f::Function) = x -> divergence(f, x)

"""
    rot(f, x)
    rot(f)

Rotational operator for vector-valued functions. For two-dimensional inputs,
returns the scalar curl `∂f₂/∂x₁ - ∂f₁/∂x₂`. For three-dimensional inputs,
returns the curl vector.

The one-argument form returns a function of `x`.
"""
rot(f, x::AbstractArray) = _rot(f, x, Val(length(x)))
rot(f::Function) = x -> rot(f, x)

_rot(f, x, ::Val{2}) = ∂(e(f, 2), 1, x) - ∂(e(f, 1), 2, x)
_rot(f, x, ::Val{3}) = @SVector [
    ∂(e(f, 3), 2, x) - ∂(e(f, 2), 3, x),
    ∂(e(f, 1), 3, x) - ∂(e(f, 3), 1, x),
    ∂(e(f, 2), 1, x) - ∂(e(f, 1), 2, x),
]

"""
    ⋅(::typeof(∇), t::Tuple)

Convenience overload for `∇ ⋅ (u, x)`, which calls `divergence(u, x)`.
"""
⋅(::typeof(∇), t::Tuple) = divergence(t...)

"""
    ×(::typeof(∇), t::Tuple)

Convenience overload for `∇ × (u, x)`, which calls `rot(u, x)`.
"""
×(::typeof(∇), t::Tuple) = rot(t...)

end
