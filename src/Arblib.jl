module Arblib

include(joinpath(@__DIR__, "..", "deps", "deps.jl"))

function __init__()
    check_deps()
end

include("macros.jl")
include("arb_types.jl")
include("types.jl")
# include("constructors.jl")

# include("predicates.jl")

end # module
