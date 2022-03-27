module ArbCall

using ..Arblib

import ..Arblib:
    cstructtype,
    arb_rnd,
    mag_struct,
    arf_struct,
    arb_struct,
    acb_struct,
    arb_vec_struct,
    acb_vec_struct,
    arb_poly_struct,
    acb_poly_struct,
    arb_mat_struct,
    acb_mat_struct,
    MagLike,
    ArfLike,
    ArbLike,
    AcbLike,
    ArbVectorLike,
    AcbVectorLike,
    ArbMatrixLike,
    AcbMatrixLike,
    ArbPolyLike,
    AcbPolyLike,
    ArbTypes

include("ArbArgTypes.jl")
include("Carg.jl")
include("ArbFunction.jl")
include("ArbFPWrapFunction.jl")

include("parse.jl")

end
