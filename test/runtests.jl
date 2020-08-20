using Arblib, Test, LinearAlgebra

@testset "Arblib" begin
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
end
