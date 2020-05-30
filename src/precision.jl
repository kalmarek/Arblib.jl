const DEFAULT_PRECISION = Ref{Clong}(256)

"""
    precision(<:Union{Arf, Arb, Acb, arf_struct, arb_struct, acb_struct})
    precision(<:Ptr{<:Union{arf_struct, arb_struct, acb_struct}})
    precision(x::Union{arf_struct, arb_struct, acb_struct})
    precision(x::Ptr{<:Union{arf_struct, arb_struct, acb_struct}})
Get the default precision (in bits) currently used for `Arblib` arithmetic.
"""
Base.precision(::Type{<:Union{Arf, Arb, Acb, arf_struct, arb_struct, acb_struct}}) = DEFAULT_PRECISION[]
Base.precision(::Type{<:Ptr{<:Union{arf_struct, arb_struct, acb_struct}}}) = DEFAULT_PRECISION[]
Base.precision(x::Union{arf_struct, arb_struct, acb_struct}) = DEFAULT_PRECISION[]
Base.precision(x::Ptr{<:Union{arf_struct, arb_struct, acb_struct}}) = DEFAULT_PRECISION[]

"""
    setprecision(::Type{<:Union{Arf, Arb, Acb}}, precision::Int)
Set the precision (in bits) to be used for `Arblib` arithmetic.
!!! warning
    This function is not thread-safe. It will affect code running on all threads, but
    its behavior is undefined if called concurrently with computations that use the
    setting.
"""
function Base.setprecision(::Type{<:Union{Arf,Arb,Acb}}, precision::Integer)
    if precision < 2
        throw(DomainError(precision, "`precision` cannot be less than 2."))
    end
    DEFAULT_PRECISION[] = precision
    return precision
end
