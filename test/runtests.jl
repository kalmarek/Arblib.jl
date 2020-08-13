using Arblib, Test, LinearAlgebra

include("arb_types-test.jl")
include("types-test.jl")
include("arbcall-test.jl")
include("precision-test.jl")
include("constructors-test.jl")
include("predicates-test.jl")
include("show-test.jl")
include("examples.jl")
include("arb_vector.jl")
include("acb_vector.jl")
include("arb_matrix.jl")
include("acb_matrix.jl")
include("linear_algebra.jl")

@testset "Arblib" begin
    @test isa(Arb(π), Arb)
end

@testset "setprecision" begin
    x = Arb("0.1")
    @test precision(x) == 256
    @test precision(Arb) == 256
    @test string(x) ==
          "[0.1000000000000000000000000000000000000000000000000000000000000000000000000000 +/- 1.95e-78]"

    setprecision(Arb, 64)
    @test precision(x) == 256
    @test precision(Arb) == 64
    y = Arb("0.1")
    @test precision(y) == 64
    @test string(y) == "[0.100000000000000000 +/- 1.22e-20]"

    setprecision(Arb, 256)
end
