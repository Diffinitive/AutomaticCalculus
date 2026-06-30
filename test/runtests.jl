using AutomaticCalculus
using StaticArrays
using Test

@testset "AutomaticCalculus" begin
    f(x) = x[1]^2 + 3x[1] * x[2] + x[2]^2
    x = @SVector [2.0, 5.0]

    @test onehot(2, 3) == @SVector [0, 1, 0]
    @test δ(1, 1) == 1
    @test δ(1, 2) == 0
    @test ∂(f, 1, x) ≈ 19.0
    @test ∂(f, 2, x) ≈ 16.0
    @test grad(f, x) == (∂(f, 1, x), ∂(f, 2, x))

    σ(x) = one(eltype(x))
    @test Δ(f, σ, x) ≈ 4.0

    u(x) = @SVector [x[1]^2, x[1] * x[2]]
    @test div(u, x) ≈ 6.0
end
