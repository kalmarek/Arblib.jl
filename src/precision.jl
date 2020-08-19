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

function Base.setprecision(x::T, precision::Integer) where {T<:Union{Arf,Arb,Acb}}
    return T(x, prec = precision)
end
Base.setprecision(v::ArbVector, precision::Integer) = ArbVector(v.arb_vec, precision)
Base.setprecision(v::AcbVector, precision::Integer) = AcbVector(v.acb_vec, precision)
Base.setprecision(A::ArbMatrix, precision::Integer) = ArbMatrix(A.arb_mat, precision)
Base.setprecision(A::AcbMatrix, precision::Integer) = AcbMatrix(A.acb_mat, precision)
