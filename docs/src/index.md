# AutomaticCalculus

AutomaticCalculus provides concise notation for calculus operations on Julia
functions. It is based on `ForwardDiff` and `StaticArrays`. The package was
created mainly to help write tests for PDE solvers, but it is broadly
applicable.

The package is intentionally narrow in scope:

- keep the notation close to the math written in notebooks and papers
- expose first and second derivatives with lightweight wrappers
- support vector-valued functions and divergence-style expressions
- stay simple enough to inspect and reason about directly

## Core API

- `δ(i, j)`: Kronecker delta
- `e(u, i, x)`: `i`th component of a vector-valued function
- `∂`: directional and partial derivatives
- `∂∂`: second derivatives, including weighted variants
- `Δ`: Laplacian and weighted Laplacian-style sum
- `∇`: gradient
- `H`: Hessian matrix of a scalar-valued function
- `J`: Jacobian matrix of a vector-valued function
- `divergence`: divergence of a vector-valued function
- `rot`: scalar curl in 2D or curl vector in 3D
- `⋅`: convenience overload for `∇ ⋅ (u, x)`
- `×`: convenience overload for `∇ × (u, x)`

## Examples

```julia
using AutomaticCalculus
using StaticArrays

f(x) = x[1]^2 + 3x[1] * x[2] + x[2]^2
x = @SVector [2.0, 5.0]

∂(f, 1, x)          # 19.0
∂(f, 2, x)          # 16.0
∇(f, x)             # [19.0, 16.0]
H(f, x)             # [2.0 3.0; 3.0 2.0]
Δ(f, x)             # 4.0
Δ(f, x -> one(eltype(x)), x)
```

```julia
u(x) = @SVector [x[1]^2, x[1] * x[2]]

J(u, x)             # [4.0 0.0; 5.0 2.0]
divergence(u, x)    # 6.0
∇ ⋅ (u, x)          # 6.0
rot(u, x)           # 5.0
∇ × (u, x)          # 5.0
```

## API

```@docs
δ
e
∂
∂∂
Δ
∇
H
J
divergence
rot
⋅
×
```
