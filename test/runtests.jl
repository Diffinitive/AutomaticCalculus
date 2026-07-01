using AutomaticCalculus
using AllocCheck: check_allocs
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
    d = @SVector [1.0, 0.0]
    u(x) = @SVector [x[1]^2, x[1] * x[2]]
    σ(x) = one(eltype(x))

    @test AutomaticCalculus.onehot(2, 3) == @SVector [0, 1, 0]
    @test δ(1, 1) == 1
    @test δ(1, 2) == 0

    @test e(u, 1, x) == 4.0
    @test e(u, 1)(x) == 4.0

    @test ∂(f, 1, x) ≈ 19.0
    @test ∂(f, d, x) ≈ 19.0
    @test ∂(f, 2, x) ≈ 16.0
    @test ∂(f, 1)(x) ≈ 19.0
    @test ∇(f, x) == (∂(f, 1, x), ∂(f, 2, x))
    @test ∇(f)(x) == (∂(f, 1, x), ∂(f, 2, x))

    @test ∂∂(f, 1, 1, x) ≈ 2.0
    @test ∂∂(f, 1, 1)(x) ≈ 2.0
    @test ∂∂(f, 1, σ, 1, x) ≈ 2.0
    @test ∂∂(f, 1, σ, 1)(x) ≈ 2.0

    @test Δ(f, σ, x) ≈ 4.0
    @test Δ(f, σ)(x) ≈ 4.0
    @test divergence(u, x) ≈ 6.0
    @test divergence(u)(x) ≈ 6.0
    @test (∇ ⋅ (u, x)) ≈ 6.0
end

no_allocs(func, types) = isempty(check_allocs(func, types))

@testset "AllocCheck" begin
    f(x) = x[1]^2 + 3x[1] * x[2] + x[2]^2
    x = @SVector [2.0, 5.0]
    d = @SVector [1.0, 0.0]
    u(x) = @SVector [x[1]^2, x[1] * x[2]]
    σ(x) = one(eltype(x))

    @test no_allocs(δ, (Int, Int))
    @test no_allocs(e, (typeof(u), Int, SVector{2,Float64}))
    @test no_allocs(∂, (typeof(f), SVector{2,Float64}, SVector{2,Float64}))
    @test no_allocs(∂, (typeof(f), Int, SVector{2,Float64}))
    @test no_allocs(∂(f, 1), (SVector{2,Float64},))
    @test no_allocs(∇, (typeof(f), SVector{2,Float64}))
    @test no_allocs(∇(f), (SVector{2,Float64},))
    @test no_allocs(∂∂, (typeof(f), Int, Int, SVector{2,Float64}))
    @test no_allocs(∂∂, (typeof(f), Int, typeof(σ), Int, SVector{2,Float64}))
    @test no_allocs(∂∂(f, 1, 1), (SVector{2,Float64},))
    @test no_allocs(∂∂(f, 1, σ, 1), (SVector{2,Float64},))
    @test no_allocs(Δ, (typeof(f), typeof(σ), SVector{2,Float64}))
    @test no_allocs(Δ(f, σ), (SVector{2,Float64},))
    @test no_allocs(divergence, (typeof(u), SVector{2,Float64}))
    @test no_allocs(divergence(u), (SVector{2,Float64},))
    @test no_allocs(⋅, (typeof(∇), Tuple{typeof(u), SVector{2,Float64}}))
end
