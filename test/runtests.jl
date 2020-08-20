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
    include("vector.jl")
    include("matrix.jl")

end
