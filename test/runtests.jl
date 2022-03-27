ENV["NEMO_THREADED"] = 1

using Arblib, Test, LinearAlgebra, SpecialFunctions

@testset "Arblib" begin
    include("arb_types-test.jl")
    include("types-test.jl")
    include("ArbCall-test.jl")
    include("precision-test.jl")
    include("setters-test.jl")
    include("constructors-test.jl")
    include("predicates-test.jl")
    include("show-test.jl")
    include("promotion.jl")
    include("examples.jl")
    include("arithmetic.jl")
    include("rand.jl")
    include("float.jl")
    include("interval.jl")
    include("vector.jl")
    include("matrix.jl")
    include("eigen.jl")
    include("calc_integrate.jl")
    include("ref-test.jl")
    include("poly.jl")
    include("series.jl")
    include("special-functions.jl")
    include("threading.jl")
end
