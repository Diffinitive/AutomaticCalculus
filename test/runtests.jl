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
    u(x) = @SVector [x[1]^2, x[1] * x[2]]
    σ(x) = one(eltype(x))

    F = typeof(f)
    U = typeof(u)
    Σ = typeof(σ)

    Point = SVector{2,Float64}

    @testset "Regular calls" begin
        @test no_allocs(δ, (Int, Int))
        @test no_allocs(e, (U, Int, Point))

        @test no_allocs(∂, (F, Point, Point))
        @test no_allocs(∂, (F, Int, Point))
        @test no_allocs(∇, (F, Point))
        @test no_allocs(∂∂, (F, Int, Int, Point))
        @test no_allocs(∂∂, (F, Int, Σ, Int, Point))
        @test no_allocs(Δ, (F, Σ, Point))
        @test no_allocs(divergence, (U, Point))
        @test no_allocs(⋅, (typeof(∇), Tuple{U, Point}))
    end

    @testset "Closure calls" begin
        @test no_allocs(∂(f, 1), (Point,))
        @test no_allocs(∇(f), (Point,))
        @test no_allocs(∂∂(f, 1, 1), (Point,))
        @test no_allocs(∂∂(f, 1, σ, 1), (Point,))
        @test no_allocs(Δ(f, σ), (Point,))
        @test no_allocs(divergence(u), (Point,))
    end
end
