"""
    Carg{T}(name, isconst)
    Carg(str::AbstractString)

Struct representing a argument to a C function in the Arb library. The
corresponding Julia type is `T`, `name` is the name of the argument,
`isconst` is true if the argument is declared as a const.

```jldoctest
julia> Arblib.ArbCall.Carg("const arb_t x")
Arblib.ArbCall.Carg{Arb}(:x, true)
```
"""
struct Carg{T}
    name::Symbol
    isconst::Bool
end

Carg{T}(name::AbstractString, isconst::Bool) where {T} = Carg{T}(Symbol(name), isconst)

function Carg(str::AbstractString)
    m = match(r"(?<const>const)?\s*(?<type>\w+(\s\*)?)\s+(?<name>\w+)", str)
    isnothing(m) && throw(ArgumentError("string doesn't match c-argument pattern"))
    isconst =
        !isnothing(m[:const]) ||
        (!isnothing(m[:type]) && (m[:type] == "arb_srcptr" || m[:type] == "acb_srcptr"))
    return Carg{arbargtypes[m[:type]]}(m[:name], isconst)
end

name(ca::Carg) = ca.name
isconst(ca::Carg) = ca.isconst
rawtype(::Carg{T}) where {T} = T

Base.:(==)(a::Carg{T}, b::Carg{S}) where {T,S} =
    T == S && name(a) == name(b) && isconst(a) == isconst(b)

"""
    jltype(ca::Carg{T})

The most general Julia type for which we allow automatic conversion to
the [`ctype`](@ref) of `ca`.

These conversations should be done without any loss of information,
for example for floating point numbers we only allow conversion from
types with lower precision. In general the conversion is done using
[`Base.cconvert`](@ref).
"""
jltype(::Carg) = rawtype(ca)
jltype(::Carg{Cint}) = Integer
jltype(::Carg{Int}) = Integer
jltype(::Carg{UInt}) = Unsigned
jltype(::Carg{Cdouble}) = Base.GMP.CdoubleMax
jltype(::Carg{ComplexF64}) = Union{ComplexF16,ComplexF32,ComplexF64}
jltype(::Carg{arb_rnd}) = Union{arb_rnd,RoundingMode}
jltype(::Carg{Base.MPFR.MPFRRoundingMode}) = Union{Base.MPFR.MPFRRoundingMode,RoundingMode}
jltype(::Carg{Cstring}) = AbstractString
jltype(::Carg{Vector{Int}}) = Vector{<:Integer}
jltype(::Carg{Vector{UInt}}) = Vector{<:Unsigned}
jltype(::Carg{Vector{Float64}}) = Vector{<:Base.GMP.CdoubleMax}
jltype(::Carg{Vector{ComplexF64}}) = Vector{<:Union{ComplexF16,ComplexF32,ComplexF64}}
jltype(::Carg{Mag}) = MagLike
jltype(::Carg{Arf}) = ArfLike
jltype(::Carg{Arb}) = ArbLike
jltype(::Carg{Acb}) = AcbLike
jltype(::Carg{ArbVector}) = ArbVectorLike
jltype(::Carg{AcbVector}) = AcbVectorLike
jltype(::Carg{ArbMatrix}) = ArbMatrixLike
jltype(::Carg{AcbMatrix}) = AcbMatrixLike
jltype(::Carg{ArbPoly}) = ArbPolyLike
jltype(::Carg{AcbPoly}) = AcbPolyLike

"""
    ctype(ca::Carg)

The type that should be used for the argument when passed to C code.
"""
ctype(ca::Carg) = rawtype(ca)
ctype(::Carg{T}) where {T<:Union{ArbVector,arb_vec_struct}} = Ptr{arb_struct}
ctype(::Carg{T}) where {T<:Union{AcbVector,acb_vec_struct}} = Ptr{acb_struct}
ctype(::Carg{T}) where {T<:Union{Mag,Arf,Arb,Acb,ArbPoly,AcbPoly,ArbMatrix,AcbMatrix}} =
    Ref{cstructtype(T)}
ctype(::Carg{T}) where {T<:Union{BigFloat,BigInt}} = Ref{T}
ctype(::Carg{Vector{T}}) where {T} = Ref{T}
