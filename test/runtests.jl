using AutomaticCalculus
using AllocCheck: check_allocs
using LinearAlgebra: norm
using StaticArrays
using Test

const skip_aqua = "--skip-aqua" in ARGS || "--skip-aqua-jet" in ARGS
const skip_jet = "--skip-jet" in ARGS || "--skip-aqua-jet" in ARGS

no_allocs(func, types) = isempty(check_allocs(func, types))

if !skip_aqua
    using Aqua
end

if !skip_jet
    using JET
end

@testset "AutomaticCalculus" begin
    f(x) = x[1]^2 + 3x[1] * x[2] + x[2]^2
    g(x) = norm(@SVector [sin(x[1]), x[1] * x[2]])
    u(x) = @SVector [x[1]^2, x[1] * x[2]]
    v(x) = @SVector [sin(x[1] * x[2]), norm(x)]
    w(x) = @SVector [x[2]^2, x[3]^2, x[1]^2]
    σ(x) = one(eltype(x))

    x = @SVector [2.0, 5.0]
    y = @SVector [1.0, 2.0, 3.0]
    d = @SVector [1.0, 0.0]

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

    @testset "Correctness" begin
        @test δ(1, 1) == 1
        @test δ(1, 2) == 0

        @test e(u, 1, x) == 4.0

        @test ∂(f, 1, x) ≈ 19.0
        @test ∂(f, d, x) ≈ 19.0
        @test ∂(f, 2, x) ≈ 16.0
        @test ∇(f, x) == [∂(f, 1, x), ∂(f, 2, x)]
        @test ∂(g, 1, x) ≈ (sin(x[1]) * cos(x[1]) + x[1] * x[2]^2) / g(x)
        @test ∂(g, 2, x) ≈ x[1]^2 * x[2] / g(x)
        @test ∇(g, x) ≈ [
            (sin(x[1]) * cos(x[1]) + x[1] * x[2]^2) / g(x),
            x[1]^2 * x[2] / g(x),
        ]

        @test ∂∂(f, 1, 1, x) ≈ 2.0
        @test ∂∂(f, 1, σ, 1, x) ≈ 2.0
        @test H(f, x) ≈ @SMatrix [2.0 3.0; 3.0 2.0]

        @test Δ(f, x) ≈ 4.0
        @test Δ(f, σ, x) ≈ 4.0
        @test J(u, x) ≈ @SMatrix [4.0 0.0; 5.0 2.0]
        @test divergence(u, x) ≈ 6.0
        @test (∇ ⋅ (u, x)) ≈ 6.0
        @test divergence(v, x) ≈ x[2] * cos(x[1] * x[2]) + x[2] / norm(x)
        @test (∇ ⋅ (v, x)) ≈ x[2] * cos(x[1] * x[2]) + x[2] / norm(x)
        @test rot(u, x) ≈ x[2]
        @test (∇ × (u, x)) ≈ x[2]
        @test rot(v, x) ≈ x[1] / norm(x) - x[1] * cos(x[1] * x[2])
        @test (∇ × (v, x)) ≈ x[1] / norm(x) - x[1] * cos(x[1] * x[2])
        @test rot(w, y) ≈ @SVector [-2y[3], -2y[1], -2y[2]]
        @test (∇ × (w, y)) ≈ @SVector [-2y[3], -2y[1], -2y[2]]
    end

    @testset "Curried correctness" begin
        @test e(u, 1)(x) == 4.0

        @test ∂(f, 1)(x) ≈ 19.0
        @test ∇(f)(x) == [∂(f, 1, x), ∂(f, 2, x)]
        @test ∂(g, 1)(x) ≈ (sin(x[1]) * cos(x[1]) + x[1] * x[2]^2) / g(x)
        @test ∇(g)(x) ≈ ∇(g, x)

        @test ∂∂(f, 1, 1)(x) ≈ 2.0
        @test ∂∂(f, 1, σ, 1)(x) ≈ 2.0
        @test H(f)(x) ≈ @SMatrix [2.0 3.0; 3.0 2.0]

        @test Δ(f)(x) ≈ 4.0
        @test Δ(f, σ)(x) ≈ 4.0
        @test J(u)(x) ≈ @SMatrix [4.0 0.0; 5.0 2.0]
        @test divergence(u)(x) ≈ 6.0
        @test divergence(v)(x) ≈ x[2] * cos(x[1] * x[2]) + x[2] / norm(x)
        @test rot(u)(x) ≈ x[2]
        @test rot(v)(x) ≈ x[1] / norm(x) - x[1] * cos(x[1] * x[2])
        @test rot(w)(y) ≈ @SVector [-2y[3], -2y[1], -2y[2]]
    end

    @testset "AllocCheck" begin
        F = typeof(f)
        G = typeof(g)
        U = typeof(u)
        V = typeof(v)
        W = typeof(w)
        Σ = typeof(σ)
        Point = SVector{2,Float64}
        Point3 = SVector{3,Float64}

        @testset "Regular calls" begin
            @test no_allocs(δ, (Int, Int))
            @test no_allocs(e, (U, Int, Point))
            @test no_allocs(∂, (F, Point, Point))
            @test no_allocs(∂, (F, Int, Point))
            @test no_allocs(∇, (F, Point))
            @test no_allocs(∂, (G, Int, Point))
            @test no_allocs(∇, (G, Point))
            @test no_allocs(∂∂, (F, Int, Int, Point))
            @test no_allocs(∂∂, (F, Int, Σ, Int, Point))
            @test no_allocs(H, (F, Point))
            @test no_allocs(Δ, (F, Point))
            @test no_allocs(Δ, (F, Σ, Point))
            @test no_allocs(J, (U, Point))
            @test no_allocs(divergence, (U, Point))
            @test no_allocs(divergence, (V, Point))
            @test no_allocs(rot, (U, Point))
            @test no_allocs(rot, (V, Point))
            @test no_allocs(rot, (W, Point3))
            @test no_allocs(⋅, (typeof(∇), Tuple{U, Point}))
            @test no_allocs(⋅, (typeof(∇), Tuple{V, Point}))
            @test no_allocs(×, (typeof(∇), Tuple{U, Point}))
            @test no_allocs(×, (typeof(∇), Tuple{V, Point}))
            @test no_allocs(×, (typeof(∇), Tuple{W, Point3}))
        end

        @testset "Curried calls" begin
            @test no_allocs(∂(f, 1), (Point,))
            @test no_allocs(∇(f), (Point,))
            @test no_allocs(∂(g, 1), (Point,))
            @test no_allocs(∇(g), (Point,))
            @test no_allocs(∂∂(f, 1, 1), (Point,))
            @test no_allocs(∂∂(f, 1, σ, 1), (Point,))
            @test no_allocs(H(f), (Point,))
            @test no_allocs(Δ(f), (Point,))
            @test no_allocs(Δ(f, σ), (Point,))
            @test no_allocs(J(u), (Point,))
            @test no_allocs(divergence(u), (Point,))
            @test no_allocs(divergence(v), (Point,))
            @test no_allocs(rot(u), (Point,))
            @test no_allocs(rot(v), (Point,))
            @test no_allocs(rot(w), (Point3,))
        end
    end
end
