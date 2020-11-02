const DEFAULT_PRECISION = Ref{Clong}(256)

"""
    precision(<:Union{Arf, Arb, Acb, arf_struct, arb_struct, acb_struct})
    precision(<:Ptr{<:Union{arf_struct, arb_struct, acb_struct}})
    precision(x::Union{arf_struct, arb_struct, acb_struct})
    precision(x::Ptr{<:Union{arf_struct, arb_struct, acb_struct}})
Get the default precision (in bits) currently used for `Arblib` arithmetic.
"""
Base.precision(::Type{<:Union{ArbTypes,ArbStructTypes}}) = DEFAULT_PRECISION[]
Base.precision(::Type{<:Ptr{<:ArbStructTypes}}) = DEFAULT_PRECISION[]

Base.precision(x::ArbStructTypes) = DEFAULT_PRECISION[]
Base.precision(x::Ptr{<:ArbStructTypes}) = DEFAULT_PRECISION[]
Base.precision(x::ArbTypes) = x.prec
# MagLike <: ArbTypes
Base.precision(x::MagLike) = DEFAULT_PRECISION[]
# disambiguation
Base.precision(::Union{Mag,MagRef}) = DEFAULT_PRECISION[]

@inline _precision(x::ArbTypes) = precision(x)
@inline _precision(x::BigFloat) = precision(x)
@inline _precision(@nospecialize _) = DEFAULT_PRECISION[]

"""
    setprecision(::Type{<:Union{Arf, Arb, Acb}}, precision::Int)
Set the precision (in bits) to be used for `Arblib` arithmetic.
!!! warning
    This function is not thread-safe. It will affect code running on all threads, but
    its behavior is undefined if called concurrently with computations that use the
    setting.
"""
function Base.setprecision(::Type{<:ArbTypes}, precision::Integer)
    if precision < 2
        throw(DomainError(precision, "`precision` cannot be less than 2."))
    end
    DEFAULT_PRECISION[] = precision
    return precision
end

Base.setprecision(x::T, prec::Integer) where {T<:Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}} =
    T(x, prec = prec)
Base.setprecision(v::T, prec::Integer) where {T<:Union{ArbVector,ArbRefVector}} =
    T(v.arb_vec, prec)
Base.setprecision(v::T, prec::Integer) where {T<:Union{AcbVector,AcbRefVector}} =
    T(v.acb_vec, prec)
Base.setprecision(A::T, prec::Integer) where {T<:Union{ArbMatrix,ArbRefMatrix}} =
    T(A.arb_mat, prec)
Base.setprecision(A::T, prec::Integer) where {T<:Union{AcbMatrix,AcbRefMatrix}} =
    T(A.acb_mat, prec)

Base.setprecision(poly::ArbPoly, prec::Integer) = ArbPoly(poly.arb_poly, prec = prec)
Base.setprecision(series::ArbSeries, prec::Integer) =
    ArbSeries(series.arb_poly, degree(series); prec = prec)
Base.setprecision(poly::AcbPoly, prec::Integer) = AcbPoly(poly.acb_poly, prec = prec)
Base.setprecision(series::AcbSeries, prec::Integer) =
    AcbSeries(series.acb_poly, degree(series); prec = prec)
