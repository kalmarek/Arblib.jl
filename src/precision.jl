const DEFAULT_PRECISION = Ref{Int}(256)

if VERSION < v"1.8.0"
    # Types
    Base.precision(::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}}) =
        DEFAULT_PRECISION[]
    # Types not storing their precision
    Base.precision(x::Union{ArbStructTypes,Ptr{<:ArbStructTypes}}) = DEFAULT_PRECISION[]
    # Types storing their precision
    Base.precision(x::ArbTypes) = x.prec
    # Mag doesn't store a precision
    Base.precision(::MagOrRef) = DEFAULT_PRECISION[]
    # ArbSeries and AcbSeries don't store their precision directly
    Base.precision(x::Union{ArbSeries,AcbSeries}) = precision(x.poly)
else
    # Since Julia 1.8.0 Base.precision calls Base._precision and by
    # overloading that we automatically support giving base argument.

    # Types
    if VERSION < v"1.11.0-DEV"
        Base._precision(::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}}) =
            DEFAULT_PRECISION[]
        # Types not storing their precision
        Base._precision(::Union{ArbStructTypes,Ptr{<:ArbStructTypes}}) = DEFAULT_PRECISION[]
        # Types storing their precision
        Base._precision(x::ArbTypes) = x.prec
        # Mag doesn't store a precision
        Base._precision(::MagOrRef) = DEFAULT_PRECISION[]
        # ArbSeries and AcbSeries don't store their precision directly
        Base._precision(x::Union{ArbSeries,AcbSeries}) = Base._precision(x.poly)
    else
        Base._precision_with_base_2(
            ::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}},
        ) = DEFAULT_PRECISION[]
        # Types not storing their precision
        Base._precision_with_base_2(::Union{ArbStructTypes,Ptr{<:ArbStructTypes}}) =
            DEFAULT_PRECISION[]
        # Types storing their precision
        Base._precision_with_base_2(x::ArbTypes) = x.prec
        # Mag doesn't store a precision
        Base._precision_with_base_2(::MagOrRef) = DEFAULT_PRECISION[]
        # ArbSeries and AcbSeries don't store their precision directly
        Base._precision_with_base_2(x::Union{ArbSeries,AcbSeries}) =
            Base._precision_with_base_2(x.poly)
    end

    # Base.precision only allows AbstractFloat, we want to be able to use
    # all ArbLib types.
    Base.precision(
        T::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}};
        base::Integer = 2,
    ) = Base._precision(T, base)
    Base.precision(
        x::Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}};
        base::Integer = 2,
    ) = Base._precision(x, base)
end

# Used internally for determining the precision
@inline _precision(x::Union{ArbTypes,BigFloat}) = precision(x)
@inline _precision(z::Complex) = max(_precision(real(z)), _precision(imag(z)))
@inline _precision(v::Union{Tuple,AbstractVector}) =
    isempty(v) ? DEFAULT_PRECISION[] : _precision(first(v))
@inline _precision(
    a::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}},
    b::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}},
) = max(_precision(a), _precision(b))
@inline _precision(a::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}}, _) =
    _precision(a)
@inline _precision(_, b::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}}) =
    _precision(b)
@inline _precision(a, b) = max(_precision(a), _precision(b))
@inline _precision(@nospecialize _) = DEFAULT_PRECISION[]

"""
    setprecision(::Type{<:ArbTypes}, precision::Int; base::Integer = 2)

Set the precision (in bits) to be used for `Arblib` arithmetic. Note
that the precision is shared for all types, it doesn't matter which
type you use to set the precision.

If `base` is specified, then the precision is the minimum required to
give at least `precision` digits in the given `base`.

!!! warning
    This function is not thread-safe. It will affect code running on all threads, but
    its behavior is undefined if called concurrently with computations that use the
    setting.
"""
function Base.setprecision(::Type{<:ArbTypes}, precision::Integer; base::Integer = 2)
    base > 1 || throw(DomainError(base, "`base` cannot be less than 2."))
    precision > 1 || throw(DomainError(precision, "`precision` cannot be less than 2."))
    DEFAULT_PRECISION[] = base == 2 ? precision : ceil(Int, precision * log2(base))
    return precision
end

function Base.setprecision(x::T, precision::Integer; base::Integer = 2) where {T<:ArbTypes}
    base > 1 || throw(DomainError(base, "`base` cannot be less than 2."))
    precision > 1 || throw(DomainError(precision, "`precision` cannot be less than 2."))
    return T(x, prec = base == 2 ? precision : ceil(Int, precision * log2(base)))
end
