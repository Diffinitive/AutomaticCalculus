# AutomaticCalculus

Small Julia helpers for calculus-style notation backed by automatic differentiation.

## Local Use

From another Julia project, add this package by path:

```julia
using Pkg
Pkg.develop(path="/Users/jonatan/Dropbox/julia/llm_test/AutomaticCalculus.jl")
```

Then load it with:

```julia
using AutomaticCalculus
```

The original `include("code.jl")` workflow still works from this directory, but package loading should be preferred for new projects.
