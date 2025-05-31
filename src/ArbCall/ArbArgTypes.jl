struct UnsupportedArgumentType <: Exception
    key::String
end

"""
    ArbArgTypes(supported, unsupported, supported_reversed)

Struct for conversion between C argument types in the Arb
documentation and Julia types.
"""
struct ArbArgTypes
    supported::Dict{String,DataType}
    unsupported::Set{String}
    supported_reversed::Dict{DataType,String}
end

function Base.getindex(arbargtypes::ArbArgTypes, key::AbstractString)
    haskey(arbargtypes.supported, key) && return arbargtypes.supported[key]
    key in arbargtypes.unsupported && throw(UnsupportedArgumentType(key))
    throw(KeyError(key))
end

# Define the conversions we use for the rest of the code
const arbargtypes = ArbArgTypes(
    Dict{String,DataType}(
        # Primitive
        "void" => Cvoid,
        "int" => Cint,
        "slong" => Int,
        "ulong" => UInt,
        "double" => Float64,
        "complex_double" => ComplexF64,
        "void *" => Ptr{Cvoid},
        "char *" => Cstring,
        "slong *" => Vector{Int},
        "ulong *" => Vector{UInt},
        "double *" => Vector{Float64},
        "complex_double *" => Vector{ComplexF64},
        # gmp.h
        "mpz_t" => BigInt,
        # mpfr.h
        "mpfr_t" => BigFloat,
        "mpfr_rnd_t" => Base.MPFR.MPFRRoundingMode,
        # mag.h
        "mag_t" => Mag,
        # arf.h
        "arf_t" => Arf,
        "arf_rnd_t" => arb_rnd,
        # acf.h
        "acf_t" => Acf,
        # arb.h
        "arb_t" => Arb,
        "arb_ptr" => ArbVector,
        "arb_srcptr" => ArbVector,
        # acb.h
        "acb_t" => Acb,
        "acb_ptr" => AcbVector,
        "acb_srcptr" => AcbVector,
        # arb_poly.h
        "arb_poly_t" => ArbPoly,
        # acb_poly.h
        "acb_poly_t" => AcbPoly,
        # arb_mat.h
        "arb_mat_t" => ArbMatrix,
        # acb_mat.h
        "acb_mat_t" => AcbMatrix,
    ),
    Set(["FILE *", "flint_rand_t"]),
    Dict{DataType,String}(
        # Primitive
        Cvoid => "void",
        Cint => "int",
        Int => "slong",
        UInt => "ulong",
        Float64 => "double",
        ComplexF64 => "complex_double",
        Ptr{Cvoid} => "void *",
        Cstring => "char *",
        Vector{Int} => "slong *",
        Vector{UInt} => "ulong *",
        Vector{Float64} => "double *",
        Vector{ComplexF64} => "complex_double *",
        # gmp.h
        BigInt => "mpz_t",
        # mpfr.h
        BigFloat => "mpfr_t",
        Base.MPFR.MPFRRoundingMode => "mpfr_rnd_t",
        # mag.h
        Mag => "mag_t",
        # arf.h
        Arf => "arf_t",
        arb_rnd => "arf_rnd_t",
        # acf.h
        Acf => "acf_t",
        # arb.h
        Arb => "arb_t",
        ArbVector => "arb_ptr",
        # acb.h
        Acb => "acb_t",
        AcbVector => "acb_ptr",
        # arb_poly.h
        ArbPoly => "arb_poly_t",
        # acb_poly.h
        AcbPoly => "acb_poly_t",
        # arb_mat.h
        ArbMatrix => "arb_mat_t",
        # acb_mat.h
        AcbMatrix => "acb_mat_t",
    ),
)
