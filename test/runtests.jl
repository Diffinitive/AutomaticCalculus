using AutomaticCalculus
using StaticArrays
using Test

const skip_aqua = "--skip-aqua" in ARGS || "--skip-aqua-jet" in ARGS
const skip_jet = "--skip-jet" in ARGS || "--skip-aqua-jet" in ARGS

if !skip_aqua
    using Aqua
end

if !skip_jet
    using JET
end

if !skip_aqua
    @testset "Aqua" begin
        Aqua.test_all(AutomaticCalculus)
    end
end

if !skip_jet
    @testset "JET" begin
        JET.test_package(
            AutomaticCalculus;
            target_modules = (AutomaticCalculus,),
            toplevel_logger = nothing,
        )
    end
end

@testset "AutomaticCalculus" begin
    f(x) = x[1]^2 + 3x[1] * x[2] + x[2]^2
    x = @SVector [2.0, 5.0]

    @test AutomaticCalculus.onehot(2, 3) == @SVector [0, 1, 0]
    @test δ(1, 1) == 1
    @test δ(1, 2) == 0
    @test ∂(f, 1, x) ≈ 19.0
    @test ∂(f, 2, x) ≈ 16.0
    @test ∇(f, x) == (∂(f, 1, x), ∂(f, 2, x))

    σ(x) = one(eltype(x))
    @test Δ(f, σ, x) ≈ 4.0

    u(x) = @SVector [x[1]^2, x[1] * x[2]]
    @test divergence(u, x) ≈ 6.0
    @test (∇ ⋅ (u, x)) ≈ 6.0
end
