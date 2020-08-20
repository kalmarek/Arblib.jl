module Arblib

using Arb_jll
import LinearAlgebra

export Arf, Arb, ArbRef, Acb, AcbRef, ArbVector, AcbVector, ArbMatrix, AcbMatrix

macro libarb(function_name)
    return (:($function_name), libarb)
end

macro libflint(function_name)
    return (:($function_name), Arb_jll.libflint)
end

include("arb_types.jl")
include("types.jl")
include("rounding.jl")
include("arbcall.jl")

include("precision.jl")

include("constructors.jl")

include("arb_vector.jl")
include("acb_vector.jl")
include("arb_matrix.jl")
include("acb_matrix.jl")

include("predicates.jl")
include("show.jl")
include("arithmetic.jl")
include("linear_algebra.jl")

include("arbcalls/mag.jl")
include("arbcalls/arf.jl")
include("arbcalls/arb.jl")
include("arbcalls/acb.jl")
include("arbcalls/arb_mat.jl")
include("arbcalls/acb_mat.jl")

end # module
