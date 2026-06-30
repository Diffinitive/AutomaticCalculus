# AutomaticCalculus

Small Julia helpers for calculus-style notation backed by automatic differentiation.

## Installation

```julia
using Pkg
Pkg.add("AutomaticCalculus")
```

## Examples

```julia
using AutomaticCalculus
using StaticArrays

f(x) = x[1]^2 + 3x[1] * x[2] + x[2]^2
x = @SVector [2.0, 5.0]

∂(f, 1, x)    # 19.0
∂(f, 2, x)    # 16.0
grad(f, x)    # (19.0, 16.0)
```

Operators can also be partially applied.

```julia
dfdx = ∂(f, 1)
dfdx(x)       # 19.0

gradient = grad(f)
gradient(x)   # (19.0, 16.0)
```

Second derivatives and weighted Laplacian-style sums are available through `∂∂` and `Δ`.

```julia
σ(x) = one(eltype(x))

∂∂(f, 1, 1, x)  # 2.0
∂∂(f, 1, 2, x)  # 3.0
Δ(f, σ, x)      # 4.0
```

For vector-valued functions, `divergence` computes the divergence.

```julia
u(x) = @SVector [x[1]^2, x[1] * x[2]]

divergence(u, x)    # 6.0
∇ ⋅ (u, x)          # 6.0
```
