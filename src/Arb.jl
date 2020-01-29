module Arb

include(joinpath(@__DIR__, "..", "deps", "deps.jl"))

function __init__()
    check_deps()
end


end # module
